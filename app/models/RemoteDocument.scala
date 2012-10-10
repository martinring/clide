package models

import scala.collection.mutable.Buffer
import isabelle.Text.Edit
import play.api.Logger

class RemoteDocument(newline: String = "\n") {
  def apply(line: Int) = buffer.slice(offset(line), offset(line + 1) - nllength).mkString
  def length = offsets.length - 1
  
  private val nllength = newline.length
  private val buffer = Buffer[Char]()
  private val offsets = Buffer[Int](0)
      
  private def shiftOffsets(start: Int, diff: Int) {
    for (i <- start until offsets.length)
      offsets(i) = offsets(i) + diff
  }
  
  def offset(line: Int) = offsets(line)
  def line(offset: Int) = offsets.takeWhile(_ <= offset).length
  
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
    offsets.insertAll(lineNumber, newOffsets.init)
    val shiftStart = lineNumber + lines.length
    val diff = newOffsets.last - startOffset
    shiftOffsets(shiftStart, diff)
    
    return Edit.insert(start, elems)
  }
  
  def removeLines(lineNumber: Int, lines: Int): Edit = {
    /* remove lines */
    val start = offsets(lineNumber)
    val count = offsets(lineNumber + lines) - start
    val text = buffer.slice(start, count).mkString
    buffer.remove(start, count)
    
    /* update offsets */
    offsets.remove(lineNumber + 1, lines)
    shiftOffsets(lineNumber + 1, -count)
    
    return Edit.remove(start, text)
  }
  
  def insertText(line: Int, column: Int, text: String): Edit = {
    /* insert text */
    val offset = offsets(line) + column
    buffer.insertAll(offset, text)
    
    /* update offsets */       
    shiftOffsets(line+1, text.length)
    
    return Edit.insert(offset, text)
  }
  
  def removeText(line: Int, column: Int, length: Int): Edit = {
    /* remove text */
    val offset = offsets(line) + column
    val text = buffer.slice(offset, length).mkString
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
    offsets.insert(line+1,offsets(line) + column + nllength)
    
    return Edit.insert(offset, newline)
  }
  
  def mergeLines(line: Int): Edit = {
    /* merge lines */
    val offset = this.offset(line)-nllength
    buffer.remove(offset, nllength)
    
    /* update offsets */
    offsets.remove(line)
    shiftOffsets(line,-nllength)
    
    return Edit.remove(offset, newline)
  }   
}