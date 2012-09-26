package models

case class Folder(
  project: String,
  path: String,  
  name: String) extends File {
  def children: List[File] = List(
    Folder(project, path + name + "/", "folder1"),
    Folder(project, path + name + "/", "folder2"),      
    Document(project, path + name + "/", "file1"),
    Document(project, path + name + "/", "file2"))
}