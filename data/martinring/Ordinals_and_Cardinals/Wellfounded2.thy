header {* More on well-founded relations *}

(* author: Andrei Popescu *)

theory Wellfounded2
imports Wellfounded Order_Relation2 "~~/src/HOL/Library/Wfrec"
begin



text {* This section contains some variations of results in the theory 
@{text "Wellfounded.thy"}:
\begin{itemize} 
\item means for slightly more direct definitions by well-founded recursion;
\item variations of well-founded induction; 
\item means for proving a linear order to be a well-order. 
\end{itemize} *}


subsection {* Well-founded recursion via genuine fixpoints *}


(*2*)lemma wfrec_fixpoint:
fixes r :: "('a * 'a) set" and 
      H :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a \<Rightarrow> 'b" 
assumes WF: "wf r" and ADM: "adm_wf r H"
shows "wfrec r H = H (wfrec r H)"
proof(rule ext)
  fix x
  have "wfrec r H x = H (cut (wfrec r H) r x) x" 
  using wfrec[of r H] WF by simp
  also 
  {have "\<And> y. (y,x) : r \<Longrightarrow> (cut (wfrec r H) r x) y = (wfrec r H) y"
   by (auto simp add: cut_apply)
   hence "H (cut (wfrec r H) r x) x = H (wfrec r H) x"
   using ADM adm_wf_def[of r H] by auto
  }
  finally show "wfrec r H x = H (wfrec r H) x" .
qed
 

(*2*)lemma adm_wf_unique_fixpoint:
fixes r :: "('a * 'a) set" and 
      H :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a \<Rightarrow> 'b" and 
      f :: "'a \<Rightarrow> 'b" and g :: "'a \<Rightarrow> 'b"
assumes WF: "wf r" and ADM: "adm_wf r H" and fFP: "f = H f" and gFP: "g = H g"
shows "f = g"
proof-
  {fix x 
   have "f x = g x"
   proof(rule wf_induct[of r "(\<lambda>x. f x = g x)"], 
         auto simp add: WF)
     fix x assume "\<forall>y. (y, x) \<in> r \<longrightarrow> f y = g y"
     hence "H f x = H g x" using ADM adm_wf_def[of r H] by auto
     thus "f x = g x" using fFP and gFP by simp
   qed
  }
  thus ?thesis by (simp add: ext)
qed


(*2*)lemma wfrec_unique_fixpoint:
fixes r :: "('a * 'a) set" and 
      H :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a \<Rightarrow> 'b" and 
      f :: "'a \<Rightarrow> 'b"
assumes WF: "wf r" and ADM: "adm_wf r H" and 
        fp: "f = H f"
shows "f = wfrec r H"
proof-
  have "H (wfrec r H) = wfrec r H" 
  using assms wfrec_fixpoint[of r H] by simp 
  thus ?thesis 
  using assms adm_wf_unique_fixpoint[of r H "wfrec r H"] by simp
qed



subsection {* Characterizations of well-founded-ness *}


text {* A transitive relation is well-founded iff it is ``locally" well-founded, 
i.e., iff its restriction to the lower bounds of of any element is well-founded.  *}

