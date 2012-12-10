(*  Author:  Gertrud Bauer  *)

header {* Correctness of Lower Bound for Final Graphs *}

theory LowerBound
imports PlaneProps ScoreProps
begin

(*<*)
lemma trans1:
 "(l::nat) = a1 + a2 + (a3 + a4) \<Longrightarrow> a1 + a3 = r \<Longrightarrow> l = r + a2 + a4"
by simp

lemma trans2: "(l::nat) =  a1 + a2 + a3  \<Longrightarrow>  a1 \<le> r \<Longrightarrow> l \<le> r + a2 + a3"
by simp

lemma trans3:
 "(l::nat) \<le>  a1 + a2 + (a3 + a4) \<Longrightarrow> a2 + a3 \<le> r \<Longrightarrow> l \<le> a1 + r + a4"
by simp

lemma trans4: "(l::nat) \<le> a1 + a2 + a3 \<Longrightarrow> a3 \<le> r \<Longrightarrow> l \<le> a1 + a2 + r"
by simp

lemma trans5: "(l::nat) \<le> a1 + a2 + a3 \<Longrightarrow> a2 + a3 = r \<Longrightarrow> l \<le> a1 + r"
by simp

lemma trans6: "(a::nat) = b1 + (b2 + b3) + b4 \<Longrightarrow> b3 = 0 \<Longrightarrow>
            a = b1 + b2 + b4" by (simp add: add_ac)
(*>*)

(* FIXME in Tame: admissibility should be expressed via setsum!
   \<rightarrow> convert a lot of listsum to setsum
*)

theorem total_weight_lowerbound:
 "inv g \<Longrightarrow> final g \<Longrightarrow> tame g \<Longrightarrow> admissible w g \<Longrightarrow>
 (\<Sum>\<^bsub>f \<in> faces g\<^esub> w f) < squanderTarget \<Longrightarrow>
 squanderLowerBound g \<le> (\<Sum>\<^bsub>f \<in> faces g\<^esub> w f)"
proof -
  assume final: "final g" and tame: "tame g" and pl: "inv g"
  assume admissible: "admissible w g"
  assume w: "(\<Sum>\<^bsub>f \<in> faces g\<^esub> w f) < squanderTarget"
(*<*)
  from admissible have admissible\<^isub>1:
   "\<And>f. f \<in> set (faces g) \<Longrightarrow> \<d> |vertices f| \<le> w f"
    by (simp add: admissible_def admissible\<^isub>1_def)
(*>*) (* *)

  have "squanderLowerBound g
     = ExcessNotAt g None + faceSquanderLowerBound g"
    by (simp add: squanderLowerBound_def)

  txt {* We expand the definition of @{text "faceSquanderLowerBound"}. *}

  also have "faceSquanderLowerBound g = (\<Sum>\<^bsub>f \<in> faces g\<^esub> \<d> |vertices f| )" (*<*)
    by (simp add: faceSquanderLowerBound_def final) (*>*)

  txt {* We expand the definition of @{text "ExcessNotAt"}. *}
  also from ExcessNotAt_eq[OF pl[THEN inv_mgp] final] obtain V
    where eq: "ExcessNotAt g None = (\<Sum>\<^bsub>v \<in> V\<^esub> ExcessAt g v)"
    and pS:  "separated g (set V)"
    and V_subset: "set V \<subseteq> set(vertices g)"
    and V_distinct: "distinct V" (*<*)
    by (blast) note eq

  txt {* We partition V in two disjoint subsets $V1, V2$,
  where $V2$ contains all exceptional vertices, $V1$ all
  not exceptional vertices. *}

  also def V1 \<equiv> "[v \<leftarrow> V. except g v = 0]"
  def V2 \<equiv> "[v \<leftarrow> V. except g v \<noteq> 0]"  (*<*)
  have s: "set V1 \<subseteq> set V" by (auto simp add: V1_def)
  with pS obtain pSV1: "separated g (set V1)"
    by (auto dest: separated_subset)
  from V_distinct obtain V1_distinct: "distinct V1"
    by (unfold V1_def) (auto dest: distinct_filter)
  obtain noExV1: "noExceptionals g (set V1)"
    by (auto simp add: V1_def noExceptionals_def
      exceptionalVertex_def)
(*>*) (* *)

  have V_subset_simp: "!!v. v: set V \<Longrightarrow> v : \<V> g"
    using V_subset by fast

  have "(\<Sum>\<^bsub>v \<in> V\<^esub> ExcessAt g v)
    = (\<Sum>\<^bsub>v \<in> V1\<^esub> ExcessAt g v) + (\<Sum>\<^bsub>v \<in> V2\<^esub> ExcessAt g v)" (*<*)
     by (simp only: V1_def V2_def ListSum_compl) (*>*)

  txt {*  We partition @{text "V2"} in two disjoint subsets,
  $V4$ contains all exceptional vertices of degree $\neq 5$
  $V3$ contains all exceptional vertices of degree $5$.
  *}

  also def V4 \<equiv> "[v \<leftarrow> V2. vertextype g v \<noteq> (5,0,1)]"
  def V3 \<equiv> "[v \<leftarrow> V2. vertextype g v = (5,0,1)]"

