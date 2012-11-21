package models

import js._
import isabelle._
import scala.actors.Actor._
import play.api.libs.json._
import scala.io.Source
import models.ace._
import play.api.Logger

class Session(project: Project) extends JSConnector {
  val docs = scala.collection.mutable.Map[Document.Node.Name,RemoteDocument]()
  
  var current: Option[Document.Node.Name] = None
  
  val thyLoad = new Thy_Load {
    override def read_header(name: Document.Node.Name): Thy_Header = {
      val file = new java.io.File(name.node)
      if (!file.exists || !file.isFile) error("No such file: " + quote(file.toString))
      Thy_Header.read(file)
    }
  }
  
  val thyInfo = new Thy_Info(thyLoad)
  
  val session = new isabelle.Session(thyLoad)    
  
  session.phase_changed += { phase =>    
    js.ignore.setPhase(phase.toString)
    phase match {
      case Session.Ready =>
        js.ignore.setFiles(project.theories)
        js.ignore.setLogic(project.logic)
      case _ =>
    }
  }
      
  session.syslog_messages += { msg =>
    js.ignore.println(Pretty.str_of(msg.body))    
  }      
  
  session.caret_focus += { x =>
    println("caret focus: " + x)
  }              
  
  session.commands_changed += { change =>
    change.nodes.foreach { node =>
      delayedLoad(node)
      val snap = session.snapshot(node, Nil)      
      val status = Protocol.node_status(snap.state, snap.version, snap.node)
      js.ignore.status(
          node.toString, 
          status.unprocessed,
          status.running,
          status.finished,
          status.warned,
          status.failed)
      if (current == Some(node)) for {
        doc <- docs.get(node)
        states = MarkupTree.getLineStates(snap, doc.ranges)
      } js.ignore.states(node.toString, states)
    }    
    change.commands.foreach { cmd =>          
      val node = cmd.node_name
      val snap = session.snapshot(node, Nil)
      val start = snap.node.command_start(cmd)         
      val state = snap.state.command_state(snap.version, cmd)                                 
      if (!cmd.is_ignored) for (doc <- docs.get(node); start <- start) {
        val docStartLine = doc.line(start)
        val docEndLine   = doc.line(start + cmd.length - 1)        
        val ranges = (docStartLine to docEndLine).map(doc.ranges(_)).toVector
        val tokens = MarkupTree.getTokens(snap, ranges).map { _.map { token =>
          val classes = token.info.map{                       
            case x => x
          }.distinct match {
            case List("text") => "text"
            case x => x.filter(_ != "text").mkString(".")            
          }
          val tooltip = MarkupTree.tooltip(snap, token.range)          
          Json.obj(
            "value"   -> doc.getRange(token.range.start, token.range.stop),
            "type"    -> classes,
            "tooltip" -> tooltip            
          )
        } }
        val json = JsObject(
	      "id" -> JsNumber(cmd.id) ::
	      "version" -> JsNumber(doc.version) ::
	      "name" -> JsString(cmd.name) ::
	      "range" -> JsObject(
	        "start" -> JsNumber(docStartLine) ::
	        "end" -> JsNumber(docEndLine) :: Nil
	      ) ::
	      "tokens" -> Json.toJson(tokens) ::
	      "output" -> JsString(commandInfo(cmd)) ::	      
	      Nil)
	    js.ignore.commandChanged(cmd.node_name.toString, json)	    
      }            
    }
  }
  
  def name(path: String) =
    Document.Node.Name(Path.explode(project.dir + path))  
   
  def node_header(name: isabelle.Document.Node.Name): isabelle.Document.Node_Header = Exn.capture {
    thyLoad.check_header(name,
      thyLoad.read_header(name))
  }
  
  js.convert = js.convert.orElse {    
    case t: Thy_Header => JsObject {
      "name" -> Json.toJson(t.name) ::
      "imports" -> Json.toJson(t.imports) ::
      "keywords" -> Json.toJson(t.keywords map { 
        case (a,Some((b,c))) => JsObject(
            "name" -> Json.toJson(a) ::            
            Nil)
        case (a,None) => JsObject(
            "name" -> Json.toJson(a) ::
            Nil)
      }) ::
      "uses" -> JsArray(t.uses.map{ 
        case (a,b) => JsObject(
            "name" -> Json.toJson(a) ::
            "is" -> Json.toJson(b) ::
            Nil) 
      }) ::      
      Nil
    } 
  }
  
