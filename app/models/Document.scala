package models

import scala.collection.mutable.ArrayBuffer

case class Document(
  name: String,
  project: String,
  path: String) extends File {  
}