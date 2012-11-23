(*  Title:      HOL/MicroJava/BV/JType.thy
    Author:     Tobias Nipkow, Gerwin Klein
    Copyright   2000 TUM
*)

header {* \isaheader{The Java Type System as Semilattice} *}

theory JType
imports "../DFA/Semilattices" "../J/WellForm"
begin

definition super :: "'a prog \<Rightarrow> cname \<Rightarrow> cname" where
  "super G C == fst (the (class G C))"

lemma superI:
  "G \<turnstile> C \<prec>C1 D \<Longrightarrow> super G C = D"
  by (unfold super_def) (auto dest: subcls1D)

definition is_ref :: "ty \<Rightarrow> bool" where
  "is_ref T == case T of PrimT t \<Rightarrow> False | RefT r \<Rightarrow> True"

definition sup :: "'c prog \<Rightarrow> ty \<Rightarrow> ty \<Rightarrow> ty err" where
  "sup G T1 T2 ==
  case T1 of PrimT P1 \<Rightarrow> (case T2 of PrimT P2 \<Rightarrow> 
                         (if P1 = P2 then OK (PrimT P1) else Err) | RefT R \<Rightarrow> Err)
           | RefT R1 \<Rightarrow> (case T2 of PrimT P \<Rightarrow> Err | RefT R2 \<Rightarrow> 
  (case R1 of NullT \<Rightarrow> (case R2 of NullT \<Rightarrow> OK NT | ClassT C \<Rightarrow> OK (Class C))
            | ClassT C \<Rightarrow> (case R2 of NullT \<Rightarrow> OK (Class C) 
                           | ClassT D \<Rightarrow> OK (Class (exec_lub (subcls1 G) (super G) C D)))))"

definition subtype :: "'c prog \<Rightarrow> ty \<Rightarrow> ty \<Rightarrow> bool" where
  "subtype G T1 T2 == G \<turnstile> T1 \<preceq> T2"

definition is_ty :: "'c prog \<Rightarrow> ty \<Rightarrow> bool" where
  "is_ty G T == case T of PrimT P \<Rightarrow> True | RefT R \<Rightarrow>
               (case R of NullT \<Rightarrow> True | ClassT C \<Rightarrow> (C, Object) \<in> (subcls1 G)^*)"

abbreviation "types G == Collect (is_type G)"

definition esl :: "'c prog \<Rightarrow> ty esl" where
  "esl G == (types G, subtype G, sup G)"

lemma PrimT_PrimT: "(G \<turnstile> xb \<preceq> PrimT p) = (xb = PrimT p)"
  by (auto elim: widen.cases)

lemma PrimT_PrimT2: "(G \<turnstile> PrimT p \<preceq> xb) = (xb = PrimT p)"
  by (auto elim: widen.cases)

lemma is_tyI:
  "\<lbrakk> is_type G T; ws_prog G \<rbrakk> \<Longrightarrow> is_ty G T"
  by (auto simp add: is_ty_def intro: subcls_C_Object 
           split: ty.splits ref_ty.splits)

lemma is_type_conv: 
  "ws_prog G \<Longrightarrow> is_type G T = is_ty G T"
proof
  assume "is_type G T" "ws_prog G" 
  thus "is_ty G T"
    by (rule is_tyI)
next
  assume wf: "ws_prog G" and
         ty: "is_ty G T"

  show "is_type G T"
  proof (cases T)
    case PrimT
    thus ?thesis by simp
  next
    fix R assume R: "T = RefT R"
    with wf
    have "R = ClassT Object \<Longrightarrow> ?thesis" by simp
    moreover    
    from R wf ty
    have "R \<noteq> ClassT Object \<Longrightarrow> ?thesis"
     by (auto simp add: is_ty_def is_class_def split_tupled_all
               elim!: subcls1.cases
               elim: converse_rtranclE
               split: ref_ty.splits)
    ultimately    
    show ?thesis by blast
  qed
qed

lemma order_widen:
  "acyclic (subcls1 G) \<Longrightarrow> order (subtype G)"
  apply (unfold Semilat.order_def lesub_def subtype_def)
  apply (auto intro: widen_trans)
  apply (case_tac x)
   apply (case_tac y)
    apply (auto simp add: PrimT_PrimT)
   apply (case_tac y)
    apply simp
  apply simp
  apply (case_tac ref_ty)
   apply (case_tac ref_tya)
    apply simp
   apply simp
  apply (case_tac ref_tya)
   apply simp
  apply simp
  apply (auto dest: acyclic_impl_antisym_rtrancl antisymD)
  done

