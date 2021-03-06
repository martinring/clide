import play.api._
import isabelle.Isabelle_System
import com.typesafe.config.ConfigFactory
import scala.io.Source

/**
 * Global configuration
 */
object Global extends GlobalSettings {
  override def onStart(app: Application) {    
    Logger.info("initializing isabelle system")
    Isabelle_System.init()    
  }   
}