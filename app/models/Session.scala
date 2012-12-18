package models

import js._
import isabelle._
import scala.actors.Actor._
import play.api.libs.json._
import scala.io.Source
import play.api.Logger
import java.lang.Throwable
import isabelle.Thy_Info

class Session(project: Project) extends JSConnector {
  val docs = scala.collection.mutable.Map[Document.Node.Name,RemoteDocumentModel]()
  
  var current: Option[Document.Node.Name] = None
  
  val thyLoad = new Thy_Load {
    override def read_header(name: Document.Node.Name): Thy_Header = {
      if (docs.isDefinedAt(name)) {
        Thy_Header.read(docs(name).buffer.mkString)        
      } else {        
	    val file = new java.io.File(name.node)
	    if (!file.exists || !file.isFile) error("No such file: " + quote(file.toString))
	    Thy_Header.read(file)
      }
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
      for {
        doc <- docs.get(node)        
      } {        
        js.ignore.states(node.node, states = MarkupTree.getStates(snap, doc.buffer.ranges))
        val cmds = snap.node.commands.map(_.id)
        doc.commands.keys.foreach { id =>
          if (!cmds.contains(id)) {
            doc.commands.remove(id)
            js.ignore.removeCommand(node.toString, id)
          }
        }
      }       
    }    
    change.commands.foreach(pushCommand)    
  }

  def pushCommand(cmd: Command): Unit = {
    val node = cmd.node_name
    if (Some(node) != current) return 
    
    val snap = session.snapshot(node, Nil)
    val start = snap.node.command_start(cmd)
    val state = snap.state.command_state(snap.version, cmd)
    if (!cmd.is_ignored) for (doc <- docs.get(node); start <- start) {
      val docStartLine = doc.buffer.line(start)
      var docEndLine = doc.buffer.line(start + cmd.length - 1)
      while (docEndLine >= 0 && !doc.buffer.lines(docEndLine).exists(c => c != ' ' && c != '\t'))
        docEndLine -= 1
      if (true) {//docStartLine >= doc.perspective._1 && docEndLine <= doc.perspective._2) {
	      val ranges = (docStartLine to docEndLine).map(doc.buffer.ranges.lift(_)).flatten.toVector
	      val cmdState = MarkupTree.getStates(snap, Vector((start, start + cmd.length - 1))).head
	      val tokens = MarkupTree.getTokens(snap, ranges).map {
	        _.map { token =>
	          val classes = token.info.map {
	            case x => x
	          }.distinct match {
	            case List("text") => "text"
	            case x            => x.filter(_ != "text").mkString(".")
	          }
	          val tooltip = MarkupTree.tooltip(snap, token.range)
	          Json.obj(
	            "value" -> doc.buffer.chars.slice(token.range.start, token.range.stop).mkString,
	            "type" -> classes,
	            "tooltip" -> tooltip
	          )
	        }
	      }
	      val json = Json.obj(
	        "id" -> cmd.id,
	        "version" -> doc.version,
	        "name" -> cmd.name,
	        "range" -> Json.obj(
	          "start" -> docStartLine,
	          "end" -> docEndLine),
	        "tokens" -> tokens,
	        "output" -> commandInfo(cmd),
	        "state" -> cmdState)
	      if (doc.commands.get(cmd.id) != Some(json))
	        doc.commands(cmd.id) = json
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
    case t: Thy_Header => Json.obj(
      "name"     -> t.name,
      "imports"  -> t.imports,
      "keywords" -> t.keywords.map {
        case (a,Some((b,c))) => Json.obj("name" -> a)
        case (a,None) => Json.obj("name" -> a)
      },
      "uses" -> t.uses.map { 
        case (a,b) => Json.obj(
            "name" -> Json.toJson(a),
            "is" -> Json.toJson(b))            
      }
    )
  }
  
  def commandInfo(cmd: Command) = {
    val snap = session.snapshot(cmd.node_name, Nil)
    val start = snap.node.command_start(cmd).map(docs(cmd.node_name).buffer.line(_)).get
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
      if (!docs.isDefinedAt(name)) try {
        val text = Source.fromFile(project.dir + name + ".thy").getLines.toTraversable // TODO        
        val doc = new RemoteDocumentModel()
        doc.buffer.lines.insertAll(0, text)
        session.init_node(name, node_header(name), Text.Perspective.full, doc.buffer.mkString)
        docs(name) = doc
        js.ignore.dependency(thy.toString, name.toString)
      } catch {
        case e: Throwable => 
          Logger.error(f"$thy could not be loaded")
          e.printStackTrace()
      }     
    }
  }
  
  val actions: PartialFunction[String, JsValue => Any] = {     
    case "getTheories" => json => project.theories
      
    case "open" => json => 
      val name = (json \ "id").as[String]
      val path = (json \ "path").as[String]
      val node = this.name(path)
      
      val doc = this.docs.getOrElseUpdate(node, {
        val text = Source.fromFile(project.dir + path).getLines.toTraversable
        val doc = new RemoteDocumentModel     
        doc.buffer.lines.insertAll(0, text)
        session.init_node(node, node_header(node), Text.Perspective.full, doc.buffer.mkString)
        doc
      })
            
      doc.buffer.mkString
      
    case "new" => json =>
      val name = json.as[String]
      val path = name + ".thy"
      val node = this.name(path)
      val doc = new RemoteDocumentModel
      doc.buffer.lines.insertAll(0,List(
        f"theory $name",
        "imports Main",
        "begin",
        "",
        "end"
      ))
      
      val out = scalax.io.Resource.fromFile(path)
      out.write(doc.buffer.mkString)      
      docs(node) = doc
      session.init_node(node, node_header(node), Text.Perspective.full, doc.buffer.mkString)
      js.ignore.addTheory(Theory(name,path))
      
    case "save" => json =>            
      val path = (json \ "path").as[String]
      val node = this.name(path)
      
      for (doc <- docs.get(node)) {
        val out = scalax.io.Resource.fromFile(path)
        out.write(doc.buffer.mkString)        
      }
        
      
    case "delete" => json =>
      val name = (json \ "id").as[String]
      val path = (json \ "path").as[String]
      val node = this.name(path)
                  
      docs.get(node) match {
        case None => false
        case Some(doc) =>
          docs.remove(node)
          new java.io.File(path).delete()
      }
      
      
                  
    case "close" => json =>
      val nodeName = json.as[String] 
      
    case "edit" => json =>
      session.cancel_execution()
      val nodeName = name((json \ "path").as[String])
      val changes = (json \ "changes").as[Array[Change]]
      val version = (json \ "version").as[Int]
      docs.get(nodeName).map{ doc =>        
        val edits = changes.toList.flatMap(c => doc.change(c.from, c.to, c.text))
        session.edit_node(nodeName, node_header(nodeName), Text.Perspective.full, edits)
        doc.version = version        
        js.ignore.check(nodeName.toString, version, doc.buffer.mkString)
      }      
      
    case "changePerspective" => json =>
      val nodeName = name((json \ "path").as[String])
      val start = (json \ "start").as[Int]
      val end = (json \ "end").as[Int]
      for (doc <- docs.get(nodeName)) {
        doc.perspective = (start,end)               
      }      
      
    case "setCurrentDoc" => json =>
      current = Some(name(json.as[String]))
      
  }
  
  override def onClose() {
    session.stop();
  }
  
  session.start(Nil)
}