import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {
    val appName         = "clide"
    val appVersion      = "1.0-SNAPSHOT"

    val appDependencies = Seq(
      "org.scala-lang" % "scala-swing" % "2.10.0-RC1"      
    )

    val main = PlayProject(appName, appVersion, appDependencies).settings(
      scalaVersion := "2.10.0-RC1",
      //coffeescriptOptions := Seq("bare"),
      lessEntryPoints <<= baseDirectory(d => (d / "app" / "assets" / "stylesheets" ** "main.less"))
    )
}
