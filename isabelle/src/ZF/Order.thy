(*  Title:      ZF/Order.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1994  University of Cambridge

Results from the book "Set Theory: an Introduction to Independence Proofs"
        by Kenneth Kunen.  Chapter 1, section 6.
Additional definitions and lemmas for reflexive orders.
*)

header{*Partial and Total Orderings: Basic Definitions and Properties*}

theory Order imports WF Perm begin

text {* We adopt the following convention: @{text ord} is used for
  strict orders and @{text order} is used for their reflexive
  counterparts. *}

definition
  part_ord :: "[i,i]=>o"                (*Strict partial ordering*)  where
   "part_ord(A,r) == irrefl(A,r) & trans[A](r)"

definition
  linear   :: "[i,i]=>o"                (*Strict total ordering*)  where
   "linear(A,r) == (\<forall>x\<in>A. \<forall>y\<in>A. <x,y>:r | x=y | <y,x>:r)"

definition
  tot_ord  :: "[i,i]=>o"                (*Strict total ordering*)  where
   "tot_ord(A,r) == part_ord(A,r) & linear(A,r)"

definition
  "preorder_on(A, r) \<equiv> refl(A, r) \<and> trans[A](r)"

definition                              (*Partial ordering*)
  "partial_order_on(A, r) \<equiv> preorder_on(A, r) \<and> antisym(r)"

abbreviation
  "Preorder(r) \<equiv> preorder_on(field(r), r)"

abbreviation
  "Partial_order(r) \<equiv> partial_order_on(field(r), r)"

definition
  well_ord :: "[i,i]=>o"                (*Well-ordering*)  where
   "well_ord(A,r) == tot_ord(A,r) & wf[A](r)"

definition
  mono_map :: "[i,i,i,i]=>i"            (*Order-preserving maps*)  where
   "mono_map(A,r,B,s) ==
              {f \<in> A->B. \<forall>x\<in>A. \<forall>y\<in>A. <x,y>:r \<longrightarrow> <f`x,f`y>:s}"

definition
  ord_iso  :: "[i,i,i,i]=>i"            (*Order isomorphisms*)  where
   "ord_iso(A,r,B,s) ==
              {f \<in> bij(A,B). \<forall>x\<in>A. \<forall>y\<in>A. <x,y>:r \<longleftrightarrow> <f`x,f`y>:s}"

definition
  pred     :: "[i,i,i]=>i"              (*Set of predecessors*)  where
   "pred(A,x,r) == {y \<in> A. <y,x>:r}"

definition
  ord_iso_map :: "[i,i,i,i]=>i"         (*Construction for linearity theorem*)  where
   "ord_iso_map(A,r,B,s) ==
     \<Union>x\<in>A. \<Union>y\<in>B. \<Union>f \<in> ord_iso(pred(A,x,r), r, pred(B,y,s), s). {<x,y>}"

definition
  first :: "[i, i, i] => o"  where
    "first(u, X, R) == u \<in> X & (\<forall>v\<in>X. v\<noteq>u \<longrightarrow> <u,v> \<in> R)"


notation (xsymbols)
  ord_iso  ("(\<langle>_, _\<rangle> \<cong>/ \<langle>_, _\<rangle>)" 51)


subsection{*Immediate Consequences of the Definitions*}

lemma part_ord_Imp_asym:
    "part_ord(A,r) ==> asym(r \<inter> A*A)"
by (unfold part_ord_def irrefl_def trans_on_def asym_def, blast)

lemma linearE:
    "[| linear(A,r);  x \<in> A;  y \<in> A;
        <x,y>:r ==> P;  x=y ==> P;  <y,x>:r ==> P |]
     ==> P"
by (simp add: linear_def, blast)


(** General properties of well_ord **)

lemma well_ordI:
    "[| wf[A](r); linear(A,r) |] ==> well_ord(A,r)"
apply (simp add: irrefl_def part_ord_def tot_ord_def
                 trans_on_def well_ord_def wf_on_not_refl)
apply (fast elim: linearE wf_on_asym wf_on_chain3)
done

lemma well_ord_is_wf:
    "well_ord(A,r) ==> wf[A](r)"
by (unfold well_ord_def, safe)

