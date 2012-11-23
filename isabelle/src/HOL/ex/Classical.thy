(*  Title:      HOL/ex/Classical.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1994  University of Cambridge
*)

header{*Classical Predicate Calculus Problems*}

theory Classical imports Main begin

subsection{*Traditional Classical Reasoner*}

text{*The machine "griffon" mentioned below is a 2.5GHz Power Mac G5.*}

text{*Taken from @{text "FOL/Classical.thy"}. When porting examples from
first-order logic, beware of the precedence of @{text "="} versus @{text
"\<leftrightarrow>"}.*}

lemma "(P --> Q | R) --> (P-->Q) | (P-->R)"
by blast

text{*If and only if*}

lemma "(P=Q) = (Q = (P::bool))"
by blast

lemma "~ (P = (~P))"
by blast


text{*Sample problems from
  F. J. Pelletier,
  Seventy-Five Problems for Testing Automatic Theorem Provers,
  J. Automated Reasoning 2 (1986), 191-216.
  Errata, JAR 4 (1988), 236-236.

The hardest problems -- judging by experience with several theorem provers,
including matrix ones -- are 34 and 43.
*}

subsubsection{*Pelletier's examples*}

text{*1*}
lemma "(P-->Q)  =  (~Q --> ~P)"
by blast

text{*2*}
lemma "(~ ~ P) =  P"
by blast

text{*3*}
lemma "~(P-->Q) --> (Q-->P)"
by blast

text{*4*}
lemma "(~P-->Q)  =  (~Q --> P)"
by blast

text{*5*}
lemma "((P|Q)-->(P|R)) --> (P|(Q-->R))"
by blast

text{*6*}
lemma "P | ~ P"
by blast

text{*7*}
lemma "P | ~ ~ ~ P"
by blast

text{*8.  Peirce's law*}
lemma "((P-->Q) --> P)  -->  P"
by blast

text{*9*}
lemma "((P|Q) & (~P|Q) & (P| ~Q)) --> ~ (~P | ~Q)"
by blast

text{*10*}
lemma "(Q-->R) & (R-->P&Q) & (P-->Q|R) --> (P=Q)"
by blast

text{*11.  Proved in each direction (incorrectly, says Pelletier!!)  *}
lemma "P=(P::bool)"
by blast

text{*12.  "Dijkstra's law"*}
lemma "((P = Q) = R) = (P = (Q = R))"
by blast

text{*13.  Distributive law*}
lemma "(P | (Q & R)) = ((P | Q) & (P | R))"
by blast

text{*14*}
lemma "(P = Q) = ((Q | ~P) & (~Q|P))"
by blast

text{*15*}
lemma "(P --> Q) = (~P | Q)"
by blast

text{*16*}
lemma "(P-->Q) | (Q-->P)"
by blast

text{*17*}
lemma "((P & (Q-->R))-->S)  =  ((~P | Q | S) & (~P | ~R | S))"
by blast

subsubsection{*Classical Logic: examples with quantifiers*}

lemma "(\<forall>x. P(x) & Q(x)) = ((\<forall>x. P(x)) & (\<forall>x. Q(x)))"
by blast

lemma "(\<exists>x. P-->Q(x))  =  (P --> (\<exists>x. Q(x)))"
by blast

lemma "(\<exists>x. P(x)-->Q) = ((\<forall>x. P(x)) --> Q)"
by blast

lemma "((\<forall>x. P(x)) | Q)  =  (\<forall>x. P(x) | Q)"
by blast

text{*From Wishnu Prasetya*}
lemma "(\<forall>s. q(s) --> r(s)) & ~r(s) & (\<forall>s. ~r(s) & ~q(s) --> p(t) | q(t))
    --> p(t) | r(t)"
by blast


subsubsection{*Problems requiring quantifier duplication*}

text{*Theorem B of Peter Andrews, Theorem Proving via General Matings,
  JACM 28 (1981).*}
lemma "(\<exists>x. \<forall>y. P(x) = P(y)) --> ((\<exists>x. P(x)) = (\<forall>y. P(y)))"
by blast

text{*Needs multiple instantiation of the quantifier.*}
lemma "(\<forall>x. P(x)-->P(f(x)))  &  P(d)-->P(f(f(f(d))))"
by blast

text{*Needs double instantiation of the quantifier*}
lemma "\<exists>x. P(x) --> P(a) & P(b)"
by blast

lemma "\<exists>z. P(z) --> (\<forall>x. P(x))"
by blast

lemma "\<exists>x. (\<exists>y. P(y)) --> P(x)"
by blast

subsubsection{*Hard examples with quantifiers*}

text{*Problem 18*}
lemma "\<exists>y. \<forall>x. P(y)-->P(x)"
by blast

text{*Problem 19*}
lemma "\<exists>x. \<forall>y z. (P(y)-->Q(z)) --> (P(x)-->Q(x))"
by blast

text{*Problem 20*}
lemma "(\<forall>x y. \<exists>z. \<forall>w. (P(x)&Q(y)-->R(z)&S(w)))
    --> (\<exists>x y. P(x) & Q(y)) --> (\<exists>z. R(z))"
by blast

text{*Problem 21*}
lemma "(\<exists>x. P-->Q(x)) & (\<exists>x. Q(x)-->P) --> (\<exists>x. P=Q(x))"
by blast

text{*Problem 22*}
lemma "(\<forall>x. P = Q(x))  -->  (P = (\<forall>x. Q(x)))"
by blast

text{*Problem 23*}
lemma "(\<forall>x. P | Q(x))  =  (P | (\<forall>x. Q(x)))"
by blast

text{*Problem 24*}
lemma "~(\<exists>x. S(x)&Q(x)) & (\<forall>x. P(x) --> Q(x)|R(x)) &
     (~(\<exists>x. P(x)) --> (\<exists>x. Q(x))) & (\<forall>x. Q(x)|R(x) --> S(x))
    --> (\<exists>x. P(x)&R(x))"
by blast

text{*Problem 25*}
lemma "(\<exists>x. P(x)) &
        (\<forall>x. L(x) --> ~ (M(x) & R(x))) &
        (\<forall>x. P(x) --> (M(x) & L(x))) &
        ((\<forall>x. P(x)-->Q(x)) | (\<exists>x. P(x)&R(x)))
    --> (\<exists>x. Q(x)&P(x))"
by blast

text{*Problem 26*}
lemma "((\<exists>x. p(x)) = (\<exists>x. q(x))) &
      (\<forall>x. \<forall>y. p(x) & q(y) --> (r(x) = s(y)))
  --> ((\<forall>x. p(x)-->r(x)) = (\<forall>x. q(x)-->s(x)))"
by blast

text{*Problem 27*}
lemma "(\<exists>x. P(x) & ~Q(x)) &
              (\<forall>x. P(x) --> R(x)) &
              (\<forall>x. M(x) & L(x) --> P(x)) &
              ((\<exists>x. R(x) & ~ Q(x)) --> (\<forall>x. L(x) --> ~ R(x)))
          --> (\<forall>x. M(x) --> ~L(x))"
by blast

text{*Problem 28.  AMENDED*}
lemma "(\<forall>x. P(x) --> (\<forall>x. Q(x))) &
        ((\<forall>x. Q(x)|R(x)) --> (\<exists>x. Q(x)&S(x))) &
        ((\<exists>x. S(x)) --> (\<forall>x. L(x) --> M(x)))
    --> (\<forall>x. P(x) & L(x) --> M(x))"
by blast

text{*Problem 29.  Essentially the same as Principia Mathematica *11.71*}
lemma "(\<exists>x. F(x)) & (\<exists>y. G(y))
    --> ( ((\<forall>x. F(x)-->H(x)) & (\<forall>y. G(y)-->J(y)))  =
          (\<forall>x y. F(x) & G(y) --> H(x) & J(y)))"
by blast

text{*Problem 30*}
lemma "(\<forall>x. P(x) | Q(x) --> ~ R(x)) &
        (\<forall>x. (Q(x) --> ~ S(x)) --> P(x) & R(x))
    --> (\<forall>x. S(x))"
by blast

text{*Problem 31*}
lemma "~(\<exists>x. P(x) & (Q(x) | R(x))) &
        (\<exists>x. L(x) & P(x)) &
        (\<forall>x. ~ R(x) --> M(x))
    --> (\<exists>x. L(x) & M(x))"
by blast

text{*Problem 32*}
lemma "(\<forall>x. P(x) & (Q(x)|R(x))-->S(x)) &
        (\<forall>x. S(x) & R(x) --> L(x)) &
        (\<forall>x. M(x) --> R(x))
    --> (\<forall>x. P(x) & M(x) --> L(x))"
by blast

text{*Problem 33*}
lemma "(\<forall>x. P(a) & (P(x)-->P(b))-->P(c))  =
     (\<forall>x. (~P(a) | P(x) | P(c)) & (~P(a) | ~P(b) | P(c)))"
by blast

text{*Problem 34  AMENDED (TWICE!!)*}
text{*Andrews's challenge*}
lemma "((\<exists>x. \<forall>y. p(x) = p(y))  =
               ((\<exists>x. q(x)) = (\<forall>y. p(y))))   =
              ((\<exists>x. \<forall>y. q(x) = q(y))  =
               ((\<exists>x. p(x)) = (\<forall>y. q(y))))"
by blast

text{*Problem 35*}
lemma "\<exists>x y. P x y -->  (\<forall>u v. P u v)"
by blast

text{*Problem 36*}
lemma "(\<forall>x. \<exists>y. J x y) &
        (\<forall>x. \<exists>y. G x y) &
        (\<forall>x y. J x y | G x y -->
        (\<forall>z. J y z | G y z --> H x z))
    --> (\<forall>x. \<exists>y. H x y)"
by blast

text{*Problem 37*}
lemma "(\<forall>z. \<exists>w. \<forall>x. \<exists>y.
           (P x z -->P y w) & P y z & (P y w --> (\<exists>u. Q u w))) &
        (\<forall>x z. ~(P x z) --> (\<exists>y. Q y z)) &
        ((\<exists>x y. Q x y) --> (\<forall>x. R x x))
    --> (\<forall>x. \<exists>y. R x y)"
by blast

text{*Problem 38*}
lemma "(\<forall>x. p(a) & (p(x) --> (\<exists>y. p(y) & r x y)) -->
           (\<exists>z. \<exists>w. p(z) & r x w & r w z))  =
     (\<forall>x. (~p(a) | p(x) | (\<exists>z. \<exists>w. p(z) & r x w & r w z)) &
           (~p(a) | ~(\<exists>y. p(y) & r x y) |
            (\<exists>z. \<exists>w. p(z) & r x w & r w z)))"
