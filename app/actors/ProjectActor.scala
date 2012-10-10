package actors

import akka.actor.Actor
import akka.event.Logging
import isabelle._
import play.api.libs.iteratee.Concurrent.Channel
import play.api.libs.json.JsValue
import scala.collection.mutable.Queue
import models.Project
import play.api.Logger
import play.api.Play.current
import scala.io.Source
import play.api.libs.concurrent.Akka
import akka.actor.Props
import isabelle.Session.Commands_Changed

object ProjectActor {
  case class PhaseChanged(msg: Any)
  case class Syslog(msg: Any)
  case class CommandsChanged(msg: Any)
  case class Open(path: String, channel: Channel[JsValue])
  case class Pause(path: String)
  case class Start(path: String)
  case class Close(path: String)
  case class Forward(path: String, msg: Any)
}

class ProjectActor(
    project: Project) extends Actor {  
  val log = Logging(context.system, this)
  
  import ProjectActor._
        
  /* the associated isabelle prover session */
  val session: Session = new Session
  val thy_load = new Thy_Load
  
  /* the websocket broadcasting channels for open theory sessions */
  val channels = scala.collection.mutable.Map[String,Channel[JsValue]]()
  
  /* postponed actions that are executed when session becomes ready */
  val postponed = Queue[() => Unit]()
  
  /* 
   * Execute a piece of code only if the session is ready. Otherwise postpone the action and 
   * execute it when the session phase changes to ready 
   */
  def whenReady(f: => Unit) = session.phase match {
    case Session.Ready => f
    case _ => postponed.enqueue(f _)
  } 
  
  /*
   * Executes all postponed actions in order and then clears the queue
   */
  def executePostponed() {
    postponed.foreach(_())
    postponed.clear()
  }
  
  override def preStart() {
    Logger.debug("initializing isabelle session for " + project)   
    session.phase_changed += WrapperActor(self, PhaseChanged)
    session.commands_changed += WrapperActor(self, CommandsChanged)
    session.start(List("HOL"))
    val basePath = "data/" + project.owner + "/" + project.name + "/"
  }
 
  def receive = {    
    case PhaseChanged(Session.Ready) =>
      log.info("ready")
      executePostponed()
    case PhaseChanged(_) =>
      log.info("phase: " + session.phase)
    case CommandsChanged(cmds: Commands_Changed) =>
      cmds.commands.foreach { command =>        
        log.info(command.span.toString)
      }      
    case Open(path, channel) =>
      val sender = this.sender
      whenReady {
        log.info("initializing " + path)      
        val filePath = "data/" + project.owner + "/" + project.name + "/" + path
        val lines = Source.fromFile(filePath).getLines.toList        
        val text = lines.mkString("\n")
        val nodeName = Document.Node.Name(Path.explode(filePath))
        val header = Exn.capture { thy_load.check_header(nodeName, Thy_Header.read(text)) }
        session.init_node(nodeName, header, Text.Perspective.full, text)
        val documentActor = context.actorOf(Props(new DocumentActor(nodeName, lines.iterator, channel, session)))
        sender ! documentActor
      }
    case Pause(path) => 
    case Start(path) => 
    case Close(path) => 
    case Forward(path,msg) =>
      log.info("message for " + path + ": " + msg)
  }
}