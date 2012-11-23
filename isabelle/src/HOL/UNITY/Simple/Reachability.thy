(*  Title:      HOL/UNITY/Simple/Reachability.thy
    Author:     Tanja Vos, Cambridge University Computer Laboratory
    Copyright   2000  University of Cambridge

Reachability in Graphs.

From Chandy and Misra, "Parallel Program Design" (1989), sections 6.2
and 11.3.
*)

theory Reachability imports "../Detects" Reach begin

type_synonym edge = "vertex * vertex"

record state =
  reach :: "vertex => bool"
  nmsg  :: "edge => nat"

consts root :: "vertex"
       E :: "edge set"
       V :: "vertex set"

inductive_set REACHABLE :: "edge set"
  where
    base: "v \<in> V ==> ((v,v) \<in> REACHABLE)"
  | step: "((u,v) \<in> REACHABLE) & (v,w) \<in> E ==> ((u,w) \<in> REACHABLE)"

definition reachable :: "vertex => state set" where
  "reachable p == {s. reach s p}"

definition nmsg_eq :: "nat => edge  => state set" where
  "nmsg_eq k == %e. {s. nmsg s e = k}"

definition nmsg_gt :: "nat => edge  => state set" where
  "nmsg_gt k  == %e. {s. k < nmsg s e}"

definition nmsg_gte :: "nat => edge => state set" where
  "nmsg_gte k == %e. {s. k \<le> nmsg s e}"

definition nmsg_lte  :: "nat => edge => state set" where
  "nmsg_lte k  == %e. {s. nmsg s e \<le> k}"

definition final :: "state set" where
  "final == (\<Inter>v\<in>V. reachable v <==> {s. (root, v) \<in> REACHABLE}) \<inter> 
            (INTER E (nmsg_eq 0))"

axiomatization
where
    Graph1: "root \<in> V" and

    Graph2: "(v,w) \<in> E ==> (v \<in> V) & (w \<in> V)" and

    MA1:  "F \<in> Always (reachable root)" and

    MA2:  "v \<in> V ==> F \<in> Always (- reachable v \<union> {s. ((root,v) \<in> REACHABLE)})" and

    MA3:  "[|v \<in> V;w \<in> V|] ==> F \<in> Always (-(nmsg_gt 0 (v,w)) \<union> (reachable v))" and

    MA4:  "(v,w) \<in> E ==> 
           F \<in> Always (-(reachable v) \<union> (nmsg_gt 0 (v,w)) \<union> (reachable w))" and

    MA5:  "[|v \<in> V; w \<in> V|] 
           ==> F \<in> Always (nmsg_gte 0 (v,w) \<inter> nmsg_lte (Suc 0) (v,w))" and

    MA6:  "[|v \<in> V|] ==> F \<in> Stable (reachable v)" and

    MA6b: "[|v \<in> V;w \<in> W|] ==> F \<in> Stable (reachable v \<inter> nmsg_lte k (v,w))" and

    MA7:  "[|v \<in> V;w \<in> V|] ==> F \<in> UNIV LeadsTo nmsg_eq 0 (v,w)"


lemmas E_imp_in_V_L = Graph2 [THEN conjunct1]
lemmas E_imp_in_V_R = Graph2 [THEN conjunct2]

lemma lemma2:
     "(v,w) \<in> E ==> F \<in> reachable v LeadsTo nmsg_eq 0 (v,w) \<inter> reachable v"
apply (rule MA7 [THEN PSP_Stable, THEN LeadsTo_weaken_L])
apply (rule_tac [3] MA6)
apply (auto simp add: E_imp_in_V_L E_imp_in_V_R)
done

lemma Induction_base: "(v,w) \<in> E ==> F \<in> reachable v LeadsTo reachable w"
apply (rule MA4 [THEN Always_LeadsTo_weaken])
apply (rule_tac [2] lemma2)
apply (auto simp add: nmsg_eq_def nmsg_gt_def)
done

lemma REACHABLE_LeadsTo_reachable:
     "(v,w) \<in> REACHABLE ==> F \<in> reachable v LeadsTo reachable w"
apply (erule REACHABLE.induct)
apply (rule subset_imp_LeadsTo, blast)
apply (blast intro: LeadsTo_Trans Induction_base)
done