lemma well_ord_is_trans_on:
    "well_ord(A,r) ==> trans[A](r)"
by (unfold well_ord_def tot_ord_def part_ord_def, safe)

lemma well_ord_is_linear: "well_ord(A,r) ==> linear(A,r)"
by (unfold well_ord_def tot_ord_def, blast)


(** Derived rules for pred(A,x,r) **)

lemma pred_iff: "y \<in> pred(A,x,r) \<longleftrightarrow> <y,x>:r & y \<in> A"
by (unfold pred_def, blast)

lemmas predI = conjI [THEN pred_iff [THEN iffD2]]

lemma predE: "[| y \<in> pred(A,x,r);  [| y \<in> A; <y,x>:r |] ==> P |] ==> P"
by (simp add: pred_def)

lemma pred_subset_under: "pred(A,x,r) \<subseteq> r -`` {x}"
by (simp add: pred_def, blast)

lemma pred_subset: "pred(A,x,r) \<subseteq> A"
by (simp add: pred_def, blast)

lemma pred_pred_eq:
    "pred(pred(A,x,r), y, r) = pred(A,x,r) \<inter> pred(A,y,r)"
by (simp add: pred_def, blast)

lemma trans_pred_pred_eq:
    "[| trans[A](r);  <y,x>:r;  x \<in> A;  y \<in> A |]
     ==> pred(pred(A,x,r), y, r) = pred(A,y,r)"
by (unfold trans_on_def pred_def, blast)


