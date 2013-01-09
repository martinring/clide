package models

import play.api.libs.json._
import scala.io.Source
import scala.sys.process._

case class User(name: String, password: String) {
  private implicit val projectFormat = Project.readsFor(name)
  private val projectsPath = f"data/$name/.projects"    
  
  def projects: Array[Project] = {
    val in = scalax.io.Resource.fromFile(projectsPath)
                      .reader(scalax.io.Codec.UTF8)    
    val res = Json.parse(in.chars.mkString).as[Array[Project]]
    res.sortBy(_.name.toLowerCase)
  }
  
  def setLogic(project: String, logic: String) = {
    val data = projects.updated(projects.indexWhere(_.name == project), Project(project, logic)(name))
    val json = Json.toJson(data)
    val out  = scalax.io.Resource.fromFile(projectsPath)
    out.truncate(0)
    out.write(json.toString())
  }
  
  def addProject(project: String, logic: String = "HOL") = {
    if (projects.exists(_.name == project))
      false
    else {
	  val data = projects :+ Project(project,logic)(name)
	  val json = Json.toJson(data)
	  val out  = scalax.io.Resource.fromFile(projectsPath)	  
      out.truncate(0)
      out.write(json.toString())
      new java.io.File(f"data/$name/$project").mkdir()
      true
    }
  }
  
  def removeProject(project: String) = {
    val data = projects.filterNot(_.name == project)
    val json = Json.toJson(data)
    val out  = scalax.io.Resource.fromFile(projectsPath)	  
    out.truncate(0)
    out.write(json.toString())    
  }
}

object User {
  implicit object Format extends Format[User] {
    def reads(json: JsValue) = for {
      name     <- Json.fromJson[String](json \ "name")
      password <- Json.fromJson[String](json \ "password")
    } yield User(name,password)
    def writes(user: User) = Json.obj(
      "name"     -> user.name,
      "password" -> user.password
    )
  }  
  
  val users: Array[User] = {    
    val file = new java.io.File("data/.users")
    val content = Source.fromFile(file).mkString
    Json.parse(content).as[Array[User]]    
  }
  
  def find(name: String) = 
    users.find(_.name == name)
  
  def authenticate(name: String, password: String) = 
    find(name).filter(_.password == password)  
}