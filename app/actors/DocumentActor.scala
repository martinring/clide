package actors

import akka.actor.Actor
import akka.event.Logging
import scala.collection.mutable.Buffer
import play.api.libs.iteratee.Concurrent.Channel
import isabelle._
import isabelle.Text.Edit
import play.api.libs.json._
import models.Delta
import models.InsertLines
import models.InsertNewline
import models.InsertText
import models.NoChange
import models.RemoteDocument
import models.RemoveLines
import models.RemoveNewline
import models.RemoveText
import models.ReplaceText
import models.Token
import scala.math.BigDecimal.int2bigDecimal
import scala.math.BigDecimal.long2bigDecimal

class DocumentActor(    
    val name: Document.Node.Name,
    val lines: Iterator[String],
    val channel: Channel[JsValue],
    val session: Session,
    val newline: String = "\n") extends Actor {  
  val log = Logging(context.system, this)
  
  val doc = new RemoteDocument(newline)  
  doc.insertLines(0, lines.toSeq :_*)
  val edits = Buffer[Edit]()
  
  var version = 0: Long
  
  def applyDelta(delta: Delta): Unit = delta match {
    case InsertNewline(range) =>
      edits += doc.splitLine(range.start.row, range.start.column)
    case RemoveNewline(range) =>
      edits += doc.mergeLines(range.end.row)
    case ReplaceText(range, text) =>
      edits += doc.removeText(range.start.row, range.start.column, text.length)
      edits += doc.insertText(range.start.row, range.start.column, text)
    case InsertText(range,text) =>
      edits += doc.insertText(range.start.row, range.start.column, text)
    case RemoveText(range, text) =>
      edits += doc.removeText(range.start.row, range.start.column, text.length)
    case InsertLines(range, lines) =>
      edits += doc.insertLines(range.start.row, lines :_*)
    case RemoveLines(range, lines) =>
      edits += doc.removeLines(range.start.row, lines.length)

    case NoChange =>      
  }
  
  def receive = {
    case deltas: Array[Delta] =>      
      val optimized = Delta.optimize(Delta.optimize(deltas.toVector))      
      for (delta <- optimized) applyDelta(delta)      
      version += 1      
      val iedits = Document.Node.Edits[Text.Edit,Text.Perspective](edits.toList)
      println(iedits)
      session.edit(List((name,iedits)))
      edits.clear()
//      for (i <- 0 until doc.length) {
//        val line = doc(i)
//        channel.push(JsObject(
//	      "type" -> JsString("row") ::
//	      "version" -> JsNumber(version) ::
//	      "index" -> JsNumber(i) ::
//	      "row" -> Json.toJson(Array(Token("string", line))) :: Nil
//        ))
//      }      
  }
}