subsection{*Restricting an Ordering's Domain*}

(** The ordering's properties hold over all subsets of its domain
    [including initial segments of the form pred(A,x,r) **)

(*Note: a relation s such that s<=r need not be a partial ordering*)
lemma part_ord_subset:
    "[| part_ord(A,r);  B<=A |] ==> part_ord(B,r)"
by (unfold part_ord_def irrefl_def trans_on_def, blast)

lemma linear_subset:
    "[| linear(A,r);  B<=A |] ==> linear(B,r)"
by (unfold linear_def, blast)

lemma tot_ord_subset:
    "[| tot_ord(A,r);  B<=A |] ==> tot_ord(B,r)"
apply (unfold tot_ord_def)
apply (fast elim!: part_ord_subset linear_subset)
done

lemma well_ord_subset:
    "[| well_ord(A,r);  B<=A |] ==> well_ord(B,r)"
apply (unfold well_ord_def)
apply (fast elim!: tot_ord_subset wf_on_subset_A)
done


(** Relations restricted to a smaller domain, by Krzysztof Grabczewski **)

lemma irrefl_Int_iff: "irrefl(A,r \<inter> A*A) \<longleftrightarrow> irrefl(A,r)"
by (unfold irrefl_def, blast)

lemma trans_on_Int_iff: "trans[A](r \<inter> A*A) \<longleftrightarrow> trans[A](r)"
by (unfold trans_on_def, blast)

lemma part_ord_Int_iff: "part_ord(A,r \<inter> A*A) \<longleftrightarrow> part_ord(A,r)"
apply (unfold part_ord_def)
apply (simp add: irrefl_Int_iff trans_on_Int_iff)
done

lemma linear_Int_iff: "linear(A,r \<inter> A*A) \<longleftrightarrow> linear(A,r)"
by (unfold linear_def, blast)

lemma tot_ord_Int_iff: "tot_ord(A,r \<inter> A*A) \<longleftrightarrow> tot_ord(A,r)"
apply (unfold tot_ord_def)
apply (simp add: part_ord_Int_iff linear_Int_iff)
done

lemma wf_on_Int_iff: "wf[A](r \<inter> A*A) \<longleftrightarrow> wf[A](r)"
apply (unfold wf_on_def wf_def, fast) (*10 times faster than blast!*)
done

lemma well_ord_Int_iff: "well_ord(A,r \<inter> A*A) \<longleftrightarrow> well_ord(A,r)"
apply (unfold well_ord_def)
apply (simp add: tot_ord_Int_iff wf_on_Int_iff)
done


subsection{*Empty and Unit Domains*}

(*The empty relation is well-founded*)
lemma wf_on_any_0: "wf[A](0)"
by (simp add: wf_on_def wf_def, fast)

subsubsection{*Relations over the Empty Set*}

lemma irrefl_0: "irrefl(0,r)"
by (unfold irrefl_def, blast)

lemma trans_on_0: "trans[0](r)"
by (unfold trans_on_def, blast)

lemma part_ord_0: "part_ord(0,r)"
apply (unfold part_ord_def)
apply (simp add: irrefl_0 trans_on_0)
done

lemma linear_0: "linear(0,r)"
by (unfold linear_def, blast)

lemma tot_ord_0: "tot_ord(0,r)"
apply (unfold tot_ord_def)
apply (simp add: part_ord_0 linear_0)
done

lemma wf_on_0: "wf[0](r)"
by (unfold wf_on_def wf_def, blast)

lemma well_ord_0: "well_ord(0,r)"
apply (unfold well_ord_def)
apply (simp add: tot_ord_0 wf_on_0)
done


subsubsection{*The Empty Relation Well-Orders the Unit Set*}

text{*by Grabczewski*}

lemma tot_ord_unit: "tot_ord({a},0)"
by (simp add: irrefl_def trans_on_def part_ord_def linear_def tot_ord_def)

lemma well_ord_unit: "well_ord({a},0)"
apply (unfold well_ord_def)
apply (simp add: tot_ord_unit wf_on_any_0)
done


subsection{*Order-Isomorphisms*}

text{*Suppes calls them "similarities"*}

(** Order-preserving (monotone) maps **)

lemma mono_map_is_fun: "f \<in> mono_map(A,r,B,s) ==> f \<in> A->B"
by (simp add: mono_map_def)

lemma mono_map_is_inj:
    "[| linear(A,r);  wf[B](s);  f \<in> mono_map(A,r,B,s) |] ==> f \<in> inj(A,B)"
apply (unfold mono_map_def inj_def, clarify)
apply (erule_tac x=w and y=x in linearE, assumption+)
apply (force intro: apply_type dest: wf_on_not_refl)+
done

lemma ord_isoI:
    "[| f \<in> bij(A, B);
        !!x y. [| x \<in> A; y \<in> A |] ==> <x, y> \<in> r \<longleftrightarrow> <f`x, f`y> \<in> s |]
     ==> f \<in> ord_iso(A,r,B,s)"
by (simp add: ord_iso_def)

lemma ord_iso_is_mono_map:
    "f \<in> ord_iso(A,r,B,s) ==> f \<in> mono_map(A,r,B,s)"
apply (simp add: ord_iso_def mono_map_def)
apply (blast dest!: bij_is_fun)
done

lemma ord_iso_is_bij:
    "f \<in> ord_iso(A,r,B,s) ==> f \<in> bij(A,B)"
by (simp add: ord_iso_def)

(*Needed?  But ord_iso_converse is!*)
lemma ord_iso_apply:
    "[| f \<in> ord_iso(A,r,B,s);  <x,y>: r;  x \<in> A;  y \<in> A |] ==> <f`x, f`y> \<in> s"
by (simp add: ord_iso_def)

lemma ord_iso_converse:
    "[| f \<in> ord_iso(A,r,B,s);  <x,y>: s;  x \<in> B;  y \<in> B |]
     ==> <converse(f) ` x, converse(f) ` y> \<in> r"
apply (simp add: ord_iso_def, clarify)
apply (erule bspec [THEN bspec, THEN iffD2])
apply (erule asm_rl bij_converse_bij [THEN bij_is_fun, THEN apply_type])+
apply (auto simp add: right_inverse_bij)
done


(** Symmetry and Transitivity Rules **)

(*Reflexivity of similarity*)
lemma ord_iso_refl: "id(A): ord_iso(A,r,A,r)"
by (rule id_bij [THEN ord_isoI], simp)

(*Symmetry of similarity*)
lemma ord_iso_sym: "f \<in> ord_iso(A,r,B,s) ==> converse(f): ord_iso(B,s,A,r)"
apply (simp add: ord_iso_def)
apply (auto simp add: right_inverse_bij bij_converse_bij
                      bij_is_fun [THEN apply_funtype])
done

(*Transitivity of similarity*)
lemma mono_map_trans:
    "[| g \<in> mono_map(A,r,B,s);  f \<in> mono_map(B,s,C,t) |]
     ==> (f O g): mono_map(A,r,C,t)"
apply (unfold mono_map_def)
apply (auto simp add: comp_fun)
done

(*Transitivity of similarity: the order-isomorphism relation*)
lemma ord_iso_trans:
    "[| g \<in> ord_iso(A,r,B,s);  f \<in> ord_iso(B,s,C,t) |]
     ==> (f O g): ord_iso(A,r,C,t)"
apply (unfold ord_iso_def, clarify)
apply (frule bij_is_fun [of f])
apply (frule bij_is_fun [of g])
apply (auto simp add: comp_bij)
done

(** Two monotone maps can make an order-isomorphism **)

lemma mono_ord_isoI:
    "[| f \<in> mono_map(A,r,B,s);  g \<in> mono_map(B,s,A,r);
        f O g = id(B);  g O f = id(A) |] ==> f \<in> ord_iso(A,r,B,s)"
