package models

import akka.actor.Actor
import akka.actor.Props
import akka.event.Logging
import scala.collection.mutable.ArrayBuffer

class DocumentActor(val newline: String = "\n") extends Actor {
  val log = Logging(context.system, this)

  val document = ArrayBuffer[String]("")
  var indices = List(0)

  def receive = {
    case deltas: Array[Delta] ⇒
      for (delta ← deltas) delta match {
        case InsertText(range, text) ⇒ if (text == "\r\n" || text == "\n") {
          val (left, right) = document(range.start.row).splitAt(range.start.column)
          document(range.start.row) = left
          document.insert(range.start.row + 1, right)
        } else if (!text.contains("\n")) {
          document(range.start.row) = {
            val row = document(range.start.row)
            row.take(range.start.column) + text + row.drop(range.start.column)
          }
        } else sys.error("insert text contains newlines")

        case RemoveText(range, text) ⇒ if (text == "\r\n" || text == "\n") {
          document(range.start.row) += document(range.start.row + 1)
          document.remove(range.start.row + 1)
        } else if (!text.contains("\n")) {
          document(range.start.row) = {
            val row = document(range.start.row)
            row.take(range.start.column) + row.drop(range.end.column)
          }
        } else sys.error("remove text contains newlines")

        case InsertLines(range, lines) ⇒
          document.insertAll(range.start.row, lines)

        case RemoveLines(range, lines) ⇒
          document.remove(range.start.row, range.end.row - range.start.row)
      }

      indices = document.foldLeft(List(0)) {
        case (indices, row) ⇒ (indices.head + newline.length + row.length) :: indices
      }.tail.reverse
      
      log.info("processed document changes")
  }
}