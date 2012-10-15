package actors

import akka.actor.actorRef2Scala

/**
 * Threadless helper for passing messages from scala actors to akka actors and decorating them with 
 * a decorator function. This is needed for interoperability of the isabelle system which is heavily
 * based on scala actors and self defined event busses and the akka based clide system
 */
private[actors] 
case class Forwarder(rec: akka.actor.ActorRef, decorator: Any => Any = identity) extends scala.actors.Actor {
  this.start()
  def act() {
    scala.actors.Actor.loop {
      scala.actors.Actor.react {
        case m => rec ! decorator(m)
      }
    }
  }
}