(*3*)lemma trans_wf_iff:
assumes "trans r" 
shows "wf r = (\<forall>a. wf(r Int (r^-1``{a} \<times> r^-1``{a})))"
proof-
  obtain R where R_def: "R = (\<lambda> a. r Int (r^-1``{a} \<times> r^-1``{a}))" by blast
  {assume *: "wf r"
   {fix a 
    have "wf(R a)" 
    using * R_def wf_subset[of r "R a"] by auto
   }
  }
  (*  *)
  moreover 
  {assume *: "\<forall>a. wf(R a)"
   have "wf r" 
   proof(unfold wf_def, clarify)
     fix phi a 
     assume **: "\<forall>a. (\<forall>b. (b,a) \<in> r \<longrightarrow> phi b) \<longrightarrow> phi a"
     obtain chi where chi_def: "chi = (\<lambda>b. (b,a) \<in> r \<longrightarrow> phi b)" by blast
     with * have "wf (R a)" by auto
     hence "(\<forall>b. (\<forall>c. (c,b) \<in> R a \<longrightarrow> chi c) \<longrightarrow> chi b) \<longrightarrow> (\<forall>b. chi b)"
     unfolding wf_def by blast
     moreover 
     have "\<forall>b. (\<forall>c. (c,b) \<in> R a \<longrightarrow> chi c) \<longrightarrow> chi b" 
     proof(auto simp add: chi_def R_def)
       fix b 
       assume 1: "(b,a) \<in> r" and 2: "\<forall>c. (c, b) \<in> r \<and> (c, a) \<in> r \<longrightarrow> phi c"
       hence "\<forall>c. (c, b) \<in> r \<longrightarrow> phi c"
       using assms trans_def[of r] by blast 
       thus "phi b" using ** by blast
     qed
     ultimately have  "\<forall>b. chi b" by (rule mp)    
     with ** chi_def show "phi a" by blast
   qed
  }
  ultimately show ?thesis using R_def by blast
qed


text {* The next lemma is a variation of @{text "wf_eq_minimal"} from Wellfounded, 
allowing one to assume the set included in the field.  *}

