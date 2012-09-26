import sbt._
import Keys._
import PlayProject._

object ApplicationBuild extends Build {
    val appName         = "Clide"
    val appVersion      = "1.0-SNAPSHOT"    

    val appDependencies = Seq(
      "org.scala-lang" % "scala-swing" % "2.9.1"
    )

    val main = PlayProject(appName, appVersion, appDependencies, mainLang = SCALA).settings(
      coffeescriptOptions := Seq("bare"),
      resourceGenerators in Compile <+= 
	    (resourceManaged in Compile, name, version) map { (dir, n, v) =>
	      val file = dir / "public" / "javascripts" / "optimized.js"
	      val contents = "name=%s\nversion=%s".format(n,v)
	      IO.write(file, contents)
	      Seq(file)
	    }
    )
}
