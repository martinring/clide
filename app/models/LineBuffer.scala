package models

import scala.collection.mutable.Buffer

object LineBuffer {
  def ranges(elems: Traversable[String]) =
    elems.foldLeft(Vector((0,-1))) {
      case (offsets,line) => offsets :+ (offsets.last._2 + 1, offsets.last._2 + 1 + line.length)
    }.tail  
}

class LineBuffer {
  private var rngs    = Buffer[(Int,Int)]()  
  private val buffer  = Buffer[Char]()     
      
  def mkString = buffer.mkString
    
  def ranges = rngs.toVector
      
  val newline = '\n'
    
  def line(offset: Int) =
    rngs.indexWhere { case (from,until) => from <= offset && offset <= until }   
  
  def offset(line: Int) = 
    rngs(line)._1
    
  object lines extends Buffer[String] {
    def += (elem: String): this.type  = {
      if (!buffer.isEmpty)
        buffer += newline
      rngs += ((buffer.length, buffer.length + elem.length))
      buffer ++= elem
      this
    }
    
    def +=: (elem: String): this.type = {
      if (buffer.isEmpty) this += elem
      else {
        buffer.prependAll(elem + newline) 
        rngs = (0,elem.length) +: rngs.map { case (from,to) => (from + elem.length + 1, to + elem.length + 1) }         
      }          
      this
    }
    
    def apply(n: Int): String = {
      val (from,until) = rngs(n)
      buffer.slice(from,until).mkString
    }
    
    def clear(): Unit = {
      rngs = Buffer()
      buffer.clear()
    }
    
    def insertAll(n: Int, elems: Traversable[String]): Unit = {
      if (n == rngs.length)        
        elems.foreach(this += _)             
      else {
        val length = elems.map(_.length + 1).sum
        val offset = rngs(n)._1
        rngs = rngs.take(n) ++ 
               LineBuffer.ranges(elems).map { case (from,to) => (from + offset, to + offset) } ++
               rngs.drop(n).map { case (from,to) => (from + length, to + length) }        	    	    
	    buffer.insertAll(offset, elems.mkString(newline.toString) + newline)
      }
    }
    
    def iterator: Iterator[String] = new Iterator[String] {
      val rs = rngs.iterator   
      def hasNext = rs.hasNext
      def next = {
        val (start,end) = rs.next()
        buffer.slice(start, end).mkString
      }
    }
    
    def length: Int = rngs.length
    
    def remove(n: Int): String = {
      val (from,until) = rngs(n)      
      val result = buffer.slice(from,until).mkString
      val len = result.length() + 1
      if (n == 0 && rngs.length == 1)
        clear()
      else if (n+1 == rngs.length)
        buffer.remove(from - 1, 1 + until - from)
      else
        buffer.remove(from, 1 + until - from)
      rngs = rngs.take(n) ++ rngs.drop(n + 1).map { case (from,to) => (from - len, to - len) }            
      result
    }    
    
    def update(n: Int, c: String): Unit = {
      require(!c.contains(newline), "updated line may not contain newlines")
      if (n == rngs.length) this += c
      else {      
	      val (of,ot) = rngs(n)
	      val len = ot - of
	      val diff = c.length - len
	      buffer.remove(of, len)
	      buffer.insertAll(of, c)
	      rngs = (rngs.take(n) :+ (of,of + c.length)) ++ rngs.drop(n + 1).map{ case (from,to) => (from + diff, to + diff) }
      }
    }    
  } 
  
  object chars extends IndexedSeq[Char] {
    def apply(n: Int): Char = {
      buffer(n)
    }
        
    def length: Int = buffer.length    
  } 
}