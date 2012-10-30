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
import scala.concurrent.ExecutionContext
import ExecutionContext.Implicits.global
import js.DynamicJsValue
import scala.language.dynamics
import scala.collection.immutable.SortedMap

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
    
  def syntax(snapshot: Document.Snapshot, range: Text.Range): Stream[Text.Info[List[String]]] = {
    val outer = Set(COMMAND,KEYWORD,STRING,ALTSTRING,VERBATIM,OPERATOR,COMMENT,CONTROL,
            MALFORMED,COMMAND_SPAN,IGNORED_SPAN,MALFORMED_SPAN,ERROR,WARNING)
            
    val inner = Set(TFREE,TVAR,FREE,SKOLEM,
            BOUND,VAR,NUMERAL,LITERAL,DELIMITER,INNER_STRING,INNER_COMMENT,TOKEN_RANGE,
            SORT,TYP,TERM,PROP,TYPING,ATTRIBUTE,METHOD,ANTIQ,ML_KEYWORD,ML_DELIMITER,
            ML_TVAR,ML_NUMERAL,ML_CHAR,ML_STRING,ML_COMMENT,ML_MALFORMED,ML_DEF,ML_OPEN,
            ML_STRUCT,ML_TYPING)
    
    def add(stream: Stream[Text.Info[List[String]]], set: Set[String]) = stream.map {
      case info => 
        val r = snapshot.cumulate_markup[List[String]](
          info.range, 
          Nil, 
          Some(set),
          { case (x, m) => List(m.info.markup.name) })
        Text.Info(info.range, info.info ++ (r.foldLeft[List[String]](Nil){ case (a,b) => a ++ b.info }))
      }
            
    val fine = snapshot.cumulate_markup[List[String]](
        range,
        Nil,
        Some(outer ++ inner),
        { case (x, m) => List(m.info.markup.name) })
   
    add(add(add(fine,outer),Set(ERROR,WARNING)),Set(ENTITY))
  }
                     
  def errors(snapshot: Document.Snapshot, range: Text.Range): Stream[Text.Info[(String,String)]] =
      snapshot.cumulate_markup[Option[(String,String)]](
          range, 
          None,
          Some(Set(ERROR,WARNING)),
          { case (x, i) =>
            val msg = Pretty.string_of(i.info.body, 25)
            Some((i.info.markup.name,msg))
        }).collect{ case Text.Info(x,Some(n)) => Text.Info(x,n) }  
  
  def receive = {
    case DocumentActor.GetText => 
      sender ! doc.mkString
    case RemoteDocument.NewVersion(version,edits) =>
      session.edit_node(name, node_header(), Text.Perspective.full, edits)
      //doc.error(5, "test")
    case change: Session.Commands_Changed =>
      //println(doc.js.sync.testSomething("Hallo").message.as[String])	    
      val snapshot = session.snapshot(name)                                                           
	  
//	  def fill(start: Text.Offset, map: Map[Text.Range, Token], classes: Set[String]) = {
//	    val ord = map.keys.toSeq.sorted(Text.Range.Ordering)
//	    val filled = ord.foldLeft(Vector[Text.Range](Text.Range(0,start))) {
//	      case (rs,next) => 
//	        if (rs.last.stop == next.start) rs :+ next
//	        else rs :+ Text.Range(rs.last.stop,next.start) :+ next
//	    }.tail
//	    Map(filled.map(x => x -> map.lift(x).getOrElse(Token(classes.toList,doc.getRange(x.start, x.stop)))) :_*)	   
//      }
	            
//      def tokens(tree: Markup_Tree, offset: Text.Offset, parent: Set[String]): Map[Text.Range, Token] =
//        tree.getBranches.flatMap { case (range,branch) =>
//          if (branch.subtree.getBranches.isEmpty)
//            Map[Text.Range,Token](branch.range + offset -> Token(
//                (parent ++ branch.elements).intersect(interesting).toList,
//                doc.getRange(branch.range.start + offset, branch.range.stop + offset)))
//          else
//            fill(offset,tokens(branch.subtree, offset + branch.range.start, parent ++ branch.elements), parent)
//        }
      
      
      
      def markup(tree: Markup_Tree, offset: Text.Offset): JsArray = JsArray(
        (for ((_,branch) <- tree.getBranches) yield JsObject(
          "range" -> Json.toJson(models.ace.Range(
              doc.position(branch.range.start + offset),
              doc.position(branch.range.stop + offset))) ::          
          "text" -> JsString(doc.getRange(branch.range.start + offset, branch.range.stop + offset)) ::
          "elements" -> JsArray(branch.elements.map(JsString).toSeq) ::
          "subtree" -> markup(branch.subtree,branch.range.start + offset) ::
          Nil
        )).toSeq
      )
      
      // markup
      for {
        cmd <- change.commands
        start <- snapshot.node.command_start(cmd)
      } {
        val info = snapshot.state.command_state(snapshot.version, cmd)
        doc.js.ignore.markup(doc.version, markup(info.markup, start))
      }
      
      val i = syntax(snapshot,snapshot.node.full_range)
      val p = i.map(c => Token(c.info, doc.getRange(c.range.start, c.range.stop)))        
      val lines = Token.lines(p.toList)
      doc.updateTokens(lines)
             
      errors(snapshot, snapshot.node.full_range) foreach { x => 
        val start = doc.position(x.range.start)
        val end = doc.position(x.range.stop)
        doc.js.ignore.annotate(
            doc.version, 
            start,
            x.info._1,
            x.info._2)
//        doc.js.ignore.mark(
//            doc.version,
//            models.ace.Range(start,end),
//            "error")
        //doc.markError(x.range.start, x.range.stop)
      }
  }
}