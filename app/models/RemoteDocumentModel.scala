package models

import isabelle._
import play.api.libs.json.JsValue

class RemoteDocumentModel(lines: Traversable[String] = Nil) {  
  val buffer = new LineBuffer
  buffer.lines ++= lines
  
  var perspective = (0,0)
  
  val commands = scala.collection.mutable.Map[Long, JsValue]()
  
  var version = 0
  
  def convert(pos: Position): Int = buffer.offset(pos.line) + pos.column    
  
  def change(from: Position, to: Position, text: Array[String]): List[Text.Edit] = {    
    if (from == to) {
      if (text.length == 0)
        Nil
      else {        
        val ln = buffer.lines(from.line)
        buffer.lines(from.line) = ln.take(from.column) + text.head
        if (text.length > 1) buffer.lines.insertAll(from.line + 1, text.tail)
        buffer.lines(from.line + (text.length - 1)) += ln.drop(from.column)                
        List(Text.Edit.insert(convert(from), text.mkString(buffer.newline.toString)))
      }
    }
    else {
      val removed = buffer.chars.slice(convert(from), convert(to)).mkString      
      buffer.lines(from.line) = buffer.lines(from.line).take(from.column) + buffer.lines(to.line).drop(to.column)
      buffer.lines.remove(from.line + 1, to.line - from.line)
      Text.Edit.remove(convert(from), removed) :: change(from,from,text)
    }
  }
}