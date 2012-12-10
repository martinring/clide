(*  Author:     Tobias Nipkow, 2007  *)

theory QEdlo_fr
imports DLO
begin

subsection "Interior Point Method"

text{* This section formalizes a new quantifier elimination procedure
based on the idea of Ferrante and Rackoff~\cite{FerranteR-SIAM75} (see
also \S\ref{sec:FRE}) of taking a point between each lower and upper
bound as a test point. For dense linear orders it is not obvious how
to realize this because we cannot name any intermediate point
directly. *}

fun asubst\<^isub>2 :: "nat \<Rightarrow> nat \<Rightarrow> atom \<Rightarrow> atom fm" where
"asubst\<^isub>2 l u (Less 0 0) = FalseF" |
"asubst\<^isub>2 l u (Less 0 (Suc j)) = Or (Atom(Less u j)) (Atom(Eq u j))" |
"asubst\<^isub>2 l u (Less (Suc i) 0) = Or (Atom(Less i l)) (Atom(Eq i l))" |
"asubst\<^isub>2 l u (Less (Suc i) (Suc j)) = Atom(Less i j)" |
"asubst\<^isub>2 l u (Eq 0 0) = TrueF" |
"asubst\<^isub>2 l u (Eq 0 _) = FalseF" |
"asubst\<^isub>2 l u (Eq _ 0) = FalseF" |
"asubst\<^isub>2 l u (Eq (Suc i) (Suc j)) = Atom(Eq i j)"

abbreviation "subst\<^isub>2 l u \<equiv> amap\<^bsub>fm\<^esub> (asubst\<^isub>2 l u)"

