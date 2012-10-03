package models

import play.api.libs.json._

trait File {
  val name: String
  val path: String
  val project: String
}

object File {
  /**
   * Typeclass instance for Json conversions
  **/
  implicit object Format extends Format[File] {
    def reads(json: JsValue): JsResult[File] = (json \ "type").as[String] match {
      case "Document" => for {
        project <- Json.fromJson[String](json \ "project")
        path <- Json.fromJson[String](json \ "path")
        name <- Json.fromJson[String](json \ "name")
      } yield Document(project, path, name)
      case "Folder" => for {
        project <- Json.fromJson[String](json \ "project")
        path <- Json.fromJson[String](json \ "path")
        name <- Json.fromJson[String](json \ "name")
      } yield Folder(project, path, name)
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