lemma Detects_part1: "F \<in> {s. (root,v) \<in> REACHABLE} LeadsTo reachable v"
apply (rule single_LeadsTo_I)
apply (simp split add: split_if_asm)
apply (rule MA1 [THEN Always_LeadsToI])
apply (erule REACHABLE_LeadsTo_reachable [THEN LeadsTo_weaken_L], auto)
done


lemma Reachability_Detected: 
     "v \<in> V ==> F \<in> (reachable v) Detects {s. (root,v) \<in> REACHABLE}"
apply (unfold Detects_def, auto)
 prefer 2 apply (blast intro: MA2 [THEN Always_weaken])
apply (rule Detects_part1 [THEN LeadsTo_weaken_L], blast)
done


lemma LeadsTo_Reachability:
     "v \<in> V ==> F \<in> UNIV LeadsTo (reachable v <==> {s. (root,v) \<in> REACHABLE})"
by (erule Reachability_Detected [THEN Detects_Imp_LeadstoEQ])


(* ------------------------------------ *)

(* Some lemmas about <==> *)

lemma Eq_lemma1: 
     "(reachable v <==> {s. (root,v) \<in> REACHABLE}) =  
      {s. ((s \<in> reachable v) = ((root,v) \<in> REACHABLE))}"
by (unfold Equality_def, blast)


lemma Eq_lemma2: 
     "(reachable v <==> (if (root,v) \<in> REACHABLE then UNIV else {})) =  
      {s. ((s \<in> reachable v) = ((root,v) \<in> REACHABLE))}"
by (unfold Equality_def, auto)

(* ------------------------------------ *)


(* Some lemmas about final (I don't need all of them!)  *)

lemma final_lemma1: 
     "(\<Inter>v \<in> V. \<Inter>w \<in> V. {s. ((s \<in> reachable v) = ((root,v) \<in> REACHABLE)) &  
                              s \<in> nmsg_eq 0 (v,w)})  
      \<subseteq> final"
apply (unfold final_def Equality_def, auto)
apply (frule E_imp_in_V_R)
apply (frule E_imp_in_V_L, blast)
done

lemma final_lemma2: 
 "E\<noteq>{}  
  ==> (\<Inter>v \<in> V. \<Inter>e \<in> E. {s. ((s \<in> reachable v) = ((root,v) \<in> REACHABLE))}  
                           \<inter> nmsg_eq 0 e)    \<subseteq>  final"
apply (unfold final_def Equality_def)
apply (auto split add: split_if_asm)
apply (frule E_imp_in_V_L, blast)
done

lemma final_lemma3:
     "E\<noteq>{}  
      ==> (\<Inter>v \<in> V. \<Inter>e \<in> E.  
           (reachable v <==> {s. (root,v) \<in> REACHABLE}) \<inter> nmsg_eq 0 e)  
          \<subseteq> final"
apply (frule final_lemma2)
apply (simp (no_asm_use) add: Eq_lemma2)
done


lemma final_lemma4:
     "E\<noteq>{}  
      ==> (\<Inter>v \<in> V. \<Inter>e \<in> E.  
           {s. ((s \<in> reachable v) = ((root,v) \<in> REACHABLE))} \<inter> nmsg_eq 0 e)  
          = final"
apply (rule subset_antisym)
apply (erule final_lemma2)
apply (unfold final_def Equality_def, blast)
done

lemma final_lemma5:
     "E\<noteq>{}  
      ==> (\<Inter>v \<in> V. \<Inter>e \<in> E.  
           ((reachable v) <==> {s. (root,v) \<in> REACHABLE}) \<inter> nmsg_eq 0 e)  
          = final"
apply (frule final_lemma4)
apply (simp (no_asm_use) add: Eq_lemma2)
done


lemma final_lemma6:
     "(\<Inter>v \<in> V. \<Inter>w \<in> V.  
       (reachable v <==> {s. (root,v) \<in> REACHABLE}) \<inter> nmsg_eq 0 (v,w))  
      \<subseteq> final"
apply (simp (no_asm) add: Eq_lemma2 Int_def)
apply (rule final_lemma1)
done


