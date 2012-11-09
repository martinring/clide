package models

import play.api.libs.json._

case class Project(
    name: String,
    owner: String,
    logic: String = "HOL") {
  val dir = "data/" + owner + "/" + name + "/"
  def theories: Array[Theory] = {
    val d = new java.io.File(dir)
    if (d.isDirectory()) {
      d.listFiles.filter(_.getName().endsWith(".thy"))
       .map(file => Theory(file.getName().dropRight(4), file.getName()))
    }
    else sys.error(dir + " is not a directory")
  }     
}

case class Theory(
  id: String,
  path: String) {  
}

object Theory {
  implicit object Writes extends Writes[Theory] {
    def writes(theory: Theory): JsValue = JsObject(Seq(
        "id" -> JsString(theory.id),
        "path" -> JsString(theory.path)))
  }  
}

object Project {
  /**
   * Typeclass instance for Json conversions
  **/
  implicit object Writes extends Writes[Project] {    
    def writes(project: Project): JsValue = JsObject(Seq(      
      "name" -> JsString(project.name),
      "owner" -> JsString(project.owner), 
      "logic" -> JsString(project.logic),
      "theories" -> Json.toJson(project.theories.toArray)))
  }
}

