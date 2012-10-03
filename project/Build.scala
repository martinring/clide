import sbt._
import Keys._
import PlayProject._

object ApplicationBuild extends Build {
    val appName         = "Clide"
    val appVersion      = "1.0-SNAPSHOT"

    val appDependencies = Seq(
      "org.scala-lang" % "scala-swing" % "2.10.0-M7"
    )

    val main = PlayProject(appName, appVersion, appDependencies, mainLang = SCALA).settings(
      scalaVersion := "2.10.0-M7",
      coffeescriptOptions := Seq("bare")
    )
}
