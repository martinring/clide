header {* Automation *}
theory Automation
imports Hoare_Triple
begin

text {*
  In this theory, we provide a set of tactics and a simplifier setup for easy
  reasoning with our separation logic.
*}

subsection {* Normalization of Assertions *}
text {*
  In this section, we provide a set of lemmas and a simplifier
  setup to bring assertions to a normal form. We provide a simproc that
  detects pure parts of assertions and duplicate pointers. Moreover,
  we provide ac-rules for assertions. See Section~\ref{sec:auto:overview}
  for a short overview of the available proof methods.
*}

lemmas assn_aci =   
  inf_aci[where 'a=assn] 
  sup_aci[where 'a=assn] 
  mult.left_ac[where 'a=assn] 

lemmas star_assoc = mult_assoc[where 'a=assn] 
lemmas assn_assoc = 
  mult.left_assoc inf_assoc[where 'a=assn] sup_assoc[where 'a=assn] 

lemma merge_true_star_ctx: "true * (true * P) = true * P"
  by (simp add: mult.left_ac)
  
lemmas star_aci = 
  mult_ac[where 'a=assn] assn_one_left mult_1_right[where 'a=assn]
  merge_true_star merge_true_star_ctx

text {* Move existential quantifiers to the front of assertions *}
lemma ex_assn_move_out[simp]:
  "\<And>Q R. (\<exists>\<^sub>Ax. Q x) * R = (\<exists>\<^sub>Ax. (Q x * R))"
  "\<And>Q R. R * (\<exists>\<^sub>Ax. Q x) = (\<exists>\<^sub>Ax. (R * Q x))"

  "\<And>P Q. (\<exists>\<^sub>Ax. Q x) \<and>\<^sub>A P = (\<exists>\<^sub>Ax. (Q x \<and>\<^sub>A P)) "
  "\<And>P Q. Q \<and>\<^sub>A (\<exists>\<^sub>Ax. P x) = (\<exists>\<^sub>Ax. (Q \<and>\<^sub>A P x))"

  "\<And>P Q. (\<exists>\<^sub>Ax. Q x) \<or>\<^sub>A P = (\<exists>\<^sub>Ax. (Q x \<or>\<^sub>A P))"
  "\<And>P Q. Q \<or>\<^sub>A (\<exists>\<^sub>Ax. P x) = (\<exists>\<^sub>Ax. (Q \<or>\<^sub>A P x))"
  apply -
  apply (simp add: ex_distrib_star)
  apply (subst mult_commute)
  apply (subst (2) mult_commute)
  apply (simp add: ex_distrib_star)

  apply (simp add: ex_distrib_and)
  apply (subst inf_commute)
  apply (subst (2) inf_commute)
  apply (simp add: ex_distrib_and)

  apply (simp add: ex_distrib_or)
  apply (subst sup_commute)
  apply (subst (2) sup_commute)
  apply (simp add: ex_distrib_or)
  done

text {* Extract pure assertions from and-clauses *}
lemma and_extract_pure_left_iff[simp]: "\<up>b \<and>\<^sub>A Q = (emp\<and>\<^sub>AQ)*\<up>b"
  by (cases b) auto

lemma and_extract_pure_left_ctx_iff[simp]: "P*\<up>b \<and>\<^sub>A Q = (P\<and>\<^sub>AQ)*\<up>b"
  by (cases b) auto

lemma and_extract_pure_right_iff[simp]: "P \<and>\<^sub>A \<up>b = (emp\<and>\<^sub>AP)*\<up>b"
  by (cases b) (auto simp: assn_aci)

lemma and_extract_pure_right_ctx_iff[simp]: "P \<and>\<^sub>A Q*\<up>b = (P\<and>\<^sub>AQ)*\<up>b"
  by (cases b) auto

lemmas and_extract_pure_iff = 
  and_extract_pure_left_iff and_extract_pure_left_ctx_iff
  and_extract_pure_right_iff and_extract_pure_right_ctx_iff

lemmas norm_assertion_simps =
  (* Neutral elements *)
  mult_1[where 'a=assn] mult_1_right[where 'a=assn]
  inf_top_left[where 'a=assn] inf_top_right[where 'a=assn]
  sup_bot_left[where 'a=assn] sup_bot_right[where 'a=assn]

  (* Zero elements *)
  star_false_left star_false_right
  inf_bot_left[where 'a=assn] inf_bot_right[where 'a=assn]
  sup_top_left[where 'a=assn] sup_top_right[where 'a=assn]

  (* Associativity *)
  mult.left_assoc[where 'a=assn]
  inf_assoc[where 'a=assn]
  sup_assoc[where 'a=assn]

  (* Existential Quantifiers *)
  ex_assn_move_out ex_assn_const

  (* Extract pure assertions from conjunctions *)
  and_extract_pure_iff

  (* Merging *)
  merge_pure_star merge_pure_and merge_pure_or
  merge_true_star 
  inf_idem[where 'a=assn] sup_idem[where 'a=assn]

  (* Duplicated References *)
  sngr_same_false snga_same_false


subsubsection {* Simplifier Setup Fine-Tuning *}
text {* Imperative HOL likes to simplify pointer inequations to this strange
  operator. We do some additional simplifier setup here *}
lemma not_same_noteqr[simp]: "\<not> a=!=a"
  by (metis Ref.unequal)
declare Ref.noteq_irrefl[dest!]

lemma not_same_noteqa[simp]: "\<not> a=!!=a"
  by (metis Array.unequal)
declare Array.noteq_irrefl[dest!]

text {* However, it is safest to disable this rewriting, as there is
  a working standard simplifier setup for @{text "op \<noteq>"}
  *}
declare Ref.unequal[simp del]
declare Array.unequal[simp del]


subsection {* Normalization of Entailments *}

text {* Used by existential quantifier extraction tactic *}
lemma enorm_exI': (* Incomplete, as chosen x may depend on heap! *)
  "(\<And>x. Z x \<longrightarrow> (P \<Longrightarrow>\<^sub>A Q x)) \<Longrightarrow> (\<exists>x. Z x) \<longrightarrow> (P \<Longrightarrow>\<^sub>A (\<exists>\<^sub>Ax. Q x))"
  by (metis ent_ex_postI)
  
text {* Example of how to build an extraction lemma. *}
thm enorm_exI'[OF enorm_exI'[OF imp_refl]]

lemmas ent_triv = ent_true ent_false

text {* Dummy rule to detect Hoare triple goal *}
lemma is_hoare_triple: "<P> c <Q> \<Longrightarrow> <P> c <Q>" .
text {* Dummy rule to detect entailment goal *}
lemma is_entails: "P\<Longrightarrow>\<^sub>AQ \<Longrightarrow> P \<Longrightarrow>\<^sub>AQ" .

subsection {* Frame Matcher *}
text {* Given star-lists P,Q and a frame F, this method tries to match 
  all elements of Q with corresponding elements of P. The result is a 
  partial match, that contains matching pairs and the unmatched content.*}

text {* The frame-matcher internally uses syntactic lists separated by
  star, and delimited by the special symbol @{text "SLN"}, which is defined
  to be @{text "emp"}. *}
definition [simp]: "SLN \<equiv> emp"
lemma SLN_left: "SLN * P = P" by simp
lemma SLN_right: "P * SLN = P" by simp

lemmas SLN_normalize = SLN_right mult.left_assoc[where 'a=assn]
lemmas SLN_strip = SLN_right SLN_left mult.left_assoc[where 'a=assn]

text {* A query to the frame matcher. Contains the assertions
  P and Q that shall be matched, as well as a frame F, that is not 
  touched. *}

definition [simp]: "FI_QUERY P Q F \<equiv> P \<Longrightarrow>\<^sub>A Q*F"

abbreviation "fi_m_fst M \<equiv> foldr (op *) (map fst M) emp"
abbreviation "fi_m_snd M \<equiv> foldr (op *) (map snd M) emp"
abbreviation "fi_m_match M \<equiv> (\<forall>(p,q)\<in>set M. p \<Longrightarrow>\<^sub>A q)"

text {* A result of the frame matcher. Contains a list of matching pairs,
  as well as the unmatched parts of P and Q, and the frame F.
*}
definition [simp]: "FI_RESULT M UP UQ F \<equiv> 
  fi_m_match M \<longrightarrow> (fi_m_fst M * UP \<Longrightarrow>\<^sub>A fi_m_snd M * UQ * F)"

text {* Internal structure used by the frame matcher: 
  m contains the matched pairs; p,q the assertions that still needs to be 
  matched; up,uq the assertions that could not be matched; and f the frame.
  p and q are SLN-delimited syntactic lists. 
*}

definition [simp]: "FI m p q up uq f \<equiv> 
  fi_m_match m \<longrightarrow> (fi_m_fst m * p * up \<Longrightarrow>\<^sub>A fi_m_snd m * q * uq * f)"

text {* Initialize processing of query *}
lemma FI_init: 
  assumes "FI [] (SLN*P) (SLN*Q) SLN SLN F"
  shows "FI_QUERY P Q F"
  using assms by simp

text {* Construct result from internal representation *}
lemma FI_finalize:
  assumes "FI_RESULT m (p*up) (q*uq) f"
  shows "FI m p q up uq f"
  using assms by (simp add: assn_aci)

text {* Auxiliary lemma to show that all matching pairs together form
  an entailment. This is required for most applications. *}
lemma fi_match_entails:
  assumes "fi_m_match m"
  shows "fi_m_fst m \<Longrightarrow>\<^sub>A fi_m_snd m"
  using assms apply (induct m)
  apply (simp_all split: prod.split_asm add: ent_star_mono)
  done

text {* Internally, the frame matcher tries to match the first assertion
  of q with the first assertion of p. If no match is found, the first
  assertion of p is discarded. If no match for any assertion in p can be
  found, the first assertion of q is discarded. *}

text {* Match *}
lemma FI_match:
  assumes "p \<Longrightarrow>\<^sub>A q"
  assumes "FI ((p,q)#m) (ps*up) (qs*uq) SLN SLN f"
  shows "FI m (ps*p) (qs*q) up uq f"
  using assms unfolding FI_def
  by (simp add: assn_aci)

text {* No match *}
lemma FI_p_nomatch:
  assumes "FI m ps (qs*q) (p*up) uq f"
  shows "FI m (ps*p) (qs*q) up uq f"
  using assms unfolding FI_def
  by (simp add: assn_aci)
  
text {* Head of q could not be matched *}
lemma FI_q_nomatch:
  assumes "FI m (SLN*up) qs SLN (q*uq) f"
  shows "FI m SLN (qs*q) up uq f"
  using assms unfolding FI_def
  by (simp add: assn_aci) 

subsection {* Frame Inference *}
lemma frame_inference_init:
  assumes "FI_QUERY P Q F"
  shows "P \<Longrightarrow>\<^sub>A Q * F"
  using assms by simp

lemma frame_inference_finalize:
  shows "FI_RESULT M F emp F"
  apply simp
  apply rule
  apply (drule fi_match_entails)
  apply (rule ent_star_mono[OF _ ent_refl])
  apply assumption
  done

subsection {* Entailment Solver *}
lemma entails_solve_init:
  "FI_QUERY P Q true \<Longrightarrow> P \<Longrightarrow>\<^sub>A Q * true"
  "FI_QUERY P Q emp \<Longrightarrow> P \<Longrightarrow>\<^sub>A Q"
  by (simp_all add: assn_aci)

lemma entails_solve_finalize:
  "FI_RESULT M P emp true"
  "FI_RESULT M emp emp emp"
  by (auto simp add: fi_match_entails intro: ent_star_mono)

lemmas solve_ent_preprocess_simps = 
  ent_pure_post_iff ent_pure_post_iff_sng ent_pure_pre_iff ent_pure_pre_iff_sng
  
subsection {* Verification Condition Generator *}

lemmas normalize_rules = norm_pre_ex_rule norm_pre_pure_rule

(* Originally we introduced backwards-reasoning here, via
  cons_pre_rule[OF _ return_wp_rule] (old name: complete_return_cons). 
  This only works, if the postcondition is not schematic! However, for 
  forward reasoning, one usually assumes a schematic postcondition!
  *)
text {* May be useful in simple, manual proofs, where the postcondition
  is no schematic variable. *}
lemmas return_cons_rule = cons_pre_rule[OF _ return_wp_rule]

text {* Useful frame-rule variant for manual proof: *}
lemma frame_rule_left:
  "<P> c <Q> \<Longrightarrow> <R * P> c <\<lambda>x. R * Q x>"
  using frame_rule by (simp add: assn_aci)

lemmas deconstruct_rules = 
  bind_rule if_rule false_rule return_sp_rule

lemmas heap_rules = 
  ref_rule
  lookup_rule
  update_rule
  new_rule
  of_list_rule
  length_rule
  nth_rule
  upd_rule
  freeze_rule

lemma fi_rule:
  assumes CMD: "<P> c <Q>"
  assumes FRAME: "Ps \<Longrightarrow>\<^sub>A P * F"
  shows "<Ps> c <\<lambda>x. Q x * F>"
  apply (rule cons_pre_rule[rotated])
  apply (rule frame_rule)
  apply (rule CMD)
  apply (rule FRAME)
  done


subsection {* ML-setup *}

ML {*
infix 1 THEN_IGNORE_NEWGOALS

structure Seplogic_Auto = struct

  (***********************************)
  (*             Tools               *)
  (***********************************)

  (* Repeat tac on subgoal. Determinize each step. 
     Stop if tac fails or subgoal is solved. *)
  fun REPEAT_DETERM' tac i st = let
    val n = nprems_of st 
  in
    REPEAT_DETERM (COND (has_fewer_prems n) no_tac (tac i)) st
  end


  (***********************************)
  (*             Debugging           *)
  (***********************************)
  fun tr_term t = Pretty.string_of (Syntax.pretty_term @{context} t);


  (***********************************)
  (*        Custom Tacticals         *)
  (***********************************)

  (* Apply tac1, and then tac2 with an offset such that anything left 
     over by tac1 is skipped.

     The typical usage of this tactic is, if a theorem is instantiated
     with another theorem that produces additional goals that should 
     be ignored first. Here, it is used in the vcg to ensure that 
     frame inference is done before additional premises (that may 
     depend on the frame) are discharged.
  *)
  fun (tac1 THEN_IGNORE_NEWGOALS tac2) i st = let
    val np = nprems_of st
  in
    (tac1 i THEN (fn st' => let val np' = nprems_of st' in
      if np'<np then tac2 i st'
      else tac2 (i+(np'-np)+1) st'
    end)) st
  end;


  (***********************************)
  (*     Assertion Normalization     *)
  (***********************************)
  (* Find two terms in a list whose key is equal *)
  fun find_similar (key_of:term -> term) (ts:term list) = let
    fun frec _ [] = NONE
    | frec tab (t::ts) = let val k=key_of t in
      if Termtab.defined tab k then
        SOME (the (Termtab.lookup tab k),t)
      else frec (Termtab.update (k,t) tab) ts
    end
  in
    frec Termtab.empty ts
  end;

  (* Perform DFS over term with binary operator opN, threading through
    a state. Atomic terms are transformed by tr. Supports omission of
    terms from the result structure by transforming them to NONE. *)
  fun dfs_opr opN (tr:'state -> term -> ('state*term option)) 
    d (t as ((op_t as Const (fN,_))$t1$t2)) =
    if fN = opN then let
        val (d1,t1') = dfs_opr opN tr d t1;
        val (d2,t2') = dfs_opr opN tr d1 t2;
      in
        case (t1',t2') of
          (NONE,NONE) => (d2,NONE)
        | (SOME t1',NONE) => (d2,SOME t1')
        | (NONE,SOME t2') => (d2,SOME t2')
        | (SOME t1',SOME t2') => (d2,SOME (op_t$t1'$t2'))
      end
    else tr d t
  | dfs_opr _ tr d t = tr d t;
    
  (* Replace single occurence of (atomic) ot in t by nt. 
    Returns new term or NONE if nothing was removed. *)
  fun dfs_replace_atomic opN ot nt t = let
    fun tr d t = if not d andalso t=ot then (true,SOME nt) else (d,SOME t);
    val (success,SOME t') = dfs_opr opN tr false t; 
  in
    if success then SOME t' else NONE
  end;

  fun assn_simproc_fun ss credex = let
    val ctxt = Simplifier.the_context ss
    val ([redex],ctxt') = Variable.import_terms true [term_of credex] ctxt;
    (*val _ = tracing (tr_term redex);*)
    val export = singleton (Variable.export ctxt' ctxt)

    val thy = theory_of_cterm credex;

    fun mk_star t1 t2 = @{term "op *::assn \<Rightarrow> _ \<Rightarrow> _"}$t2$t1;

    fun mk_star' NONE NONE = NONE
    | mk_star' (SOME t1) NONE  = SOME t1
    | mk_star' NONE (SOME t2) = SOME t2
    | mk_star' (SOME t1) (SOME t2) = SOME (mk_star t1 t2);

    fun ptrs_key (_$k$_) = k;

    fun remove_term pt t = case
      dfs_replace_atomic @{const_name "Groups.times_class.times"} pt 
        @{term emp} t 
    of
      SOME t' => t';  

    fun normalize t = let

      fun ep_tr (has_true,ps,ptrs) t = case t of 
        Const (@{const_name "Assertions.pure_assn"},_)$_ 
        => ((has_true,t::ps,ptrs),NONE)
      | Const (@{const_name "Assertions.sngr_assn"},_)$_$_ 
        => ((has_true,ps,t::ptrs),SOME t)
      | Const (@{const_name "Assertions.snga_assn"},_)$_$_
        => ((has_true,ps,t::ptrs),SOME t)
      | Const (@{const_name "Orderings.top_class.top"},_)
        => ((true,ps,ptrs),NONE)
      | (inf_op as Const (@{const_name "Lattices.inf_class.inf"},_))$t1$t2
        => ((has_true,ps,ptrs),SOME (inf_op$normalize t1$normalize t2))
      | _ => ((has_true,ps,ptrs),SOME t);

      fun normalizer t = case dfs_opr @{const_name "Groups.times_class.times"}
        ep_tr (false,[],[]) t 
      of 
        ((has_true,ps,ptrs),rt) => ((has_true,rev ps,ptrs),rt);

      fun normalize_core t = let 
        val ((has_true,pures,ptrs),rt) = normalizer t;
        (*val _ = tracing (PolyML.makestring ptrs);*)
        val similar = find_similar ptrs_key ptrs;
        (*val _ = tracing (PolyML.makestring similar);*)
        val true_t = if has_true then SOME @{term "Assertions.top_assn"} 
          else NONE;
        val pures' = case pures of 
            [] => NONE
          | p::ps => SOME (fold mk_star ps p);
      in
        case similar of NONE => the (mk_star' pures' (mk_star' true_t rt))
        | SOME (t1,t2) => let
            val t_stripped = remove_term t1 (remove_term t2 t);
          in mk_star t_stripped (mk_star t1 t2) end
      end;

      fun skip_ex ((exq as Const (@{const_name "ex_assn"},_))$(Abs (n,ty,t))) =
        exq$Abs (n,ty,skip_ex t)
      | skip_ex t = normalize_core t;

      val (bs,t') = strip_abs t;
      val ty = fastype_of1 (map #2 bs,t');
    in
      if ty = @{typ assn} then
        Logic.rlist_abs (bs,skip_ex t')
      else t
    end;

    (*val _ = tracing (tr_term redex);*)
    val (f,terms) = strip_comb redex;
    val nterms = map (fn t => let
        (*val _ = tracing (tr_term t); *)
        val t'=normalize t; 
        (*val _ = tracing (tr_term t');*)
      in t' end) terms;
    val new_form = list_comb (f,nterms);

    val res_ss = Simplifier.inherit_context ss 
      (HOL_basic_ss addsimps @{thms star_aci});
    val result = Option.map (export o mk_meta_eq) (Arith_Data.prove_conv_nohyps
      [simp_tac res_ss 1] ctxt' (redex,new_form)
    );

  in 
    result
  end handle exc => 
    (tracing ("assn_simproc failed with exception: "^PolyML.makestring exc); 
      NONE) (* Fail silently *);
  
  val assn_simproc = Simplifier.make_simproc {
    lhss = [@{cpat "?h\<Turnstile>?P"},@{cpat "?P \<Longrightarrow>\<^sub>A ?Q"},
            @{cpat "Hoare_Triple.hoare_triple ?P ?c ?Q"},
            @{cpat "(?P::assn) = ?Q"}],
    name = "assn_simproc",
    proc = K assn_simproc_fun,
    identifier = []
  };



  (***********************************)
  (*     Default Simplifications     *)
  (***********************************)

  structure dflt_simps = Named_Thms
    ( val name = @{binding "sep_dflt_simps"}
      val description = "Seplogic: " ^
        "Default simplification rules for automated solvers" );

  (* Default simplification. MUST contain assertion normalization!
    Tactic must not fail! *)
  fun dflt_tac ctxt = asm_full_simp_tac
    (HOL_ss
      addsimprocs [assn_simproc] 
      addsimps @{thms norm_assertion_simps}
      addsimps dflt_simps.get ctxt
      |> fold Splitter.del_split @{thms split_if_asm split_if}
    );

  (***********************************)
  (*         Frame Matcher           *)
  (***********************************)

  (* Do frame matching
    imp_solve_tac - tactic used to discharge first assumption of match-rule
      cf. lemma FI_match.
  *)
  fun match_frame_tac imp_solve_tac ctxt = let
    (* Normalize star-lists *)
    val norm_tac = simp_tac (HOL_basic_ss addsimps @{thms SLN_normalize});

    (* Strip star-lists *)
    val strip_tac = 
      simp_tac (HOL_basic_ss addsimps @{thms SLN_strip}) THEN'
      simp_tac (HOL_basic_ss addsimps @{thms SLN_def});

    (* Do a match step *)
    val match_tac = rtac @{thm FI_match} (* Separate p,q*)
      THEN' SOLVED' imp_solve_tac (* Solve implication *)
      THEN' norm_tac;

    (* Do a no-match step *)
    val nomatch_tac = rtac @{thm FI_p_nomatch} ORELSE' 
      (rtac @{thm FI_q_nomatch} THEN' norm_tac);
  in
    rtac @{thm FI_init} THEN' norm_tac 
    THEN' REPEAT_DETERM' (FIRST' [
      CHANGED o dflt_tac ctxt,
      (match_tac ORELSE' nomatch_tac)])
    THEN' rtac @{thm FI_finalize} THEN' strip_tac
  end;


  (***********************************)
  (*         Frame Inference         *)
  (***********************************)

  fun frame_inference_tac ctxt =
    rtac @{thm frame_inference_init} 
    THEN' match_frame_tac (rtac @{thm ent_refl}) ctxt
    THEN' rtac @{thm frame_inference_finalize};


  (***********************************)
  (*       Entailment Solver         *)
  (***********************************)

  structure eintros = Named_Thms
    ( val name = @{binding "sep_eintros"}
      val description = "Seplogic: " ^
        "Intro rules for entailment solver" );

  (* Extract existential quantifiers from entailment goal *)
  fun extract_ex_tac i st = let
    fun count_ex (Const (@{const_name Assertions.entails},_)$_$c) = 
      count_ex c RS @{thm HOL.mp}
    | count_ex (Const (@{const_name Assertions.ex_assn},_)$Abs (_,_,t))
      = count_ex t RS @{thm enorm_exI'}
    | count_ex _ = @{thm imp_refl};

    val concl = Logic.concl_of_goal (prop_of st) i |> HOLogic.dest_Trueprop;
    val thm = count_ex concl;
  in
    (TRY o REPEAT_ALL_NEW (match_tac @{thms ent_ex_preI}) THEN'
     rtac thm) i st
  end;


  (* Solve Entailment *)
  fun solve_entails_tac ctxt = let
    val preprocess_entails_tac = 
      dflt_tac ctxt 
      THEN' extract_ex_tac
      THEN' simp_tac (HOL_ss addsimps @{thms solve_ent_preprocess_simps});

    val match_entails_tac =
      resolve_tac @{thms entails_solve_init} 
      THEN' match_frame_tac (resolve_tac @{thms ent_refl}) ctxt
      THEN' resolve_tac @{thms entails_solve_finalize};
  in
    preprocess_entails_tac
    THEN' (TRY o REPEAT_ALL_NEW (match_tac (eintros.get ctxt)))
    THEN_ALL_NEW (dflt_tac ctxt THEN' 
      TRY o (match_tac @{thms ent_triv} 
        ORELSE' resolve_tac @{thms ent_refl}
        ORELSE' match_entails_tac))
  end;


  (***********************************)
  (* Verification Condition Generator*)
  (***********************************)

  structure heap_rules = Named_Thms
    ( val name = @{binding "sep_heap_rules"}
      val description = "Seplogic: " ^
        "VCG heap rules" );

  structure decon_rules = Named_Thms
    ( val name = @{binding "sep_decon_rules"}
      val description = "Seplogic: " ^
        "VCG deconstruct rules" );

  fun vcg_tac ctxt = let
    val h_thms = heap_rules.get ctxt;
    val d_thms = decon_rules.get ctxt;
    val heap_rule_tac =
      resolve_tac h_thms ORELSE' (
      rtac @{thm fi_rule} THEN' (resolve_tac h_thms THEN_IGNORE_NEWGOALS
      frame_inference_tac ctxt));

    (* Apply consequence rule if postcondition is not a schematic var *)
    fun app_post_cons_tac i st = 
      case Logic.concl_of_goal (prop_of st) i |> HOLogic.dest_Trueprop of
        Const (@{const_name Hoare_Triple.hoare_triple},_)$_$_$qt =>
          if is_Var (head_of qt) then no_tac st
          else rtac @{thm cons_post_rule} i st
      | _ => no_tac st;

  in
    REPEAT_DETERM' (FIRST' [
      CHANGED o dflt_tac ctxt,
      REPEAT_ALL_NEW (resolve_tac @{thms normalize_rules}),
      CHANGED o (FIRST' [resolve_tac d_thms, heap_rule_tac]
        ORELSE' (app_post_cons_tac THEN' 
          FIRST' [resolve_tac d_thms, heap_rule_tac])) 
    ])
  end;


  (***********************************)
  (*        Automatic Solver         *)
  (***********************************)

  fun sep_autosolve_tac do_pre do_post ctxt = let
    val pre_tacs = [
      CHANGED o clarsimp_tac ctxt,
      CHANGED o REPEAT_ALL_NEW (match_tac @{thms ballI allI impI conjI})
    ];
    val main_tacs = [
      match_tac @{thms is_hoare_triple} THEN' CHANGED o vcg_tac ctxt,
      match_tac @{thms is_entails} THEN' CHANGED o solve_entails_tac ctxt
    ];
    val post_tacs = [SELECT_GOAL (auto_tac ctxt)];
    val tacs = (if do_pre then pre_tacs else [])
      @ main_tacs 
      @ (if do_post then post_tacs else []);
  in
    REPEAT_DETERM' (CHANGED o FIRST' tacs)
  end;


  (***********************************)
  (*          Method Setup           *)
  (***********************************)

  val dflt_simps_modifiers = [
    Args.$$$ "dflt_simps" -- Scan.option Args.add -- Args.colon 
      >> K ((I,dflt_simps.add):Method.modifier),
    Args.$$$ "dflt_simps" -- Scan.option Args.del -- Args.colon 
      >> K ((I,dflt_simps.del):Method.modifier)
  ];
  val heap_modifiers = [
    Args.$$$ "heap" -- Scan.option Args.add -- Args.colon 
      >> K ((I,heap_rules.add):Method.modifier),
    Args.$$$ "heap" -- Scan.option Args.del -- Args.colon 
      >> K ((I,heap_rules.del):Method.modifier)
  ];
  val decon_modifiers = [
    Args.$$$ "decon" -- Scan.option Args.add -- Args.colon 
      >> K ((I,decon_rules.add):Method.modifier),
    Args.$$$ "decon" -- Scan.option Args.del -- Args.colon 
      >> K ((I,decon_rules.del):Method.modifier)
  ];

  val eintros_modifiers = [
    Args.$$$ "eintros" -- Scan.option Args.add -- Args.colon 
      >> K ((I,eintros.add):Method.modifier),
    Args.$$$ "eintros" -- Scan.option Args.del -- Args.colon 
      >> K ((I,eintros.del):Method.modifier)
  ];


  val solve_entails_modifiers = dflt_simps_modifiers @ eintros_modifiers;

  val vcg_modifiers = 
    heap_modifiers @ decon_modifiers @ dflt_simps_modifiers;

  val sep_auto_modifiers = 
    clasimp_modifiers @ vcg_modifiers @ eintros_modifiers;

end;
*}

simproc_setup assn_simproc ("h\<Turnstile>P" | "P\<Longrightarrow>\<^sub>AQ" | "<P> c <R>" | "(P::assn) = Q") 
  = {*K Seplogic_Auto.assn_simproc_fun*}

method_setup frame_inference = {* Scan.succeed (fn ctxt => (SIMPLE_METHOD' (
  CHANGED o Seplogic_Auto.frame_inference_tac ctxt
))) *} "Seplogic: Frame inference"

method_setup solve_entails = {* 
  Method.sections Seplogic_Auto.solve_entails_modifiers >>
  (fn _ => fn ctxt => SIMPLE_METHOD' (
  CHANGED o Seplogic_Auto.solve_entails_tac ctxt
)) *} "Seplogic: Entailment Solver"

method_setup vcg = {* 
  Method.sections Seplogic_Auto.vcg_modifiers >>
  (fn _ => fn ctxt => SIMPLE_METHOD' (
  CHANGED o Seplogic_Auto.vcg_tac ctxt
)) *} "Seplogic: Verification Condition Generator"

method_setup sep_auto = 
  {* (Args.mode "nopre" -- Args.mode "nopost" -- Args.mode "plain") 
      --| Method.sections Seplogic_Auto.sep_auto_modifiers >>
  (fn ((nopre,nopost),plain) => fn ctxt => SIMPLE_METHOD' (
    CHANGED o Seplogic_Auto.sep_autosolve_tac 
      ((not nopre) andalso (not plain)) 
      ((not nopost) andalso (not plain)) ctxt
  )) *} "Seplogic: Automatic solver"

setup {* Seplogic_Auto.dflt_simps.setup *}
setup {* Seplogic_Auto.heap_rules.setup *}
setup {* Seplogic_Auto.decon_rules.setup *}
setup {* Seplogic_Auto.eintros.setup *}

lemmas [sep_dflt_simps] = split

declare deconstruct_rules[sep_decon_rules]
declare heap_rules[sep_heap_rules]

lemmas [sep_eintros] = impI conjI exI

subsection {* Semi-Automatic Reasoning *}
text {* In this section, we provide some lemmas for semi-automatic reasoning *}

text {* Forward reasoning with frame. Use @{text "frame_inference"}-method 
  to discharge second assumption. *}
lemma ent_frame_fwd:
  assumes R: "P \<Longrightarrow>\<^sub>A R"
  assumes F: "Ps \<Longrightarrow>\<^sub>A P*F"
  assumes I: "R*F \<Longrightarrow>\<^sub>A Q"
  shows "Ps \<Longrightarrow>\<^sub>A Q"
  using assms
  by (metis ent_refl ent_star_mono ent_trans)

lemma mod_frame_fwd:
  assumes M: "h\<Turnstile>Ps"
  assumes R: "P\<Longrightarrow>\<^sub>AR"
  assumes F: "Ps \<Longrightarrow>\<^sub>A P*F"
  shows "h\<Turnstile>R*F"
  using assms
  by (metis ent_star_mono entails_def)


text {* Apply precision rule with frame inference. *}
lemma prec_frame:
  assumes PREC: "\<forall>x y. (h\<Turnstile>(P x * F1) \<and>\<^sub>A (P y * F2)) \<longrightarrow> x=y"
  assumes M1: "h\<Turnstile>(R1 \<and>\<^sub>A R2)"
  assumes F1: "R1 \<Longrightarrow>\<^sub>A P x * F1"
  assumes F2: "R2 \<Longrightarrow>\<^sub>A P y * F2"
  shows "x=y"
  using assms
  by (metis entailsD mod_and_dist)

text {* Variant that is useful within induction proofs, where induction
  goes over @{text "x"} or @{text "y"} *}
lemma prec_frame':
  assumes PREC: "(h\<Turnstile>(P x * F1) \<and>\<^sub>A (P y * F2)) \<longrightarrow> x=y"
  assumes M1: "h\<Turnstile>(R1 \<and>\<^sub>A R2)"
  assumes F1: "R1 \<Longrightarrow>\<^sub>A P x * F1"
  assumes F2: "R2 \<Longrightarrow>\<^sub>A P y * F2"
  shows "x=y"
  using assms
  by (metis entailsD mod_and_dist)


lemma ent_wand_frameI:
  assumes "(Q -* R) * F \<Longrightarrow>\<^sub>A S"
  assumes "P \<Longrightarrow>\<^sub>A F * X"
  assumes "Q*X \<Longrightarrow>\<^sub>A R"
  shows "P \<Longrightarrow>\<^sub>A S"
  using assms
  by (metis ent_frame_fwd ent_wandI mult_commute)

(*<*)
subsection {* Test Cases *}

lemma "\<And>x. A x * true * Q x \<Longrightarrow>\<^sub>A true * A x * Q x"
  apply simp
  done

lemma "A * (true * B) \<Longrightarrow>\<^sub>A true * A * B"
  apply (simp)
  done
  
lemma "h\<Turnstile>true*P*true \<longleftrightarrow> h\<Turnstile>P*true"
  by simp

lemma "A * true * \<up>(b \<and> c) * true * B \<Longrightarrow>\<^sub>A \<up>b * \<up>c * true *A * B"
  by simp

lemma "\<exists>y c. \<exists>\<^sub>Ax. P x * (R x * Q y) * \<up> (b \<and> c) \<Longrightarrow>\<^sub>A (\<exists>\<^sub>Ax. \<up>b * (P x * (R x * Q y) * \<up>c))"
  apply simp
  done

lemma "A * B * (\<up>c * B * C * D * \<up>a * true * \<up>d) * (\<exists>\<^sub>Ax. E x * F * \<up>b) * true \<Longrightarrow>\<^sub>A (\<exists>\<^sub>Ax. \<up> (c \<and> a \<and> d \<and> b) *
          true * A * B * (true * B * C * D) * (E x * F))"
  apply simp
  done

lemma "<P> c <\<lambda>r. Q r * true * \<up>(b r) * true * \<up>a> 
  \<longleftrightarrow> <P> c <\<lambda>r. Q r * true * \<up>(b r \<and> a)>"
  apply simp
  done


lemma "(h\<Turnstile>((A*B*\<up>b*true*\<up>c*true) \<and>\<^sub>A (\<up>(p=q)*P*Q)))
  \<longleftrightarrow> h \<Turnstile> A * B * true \<and>\<^sub>A P * Q \<and> b \<and> c \<and> p = q"
  apply simp
  done

lemma assumes "FI_RESULT [(B, B), (A, A)] C D F" 
  shows "FI_QUERY (A*B*C) (D*B*A) F"
  apply (tactic {* Seplogic_Auto.match_frame_tac 
    (rtac @{thm ent_refl}) @{context} 1 *})
  by (rule assms)

lemma 
  assumes "FI_RESULT [(B,B), (A,A)] C emp F"
  shows "FI_QUERY (A*B*C) (B*A) F"
  apply (tactic {* Seplogic_Auto.match_frame_tac 
    (rtac @{thm ent_refl}) @{context} 1 *})
  by (rule assms)

lemma 
  assumes "FI_RESULT [(B, B), (A, A)] emp emp F"
  shows "FI_QUERY (A*B) (B*A) F"
  apply (tactic {* Seplogic_Auto.match_frame_tac 
    (rtac @{thm ent_refl}) @{context} 1 *})
  by (rule assms)

lemma 
  assumes "FI_RESULT [(A, A)] emp emp F"
  shows "FI_QUERY (A) (A) F"
  apply (tactic {* Seplogic_Auto.match_frame_tac 
    (rtac @{thm ent_refl}) @{context} 1 *})
  by (rule assms)

lemma 
  assumes "FI_RESULT [(A, A)] (B * C * D) emp F"
  shows "FI_QUERY (B*C*D*A) (A) F"
  apply (tactic {* Seplogic_Auto.match_frame_tac 
    (rtac @{thm ent_refl}) @{context} 1 *})
  by (rule assms)


schematic_lemma 
  "P1 * P2 * P3 * P4 \<Longrightarrow>\<^sub>A P3 * ?R1"
  "P1 * (P2 * (P3 * P4)) \<Longrightarrow>\<^sub>A P1 * ?R2"
  "P4 * (P2 * (P1 * P3)) \<Longrightarrow>\<^sub>A P1 * ?R2'"
  "P1 * P2 * P3 * P4 \<Longrightarrow>\<^sub>A P4 * ?R3"
  "P1 * P2 \<Longrightarrow>\<^sub>A P1 * ?R4"
  "P1 * P2 \<Longrightarrow>\<^sub>A P2 * ?R5"
  "P1 \<Longrightarrow>\<^sub>A P1 * ?R6"
  "P1 * P2 \<Longrightarrow>\<^sub>A emp * ?R7"
  by frame_inference+


lemma "\<lbrakk>A; B; C; b 17\<rbrakk> \<Longrightarrow> 
  Q 1 5 3 \<Longrightarrow>\<^sub>A (\<exists>\<^sub>Ax y z. \<exists>\<^sub>Aa. Q x y z * \<up>(b a) * \<up>(y=5))"
  by solve_entails

thm nth_rule
lemma "<P * x\<mapsto>\<^sub>a[1,2,3]> 
  do { v\<leftarrow>Array.nth x 1; return v } 
  <\<lambda>r. P * x\<mapsto>\<^sub>a[1,2,3] * \<up>(r=2)>"
  apply sep_auto
  done

(*>*)

subsection {* Quick Overview of Proof Methods *} 
  text_raw {*\label{sec:auto:overview}*}
text {*
  In this section, we give a quick overview of the available proof methods 
  and options. The most versatile proof method that we provide is
  @{text "sep_auto"}. It tries to solve the first subgoal, invoking appropriate
  proof methods as required. If it cannot solve the subgoal completely, it
  stops at the intermediate state that it could not handle any more. 

  @{text "sep_auto"} can be configured by 
  section-arguments for the simplifier, the classical reasoner, and all
  section-arguments for the verification condition generator and 
  entailment solver. Moreover, it takes an optional mode argument (mode), where
  valid modes are:
  \begin{description}
    \item[(nopre)] No preprocessing of goal. The preprocessor tries to clarify
      and simplify the goal before the main method is invoked.
    \item[(nopost)] No postprocessing of goal. The postprocessor tries to 
      solve or simplify goals left over by verification condition generation or
      entailment solving.
    \item[(plain)] Neither pre- nor postprocessing. Just applies vcg and 
      entailment solver.  
  \end{description}

  \paragraph{Entailment Solver.} The entailment solver processes goals of the
  form @{text "P \<Longrightarrow>\<^sub>A Q"}. It is invoked by the method @{text "solve_entails"}.
  It first tries to pull out pure parts of
  @{text "P"} and @{text "Q"}. This may introduce quantifiers, conjunction,
  and implication into the goal, that are eliminated by resolving with rules
  declared as @{text "sep_eintros"} (method argument: eintros[add/del]:).
  Moreover, it simplifies with rules declared as @{text "sep_dflt_simps"} 
  (section argument: @{text "dflt_simps[add/del]:"}).

  Now, @{text "P"} and @{text "Q"} should have the form @{text "X\<^sub>1*\<dots>*X\<^sub>n"}.
  Then, the frame-matcher is used to match all items of @{text "P"} with items
  of @{text "Q"}, and thus solve the implication. Matching is currently done 
  syntactically, but can instantiate schematic variables.

  Note that, by default, existential introduction is declared as 
  @{text "sep_eintros"}-rule. This introduces schematic variables, that can
  later be matched against. However, in some cases, the matching may instantiate
  the schematic variables in an undesired way. In this case, the argument 
  @{text "eintros del: exI"} should be passed to the entailment solver, and
  the existential quantifier should be instantiated manually.

  \paragraph{Frame Inference}
  The method @{text "frame_inference"} tries to solve a goal of the 
  form @{text "P\<Longrightarrow>Q*?F"}, by matching @{text "Q"} against the parts of 
  @{text "P"}, and instantiating @{text "?F"} accordingly. 
  Matching is done syntactically, possibly 
  instantiating schematic variables. @{text "P"} and @{text "Q"} should be 
  assertions separated by @{text "*"}. Note that frame inference does no 
  simplification or other kinds of normalization.

  \paragraph{Verification Condition Generator}
  The verification condition generator processes goals of the form 
  @{text "<P>c<Q>"}. It is invoked by the method @{text "vcg"}.
  First, it tries to pull out pure parts and simplifies with
  the default simplification rules. Then, it tries to resolve the goal with
  deconstruct rules (attribute: @{text "sep_decon_rules"}, 
  section argument: @{text "decon[add/del]:"}), and if this does not succeed, 
  it tries
  to resolve the goal with heap rules (attribute: @{text "sep_heap_rules"}, 
  section argument: @{text "heap[add/del]:"}), using the frame rule and 
  frame inference.
  If resolving is not possible, it also tries to apply the consequence rule to
  make the postcondition a schematic variable.
*}


(*<*)
subsection {* Hiding of internal stuff *}
hide_const (open) FI SLN
(*>*)

end
