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
import play.api.data.Form
import play.api.data.Forms._
import akka.routing.Broadcast
import views.html.defaultpages.badRequest
import scala.collection.mutable.Buffer


object Projects extends Controller with Secured {
  /**
   * Project overview for a specific user
  **/
  def index(user: String) = IsAuthenticated { _ => implicit request =>  
    User.find(user) match {
      case Some(user) => Ok(views.html.projects(user))
      case None => NotFound("user " + user + " does not exist")
    }    
  }
  
  /**
   * JSON-Formatted list of projects for a specific user
  **/
  def listProjects(user: String) = IsAuthenticated { _ => implicit request =>    
    User.find(user) match {
      case Some(user) =>           
        Ok(Json.toJson(user.projects))
      case None       => NotFound("user " + user + " does not exist")
    }
  }

  /**
   * JSON-Formatted Project Info
   **/
  def getProject(user: String, project: String) = IsAuthenticated { _ => implicit request =>
    User.find(user) match {
      case Some(user) => user.projects.find(_.name == java.net.URLDecoder.decode(project,"UTF-8")) match {
        case Some(project) => Ok(Json.toJson(project.theories))
        case None          => NotFound("project " + project + " does not exist")
      }
      case None       => NotFound("user " + user + " does not exist")
    }
  }
  
  var openProjects: Buffer[(String,String)] = Buffer()
  
  /**
   * Create a WebSocket Session, connected via ScalaConnector/JSConnector
   **/
  def getSession(user: String, project: String) = WebSocket.using[JsValue] { request =>
    User.find(user) match {
      case Some(user) => user.projects.find(_.name == java.net.URLDecoder.decode(project,"UTF-8")) match {
        case Some(project) => 
          val session = new models.Session(project)
          (session.in, session.out)
        case None =>
          val (out,channel) = Concurrent.broadcast[JsValue]
          (Iteratee.ignore,out)
      }
      case None =>
          val (out,channel) = Concurrent.broadcast[JsValue]
          (Iteratee.ignore,out)
    }        
  }
  
  /**
   * IDE for a specific project
   */
  def project(user: String, project: String, path: String) = IsAuthenticated { _ => implicit request =>
    User.find(user) match {
      case Some(user) => user.projects.find(_.name == java.net.URLDecoder.decode(project,"UTF-8")) match {
        case Some(project) => Ok(views.html.ide(user.name,project.name,path))
        case None          => NotFound("project " + project + " does not exist")
      }
      case None       => NotFound("user " + user + " does not exist")
    }    
  }

    
  /**
   * Modify Project configuration
   **/
  def setProjectConf(user: String, project: String) = IsAuthenticated { _ => implicit request =>
    Form("logic" -> nonEmptyText).bindFromRequest.fold(
      errors => BadRequest,
      logic => { User.find(user).map(_.setLogic(project, logic)); Ok(logic) }
    )
  }  
  
  /**
   * Create a project
   **/
  def createProject(user: String, project: String) = IsAuthenticated { _ => implicit request =>
    User.find(user) match {
      case None => BadRequest
      case Some(user) => if (user.addProject(project))
        Ok(project)
      else BadRequest
    }
  }
  
  /**
   * Remove a project
   **/
  def removeProject(user: String, project: String) = IsAuthenticated { _ => implicit request =>
    User.find(user) match {
      case None => BadRequest
      case Some(user) => user.removeProject(project)
        Ok(project)      
    }
  }
}