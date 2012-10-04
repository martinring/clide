package models

import play.api.libs.json._

case class Token(tpe: String, value: String)

object Token {
  implicit object Format extends Writes[Token] {
    def writes(token: Token) = JsObject(
        "type" -> JsString(token.tpe) ::
        "value" -> JsString(token.value) :: Nil)
  }
}