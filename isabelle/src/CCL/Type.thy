(*  Title:      CCL/Type.thy
    Author:     Martin Coen
    Copyright   1993  University of Cambridge
*)

header {* Types in CCL are defined as sets of terms *}

theory Type
imports Term
begin

consts

  Subtype       :: "['a set, 'a => o] => 'a set"
  Bool          :: "i set"
  Unit          :: "i set"
  Plus           :: "[i set, i set] => i set"        (infixr "+" 55)
  Pi            :: "[i set, i => i set] => i set"
  Sigma         :: "[i set, i => i set] => i set"
  Nat           :: "i set"
  List          :: "i set => i set"
  Lists         :: "i set => i set"
  ILists        :: "i set => i set"
  TAll          :: "(i set => i set) => i set"       (binder "TALL " 55)
  TEx           :: "(i set => i set) => i set"       (binder "TEX " 55)
  Lift          :: "i set => i set"                  ("(3[_])")

  SPLIT         :: "[i, [i, i] => i set] => i set"

syntax
  "_Pi"         :: "[idt, i set, i set] => i set"    ("(3PROD _:_./ _)"
                                [0,0,60] 60)

  "_Sigma"      :: "[idt, i set, i set] => i set"    ("(3SUM _:_./ _)"
                                [0,0,60] 60)

  "_arrow"      :: "[i set, i set] => i set"         ("(_ ->/ _)"  [54, 53] 53)
  "_star"       :: "[i set, i set] => i set"         ("(_ */ _)" [56, 55] 55)
  "_Subtype"    :: "[idt, 'a set, o] => 'a set"      ("(1{_: _ ./ _})")

translations
  "PROD x:A. B" => "CONST Pi(A, %x. B)"
  "A -> B"      => "CONST Pi(A, %_. B)"
  "SUM x:A. B"  => "CONST Sigma(A, %x. B)"
  "A * B"       => "CONST Sigma(A, %_. B)"
  "{x: A. B}"   == "CONST Subtype(A, %x. B)"

