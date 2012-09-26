package models

import play.api.libs.json._

case class Project(
    name: String,
    owner: String) {
  def files: List[File] = List(
      Folder(name, "/", "folder1"),
      Folder(name, "/", "folder2"),      
      Document(name, "/", "file1"),
      Document(name, "/", "file2"))
}

object Project {
  /**
   * Typeclass instance for Json conversions
  **/
  implicit object Format extends Format[Project] {
    def reads(json: JsValue): Project = Project(
      (json \ "name").as[String],
      (json \ "owner").as[String])
    def writes(project: Project): JsValue = JsObject(Seq(
      "type" -> JsString("Project"),
      "name" -> JsString(project.name),
      "owner" -> JsString(project.owner)))
  }
}