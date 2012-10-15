package models.ace

import play.api.libs.json._
import scala.Array.canBuildFrom
import scala.math.BigDecimal.int2bigDecimal

trait Delta {
  val range: Range
  def + (other: Delta): Option[Delta]
}

object NoChange extends Delta {
  val range: Range = Range(Position(0,0),Position(0,0))
  def + (other: Delta) = Some(other)
}

case class ReplaceText(range: Range, text: String) extends Delta {
  def + (other: Delta) = other match {
    case ReplaceText(range, text) if this.range.end == range.start =>
      Some(ReplaceText(Range(this.range.start, range.end), this.text + text))
    case r@ReplaceText(range, text) if this.range == range => Some(r)
    case _ => None
  }
}

case class InsertNewline(range: Range) extends Delta {
  def + (other: Delta) = other match {
    case RemoveNewline(range) if this.range == range => Some(NoChange)    
    case _ => None
  } 
} 
case class RemoveNewline(range: Range) extends Delta {
  def + (other: Delta) = other match {
    case InsertNewline(range) if this.range == range => Some(NoChange)
    case _ => None
  }
}

case class InsertLines(range: Range, lines: Array[String]) extends Delta {
  def + (other: Delta) = other match {
    case InsertLines(range, lines) if this.range.end == range.start =>
      Some(InsertLines(Range(this.range.start,range.end), this.lines ++ lines))
    case RemoveLines(range, lines) if this.range == range => Some(NoChange)
    case _ => None
  }
}

case class RemoveLines(range: Range, lines: Array[String]) extends Delta {
  def + (other: Delta) = other match {
    case RemoveLines(range, lines) if this.range.start == range.end =>
      Some(RemoveLines(Range(range.start,this.range.end), lines ++ this.lines))
    case InsertLines(range, lines) if this.range == range => Some(NoChange)
    case _ => None
  }
}

case class InsertText(range: Range, text: String) extends Delta {
  def + (other: Delta) = other match {
    case InsertText(range, text) if this.range.end == range.start =>
      Some(InsertText(Range(this.range.start,range.end), this.text + text))
    case InsertNewline(range) if this.range.start.column == 0 && this.range.end == range.start =>
      Some(InsertLines(Range(this.range.start,range.end), Array(this.text)))
    case RemoveText(range, text) if this.range == range => Some(NoChange)
    case RemoveText(range, text) if this.range.end == range.end => 
      if (range.start.column < this.range.start.column) Some(RemoveText(
          Range(range.start, this.range.start), 
          text.take(this.range.start.column - range.start.column)))
      else Some(InsertText(
          Range(this.range.start, range.start),
          this.text.take(range.start.column - this.range.start.column)))
    case _ => None
  }
}

case class RemoveText(range: Range, text: String) extends Delta {
  def + (other: Delta) = other match {
    case RemoveText(range, text) if this.range.start == range.end =>
      Some(RemoveText(Range(range.start,this.range.end), text + this.text))
    case InsertText(range, text) if this.range == range =>
      if (this.text == text) Some(NoChange)
      else Some(ReplaceText(range, text))
    case _ => None
  }
}

case class Position(row: Int, column: Int) {
  override def toString = row + ":" + column
  def toOffset (implicit indices: Vector[isabelle.Text.Offset]) = indices(row) + column
} 

case class Range(start: Position, end: Position) {
  def toOffsets (implicit indices: Vector[isabelle.Text.Offset]) = (start.toOffset, end.toOffset)
  def length = end.row - start.row
  override def toString = "[" + start + "->" + end + "]"
}

object Position {
  implicit object Format extends Format[Position] {
    def reads(json: JsValue): JsResult[Position] = for {
      row <- Json.fromJson[Int](json \ "row")
      column <- Json.fromJson[Int](json \ "column")
    } yield Position(row, column)
    def writes(pos: Position): JsValue = JsObject(
        "row" -> JsNumber(pos.row) ::
        "column" -> JsNumber(pos.column) :: Nil)
  }  
}

object Range {
  implicit object Format extends Format[Range] {
    def reads(json: JsValue): JsResult[Range] = for {
      start <- Json.fromJson[Position](json \ "start")
      end <- Json.fromJson[Position](json \ "end")      
    } yield Range(start, end)
    def writes(range: Range): JsValue = JsObject(
        "start" -> Json.toJson(range.start) ::
        "end" -> Json.toJson(range.end) :: Nil)
  }  
}

object Delta {
  def optimize(deltas: Vector[Delta]): Vector[Delta] = deltas.tail.foldLeft(Vector(deltas.head)){
    case (deltas, delta) => (deltas.last + delta) match {
      case Some(combined) => deltas.init :+ combined
      case None => deltas :+ delta
    }
  }
  
  implicit object Format extends Reads[Delta] {
    def reads(json: JsValue): JsResult[Delta] = for {
      range <- Json.fromJson[Range](json \ "range")      
      result <- Json.fromJson[String](json \ "action") map {
        case "insertLines" => InsertLines(range, (json \ "lines").as[Array[String]])
        case "removeLines" => RemoveLines(range, (json \ "lines").as[Array[String]])
        case "insertText" if range.length == 0 => InsertText(range, (json \ "text").as[String])
        case "insertText" if range.length == 1 => 
          if (range.start.column == 0) InsertLines(range, Array(""))
          else InsertNewline(range)
        case "removeText" if range.length == 0 => RemoveText(range, (json \ "text").as[String])
        case "removeText" if range.length == 1 => RemoveNewline(range)
      }
    } yield result          
  }  
}