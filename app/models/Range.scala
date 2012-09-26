package models

import play.api.libs.json._

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