import play.api._
import isabelle.Isabelle_System
import com.typesafe.config.ConfigFactory

object Global extends GlobalSettings {
  override def onStart(app: Application) {    
    Logger.info("initializing isabelle system")
    app.configuration.getString("isabelle.home") match {
      case Some(path) => Isabelle_System.init(path)
      case None       => sys.error("Property 'isabelle.home' is not configured in conf/application.conf")
    }    
  }  
}