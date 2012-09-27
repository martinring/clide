package models

import scala.collection.mutable.ArrayBuffer
import play.api.libs.iteratee._
import play.api.libs.json._
import play.api.libs.concurrent.Promise

class RemoteTokenizer() {
  val newline = "\n"
  val document = ArrayBuffer[String]("")
  var indices = Promise[List[Int]]   
  
  val out = Enumerator.imperative[JsValue]()  
  val in = Iteratee.foreach[JsValue]{ json =>
    for (delta <- json.as[Array[Delta]]) {      
	  println("Delta: " + delta)
      delta match {
	  case InsertText(range, text) => if (text == newline) {
		  val (left,right) = document(range.start.row).splitAt(range.start.column)
		  document(range.start.row) = left
		  document.insert(range.start.row + 1, right)
	    } else if (!text.contains(newline)) {
	      document(range.start.row) = {
	        val row = document(range.start.row)
	        row.take(range.start.column) + text + row.drop(range.start.column)
	      }
	    } else sys.error("insert text contains newlines")
	  case RemoveText(range, text) => if (text == newline) {	      
		  document(range.start.row) += document(range.start.row + 1)
		  document.remove(range.start.row + 1)
	    } else if (!text.contains(newline)){
	      document(range.start.row) = {
	        val row = document(range.start.row)
	        row.take(range.start.column) + row.drop(range.end.column)
	      }
	    } else sys.error("remove text contains newlines")
	  case InsertLines(range, lines) => {	    
	    document.insertAll(range.start.row, lines)
	  }
	  case RemoveLines(range, lines) =>	{
	    document.remove(range.start.row, range.end.row - range.start.row)
	  }	  
 	}}	    	
    println("------------------------")
    println(document.mkString(newline))
    println("------------------------")
  }
}