package models

import play.api.libs.json._

case class Annotation(annotationType: String, position: Position, message: String)

object Annotation {
  implicit object Writes extends Writes[Annotation] {
    def writes(annotation: Annotation): JsValue = JsObject(
      "type" -> JsString("Annotation") ::
      "annotationType" -> JsString(annotation.annotationType) ::
      "position" -> Json.toJson(annotation.position) ::
      "message" -> JsString(annotation.message) :: Nil)
  }
}