lemma final_lemma7: 
     "final =  
      (\<Inter>v \<in> V. \<Inter>w \<in> V.  
       ((reachable v) <==> {s. (root,v) \<in> REACHABLE}) \<inter> 
       (-{s. (v,w) \<in> E} \<union> (nmsg_eq 0 (v,w))))"
apply (unfold final_def)
apply (rule subset_antisym, blast)
apply (auto split add: split_if_asm)
apply (blast dest: E_imp_in_V_L E_imp_in_V_R)+
done

(* ------------------------------------ *)


(* ------------------------------------ *)

(* Stability theorems *)
lemma not_REACHABLE_imp_Stable_not_reachable:
     "[| v \<in> V; (root,v) \<notin> REACHABLE |] ==> F \<in> Stable (- reachable v)"
apply (drule MA2 [THEN AlwaysD], auto)
done

lemma Stable_reachable_EQ_R:
     "v \<in> V ==> F \<in> Stable (reachable v <==> {s. (root,v) \<in> REACHABLE})"
apply (simp (no_asm) add: Equality_def Eq_lemma2)
apply (blast intro: MA6 not_REACHABLE_imp_Stable_not_reachable)
done


lemma lemma4: 
     "((nmsg_gte 0 (v,w) \<inter> nmsg_lte (Suc 0) (v,w)) \<inter> 
       (- nmsg_gt 0 (v,w) \<union> A))  
      \<subseteq> A \<union> nmsg_eq 0 (v,w)"
apply (unfold nmsg_gte_def nmsg_lte_def nmsg_gt_def nmsg_eq_def, auto)
done


lemma lemma5: 
     "reachable v \<inter> nmsg_eq 0 (v,w) =  
      ((nmsg_gte 0 (v,w) \<inter> nmsg_lte (Suc 0) (v,w)) \<inter> 
       (reachable v \<inter> nmsg_lte 0 (v,w)))"
by (unfold nmsg_gte_def nmsg_lte_def nmsg_gt_def nmsg_eq_def, auto)

lemma lemma6: 
     "- nmsg_gt 0 (v,w) \<union> reachable v \<subseteq> nmsg_eq 0 (v,w) \<union> reachable v"
apply (unfold nmsg_gte_def nmsg_lte_def nmsg_gt_def nmsg_eq_def, auto)
done

lemma Always_reachable_OR_nmsg_0:
     "[|v \<in> V; w \<in> V|] ==> F \<in> Always (reachable v \<union> nmsg_eq 0 (v,w))"
apply (rule Always_Int_I [OF MA5 MA3, THEN Always_weaken])
apply (rule_tac [5] lemma4, auto)
done

lemma Stable_reachable_AND_nmsg_0:
     "[|v \<in> V; w \<in> V|] ==> F \<in> Stable (reachable v \<inter> nmsg_eq 0 (v,w))"
apply (subst lemma5)
apply (blast intro: MA5 Always_imp_Stable [THEN Stable_Int] MA6b)
done

lemma Stable_nmsg_0_OR_reachable:
     "[|v \<in> V; w \<in> V|] ==> F \<in> Stable (nmsg_eq 0 (v,w) \<union> reachable v)"
by (blast intro!: Always_weaken [THEN Always_imp_Stable] lemma6 MA3)

lemma not_REACHABLE_imp_Stable_not_reachable_AND_nmsg_0:
     "[| v \<in> V; w \<in> V; (root,v) \<notin> REACHABLE |]  
      ==> F \<in> Stable (- reachable v \<inter> nmsg_eq 0 (v,w))"
apply (rule Stable_Int [OF MA2 [THEN Always_imp_Stable] 
                           Stable_nmsg_0_OR_reachable, 
            THEN Stable_eq])
   prefer 4 apply blast
apply auto
done

lemma Stable_reachable_EQ_R_AND_nmsg_0:
     "[| v \<in> V; w \<in> V |]  
      ==> F \<in> Stable ((reachable v <==> {s. (root,v) \<in> REACHABLE}) \<inter> 
                      nmsg_eq 0 (v,w))"
by (simp add: Equality_def Eq_lemma2  Stable_reachable_AND_nmsg_0
              not_REACHABLE_imp_Stable_not_reachable_AND_nmsg_0)



