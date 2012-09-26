package controllers

import models._
import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import scala.io.Source
import isabelle._
import scala.actors._

object Projects extends Controller {
  def listProjects(user: String) = Action {
    Users.find(user) match {
      case Some(user) => Ok(Json.toJson(user.projects))
      case None       => NotFound("user " + user + " does not exist")
    }
  }

  def getProject(user: String, project: String) = Action {
    Users.find(user) match {
      case Some(user) => user.projects.find(_.name == project) match {
        case Some(project) => Ok(Json.toJson(project.files))
        case None          => NotFound("project " + project + " does not exist")
      }
      case None       => NotFound("user " + user + " does not exist")
    }
  }
  
  def getFileSocket(user: String, project: String, path: String) = WebSocket.using[JsValue] { request =>
    val out = Enumerator.imperative[JsValue]()

    FileServer.out = out
    FileServer.thyDir = "data/" + user + "/" + project + "/"
    Isabelle.start("HOL", List(path))
    
    val in = Iteratee.foreach[JsValue]{ json =>
      val range = (json \ "range").as[Range]
      val edit: Text.Edit = (json \ "action").as[String] match {
	    case "insertLines" =>
	      Text.Edit.insert((json \ "offset").as[Int], (json \ "lines").as[Array[String]].mkString("\n"))	      
	    case "insertText" =>
	      Text.Edit.insert((json \ "offset").as[Int], (json \ "text").as[String])	      
	    case "removeText" =>
	      Text.Edit.remove((json \ "offset").as[Int], (json \ "text").as[String])	      
	    case "removeLines" =>
	      Text.Edit.remove((json \ "offset").as[Int], (json \ "lines").as[Array[String]].mkString("\n"))	      
	    case x => sys.error("unknown action: " + x)
	  }      
      println(edit)
      Isabelle.session.get.edit(List(
          (
              isabelle.Document.Node.Name.apply(Path.explode(path)), 
              isabelle.Document.Node.Edits(List(edit))
          )))
      
    }
    (in, out)
  }   

  def getFileContent(user: String, project: String, path: String) = Action {
    val src = Source.fromFile("data/" + user + "/" + project + "/" + path)
    Ok(src.getLines.mkString("\n"))
  }
}