package models

import play.api.libs.json._

trait Delta {
  val range: Range
}

case class InsertLines(range: Range, lines: Array[String]) extends Delta
case class RemoveLines(range: Range, lines: Array[String]) extends Delta
case class InsertText(range: Range, text: String) extends Delta
case class RemoveText(range: Range, text: String) extends Delta

case class Position(row: Int, column: Int) {
  override def toString = row + ":" + column
} 

case class Range(start: Position, end: Position) {
  override def toString = "[" + start + "->" + end + "]" 
}

object Position {
  implicit object Format extends Format[Position] {
    def reads(json: JsValue): Position = Position(
        (json \ "row").as[Int],
        (json \ "column").as[Int])
    def writes(pos: Position): JsValue = JsObject(
        "row" -> JsNumber(pos.row) ::
        "column" -> JsNumber(pos.column) :: Nil)
  }  
}

object Range {
  implicit object Format extends Format[Range] {
    def reads(json: JsValue): Range = Range(
        (json \ "start").as[Position],
        (json \ "end").as[Position])
    def writes(range: Range): JsValue = JsObject(
        "start" -> Json.toJson(range.start) ::
        "end" -> Json.toJson(range.end) :: Nil)
  }  
}

object Delta {
  implicit object Format extends Format[Delta] {
    def reads(json: JsValue): Delta = {
      val range = (json \ "range").as[Range]
      val action = (json \ "action").as[String]
      action match {
        case "insertLines" => InsertLines(range, (json \ "lines").as[Array[String]])
        case "removeLines" => RemoveLines(range, (json \ "lines").as[Array[String]])
        case "insertText" => InsertText(range, (json \ "text").as[String])
        case "removeText" => RemoveText(range, (json \ "text").as[String])        
      }
    }
    def writes(delta: Delta): JsValue = delta match {
      case InsertLines(range, lines) => JsObject(
        "action" -> JsString("insertLines") ::
        "range" -> Json.toJson(range) ::
        "lines" -> Json.toJson(lines) :: Nil)
      case RemoveLines(range, lines) => JsObject(
        "action" -> JsString("removeLines") ::
        "range" -> Json.toJson(range) ::
        "lines" -> Json.toJson(lines) :: Nil)
      case InsertText(range, text) => JsObject(
        "action" -> JsString("insertText") ::
        "range" -> Json.toJson(range) ::
        "lines" -> JsString(text) :: Nil)
      case RemoveText(range, text) => JsObject(
        "action" -> JsString("removeText") ::
        "range" -> Json.toJson(range) ::
        "lines" -> JsString(text) :: Nil)      
    } 
      
  }  
}