(* ------------------------------------ *)


(* LeadsTo final predicate (Exercise 11.2 page 274) *)

lemma UNIV_lemma: "UNIV \<subseteq> (\<Inter>v \<in> V. UNIV)"
by blast

lemmas UNIV_LeadsTo_completion = 
    LeadsTo_weaken_L [OF Finite_stable_completion UNIV_lemma]

lemma LeadsTo_final_E_empty: "E={} ==> F \<in> UNIV LeadsTo final"
apply (unfold final_def, simp)
apply (rule UNIV_LeadsTo_completion)
  apply safe
 apply (erule LeadsTo_Reachability [simplified])
apply (drule Stable_reachable_EQ_R, simp)
done


lemma Leadsto_reachability_AND_nmsg_0:
     "[| v \<in> V; w \<in> V |]  
      ==> F \<in> UNIV LeadsTo  
             ((reachable v <==> {s. (root,v): REACHABLE}) \<inter> nmsg_eq 0 (v,w))"
apply (rule LeadsTo_Reachability [THEN LeadsTo_Trans], blast)
apply (subgoal_tac
         "F \<in> (reachable v <==> {s. (root,v) \<in> REACHABLE}) \<inter> 
              UNIV LeadsTo (reachable v <==> {s. (root,v) \<in> REACHABLE}) \<inter> 
              nmsg_eq 0 (v,w) ")
apply simp
apply (rule PSP_Stable2)
apply (rule MA7)
apply (rule_tac [3] Stable_reachable_EQ_R, auto)
done

lemma LeadsTo_final_E_NOT_empty: "E\<noteq>{} ==> F \<in> UNIV LeadsTo final"
apply (rule LeadsTo_weaken_L [OF LeadsTo_weaken_R UNIV_lemma])
apply (rule_tac [2] final_lemma6)
apply (rule Finite_stable_completion)
  apply blast
 apply (rule UNIV_LeadsTo_completion)
   apply (blast intro: Stable_INT Stable_reachable_EQ_R_AND_nmsg_0
                    Leadsto_reachability_AND_nmsg_0)+
done

lemma LeadsTo_final: "F \<in> UNIV LeadsTo final"
apply (cases "E={}")
 apply (rule_tac [2] LeadsTo_final_E_NOT_empty)
apply (rule LeadsTo_final_E_empty, auto)
done

(* ------------------------------------ *)

(* Stability of final (Exercise 11.2 page 274) *)

lemma Stable_final_E_empty: "E={} ==> F \<in> Stable final"
apply (unfold final_def, simp)
apply (rule Stable_INT)
apply (drule Stable_reachable_EQ_R, simp)
done


lemma Stable_final_E_NOT_empty: "E\<noteq>{} ==> F \<in> Stable final"
apply (subst final_lemma7)
apply (rule Stable_INT)
apply (rule Stable_INT)
apply (simp (no_asm) add: Eq_lemma2)
apply safe
apply (rule Stable_eq)
apply (subgoal_tac [2]
     "({s. (s \<in> reachable v) = ((root,v) \<in> REACHABLE) } \<inter> nmsg_eq 0 (v,w)) = 
      ({s. (s \<in> reachable v) = ( (root,v) \<in> REACHABLE) } \<inter> (- UNIV \<union> nmsg_eq 0 (v,w)))")
prefer 2 apply blast
prefer 2 apply blast 
apply (rule Stable_reachable_EQ_R_AND_nmsg_0
            [simplified Eq_lemma2 Collect_const])
apply (blast, blast)
apply (rule Stable_eq)
 apply (rule Stable_reachable_EQ_R [simplified Eq_lemma2 Collect_const])
 apply simp
apply (subgoal_tac 
        "({s. (s \<in> reachable v) = ((root,v) \<in> REACHABLE) }) = 
         ({s. (s \<in> reachable v) = ( (root,v) \<in> REACHABLE) } Int
              (- {} \<union> nmsg_eq 0 (v,w)))")
apply blast+
done

lemma Stable_final: "F \<in> Stable final"
apply (cases "E={}")
 prefer 2 apply (blast intro: Stable_final_E_NOT_empty)
apply (blast intro: Stable_final_E_empty)
done

end