  def commandInfo(cmd: Command) = {
    val snap = session.snapshot(cmd.node_name, Nil)
    val start = snap.node.command_start(cmd).map(docs(cmd.node_name).line(_)).get
    val state = snap.state.command_state(snap.version, cmd)
    val filtered = state.results.map(_._2).filter(
	  {
	    case XML.Elem(Markup(Isabelle_Markup.TRACING, _), _) => false 
	    case _ => true
	  }).toList	
	val html_body =
      filtered.flatMap(div =>
	    Pretty.formatted(List(div), 0, Pretty.font_metric(null))
	      .map(t =>
	        XML.Elem(Markup(HTML.PRE, List((HTML.CLASS, Isabelle_Markup.MESSAGE))),
          HTML.spans(t, true))))    
    Pretty.string_of(state.results.values.toList)
  }
  
  def delayedLoad(thy: Document.Node.Name) {    
    thyInfo.dependencies(List(thy)).foreach { case (name,header) =>      
      if (!docs.isDefinedAt(name)) {
        val text = Source.fromFile(project.dir + name + ".thy").getLines.toSeq // TODO!
        val doc = new RemoteDocument     
        doc.insertLines(0, text :_*)
        session.init_node(name, node_header(name), Text.Perspective.full, doc.mkString)
        docs(name) = doc
        js.ignore.dependency(thy.toString, name.toString)
      }
    }
  }
  
  val actions: PartialFunction[String, JsValue => Any] = {     
    case "getTheories" => json =>
      project.theories
      
    case "open" => json => 
      val name = (json \ "id").as[String]
      val path = (json \ "path").as[String]
      val node = this.name(path)
      
      val doc = this.docs.getOrElseUpdate(node, {
        val text = Source.fromFile(project.dir + path).getLines.toSeq
        val doc = new RemoteDocument     
        doc.insertLines(0, text :_*)        
       session.init_node(node, node_header(node), Text.Perspective.full, doc.mkString)
        doc
      })
            
      doc.mkString
      
    case "new" => json =>      
      
    case "close" => json =>
      val nodeName = json.as[String]
      println("close " + nodeName)      
      
    case "edit" => json =>
      val nodeName = name((json \ "path").as[String])
      val deltas = (json \ "deltas").as[Array[ace.Delta]]
      docs.get(nodeName).map{ doc => 
        val edits = doc.edit(deltas.toVector)        
        session.edit_node(nodeName, node_header(nodeName), Text.Perspective.full, edits)        
      }
      
    case "changePerspective" => json =>
      val nodeName = name((json \ "path").as[String])
      val start = (json \ "start").as[Int]
      val end = (json \ "end").as[Int]
      for (doc <- docs.get(nodeName)) {
        doc.perspective = (start,end)
        session.edit_node(nodeName, node_header(nodeName), Text.Perspective.full, Nil)
      }
      println("change perspective of " + nodeName + " to " + start + " -> " + end)
      
    case "setCurrentDoc" => json =>        
      current = Some(name(json.as[String]))      
    
    case "moveCursor" => json =>
//      val nodeName = name((json \ "path").as[String])
//      val pos = (json \ "pos").as[ace.Position]
//      docs.get(nodeName) match {
//        case Some(doc) => 
//          doc.cursor = (pos.row, pos.column)
//          val snap = session.snapshot(nodeName, Nil)
//          val cmd = for {
//            pos <- doc.toOffset((pos.row,pos.column))
//            (cmd,start) <- snap.node.command_at(pos)
//          } yield cmd            
//          if (doc.currentCommand != cmd) {
//            doc.currentCommand = cmd            
//          }
//         
//        case None => sys.error("invalid node")
//      }
  }
  
  override def onClose() {
    session.stop();
  }
  
  session.start(Nil)
}