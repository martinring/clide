package models

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import scala.collection.mutable.Buffer
import org.specs2.specification.Scope

class RemoteDocumentTest extends Specification {
  trait initDoc extends Scope {    
    var lines = Buffer("Hallo", "Test", "1", "2", "3", "Längere Zeile")
    val nl = "\r\n"
    val doc = new RemoteDocument(nl)
    doc.insertLines(0, lines: _*)
    
    def checkConsistency() = {
      doc.length must_== lines.length

      val offsets = lines.foldLeft(Vector(0)) {
        case (offsets, line) => offsets :+ (offsets.last + nl.length + line.length)
      }

      for ((o, i) <- offsets.zipWithIndex) {
        doc.offset(i) must_== o
      }

      for ((l, i) <- lines.zipWithIndex) {
        doc(i).mkString must_== l
      }

      doc.mkString must startWith(lines.mkString(nl))
    }

    
    checkConsistency()
  }

  "The RemoteDocument should be consistent after" >> {
    "insertLines" in new initDoc {
      doc.insertLines(2,"Hallo","Test")
      doc.insertLines(3, "one", "three")
      lines.insert(2,"Hallo","Test")
      lines.insert(3,"one","three")
      checkConsistency()
    }
    "removeLines" in new initDoc {
      doc.removeLines(1, 2)
      doc.removeLines(0, 1)
      lines.remove(1,2)
      lines.remove(0,1)
      checkConsistency()
    }
    "mergeLines" in new initDoc {
      doc.mergeLines(3)
      doc.mergeLines(3)
      lines(2) += lines(3)
      lines.remove(3)
      lines(2) += lines(3)
      lines.remove(3)
      checkConsistency()
    }
    "splitLines" in new initDoc {
      doc.splitLine(5, 4)
      lines.insert(6, lines(5).drop(4))
      lines(5) = lines(5).take(4)
      checkConsistency() 
    }
    "insertText" in new initDoc {
      doc.insertText(1, 2, "---")
      lines(1) = lines(1).take(2) + "---" + lines(1).drop(2)        
      checkConsistency()
    }
    "removeText" in new initDoc {
      doc.removeText(1, 1, 2)
      lines(1) = lines(1).take(1) + lines(1).drop(1+2)
      checkConsistency()
    }
  }
}