package models

import isabelle._
import play.api.libs.json._

object MarkupTree {
  def getLineStates(
      snapshot: Document.Snapshot, 
      ranges: Vector[(Int,Int)], 
      perspective: Text.Perspective = Text.Perspective.full) = ranges.map {
      case (start,end) =>
        type T = (Protocol.Status,Int)
        val f: PartialFunction[(T,Text.Info[XML.Elem]),T] = {
          case ((status,p), Text.Info(_,XML.Elem(markup,_))) =>
            if (markup.name == Isabelle_Markup.WARNING) (status, p max 1)
            else if (markup.name == Isabelle_Markup.ERROR) (status, p max 2)
            else (Protocol.command_status(status, markup), p)
        }
        val results = snapshot.cumulate_markup[(Protocol.Status,Int)](
          Text.Range(start,end),
          (Protocol.Status.init,0), 
          Some(Protocol.command_status_markup + Isabelle_Markup.WARNING + Isabelle_Markup.ERROR),
          f)        
        if (results.isEmpty) "init"
        else {
          val (status,p) = ((Protocol.Status.init, 0) /: results) {
            case ((s1,p1), Text.Info(_, (s2,p2))) => (s1 + s2, p1 max p2) }
          if (p == 1) "warning"
          else if (p == 2) "error"
		  else if (status.is_unprocessed) "unprocessed"
		  else if (status.is_running) "running"
		  else if (status.is_failed) "failed"
		  else "finished"
    }
  }
}