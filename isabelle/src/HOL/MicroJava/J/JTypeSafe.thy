(*  Title:      HOL/MicroJava/J/JTypeSafe.thy
    Author:     David von Oheimb, Technische Universitaet Muenchen
*)

header {* \isaheader{Type Safety Proof} *}

theory JTypeSafe imports Eval Conform begin

declare split_beta [simp]

lemma NewC_conforms: 
"[|h a = None; (x,(h, l))::\<preceq>(G, lT); wf_prog wf_mb G; is_class G C|] ==>  
  (x,(h(a\<mapsto>(C,(init_vars (fields (G,C))))), l))::\<preceq>(G, lT)"
apply( erule conforms_upd_obj)
apply(  unfold oconf_def)
apply(  auto dest!: fields_is_type simp add: wf_prog_ws_prog)
done


lemma Cast_conf: 
 "[| wf_prog wf_mb G; G,h\<turnstile>v::\<preceq>CC; G\<turnstile>CC \<preceq>? Class D; cast_ok G D h v|]  
  ==> G,h\<turnstile>v::\<preceq>Class D"
apply (case_tac "CC")
apply simp
apply (case_tac "ref_ty")
apply (clarsimp simp add: conf_def)
apply simp
apply (ind_cases "G \<turnstile> Class cname \<preceq>? Class D" for cname, simp)
apply (rule conf_widen, assumption+) apply (erule widen.subcls)

apply (unfold cast_ok_def)
apply( case_tac "v = Null")
apply(  simp)
apply(  clarify)
apply( drule (1) non_npD)
apply( auto intro!: conf_AddrI simp add: obj_ty_def)
done


