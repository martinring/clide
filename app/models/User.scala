package models

import play.api.libs.json._
import scala.io.Source

case class User(name: String, password: String) {
  implicit val projectFormat = Project.readsFor(name)
  
  def projects: Array[Project] = {
    val file = new java.io.File(f"data/$name/.projects")
    val content = Source.fromFile(file).mkString    
    Json.parse(content).as[Array[Project]]
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