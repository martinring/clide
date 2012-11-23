(*  Title:      HOL/ex/Intuitionistic.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1991  University of Cambridge

Taken from FOL/ex/int.ML
*)

header {* Higher-Order Logic: Intuitionistic predicate calculus problems *}

theory Intuitionistic imports Main begin


(*Metatheorem (for PROPOSITIONAL formulae...):
  P is classically provable iff ~~P is intuitionistically provable.
  Therefore ~P is classically provable iff it is intuitionistically provable.  

Proof: Let Q be the conjuction of the propositions A|~A, one for each atom A
in P.  Now ~~Q is intuitionistically provable because ~~(A|~A) is and because
~~ distributes over &.  If P is provable classically, then clearly Q-->P is
provable intuitionistically, so ~~(Q-->P) is also provable intuitionistically.
The latter is intuitionistically equivalent to ~~Q-->~~P, hence to ~~P, since
~~Q is intuitionistically provable.  Finally, if P is a negation then ~~P is
intuitionstically equivalent to P.  [Andy Pitts] *)

lemma "(~~(P&Q)) = ((~~P) & (~~Q))"
  by iprover

lemma "~~ ((~P --> Q) --> (~P --> ~Q) --> P)"
  by iprover

(* ~~ does NOT distribute over | *)

lemma "(~~(P-->Q))  = (~~P --> ~~Q)"
  by iprover

lemma "(~~~P) = (~P)"
  by iprover

lemma "~~((P --> Q | R)  -->  (P-->Q) | (P-->R))"
  by iprover

lemma "(P=Q) = (Q=P)"
  by iprover

lemma "((P --> (Q | (Q-->R))) --> R) --> R"
  by iprover

lemma "(((G-->A) --> J) --> D --> E) --> (((H-->B)-->I)-->C-->J)
      --> (A-->H) --> F --> G --> (((C-->B)-->I)-->D)-->(A-->C)
      --> (((F-->A)-->B) --> I) --> E"
  by iprover


(* Lemmas for the propositional double-negation translation *)

lemma "P --> ~~P"
  by iprover

lemma "~~(~~P --> P)"
  by iprover

lemma "~~P & ~~(P --> Q) --> ~~Q"
  by iprover


(* de Bruijn formulae *)

(*de Bruijn formula with three predicates*)
lemma "((P=Q) --> P&Q&R) &
       ((Q=R) --> P&Q&R) &
       ((R=P) --> P&Q&R) --> P&Q&R"
  by iprover

(*de Bruijn formula with five predicates*)
lemma "((P=Q) --> P&Q&R&S&T) &
       ((Q=R) --> P&Q&R&S&T) &
       ((R=S) --> P&Q&R&S&T) &
       ((S=T) --> P&Q&R&S&T) &
       ((T=P) --> P&Q&R&S&T) --> P&Q&R&S&T"
  by iprover


(*** Problems from Sahlin, Franzen and Haridi, 
     An Intuitionistic Predicate Logic Theorem Prover.
     J. Logic and Comp. 2 (5), October 1992, 619-656.
***)

