package models

case class User(name: String, password: String) {
  def projects = List(
      Project("project1", name),
      Project("project2", name)) 
}

object Users {
  def find(name: String) = name match {
    case "martinring" | "test" => Some(User(name, "password"))
    case _ => None
  }
}