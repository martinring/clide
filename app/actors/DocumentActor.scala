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

object DocumentActor {
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
 
  def node_header(): Document.Node_Header = Exn.capture {
    thy_load.check_header(name,
      Thy_Header.read(doc.mkString))
  }
  
  def init() {    	        	           
	session.init_node(name, node_header(), Text.Perspective.full, doc.mkString)	
  }
  
  override def preStart = {
    init()
    doc.listen(self)    
  }    
  
  def invalidate(start: Int = 0) {
    
  }
  
  def convertToken(add: String)(token: isabelle.Token) = token.kind match {
    case isabelle.Token.Kind.COMMENT =>
      Token("comment " + add, "(*" + token.content + "*)")
    case isabelle.Token.Kind.STRING =>
      Token("string " + add, "\"" + token.content + "\"")
    case isabelle.Token.Kind.VERBATIM =>
      Token("string " + add, "{*" + token.content + "*}")    
    case _ =>
      Token(token.kind.toString() + " " + add, token.content)
  }
  
  private val token_classes: Map[String, String] =
    Map(
      Isabelle_Markup.ERROR -> "error",      
      Isabelle_Markup.BAD -> "bad",
      Isabelle_Markup.WARNING -> "warn",
      Isabelle_Markup.KEYWORD -> "keyword",      
      Isabelle_Markup.COMMAND -> "command",
      Isabelle_Markup.COMMENT -> "comment",      
      Isabelle_Markup.STRING -> "string",
      Isabelle_Markup.ALTSTRING -> "altstring",
      Isabelle_Markup.VERBATIM -> "verbatim",
      Isabelle_Markup.LITERAL -> "literal",
      Isabelle_Markup.DELIMITER -> "delimiter",
      Isabelle_Markup.TFREE -> "typeFree",
      Isabelle_Markup.TVAR -> "typeVar",
      Isabelle_Markup.FREE -> "free",
      Isabelle_Markup.SKOLEM -> "skolem",
      Isabelle_Markup.BOUND -> "bound",
      Isabelle_Markup.VAR -> "var",
      Isabelle_Markup.INNER_STRING -> "inner_string",
      Isabelle_Markup.INNER_COMMENT -> "inner_comment",
      Isabelle_Markup.DYNAMIC_FACT -> "dynamic_fact",
      Isabelle_Markup.ML_KEYWORD -> "ml_keyword",
      Isabelle_Markup.ML_DELIMITER -> "ml_delimiter",
      Isabelle_Markup.ML_NUMERAL -> "ml_numeral",
      Isabelle_Markup.ML_CHAR -> "ml_char",
      Isabelle_Markup.ML_STRING -> "ml_string",
      Isabelle_Markup.ML_COMMENT -> "ml_comment",
      Isabelle_Markup.ML_MALFORMED -> "ml_malformed",
      Isabelle_Markup.ANTIQ -> "antiquotation")        

  private val token_class_elements = Set.empty[String] ++ token_classes.keys

  def markup(snapshot: Document.Snapshot, range: Text.Range)
      : Stream[Text.Info[String]] =
    snapshot.cumulate_markup(range, "", Some(token_class_elements),
      {
        case (x, Text.Info(_, XML.Elem(Markup(m, _), _)))
        if token_classes.isDefinedAt(m) => token_classes(m)
      })

  private val writeln_pri = 1
  private val warning_pri = 2
  private val legacy_pri = 3
  private val error_pri = 4      
      
  private val squiggly_colors = Map(
    writeln_pri -> "writeln",
    warning_pri -> "warning",
    error_pri -> "error")

  def squiggly_underline(snapshot: Document.Snapshot, range: Text.Range): Stream[Text.Info[String]] =
  {
    val results =
      snapshot.cumulate_markup[Int](range, 0,
        Some(Set(Isabelle_Markup.WRITELN, Isabelle_Markup.WARNING, Isabelle_Markup.ERROR)),
        {
          case (pri, Text.Info(_, XML.Elem(Markup(name, _), _))) =>
            name match {
              case Isabelle_Markup.WRITELN => pri max writeln_pri
              case Isabelle_Markup.WARNING => pri max warning_pri
              case Isabelle_Markup.ERROR => pri max error_pri
              case _ => pri
            }
        })
    for {
      Text.Info(r, pri) <- results
      color <- squiggly_colors.get(pri)
    } yield Text.Info(r, color)
  }  
      
  def receive = {
    case DocumentActor.GetText => 
      sender ! doc.mkString      
    case RemoteDocument.NewVersion(version,edits) =>
      session.edit_node(name, node_header(), Text.Perspective.full, edits)
      //doc.error(5, "test")
    case change: Session.Commands_Changed =>      
      val snapshot = session.snapshot(name,Nil)
      val markers = squiggly_underline(snapshot, Text.Range(0,doc.bufferLength)).toList
      markers.foreach(i => doc.markError(i.range.start, i.range.stop))
      val cs = markup(snapshot,Text.Range(0,doc.bufferLength))
      val tokens = cs.toList.map(c =>
        Token(c.info, doc.getRange(c.range.start, c.range.stop)))
        /*snapshot.node.commands.toList.flatMap { command =>
        val add = if (command.is_malformed) "error" else "" 
        command.span.map(convertToken(add))
      }*/
      val lines = Token.lines(tokens)
      doc.tokens(lines)
      
  }
}