package models

case class User(name: String, password: String) {
  val dir = "data/" + name + "/"
  def projects: Array[Project] = {
    val d = new java.io.File(dir)
    if (d.isDirectory()) {
      d.listFiles.filter(_.isDirectory())
       .map(file => Project(file.getName(),name))
    }
    else sys.error(dir + " is not a directory")
  }   
}

object Users {
  def users: Array[User] = {
    val d = new java.io.File("data/")
    if (d.isDirectory()) {
      d.listFiles.filter(_.isDirectory())
       .map(file => User(file.getName(),"password"))
    }
    else sys.error("no data directory")
  }

  def find(name: String) = name match {
    case "martinring" | "test" => Some(User(name, "password"))
    case _ => None
  }
}