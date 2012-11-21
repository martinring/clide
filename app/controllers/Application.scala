package controllers

import play.api._
import play.api.mvc._
import isabelle.Isabelle_System

object Application extends Controller {  
  def index = Action {
    Logger.info("request for index")
    val ok = Ok(views.html.index())
    Logger.info("served")
    ok
  }    

  // -- Javascript routing
  def javascriptRoutes = Action { implicit request =>
    import routes.javascript._
    Ok(
      Routes.javascriptRouter("routes")(
        routes.javascript.Application.index,
        Projects.listProjects,        
        Projects.getSession
      )
    ).as("text/javascript") 
  }
}