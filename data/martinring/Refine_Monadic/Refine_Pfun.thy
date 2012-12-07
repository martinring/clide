header {* \isaheader{Partial Function Package Setup} *}
theory Refine_Pfun
imports Refine_Basic Refine_Det
begin

text {*
  In this theory, we set up the partial function package to be used 
  with our refinement framework.
*}

subsection {* Nondeterministic Result Monad *}

interpretation nrec!:
  partial_function_definitions "op \<le>" "Sup::'a nres set \<Rightarrow> 'a nres"
  by unfold_locales (auto simp add: Sup_upper Sup_least)

lemma nrec_admissible: "nrec.admissible (\<lambda>(f::'a \<Rightarrow> 'b nres).
  (\<forall>x0. f x0 \<le> SPEC (P x0)))"
  apply (rule ccpo.admissibleI[OF nrec.ccpo])
  apply (unfold fun_lub_def)
  apply (intro allI impI)
  apply (rule Sup_least)
  apply auto
  done

(*
lemma fixp_induct_nrec:
  fixes F :: "'c \<Rightarrow> 'c" and
    U :: "'c \<Rightarrow> 'b \<Rightarrow> 'a nres" and
    C :: "('b \<Rightarrow> 'a nres) \<Rightarrow> 'c" and
    P :: "'b \<Rightarrow> 'a \<Rightarrow> bool"
  assumes mono: "\<And>x. nrec_mono (\<lambda>f. U (F (C f)) x)"
  assumes eq: "f \<equiv> C (nrec_ffix (\<lambda>f. U (F (C f))))"
  assumes inverse2: "\<And>f. U (C f) = f"
  assumes step: "\<And>f x. (\<And>x. U f x \<le> SPEC (P x)) \<Longrightarrow> U (F f) x \<le> SPEC (P x)"
  assumes defined: "RETURN y \<le> U f x"
  shows "U f x \<le> SPEC (P x)"
  using step defined 
    nrec.fixp_induct_uc[of U F C, OF mono eq inverse2 nrec_admissible]
  by blast

lemma fixp_induct_nrec':
  fixes F :: "'c \<Rightarrow> 'c" and
    U :: "'c \<Rightarrow> 'b \<Rightarrow> 'a nres" and
    C :: "('b \<Rightarrow> 'a nres) \<Rightarrow> 'c" and
    P :: "'b \<Rightarrow> 'a \<Rightarrow> bool"
  assumes mono: "\<And>x. nrec_mono (\<lambda>f. U (F (C f)) x)"
  assumes eq: "f \<equiv> C (nrec_ffix (\<lambda>f. U (F (C f))))"
  assumes inverse2: "\<And>f. U (C f) = f"
  assumes step: "\<And>f x0. (\<And>x0. U f x0 \<le> SPEC (P x0)) 
    \<Longrightarrow> U (F f) x0 \<le> SPEC (P x0)"
  assumes defined: "RETURN y \<le> U f x"
  shows "P x y"
proof -
  note defined
  also have "\<forall>x0. U f x0 \<le> SPEC (P x0)"
    apply (rule nrec.fixp_induct_uc[of U F C, OF mono eq inverse2 
      nrec_admissible])
    using step by blast
  hence "U f x \<le> SPEC (P x)" by simp
  finally show "P x y" by auto
qed
*)    
(* TODO/FIXME: Induction rule seems not to work here ! 
    Function package expects induction rule where conclusion is a binary 
    predicate as free variable.
*)

declaration {* Partial_Function.init "nrec" @{term nrec.fixp_fun}
  @{term nrec.mono_body} @{thm nrec.fixp_rule_uc} 
  (*SOME @{thm fixp_induct_nrec'}*) NONE *}

lemma bind_mono_pfun[partial_function_mono]:
  "\<lbrakk> nrec.mono_body B; \<And>y. nrec.mono_body (\<lambda>f. C y f) \<rbrakk> \<Longrightarrow> 
     nrec.mono_body (\<lambda>f. bind (B f) (\<lambda>y. C y f))"
  apply rule
  apply (rule Refine_Basic.bind_mono)
  apply (blast dest: monotoneD)+
  done



subsection {* Deterministic Result Monad *}

interpretation drec!:
  partial_function_definitions "op \<le>" "Sup::'a dres set \<Rightarrow> 'a dres"
  by unfold_locales (auto simp add: Sup_upper Sup_least)

lemma drec_admissible: "drec.admissible (\<lambda>(f::'a \<Rightarrow> 'b dres).
  (\<forall>x. P x \<longrightarrow> 
    (f x \<noteq> dFAIL \<and> 
    (\<forall>r. f x = dRETURN r \<longrightarrow> Q x r))))"
proof -
  have [simp]: "fun_ord (op \<le>::'b dres \<Rightarrow> _ \<Rightarrow> _) = op \<le>"
    apply (intro ext)
    unfolding fun_ord_def le_fun_def
    by (rule refl)

  have [simp]: "\<And>A x. {y. \<exists>f\<in>A. y = f x} = (\<lambda>f. f x)`A" by auto

  show ?thesis
    apply (rule ccpo.admissibleI[OF drec.ccpo])
    apply (unfold fun_lub_def)
    apply clarsimp
    apply (drule_tac x=x in point_chainI)
    apply (erule dres_Sup_chain_cases)
    apply (simp only:)
    apply simp
    apply (simp only:)
    apply auto []
    apply (simp only:)
    apply force
    done
qed

declaration {* Partial_Function.init "drec" @{term drec.fixp_fun}
  @{term drec.mono_body} @{thm drec.fixp_rule_uc} NONE *}

lemma drec_bind_mono_pfun[partial_function_mono]:
  "\<lbrakk> drec.mono_body B; \<And>y. drec.mono_body (\<lambda>f. C y f) \<rbrakk> \<Longrightarrow> 
     drec.mono_body (\<lambda>f. dbind (B f) (\<lambda>y. C y f))"
  apply rule
  apply (rule dbind_mono)
  apply (blast dest: monotoneD)+
  done

end