by blast (*beats fast!*)

text{*Problem 39*}
lemma "~ (\<exists>x. \<forall>y. F y x = (~ F y y))"
by blast

text{*Problem 40.  AMENDED*}
lemma "(\<exists>y. \<forall>x. F x y = F x x)
        -->  ~ (\<forall>x. \<exists>y. \<forall>z. F z y = (~ F z x))"
by blast

text{*Problem 41*}
lemma "(\<forall>z. \<exists>y. \<forall>x. f x y = (f x z & ~ f x x))
               --> ~ (\<exists>z. \<forall>x. f x z)"
by blast

text{*Problem 42*}
lemma "~ (\<exists>y. \<forall>x. p x y = (~ (\<exists>z. p x z & p z x)))"
by blast

text{*Problem 43!!*}
lemma "(\<forall>x::'a. \<forall>y::'a. q x y = (\<forall>z. p z x = (p z y::bool)))
  --> (\<forall>x. (\<forall>y. q x y = (q y x::bool)))"
by blast

text{*Problem 44*}
lemma "(\<forall>x. f(x) -->
              (\<exists>y. g(y) & h x y & (\<exists>y. g(y) & ~ h x y)))  &
              (\<exists>x. j(x) & (\<forall>y. g(y) --> h x y))
              --> (\<exists>x. j(x) & ~f(x))"