(*<*)
  with pS V2_def have V3: "separated g (set V3)"
    by (rule_tac separated_subset) auto
  have "distinct V3" by(simp add:V3_def V2_def `distinct V`)
(*
  with V3_def V2_def obtain V3: "separated g (set V3)"
    by (simp add: vertextype_def separated_def preSeparated_def separated\<^isub>1_def
      separated\<^isub>4_def)
*)
  from V_subset obtain V3_subset: "set V3 \<subseteq> \<V> g"
    by (auto simp add: V3_def V2_def)
(*>*)

  have "(\<Sum>\<^bsub>v \<in> V2\<^esub> ExcessAt g v)
    = (\<Sum>\<^bsub>v \<in> V3\<^esub> ExcessAt g v) + (\<Sum>\<^bsub>v \<in> V4\<^esub> ExcessAt g v)" (*<*)
    by (simp add: V4_def V3_def ListSum_compl) (*>*) (* *)

  txt {*  We partition  @{text "faces g"} in two disjoint subsets:
  $F1$ contains all faces that contain a vertex of $V1$,
  $F2$ the remaining faces. *}

  also def F1 \<equiv> "[f \<leftarrow> faces g . \<exists> v \<in> set V1. f \<in> set (facesAt g v)]"
  def F2 \<equiv> "[f \<leftarrow> faces g . \<not>(\<exists> v \<in> set V1. f \<in> set (facesAt g v))]"

  have "(\<Sum>\<^bsub>f \<in> faces g\<^esub> \<d> |vertices f| )
      = (\<Sum>\<^bsub>f \<in> F1\<^esub> \<d> |vertices f| ) + (\<Sum>\<^bsub> f \<in> F2\<^esub> \<d> |vertices f| )" (*<*)
    by (simp only: ListSum_compl F1_def F2_def) (*>*) (* *)

  txt {*  We split up @{text "F2"} in two disjoint subsets: *}

  also def F3 \<equiv> "[f\<leftarrow>F2. \<exists>v \<in> set V3. f \<in> set (facesAt g v)]"
  def F4 \<equiv> "[f\<leftarrow>F2. \<not> (\<exists>v \<in> set V3. f \<in> set (facesAt g v))]"

  have F3: "F3 = [f\<leftarrow>faces g . \<exists>v \<in> set V3. f \<in> set (facesAt g v)]"
