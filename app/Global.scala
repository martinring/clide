import play.api._
import isabelle.Isabelle_System

object Global extends GlobalSettings {
  override def onStart(app: Application) {
    Logger.info("initializing isabelle system")
    Isabelle_System.init()    
  }  
  
  override def onStop(app: Application) {
    Logger.info("releasing isabelle system")
    Isabelle_System.find_logics.foreach(println)
  }
}