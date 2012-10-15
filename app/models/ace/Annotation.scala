package models.ace

import play.api.libs.json._

case class Annotation(
    annotationType: String,
    version: Long,
    position: Position, 
    message: String)

object Annotation {
  implicit object Writes extends Writes[Annotation] {
    def writes(annotation: Annotation): JsValue = JsObject(
      "action" -> JsString("Annotation") ::
      "version" -> JsNumber(annotation.version) ::
      "row" -> JsNumber(annotation.position.row) ::
      "column" -> JsNumber(annotation.position.column) ::
      "type" -> JsString(annotation.annotationType) ::      
      "text" -> JsString(annotation.message) :: Nil)
  }
}