proof(simp add: F3_def F2_def, intro filter_eqI iffI conjI)
     fix f assume "f \<in> set (faces g)"
     with final have fin: "final f" by (rule finalGraph_face)
     assume "\<exists>v3\<in>set V3. f \<in> set (facesAt g v3)"
     then obtain v3 where v3: "v3 \<in> set V3" "f \<in> set (facesAt g v3)"
       by auto
     show "(\<forall>v1\<in>set V1. f \<notin> set (facesAt g v1))"
     proof (intro ballI notI)
       fix v1 assume v1: "v1 \<in> set V1"
       with v3 have "v1 \<noteq> v3"
         by (auto simp add: V3_def V2_def V1_def)

       moreover assume f: "f \<in> set (facesAt g v1)"
       with v1 fin have c: "|vertices f| \<le> 4"
         by (auto simp add: V1_def except_def)

       from v1 have "v1 \<in> set V" by (simp add: V1_def)
       with f pS c have "set (vertices f) \<inter> set V = {v1}"
         by (simp add: separated_def separated\<^isub>3_def)

       moreover from v3 have "v3 \<in> set V"
         by (simp add: V3_def V2_def)
       with v3 pS c have "set (vertices f) \<inter> set V = {v3}"
         by (simp add: separated_def separated\<^isub>3_def)
       ultimately show False by auto
    qed
  qed simp

  have "(\<Sum>\<^bsub>f\<in>F2\<^esub> \<d> |vertices f| )
   = (\<Sum>\<^bsub>f\<in>F3\<^esub> \<d> |vertices f| ) + (\<Sum>\<^bsub>f\<in>F4\<^esub> \<d> |vertices f| )" (*<*)
    by (simp only: F3_def F4_def ListSum_compl) (*>*) (* *)

  txt_raw {* \newpage *}
  txt {* ($E_1$) From the definition of @{text "ExcessAt"} we have *}

  also have "(\<Sum>\<^bsub>v \<in> V1\<^esub> ExcessAt g v) + (\<Sum>\<^bsub> f \<in> F1\<^esub> \<d> |vertices f| )
      = (\<Sum>\<^bsub>v \<in> V1\<^esub> \<b> (tri g v) (quad g v))"
  proof -
    from noExV1 V_subset have "(\<Sum>\<^bsub> f \<in> F1\<^esub> \<d> |vertices f| )
      = (\<Sum>\<^bsub>v \<in> V1\<^esub> (tri g v *  \<d> 3 + quad g v * \<d> 4))"
    apply (unfold F1_def)
    apply (rule_tac squanderFace_distr2)
    apply (rule pl)
    apply (rule final)
    apply (rule noExV1)
    apply (rule pSV1)
    apply (rule V1_distinct)
    apply (unfold V1_def)
    apply auto
    done

    also have "(\<Sum>\<^bsub>v \<in> V1\<^esub> ExcessAt g v)
      + (\<Sum>\<^bsub>v \<in> V1\<^esub> (tri g v * \<d> 3 + quad g v * \<d> 4))
      = (\<Sum>\<^bsub>v \<in> V1\<^esub> (ExcessAt g v
      + tri g v * \<d> 3 + quad g v * \<d> 4))" (*<*)
      by (simp add: ListSum_add add_ac) (*>*) (* FIXME  also takes too long *)
    also from pl final tame have "\<dots> = (\<Sum>\<^bsub>v \<in> V1\<^esub> \<b> (tri g v) (quad g v))"
      by (rule_tac ListSum_eq)
         (fastforce simp add: V1_def V_subset[THEN subsetD] intro: excess_eq1)
    finally show ?thesis .
  qed

  txt {* ($E_2$)  For all exceptional vertices of degree $5$
  @{text "excess"} returns @{text "a (tri g v)"}. *}

  also (trans1)
    from pl final V_subset have
    "(\<Sum>\<^bsub>v \<in> V3\<^esub> ExcessAt g v) = (\<Sum>\<^bsub>v \<in> V3\<^esub> \<a>)" (*<*)
     apply (rule_tac ListSum_eq)
     apply (simp add: V3_def V2_def excessAtType_def ExcessAt_def degree_eq vertextype_def)
     by(blast intro: finalVertexI)
