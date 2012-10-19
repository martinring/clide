package actors

import akka.actor.Actor
import akka.event.Logging
import scala.collection.mutable.Buffer
import play.api.libs.iteratee.Concurrent.Channel
import isabelle._
import isabelle.Text.Edit
import play.api.libs.json._
import models.ace.Delta
import models.ace.InsertLines
import models.ace.InsertNewline
import models.ace.InsertText
import models.ace.NoChange
import models.ace.RemoteDocument
import models.ace.RemoveLines
import models.ace.RemoveNewline
import models.ace.RemoveText
import models.ace.ReplaceText
import models.ace.Token
import scala.math.BigDecimal.int2bigDecimal
import scala.math.BigDecimal.long2bigDecimal
import models.MarkupTree

object DocumentActor {
  case class Reset(doc: RemoteDocument[Scan.Context])
  object Close
  object Pause
  object Start
  object GetText
}

class DocumentActor(
    val name: Document.Node.Name,
    var doc: RemoteDocument[Scan.Context],
    val session: Session,
    val thy_load: Thy_Load) extends Actor {
  val log = Logging(context.system, this)       
 
  override def preStart = {
	session.init_node(name, node_header(), Text.Perspective.full, doc.mkString)	
    doc.listen(self)    
  }    

  def node_header(): Document.Node_Header = Exn.capture {
    thy_load.check_header(name,
      Thy_Header.read(doc.mkString))
  }
    
  import Isabelle_Markup._
    
  def syntax(snapshot: Document.Snapshot, range: Text.Range): Stream[Text.Info[String]] = {
    val outer = Set(COMMAND,KEYWORD,STRING,ALTSTRING,VERBATIM,OPERATOR,COMMENT,CONTROL,
            MALFORMED,COMMAND_SPAN,IGNORED_SPAN,MALFORMED_SPAN)
            
    val inner = Set(TFREE,TVAR,FREE,SKOLEM,
            BOUND,VAR,NUMERAL,LITERAL,DELIMITER,INNER_STRING,INNER_COMMENT,TOKEN_RANGE,
            SORT,TYP,TERM,PROP,TYPING,ATTRIBUTE,METHOD,ANTIQ,ML_KEYWORD,ML_DELIMITER,
            ML_TVAR,ML_NUMERAL,ML_CHAR,ML_STRING,ML_COMMENT,ML_MALFORMED,ML_DEF,ML_OPEN,
            ML_STRUCT,ML_TYPING)
    
    snapshot.cumulate_markup[String](
        range,
        "accepted",
        Some(outer ++ inner),
        { case (x, m) => m.info.markup.name })
  }
                  
  def errors(snapshot: Document.Snapshot, range: Text.Range): Stream[Text.Info[(String,String)]] =
      snapshot.cumulate_markup[Option[(String,String)]](
          range, 
          None,
          Some(Set(ERROR)),
          { case (x, i) =>
            val msg = i.toString() // Pretty.string_of(i.info., 25)
            Some((i.info.markup.name,msg))
        }).collect{ case Text.Info(x,Some(n)) => Text.Info(x,n) }  
      
//  def gutter_message(snapshot: Document.Snapshot, range: Text.Range): Option[String] =
//  {
//    val results =
//      snapshot.cumulate_markup[Int](range, 0,
//        Some(Set(Isabelle_Markup.WARNING, Isabelle_Markup.ERROR)),
//        {
//          case (pri, Text.Info(_, XML.Elem(Markup(Isabelle_Markup.WARNING, _), body))) =>
//            body match {
//              case List(XML.Elem(Markup(Isabelle_Markup.LEGACY, _), _)) => pri max legacy_pri
//              case _ => pri max warning_pri
//            }
//          case (pri, Text.Info(_, XML.Elem(Markup(Isabelle_Markup.ERROR, _), body))) =>            
//            pri max error_pri
//        })
//    val pri = (0 /: results) { case (p1, Text.Info(_, p2)) => p1 max p2 }
//    gutter_icons.get(pri)
//  }  
  
  def receive = {
    case DocumentActor.GetText => 
      sender ! doc.mkString      
    case RemoteDocument.NewVersion(version,edits) =>
      session.edit_node(name, node_header(), Text.Perspective.full, edits)
      //doc.error(5, "test")
    case change: Session.Commands_Changed =>            
      val snapshot = session.snapshot(name)                                                           
      
//      doc.channel.push(JsObject(
//        "action" -> JsString("markup") ::
//        "markup" -> JsArray(snapshot.select_markup(snapshot.node.full_range, None, {
//          case markup => JsObject(
//            "name" -> JsString(markup.info.markup.name) ::            
//            "body" -> JsArray(markup.info.body.map(x => JsString(x.toString))) ::
//            "properties" -> JsObject(markup.info.markup.properties.map{
//              case (x,y) => x -> JsString(y)}) :: 
//            Nil)}).map(i => i.info + 
//            ("start" -> Json.toJson(doc.position(i.range.start))) + 
//            ("end" -> Json.toJson(doc.position(i.range.stop)))).toSeq) 
//       :: Nil))
            
      // markup             
      val i = syntax(snapshot,snapshot.node.full_range)
      val p = i.map(c => Token(List(c.info), doc.getRange(c.range.start, c.range.stop)))        
      val lines = Token.lines(p.toList)
      doc.updateTokens(lines)
      
      // gutter messages
//      for (((start,stop),line) <- doc.ranges.zipWithIndex) {
//        gutter_message(snapshot, Text.Range(start,stop)) match {
//          case Some("error") => doc.error(line, "")
//          case Some("warning") => doc.warning(line, "")
//          case Some("info") => doc.info(line, "")
//          case None => 
//        }
//      }
      
      errors(snapshot, snapshot.node.full_range) foreach { x =>
        println(x.range)
        doc.error(doc.position(x.range.start).row, x.info._2)
        doc.markError(x.range.start, x.range.stop)
      }
  }
}