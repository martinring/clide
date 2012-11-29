package controllers

import play.api._
import play.api.mvc._
import isabelle.Isabelle_System

object Application extends Controller {  
  def index = Action {    
    Ok(views.html.index("","",""))
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