lemma I_subst\<^isub>21:
 "nqfree f \<Longrightarrow> xs!l < xs!u \<Longrightarrow> DLO.I (subst\<^isub>2 l u f) xs
 \<Longrightarrow> xs!l < x \<Longrightarrow> x < xs!u \<Longrightarrow> DLO.I f (x#xs)"
proof(induct f arbitrary: x)
  case (Atom a) thus ?case
    by (cases "(l,u,a)" rule: asubst\<^isub>2.cases) auto
qed auto

definition
"nolub f xs l x u \<longleftrightarrow> (\<forall>y\<in>{l<..<x}. y \<notin> LB f xs) \<and> (\<forall>y\<in>{x<..<u}. y \<notin> UB f xs)"

lemma nolub_And[simp]:
  "nolub (And f g) xs l x u = (nolub f xs l x u \<and> nolub g xs l x u)"
by(auto simp:nolub_def)

lemma nolub_Or[simp]:
  "nolub (Or f g) xs l x u = (nolub f xs l x u \<and> nolub g xs l x u)"
by(auto simp:nolub_def)

declare[[simp_depth_limit=3]]
lemma innermost_intvl:
 "\<lbrakk> nqfree f; nolub f xs l x u; l < x; x < u; x \<notin> EQ f xs;
    DLO.I f (x#xs); l < y; y < u\<rbrakk>
    \<Longrightarrow> DLO.I f (y#xs)"
proof(induct f)
  case (Atom a)
  show ?case
  proof (cases a)
    case (Less i j)
    then show ?thesis using Atom
      unfolding nolub_def
      by (clarsimp simp: nth.simps Ball_def split:split_if_asm nat.splits)
         (metis not_leE order_antisym order_less_trans)+
  next
    case (Eq i j)[simp]
    show ?thesis
    proof (cases i)
      case 0[simp]
      show ?thesis
      proof (cases j)
        case 0 thus ?thesis using Atom by simp
      next
        case Suc thus ?thesis using Atom by(simp add:EQ_def)
      qed
    next
      case Suc[simp]
      show ?thesis
      proof (cases j)
        case 0 thus ?thesis using Atom by(simp add:EQ_def)
      next
        case Suc thus ?thesis using Atom by simp
      qed
    qed
  qed
next
  case (And f1 f2) thus ?case by (fastforce)
next
  case (Or f1 f2) thus ?case by (fastforce)
qed simp+

lemma I_subst\<^isub>22:
 "nqfree f \<Longrightarrow> xs!l < x \<and> x < xs!u \<Longrightarrow> nolub f xs (xs!l) x (xs!u)
 \<Longrightarrow> \<forall>x\<in>{xs!l <..< xs!u}. DLO.I f (x#xs) \<and> x \<notin> EQ f xs
 \<Longrightarrow> DLO.I (subst\<^isub>2 l u f) xs"
proof (induct f)
  case (Atom a) show ?case
    apply (cases "(l,u,a)" rule: asubst\<^isub>2.cases)
    apply(insert Atom, auto simp: EQ_def nolub_def split:split_if_asm)
    done
next
  case Or thus ?case by (simp add: Ball_def)(metis innermost_intvl)
qed auto
declare[[simp_depth_limit=50]]

definition
"qe_interior\<^isub>1 \<phi> =
(let as = DLO.atoms\<^isub>0 \<phi>; lbs = lbounds as; ubs = ubounds as; ebs = ebounds as;
     intrs = [And (Atom(Less l u)) (subst\<^isub>2 l u \<phi>). l\<leftarrow>lbs, u\<leftarrow>ubs]
 in list_disj (inf\<^isub>- \<phi> # inf\<^isub>+ \<phi> # intrs @ map (subst \<phi>) ebs))"

lemma dense_interval:
assumes "finite L" "finite U" "l : L" "u : U" "l < x" "x < u" "P(x::'a::dlo)"
and dense: "\<And>y l u. \<lbrakk> \<forall>y\<in>{l<..<x}. y \<notin> L;  \<forall>y\<in>{x<..<u}. y \<notin> U;
                       l<x;x<u; l<y;y<u \<rbrakk> \<Longrightarrow> P y"
shows "\<exists>l\<in>L.\<exists>u\<in>U. l<x \<and> x<u \<and> (\<forall>y\<in>{l<..<x}. y\<notin>L) \<and> (\<forall>y\<in>{x<..<u}. y\<notin>U)
            \<and> (\<forall>y. l<y \<and> y<u \<longrightarrow> P y)"
proof -
  let ?L = "{l:L. l < x}" let ?U = "{u:U. x < u}"
  let ?ll = "Max ?L" let ?uu = "Min ?U"
  have "?L \<noteq> {}" using `l : L` `l<x` by (blast intro:order_less_imp_le)
  moreover have "?U \<noteq> {}" using `u:U` `x<u` by (blast intro:order_less_imp_le)
  ultimately have "\<forall>y. ?ll<y \<and> y<x \<longrightarrow> y \<notin> L" "\<forall>y. x<y \<and> y<?uu \<longrightarrow> y \<notin> U"
    using `finite L` `finite U` by force+
  moreover have "?ll : L"
  proof
    show "?ll : ?L" using `finite L` Max_in[OF _ `?L \<noteq> {}`] by simp
    show "?L \<subseteq> L" by blast
  qed
  moreover have "?uu : U"
  proof
    show "?uu : ?U" using `finite U` Min_in[OF _ `?U \<noteq> {}`] by simp
    show "?U \<subseteq> U" by blast
  qed
  moreover have "?ll < x" using `finite L` `?L \<noteq> {}` by simp
  moreover have "x < ?uu" using `finite U` `?U \<noteq> {}` by simp
  moreover have "?ll < ?uu" using `?ll<x` `x<?uu` by simp
  ultimately show ?thesis using `l < x` `x < u` `?L \<noteq> {}` `?U \<noteq> {}`
    by(blast intro!:dense greaterThanLessThan_iff[THEN iffD1])
qed


theorem I_interior1:
assumes "nqfree \<phi>" shows "DLO.I (qe_interior\<^isub>1 \<phi>) xs = (EX x. DLO.I \<phi> (x#xs))"
  (is "?QE = ?EX")
proof
  assume ?QE
  { assume "DLO.I (inf\<^isub>- \<phi>) xs"
    hence ?EX using `?QE` min_inf[of \<phi> xs] `nqfree \<phi>`
      by(auto simp add:qe_interior\<^isub>1_def amap_fm_list_disj)
  } moreover
  { assume  "DLO.I (inf\<^isub>+ \<phi>) xs"
    hence ?EX using `?QE` plus_inf[of \<phi> xs] `nqfree \<phi>`
      by(auto simp add:qe_interior\<^isub>1_def amap_fm_list_disj)
  } moreover
  { assume "\<not>DLO.I (inf\<^isub>- \<phi>) xs \<and> \<not>DLO.I (inf\<^isub>+ \<phi>) xs \<and>
            (\<forall>x\<in>EQ \<phi> xs. \<not>DLO.I \<phi> (x#xs))"
    with `?QE` `nqfree \<phi>` obtain l u
      where "DLO.I (subst\<^isub>2 l u \<phi>) xs" and "xs!l < xs!u"
      by(fastforce simp: qe_interior\<^isub>1_def set_lbounds set_ubounds I_subst EQ_conv_set_ebounds)
    moreover then obtain x where "xs!l < x \<and> x < xs!u" by(metis dense)
    ultimately have "DLO.I \<phi> (x # xs)"
      using `nqfree \<phi>` I_subst\<^isub>21[OF `nqfree \<phi>` `xs!l < xs!u`] by simp
    hence ?EX .. }
  ultimately show ?EX by blast
next
  let ?as = "DLO.atoms\<^isub>0 \<phi>" let ?E = "set(ebounds ?as)"
  assume ?EX
  then obtain x where x: "DLO.I \<phi> (x#xs)" ..
  { assume "DLO.I (inf\<^isub>- \<phi>) xs \<or> DLO.I (inf\<^isub>+ \<phi>) xs"
    hence ?QE using `nqfree \<phi>` by(auto simp:qe_interior\<^isub>1_def)
  } moreover
  { assume "EX k : ?E. DLO.I (subst \<phi> k) xs"
    hence ?QE by(force simp:qe_interior\<^isub>1_def) } moreover
  { assume "\<not> DLO.I (inf\<^isub>- \<phi>) xs" and "\<not> DLO.I (inf\<^isub>+ \<phi>) xs"
    and "\<forall>k \<in> ?E. \<not> DLO.I (subst \<phi> k) xs"
    hence noE: "\<forall>e \<in> EQ \<phi> xs. \<not> DLO.I \<phi> (e#xs)"
      using `nqfree \<phi>` by (force simp:set_ebounds EQ_def I_subst)
    hence "x \<notin> EQ \<phi> xs" using x by fastforce
    obtain l where "l : LB \<phi> xs" "l < x"
      using LBex[OF `nqfree \<phi>` x `\<not> DLO.I(inf\<^isub>- \<phi>) xs` `x \<notin> EQ \<phi> xs`] ..
    obtain u where "u : UB \<phi> xs" "x < u"
      using UBex[OF `nqfree \<phi>` x `\<not> DLO.I(inf\<^isub>+ \<phi>) xs` `x \<notin> EQ \<phi> xs`] ..
    have "\<exists>l\<in>LB \<phi> xs. \<exists>u\<in>UB \<phi> xs. l<x \<and> x<u \<and> nolub \<phi> xs l x u \<and> (\<forall>y. l < y \<and> y < u \<longrightarrow> DLO.I \<phi> (y#xs))"
      using dense_interval[where P = "\<lambda>x. DLO.I \<phi> (x#xs)", OF finite_LB finite_UB `l:LB \<phi> xs` `u:UB \<phi> xs` `l<x` `x<u` x] x innermost_intvl[OF `nqfree \<phi>` _ _ _ `x \<notin> EQ \<phi> xs`]
      by (simp add:nolub_def) fastforce
    then obtain m n where
      "Less (Suc m) 0 : set ?as" "Less 0 (Suc n) : set ?as"
      "xs!m < x \<and> x < xs!n"
      "nolub \<phi> xs (xs!m) x (xs!n)"
      "\<forall>y. xs!m < y \<and> y < xs!n \<longrightarrow> DLO.I \<phi> (y#xs)"
      by blast
    moreover
    hence "DLO.I (subst\<^isub>2 m n \<phi>) xs" using noE
      by(force intro!: I_subst\<^isub>22[OF `nqfree \<phi>`])
    ultimately have ?QE
      by(fastforce simp add:qe_interior\<^isub>1_def bex_Un set_lbounds set_ubounds)
  } ultimately show ?QE by blast
qed

lemma qfree_asubst\<^isub>2: "qfree (asubst\<^isub>2 l u a)"
by(cases "(l,u,a)" rule:asubst\<^isub>2.cases) simp_all

lemma qfree_subst\<^isub>2: "nqfree \<phi> \<Longrightarrow> qfree (subst\<^isub>2 l u \<phi>)"
by(induct \<phi>) (simp_all add:qfree_asubst\<^isub>2)

lemma qfree_interior1: "nqfree \<phi> \<Longrightarrow> qfree(qe_interior\<^isub>1 \<phi>)"
apply(simp add:qe_interior\<^isub>1_def)
apply(rule qfree_list_disj)
apply (auto simp:qfree_min_inf qfree_plus_inf qfree_subst\<^isub>2 qfree_map_fm)
done


definition "qe_interior = DLO.lift_nnf_qe qe_interior\<^isub>1"

lemma qfree_qe_interior: "qfree(qe_interior \<phi>)"
by(simp add: qe_interior_def DLO.qfree_lift_nnf_qe qfree_interior1)

lemma I_qe_interior: "DLO.I (qe_interior \<phi>) xs = DLO.I \<phi> xs"
by(simp add:qe_interior_def DLO.I_lift_nnf_qe qfree_interior1 I_interior1)

end
