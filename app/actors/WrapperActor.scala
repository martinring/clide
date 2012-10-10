package actors

import akka.actor.actorRef2Scala

/**
 * Threadless helper for passing messages from scala actors to akka actors and decorating them with 
 * a decorator function
 */
case class WrapperActor(rec: akka.actor.ActorRef, decorator: Any => Any) extends scala.actors.Actor {
  this.start()
  def act() {
    scala.actors.Actor.loop {
      scala.actors.Actor.react {
        case m => rec ! decorator(m)
      }
    }
  }  
}