(*2*)lemma wf_eq_minimal2: 
"wf r = (\<forall>A. A <= Field r \<and> A \<noteq> {} \<longrightarrow> (\<exists>a \<in> A. \<forall>a' \<in> A. \<not> (a',a) \<in> r))"
proof-
  let ?phi = "\<lambda> A. A \<noteq> {} \<longrightarrow> (\<exists>a \<in> A. \<forall>a' \<in> A. \<not> (a',a) \<in> r)"
  have "wf r = (\<forall>A. ?phi A)"
  proof(unfold wf_eq_minimal, auto)
    fix A c assume *: "\<forall>A. (\<exists>c. c \<in> A) \<longrightarrow> (\<exists>a\<in>A. \<forall>a'. (a', a) \<in> r \<longrightarrow> a' \<notin> A)" and 
                  **: "\<forall>a\<in>A. \<exists>a'\<in>A. (a', a) \<in> r" and 
                 ***: "c \<in> A"
    obtain a where "a \<in> A \<and> (\<forall>a'. (a', a) \<in> r \<longrightarrow> a' \<notin> A)" 
    using * *** by auto
    with ** show False by blast
  next
    fix A::"'a set" and c 
    assume *: "\<forall>A. A \<noteq> {} \<longrightarrow> (\<exists>a\<in>A. \<forall>a'\<in>A. (a', a) \<notin> r)" and 
           **: "c \<in> A"
    obtain a where "a \<in> A \<and> (\<forall>a'\<in>A. (a', a) \<notin> r)" using * ** by blast
    thus "\<exists>a\<in>A. \<forall>a'. (a', a) \<in> r \<longrightarrow> a' \<notin> A" by blast
  qed  (* Why did this not go directly by blast?  *)
  (*  *)   
  also have "(\<forall>A. ?phi A) = (\<forall>B \<le> Field r. ?phi B)"
  proof
    assume "\<forall>A. ?phi A" 
    thus "\<forall>B \<le> Field r. ?phi B" by simp
  next
    assume *: "\<forall>B \<le> Field r. ?phi B"
    show "\<forall>A. ?phi A"
    proof(clarify)
      fix A::"'a set" assume **: "A \<noteq> {}"  
      obtain B where B_def: "B = A Int (Field r)" by blast
      show "\<exists>a \<in> A. \<forall>a' \<in> A. (a',a) \<notin> r" 
      proof(cases "B = {}")
        assume Case1: "B = {}"
        obtain a where 1: "a \<in> A \<and> a \<notin> Field r" using ** Case1 B_def by auto
        hence "\<forall>a' \<in> A. (a',a) \<notin> r" using 1 unfolding Field_def by blast
        thus ?thesis using 1 by auto 
      next
        assume Case2: "B \<noteq> {}" have 1: "B \<le> Field r" using B_def by auto
        obtain a where 2: "a \<in> B \<and> (\<forall>a' \<in> B. (a',a) \<notin> r)" 
        using Case2 1 * by blast
        have "\<forall>a' \<in> A. (a',a) \<notin> r"
        proof(clarify)
          fix a' assume "a' \<in> A" and **: "(a',a) \<in> r"
          hence "a' \<in> B" using B_def Field_def by fastforce 
          thus False using 2 ** by auto
        qed
        thus ?thesis using 2 B_def by auto
      qed
    qed
  qed
  finally show ?thesis by blast
qed


text {* The next lemma and its corollary enable one to prove that 
a linear order is a well-order in a way which is more standard than 
via well-founded-ness of the strict version of the relation.  *}

(*3*)lemma Linear_order_wf_diff_Id: 
assumes LI: "Linear_order r"
shows "wf(r - Id) = (\<forall>A \<le> Field r. A \<noteq> {} \<longrightarrow> (\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r))"
proof(cases "r \<le> Id")
  assume Case1: "r \<le> Id" 
  hence temp: "r - Id = {}" by blast 
  hence "wf(r - Id)" by (auto simp add: temp)   (* did not work with "using temp"!  *)
  moreover 
  {fix A assume *: "A \<le> Field r" and **: "A \<noteq> {}"
   obtain a where 1: "r = {} \<or> r = {(a,a)}" using LI 
   unfolding order_on_defs using Case1 rel.Total_subset_Id by blast
   hence "A = {a} \<and> r = {(a,a)}" using * ** unfolding Field_def by blast
   hence "\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r" using 1 by auto
  }
  ultimately show ?thesis by blast
next
  assume Case2: "\<not> r \<le> Id"
  hence 1: "Field r = Field(r - Id)" using rel.Total_Id_Field LI 
  unfolding order_on_defs by blast  
  show ?thesis 
  proof
    assume *: "wf(r - Id)"
    show "\<forall>A \<le> Field r. A \<noteq> {} \<longrightarrow> (\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r)" 
    proof(clarify)
      fix A assume **: "A \<le> Field r" and ***: "A \<noteq> {}"
      hence "\<exists>a \<in> A. \<forall>a' \<in> A. (a',a) \<notin> r - Id" 
      using 1 * unfolding wf_eq_minimal2 by auto
      moreover have "\<forall>a \<in> A. \<forall>a' \<in> A. ((a,a') \<in> r) = ((a',a) \<notin> r - Id)"   
      using rel.Linear_order_in_diff_Id[of r] ** LI by blast
      ultimately show "\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r" by blast
    qed
  next 
    assume *: "\<forall>A \<le> Field r. A \<noteq> {} \<longrightarrow> (\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r)"
    show "wf(r - Id)"
    proof(unfold wf_eq_minimal2, clarify)
      fix A assume **: "A \<le> Field(r - Id)" and ***: "A \<noteq> {}"
      hence "\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r" 
      using 1 * by auto
      moreover have "\<forall>a \<in> A. \<forall>a' \<in> A. ((a,a') \<in> r) = ((a',a) \<notin> r - Id)"   
      using rel.Linear_order_in_diff_Id[of r] ** LI mono_Field[of "r - Id" r] by blast
      ultimately show "\<exists>a \<in> A. \<forall>a' \<in> A. (a',a) \<notin> r - Id" by blast
    qed
  qed 
qed


(*3*)corollary Linear_order_Well_order_iff: 
assumes LI: "Linear_order r"
shows "Well_order r = (\<forall>A \<le> Field r. A \<noteq> {} \<longrightarrow> (\<exists>a \<in> A. \<forall>a' \<in> A. (a,a') \<in> r))"
using assms unfolding well_order_on_def using Linear_order_wf_diff_Id[of r] by auto


end
