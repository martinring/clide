package models

import scala.collection.mutable.ArrayBuffer
import play.api.libs.iteratee._
import play.api.libs.json._
import concurrent.util.duration._
import play.api.Play.current
import play.api.libs.concurrent.Akka
import akka.actor.Props
import scala.io.Source
import scala.concurrent.util.duration._
import isabelle.{Session,Path,Thy_Load,Exn,Thy_Header,Text,Isabelle_System,Scan,Time}
import actors.DocumentActor

//object RemoteSession {
//  private val sessions = scala.collection.mutable.Map[(String,String),(Session,Thy_Load)]()
//  def getSession(user: String, project: String) = Akka.future{
//    sessions.getOrElseUpdate((user, project), {
//     val session = new Session
//     session.start(Time.seconds(5), List("HOL"))
//     while(session.phase != Session.Ready) {
//       Thread.sleep(200) // FIXME...
//     }
//     (session, new Thy_Load)
//    })
//  }
//}
//
//class RemoteSession(user: String, project: String, path: String) {  
//  val (out, channel) = Concurrent.broadcast[JsValue]
//  
////  val (session,thy_load) = RemoteSession.getSession(user,project).result(5 seconds)
////  
////  val nl = "\n"
//  val filePath = "data/" + user + "/" + project + "/" + path
//  val lines = Source.fromFile(filePath).getLines
////  val node_name = isabelle.Document.Node.Name(Path.explode(filePath))
////  val header = Exn.capture { thy_load.check_header(node_name, Thy_Header.read(text)) }
////  session.init_node(node_name, header, Text.Perspective.full, text)
////  println(header)
////  
//  
//  val document = Akka.system.actorOf(Props(new DocumentActor(lines, channel, null)))
////  
//  val in = Iteratee.foreach[JsValue] { deltas =>
//    document ! deltas.as[Array[Delta]]
//  }
//}