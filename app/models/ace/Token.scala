package models.ace

import play.api.libs.json._

case class Token(
    types: List[String], 
    value: String,
    tooltip: Option[String]
    ) {
  
  val id = {
    Token.id += 1
    "tk" + Token.id
  }
  
  private val newline = "\n"
    
  def isMultiline = value.contains(newline)
  
  def isEmpty = value.isEmpty
  
  def length = value.length
  
  def take(n: Int): Token = Token(types,value.take(n),tooltip)
  def drop(n: Int): Token = Token(types,value.drop(n),tooltip)
  
  def splitAt(n: Int): (Token,Token) = {
    val (left,right) = value.splitAt(n)
    (Token(types,left,tooltip),Token(types,right,tooltip))
  }
  
  def splitLine: (Token,Token) = {
    val (left,right) = value.splitAt(value.indexOf(newline))
    (Token(types,left,tooltip),Token(types,right.drop(newline.length),tooltip))
  }
}

object Token {
  private[ace] var id = 0: Long

  implicit object Writes extends Writes[Token] {
    def writes(token: Token) = JsObject(
        "type" -> JsString((token.id :: token.types).mkString(".")) ::
        "value" -> JsString(token.value) :: (token.tooltip match {
          case Some(tooltip) => "tooltip" -> JsString(tooltip) :: Nil
          case None          => Nil
        }))
  }        

  def lines(tokens: List[Token]): List[List[Token]] = {    
    val (left, right) = tokens.span(!_.isMultiline)
    right match {
      case head :: tail => 
        val (last, next) = head.splitLine
        (left :+ last).filter(!_.isEmpty) :: lines(next :: tail)
      case Nil => 
        List(left.filter(!_.isEmpty))
    }
  }
}

case class Line(val t: List[Token]) extends AnyVal {
  override def toString = t.map(_.value).mkString 
  
  def take(n: Int) = t.foldLeft((0, List.empty[Token])) {
    case ((p,r),t) if (p>n) => (p,r)
    case ((p,r),t) if (p+t.length>n) => (p+t.length,r:+t.take(n-p))
    case ((p,r),t) => (p+t.length,r:+t)
  }._2

  def drop(n: Int) = t.foldLeft((0, List.empty[Token])) {
    case ((p,r),t) if (p>n) => (p,r:+t)
    case ((p,r),t) if (p+t.length>n) => (p+t.length,r:+t.drop(n-p))
    case ((p,r),t) => (p+t.length,r)
  }._2

  def splitAt(n: Int) = t.foldLeft((0, (List.empty[Token],List.empty[Token]))) {
    case ((p,(l,r)),t) if (p>n) => (p,(l,r:+t))
    case ((p,(l,r)),t) if (p+t.length>n) =>
      val (a,b) = t.splitAt(n-p)
      (p+t.length,(l:+a,r:+b))
    case ((p,(l,r)),t) => (p+t.length,(l:+t,r))
  }._2    
}