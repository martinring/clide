package models

import js._
import isabelle._
import scala.actors.Actor._

class Session(user: String, project: String) extends JSConnector {  
  val thyLoad = new Thy_Load {
    // TODO
  }
  
  val session = new isabelle.Session(thyLoad)
  
  session.phase_changed += { phase =>    
    js.ignore.setPhase(phase.toString)
  }    
  
  session.commands_changed += { change =>
    change.commands.foreach { cmd =>
      js.ignore.commandChanged(cmd.node_name, cmd.name)
    }
  }
  
  val actions: PartialFunction[String, DynamicJsValue => Any] = {
    case "getFiles" => json =>
      val dir = new java.io.File("data/" + user + "/" + project + "/")
      println(dir)
      val children = dir.listFiles()
      println(children)
      children.map(_.getName())
  }
  
  override def onClose() {
    session.stop();
  }
  
  session.start(Nil)
}