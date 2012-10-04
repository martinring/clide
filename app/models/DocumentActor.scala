package models

import akka.actor.Actor
import akka.actor.Props
import akka.event.Logging
import scala.collection.mutable.ArrayBuffer
import akka.actor.ActorRef
import play.api.libs.iteratee.Concurrent.Channel
import isabelle.Document.Node.Name
import isabelle.Session
import play.api.libs.json._

class DocumentActor(
    val channel: Channel[JsValue],    
    val newline: String = "\n") extends Actor {
  val log = Logging(context.system, this)
  
  var version = 0: Long
  
  val lines = ArrayBuffer[String]("")
  
  implicit def indices: Vector[isabelle.Text.Offset] = {
    val lengths = lines.toList.map(_.length())
    lengths.foldLeft(Vector(0)){
      case (v, l) => v :+ (v.last + l + newline.length)
    }
  }
  
  def applyDelta(delta: Delta): Unit = delta match {
    case InsertNewline(range) =>
      val (left, right) = lines(range.start.row).splitAt(range.start.column)
      lines(range.start.row) = left
      lines.insert(range.end.row, right)
      println("+ newline " + range.toOffsets)
      
    case RemoveNewline(range) =>
      println("- newline " + range.toOffsets)
      lines(range.start.row) += lines(range.end.row)
      lines.remove(range.end.row)
      

    case ReplaceText(range, text) =>
      println("§ " + text + " " + range.toOffsets)
      applyDelta(RemoveText(range,null))
      applyDelta(InsertText(range,text))
      
    case InsertText(range,text) =>
      val row = lines(range.start.row)
      lines(range.start.row) = row.take(range.start.column) + text + row.drop(range.start.column)
      println("+ " + text + " " + range.toOffsets)
      
    case RemoveText(range, text) =>
      println("- " + text + " " + range.toOffsets)
      val row = lines(range.start.row)
      lines(range.start.row) = row.take(range.start.column) + row.drop(range.end.column)

    case InsertLines(range, lines) =>
      this.lines.insertAll(range.start.row, lines)
      println("+ " + lines.length + " lines " + range.toOffsets)
      
    case RemoveLines(range, lines) =>
      println("- " + lines.length + " lines " + range.toOffsets)      
      this.lines.remove(range.start.row, range.end.row - range.start.row)
      
    case NoChange =>      
  }
  
  def receive = {
    case deltas: Array[Delta] =>
      // optimize twice for better performance
      val optimized = Delta.optimize(Delta.optimize(deltas.toVector))
      println()
      for (delta <- optimized) {
    	applyDelta(delta)
      }
      
      version += 1
      
      lines.zipWithIndex.foreach{ case (line,index) =>
        channel.push(JsObject(
	        "type" -> JsString("row") ::
	        "version" -> JsNumber(version) ::
	        "index" -> JsNumber(index) ::
	        "row" -> Json.toJson(Array(Token("string", line))) :: Nil
        ))
      }
      
      println("-- version " + version.toString.padTo(5, ' ') + " ----------------")
      lines.foreach(println)
      println(indices)
  }
}