lemma wf_converse_subcls1_impl_acc_subtype:
  "wf ((subcls1 G)^-1) \<Longrightarrow> acc (subtype G)"
apply (unfold Semilat.acc_def lesssub_def)
apply (drule_tac p = "((subcls1 G)^-1) - Id" in wf_subset)
 apply auto
apply (drule wf_trancl)
apply (simp add: wf_eq_minimal)
apply clarify
apply (unfold lesub_def subtype_def)
apply (rename_tac M T) 
apply (case_tac "EX C. Class C : M")
 prefer 2
 apply (case_tac T)
  apply (fastforce simp add: PrimT_PrimT2)
 apply simp
 apply (subgoal_tac "ref_ty = NullT")
  apply simp
  apply (rule_tac x = NT in bexI)
   apply (rule allI)
   apply (rule impI, erule conjE)
   apply (drule widen_RefT)
   apply clarsimp
   apply (case_tac t)
    apply simp
   apply simp
  apply simp
 apply (case_tac ref_ty)
  apply simp
 apply simp
apply (erule_tac x = "{C. Class C : M}" in allE)
apply auto
apply (rename_tac D)
apply (rule_tac x = "Class D" in bexI)
 prefer 2
 apply assumption
apply clarify 
apply (frule widen_RefT)
apply (erule exE)
apply (case_tac t)
 apply simp
apply simp
apply (insert rtrancl_r_diff_Id [symmetric, of "subcls1 G"])
apply simp
apply (erule rtrancl.cases)
 apply blast
apply (drule rtrancl_converseI)
apply (subgoal_tac "(subcls1 G - Id)^-1 = (subcls1 G)^-1 - Id")
 prefer 2
 apply (simp add: converse_Int) apply safe[1]
apply simp
apply (blast intro: rtrancl_into_trancl2)
done

lemma closed_err_types:
  "\<lbrakk> ws_prog G; single_valued (subcls1 G); acyclic (subcls1 G) \<rbrakk> 
  \<Longrightarrow> closed (err (types G)) (lift2 (sup G))"
  apply (unfold closed_def plussub_def lift2_def sup_def)
  apply (auto split: err.split)
  apply (drule is_tyI, assumption)
  apply (auto simp add: is_ty_def is_type_conv simp del: is_type.simps 
              split: ty.split ref_ty.split)  
  apply (blast dest!: is_lub_exec_lub is_lubD is_ubD intro!: is_ubI superI)
  done


lemma sup_subtype_greater:
  "\<lbrakk> ws_prog G; single_valued (subcls1 G); acyclic (subcls1 G);
      is_type G t1; is_type G t2; sup G t1 t2 = OK s \<rbrakk> 
  \<Longrightarrow> subtype G t1 s \<and> subtype G t2 s"
proof -
  assume ws_prog:       "ws_prog G"
  assume single_valued: "single_valued (subcls1 G)"
  assume acyclic:       "acyclic (subcls1 G)"
 
  { fix c1 c2
    assume is_class: "is_class G c1" "is_class G c2"
    with ws_prog 
    obtain 
      "G \<turnstile> c1 \<preceq>C Object"
      "G \<turnstile> c2 \<preceq>C Object"
      by (blast intro: subcls_C_Object)
    with ws_prog single_valued
    obtain u where
      "is_lub ((subcls1 G)^* ) c1 c2 u"
      by (blast dest: single_valued_has_lubs)
    moreover
    note acyclic
    moreover
    have "\<forall>x y. G \<turnstile> x \<prec>C1 y \<longrightarrow> super G x = y"
      by (blast intro: superI)
    ultimately
    have "G \<turnstile> c1 \<preceq>C exec_lub (subcls1 G) (super G) c1 c2 \<and>
          G \<turnstile> c2 \<preceq>C exec_lub (subcls1 G) (super G) c1 c2"
      by (simp add: exec_lub_conv) (blast dest: is_lubD is_ubD)
  } note this [simp]
      
  assume "is_type G t1" "is_type G t2" "sup G t1 t2 = OK s"
  thus ?thesis
    apply (unfold sup_def subtype_def) 
    apply (cases s)
    apply (auto split: ty.split_asm ref_ty.split_asm split_if_asm)
    done
qed

lemma sup_subtype_smallest:
  "\<lbrakk> ws_prog G; single_valued (subcls1 G); acyclic (subcls1 G);
      is_type G a; is_type G b; is_type G c; 
      subtype G a c; subtype G b c; sup G a b = OK d \<rbrakk>
  \<Longrightarrow> subtype G d c"