apply (simp add: ord_iso_def mono_map_def, safe)
apply (intro fg_imp_bijective, auto)
apply (subgoal_tac "<g` (f`x), g` (f`y) > \<in> r")
apply (simp add: comp_eq_id_iff [THEN iffD1])
apply (blast intro: apply_funtype)
done

lemma well_ord_mono_ord_isoI:
     "[| well_ord(A,r);  well_ord(B,s);
         f \<in> mono_map(A,r,B,s);  converse(f): mono_map(B,s,A,r) |]
      ==> f \<in> ord_iso(A,r,B,s)"
apply (intro mono_ord_isoI, auto)
apply (frule mono_map_is_fun [THEN fun_is_rel])
apply (erule converse_converse [THEN subst], rule left_comp_inverse)
apply (blast intro: left_comp_inverse mono_map_is_inj well_ord_is_linear
                    well_ord_is_wf)+
done


(** Order-isomorphisms preserve the ordering's properties **)

lemma part_ord_ord_iso:
    "[| part_ord(B,s);  f \<in> ord_iso(A,r,B,s) |] ==> part_ord(A,r)"
apply (simp add: part_ord_def irrefl_def trans_on_def ord_iso_def)
apply (fast intro: bij_is_fun [THEN apply_type])
done

lemma linear_ord_iso:
    "[| linear(B,s);  f \<in> ord_iso(A,r,B,s) |] ==> linear(A,r)"
apply (simp add: linear_def ord_iso_def, safe)
apply (drule_tac x1 = "f`x" and x = "f`y" in bspec [THEN bspec])
apply (safe elim!: bij_is_fun [THEN apply_type])
apply (drule_tac t = "op ` (converse (f))" in subst_context)
apply (simp add: left_inverse_bij)
done

lemma wf_on_ord_iso:
    "[| wf[B](s);  f \<in> ord_iso(A,r,B,s) |] ==> wf[A](r)"
apply (simp add: wf_on_def wf_def ord_iso_def, safe)
apply (drule_tac x = "{f`z. z \<in> Z \<inter> A}" in spec)
apply (safe intro!: equalityI)
apply (blast dest!: equalityD1 intro: bij_is_fun [THEN apply_type])+
done

lemma well_ord_ord_iso:
    "[| well_ord(B,s);  f \<in> ord_iso(A,r,B,s) |] ==> well_ord(A,r)"
apply (unfold well_ord_def tot_ord_def)
apply (fast elim!: part_ord_ord_iso linear_ord_iso wf_on_ord_iso)
done


subsection{*Main results of Kunen, Chapter 1 section 6*}

(*Inductive argument for Kunen's Lemma 6.1, etc.
  Simple proof from Halmos, page 72*)
lemma well_ord_iso_subset_lemma:
     "[| well_ord(A,r);  f \<in> ord_iso(A,r, A',r);  A'<= A;  y \<in> A |]
      ==> ~ <f`y, y>: r"
apply (simp add: well_ord_def ord_iso_def)
apply (elim conjE CollectE)
apply (rule_tac a=y in wf_on_induct, assumption+)
apply (blast dest: bij_is_fun [THEN apply_type])
done

(*Kunen's Lemma 6.1 \<in> there's no order-isomorphism to an initial segment
                     of a well-ordering*)
lemma well_ord_iso_predE:
     "[| well_ord(A,r);  f \<in> ord_iso(A, r, pred(A,x,r), r);  x \<in> A |] ==> P"
apply (insert well_ord_iso_subset_lemma [of A r f "pred(A,x,r)" x])
apply (simp add: pred_subset)
(*Now we know  f`x < x *)
apply (drule ord_iso_is_bij [THEN bij_is_fun, THEN apply_type], assumption)
(*Now we also know @{term"f`x \<in> pred(A,x,r)"}: contradiction! *)
apply (simp add: well_ord_def pred_def)
done

