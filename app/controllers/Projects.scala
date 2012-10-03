package controllers

import models._
import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import scala.io.Source
import isabelle._

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
    val remoteSession = new RemoteSession
    (remoteSession.in, remoteSession.out)
  }   

  def getFileContent(user: String, project: String, path: String) = Action {
    val src = Source.fromFile("data/" + user + "/" + project + "/" + path)
    Ok(src.getLines.mkString("\n"))
  }
}