print_translation {*
 [(@{const_syntax Pi},
    Syntax_Trans.dependent_tr' (@{syntax_const "_Pi"}, @{syntax_const "_arrow"})),
  (@{const_syntax Sigma},
    Syntax_Trans.dependent_tr' (@{syntax_const "_Sigma"}, @{syntax_const "_star"}))]
*}

defs
  Subtype_def: "{x:A. P(x)} == {x. x:A & P(x)}"
  Unit_def:          "Unit == {x. x=one}"
  Bool_def:          "Bool == {x. x=true | x=false}"
  Plus_def:           "A+B == {x. (EX a:A. x=inl(a)) | (EX b:B. x=inr(b))}"
  Pi_def:         "Pi(A,B) == {x. EX b. x=lam x. b(x) & (ALL x:A. b(x):B(x))}"
  Sigma_def:   "Sigma(A,B) == {x. EX a:A. EX b:B(a).x=<a,b>}"
  Nat_def:            "Nat == lfp(% X. Unit + X)"
  List_def:       "List(A) == lfp(% X. Unit + A*X)"

  Lists_def:     "Lists(A) == gfp(% X. Unit + A*X)"
  ILists_def:   "ILists(A) == gfp(% X.{} + A*X)"

  Tall_def:   "TALL X. B(X) == Inter({X. EX Y. X=B(Y)})"
  Tex_def:     "TEX X. B(X) == Union({X. EX Y. X=B(Y)})"
  Lift_def:           "[A] == A Un {bot}"

  SPLIT_def:   "SPLIT(p,B) == Union({A. EX x y. p=<x,y> & A=B(x,y)})"


lemmas simp_type_defs =
    Subtype_def Unit_def Bool_def Plus_def Sigma_def Pi_def Lift_def Tall_def Tex_def
  and ind_type_defs = Nat_def List_def
  and simp_data_defs = one_def inl_def inr_def
  and ind_data_defs = zero_def succ_def nil_def cons_def

lemma subsetXH: "A <= B <-> (ALL x. x:A --> x:B)"
  by blast


subsection {* Exhaustion Rules *}

lemma EmptyXH: "!!a. a : {} <-> False"
  and SubtypeXH: "!!a A P. a : {x:A. P(x)} <-> (a:A & P(a))"
  and UnitXH: "!!a. a : Unit          <-> a=one"
  and BoolXH: "!!a. a : Bool          <-> a=true | a=false"
  and PlusXH: "!!a A B. a : A+B           <-> (EX x:A. a=inl(x)) | (EX x:B. a=inr(x))"
  and PiXH: "!!a A B. a : PROD x:A. B(x) <-> (EX b. a=lam x. b(x) & (ALL x:A. b(x):B(x)))"
  and SgXH: "!!a A B. a : SUM x:A. B(x)  <-> (EX x:A. EX y:B(x).a=<x,y>)"
  unfolding simp_type_defs by blast+

lemmas XHs = EmptyXH SubtypeXH UnitXH BoolXH PlusXH PiXH SgXH

lemma LiftXH: "a : [A] <-> (a=bot | a:A)"
  and TallXH: "a : TALL X. B(X) <-> (ALL X. a:B(X))"
  and TexXH: "a : TEX X. B(X) <-> (EX X. a:B(X))"
  unfolding simp_type_defs by blast+

ML {*
bind_thms ("case_rls", XH_to_Es @{thms XHs});
*}


subsection {* Canonical Type Rules *}

lemma oneT: "one : Unit"
  and trueT: "true : Bool"
  and falseT: "false : Bool"
  and lamT: "!!b B. [| !!x. x:A ==> b(x):B(x) |] ==> lam x. b(x) : Pi(A,B)"
  and pairT: "!!b B. [| a:A; b:B(a) |] ==> <a,b>:Sigma(A,B)"
  and inlT: "a:A ==> inl(a) : A+B"
  and inrT: "b:B ==> inr(b) : A+B"
  by (blast intro: XHs [THEN iffD2])+

lemmas canTs = oneT trueT falseT pairT lamT inlT inrT


subsection {* Non-Canonical Type Rules *}

lemma lem: "[| a:B(u);  u=v |] ==> a : B(v)"
  by blast


ML {*
fun mk_ncanT_tac top_crls crls =
  SUBPROOF (fn {context = ctxt, prems = major :: prems, ...} =>
    resolve_tac ([major] RL top_crls) 1 THEN
    REPEAT_SOME (eresolve_tac (crls @ [@{thm exE}, @{thm bexE}, @{thm conjE}, @{thm disjE}])) THEN
    ALLGOALS (asm_simp_tac (simpset_of ctxt)) THEN
    ALLGOALS (ares_tac (prems RL [@{thm lem}]) ORELSE' etac @{thm bspec}) THEN
    safe_tac (ctxt addSIs prems))
*}

method_setup ncanT = {*
  Scan.succeed (SIMPLE_METHOD' o mk_ncanT_tac @{thms case_rls} @{thms case_rls})
*}

lemma ifT:
  "[| b:Bool; b=true ==> t:A(true); b=false ==> u:A(false) |] ==>
    if b then t else u : A(b)"
  by ncanT

lemma applyT: "[| f : Pi(A,B);  a:A |] ==> f ` a : B(a)"
  by ncanT

lemma splitT:
  "[| p:Sigma(A,B); !!x y. [| x:A;  y:B(x); p=<x,y> |] ==> c(x,y):C(<x,y>) |]
    ==> split(p,c):C(p)"
  by ncanT

lemma whenT:
  "[| p:A+B; !!x.[| x:A;  p=inl(x) |] ==> a(x):C(inl(x)); !!y.[| y:B;  p=inr(y) |]
    ==> b(y):C(inr(y)) |] ==> when(p,a,b) : C(p)"
  by ncanT

lemmas ncanTs = ifT applyT splitT whenT


subsection {* Subtypes *}

lemma SubtypeD1: "a : Subtype(A, P) ==> a : A"
  and SubtypeD2: "a : Subtype(A, P) ==> P(a)"
  by (simp_all add: SubtypeXH)

lemma SubtypeI: "[| a:A;  P(a) |] ==> a : {x:A. P(x)}"
  by (simp add: SubtypeXH)

lemma SubtypeE: "[| a : {x:A. P(x)};  [| a:A;  P(a) |] ==> Q |] ==> Q"
  by (simp add: SubtypeXH)


subsection {* Monotonicity *}

lemma idM: "mono (%X. X)"
  apply (rule monoI)
  apply assumption
  done

lemma constM: "mono(%X. A)"
  apply (rule monoI)
  apply (rule subset_refl)
  done

lemma "mono(%X. A(X)) ==> mono(%X.[A(X)])"
  apply (rule subsetI [THEN monoI])
  apply (drule LiftXH [THEN iffD1])
  apply (erule disjE)
   apply (erule disjI1 [THEN LiftXH [THEN iffD2]])
  apply (rule disjI2 [THEN LiftXH [THEN iffD2]])
  apply (drule (1) monoD)
  apply blast
  done

lemma SgM:
  "[| mono(%X. A(X)); !!x X. x:A(X) ==> mono(%X. B(X,x)) |] ==>
    mono(%X. Sigma(A(X),B(X)))"
  by (blast intro!: subsetI [THEN monoI] canTs elim!: case_rls
    dest!: monoD [THEN subsetD])

lemma PiM:
  "[| !!x. x:A ==> mono(%X. B(X,x)) |] ==> mono(%X. Pi(A,B(X)))"
  by (blast intro!: subsetI [THEN monoI] canTs elim!: case_rls
    dest!: monoD [THEN subsetD])

lemma PlusM:
    "[| mono(%X. A(X));  mono(%X. B(X)) |] ==> mono(%X. A(X)+B(X))"
  by (blast intro!: subsetI [THEN monoI] canTs elim!: case_rls
    dest!: monoD [THEN subsetD])


subsection {* Recursive types *}

subsubsection {* Conversion Rules for Fixed Points via monotonicity and Tarski *}

lemma NatM: "mono(%X. Unit+X)"
  apply (rule PlusM constM idM)+
  done

lemma def_NatB: "Nat = Unit + Nat"
  apply (rule def_lfp_Tarski [OF Nat_def])
  apply (rule NatM)
  done

lemma ListM: "mono(%X.(Unit+Sigma(A,%y. X)))"
  apply (rule PlusM SgM constM idM)+
  done

lemma def_ListB: "List(A) = Unit + A * List(A)"
  apply (rule def_lfp_Tarski [OF List_def])
  apply (rule ListM)
  done

lemma def_ListsB: "Lists(A) = Unit + A * Lists(A)"
  apply (rule def_gfp_Tarski [OF Lists_def])
  apply (rule ListM)
  done

lemma IListsM: "mono(%X.({} + Sigma(A,%y. X)))"
  apply (rule PlusM SgM constM idM)+
  done

lemma def_IListsB: "ILists(A) = {} + A * ILists(A)"
  apply (rule def_gfp_Tarski [OF ILists_def])
  apply (rule IListsM)
  done

lemmas ind_type_eqs = def_NatB def_ListB def_ListsB def_IListsB


subsection {* Exhaustion Rules *}

lemma NatXH: "a : Nat <-> (a=zero | (EX x:Nat. a=succ(x)))"
  and ListXH: "a : List(A) <-> (a=[] | (EX x:A. EX xs:List(A).a=x$xs))"
  and ListsXH: "a : Lists(A) <-> (a=[] | (EX x:A. EX xs:Lists(A).a=x$xs))"
  and IListsXH: "a : ILists(A) <-> (EX x:A. EX xs:ILists(A).a=x$xs)"
  unfolding ind_data_defs
  by (rule ind_type_eqs [THEN XHlemma1], blast intro!: canTs elim!: case_rls)+

lemmas iXHs = NatXH ListXH

ML {* bind_thms ("icase_rls", XH_to_Es @{thms iXHs}) *}


subsection {* Type Rules *}

lemma zeroT: "zero : Nat"
  and succT: "n:Nat ==> succ(n) : Nat"
  and nilT: "[] : List(A)"
  and consT: "[| h:A;  t:List(A) |] ==> h$t : List(A)"
  by (blast intro: iXHs [THEN iffD2])+

lemmas icanTs = zeroT succT nilT consT


method_setup incanT = {*
  Scan.succeed (SIMPLE_METHOD' o mk_ncanT_tac @{thms icase_rls} @{thms case_rls})
*}

lemma ncaseT:
  "[| n:Nat; n=zero ==> b:C(zero); !!x.[| x:Nat;  n=succ(x) |] ==> c(x):C(succ(x)) |]
    ==> ncase(n,b,c) : C(n)"
  by incanT

lemma lcaseT:
  "[| l:List(A); l=[] ==> b:C([]); !!h t.[| h:A;  t:List(A); l=h$t |] ==>
    c(h,t):C(h$t) |] ==> lcase(l,b,c) : C(l)"
  by incanT

lemmas incanTs = ncaseT lcaseT


subsection {* Induction Rules *}

lemmas ind_Ms = NatM ListM

lemma Nat_ind: "[| n:Nat; P(zero); !!x.[| x:Nat; P(x) |] ==> P(succ(x)) |] ==> P(n)"
  apply (unfold ind_data_defs)
  apply (erule def_induct [OF Nat_def _ NatM])
  apply (blast intro: canTs elim!: case_rls)
  done

lemma List_ind:
  "[| l:List(A); P([]); !!x xs.[| x:A;  xs:List(A); P(xs) |] ==> P(x$xs) |] ==> P(l)"
  apply (unfold ind_data_defs)
  apply (erule def_induct [OF List_def _ ListM])
  apply (blast intro: canTs elim!: case_rls)
  done

lemmas inds = Nat_ind List_ind


subsection {* Primitive Recursive Rules *}

lemma nrecT:
  "[| n:Nat; b:C(zero);
      !!x g.[| x:Nat; g:C(x) |] ==> c(x,g):C(succ(x)) |] ==>
      nrec(n,b,c) : C(n)"
  by (erule Nat_ind) auto

lemma lrecT:
  "[| l:List(A); b:C([]);
      !!x xs g.[| x:A;  xs:List(A); g:C(xs) |] ==> c(x,xs,g):C(x$xs) |] ==>
      lrec(l,b,c) : C(l)"
  by (erule List_ind) auto

lemmas precTs = nrecT lrecT


subsection {* Theorem proving *}

lemma SgE2:
  "[| <a,b> : Sigma(A,B);  [| a:A;  b:B(a) |] ==> P |] ==> P"
  unfolding SgXH by blast

(* General theorem proving ignores non-canonical term-formers,             *)
(*         - intro rules are type rules for canonical terms                *)
(*         - elim rules are case rules (no non-canonical terms appear)     *)

ML {* bind_thms ("XHEs", XH_to_Es @{thms XHs}) *}

lemmas [intro!] = SubtypeI canTs icanTs
  and [elim!] = SubtypeE XHEs


subsection {* Infinite Data Types *}

lemma lfp_subset_gfp: "mono(f) ==> lfp(f) <= gfp(f)"
  apply (rule lfp_lowerbound [THEN subset_trans])
   apply (erule gfp_lemma3)
  apply (rule subset_refl)
  done

lemma gfpI:
  assumes "a:A"
    and "!!x X.[| x:A;  ALL y:A. t(y):X |] ==> t(x) : B(X)"
  shows "t(a) : gfp(B)"
  apply (rule coinduct)
   apply (rule_tac P = "%x. EX y:A. x=t (y)" in CollectI)
   apply (blast intro!: assms)+
  done

lemma def_gfpI:
  "[| C==gfp(B);  a:A;  !!x X.[| x:A;  ALL y:A. t(y):X |] ==> t(x) : B(X) |] ==>
    t(a) : C"
  apply unfold
  apply (erule gfpI)
  apply blast
  done

(* EG *)
lemma "letrec g x be zero$g(x) in g(bot) : Lists(Nat)"
  apply (rule refl [THEN UnitXH [THEN iffD2], THEN Lists_def [THEN def_gfpI]])
  apply (subst letrecB)
  apply (unfold cons_def)
  apply blast
  done


subsection {* Lemmas and tactics for using the rule @{text
  "coinduct3"} on @{text "[="} and @{text "="} *}

lemma lfpI: "[| mono(f);  a : f(lfp(f)) |] ==> a : lfp(f)"
  apply (erule lfp_Tarski [THEN ssubst])
  apply assumption
  done

lemma ssubst_single: "[| a=a';  a' : A |] ==> a : A"
  by simp

lemma ssubst_pair: "[| a=a';  b=b';  <a',b'> : A |] ==> <a,b> : A"
  by simp


ML {*
  val coinduct3_tac = SUBPROOF (fn {context = ctxt, prems = mono :: prems, ...} =>
    fast_tac (ctxt addIs (mono RS @{thm coinduct3_mono_lemma} RS @{thm lfpI}) :: prems) 1);
*}

method_setup coinduct3 = {* Scan.succeed (SIMPLE_METHOD' o coinduct3_tac) *}

lemma ci3_RI: "[| mono(Agen);  a : R |] ==> a : lfp(%x. Agen(x) Un R Un A)"
  by coinduct3

lemma ci3_AgenI: "[| mono(Agen);  a : Agen(lfp(%x. Agen(x) Un R Un A)) |] ==>
    a : lfp(%x. Agen(x) Un R Un A)"
  by coinduct3

lemma ci3_AI: "[| mono(Agen);  a : A |] ==> a : lfp(%x. Agen(x) Un R Un A)"
  by coinduct3

ML {*
fun genIs_tac ctxt genXH gen_mono =
  rtac (genXH RS @{thm iffD2}) THEN'
  simp_tac (simpset_of ctxt) THEN'
  TRY o fast_tac
    (ctxt addIs [genXH RS @{thm iffD2}, gen_mono RS @{thm coinduct3_mono_lemma} RS @{thm lfpI}])
*}

method_setup genIs = {*
  Attrib.thm -- Attrib.thm >>
    (fn (genXH, gen_mono) => fn ctxt => SIMPLE_METHOD' (genIs_tac ctxt genXH gen_mono))
*}


subsection {* POgen *}

lemma PO_refl: "<a,a> : PO"
  by (rule po_refl [THEN PO_iff [THEN iffD1]])

lemma POgenIs:
  "<true,true> : POgen(R)"
  "<false,false> : POgen(R)"
  "[| <a,a'> : R;  <b,b'> : R |] ==> <<a,b>,<a',b'>> : POgen(R)"
  "!!b b'. [|!!x. <b(x),b'(x)> : R |] ==><lam x. b(x),lam x. b'(x)> : POgen(R)"
  "<one,one> : POgen(R)"
  "<a,a'> : lfp(%x. POgen(x) Un R Un PO) ==>
    <inl(a),inl(a')> : POgen(lfp(%x. POgen(x) Un R Un PO))"
  "<b,b'> : lfp(%x. POgen(x) Un R Un PO) ==>
    <inr(b),inr(b')> : POgen(lfp(%x. POgen(x) Un R Un PO))"
  "<zero,zero> : POgen(lfp(%x. POgen(x) Un R Un PO))"
  "<n,n'> : lfp(%x. POgen(x) Un R Un PO) ==>
    <succ(n),succ(n')> : POgen(lfp(%x. POgen(x) Un R Un PO))"
  "<[],[]> : POgen(lfp(%x. POgen(x) Un R Un PO))"
  "[| <h,h'> : lfp(%x. POgen(x) Un R Un PO);  <t,t'> : lfp(%x. POgen(x) Un R Un PO) |]
    ==> <h$t,h'$t'> : POgen(lfp(%x. POgen(x) Un R Un PO))"
  unfolding data_defs by (genIs POgenXH POgen_mono)+

ML {*
fun POgen_tac ctxt (rla, rlb) i =
  SELECT_GOAL (safe_tac ctxt) i THEN
  rtac (rlb RS (rla RS @{thm ssubst_pair})) i THEN
  (REPEAT (resolve_tac
      (@{thms POgenIs} @ [@{thm PO_refl} RS (@{thm POgen_mono} RS @{thm ci3_AI})] @
        (@{thms POgenIs} RL [@{thm POgen_mono} RS @{thm ci3_AgenI}]) @
        [@{thm POgen_mono} RS @{thm ci3_RI}]) i))
*}


subsection {* EQgen *}

lemma EQ_refl: "<a,a> : EQ"
  by (rule refl [THEN EQ_iff [THEN iffD1]])

lemma EQgenIs:
  "<true,true> : EQgen(R)"
  "<false,false> : EQgen(R)"
  "[| <a,a'> : R;  <b,b'> : R |] ==> <<a,b>,<a',b'>> : EQgen(R)"
  "!!b b'. [|!!x. <b(x),b'(x)> : R |] ==> <lam x. b(x),lam x. b'(x)> : EQgen(R)"
  "<one,one> : EQgen(R)"
  "<a,a'> : lfp(%x. EQgen(x) Un R Un EQ) ==>
    <inl(a),inl(a')> : EQgen(lfp(%x. EQgen(x) Un R Un EQ))"
  "<b,b'> : lfp(%x. EQgen(x) Un R Un EQ) ==>
    <inr(b),inr(b')> : EQgen(lfp(%x. EQgen(x) Un R Un EQ))"
  "<zero,zero> : EQgen(lfp(%x. EQgen(x) Un R Un EQ))"
  "<n,n'> : lfp(%x. EQgen(x) Un R Un EQ) ==>
    <succ(n),succ(n')> : EQgen(lfp(%x. EQgen(x) Un R Un EQ))"
  "<[],[]> : EQgen(lfp(%x. EQgen(x) Un R Un EQ))"
  "[| <h,h'> : lfp(%x. EQgen(x) Un R Un EQ); <t,t'> : lfp(%x. EQgen(x) Un R Un EQ) |]
    ==> <h$t,h'$t'> : EQgen(lfp(%x. EQgen(x) Un R Un EQ))"
  unfolding data_defs by (genIs EQgenXH EQgen_mono)+

ML {*
fun EQgen_raw_tac i =
  (REPEAT (resolve_tac (@{thms EQgenIs} @
        [@{thm EQ_refl} RS (@{thm EQgen_mono} RS @{thm ci3_AI})] @
        (@{thms EQgenIs} RL [@{thm EQgen_mono} RS @{thm ci3_AgenI}]) @
        [@{thm EQgen_mono} RS @{thm ci3_RI}]) i))

(* Goals of the form R <= EQgen(R) - rewrite elements <a,b> : EQgen(R) using rews and *)
(* then reduce this to a goal <a',b'> : R (hopefully?)                                *)
(*      rews are rewrite rules that would cause looping in the simpifier              *)

fun EQgen_tac ctxt rews i =
 SELECT_GOAL
   (TRY (safe_tac ctxt) THEN
    resolve_tac ((rews @ [@{thm refl}]) RL ((rews @ [@{thm refl}]) RL [@{thm ssubst_pair}])) i THEN
    ALLGOALS (simp_tac (simpset_of ctxt)) THEN
    ALLGOALS EQgen_raw_tac) i
*}

end
