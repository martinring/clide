package controllers

import models._
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
import actors.ProjectActor
import akka.pattern.ask
import akka.util.Timeout
import scala.concurrent.util.duration._
import scala.concurrent.Await

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
  
  val projectActors = scala.collection.mutable.Map[(String,String),ActorRef]()
  
  def getProjectActor(project: Project) = projectActors.getOrElseUpdate((project.owner,project.name),
    Akka.system.actorOf(Props(new ProjectActor(project)), name = "project-" + project.owner + "-" + project.name)) 
    
  def close(username: String, projectname: String) = Action {
    Users.find(username) match {
      case Some(user) => user.projects.find(_.name == projectname) match {
        case Some(project) =>
          projectActors.remove((username,projectname))
          Ok(Json.toJson(true))
        case None          => NotFound("project " + projectname + " does not exist")
      }
      case None       => NotFound("user " + username + " does not exist")
    }
  }

  def getFileSocket(user: String, project: String, path: String) = WebSocket.using[JsValue] { request =>
    val projectActor = getProjectActor(Project(project, user)) 
    val (out, channel) = Concurrent.broadcast[JsValue]
    val docActor = Await.result(
        projectActor.ask
           (ProjectActor.Open(path, channel))
           (Timeout(10 seconds)).mapTo[ActorRef],
        10 seconds)
    val in = Iteratee.foreach[JsValue] { deltas =>
      docActor ! deltas.as[Array[Delta]]
    }    
    (in, out)
  }

  def getFileContent(user: String, project: String, path: String) = Action {
    val src = Source.fromFile("data/" + user + "/" + project + "/" + path)
    Ok(src.getLines.mkString("\n"))
  }
}