lemma FAcc_type_sound: 
"[| wf_prog wf_mb G; field (G,C) fn = Some (fd, ft); (x,(h,l))::\<preceq>(G,lT);  
  x' = None --> G,h\<turnstile>a'::\<preceq> Class C; np a' x' = None |] ==>  
  G,h\<turnstile>the (snd (the (h (the_Addr a'))) (fn, fd))::\<preceq>ft"
apply( drule np_NoneD)
apply( erule conjE)
apply( erule (1) notE impE)
apply( drule non_np_objD)
apply   auto
apply( drule conforms_heapD [THEN hconfD])
apply(  assumption)
apply (frule wf_prog_ws_prog)
apply( drule (2) widen_cfs_fields)
apply( drule (1) oconf_objD)
apply auto
done

lemma FAss_type_sound: 
 "[| wf_prog wf_mb G; a = the_Addr a'; (c, fs) = the (h a);  
    (G, lT)\<turnstile>v::T'; G\<turnstile>T'\<preceq>ft;  
    (G, lT)\<turnstile>aa::Class C;  
    field (G,C) fn = Some (fd, ft); h''\<le>|h';  
    x' = None --> G,h'\<turnstile>a'::\<preceq> Class C; h'\<le>|h;  
    Norm (h, l)::\<preceq>(G, lT); G,h\<turnstile>x::\<preceq>T'; np a' x' = None|] ==>  
  h''\<le>|h(a\<mapsto>(c,(fs((fn,fd)\<mapsto>x)))) \<and>   
  Norm(h(a\<mapsto>(c,(fs((fn,fd)\<mapsto>x)))), l)::\<preceq>(G, lT) \<and>   
  G,h(a\<mapsto>(c,(fs((fn,fd)\<mapsto>x))))\<turnstile>x::\<preceq>T'"
apply( drule np_NoneD)
apply( erule conjE)
apply( simp)
apply( drule non_np_objD)
apply(  assumption)
apply( clarify)
apply( simp (no_asm_use))
apply( frule (1) hext_objD)
apply( erule exE)
apply( simp)
apply( clarify)
apply( rule conjI)
apply(  fast elim: hext_trans hext_upd_obj)
apply( rule conjI)
prefer 2
apply(  fast elim: conf_upd_obj [THEN iffD2])

apply( rule conforms_upd_obj)
apply   auto
apply(  rule_tac [2] hextI)
prefer 2
apply(  force)
apply( rule oconf_hext)
apply(  erule_tac [2] hext_upd_obj)
apply (frule wf_prog_ws_prog)
apply( drule (2) widen_cfs_fields)
apply( rule oconf_obj [THEN iffD2])
apply( simp (no_asm))
apply( intro strip)
apply( case_tac "(aaa, b) = (fn, fd)")
apply(  simp)
apply(  fast intro: conf_widen)
apply( fast dest: conforms_heapD [THEN hconfD] oconf_objD)
done



lemma Call_lemma2: "[| wf_prog wf_mb G; list_all2 (conf G h) pvs pTs;  
   list_all2 (\<lambda>T T'. G\<turnstile>T\<preceq>T') pTs pTs'; wf_mhead G (mn,pTs') rT;  
  length pTs' = length pns; distinct pns;  
  Ball (set lvars) (split (\<lambda>vn. is_type G))  
  |] ==> G,h\<turnstile>init_vars lvars(pns[\<mapsto>]pvs)[::\<preceq>]map_of lvars(pns[\<mapsto>]pTs')"
apply (unfold wf_mhead_def)
apply( clarsimp)
apply( rule lconf_ext_list)
apply(    rule Ball_set_table [THEN lconf_init_vars])
apply(    force)
apply(   assumption)
apply(  assumption)
apply( erule (2) conf_list_gext_widen)
done

lemma Call_type_sound: 
 "[| wf_java_prog G; a' \<noteq> Null; Norm (h, l)::\<preceq>(G, lT); class G C = Some y;  
     max_spec G C (mn,pTsa) = {((mda,rTa),pTs')}; xc\<le>|xh; xh\<le>|h;  
     list_all2 (conf G h) pvs pTsa; 
     (md, rT, pns, lvars, blk, res) =  
               the (method (G,fst (the (h (the_Addr a')))) (mn, pTs')); 
  \<forall>lT. (np a' None, h, init_vars lvars(pns[\<mapsto>]pvs)(This\<mapsto>a'))::\<preceq>(G, lT) -->  
  (G, lT)\<turnstile>blk\<surd> -->  h\<le>|xi \<and>  (xcptb, xi, xl)::\<preceq>(G, lT);  
  \<forall>lT. (xcptb,xi, xl)::\<preceq>(G, lT) --> (\<forall>T. (G, lT)\<turnstile>res::T -->  
          xi\<le>|h' \<and> (x',h', xj)::\<preceq>(G, lT) \<and> (x' = None --> G,h'\<turnstile>v::\<preceq>T));  
  G,xh\<turnstile>a'::\<preceq> Class C
  |] ==>  
  xc\<le>|h' \<and> (x',(h', l))::\<preceq>(G, lT) \<and>  (x' = None --> G,h'\<turnstile>v::\<preceq>rTa)"
apply( drule max_spec2mheads)
apply( clarify)
apply( drule (2) non_np_objD')
apply( clarsimp)
apply( frule (1) hext_objD)
apply( clarsimp)
apply( drule (3) Call_lemma)
apply( clarsimp simp add: wf_java_mdecl_def)
apply( erule_tac V = "method ?sig ?x = ?y" in thin_rl)
apply( drule spec, erule impE,  erule_tac [2] notE impE, tactic "assume_tac 2")
apply(  rule conformsI)
apply(   erule conforms_heapD)
apply(  rule lconf_ext)
apply(   force elim!: Call_lemma2)
apply(  erule conf_hext, erule (1) conf_obj_AddrI)
apply( erule_tac V = "?E\<turnstile>?blk\<surd>" in thin_rl) 
apply (simp add: conforms_def)

apply( erule conjE)
apply( drule spec, erule (1) impE)
apply( drule spec, erule (1) impE)
apply( erule_tac V = "?E\<turnstile>res::?rT" in thin_rl)
apply( clarify)
apply( rule conjI)
apply(  fast intro: hext_trans)
apply( rule conjI)
apply(  rule_tac [2] impI)
apply(  erule_tac [2] notE impE, tactic "assume_tac 2")
apply(  frule_tac [2] conf_widen)
apply(    tactic "assume_tac 4")
apply(   tactic "assume_tac 2")
prefer 2
apply(  fast elim!: widen_trans)
apply (rule conforms_xcpt_change)
apply( rule conforms_hext) apply assumption
apply(  erule (1) hext_trans)
apply( erule conforms_heapD)
apply (simp add: conforms_def)
done



declare split_if [split del]
declare fun_upd_apply [simp del]
declare fun_upd_same [simp]
declare wf_prog_ws_prog [simp]

ML{*
val forward_hyp_tac = ALLGOALS (TRY o (EVERY' [dtac spec, mp_tac,
  (mp_tac ORELSE' (dtac spec THEN' mp_tac)), REPEAT o (etac conjE)]))
*}


theorem eval_evals_exec_type_sound: 
"wf_java_prog G ==>  
  (G\<turnstile>(x,(h,l)) -e  \<succ>v  -> (x', (h',l')) -->  
      (\<forall>lT.   (x,(h ,l ))::\<preceq>(G,lT) --> (\<forall>T . (G,lT)\<turnstile>e  :: T -->  
      h\<le>|h' \<and> (x',(h',l'))::\<preceq>(G,lT) \<and> (x'=None --> G,h'\<turnstile>v  ::\<preceq> T )))) \<and>  
  (G\<turnstile>(x,(h,l)) -es[\<succ>]vs-> (x', (h',l')) -->  
      (\<forall>lT.   (x,(h ,l ))::\<preceq>(G,lT) --> (\<forall>Ts. (G,lT)\<turnstile>es[::]Ts -->  
      h\<le>|h' \<and> (x',(h',l'))::\<preceq>(G,lT) \<and> (x'=None --> list_all2 (\<lambda>v T. G,h'\<turnstile>v::\<preceq>T) vs Ts)))) \<and>  
  (G\<turnstile>(x,(h,l)) -c       -> (x', (h',l')) -->  
      (\<forall>lT.   (x,(h ,l ))::\<preceq>(G,lT) -->       (G,lT)\<turnstile>c  \<surd> -->  
      h\<le>|h' \<and> (x',(h',l'))::\<preceq>(G,lT)))"
apply( rule eval_evals_exec_induct)
apply( unfold c_hupd_def)

-- "several simplifications, XcptE, XcptEs, XcptS, Skip, Nil??"
apply( simp_all)
apply( tactic "ALLGOALS strip_tac")
apply( tactic {* ALLGOALS (eresolve_tac [@{thm ty_expr.cases}, @{thm ty_exprs.cases}, @{thm wt_stmt.cases}]
                 THEN_ALL_NEW (full_simp_tac (global_simpset_of @{theory Conform}))) *})
apply(tactic "ALLGOALS (EVERY' [REPEAT o (etac conjE), REPEAT o hyp_subst_tac])")

-- "Level 7"
-- "15 NewC"
apply (drule sym)
apply( drule new_AddrD)
apply( erule disjE)
prefer 2
apply(  simp (no_asm_simp))
apply (rule conforms_xcpt_change, assumption) 
apply (simp (no_asm_simp) add: xconf_def)
apply( clarsimp)
apply( rule conjI)
apply(  force elim!: NewC_conforms)
apply( rule conf_obj_AddrI)
apply(  rule_tac [2] rtrancl.rtrancl_refl)
apply( simp (no_asm))

-- "for Cast"
defer 1

-- "14 Lit"
apply( erule conf_litval)

-- "13 BinOp"
apply (tactic "forward_hyp_tac")
apply (tactic "forward_hyp_tac")
apply( rule conjI, erule (1) hext_trans)
apply( erule conjI)
apply( clarsimp)
apply( drule eval_no_xcpt)
apply( simp split add: binop.split)

-- "12 LAcc"
apply simp
apply( fast elim: conforms_localD [THEN lconfD])

-- "for FAss"
apply( tactic {* EVERY'[eresolve_tac [@{thm ty_expr.cases}, @{thm ty_exprs.cases}, @{thm wt_stmt.cases}] 
       THEN_ALL_NEW (full_simp_tac @{simpset}), REPEAT o (etac conjE), hyp_subst_tac] 3*})

-- "for if"
apply( tactic {* (Induct_Tacs.case_tac @{context} "the_Bool v" THEN_ALL_NEW
  (asm_full_simp_tac @{simpset})) 7*})

apply (tactic "forward_hyp_tac")

-- "11+1 if"
prefer 7
apply(  fast intro: hext_trans)
prefer 7
apply(  fast intro: hext_trans)

-- "10 Expr"
prefer 6
apply( fast)

-- "9 ???"
apply( simp_all)

-- "8 Cast"
prefer 8
apply (rule conjI)
  apply (fast intro: conforms_xcpt_change xconf_raise_if)

  apply clarify
  apply (drule raise_if_NoneD)
  apply (clarsimp)
  apply (rule Cast_conf)
  apply assumption+


-- "7 LAss"
apply (fold fun_upd_def)
apply( tactic {* (eresolve_tac [@{thm ty_expr.cases}, @{thm ty_exprs.cases}, @{thm wt_stmt.cases}] 
                 THEN_ALL_NEW (full_simp_tac @{simpset})) 1 *})
apply (intro strip)
apply (case_tac E)
apply (simp)
apply( blast intro: conforms_upd_local conf_widen)

-- "6 FAcc"
apply (rule conjI) 
  apply (simp add: np_def)
  apply (fast intro: conforms_xcpt_change xconf_raise_if)
apply( fast elim!: FAcc_type_sound)

-- "5 While"
prefer 5
apply(erule_tac V = "?a \<longrightarrow> ?b" in thin_rl)
apply(drule (1) ty_expr_ty_exprs_wt_stmt.Loop)
apply(force elim: hext_trans)

apply (tactic "forward_hyp_tac")

-- "4 Cond"
prefer 4
apply (case_tac "the_Bool v")
apply simp
apply( fast dest: evals_no_xcpt intro: conf_hext hext_trans)
apply simp
apply( fast dest: evals_no_xcpt intro: conf_hext hext_trans)

-- "3 ;;"
prefer 3
apply( fast dest: evals_no_xcpt intro: conf_hext hext_trans)


-- "2 FAss"
apply (subgoal_tac "(np a' x1, aa, ba) ::\<preceq> (G, lT)")
  prefer 2
  apply (simp add: np_def)
  apply (fast intro: conforms_xcpt_change xconf_raise_if)
apply( case_tac "x2")
  -- "x2 = None"
  apply (simp)
  apply (tactic forward_hyp_tac, clarify)
  apply( drule eval_no_xcpt)
  apply( erule FAss_type_sound, rule HOL.refl, assumption+)
  -- "x2 = Some a"
  apply (  simp (no_asm_simp))
  apply(  fast intro: hext_trans)


apply( tactic prune_params_tac)
-- "Level 52"

-- "1 Call"
apply( case_tac "x")
prefer 2
apply(  clarsimp)
apply(  drule exec_xcpt)
apply(  simp)
apply(  drule_tac eval_xcpt)
apply(  simp)
apply(  fast elim: hext_trans)
apply( clarify)
apply( drule evals_no_xcpt)
apply( simp)
apply( case_tac "a' = Null")
apply(  simp)
apply(  drule exec_xcpt)
apply(  simp)
apply(  drule eval_xcpt)
apply(  simp)
apply (rule conjI)
  apply(  fast elim: hext_trans)
  apply (rule conforms_xcpt_change, assumption) 
  apply (simp (no_asm_simp) add: xconf_def)
apply(clarsimp)

apply( drule ty_expr_is_type, simp)
apply(clarsimp)
apply(unfold is_class_def)
apply(clarsimp)

apply(rule Call_type_sound);
prefer 11
apply blast
apply (simp (no_asm_simp))+ 

done


lemma eval_type_sound: "!!E s s'.  
  [| wf_java_prog G; G\<turnstile>(x,s) -e\<succ>v -> (x',s'); (x,s)::\<preceq>E; E\<turnstile>e::T; G=prg E |]  
  ==> (x',s')::\<preceq>E \<and> (x'=None --> G,heap s'\<turnstile>v::\<preceq>T) \<and> heap s \<le>| heap s'"
apply (simp (no_asm_simp) only: split_tupled_all)
apply (drule eval_evals_exec_type_sound [THEN conjunct1, THEN mp, THEN spec, THEN mp])
apply auto
done


lemma evals_type_sound: "!!E s s'.  
  [| wf_java_prog G; G\<turnstile>(x,s) -es[\<succ>]vs -> (x',s'); (x,s)::\<preceq>E; E\<turnstile>es[::]Ts; G=prg E |]  
  ==> (x',s')::\<preceq>E \<and> (x'=None --> (list_all2 (\<lambda>v T. G,heap s'\<turnstile>v::\<preceq>T) vs Ts)) \<and> heap s \<le>| heap s'"
apply (simp (no_asm_simp) only: split_tupled_all)
apply (drule eval_evals_exec_type_sound [THEN conjunct2, THEN conjunct1, THEN mp, THEN spec, THEN mp])
apply auto
done

lemma exec_type_sound: "!!E s s'.  
  \<lbrakk> wf_java_prog G; G\<turnstile>(x,s) -s0-> (x',s'); (x,s)::\<preceq>E; E\<turnstile>s0\<surd>; G=prg E \<rbrakk>
  \<Longrightarrow> (x',s')::\<preceq>E \<and> heap s \<le>| heap s'"
apply( simp (no_asm_simp) only: split_tupled_all)
apply (drule eval_evals_exec_type_sound 
             [THEN conjunct2, THEN conjunct2, THEN mp, THEN spec, THEN mp])
apply   auto
done

theorem all_methods_understood: 
"[|G=prg E; wf_java_prog G; G\<turnstile>(x,s) -e\<succ>a'-> Norm s'; a' \<noteq> Null; 
          (x,s)::\<preceq>E; E\<turnstile>e::Class C; method (G,C) sig \<noteq> None|] ==>  
  method (G,fst (the (heap s' (the_Addr a')))) sig \<noteq> None"
apply (frule eval_type_sound, assumption+)
apply(clarsimp)
apply( frule widen_methd)
apply assumption
prefer 2
apply(  fast)
apply( drule non_npD)
apply auto
done

declare split_beta [simp del]
declare fun_upd_apply [simp]
declare wf_prog_ws_prog [simp del]

end