(*Problem 1.1*)
lemma "(ALL x. EX y. ALL z. p(x) & q(y) & r(z)) =
       (ALL z. EX y. ALL x. p(x) & q(y) & r(z))"
  by (iprover del: allE elim 2: allE')

(*Problem 3.1*)
lemma "~ (EX x. ALL y. p y x = (~ p x x))"
  by iprover


(* Intuitionistic FOL: propositional problems based on Pelletier. *)

(* Problem ~~1 *)
lemma "~~((P-->Q)  =  (~Q --> ~P))"
  by iprover

(* Problem ~~2 *)
lemma "~~(~~P  =  P)"
  by iprover

(* Problem 3 *)
lemma "~(P-->Q) --> (Q-->P)"
  by iprover

(* Problem ~~4 *)
lemma "~~((~P-->Q)  =  (~Q --> P))"
  by iprover

(* Problem ~~5 *)
lemma "~~((P|Q-->P|R) --> P|(Q-->R))"
  by iprover

(* Problem ~~6 *)
lemma "~~(P | ~P)"
  by iprover

(* Problem ~~7 *)
lemma "~~(P | ~~~P)"
  by iprover

(* Problem ~~8.  Peirce's law *)
lemma "~~(((P-->Q) --> P)  -->  P)"
  by iprover

(* Problem 9 *)
lemma "((P|Q) & (~P|Q) & (P| ~Q)) --> ~ (~P | ~Q)"
  by iprover

(* Problem 10 *)
lemma "(Q-->R) --> (R-->P&Q) --> (P-->(Q|R)) --> (P=Q)"
  by iprover

(* 11.  Proved in each direction (incorrectly, says Pelletier!!) *)
lemma "P=P"
  by iprover

(* Problem ~~12.  Dijkstra's law *)
lemma "~~(((P = Q) = R)  =  (P = (Q = R)))"
  by iprover

lemma "((P = Q) = R)  -->  ~~(P = (Q = R))"
  by iprover

(* Problem 13.  Distributive law *)
lemma "(P | (Q & R))  = ((P | Q) & (P | R))"
  by iprover

(* Problem ~~14 *)
lemma "~~((P = Q) = ((Q | ~P) & (~Q|P)))"
  by iprover

(* Problem ~~15 *)
lemma "~~((P --> Q) = (~P | Q))"
  by iprover

(* Problem ~~16 *)
lemma "~~((P-->Q) | (Q-->P))"
by iprover

(* Problem ~~17 *)
lemma "~~(((P & (Q-->R))-->S) = ((~P | Q | S) & (~P | ~R | S)))"
  oops

(*Dijkstra's "Golden Rule"*)
lemma "(P&Q) = (P = (Q = (P|Q)))"
  by iprover


(****Examples with quantifiers****)

(* The converse is classical in the following implications... *)

lemma "(EX x. P(x)-->Q)  -->  (ALL x. P(x)) --> Q"
  by iprover

lemma "((ALL x. P(x))-->Q) --> ~ (ALL x. P(x) & ~Q)"
  by iprover

lemma "((ALL x. ~P(x))-->Q)  -->  ~ (ALL x. ~ (P(x)|Q))"
  by iprover

lemma "(ALL x. P(x)) | Q  -->  (ALL x. P(x) | Q)"
  by iprover 

lemma "(EX x. P --> Q(x)) --> (P --> (EX x. Q(x)))"
  by iprover


(* Hard examples with quantifiers *)

(*The ones that have not been proved are not known to be valid!
  Some will require quantifier duplication -- not currently available*)

(* Problem ~~19 *)
lemma "~~(EX x. ALL y z. (P(y)-->Q(z)) --> (P(x)-->Q(x)))"
  by iprover

(* Problem 20 *)
lemma "(ALL x y. EX z. ALL w. (P(x)&Q(y)-->R(z)&S(w)))
    --> (EX x y. P(x) & Q(y)) --> (EX z. R(z))"
  by iprover

(* Problem 21 *)
lemma "(EX x. P-->Q(x)) & (EX x. Q(x)-->P) --> ~~(EX x. P=Q(x))"
  by iprover

(* Problem 22 *)
lemma "(ALL x. P = Q(x))  -->  (P = (ALL x. Q(x)))"
  by iprover

(* Problem ~~23 *)
lemma "~~ ((ALL x. P | Q(x))  =  (P | (ALL x. Q(x))))"
  by iprover

(* Problem 25 *)
lemma "(EX x. P(x)) &
       (ALL x. L(x) --> ~ (M(x) & R(x))) &
       (ALL x. P(x) --> (M(x) & L(x))) &
       ((ALL x. P(x)-->Q(x)) | (EX x. P(x)&R(x)))
   --> (EX x. Q(x)&P(x))"
  by iprover

(* Problem 27 *)
lemma "(EX x. P(x) & ~Q(x)) &
             (ALL x. P(x) --> R(x)) &
             (ALL x. M(x) & L(x) --> P(x)) &
             ((EX x. R(x) & ~ Q(x)) --> (ALL x. L(x) --> ~ R(x)))
         --> (ALL x. M(x) --> ~L(x))"
  by iprover

(* Problem ~~28.  AMENDED *)
lemma "(ALL x. P(x) --> (ALL x. Q(x))) &
       (~~(ALL x. Q(x)|R(x)) --> (EX x. Q(x)&S(x))) &
       (~~(EX x. S(x)) --> (ALL x. L(x) --> M(x)))
   --> (ALL x. P(x) & L(x) --> M(x))"
  by iprover

(* Problem 29.  Essentially the same as Principia Mathematica *11.71 *)
lemma "(((EX x. P(x)) & (EX y. Q(y))) -->
   (((ALL x. (P(x) --> R(x))) & (ALL y. (Q(y) --> S(y)))) =
    (ALL x y. ((P(x) & Q(y)) --> (R(x) & S(y))))))"
  by iprover

(* Problem ~~30 *)
lemma "(ALL x. (P(x) | Q(x)) --> ~ R(x)) &
       (ALL x. (Q(x) --> ~ S(x)) --> P(x) & R(x))
   --> (ALL x. ~~S(x))"
  by iprover

(* Problem 31 *)
lemma "~(EX x. P(x) & (Q(x) | R(x))) & 
        (EX x. L(x) & P(x)) &
        (ALL x. ~ R(x) --> M(x))
    --> (EX x. L(x) & M(x))"
  by iprover

(* Problem 32 *)
lemma "(ALL x. P(x) & (Q(x)|R(x))-->S(x)) &
       (ALL x. S(x) & R(x) --> L(x)) &
       (ALL x. M(x) --> R(x))
   --> (ALL x. P(x) & M(x) --> L(x))"
  by iprover

(* Problem ~~33 *)
lemma "(ALL x. ~~(P(a) & (P(x)-->P(b))-->P(c)))  =
       (ALL x. ~~((~P(a) | P(x) | P(c)) & (~P(a) | ~P(b) | P(c))))"
  oops

(* Problem 36 *)
lemma
     "(ALL x. EX y. J x y) &
      (ALL x. EX y. G x y) &
      (ALL x y. J x y | G x y --> (ALL z. J y z | G y z --> H x z))
  --> (ALL x. EX y. H x y)"
  by iprover

(* Problem 39 *)
lemma "~ (EX x. ALL y. F y x = (~F y y))"
  by iprover

(* Problem 40.  AMENDED *)
lemma "(EX y. ALL x. F x y = F x x) -->
             ~(ALL x. EX y. ALL z. F z y = (~ F z x))"
  by iprover

(* Problem 44 *)
lemma "(ALL x. f(x) -->
             (EX y. g(y) & h x y & (EX y. g(y) & ~ h x y)))  &
             (EX x. j(x) & (ALL y. g(y) --> h x y))
             --> (EX x. j(x) & ~f(x))"
  by iprover

(* Problem 48 *)
lemma "(a=b | c=d) & (a=c | b=d) --> a=d | b=c"
  by iprover

(* Problem 51 *)
lemma "((EX z w. (ALL x y. (P x y = ((x = z) & (y = w))))) -->
  (EX z. (ALL x. (EX w. ((ALL y. (P x y = (y = w))) = (x = z))))))"
  by iprover

(* Problem 52 *)
(*Almost the same as 51. *)
lemma "((EX z w. (ALL x y. (P x y = ((x = z) & (y = w))))) -->
   (EX w. (ALL y. (EX z. ((ALL x. (P x y = (x = z))) = (y = w))))))"
  by iprover

(* Problem 56 *)
lemma "(ALL x. (EX y. P(y) & x=f(y)) --> P(x)) = (ALL x. P(x) --> P(f(x)))"
  by iprover

(* Problem 57 *)
lemma "P (f a b) (f b c) & P (f b c) (f a c) &
     (ALL x y z. P x y & P y z --> P x z) --> P (f a b) (f a c)"
  by iprover

(* Problem 60 *)
lemma "ALL x. P x (f x) = (EX y. (ALL z. P z y --> P z (f x)) & P x y)"
  by iprover

end
