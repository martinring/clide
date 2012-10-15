package models.ace

import play.api.libs.json._

case class Token(tpe: String, value: String) {
  private val newline = "\n"
  def isMultiline = value.contains(newline)
  def isEmpty = value.isEmpty
  def splitLine: (Token,Token) =
    value.splitAt(value.indexOf(newline)) match {
      case (left,right) => (Token(tpe,left),Token(tpe,right.drop(newline.length)))
    }    
}

object Token {
  implicit object Writes extends Writes[Token] {
    def writes(token: Token) = JsObject(
        "type" -> JsString(token.tpe) ::
        "value" -> JsString(token.value) :: Nil)
  }        
  
  def lines(tokens: List[Token]): List[List[Token]] = {    
    val (left, right) = tokens.span(!_.isMultiline)
    right match {
      case head :: tail => 
        val (last, next) = head.splitLine
        (left :+ last).filter(!_.isEmpty) :: lines(next :: tail)
      case Nil => 
        List(left.filter(!_.isEmpty))
    }
  }
}

case class LineUpdate(line: Int, version: Long, tokens: List[Token])

object LineUpdate {
  implicit object Writes extends Writes[LineUpdate] {
    def writes(up: LineUpdate) = JsObject(
        "action" -> JsString("LineUpdate") ::
        "line" -> JsNumber(up.line) ::
        "version" -> JsNumber(up.version) ::
        "tokens" -> Json.toJson(up.tokens.toArray) ::
        Nil)
  }
}