(*     apply force by(blast intro: finalVertexI)*) (*>*) (* *)

  txt {* ($E_3$) For all exceptional vertices of degree $\neq 5$
  @{text "ExcessAt"} returns 0. *}

  also from pl final tame have "(\<Sum>\<^bsub>v \<in> V4\<^esub> ExcessAt g v) = (\<Sum>\<^bsub>v \<in> V4\<^esub> 0)" (*<*)
    by (rule_tac ListSum_eq)
       (auto simp: V2_def V4_def excessAtType_def ExcessAt_def degree_eq V_subset_simp tame_def tame12o_def) (*>*) (* *)

  also have "\<dots> = 0" (*<*) by simp   (*>*) (* *)

  txt {* ($A_1$) We use property @{text "admissible\<^isub>2"}. *}

  also(trans6) have
  "(\<Sum>\<^bsub>v \<in> V1\<^esub> \<b> (tri g v) (quad g v)) \<le> (\<Sum>\<^bsub>v \<in> V1\<^esub> \<Sum>\<^bsub>f \<in> facesAt g v\<^esub> w f)"

  proof (rule_tac ListSum_le)
    fix v assume "v \<in> set V1"
    with V1_def V_subset have "v \<in> set (vertices g)" (*<*)  by auto (*>*) (* *)
    with admissible show "\<b> (tri g v) (quad g v) \<le> (\<Sum>\<^bsub>f \<in> facesAt g v\<^esub> w f)"
      using `v \<in> set V1` by (auto simp add:admissible_def admissible\<^isub>2_def V1_def)
  qed

  also(trans2) from pSV1 V1_distinct V_subset have "\<dots> = (\<Sum>\<^bsub>f \<in> F1\<^esub> w f)"
    apply (unfold F1_def)
    apply (rule ScoreProps.separated_disj_Union2)
    apply (rule pl)
    apply (rule final)
    apply (rule noExV1)
    apply (rule pSV1)
    apply (rule V1_distinct)
    apply (unfold V1_def)
    apply auto
    done

  txt {* ($A_2$) We use property @{text "admissible\<^isub>4"}. *}

  also have "(\<Sum>\<^bsub>v\<in>V3\<^esub> \<a>) + (\<Sum>\<^bsub>f\<in>F3\<^esub> \<d> |vertices f| ) \<le> (\<Sum>\<^bsub>f \<in> F3 \<^esub>w f)" (*<*)
  proof-
    def T == "[f\<leftarrow>F3. triangle f]"
    def E == "[f\<leftarrow>F3. ~ triangle f]"
    have "(\<Sum>\<^bsub>f\<in>F3\<^esub> \<d> |vertices f| ) =
      (\<Sum>\<^bsub>f\<in>T\<^esub> \<d> |vertices f| ) + (\<Sum>\<^bsub>f\<in>E\<^esub> \<d> |vertices f| )"
      by(simp only: T_def E_def ListSum_compl2)
    also have "(\<Sum>\<^bsub>f\<in>T\<^esub> \<d> |vertices f| ) =
          (\<Sum>\<^bsub>f \<in> [f\<leftarrow>faces g . \<exists>v \<in> set V3. f \<in> set (facesAt g v) Int Collect triangle]\<^esub> \<d> |vertices f| )"
      by(rule listsum_cong[OF _ HOL.refl])
        (simp add:T_def F3 Int_def)
    also have "\<dots> = (\<Sum>\<^bsub>v \<in> V3\<^esub> \<Sum>\<^bsub>f \<in> filter triangle (facesAt g v)\<^esub> \<d> |vertices f| )"
      by(rule ListSum_V_F_eq_ListSum_F[symmetric, OF `inv g` V3 `distinct V3` `set V3 \<subseteq> \<V> g`])
        (simp add:Ball_def)
    also have "\<dots> = 0" by (simp add: squanderFace_def)
    finally have "(\<Sum>\<^bsub>v\<in>V3\<^esub> \<a>) + (\<Sum>\<^bsub>f\<in>F3\<^esub> \<d> |vertices f| ) =
      (\<Sum>\<^bsub>v\<in>V3\<^esub> \<a>) + (\<Sum>\<^bsub>f\<in>E\<^esub> \<d> |vertices f| )" by simp
    also have "(\<Sum>\<^bsub>f\<in>E\<^esub> \<d> |vertices f| ) \<le> (\<Sum>\<^bsub>f\<in>E\<^esub> w f )"
      using `admissible w g`
      by(rule_tac ListSum_le)
        (simp add: admissible_def admissible\<^isub>1_def E_def F3_def F2_def)
    also have "(\<Sum>\<^bsub>v\<in>V3\<^esub> \<a>) \<le> (\<Sum>\<^bsub>v\<in>V3\<^esub> \<Sum>\<^bsub>f\<in>filter triangle (facesAt g v)\<^esub> w(f))"
      using `admissible w g`
      by(rule_tac ListSum_le)
        (simp add: admissible_def admissible\<^isub>3_def V3_def V2_def V_subset_simp)
    also have "\<dots> = (\<Sum>\<^bsub>f \<in> [f\<leftarrow>faces g . \<exists>v \<in> set V3. f \<in> set (facesAt g v) Int Collect triangle]\<^esub> w f)"
      by(rule ListSum_V_F_eq_ListSum_F[OF `inv g` V3 `distinct V3` `set V3 \<subseteq> \<V> g`])
        (simp add:Ball_def)
    also have "\<dots> = (\<Sum>\<^bsub>f\<in>T\<^esub> w f)"
      by(simp add: T_def F3 Int_def)
    also have "ListSum T w + ListSum E w = ListSum F3 w"
      by(simp add: T_def E_def ListSum_compl2)
    finally show ?thesis by simp
  qed

  txt_raw {* \newpage *}
  txt {* ($A_3$) We use property @{text "admissible\<^isub>1"}. *}

  also(trans3) have "(\<Sum>\<^bsub> f \<in> F4\<^esub> \<d> |vertices f| ) \<le> (\<Sum>\<^bsub>f \<in> F4\<^esub> w f)"
  proof (rule ListSum_le)
    fix f assume "f \<in> set F4"
    then have f: "f \<in> set (faces g)" (*<*) by (simp add: F4_def F2_def)(*>*) (* *)
    with admissible\<^isub>1 f show "\<d> |vertices f| \<le> w f" by (simp)
  qed

  txt {*  We reunite $F3$ and $F4$.  *}

  also(trans4) have "(\<Sum>\<^bsub> f \<in> F3\<^esub> w f) + (\<Sum>\<^bsub> f \<in> F4\<^esub> w f) = (\<Sum>\<^bsub> f \<in> F2\<^esub> w f)" (*<*)
    by (simp only: F3_def F4_def ListSum_compl) (*>*) (* *)

  txt {*  We reunite $F1$ and $F2$.  *}

  also(trans5) have "(\<Sum>\<^bsub> f \<in> F1\<^esub> w f) + (\<Sum>\<^bsub> f \<in> F2\<^esub> w f) = (\<Sum>\<^bsub>f \<in> faces g\<^esub> w f)" (*<*)
    by (simp only: F1_def F2_def ListSum_compl) (*>*) (* *)

  finally show "squanderLowerBound g \<le> (\<Sum>\<^bsub>f \<in> faces g\<^esub> w f)" .
qed

end
