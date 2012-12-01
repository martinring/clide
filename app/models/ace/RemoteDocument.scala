package models.ace
import scala.collection.mutable._
import isabelle.Text.Edit
import isabelle._
import play.api.libs.iteratee.Concurrent
import play.api.libs.json.JsValue
import play.api.libs.iteratee.Iteratee
import akka.actor.ActorRef
import akka.actor.actorRef2Scala
import models.ace._
import play.api.libs.json.Json
import js._
import scala.concurrent.ExecutionContext
import ExecutionContext.Implicits.global
import play.api.libs.json._
import scala.swing._

/** 
 * This is the main interface between the JavaScript ACE-Editor and the scala world. 
 **/
class RemoteDocument(newline: String = "\n") {
  import RemoteDocument._  
  
  def apply(line: Int) = 
    if (line < length)  
      buffer.slice(offset(line), offset(line + 1) - nllength).mkString
    else ""
      
  def length = offsets_.length - 1

  private var edits = Buffer[Text.Edit]()
  private val nllength = newline.length
  private val buffer = Buffer[Char]()
  private val offsets_ = Buffer[Int](0)
  private var listener: Option[ActorRef] = None
    
  def toOffset(position: (Int,Int)) = position match {
    case (row, column) => offsets_.lift(row).map(_ + column) 
  }
  
  private var version_ = 0: Long
  
  def lines = ranges.map { 
    case (start,stop) => 
      buffer.slice(start, stop - newline.length).mkString 
  }
  
  def version = version_
    
  def offsets = offsets_.toSeq
  
  def ranges = 
    offsets_.tail.foldLeft(Vector((0,0))){
      case (v,o) => v :+ (v.last._2, o)
    }.tail.map { case (start,end) => (start,end - newline.length) }     
  
  def getRange(start: Int, end: Int) = buffer.slice(start, end).mkString
    
  private def shiftOffsets(start: Int, diff: Int) {
    for (i <- start until offsets.length)
      offsets_(i) = offsets_(i) + diff
  }

  def offset(line: Int) = offsets_(line)
  def line(offset: Int) = offsets_.takeWhile(_ <= offset).length - 1

  def position(offset: Int) = {
    val line = this.line(offset)
    Position(line,offset - offsets_(line))
  }
  
  def mkString = buffer.mkString.dropRight(newline.length)

  def bufferLength = buffer.length
  
  def insertLines(lineNumber: Int, lines: String*): Edit = {
    /* insert lines */
    val start = offsets(lineNumber)
    val elems = lines.mkString(newline) + newline
    
    buffer.insertAll(start, elems)

    /* update offsets */
    val startOffset = offset(lineNumber)
    val newOffsets = lines.foldLeft(Vector(startOffset)){
      case (offsets, line) => offsets :+ (offsets.last + line.length + nllength)
    }
    offsets_.insertAll(lineNumber, newOffsets.init)
    val shiftStart = lineNumber + lines.length
    val diff = newOffsets.last - startOffset
    shiftOffsets(shiftStart, diff)
        
    return Edit.insert(start, elems)
  }
  
  def removeLines(lineNumber: Int, lines: Int): Edit = {
    /* remove lines */
    val start = offsets(lineNumber)
    val count = offsets(lineNumber + lines) - start
    val text = buffer.slice(start, start + count).mkString
    buffer.remove(start, count)
    
    /* update offsets */
    offsets_.remove(lineNumber + 1, lines)
    shiftOffsets(lineNumber + 1, -count)
    
    require(text.length >= lines)
        
    return Edit.remove(start, text)
  }
  
  def insertText(line: Int, column: Int, text: String): Edit = {
    /* insert text */
    val offset = offsets(line) + column
    buffer.insertAll(offset, text)
    
    /* update offsets */       
    shiftOffsets(line+1, text.length)
    
    /* update tokens */    
  
    return Edit.insert(offset, text)
  }
  
  def removeText(line: Int, column: Int, length: Int): Edit = {
    /* remove text */
    val offset = offsets(line) + column
    val text = buffer.slice(offset, offset + length).mkString
    buffer.remove(offset, length)
    
    /* update offsets */
    shiftOffsets(line+1,-length)    
    
    return Edit.remove(offset, text)
  }
  
  def splitLine(line: Int, column: Int): Edit = {
    /* split lines */
    val offset = this.offsets(line) + column
    buffer.insertAll(offset, newline)
    
    /* update offsets */
    shiftOffsets(line+1,nllength)
    offsets_.insert(line+1,offsets(line) + column + nllength)
        
    return Edit.insert(offset, newline)
  }
  
  def mergeLines(line: Int): Edit = {
    /* merge lines */
    val offset = this.offset(line)-nllength
    buffer.remove(offset, nllength)
    
    /* update offsets */
    offsets_.remove(line)
    shiftOffsets(line,-nllength)
     
    return Edit.remove(offset, newline)
  }           
   
  var perspective = (0, 0)
  
  var active = false
  
  def isabellePerspective: Text.Perspective = perspective match {
    case (start,end) => if (active) Text.Perspective(Seq(Text.Range(start,end))) else Text.Perspective.empty
  }
  
  def applyDelta(delta: Delta): List[Text.Edit] = delta match {
    case InsertNewline(range) =>
      List(splitLine(range.start.row, range.start.column))
    case RemoveNewline(range) =>
      List(mergeLines(range.end.row))
    case ReplaceText(range, text) =>
      List(removeText(range.start.row, range.start.column, text.length),
		   insertText(range.start.row, range.start.column, text))
    case InsertText(range, text) =>
      List(insertText(range.start.row, range.start.column, text))
    case RemoveText(range, text) =>
      List(removeText(range.start.row, range.start.column, text.length))
    case InsertLines(range, lines) =>
      List(insertLines(range.start.row, lines: _*))
    case RemoveLines(range, lines) =>
      List(removeLines(range.start.row, lines.length))
    case NoChange => Nil
  }

  def edit(delta: Delta): List[Text.Edit] = {
    version_ += 1
    applyDelta(delta)
  }   
  
  def edit(deltas: Vector[Delta]): List[Text.Edit] = {
    version_ += 1
    deltas.toList.flatMap(applyDelta)
  }
}

trait Visualization { this: RemoteDocument =>
  val textPane = new EditorPane
    
  textPane.font = java.awt.Font.decode("Inconsolata")  
  
  val frame = new Frame {
    title = "Document Visualized"
    contents = textPane
  }
  
  frame.visible = true
  
  def update() {    
    textPane.text = this.mkString            
  }    
}
