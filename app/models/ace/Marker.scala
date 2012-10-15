package models.ace

import play.api.libs.json._

case class Marker(
    version: Long,
    range: models.ace.Range,
    clazz: String,
    style: String)

object Marker {
  implicit object Writes extends Writes[Marker] {
    def writes(marker: Marker): JsValue = JsObject(
      "action" -> JsString("Marker") ::
      "version" -> JsNumber(marker.version) ::
      "range" -> Json.toJson(marker.range) ::
      "clazz" -> JsString(marker.clazz) ::
      "style" -> JsString(marker.style) ::
      Nil)
  }
}