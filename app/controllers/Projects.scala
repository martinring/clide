package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import scala.io.Source
import isabelle._
import akka.actor.ActorRef
import play.api.Play.current
import play.api.libs.concurrent.Akka
import akka.actor.Props
import akka.pattern.ask
import akka.util.Timeout
import scala.concurrent.duration._
import scala.concurrent.Await
import models.User
import models.Project
import models.ace.Delta
import models.ace.RemoteDocument

object Projects extends Controller {
  def index(user: String) = Action {
    User.find(user) match {
      case Some(user) => Ok(views.html.projects(user))
      case None => NotFound("user " + user + " does not exist")
    }    
  }
  
  def listProjects(user: String) = Action {    
    User.find(user) match {
      case Some(user) =>        
        Ok(Json.toJson(user.projects))
      case None       => NotFound("user " + user + " does not exist")
    }
  }

  def getProject(user: String, project: String) = Action {
    User.find(user) match {
      case Some(user) => user.projects.find(_.name == java.net.URLDecoder.decode(project,"UTF-8")) match {
        case Some(project) => Ok(Json.toJson(project.theories))
        case None          => NotFound("project " + project + " does not exist")
      }
      case None       => NotFound("user " + user + " does not exist")
    }
  }
  
  def getSession(user: String, project: String) = WebSocket.using[JsValue] { request =>
    val p = Project(java.net.URLDecoder.decode(project,"UTF-8"))(user)
    val session = new models.Session(p)
    (session.in, session.out)
  }
  
  def project(user: String, project: String, path: String) = Action {
    User.find(user) match {
      case Some(user) => user.projects.find(_.name == java.net.URLDecoder.decode(project,"UTF-8")) match {
        case Some(project) => Ok(views.html.ide(user.name,project.name,path))
        case None          => NotFound("project " + project + " does not exist")
      }
      case None       => NotFound("user " + user + " does not exist")
    } 
    
  }
}