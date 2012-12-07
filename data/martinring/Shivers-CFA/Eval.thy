header "Standard semantics"

theory Eval
  imports HOLCF HOLCFUtils CPSScheme
begin

text {*
We begin by giving the standard semantics for our language. Although this is not actually used to show any results, it is helpful to see that the later algorithms ``look similar'' to the evaluation code and the relation between calls done during evaluation and calls recorded by the control flow graph.
*}

text {*
We follow the definition in Figure 3.1 and 3.2 of Shivers' dissertation, with the clarifications from Section 4.1. As explained previously, our set of values encompasses just the integers, there is no separate value for \textit{false}. Also, values and procedures are not distinguished by the type system.

Due to recursion, one variable can have more than one currently valid binding, and due to closures all bindings can possibly be accessed. A simple call stack is therefore not sufficient. Instead we have a \textit{contour counter}, which is increased in each evaluation step. It can also be thought of as a time counter. The variable environment maps tuples of variables and contour counter to values, thus allowing a variable to have more than one active binding.  A contour environment lists the currently visible binding for each binding position and is preserved when a lambda expression is turned into a closure.
*}

type_synonym contour = nat
type_synonym benv = "label \<rightharpoonup> contour"
type_synonym closure = "lambda \<times> benv"

text {*
The set of semantic values consist of the integers, closures, primitive operations and a special value @{text Stop}. This is passed as an argument to the program and represents the terminal continuation. When this value occurs in the first position of a call, the program terminates.
*}

datatype d = DI int
           | DC closure
           | DP prim
           | Stop

type_synonym venv = "var \<times> contour \<rightharpoonup> d"

text {*
The function @{text \<A>} evaluates a syntactic value into a semantic datum. Constants and primitive operations are left untouched. Variable references are resolved in two stages: First the current binding contour is fetched from the binding environment @{text \<beta>}, then the stored value is fetched from the variable environment @{text ve}. A lambda expression is bundled with the current contour environment to form a closure.
*}

fun evalV :: "val \<Rightarrow> benv \<Rightarrow> venv \<Rightarrow> d" ("\<A>")
  where "\<A> (C _ i) \<beta> ve = DI i"
  |     "\<A> (P prim) \<beta> ve = DP prim"
  |     "\<A> (R _ var) \<beta> ve =
           (case \<beta> (binder var) of
              Some l \<Rightarrow> (case ve (var,l) of Some d \<Rightarrow> d))"
  |     "\<A> (L lam) \<beta> ve = DC (lam, \<beta>)"


text {*
The answer domain of our semantics is the set of integers, lifted to obtain an additional element denoting bottom. Shivers distinguishes runtime errors from non-termination. Here, both are represented by @{text \<bottom>}.
*}

type_synonym ans = "int lift"

text {*
To be able to do case analysis on the custom datatypes @{text lambda}, @{text d}, @{text call} and @{text prim} inside a function defined with @{text fixrec}, we need continuity results for them. These are all of the same shape and proven by case analysis on the discriminator.
*}

lemma cont2cont_lambda_case [simp, cont2cont]:
  assumes "\<And>a b c. cont (\<lambda>x. f x a b c)"
  shows "cont (\<lambda>x. lambda_case (f x) l)"
using assms
by (cases l) auto

lemma cont2cont_d_case [simp, cont2cont]:
  assumes "\<And>y. cont (\<lambda>x. f1 x y)"
     and  "\<And>y. cont (\<lambda>x. f2 x y)"
     and  "\<And>y. cont (\<lambda>x. f3 x y)"
    and   "cont (\<lambda>x. f4 x)"
  shows "cont (\<lambda>x. d_case (f1 x) (f2 x) (f3 x) (f4 x) d)"
using assms
by (cases d) auto

value call_case
lemma cont2cont_call_case [simp, cont2cont]:
  assumes "\<And>a b c. cont (\<lambda>x. f1 x a b c)"
     and  "\<And>a b c. cont (\<lambda>x. f2 x a b c)"
  shows "cont (\<lambda>x. call_case (f1 x) (f2 x) c)"
using assms
by (cases c) auto

lemma cont2cont_prim_case [simp, cont2cont]:
  assumes "\<And>y. cont (\<lambda>x. f1 x y)"
     and  "\<And>y z. cont (\<lambda>x. f2 x y z)"
  shows "cont (\<lambda>x. prim_case (f1 x) (f2 x) p)"
using assms
by (cases p) auto

