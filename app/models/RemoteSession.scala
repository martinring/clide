package models

import scala.collection.mutable.ArrayBuffer
import play.api.libs.iteratee._
import play.api.libs.json._
import akka.actor.ActorDSL._
import concurrent.util.duration._
import play.api.Play.current
import play.api.libs.concurrent.Akka
import akka.actor.Props

class RemoteSession() {  
  val (out, channel) = Concurrent.broadcast[JsValue]
    
  val document = Akka.system.actorOf(Props(new DocumentActor))
  
  val in = Iteratee.foreach[JsValue] { deltas ⇒
    document ! deltas.as[Array[Delta]]
  }
}