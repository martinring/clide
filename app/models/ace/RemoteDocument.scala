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

object RemoteDocument {
  case class NewVersion(version: Long, edits: List[Text.Edit])
}

/** 
 * This is the main interface between the JavaScript ACE-Editor and the scala world. 
 **/
class RemoteDocument[Context](newline: String = "\n") {
  import RemoteDocument._
  
  def apply(line: Int) = if (line < length)  
      buffer.slice(offset(line), offset(line + 1) - nllength).mkString
    else ""
  def length = offsets_.length - 1

  private var edits = Buffer[Text.Edit]()
  private val nllength = newline.length
  private val buffer = Buffer[Char]()
  private val offsets_ = Buffer[Int](0)
  private var listener: Option[ActorRef] = None
  private val tokens = Buffer[List[Token]]()  
  
  private var version = 0: Long        
  
  def listen(who: ActorRef) = listener match {
    case None => 
      listener = Some(who)
    case Some(_) => 
      sys.error("listener allready registered")
  }
  
  def offsets = offsets_.toSeq
  
  def ranges = 
    offsets_.tail.foldLeft(Vector((0,0))){
      case (v,o) => v :+ (v.last._2, o)
    }.tail
  
  def getRange(start: Int, end: Int) = buffer.slice(start, end).mkString
  
  private def push() = listener match {
    case None =>
    case Some(listener) => 
      listener ! NewVersion(version, edits.toList)
      edits.clear()
  }
  
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
  
  def mkString = buffer.mkString

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
    
    /* update tokens */
    tokens.insertAll(lineNumber, lines.map(line => List(Token(List("text"), line))))
    
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
    
    /* update tokens */
    tokens.remove(lineNumber,lines)
    
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
    
    /* update tokens */
    
    
    return Edit.remove(offset, text)
  }
  
  def splitLine(line: Int, column: Int): Edit = {
    /* split lines */
    val offset = this.offsets(line) + column
    buffer.insertAll(offset, newline)
    
    /* update offsets */        
    shiftOffsets(line+1,nllength)
    offsets_.insert(line+1,offsets(line) + column + nllength)
    
    /* update tokens */            
    val (_,(lts,rts)) = tokens(line).foldLeft((0,(Vector[Token](),Vector[Token]()))){
      case ((pos,(l,r)),t) => 
        if (pos + t.length <= column) (pos+t.length,(l:+t,r))
        else if (pos == column) (pos+t.length,(l,r:+t))
        else if (pos < column) {
          val (lv,rv) = t.splitAt(column-pos)
          (pos+t.length,(l:+lv,r:+rv))
        }
        else (pos,(l,r:+t))
    }    
    tokens(line) = lts.toList
    tokens.insert(line+1, rts.toList)
    
    return Edit.insert(offset, newline)
  }
  
  def mergeLines(line: Int): Edit = {
    /* merge lines */
    val offset = this.offset(line)-nllength
    buffer.remove(offset, nllength)
    
    /* update offsets */
    offsets_.remove(line)
    shiftOffsets(line,-nllength)
    
    /* update tokens */
    tokens(line) ++= tokens(line + 1)
    tokens.remove(line + 1)
    
    return Edit.remove(offset, newline)
  }           
  
//  def updateTokens(offset: Int, tokens: List[Token]) {
//    val line = this.line(offset)
//    val column = offset - this.offset(line)
//    for ((tokenLine,i) <- Token.lines(tokens).zipWithIndex.tail) {
//      if (i == 0 && column != 0)
//        this.tokens(line + i) = 
//          Token("invisible", buffer.slice(this.offset(line), this.offset(line) + column).mkString) :: 
//          tokenLine
//      else 
//        this.tokens(line + i) = 
//          tokenLine
//    }
//  }    
  
  val (out, channel) = Concurrent.broadcast[JsValue]
  
  def updateTokens(t: List[List[Token]], from: Int = 0) = {    
    t.zipWithIndex.foreach {
      case (l,i) => 
        if (tokens.isDefinedAt(from+i)) 
          if (tokens(from + i) != l) {          
            tokens(from+i) = l
            channel.push(Json.toJson(LineUpdate(from + i,version,l)))
          }
        else {
          tokens.insert(from+i, l)
          channel.push(Json.toJson(LineUpdate(from + i,version,l)))
        }                              
    }
  }
  
  def error(line: Int, msg: String) {
    channel.push(Json.toJson(Annotation("error", version, Position(line,0), msg)))    
  }
  
  def warning(line: Int, msg: String) {
    channel.push(Json.toJson(Annotation("warning", version, Position(line,0), msg)))
  }
  
  def info(line: Int, msg: String) {
    channel.push(Json.toJson(Annotation("info", version, Position(line,0), msg)))
  }
  
  def markError(start: Int, end: Int) {    
    channel.push(Json.toJson(Marker(version, Range(position(start), position(end)),"error","")))
  }
  
  val in = Iteratee.foreach[JsValue] { json =>
    version += 1
    val deltas = json.as[Array[Delta]]
    Delta.optimize(Delta.optimize(deltas.toVector)).foreach {
      case InsertNewline(range) =>
        edits += splitLine(range.start.row, range.start.column)
      case RemoveNewline(range) =>
        edits += mergeLines(range.end.row)
      case ReplaceText(range, text) =>
        edits += removeText(range.start.row, range.start.column, text.length)
        edits += insertText(range.start.row, range.start.column, text)
      case InsertText(range,text) =>
        edits += insertText(range.start.row, range.start.column, text)
      case RemoveText(range, text) =>
        edits += removeText(range.start.row, range.start.column, text.length)
      case InsertLines(range, lines) =>
        edits += insertLines(range.start.row, lines :_*)
      case RemoveLines(range, lines) =>
        edits += removeLines(range.start.row, lines.length)
      case NoChange => 
    }    
    push()
  }      
}