text {*
As usual, the semantics of a functional language is given as a denotational semantics. To that end, two functions are defined here: @{text \<F>} applies a procedure to a list of arguments. Here closures are unwrapped, the primitive operations are implemented and the terminal continuation @{text Stop} is handled. @{text \<C>} evaluates a call expression, either by evaluating procedure and arguments and passing them to @{text \<F>}, or by adding the bindings of a @{text Let} expression to the environment.

Note how the contour counter is incremented before each call to @{text \<F>} or when a @{text Let} expression is evaluated.

With mutually recursive equations, such as those given here, the existence of a function satisfying these is not obvious. Therefore, the @{text fixrec} command from the @{theory HOLCF} package is used. This takes a set of equations and builds a functional from that. It mechanically proofs that this functional is continuous and thus a least fixed point exists. This is then used to define @{text \<F>} and @{text \<C>} and proof the equations given here. To use the @{theory HOLCF} setup, the continuous function arrow @{text \<rightarrow>} with application operator @{text \<cdot>} is used and our types are wrapped in @{text discr} and @{text lift} to indicate which partial order is to be used.
*}

type_synonym fstate = "(d \<times> d list \<times> venv \<times> contour)"
type_synonym cstate = "(call \<times> benv \<times> venv \<times> contour)"


fixrec   evalF :: "fstate discr \<rightarrow> ans" ("\<F>")
     and evalC :: "cstate discr \<rightarrow> ans" ("\<C>")
  where "evalF\<cdot>fstate = (case undiscr fstate of
             (DC (Lambda lab vs c, \<beta>), as, ve, b) \<Rightarrow>
               (if length vs = length as
                then let \<beta>' = \<beta> (lab \<mapsto> b);
                         ve' = map_upds ve (map (\<lambda>v.(v,b)) vs) as
                     in \<C>\<cdot>(Discr (c,\<beta>',ve',b))
                else \<bottom>)
            | (DP (Plus c),[DI a1, DI a2, cnt],ve,b) \<Rightarrow>
                     let b' = Suc b;
                         \<beta>  = [c \<mapsto> b]
                     in \<F>\<cdot>(Discr (cnt,[DI (a1 + a2)],ve,b'))
            | (DP (prim.If ct cf),[DI v, contt, contf],ve,b) \<Rightarrow>
                  (if v \<noteq> 0
                   then let b' = Suc b;
                            \<beta> = [ct \<mapsto> b]
                        in \<F>\<cdot>(Discr (contt,[],ve,b'))
                   else let b' = Suc b;
                            \<beta> = [cf \<mapsto> b]
                        in \<F>\<cdot>(Discr (contf,[],ve,b')))
            | (Stop,[DI i],_,_) \<Rightarrow> Def i
            | _ \<Rightarrow> \<bottom>
        )"
      | "\<C>\<cdot>cstate = (case undiscr cstate of
             (App lab f vs,\<beta>,ve,b) \<Rightarrow>
                 let f' = \<A> f \<beta> ve;
                     as = map (\<lambda>v. \<A> v \<beta> ve) vs;
                     b' = Suc b
                  in \<F>\<cdot>(Discr (f',as,ve,b'))
            | (Let lab ls c',\<beta>,ve,b) \<Rightarrow>
                 let b' = Suc b;
                     \<beta>' = \<beta> (lab \<mapsto> b');
                    ve' = ve ++ map_of (map (\<lambda>(v,l). ((v,b'), \<A> (L l) \<beta>' ve)) ls)
                 in \<C>\<cdot>(Discr (c',\<beta>',ve',b'))
        )"

text {* 
To evaluate a full program, it is passed to @{text \<F>} with proper initializations of the other arguments. We test our semantics function against two example programs and observe that the expected value is returned. 
*}

definition evalCPS :: "prog \<Rightarrow> ans" ("\<PR>")
  where "\<PR> l = (let ve = empty;
                          \<beta> = empty;
                          f = \<A> (L l) \<beta> ve
                      in  \<F>\<cdot>(Discr (f,[Stop],ve,0)))"

lemma correct_ex1: "\<PR> ex1 = Def 0"
unfolding evalCPS_def
by simp

lemma correct_ex2: "\<PR> ex2 = Def 2"
unfolding evalCPS_def
by simp

(* (The third example takes long to finish, thus is it not ran by default.) 
lemma correct_ex3: "evalCPS ex3 = Def 55"
oops
unfolding evalCPS_def
by simp
*)

end
