import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {
    val appName         = "clide"
    val appVersion      = "1.0-SNAPSHOT"

    val appDependencies = Seq(
      "org.scala-lang" % "scala-swing" % "2.10.1"      
    )

    val main = play.Project(appName, appVersion, appDependencies).settings(
      scalaVersion := "2.10.1",      
      lessEntryPoints <<= baseDirectory(d => 
        (d / "app" / "assets" / "stylesheets" ** "ide.less") +++
        (d / "app" / "assets" / "stylesheets" ** "login.less") +++
        (d / "app" / "assets" / "stylesheets" ** "projects.less") ) 
    )
}
