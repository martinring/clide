package actors

import js.JSConnector
import scala.collection.mutable.Queue
import scala.io.Source
import akka.actor._
import akka.event.Logging
import isabelle._
import models.Project
import play.api.Logger
import play.api.libs.iteratee.Concurrent.Channel
import play.api.libs.json.JsValue
import models.ace.RemoteDocument
import js.DynamicJsValue

object SessionActor {  
  case class Raw(msg: Any)
  case class Open(name: Document.Node.Name, doc: RemoteDocument[Scan.Context])
  case class Pause(name: Document.Node.Name)
  case class Start(name: Document.Node.Name)
  case class Close(name: Document.Node.Name)
}

class SessionActor(project: Project) extends Actor with JSConnector {  
  val log = Logging(context.system, SessionActor.this)

  import SessionActor._
    
  val thy_load = new Thy_Load {
    // TODO: Include DocActors
  }
  
  /** the associated isabelle prover session **/
  val session: Session = new Session(thy_load)
    
  val docs = scala.collection.mutable.Map[Document.Node.Name,ActorRef]()
  
  /** postponed actions that are executed when session becomes ready */
  val postponed = Queue[() => Unit]()
  
  /**
   * Execute a piece of code only if the session is ready. Otherwise postpone the action and 
   * execute it when the session phase changes to ready 
   */
  def whenReady(f: => Unit) = session.phase match {
    case Session.Ready => f
    case _ => postponed.enqueue(f _)
  } 
  
  /**
   * Executes all postponed actions in order and then clears the queue
   */
  def executePostponed() {
    postponed.foreach(_())
    postponed.clear()
  }
  
  override def preStart() {
    Logger.debug("initializing isabelle session for " + project)
    session.phase_changed += Forwarder(self)
    session.commands_changed += Forwarder(self)
    //session.raw_output_messages += Forwarder(self,Raw)
    //session.all_messages += Forwarder(self,Raw)
    session.start(List("HOL"))
    val basePath = "data/" + project.owner + "/" + project.name + "/"
  }
  
  override def postStop() {   
    session.stop()    
  }
 
  def handlePhaseChange(phase: Session.Phase) = phase match {
    case Session.Ready =>
      log.info(Session.Ready.toString())
      executePostponed()
    case other =>
      log.info(other.toString())
  }
  
  def handleCommandsChange(change: Session.Commands_Changed) = {
    change.nodes.foreach{ node =>
      docs.get(node).map(_ ! change)
    }    
  }
  
  val actions: PartialFunction[String, DynamicJsValue => Any] = {
    case "getFiles" => json =>
      "none"
  }
  
  def receive = {    
    case phaseChange: Session.Phase =>
      js.ignore.phaseChange(phaseChange.toString)
      handlePhaseChange(phaseChange)
    case commandChange: Session.Commands_Changed =>
      handleCommandsChange(commandChange)
    case Raw(msg) => 
      println(msg)
    case Open(name, doc) =>
      val sender = SessionActor.this.sender
      whenReady {
        docs.get(name) match {
          case None =>
            log.info("initializing " + name)
	        val documentActor = context.actorOf(Props(new DocumentActor(name, doc, session, thy_load)))
	        sender ! documentActor
	        docs(name) = documentActor
          case Some(actor) =>            
            sender ! actor
        } }
    case Pause(name) => docs.get(name) match {
      case Some(act) => act ! DocumentActor.Pause
      case None => log.error("trying to pause " + name + " which is not opened")
    }
    case Start(name) => docs.get(name) match {
      case Some(act) => act ! DocumentActor.Start
      case None => log.error("trying to start " + name + " which is not opened")
    }
    case Close(name) => docs.get(name) match {
      case Some(act) => act ! DocumentActor.Close
      case None => log.error("trying to close " + name + " which is not opened")
    }      
  }
}