(*Simple consequence of Lemma 6.1*)
lemma well_ord_iso_pred_eq:
     "[| well_ord(A,r);  f \<in> ord_iso(pred(A,a,r), r, pred(A,c,r), r);
         a \<in> A;  c \<in> A |] ==> a=c"
apply (frule well_ord_is_trans_on)
apply (frule well_ord_is_linear)
apply (erule_tac x=a and y=c in linearE, assumption+)
apply (drule ord_iso_sym)
(*two symmetric cases*)
apply (auto elim!: well_ord_subset [OF _ pred_subset, THEN well_ord_iso_predE]
            intro!: predI
            simp add: trans_pred_pred_eq)
done

(*Does not assume r is a wellordering!*)
lemma ord_iso_image_pred:
     "[|f \<in> ord_iso(A,r,B,s);  a \<in> A|] ==> f `` pred(A,a,r) = pred(B, f`a, s)"
apply (unfold ord_iso_def pred_def)
apply (erule CollectE)
apply (simp (no_asm_simp) add: image_fun [OF bij_is_fun Collect_subset])
apply (rule equalityI)
apply (safe elim!: bij_is_fun [THEN apply_type])
apply (rule RepFun_eqI)
apply (blast intro!: right_inverse_bij [symmetric])
apply (auto simp add: right_inverse_bij  bij_is_fun [THEN apply_funtype])
done

lemma ord_iso_restrict_image:
     "[| f \<in> ord_iso(A,r,B,s);  C<=A |]
      ==> restrict(f,C) \<in> ord_iso(C, r, f``C, s)"
apply (simp add: ord_iso_def)
apply (blast intro: bij_is_inj restrict_bij)
done

(*But in use, A and B may themselves be initial segments.  Then use
  trans_pred_pred_eq to simplify the pred(pred...) terms.  See just below.*)
