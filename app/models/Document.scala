package models

case class Document(
  name: String,
  project: String,
  path: String) extends File