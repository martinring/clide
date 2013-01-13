package models

import play.api.libs.json._

/**
 * Represents clientside text positions
 **/
case class Position(line: Int, column: Int)

object Position {
  /**
   * Reads-typeclass instance for Positions
   **/
  implicit object Reads extends Reads[Position] {
    def reads(json: JsValue): JsResult[Position] = for {
      line  <- Json.fromJson[Int](json \ "line")
      ch    <- Json.fromJson[Int](json \ "ch")
    } yield Position(line, ch)
  }
}

/**
 * Represents a clientside text change
 **/
case class Change(from: Position, to: Position, text: Array[String]) 

object Change {
  /**
   * Reads-typeclass instance for Changes
   **/
  implicit object Reads extends Reads[Change] {
    def reads(json: JsValue): JsResult[Change] = for {
      from  <- Json.fromJson[Position](json \ "from")
      to    <- Json.fromJson[Position](json \ "to")
      text  <- Json.fromJson[Array[String]](json \ "text")      
    } yield Change(from, to, text)
  }
}