lemma ord_iso_restrict_pred:
   "[| f \<in> ord_iso(A,r,B,s);   a \<in> A |]
    ==> restrict(f, pred(A,a,r)) \<in> ord_iso(pred(A,a,r), r, pred(B, f`a, s), s)"
apply (simp add: ord_iso_image_pred [symmetric])
apply (blast intro: ord_iso_restrict_image elim: predE)
done

(*Tricky; a lot of forward proof!*)
lemma well_ord_iso_preserving:
     "[| well_ord(A,r);  well_ord(B,s);  <a,c>: r;
         f \<in> ord_iso(pred(A,a,r), r, pred(B,b,s), s);
         g \<in> ord_iso(pred(A,c,r), r, pred(B,d,s), s);
         a \<in> A;  c \<in> A;  b \<in> B;  d \<in> B |] ==> <b,d>: s"
apply (frule ord_iso_is_bij [THEN bij_is_fun, THEN apply_type], (erule asm_rl predI predE)+)
apply (subgoal_tac "b = g`a")
apply (simp (no_asm_simp))
apply (rule well_ord_iso_pred_eq, auto)
apply (frule ord_iso_restrict_pred, (erule asm_rl predI)+)
apply (simp add: well_ord_is_trans_on trans_pred_pred_eq)
apply (erule ord_iso_sym [THEN ord_iso_trans], assumption)
done

(*See Halmos, page 72*)
lemma well_ord_iso_unique_lemma:
     "[| well_ord(A,r);
         f \<in> ord_iso(A,r, B,s);  g \<in> ord_iso(A,r, B,s);  y \<in> A |]
      ==> ~ <g`y, f`y> \<in> s"
apply (frule well_ord_iso_subset_lemma)
apply (rule_tac f = "converse (f) " and g = g in ord_iso_trans)
apply auto
apply (blast intro: ord_iso_sym)
apply (frule ord_iso_is_bij [of f])
apply (frule ord_iso_is_bij [of g])
apply (frule ord_iso_converse)
apply (blast intro!: bij_converse_bij
             intro: bij_is_fun apply_funtype)+
apply (erule notE)
apply (simp add: left_inverse_bij bij_is_fun comp_fun_apply [of _ A B])
done


(*Kunen's Lemma 6.2: Order-isomorphisms between well-orderings are unique*)
lemma well_ord_iso_unique: "[| well_ord(A,r);
         f \<in> ord_iso(A,r, B,s);  g \<in> ord_iso(A,r, B,s) |] ==> f = g"
apply (rule fun_extension)
apply (erule ord_iso_is_bij [THEN bij_is_fun])+
apply (subgoal_tac "f`x \<in> B & g`x \<in> B & linear(B,s)")
 apply (simp add: linear_def)
 apply (blast dest: well_ord_iso_unique_lemma)
apply (blast intro: ord_iso_is_bij bij_is_fun apply_funtype
                    well_ord_is_linear well_ord_ord_iso ord_iso_sym)
done

subsection{*Towards Kunen's Theorem 6.3: Linearity of the Similarity Relation*}

lemma ord_iso_map_subset: "ord_iso_map(A,r,B,s) \<subseteq> A*B"
by (unfold ord_iso_map_def, blast)

lemma domain_ord_iso_map: "domain(ord_iso_map(A,r,B,s)) \<subseteq> A"
by (unfold ord_iso_map_def, blast)

lemma range_ord_iso_map: "range(ord_iso_map(A,r,B,s)) \<subseteq> B"
by (unfold ord_iso_map_def, blast)

lemma converse_ord_iso_map:
    "converse(ord_iso_map(A,r,B,s)) = ord_iso_map(B,s,A,r)"
apply (unfold ord_iso_map_def)
apply (blast intro: ord_iso_sym)
done

lemma function_ord_iso_map:
    "well_ord(B,s) ==> function(ord_iso_map(A,r,B,s))"
apply (unfold ord_iso_map_def function_def)
apply (blast intro: well_ord_iso_pred_eq ord_iso_sym ord_iso_trans)
done

lemma ord_iso_map_fun: "well_ord(B,s) ==> ord_iso_map(A,r,B,s)
           \<in> domain(ord_iso_map(A,r,B,s)) -> range(ord_iso_map(A,r,B,s))"
by (simp add: Pi_iff function_ord_iso_map
                 ord_iso_map_subset [THEN domain_times_range])

lemma ord_iso_map_mono_map:
    "[| well_ord(A,r);  well_ord(B,s) |]
     ==> ord_iso_map(A,r,B,s)
           \<in> mono_map(domain(ord_iso_map(A,r,B,s)), r,
                      range(ord_iso_map(A,r,B,s)), s)"
apply (unfold mono_map_def)
apply (simp (no_asm_simp) add: ord_iso_map_fun)
apply safe
apply (subgoal_tac "x \<in> A & ya:A & y \<in> B & yb:B")
 apply (simp add: apply_equality [OF _  ord_iso_map_fun])
 apply (unfold ord_iso_map_def)
 apply (blast intro: well_ord_iso_preserving, blast)
done

lemma ord_iso_map_ord_iso:
    "[| well_ord(A,r);  well_ord(B,s) |] ==> ord_iso_map(A,r,B,s)
           \<in> ord_iso(domain(ord_iso_map(A,r,B,s)), r,
                      range(ord_iso_map(A,r,B,s)), s)"
apply (rule well_ord_mono_ord_isoI)
   prefer 4
   apply (rule converse_ord_iso_map [THEN subst])
   apply (simp add: ord_iso_map_mono_map
                    ord_iso_map_subset [THEN converse_converse])
apply (blast intro!: domain_ord_iso_map range_ord_iso_map
             intro: well_ord_subset ord_iso_map_mono_map)+
done


(*One way of saying that domain(ord_iso_map(A,r,B,s)) is downwards-closed*)
lemma domain_ord_iso_map_subset:
     "[| well_ord(A,r);  well_ord(B,s);
         a \<in> A;  a \<notin> domain(ord_iso_map(A,r,B,s)) |]
      ==>  domain(ord_iso_map(A,r,B,s)) \<subseteq> pred(A, a, r)"
apply (unfold ord_iso_map_def)
apply (safe intro!: predI)
(*Case analysis on  xa vs a in r *)
apply (simp (no_asm_simp))
apply (frule_tac A = A in well_ord_is_linear)
apply (rename_tac b y f)
apply (erule_tac x=b and y=a in linearE, assumption+)
(*Trivial case: b=a*)
apply clarify
apply blast
(*Harder case: <a, xa>: r*)
apply (frule ord_iso_is_bij [THEN bij_is_fun, THEN apply_type],
       (erule asm_rl predI predE)+)
apply (frule ord_iso_restrict_pred)
 apply (simp add: pred_iff)
apply (simp split: split_if_asm
          add: well_ord_is_trans_on trans_pred_pred_eq domain_UN domain_Union, blast)
done

(*For the 4-way case analysis in the main result*)
lemma domain_ord_iso_map_cases:
     "[| well_ord(A,r);  well_ord(B,s) |]
      ==> domain(ord_iso_map(A,r,B,s)) = A |
          (\<exists>x\<in>A. domain(ord_iso_map(A,r,B,s)) = pred(A,x,r))"
apply (frule well_ord_is_wf)
apply (unfold wf_on_def wf_def)
apply (drule_tac x = "A-domain (ord_iso_map (A,r,B,s))" in spec)
apply safe
(*The first case: the domain equals A*)
apply (rule domain_ord_iso_map [THEN equalityI])
apply (erule Diff_eq_0_iff [THEN iffD1])
(*The other case: the domain equals an initial segment*)
apply (blast del: domainI subsetI
             elim!: predE
             intro!: domain_ord_iso_map_subset
             intro: subsetI)+
done

(*As above, by duality*)
lemma range_ord_iso_map_cases:
    "[| well_ord(A,r);  well_ord(B,s) |]
     ==> range(ord_iso_map(A,r,B,s)) = B |
         (\<exists>y\<in>B. range(ord_iso_map(A,r,B,s)) = pred(B,y,s))"
apply (rule converse_ord_iso_map [THEN subst])
apply (simp add: domain_ord_iso_map_cases)
done

text{*Kunen's Theorem 6.3: Fundamental Theorem for Well-Ordered Sets*}
theorem well_ord_trichotomy:
   "[| well_ord(A,r);  well_ord(B,s) |]
    ==> ord_iso_map(A,r,B,s) \<in> ord_iso(A, r, B, s) |
        (\<exists>x\<in>A. ord_iso_map(A,r,B,s) \<in> ord_iso(pred(A,x,r), r, B, s)) |
        (\<exists>y\<in>B. ord_iso_map(A,r,B,s) \<in> ord_iso(A, r, pred(B,y,s), s))"
apply (frule_tac B = B in domain_ord_iso_map_cases, assumption)
apply (frule_tac B = B in range_ord_iso_map_cases, assumption)
apply (drule ord_iso_map_ord_iso, assumption)
apply (elim disjE bexE)
   apply (simp_all add: bexI)
apply (rule wf_on_not_refl [THEN notE])
  apply (erule well_ord_is_wf)
 apply assumption
apply (subgoal_tac "<x,y>: ord_iso_map (A,r,B,s) ")
 apply (drule rangeI)
 apply (simp add: pred_def)
apply (unfold ord_iso_map_def, blast)
done


subsection{*Miscellaneous Results by Krzysztof Grabczewski*}

(** Properties of converse(r) **)

lemma irrefl_converse: "irrefl(A,r) ==> irrefl(A,converse(r))"
by (unfold irrefl_def, blast)

lemma trans_on_converse: "trans[A](r) ==> trans[A](converse(r))"
by (unfold trans_on_def, blast)

lemma part_ord_converse: "part_ord(A,r) ==> part_ord(A,converse(r))"
apply (unfold part_ord_def)
apply (blast intro!: irrefl_converse trans_on_converse)
done

lemma linear_converse: "linear(A,r) ==> linear(A,converse(r))"
by (unfold linear_def, blast)

lemma tot_ord_converse: "tot_ord(A,r) ==> tot_ord(A,converse(r))"
apply (unfold tot_ord_def)
apply (blast intro!: part_ord_converse linear_converse)
done


(** By Krzysztof Grabczewski.
    Lemmas involving the first element of a well ordered set **)

lemma first_is_elem: "first(b,B,r) ==> b \<in> B"
by (unfold first_def, blast)

lemma well_ord_imp_ex1_first:
        "[| well_ord(A,r); B<=A; B\<noteq>0 |] ==> (EX! b. first(b,B,r))"
apply (unfold well_ord_def wf_on_def wf_def first_def)
apply (elim conjE allE disjE, blast)
apply (erule bexE)
apply (rule_tac a = x in ex1I, auto)
apply (unfold tot_ord_def linear_def, blast)
done

lemma the_first_in:
     "[| well_ord(A,r); B<=A; B\<noteq>0 |] ==> (THE b. first(b,B,r)) \<in> B"
apply (drule well_ord_imp_ex1_first, assumption+)
apply (rule first_is_elem)
apply (erule theI)
done


subsection {* Lemmas for the Reflexive Orders *}

lemma subset_vimage_vimage_iff:
  "[| Preorder(r); A \<subseteq> field(r); B \<subseteq> field(r) |] ==>
  r -`` A \<subseteq> r -`` B \<longleftrightarrow> (\<forall>a\<in>A. \<exists>b\<in>B. <a, b> \<in> r)"
  apply (auto simp: subset_def preorder_on_def refl_def vimage_def image_def)
   apply blast
  unfolding trans_on_def
  apply (erule_tac P = "(\<lambda>x. \<forall>y\<in>field(?r).
          \<forall>z\<in>field(?r). \<langle>x, y\<rangle> \<in> ?r \<longrightarrow> \<langle>y, z\<rangle> \<in> ?r \<longrightarrow> \<langle>x, z\<rangle> \<in> ?r)" in rev_ballE)
    (* instance obtained from proof term generated by best *)
   apply best
  apply blast
  done

lemma subset_vimage1_vimage1_iff:
  "[| Preorder(r); a \<in> field(r); b \<in> field(r) |] ==>
  r -`` {a} \<subseteq> r -`` {b} \<longleftrightarrow> <a, b> \<in> r"
  by (simp add: subset_vimage_vimage_iff)

lemma Refl_antisym_eq_Image1_Image1_iff:
  "[| refl(field(r), r); antisym(r); a \<in> field(r); b \<in> field(r) |] ==>
  r `` {a} = r `` {b} \<longleftrightarrow> a = b"
  apply rule
   apply (frule equality_iffD)
   apply (drule equality_iffD)
   apply (simp add: antisym_def refl_def)
   apply best
  apply (simp add: antisym_def refl_def)
  done

lemma Partial_order_eq_Image1_Image1_iff:
  "[| Partial_order(r); a \<in> field(r); b \<in> field(r) |] ==>
  r `` {a} = r `` {b} \<longleftrightarrow> a = b"
  by (simp add: partial_order_on_def preorder_on_def
    Refl_antisym_eq_Image1_Image1_iff)

lemma Refl_antisym_eq_vimage1_vimage1_iff:
  "[| refl(field(r), r); antisym(r); a \<in> field(r); b \<in> field(r) |] ==>
  r -`` {a} = r -`` {b} \<longleftrightarrow> a = b"
  apply rule
   apply (frule equality_iffD)
   apply (drule equality_iffD)
   apply (simp add: antisym_def refl_def)
   apply best
  apply (simp add: antisym_def refl_def)
  done

lemma Partial_order_eq_vimage1_vimage1_iff:
  "[| Partial_order(r); a \<in> field(r); b \<in> field(r) |] ==>
  r -`` {a} = r -`` {b} \<longleftrightarrow> a = b"
  by (simp add: partial_order_on_def preorder_on_def
    Refl_antisym_eq_vimage1_vimage1_iff)

end