proof -
  assume ws_prog:       "ws_prog G"
  assume single_valued: "single_valued (subcls1 G)"
  assume acyclic:       "acyclic (subcls1 G)"

  { fix c1 c2 D
    assume is_class: "is_class G c1" "is_class G c2"
    assume le: "G \<turnstile> c1 \<preceq>C D" "G \<turnstile> c2 \<preceq>C D"
    from ws_prog is_class
    obtain 
      "G \<turnstile> c1 \<preceq>C Object"
      "G \<turnstile> c2 \<preceq>C Object"
      by (blast intro: subcls_C_Object)
    with ws_prog single_valued
    obtain u where
      lub: "is_lub ((subcls1 G)^*) c1 c2 u"
      by (blast dest: single_valued_has_lubs)   
    with acyclic
    have "exec_lub (subcls1 G) (super G) c1 c2 = u"
      by (blast intro: superI exec_lub_conv)
    moreover
    from lub le
    have "G \<turnstile> u \<preceq>C D" 
      by (simp add: is_lub_def is_ub_def)
    ultimately     
    have "G \<turnstile> exec_lub (subcls1 G) (super G) c1 c2 \<preceq>C D"
      by blast
  } note this [intro]

  have [dest!]:
    "\<And>C T. G \<turnstile> Class C \<preceq> T \<Longrightarrow> \<exists>D. T=Class D \<and> G \<turnstile> C \<preceq>C D"
    by (frule widen_Class, auto)

  assume "is_type G a" "is_type G b" "is_type G c"
         "subtype G a c" "subtype G b c" "sup G a b = OK d"
  thus ?thesis
    by (auto simp add: subtype_def sup_def 
             split: ty.split_asm ref_ty.split_asm split_if_asm)
qed

lemma sup_exists:
  "\<lbrakk> subtype G a c; subtype G b c; sup G a b = Err \<rbrakk> \<Longrightarrow> False"
  by (auto simp add: PrimT_PrimT PrimT_PrimT2 sup_def subtype_def
           split: ty.splits ref_ty.splits)

lemma err_semilat_JType_esl_lemma:
  "\<lbrakk> ws_prog G; single_valued (subcls1 G); acyclic (subcls1 G) \<rbrakk> 
  \<Longrightarrow> err_semilat (esl G)"
proof -
  assume ws_prog:   "ws_prog G"
  assume single_valued: "single_valued (subcls1 G)"
  assume acyclic:   "acyclic (subcls1 G)"
  
  hence "order (subtype G)"
    by (rule order_widen)
  moreover
  from ws_prog single_valued acyclic
  have "closed (err (types G)) (lift2 (sup G))"
    by (rule closed_err_types)
  moreover

  from ws_prog single_valued acyclic
  have
    "(\<forall>x\<in>err (types G). \<forall>y\<in>err (types G). x <=_(Err.le (subtype G)) x +_(lift2 (sup G)) y) \<and> 
     (\<forall>x\<in>err (types G). \<forall>y\<in>err (types G). y <=_(Err.le (subtype G)) x +_(lift2 (sup G)) y)"
    by (auto simp add: lesub_def plussub_def Err.le_def lift2_def sup_subtype_greater split: err.split)

  moreover

  from ws_prog single_valued acyclic 
  have
    "\<forall>x\<in>err (types G). \<forall>y\<in>err (types G). \<forall>z\<in>err (types G). 
    x <=_(Err.le (subtype G)) z \<and> y <=_(Err.le (subtype G)) z \<longrightarrow> x +_(lift2 (sup G)) y <=_(Err.le (subtype G)) z"
    by (unfold lift2_def plussub_def lesub_def Err.le_def)
       (auto intro: sup_subtype_smallest sup_exists split: err.split)

  ultimately
  
  show ?thesis
    by (unfold esl_def semilat_def Err.sl_def) auto
qed

lemma single_valued_subcls1:
  "ws_prog G \<Longrightarrow> single_valued (subcls1 G)"
  by (auto simp add: ws_prog_def unique_def single_valued_def
    intro: subcls1I elim!: subcls1.cases)

theorem err_semilat_JType_esl:
  "ws_prog G \<Longrightarrow> err_semilat (esl G)"
  by (frule acyclic_subcls1, frule single_valued_subcls1, rule err_semilat_JType_esl_lemma)

end
