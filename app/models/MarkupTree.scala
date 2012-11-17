package models

import isabelle._
import play.api.libs.json._

object MarkupTree {
  def getLineStates(
    snapshot: Document.Snapshot,
    ranges: Vector[(Int, Int)]) = ranges.map {
    case (start, end) =>
      type T = (Protocol.Status, Int)
      val f: PartialFunction[(T, Text.Info[XML.Elem]), T] = {
        case ((status, p), Text.Info(_, XML.Elem(markup, _))) =>
          if (markup.name == Isabelle_Markup.WARNING) (status, p max 1)
          else if (markup.name == Isabelle_Markup.ERROR) (status, p max 2)
          else (Protocol.command_status(status, markup), p)
      }
      val results = snapshot.cumulate_markup[(Protocol.Status, Int)](
        Text.Range(start, end),
        (Protocol.Status.init, 0),
        Some(Protocol.command_status_markup + Isabelle_Markup.WARNING + Isabelle_Markup.ERROR),
        f)
      if (results.isEmpty) "init"
      else {
        val (status, p) = ((Protocol.Status.init, 0) /: results) {
          case ((s1, p1), Text.Info(_, (s2, p2))) => (s1 + s2, p1 max p2)
        }
        if (p == 1) "warning"
        else if (p == 2) "error"
        else if (status.is_unprocessed) "unprocessed"
        else if (status.is_running) "running"
        else if (status.is_failed) "failed"
        else "finished"
      }
  }

  import Isabelle_Markup._
  val outer = Set(COMMAND,KEYWORD,STRING,ALTSTRING,VERBATIM,OPERATOR,COMMENT,CONTROL,
        MALFORMED,COMMAND_SPAN,IGNORED_SPAN,MALFORMED_SPAN,ERROR,WARNING)
        
  val inner = Set(TFREE,TVAR,FREE,SKOLEM,
        BOUND,VAR,NUMERAL,LITERAL,DELIMITER,INNER_STRING,INNER_COMMENT,TOKEN_RANGE,
        SORT,TYP,TERM,PROP,TYPING,ATTRIBUTE,METHOD,ANTIQ,ML_KEYWORD,ML_DELIMITER,
        ML_TVAR,ML_NUMERAL,ML_CHAR,ML_STRING,ML_COMMENT,ML_MALFORMED,ML_DEF,ML_OPEN,
        ML_STRUCT,ML_TYPING)
  
  def getTokens(
    snapshot: Document.Snapshot,
    ranges: Vector[(Int, Int)]) = ranges.map {
    case (start, end) =>
      def add(stream: Stream[Text.Info[List[String]]], set: Set[String]) = stream.map {
      case info => 
        val r = snapshot.cumulate_markup[List[String]](
          info.range, 
          List("text"), 
          Some(set),
          { case (x, m) => List(m.info.markup.name) })
        Text.Info(info.range, info.info ++ (r.foldLeft[List[String]](Nil){ case (a,b) => a ++ b.info }))
      }
            
      val fine = snapshot.cumulate_markup[List[String]](
        Text.Range(start,end),
        Nil,
        Some(outer ++ inner),
        { case (x, m) => List(m.info.markup.name) })
   
      add(add(add(fine,outer),Set(ERROR,WARNING)),Set(ENTITY))
  }
}