package models

import play.api.libs.json._

trait File

object File {
  /**
   * Typeclass instance for Json conversions
  **/
  implicit object Format extends Format[File] {
    def reads(json: JsValue): File = (json \ "type").as[String] match {
      case "Document" => Document(
          (json \ "project").as[String],
          (json \ "path").as[String],
          (json \ "name").as[String])
      case "Folder" => Folder(
          (json \ "project").as[String],
          (json \ "path").as[String],
          (json \ "name").as[String])
      case x => sys.error("Type missmatch. Expected Document or Folder but got " + x)
    }
    
    def writes(file: File): JsValue = file match {
      case Document(name, project, path) => JsObject(Seq(
          "type" -> JsString("Document"),
          "project" -> JsString(project),
          "path" -> JsString(path),
          "name" -> JsString(name)))
      case folder: Folder => JsObject(Seq(
          "type" -> JsString("Folder"),
          "project" -> JsString(folder.project),
          "path" -> JsString(folder.path),
          "name" -> JsString(folder.name)))
    }
  }
}