package models

import scala.actors.Actor
import scala.io.Source
import isabelle.Thy_Load
import isabelle._
import play.api.libs.iteratee._
import play.api.libs.json.JsValue

object Isabelle
{
  var session: Option[Session] = None

  def start(logic: String, thys: List[String]) {
    val thy_load = new Thy_Load()
    val thy_info = new Thy_Info(thy_load)

    Isabelle_System.init()

    val s = new Session(thy_load)
    val smgr = new SessionActor(s, thys)
 
    println("Starting actors...")
    s.phase_changed += smgr 
    smgr.start()
    /* Start session */
    println("Starting sesssion...")
    s.start(Time.seconds(30), List(logic))
    println("All started.")
  }
}

class SessionActor(val s: Session, val thys: List[String]) extends Actor {
  def act () {
    loop { react {
      case Session.Ready => 
        Isabelle.session = Some(s); 
        println("Isabelle is ready.")
        val rm= new RawMsgActor("Raw message")
        s.raw_output_messages += rm
        // The output from s.raw_messages is voluminous, but 
        // it seems not the be the case that s.raw_output_messages
        // contains exactly Result messages from s.raw_messages, so we have
        // to sift through it...
        rm.start()
        // s.syslog_messages += rm -- same holds for syslog
        for (thy<- thys) FileServer.read(thy)
      case Session.Failed => Isabelle.session = None
    }}
  }
}


class RawMsgActor(val pre : String) extends Actor {
  def act () {
    loop { react {
        case result: Isabelle_Process.Message =>
          println(pre+ ": "+ result) 
        // case input: Isabelle_Process.Input =>
        //   println("Raw input: "+ input)  // These are not that interesting
        // case bad => System.err.println("Raw output: ignoring bad message " + bad)
      }
    }
  }
}

object FileServer {
  var out = Enumerator.imperative[JsValue]()
  var thyDir = "/home/cxl/src/isabelle/pide-test/theories/"; /* Just the default value */ 
   
  def readFile(name : String) : String = {
    val src = Source.fromFile(thyDir + name)
    val lines = src.mkString
    src.close()
    return lines
  }
 
  def read(name: String) {
    Isabelle.session match {
      case Some(s) => 
        val nn  = isabelle.Document.Node.Name(Path.explode(name))
        val txt = readFile(name)
        val thy_load = new Thy_Load
        val header = Thy_Header.read(txt) 
        val node_imports = header.imports.map(name => isabelle.Document.Node.Name(name, "", name))
        val node_header: isabelle.Document.Node_Header =
        	Exn.Res(isabelle.Document.Node.Deps(node_imports, header.keywords, header.uses))       
         // Thy_Header.check(nn.theory, txt) }
        val rng = Text.Range(0, txt.length)
        val per = Text.Perspective(List(rng))
        val f   = new FileActor(s, nn, txt)
        s.commands_changed += f
        f.start()
        s.init_node(nn, node_header, per, txt)          
      case None =>
	    println("Isabelle not ready yet-- try again later.")
	}
  }
}

class FileActor(val s: Session, val name: isabelle.Document.Node.Name, val txt: String) extends Actor {
    def act () {
        loop { react {
            case Session.Commands_Changed(true, nodes, cmds) =>
            // The nodes (i.e. theory files) and cmds are actually just upper bounds 
            // of the region of the document affected by the change. 
            // If you want to look at them, use this:
            //   println("Node: "+ nodes+ ", command tokens: "+ cmds.map (c=> c.span))
            //   println("Node: "+ nodes+ ", command source: "+ cmds.map (c=> c.source))
            // It turns out that e.g. the order of the cmds is irrelevant (unsurprisingly, given that they are a set).
            // This piece of code extracts the source and the markup of the affected nodes:
           for ( name<-nodes; snap= s.snapshot(name, List()); (cmd, off) <- snap.node.command_range() ) {
             //println(cmd.name)
             println("Command: " + cmd.name)
             println(cmd.node_name.toString)               
        }}}
    }
}
