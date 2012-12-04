package js

import play.api.libs.iteratee._
import play.api.libs.json._
import play.api.Play.current
import play.api.libs.concurrent.Akka
import scala.concurrent.Future
import scala.concurrent.Promise
import scala.util.Try
import scala.language.dynamics
import scala.util.Success
import scala.util.Failure
import scala.concurrent.ExecutionContext
import scala.concurrent.Await
import scala.concurrent.duration._
import scala.actors.Futures
import ExecutionContext.Implicits.global

trait JSConnector {
  val (out, channel) = Concurrent.broadcast[JsValue] 
  
  object js {
    object ignore extends Dynamic {
      def selectDynamic(action: String): Unit =
        applyDynamicNamed(action)()

      def applyDynamicNamed(action: String)(args: (String, Any)*): Unit = 
        channel.push(JsObject(
          "action" -> JsString(action) ::            
            "args" -> JsArray(JsObject(args.map { case (n, a) => (n, convert(a)) }) :: Nil) ::
            Nil
        ))      

      def applyDynamic(action: String)(args: Any*): Unit = 
        channel.push(JsObject(
          "action" -> JsString(action) ::
            "args" -> JsArray(args map convert) ::
            Nil
        ))            
    }
    
    object async extends Dynamic {
      def selectDynamic(action: String): Future[JsValue] =
        applyDynamicNamed(action)()

      def applyDynamicNamed(action: String)(args: (String, Any)*): Future[JsValue] = {
        channel.push(JsObject(
          "action" -> JsString(action) ::
            "id" -> JsNumber(id) ::
            "args" -> JsArray(JsObject(args.map { case (n, a) => (n, convert(a)) }) :: Nil) ::
            Nil
        ))
        val result = Promise[JsValue]()
        requests(id) = result
        id += 1
        result.future
      }

      def applyDynamic(action: String)(args: Any*): Future[JsValue] = {
        channel.push(JsObject(
          "action" -> JsString(action) ::
            "id" -> JsNumber(id) ::
            "args" -> JsArray(args map convert) ::
            Nil
        ))
        val result = Promise[JsValue]()
        requests(id) = result
        id += 1
        result.future
      }
    }
    
    object sync extends Dynamic {
      def selectDynamic(action: String): JsValue = 
        Await.result(async.selectDynamic(action), Duration(5,"seconds"))
      def applyDynamicNamed(action: String)(args: (String, Any)*): JsValue =
        Await.result(async.applyDynamicNamed(action)(args :_*), Duration(5,"seconds"))
      def applyDynamic(action: String)(args: Any*): JsValue =
        Await.result(async.applyDynamic(action)(args :_*), Duration(5,"seconds"))      
    }
    
    var convert: PartialFunction[Any,JsValue] = {
      case i: Int => JsNumber(i)
      case i: Long => JsNumber(i)
      case s: String => JsString(s)
      case t: Traversable[_] => JsArray(t.map(convert).toSeq)
      case a: Array[_] => JsArray(a.map(convert))
      case t: models.Theory => Json.toJson(t)      
      case js: JsValue => js
    }
    
    val requests = scala.collection.mutable.Map[Long,Promise[JsValue]]()
    
    var id: Long = 1     
  }          
          
  def actions: PartialFunction[String,JsValue => Any]    
  
  def onClose(): Unit = {}
  
  val in = Iteratee.foreach[JsValue] { json =>    
    (json \ "action").asOpt[String] match {
      case Some(a) =>        
        require(actions.isDefinedAt(a))
        scala.concurrent.future(actions(a)(json \ "data")).onComplete {
          case Success(result) =>           
            (json \ "id").asOpt[Long].map(id => channel.push(JsObject(
                "resultFor" -> JsNumber(id) ::
                "data" -> js.convert(result) ::
                Nil)))
          case Failure(msg) =>
            msg.printStackTrace()
        }
      case None => (json \ "resultFor").asOpt[Long] match {
        case Some(id) =>          
          val p: Promise[JsValue] = js.requests(id)
          if (!(json \ "success").as[Boolean])
            p.failure(new Exception((json \ "message").as[String]))
          else
            p.complete(Try(json \ "data"))
          js.requests.remove(id)
        case None =>
      }
    }
  }.mapDone(_ => onClose)
}