by blast

text{*Problem 45*}
lemma "(\<forall>x. f(x) & (\<forall>y. g(y) & h x y --> j x y)
                      --> (\<forall>y. g(y) & h x y --> k(y))) &
     ~ (\<exists>y. l(y) & k(y)) &
     (\<exists>x. f(x) & (\<forall>y. h x y --> l(y))
                & (\<forall>y. g(y) & h x y --> j x y))
      --> (\<exists>x. f(x) & ~ (\<exists>y. g(y) & h x y))"
by blast


subsubsection{*Problems (mainly) involving equality or functions*}

text{*Problem 48*}
lemma "(a=b | c=d) & (a=c | b=d) --> a=d | b=c"
by blast

text{*Problem 49  NOT PROVED AUTOMATICALLY.
     Hard because it involves substitution for Vars
  the type constraint ensures that x,y,z have the same type as a,b,u. *}
lemma "(\<exists>x y::'a. \<forall>z. z=x | z=y) & P(a) & P(b) & (~a=b)
                --> (\<forall>u::'a. P(u))"
by metis

text{*Problem 50.  (What has this to do with equality?) *}
lemma "(\<forall>x. P a x | (\<forall>y. P x y)) --> (\<exists>x. \<forall>y. P x y)"
by blast

text{*Problem 51*}
lemma "(\<exists>z w. \<forall>x y. P x y = (x=z & y=w)) -->
     (\<exists>z. \<forall>x. \<exists>w. (\<forall>y. P x y = (y=w)) = (x=z))"
by blast

text{*Problem 52. Almost the same as 51. *}
lemma "(\<exists>z w. \<forall>x y. P x y = (x=z & y=w)) -->
     (\<exists>w. \<forall>y. \<exists>z. (\<forall>x. P x y = (x=z)) = (y=w))"
by blast

text{*Problem 55*}

text{*Non-equational version, from Manthey and Bry, CADE-9 (Springer, 1988).
  fast DISCOVERS who killed Agatha. *}
schematic_lemma "lives(agatha) & lives(butler) & lives(charles) &
   (killed agatha agatha | killed butler agatha | killed charles agatha) &
   (\<forall>x y. killed x y --> hates x y & ~richer x y) &
   (\<forall>x. hates agatha x --> ~hates charles x) &
   (hates agatha agatha & hates agatha charles) &
   (\<forall>x. lives(x) & ~richer x agatha --> hates butler x) &
   (\<forall>x. hates agatha x --> hates butler x) &
   (\<forall>x. ~hates x agatha | ~hates x butler | ~hates x charles) -->
    killed ?who agatha"
by fast

text{*Problem 56*}
lemma "(\<forall>x. (\<exists>y. P(y) & x=f(y)) --> P(x)) = (\<forall>x. P(x) --> P(f(x)))"
by blast

text{*Problem 57*}
lemma "P (f a b) (f b c) & P (f b c) (f a c) &
     (\<forall>x y z. P x y & P y z --> P x z)    -->   P (f a b) (f a c)"
by blast

text{*Problem 58  NOT PROVED AUTOMATICALLY*}
lemma "(\<forall>x y. f(x)=g(y)) --> (\<forall>x y. f(f(x))=f(g(y)))"
by (fast intro: arg_cong [of concl: f])

text{*Problem 59*}
lemma "(\<forall>x. P(x) = (~P(f(x)))) --> (\<exists>x. P(x) & ~P(f(x)))"
by blast

text{*Problem 60*}
lemma "\<forall>x. P x (f x) = (\<exists>y. (\<forall>z. P z y --> P z (f x)) & P x y)"
by blast

text{*Problem 62 as corrected in JAR 18 (1997), page 135*}
lemma "(\<forall>x. p a & (p x --> p(f x)) --> p(f(f x)))  =
      (\<forall>x. (~ p a | p x | p(f(f x))) &
              (~ p a | ~ p(f x) | p(f(f x))))"
by blast

text{*From Davis, Obvious Logical Inferences, IJCAI-81, 530-531
  fast indeed copes!*}
lemma "(\<forall>x. F(x) & ~G(x) --> (\<exists>y. H(x,y) & J(y))) &
       (\<exists>x. K(x) & F(x) & (\<forall>y. H(x,y) --> K(y))) &
       (\<forall>x. K(x) --> ~G(x))  -->  (\<exists>x. K(x) & J(x))"
by fast

text{*From Rudnicki, Obvious Inferences, JAR 3 (1987), 383-393.
  It does seem obvious!*}
lemma "(\<forall>x. F(x) & ~G(x) --> (\<exists>y. H(x,y) & J(y))) &
       (\<exists>x. K(x) & F(x) & (\<forall>y. H(x,y) --> K(y)))  &
       (\<forall>x. K(x) --> ~G(x))   -->   (\<exists>x. K(x) --> ~G(x))"
by fast

text{*Attributed to Lewis Carroll by S. G. Pulman.  The first or last
assumption can be deleted.*}
lemma "(\<forall>x. honest(x) & industrious(x) --> healthy(x)) &
      ~ (\<exists>x. grocer(x) & healthy(x)) &
      (\<forall>x. industrious(x) & grocer(x) --> honest(x)) &
      (\<forall>x. cyclist(x) --> industrious(x)) &
      (\<forall>x. ~healthy(x) & cyclist(x) --> ~honest(x))
      --> (\<forall>x. grocer(x) --> ~cyclist(x))"
by blast

lemma "(\<forall>x y. R(x,y) | R(y,x)) &
       (\<forall>x y. S(x,y) & S(y,x) --> x=y) &
       (\<forall>x y. R(x,y) --> S(x,y))    -->   (\<forall>x y. S(x,y) --> R(x,y))"
by blast


subsection{*Model Elimination Prover*}


text{*Trying out meson with arguments*}
lemma "x < y & y < z --> ~ (z < (x::nat))"
by (meson order_less_irrefl order_less_trans)

text{*The "small example" from Bezem, Hendriks and de Nivelle,
Automatic Proof Construction in Type Theory Using Resolution,
JAR 29: 3-4 (2002), pages 253-275 *}
lemma "(\<forall>x y z. R(x,y) & R(y,z) --> R(x,z)) &
       (\<forall>x. \<exists>y. R(x,y)) -->
       ~ (\<forall>x. P x = (\<forall>y. R(x,y) --> ~ P y))"
by (tactic{*Meson.safe_best_meson_tac @{context} 1*})
    --{*In contrast, @{text meson} is SLOW: 7.6s on griffon*}


subsubsection{*Pelletier's examples*}
text{*1*}
lemma "(P --> Q)  =  (~Q --> ~P)"
by blast

text{*2*}
lemma "(~ ~ P) =  P"
by blast

text{*3*}
lemma "~(P-->Q) --> (Q-->P)"
by blast

text{*4*}
lemma "(~P-->Q)  =  (~Q --> P)"
by blast

text{*5*}
lemma "((P|Q)-->(P|R)) --> (P|(Q-->R))"
by blast

text{*6*}
lemma "P | ~ P"
by blast

text{*7*}
lemma "P | ~ ~ ~ P"
by blast

text{*8.  Peirce's law*}
lemma "((P-->Q) --> P)  -->  P"
by blast

text{*9*}
lemma "((P|Q) & (~P|Q) & (P| ~Q)) --> ~ (~P | ~Q)"
by blast

text{*10*}
lemma "(Q-->R) & (R-->P&Q) & (P-->Q|R) --> (P=Q)"
by blast

text{*11.  Proved in each direction (incorrectly, says Pelletier!!)  *}
lemma "P=(P::bool)"
by blast

text{*12.  "Dijkstra's law"*}
lemma "((P = Q) = R) = (P = (Q = R))"
by blast

text{*13.  Distributive law*}
lemma "(P | (Q & R)) = ((P | Q) & (P | R))"
by blast

text{*14*}
lemma "(P = Q) = ((Q | ~P) & (~Q|P))"
by blast

text{*15*}
lemma "(P --> Q) = (~P | Q)"
by blast

text{*16*}
lemma "(P-->Q) | (Q-->P)"
by blast

text{*17*}
lemma "((P & (Q-->R))-->S)  =  ((~P | Q | S) & (~P | ~R | S))"
by blast

subsubsection{*Classical Logic: examples with quantifiers*}

lemma "(\<forall>x. P x & Q x) = ((\<forall>x. P x) & (\<forall>x. Q x))"
by blast

lemma "(\<exists>x. P --> Q x)  =  (P --> (\<exists>x. Q x))"
by blast

lemma "(\<exists>x. P x --> Q) = ((\<forall>x. P x) --> Q)"
by blast

lemma "((\<forall>x. P x) | Q)  =  (\<forall>x. P x | Q)"
by blast

lemma "(\<forall>x. P x --> P(f x))  &  P d --> P(f(f(f d)))"
by blast

text{*Needs double instantiation of EXISTS*}
lemma "\<exists>x. P x --> P a & P b"
by blast

lemma "\<exists>z. P z --> (\<forall>x. P x)"
by blast

text{*From a paper by Claire Quigley*}
lemma "\<exists>y. ((P c & Q y) | (\<exists>z. ~ Q z)) | (\<exists>x. ~ P x & Q d)"
by fast

subsubsection{*Hard examples with quantifiers*}

text{*Problem 18*}
lemma "\<exists>y. \<forall>x. P y --> P x"
by blast

text{*Problem 19*}
lemma "\<exists>x. \<forall>y z. (P y --> Q z) --> (P x --> Q x)"
by blast

text{*Problem 20*}
lemma "(\<forall>x y. \<exists>z. \<forall>w. (P x & Q y --> R z & S w))
    --> (\<exists>x y. P x & Q y) --> (\<exists>z. R z)"
by blast

text{*Problem 21*}
lemma "(\<exists>x. P --> Q x) & (\<exists>x. Q x --> P) --> (\<exists>x. P=Q x)"
by blast

text{*Problem 22*}
lemma "(\<forall>x. P = Q x)  -->  (P = (\<forall>x. Q x))"
by blast

text{*Problem 23*}
lemma "(\<forall>x. P | Q x)  =  (P | (\<forall>x. Q x))"
by blast

text{*Problem 24*}  (*The first goal clause is useless*)
lemma "~(\<exists>x. S x & Q x) & (\<forall>x. P x --> Q x | R x) &
      (~(\<exists>x. P x) --> (\<exists>x. Q x)) & (\<forall>x. Q x | R x --> S x)
    --> (\<exists>x. P x & R x)"
by blast

text{*Problem 25*}
lemma "(\<exists>x. P x) &
      (\<forall>x. L x --> ~ (M x & R x)) &
      (\<forall>x. P x --> (M x & L x)) &
      ((\<forall>x. P x --> Q x) | (\<exists>x. P x & R x))
    --> (\<exists>x. Q x & P x)"
by blast

text{*Problem 26; has 24 Horn clauses*}
lemma "((\<exists>x. p x) = (\<exists>x. q x)) &
      (\<forall>x. \<forall>y. p x & q y --> (r x = s y))
  --> ((\<forall>x. p x --> r x) = (\<forall>x. q x --> s x))"
by blast

text{*Problem 27; has 13 Horn clauses*}
lemma "(\<exists>x. P x & ~Q x) &
      (\<forall>x. P x --> R x) &
      (\<forall>x. M x & L x --> P x) &
      ((\<exists>x. R x & ~ Q x) --> (\<forall>x. L x --> ~ R x))
      --> (\<forall>x. M x --> ~L x)"
by blast

text{*Problem 28.  AMENDED; has 14 Horn clauses*}
lemma "(\<forall>x. P x --> (\<forall>x. Q x)) &
      ((\<forall>x. Q x | R x) --> (\<exists>x. Q x & S x)) &
      ((\<exists>x. S x) --> (\<forall>x. L x --> M x))
    --> (\<forall>x. P x & L x --> M x)"
by blast

text{*Problem 29.  Essentially the same as Principia Mathematica *11.71.
      62 Horn clauses*}
lemma "(\<exists>x. F x) & (\<exists>y. G y)
    --> ( ((\<forall>x. F x --> H x) & (\<forall>y. G y --> J y))  =
          (\<forall>x y. F x & G y --> H x & J y))"
by blast


text{*Problem 30*}
lemma "(\<forall>x. P x | Q x --> ~ R x) & (\<forall>x. (Q x --> ~ S x) --> P x & R x)
       --> (\<forall>x. S x)"
by blast

text{*Problem 31; has 10 Horn clauses; first negative clauses is useless*}
lemma "~(\<exists>x. P x & (Q x | R x)) &
      (\<exists>x. L x & P x) &
      (\<forall>x. ~ R x --> M x)
    --> (\<exists>x. L x & M x)"
by blast

text{*Problem 32*}
lemma "(\<forall>x. P x & (Q x | R x)-->S x) &
      (\<forall>x. S x & R x --> L x) &
      (\<forall>x. M x --> R x)
    --> (\<forall>x. P x & M x --> L x)"
by blast

text{*Problem 33; has 55 Horn clauses*}
lemma "(\<forall>x. P a & (P x --> P b)-->P c)  =
      (\<forall>x. (~P a | P x | P c) & (~P a | ~P b | P c))"
by blast

text{*Problem 34: Andrews's challenge has 924 Horn clauses*}
lemma "((\<exists>x. \<forall>y. p x = p y)  = ((\<exists>x. q x) = (\<forall>y. p y)))     =
      ((\<exists>x. \<forall>y. q x = q y)  = ((\<exists>x. p x) = (\<forall>y. q y)))"
by blast

text{*Problem 35*}
lemma "\<exists>x y. P x y -->  (\<forall>u v. P u v)"
by blast

text{*Problem 36; has 15 Horn clauses*}
lemma "(\<forall>x. \<exists>y. J x y) & (\<forall>x. \<exists>y. G x y) &
       (\<forall>x y. J x y | G x y --> (\<forall>z. J y z | G y z --> H x z))
       --> (\<forall>x. \<exists>y. H x y)"
by blast

text{*Problem 37; has 10 Horn clauses*}
lemma "(\<forall>z. \<exists>w. \<forall>x. \<exists>y.
           (P x z --> P y w) & P y z & (P y w --> (\<exists>u. Q u w))) &
      (\<forall>x z. ~P x z --> (\<exists>y. Q y z)) &
      ((\<exists>x y. Q x y) --> (\<forall>x. R x x))
    --> (\<forall>x. \<exists>y. R x y)"
by blast --{*causes unification tracing messages*}


text{*Problem 38*}  text{*Quite hard: 422 Horn clauses!!*}
lemma "(\<forall>x. p a & (p x --> (\<exists>y. p y & r x y)) -->
           (\<exists>z. \<exists>w. p z & r x w & r w z))  =
      (\<forall>x. (~p a | p x | (\<exists>z. \<exists>w. p z & r x w & r w z)) &
            (~p a | ~(\<exists>y. p y & r x y) |
             (\<exists>z. \<exists>w. p z & r x w & r w z)))"
by blast

text{*Problem 39*}
lemma "~ (\<exists>x. \<forall>y. F y x = (~F y y))"
by blast

text{*Problem 40.  AMENDED*}
lemma "(\<exists>y. \<forall>x. F x y = F x x)
      -->  ~ (\<forall>x. \<exists>y. \<forall>z. F z y = (~F z x))"
by blast

text{*Problem 41*}
lemma "(\<forall>z. (\<exists>y. (\<forall>x. f x y = (f x z & ~ f x x))))
      --> ~ (\<exists>z. \<forall>x. f x z)"
by blast

text{*Problem 42*}
lemma "~ (\<exists>y. \<forall>x. p x y = (~ (\<exists>z. p x z & p z x)))"
by blast

text{*Problem 43  NOW PROVED AUTOMATICALLY!!*}
lemma "(\<forall>x. \<forall>y. q x y = (\<forall>z. p z x = (p z y::bool)))
      --> (\<forall>x. (\<forall>y. q x y = (q y x::bool)))"
by blast

text{*Problem 44: 13 Horn clauses; 7-step proof*}
lemma "(\<forall>x. f x --> (\<exists>y. g y & h x y & (\<exists>y. g y & ~ h x y)))  &
       (\<exists>x. j x & (\<forall>y. g y --> h x y))
       --> (\<exists>x. j x & ~f x)"
by blast

text{*Problem 45; has 27 Horn clauses; 54-step proof*}
lemma "(\<forall>x. f x & (\<forall>y. g y & h x y --> j x y)
            --> (\<forall>y. g y & h x y --> k y)) &
      ~ (\<exists>y. l y & k y) &
      (\<exists>x. f x & (\<forall>y. h x y --> l y)
                & (\<forall>y. g y & h x y --> j x y))
      --> (\<exists>x. f x & ~ (\<exists>y. g y & h x y))"
by blast

text{*Problem 46; has 26 Horn clauses; 21-step proof*}
lemma "(\<forall>x. f x & (\<forall>y. f y & h y x --> g y) --> g x) &
       ((\<exists>x. f x & ~g x) -->
       (\<exists>x. f x & ~g x & (\<forall>y. f y & ~g y --> j x y))) &
       (\<forall>x y. f x & f y & h x y --> ~j y x)
       --> (\<forall>x. f x --> g x)"
by blast

text{*Problem 47.  Schubert's Steamroller.
      26 clauses; 63 Horn clauses.
      87094 inferences so far.  Searching to depth 36*}
lemma "(\<forall>x. wolf x \<longrightarrow> animal x) & (\<exists>x. wolf x) &
       (\<forall>x. fox x \<longrightarrow> animal x) & (\<exists>x. fox x) &
       (\<forall>x. bird x \<longrightarrow> animal x) & (\<exists>x. bird x) &
       (\<forall>x. caterpillar x \<longrightarrow> animal x) & (\<exists>x. caterpillar x) &
       (\<forall>x. snail x \<longrightarrow> animal x) & (\<exists>x. snail x) &
       (\<forall>x. grain x \<longrightarrow> plant x) & (\<exists>x. grain x) &
       (\<forall>x. animal x \<longrightarrow>
             ((\<forall>y. plant y \<longrightarrow> eats x y)  \<or> 
              (\<forall>y. animal y & smaller_than y x &
                    (\<exists>z. plant z & eats y z) \<longrightarrow> eats x y))) &
       (\<forall>x y. bird y & (snail x \<or> caterpillar x) \<longrightarrow> smaller_than x y) &
       (\<forall>x y. bird x & fox y \<longrightarrow> smaller_than x y) &
       (\<forall>x y. fox x & wolf y \<longrightarrow> smaller_than x y) &
       (\<forall>x y. wolf x & (fox y \<or> grain y) \<longrightarrow> ~eats x y) &
       (\<forall>x y. bird x & caterpillar y \<longrightarrow> eats x y) &
       (\<forall>x y. bird x & snail y \<longrightarrow> ~eats x y) &
       (\<forall>x. (caterpillar x \<or> snail x) \<longrightarrow> (\<exists>y. plant y & eats x y))
       \<longrightarrow> (\<exists>x y. animal x & animal y & (\<exists>z. grain z & eats y z & eats x y))"
by (tactic{*Meson.safe_best_meson_tac @{context} 1*})
    --{*Nearly twice as fast as @{text meson},
        which performs iterative deepening rather than best-first search*}

text{*The Los problem. Circulated by John Harrison*}
lemma "(\<forall>x y z. P x y & P y z --> P x z) &
       (\<forall>x y z. Q x y & Q y z --> Q x z) &
       (\<forall>x y. P x y --> P y x) &
       (\<forall>x y. P x y | Q x y)
       --> (\<forall>x y. P x y) | (\<forall>x y. Q x y)"
by meson

text{*A similar example, suggested by Johannes Schumann and
 credited to Pelletier*}
lemma "(\<forall>x y z. P x y --> P y z --> P x z) -->
       (\<forall>x y z. Q x y --> Q y z --> Q x z) -->
       (\<forall>x y. Q x y --> Q y x) -->  (\<forall>x y. P x y | Q x y) -->
       (\<forall>x y. P x y) | (\<forall>x y. Q x y)"
by meson

text{*Problem 50.  What has this to do with equality?*}
lemma "(\<forall>x. P a x | (\<forall>y. P x y)) --> (\<exists>x. \<forall>y. P x y)"
by blast

text{*Problem 54: NOT PROVED*}
lemma "(\<forall>y::'a. \<exists>z. \<forall>x. F x z = (x=y)) -->
      ~ (\<exists>w. \<forall>x. F x w = (\<forall>u. F x u --> (\<exists>y. F y u & ~ (\<exists>z. F z u & F z y))))"
oops 


text{*Problem 55*}

text{*Non-equational version, from Manthey and Bry, CADE-9 (Springer, 1988).
  @{text meson} cannot report who killed Agatha. *}
lemma "lives agatha & lives butler & lives charles &
       (killed agatha agatha | killed butler agatha | killed charles agatha) &
       (\<forall>x y. killed x y --> hates x y & ~richer x y) &
       (\<forall>x. hates agatha x --> ~hates charles x) &
       (hates agatha agatha & hates agatha charles) &
       (\<forall>x. lives x & ~richer x agatha --> hates butler x) &
       (\<forall>x. hates agatha x --> hates butler x) &
       (\<forall>x. ~hates x agatha | ~hates x butler | ~hates x charles) -->
       (\<exists>x. killed x agatha)"
by meson

text{*Problem 57*}
lemma "P (f a b) (f b c) & P (f b c) (f a c) &
      (\<forall>x y z. P x y & P y z --> P x z)    -->   P (f a b) (f a c)"
by blast

text{*Problem 58: Challenge found on info-hol *}
lemma "\<forall>P Q R x. \<exists>v w. \<forall>y z. P x & Q y --> (P v | R w) & (R z --> Q v)"
by blast

text{*Problem 59*}
lemma "(\<forall>x. P x = (~P(f x))) --> (\<exists>x. P x & ~P(f x))"
by blast

text{*Problem 60*}
lemma "\<forall>x. P x (f x) = (\<exists>y. (\<forall>z. P z y --> P z (f x)) & P x y)"
by blast

text{*Problem 62 as corrected in JAR 18 (1997), page 135*}
lemma "(\<forall>x. p a & (p x --> p(f x)) --> p(f(f x)))  =
       (\<forall>x. (~ p a | p x | p(f(f x))) &
            (~ p a | ~ p(f x) | p(f(f x))))"
by blast

text{** Charles Morgan's problems **}

lemma
  assumes a: "\<forall>x y.  T(i x(i y x))"
      and b: "\<forall>x y z. T(i (i x (i y z)) (i (i x y) (i x z)))"
      and c: "\<forall>x y.   T(i (i (n x) (n y)) (i y x))"
      and c': "\<forall>x y.   T(i (i y x) (i (n x) (n y)))"
      and d: "\<forall>x y.   T(i x y) & T x --> T y"
 shows True
proof -
  from a b d have "\<forall>x. T(i x x)" by blast
  from a b c d have "\<forall>x. T(i x (n(n x)))" --{*Problem 66*}
    by metis
  from a b c d have "\<forall>x. T(i (n(n x)) x)" --{*Problem 67*}
    by meson
      --{*4.9s on griffon. 51061 inferences, depth 21 *}
  from a b c' d have "\<forall>x. T(i x (n(n x)))" 
      --{*Problem 68: not proved.  Listed as satisfiable in TPTP (LCL078-1)*}
oops

text{*Problem 71, as found in TPTP (SYN007+1.005)*}
lemma "p1 = (p2 = (p3 = (p4 = (p5 = (p1 = (p2 = (p3 = (p4 = p5))))))))"
by blast

end
