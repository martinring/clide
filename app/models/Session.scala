package models

import js._
import isabelle._
import scala.actors.Actor._
import play.api.libs.json._
import scala.io.Source
import models.ace.RemoteDocument

class Session(project: Project) extends JSConnector {
  val docs = scala.collection.mutable.Map[Document.Node.Name,RemoteDocument]()
  
  val thyLoad = new Thy_Load {
    override def read_header(name: Document.Node.Name): Thy_Header = {
      val file = new java.io.File(name.node)
      if (!file.exists || !file.isFile) error("No such file: " + quote(file.toString))
      Thy_Header.read(file)
    }
  }
  
  val session = new isabelle.Session(thyLoad)    
  
  session.phase_changed += { phase =>    
    js.ignore.setPhase(phase.toString)
    phase match {
      case Session.Ready =>
        js.ignore.setFiles(project.theories)
        js.ignore.setLogic(project.logic)
      case _ =>
    }
  }
      
  session.syslog_messages += { msg =>
    js.ignore.println(Pretty.str_of(msg.body))    
  }      
  
  session.caret_focus += { x =>
    println("caret focus: " + x)
  }
  
  session.global_settings += { x =>
    println("settings: " + x)
  }
  
  session.commands_changed += { change =>
    change.nodes.foreach { node =>      
      val snap = session.snapshot(node, Nil)      
      val status = Protocol.node_status(snap.state, snap.version, snap.node)
      js.ignore.status(
          node.toString, 
          status.unprocessed,
          status.running,
          status.finished,
          status.warned,
          status.failed)
    }
    change.commands.foreach { cmd =>
      val node = cmd.node_name
      val snap = session.snapshot(node, Nil)
      val start = snap.node.command_start(cmd)
      val state = snap.state.command_state(snap.version, cmd)
      state.results.foreach { case (a,b) =>
        //js.ignore.result(cmd.node_name, b)
      }
      js.ignore.commandChanged(cmd.node_name.toString, cmd.name, cmd.span.map(_.content))
    }
  }
    
  def name(path: String) =
    Document.Node.Name(Path.explode(project.dir + path))  
   
  def node_header(name: isabelle.Document.Node.Name): isabelle.Document.Node_Header = Exn.capture {
    thyLoad.check_header(name,
      thyLoad.read_header(name))
  }
  
  js.convert = js.convert.orElse {    
    case t: Thy_Header => JsObject {
      "name" -> Json.toJson(t.name) ::
      "imports" -> Json.toJson(t.imports) ::
      "keywords" -> Json.toJson(t.keywords map { 
        case (a,Some((b,c))) => JsObject(
            "name" -> Json.toJson(a) ::            
            Nil)
        case (a,None) => JsObject(
            "name" -> Json.toJson(a) ::
            Nil)
      }) ::
      "uses" -> JsArray(t.uses.map{ 
        case (a,b) => JsObject(
            "name" -> Json.toJson(a) ::
            "is" -> Json.toJson(b) ::
            Nil) 
      }) ::      
      Nil
    } 
  }
  
  val actions: PartialFunction[String, JsValue => Any] = {     
    case "getTheories" => json =>            
      project.theories
      
    case "open" => json => 
      val name = (json \ "id").as[String]
      val path = (json \ "path").as[String]
      val node = this.name(path)
      
      val doc = this.docs.getOrElseUpdate(node, {
        val text = Source.fromFile(project.dir + path).getLines.toSeq
        val doc = new RemoteDocument()        
        doc.insertLines(0, text :_*)        
       session.init_node(node, node_header(node), Text.Perspective.full, doc.mkString)
        doc
      })
            
      doc.mkString
      
    case "new" => json =>      
      
    case "close" => json =>
      val nodeName = json.as[String]
      println("close " + nodeName)      
      
    case "edit" => json =>
      val nodeName = name((json \ "path").as[String])
      val deltas = (json \ "deltas").as[Array[ace.Delta]]
      docs.get(nodeName).map(doc => 
        session.edit_node(nodeName, node_header(nodeName), Text.Perspective.full, doc.edit(deltas.toVector))
      )
      
    case "changePerspective" => json =>
      val nodeName = name((json \ "path").as[String])
      val start = (json \ "start").as[Int]
      val end = (json \ "end").as[Int]      
      println("change perspective of " + nodeName + " to " + start + " -> " + end)
      
    case "moveCursor" => json =>
      val nodeName = name((json \ "path").as[String])
      val pos = (json \ "pos").as[ace.Position]
      println("move cursor: " + nodeName + " " + pos)
  }
  
  override def onClose() {
    session.stop();
  }
  
  session.start(Nil)
}