(*  Title:      ZF/Constructible/Relative.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
*)

header {*Relativization and Absoluteness*}

theory Relative imports Main begin

subsection{* Relativized versions of standard set-theoretic concepts *}

definition
  empty :: "[i=>o,i] => o" where
    "empty(M,z) == \<forall>x[M]. x \<notin> z"

definition
  subset :: "[i=>o,i,i] => o" where
    "subset(M,A,B) == \<forall>x[M]. x\<in>A \<longrightarrow> x \<in> B"

definition
  upair :: "[i=>o,i,i,i] => o" where
    "upair(M,a,b,z) == a \<in> z & b \<in> z & (\<forall>x[M]. x\<in>z \<longrightarrow> x = a | x = b)"

definition
  pair :: "[i=>o,i,i,i] => o" where
    "pair(M,a,b,z) == \<exists>x[M]. upair(M,a,a,x) &
                     (\<exists>y[M]. upair(M,a,b,y) & upair(M,x,y,z))"


definition
  union :: "[i=>o,i,i,i] => o" where
    "union(M,a,b,z) == \<forall>x[M]. x \<in> z \<longleftrightarrow> x \<in> a | x \<in> b"

definition
  is_cons :: "[i=>o,i,i,i] => o" where
    "is_cons(M,a,b,z) == \<exists>x[M]. upair(M,a,a,x) & union(M,x,b,z)"

definition
  successor :: "[i=>o,i,i] => o" where
    "successor(M,a,z) == is_cons(M,a,a,z)"

definition
  number1 :: "[i=>o,i] => o" where
    "number1(M,a) == \<exists>x[M]. empty(M,x) & successor(M,x,a)"

definition
  number2 :: "[i=>o,i] => o" where
    "number2(M,a) == \<exists>x[M]. number1(M,x) & successor(M,x,a)"

definition
  number3 :: "[i=>o,i] => o" where
    "number3(M,a) == \<exists>x[M]. number2(M,x) & successor(M,x,a)"

definition
  powerset :: "[i=>o,i,i] => o" where
    "powerset(M,A,z) == \<forall>x[M]. x \<in> z \<longleftrightarrow> subset(M,x,A)"

definition
  is_Collect :: "[i=>o,i,i=>o,i] => o" where
    "is_Collect(M,A,P,z) == \<forall>x[M]. x \<in> z \<longleftrightarrow> x \<in> A & P(x)"

definition
  is_Replace :: "[i=>o,i,[i,i]=>o,i] => o" where
    "is_Replace(M,A,P,z) == \<forall>u[M]. u \<in> z \<longleftrightarrow> (\<exists>x[M]. x\<in>A & P(x,u))"

definition
  inter :: "[i=>o,i,i,i] => o" where
    "inter(M,a,b,z) == \<forall>x[M]. x \<in> z \<longleftrightarrow> x \<in> a & x \<in> b"

definition
  setdiff :: "[i=>o,i,i,i] => o" where
    "setdiff(M,a,b,z) == \<forall>x[M]. x \<in> z \<longleftrightarrow> x \<in> a & x \<notin> b"

definition
  big_union :: "[i=>o,i,i] => o" where
    "big_union(M,A,z) == \<forall>x[M]. x \<in> z \<longleftrightarrow> (\<exists>y[M]. y\<in>A & x \<in> y)"

definition
  big_inter :: "[i=>o,i,i] => o" where
    "big_inter(M,A,z) ==
             (A=0 \<longrightarrow> z=0) &
             (A\<noteq>0 \<longrightarrow> (\<forall>x[M]. x \<in> z \<longleftrightarrow> (\<forall>y[M]. y\<in>A \<longrightarrow> x \<in> y)))"

definition
  cartprod :: "[i=>o,i,i,i] => o" where
    "cartprod(M,A,B,z) ==
        \<forall>u[M]. u \<in> z \<longleftrightarrow> (\<exists>x[M]. x\<in>A & (\<exists>y[M]. y\<in>B & pair(M,x,y,u)))"

definition
  is_sum :: "[i=>o,i,i,i] => o" where
    "is_sum(M,A,B,Z) ==
       \<exists>A0[M]. \<exists>n1[M]. \<exists>s1[M]. \<exists>B1[M].
       number1(M,n1) & cartprod(M,n1,A,A0) & upair(M,n1,n1,s1) &
       cartprod(M,s1,B,B1) & union(M,A0,B1,Z)"

definition
  is_Inl :: "[i=>o,i,i] => o" where
    "is_Inl(M,a,z) == \<exists>zero[M]. empty(M,zero) & pair(M,zero,a,z)"

definition
  is_Inr :: "[i=>o,i,i] => o" where
    "is_Inr(M,a,z) == \<exists>n1[M]. number1(M,n1) & pair(M,n1,a,z)"

definition
  is_converse :: "[i=>o,i,i] => o" where
    "is_converse(M,r,z) ==
        \<forall>x[M]. x \<in> z \<longleftrightarrow>
             (\<exists>w[M]. w\<in>r & (\<exists>u[M]. \<exists>v[M]. pair(M,u,v,w) & pair(M,v,u,x)))"

definition
  pre_image :: "[i=>o,i,i,i] => o" where
    "pre_image(M,r,A,z) ==
        \<forall>x[M]. x \<in> z \<longleftrightarrow> (\<exists>w[M]. w\<in>r & (\<exists>y[M]. y\<in>A & pair(M,x,y,w)))"

definition
  is_domain :: "[i=>o,i,i] => o" where
    "is_domain(M,r,z) ==
        \<forall>x[M]. x \<in> z \<longleftrightarrow> (\<exists>w[M]. w\<in>r & (\<exists>y[M]. pair(M,x,y,w)))"

definition
  image :: "[i=>o,i,i,i] => o" where
    "image(M,r,A,z) ==
        \<forall>y[M]. y \<in> z \<longleftrightarrow> (\<exists>w[M]. w\<in>r & (\<exists>x[M]. x\<in>A & pair(M,x,y,w)))"

definition
  is_range :: "[i=>o,i,i] => o" where
    --{*the cleaner
      @{term "\<exists>r'[M]. is_converse(M,r,r') & is_domain(M,r',z)"}
      unfortunately needs an instance of separation in order to prove
        @{term "M(converse(r))"}.*}
    "is_range(M,r,z) ==
        \<forall>y[M]. y \<in> z \<longleftrightarrow> (\<exists>w[M]. w\<in>r & (\<exists>x[M]. pair(M,x,y,w)))"

definition
  is_field :: "[i=>o,i,i] => o" where
    "is_field(M,r,z) ==
        \<exists>dr[M]. \<exists>rr[M]. is_domain(M,r,dr) & is_range(M,r,rr) &
                        union(M,dr,rr,z)"

definition
  is_relation :: "[i=>o,i] => o" where
    "is_relation(M,r) ==
        (\<forall>z[M]. z\<in>r \<longrightarrow> (\<exists>x[M]. \<exists>y[M]. pair(M,x,y,z)))"

definition
  is_function :: "[i=>o,i] => o" where
    "is_function(M,r) ==
        \<forall>x[M]. \<forall>y[M]. \<forall>y'[M]. \<forall>p[M]. \<forall>p'[M].
           pair(M,x,y,p) \<longrightarrow> pair(M,x,y',p') \<longrightarrow> p\<in>r \<longrightarrow> p'\<in>r \<longrightarrow> y=y'"

definition
  fun_apply :: "[i=>o,i,i,i] => o" where
    "fun_apply(M,f,x,y) ==
        (\<exists>xs[M]. \<exists>fxs[M].
         upair(M,x,x,xs) & image(M,f,xs,fxs) & big_union(M,fxs,y))"

definition
  typed_function :: "[i=>o,i,i,i] => o" where
    "typed_function(M,A,B,r) ==
        is_function(M,r) & is_relation(M,r) & is_domain(M,r,A) &
        (\<forall>u[M]. u\<in>r \<longrightarrow> (\<forall>x[M]. \<forall>y[M]. pair(M,x,y,u) \<longrightarrow> y\<in>B))"

definition
  is_funspace :: "[i=>o,i,i,i] => o" where
    "is_funspace(M,A,B,F) ==
        \<forall>f[M]. f \<in> F \<longleftrightarrow> typed_function(M,A,B,f)"

definition
  composition :: "[i=>o,i,i,i] => o" where
    "composition(M,r,s,t) ==
        \<forall>p[M]. p \<in> t \<longleftrightarrow>
               (\<exists>x[M]. \<exists>y[M]. \<exists>z[M]. \<exists>xy[M]. \<exists>yz[M].
                pair(M,x,z,p) & pair(M,x,y,xy) & pair(M,y,z,yz) &
                xy \<in> s & yz \<in> r)"

definition
  injection :: "[i=>o,i,i,i] => o" where
    "injection(M,A,B,f) ==
        typed_function(M,A,B,f) &
        (\<forall>x[M]. \<forall>x'[M]. \<forall>y[M]. \<forall>p[M]. \<forall>p'[M].
          pair(M,x,y,p) \<longrightarrow> pair(M,x',y,p') \<longrightarrow> p\<in>f \<longrightarrow> p'\<in>f \<longrightarrow> x=x')"

definition
  surjection :: "[i=>o,i,i,i] => o" where
    "surjection(M,A,B,f) ==
        typed_function(M,A,B,f) &
        (\<forall>y[M]. y\<in>B \<longrightarrow> (\<exists>x[M]. x\<in>A & fun_apply(M,f,x,y)))"

definition
  bijection :: "[i=>o,i,i,i] => o" where
    "bijection(M,A,B,f) == injection(M,A,B,f) & surjection(M,A,B,f)"

definition
  restriction :: "[i=>o,i,i,i] => o" where
    "restriction(M,r,A,z) ==
        \<forall>x[M]. x \<in> z \<longleftrightarrow> (x \<in> r & (\<exists>u[M]. u\<in>A & (\<exists>v[M]. pair(M,u,v,x))))"

definition
  transitive_set :: "[i=>o,i] => o" where
    "transitive_set(M,a) == \<forall>x[M]. x\<in>a \<longrightarrow> subset(M,x,a)"

definition
  ordinal :: "[i=>o,i] => o" where
     --{*an ordinal is a transitive set of transitive sets*}
    "ordinal(M,a) == transitive_set(M,a) & (\<forall>x[M]. x\<in>a \<longrightarrow> transitive_set(M,x))"

definition
  limit_ordinal :: "[i=>o,i] => o" where
    --{*a limit ordinal is a non-empty, successor-closed ordinal*}
    "limit_ordinal(M,a) ==
        ordinal(M,a) & ~ empty(M,a) &
        (\<forall>x[M]. x\<in>a \<longrightarrow> (\<exists>y[M]. y\<in>a & successor(M,x,y)))"

definition
  successor_ordinal :: "[i=>o,i] => o" where
    --{*a successor ordinal is any ordinal that is neither empty nor limit*}
    "successor_ordinal(M,a) ==
        ordinal(M,a) & ~ empty(M,a) & ~ limit_ordinal(M,a)"

definition
  finite_ordinal :: "[i=>o,i] => o" where
    --{*an ordinal is finite if neither it nor any of its elements are limit*}
    "finite_ordinal(M,a) ==
        ordinal(M,a) & ~ limit_ordinal(M,a) &
        (\<forall>x[M]. x\<in>a \<longrightarrow> ~ limit_ordinal(M,x))"

definition
  omega :: "[i=>o,i] => o" where
    --{*omega is a limit ordinal none of whose elements are limit*}
    "omega(M,a) == limit_ordinal(M,a) & (\<forall>x[M]. x\<in>a \<longrightarrow> ~ limit_ordinal(M,x))"

definition
  is_quasinat :: "[i=>o,i] => o" where
    "is_quasinat(M,z) == empty(M,z) | (\<exists>m[M]. successor(M,m,z))"

definition
  is_nat_case :: "[i=>o, i, [i,i]=>o, i, i] => o" where
    "is_nat_case(M, a, is_b, k, z) ==
       (empty(M,k) \<longrightarrow> z=a) &
       (\<forall>m[M]. successor(M,m,k) \<longrightarrow> is_b(m,z)) &
       (is_quasinat(M,k) | empty(M,z))"

definition
  relation1 :: "[i=>o, [i,i]=>o, i=>i] => o" where
    "relation1(M,is_f,f) == \<forall>x[M]. \<forall>y[M]. is_f(x,y) \<longleftrightarrow> y = f(x)"

definition
  Relation1 :: "[i=>o, i, [i,i]=>o, i=>i] => o" where
    --{*as above, but typed*}
    "Relation1(M,A,is_f,f) ==
        \<forall>x[M]. \<forall>y[M]. x\<in>A \<longrightarrow> is_f(x,y) \<longleftrightarrow> y = f(x)"

definition
  relation2 :: "[i=>o, [i,i,i]=>o, [i,i]=>i] => o" where
    "relation2(M,is_f,f) == \<forall>x[M]. \<forall>y[M]. \<forall>z[M]. is_f(x,y,z) \<longleftrightarrow> z = f(x,y)"

definition
  Relation2 :: "[i=>o, i, i, [i,i,i]=>o, [i,i]=>i] => o" where
    "Relation2(M,A,B,is_f,f) ==
        \<forall>x[M]. \<forall>y[M]. \<forall>z[M]. x\<in>A \<longrightarrow> y\<in>B \<longrightarrow> is_f(x,y,z) \<longleftrightarrow> z = f(x,y)"

definition
  relation3 :: "[i=>o, [i,i,i,i]=>o, [i,i,i]=>i] => o" where
    "relation3(M,is_f,f) ==
       \<forall>x[M]. \<forall>y[M]. \<forall>z[M]. \<forall>u[M]. is_f(x,y,z,u) \<longleftrightarrow> u = f(x,y,z)"

definition
  Relation3 :: "[i=>o, i, i, i, [i,i,i,i]=>o, [i,i,i]=>i] => o" where
    "Relation3(M,A,B,C,is_f,f) ==
       \<forall>x[M]. \<forall>y[M]. \<forall>z[M]. \<forall>u[M].
         x\<in>A \<longrightarrow> y\<in>B \<longrightarrow> z\<in>C \<longrightarrow> is_f(x,y,z,u) \<longleftrightarrow> u = f(x,y,z)"

definition
  relation4 :: "[i=>o, [i,i,i,i,i]=>o, [i,i,i,i]=>i] => o" where
    "relation4(M,is_f,f) ==
       \<forall>u[M]. \<forall>x[M]. \<forall>y[M]. \<forall>z[M]. \<forall>a[M]. is_f(u,x,y,z,a) \<longleftrightarrow> a = f(u,x,y,z)"


text{*Useful when absoluteness reasoning has replaced the predicates by terms*}
lemma triv_Relation1:
     "Relation1(M, A, \<lambda>x y. y = f(x), f)"
by (simp add: Relation1_def)

lemma triv_Relation2:
     "Relation2(M, A, B, \<lambda>x y a. a = f(x,y), f)"
by (simp add: Relation2_def)


subsection {*The relativized ZF axioms*}

definition
  extensionality :: "(i=>o) => o" where
    "extensionality(M) ==
        \<forall>x[M]. \<forall>y[M]. (\<forall>z[M]. z \<in> x \<longleftrightarrow> z \<in> y) \<longrightarrow> x=y"

definition
  separation :: "[i=>o, i=>o] => o" where
    --{*The formula @{text P} should only involve parameters
        belonging to @{text M} and all its quantifiers must be relativized
        to @{text M}.  We do not have separation as a scheme; every instance
        that we need must be assumed (and later proved) separately.*}
    "separation(M,P) ==
        \<forall>z[M]. \<exists>y[M]. \<forall>x[M]. x \<in> y \<longleftrightarrow> x \<in> z & P(x)"

definition
  upair_ax :: "(i=>o) => o" where
    "upair_ax(M) == \<forall>x[M]. \<forall>y[M]. \<exists>z[M]. upair(M,x,y,z)"

definition
  Union_ax :: "(i=>o) => o" where
    "Union_ax(M) == \<forall>x[M]. \<exists>z[M]. big_union(M,x,z)"

definition
  power_ax :: "(i=>o) => o" where
    "power_ax(M) == \<forall>x[M]. \<exists>z[M]. powerset(M,x,z)"

definition
  univalent :: "[i=>o, i, [i,i]=>o] => o" where
    "univalent(M,A,P) ==
        \<forall>x[M]. x\<in>A \<longrightarrow> (\<forall>y[M]. \<forall>z[M]. P(x,y) & P(x,z) \<longrightarrow> y=z)"

definition
  replacement :: "[i=>o, [i,i]=>o] => o" where
    "replacement(M,P) ==
      \<forall>A[M]. univalent(M,A,P) \<longrightarrow>
      (\<exists>Y[M]. \<forall>b[M]. (\<exists>x[M]. x\<in>A & P(x,b)) \<longrightarrow> b \<in> Y)"

definition
  strong_replacement :: "[i=>o, [i,i]=>o] => o" where
    "strong_replacement(M,P) ==
      \<forall>A[M]. univalent(M,A,P) \<longrightarrow>
      (\<exists>Y[M]. \<forall>b[M]. b \<in> Y \<longleftrightarrow> (\<exists>x[M]. x\<in>A & P(x,b)))"

definition
  foundation_ax :: "(i=>o) => o" where
    "foundation_ax(M) ==
        \<forall>x[M]. (\<exists>y[M]. y\<in>x) \<longrightarrow> (\<exists>y[M]. y\<in>x & ~(\<exists>z[M]. z\<in>x & z \<in> y))"


subsection{*A trivial consistency proof for $V_\omega$ *}

text{*We prove that $V_\omega$
      (or @{text univ} in Isabelle) satisfies some ZF axioms.
     Kunen, Theorem IV 3.13, page 123.*}

lemma univ0_downwards_mem: "[| y \<in> x; x \<in> univ(0) |] ==> y \<in> univ(0)"
apply (insert Transset_univ [OF Transset_0])
apply (simp add: Transset_def, blast)
done

lemma univ0_Ball_abs [simp]:
     "A \<in> univ(0) ==> (\<forall>x\<in>A. x \<in> univ(0) \<longrightarrow> P(x)) \<longleftrightarrow> (\<forall>x\<in>A. P(x))"
by (blast intro: univ0_downwards_mem)

lemma univ0_Bex_abs [simp]:
     "A \<in> univ(0) ==> (\<exists>x\<in>A. x \<in> univ(0) & P(x)) \<longleftrightarrow> (\<exists>x\<in>A. P(x))"
by (blast intro: univ0_downwards_mem)

text{*Congruence rule for separation: can assume the variable is in @{text M}*}
lemma separation_cong [cong]:
     "(!!x. M(x) ==> P(x) \<longleftrightarrow> P'(x))
      ==> separation(M, %x. P(x)) \<longleftrightarrow> separation(M, %x. P'(x))"
by (simp add: separation_def)

lemma univalent_cong [cong]:
     "[| A=A'; !!x y. [| x\<in>A; M(x); M(y) |] ==> P(x,y) \<longleftrightarrow> P'(x,y) |]
      ==> univalent(M, A, %x y. P(x,y)) \<longleftrightarrow> univalent(M, A', %x y. P'(x,y))"
by (simp add: univalent_def)

lemma univalent_triv [intro,simp]:
     "univalent(M, A, \<lambda>x y. y = f(x))"
by (simp add: univalent_def)

lemma univalent_conjI2 [intro,simp]:
     "univalent(M,A,Q) ==> univalent(M, A, \<lambda>x y. P(x,y) & Q(x,y))"
by (simp add: univalent_def, blast)

text{*Congruence rule for replacement*}
lemma strong_replacement_cong [cong]:
     "[| !!x y. [| M(x); M(y) |] ==> P(x,y) \<longleftrightarrow> P'(x,y) |]
      ==> strong_replacement(M, %x y. P(x,y)) \<longleftrightarrow>
          strong_replacement(M, %x y. P'(x,y))"
by (simp add: strong_replacement_def)

text{*The extensionality axiom*}
lemma "extensionality(\<lambda>x. x \<in> univ(0))"
apply (simp add: extensionality_def)
apply (blast intro: univ0_downwards_mem)
done

text{*The separation axiom requires some lemmas*}
lemma Collect_in_Vfrom:
     "[| X \<in> Vfrom(A,j);  Transset(A) |] ==> Collect(X,P) \<in> Vfrom(A, succ(j))"
apply (drule Transset_Vfrom)
apply (rule subset_mem_Vfrom)
apply (unfold Transset_def, blast)
done

lemma Collect_in_VLimit:
     "[| X \<in> Vfrom(A,i);  Limit(i);  Transset(A) |]
      ==> Collect(X,P) \<in> Vfrom(A,i)"
apply (rule Limit_VfromE, assumption+)
apply (blast intro: Limit_has_succ VfromI Collect_in_Vfrom)
done

lemma Collect_in_univ:
     "[| X \<in> univ(A);  Transset(A) |] ==> Collect(X,P) \<in> univ(A)"
by (simp add: univ_def Collect_in_VLimit Limit_nat)

lemma "separation(\<lambda>x. x \<in> univ(0), P)"
apply (simp add: separation_def, clarify)
apply (rule_tac x = "Collect(z,P)" in bexI)
apply (blast intro: Collect_in_univ Transset_0)+
done

text{*Unordered pairing axiom*}
lemma "upair_ax(\<lambda>x. x \<in> univ(0))"
apply (simp add: upair_ax_def upair_def)
apply (blast intro: doubleton_in_univ)
done

text{*Union axiom*}
lemma "Union_ax(\<lambda>x. x \<in> univ(0))"
apply (simp add: Union_ax_def big_union_def, clarify)
apply (rule_tac x="\<Union>x" in bexI)
 apply (blast intro: univ0_downwards_mem)
apply (blast intro: Union_in_univ Transset_0)
done

text{*Powerset axiom*}

lemma Pow_in_univ:
     "[| X \<in> univ(A);  Transset(A) |] ==> Pow(X) \<in> univ(A)"
apply (simp add: univ_def Pow_in_VLimit Limit_nat)
done

lemma "power_ax(\<lambda>x. x \<in> univ(0))"
apply (simp add: power_ax_def powerset_def subset_def, clarify)
apply (rule_tac x="Pow(x)" in bexI)
 apply (blast intro: univ0_downwards_mem)
apply (blast intro: Pow_in_univ Transset_0)
done

text{*Foundation axiom*}
lemma "foundation_ax(\<lambda>x. x \<in> univ(0))"
apply (simp add: foundation_ax_def, clarify)
apply (cut_tac A=x in foundation)
apply (blast intro: univ0_downwards_mem)
done

lemma "replacement(\<lambda>x. x \<in> univ(0), P)"
apply (simp add: replacement_def, clarify)
oops
text{*no idea: maybe prove by induction on the rank of A?*}

text{*Still missing: Replacement, Choice*}

subsection{*Lemmas Needed to Reduce Some Set Constructions to Instances
      of Separation*}

lemma image_iff_Collect: "r `` A = {y \<in> \<Union>(\<Union>(r)). \<exists>p\<in>r. \<exists>x\<in>A. p=<x,y>}"
apply (rule equalityI, auto)
apply (simp add: Pair_def, blast)
done

lemma vimage_iff_Collect:
     "r -`` A = {x \<in> \<Union>(\<Union>(r)). \<exists>p\<in>r. \<exists>y\<in>A. p=<x,y>}"
apply (rule equalityI, auto)
apply (simp add: Pair_def, blast)
done

text{*These two lemmas lets us prove @{text domain_closed} and
      @{text range_closed} without new instances of separation*}

lemma domain_eq_vimage: "domain(r) = r -`` Union(Union(r))"
apply (rule equalityI, auto)
apply (rule vimageI, assumption)
apply (simp add: Pair_def, blast)
done

lemma range_eq_image: "range(r) = r `` Union(Union(r))"
apply (rule equalityI, auto)
apply (rule imageI, assumption)
apply (simp add: Pair_def, blast)
done

lemma replacementD:
    "[| replacement(M,P); M(A);  univalent(M,A,P) |]
     ==> \<exists>Y[M]. (\<forall>b[M]. ((\<exists>x[M]. x\<in>A & P(x,b)) \<longrightarrow> b \<in> Y))"
by (simp add: replacement_def)

lemma strong_replacementD:
    "[| strong_replacement(M,P); M(A);  univalent(M,A,P) |]
     ==> \<exists>Y[M]. (\<forall>b[M]. (b \<in> Y \<longleftrightarrow> (\<exists>x[M]. x\<in>A & P(x,b))))"
by (simp add: strong_replacement_def)

lemma separationD:
    "[| separation(M,P); M(z) |] ==> \<exists>y[M]. \<forall>x[M]. x \<in> y \<longleftrightarrow> x \<in> z & P(x)"
by (simp add: separation_def)


text{*More constants, for order types*}

definition
  order_isomorphism :: "[i=>o,i,i,i,i,i] => o" where
    "order_isomorphism(M,A,r,B,s,f) ==
        bijection(M,A,B,f) &
        (\<forall>x[M]. x\<in>A \<longrightarrow> (\<forall>y[M]. y\<in>A \<longrightarrow>
          (\<forall>p[M]. \<forall>fx[M]. \<forall>fy[M]. \<forall>q[M].
            pair(M,x,y,p) \<longrightarrow> fun_apply(M,f,x,fx) \<longrightarrow> fun_apply(M,f,y,fy) \<longrightarrow>
            pair(M,fx,fy,q) \<longrightarrow> (p\<in>r \<longleftrightarrow> q\<in>s))))"

definition
  pred_set :: "[i=>o,i,i,i,i] => o" where
    "pred_set(M,A,x,r,B) ==
        \<forall>y[M]. y \<in> B \<longleftrightarrow> (\<exists>p[M]. p\<in>r & y \<in> A & pair(M,y,x,p))"

definition
  membership :: "[i=>o,i,i] => o" where --{*membership relation*}
    "membership(M,A,r) ==
        \<forall>p[M]. p \<in> r \<longleftrightarrow> (\<exists>x[M]. x\<in>A & (\<exists>y[M]. y\<in>A & x\<in>y & pair(M,x,y,p)))"


subsection{*Introducing a Transitive Class Model*}

text{*The class M is assumed to be transitive and to satisfy some
      relativized ZF axioms*}
locale M_trivial =
  fixes M
  assumes transM:           "[| y\<in>x; M(x) |] ==> M(y)"
      and upair_ax:         "upair_ax(M)"
      and Union_ax:         "Union_ax(M)"
      and power_ax:         "power_ax(M)"
      and replacement:      "replacement(M,P)"
      and M_nat [iff]:      "M(nat)"           (*i.e. the axiom of infinity*)


text{*Automatically discovers the proof using @{text transM}, @{text nat_0I}
and @{text M_nat}.*}
lemma (in M_trivial) nonempty [simp]: "M(0)"
by (blast intro: transM)

lemma (in M_trivial) rall_abs [simp]:
     "M(A) ==> (\<forall>x[M]. x\<in>A \<longrightarrow> P(x)) \<longleftrightarrow> (\<forall>x\<in>A. P(x))"
by (blast intro: transM)

lemma (in M_trivial) rex_abs [simp]:
     "M(A) ==> (\<exists>x[M]. x\<in>A & P(x)) \<longleftrightarrow> (\<exists>x\<in>A. P(x))"
by (blast intro: transM)

lemma (in M_trivial) ball_iff_equiv:
     "M(A) ==> (\<forall>x[M]. (x\<in>A \<longleftrightarrow> P(x))) \<longleftrightarrow>
               (\<forall>x\<in>A. P(x)) & (\<forall>x. P(x) \<longrightarrow> M(x) \<longrightarrow> x\<in>A)"
by (blast intro: transM)

text{*Simplifies proofs of equalities when there's an iff-equality
      available for rewriting, universally quantified over M.
      But it's not the only way to prove such equalities: its
      premises @{term "M(A)"} and  @{term "M(B)"} can be too strong.*}
lemma (in M_trivial) M_equalityI:
     "[| !!x. M(x) ==> x\<in>A \<longleftrightarrow> x\<in>B; M(A); M(B) |] ==> A=B"
by (blast intro!: equalityI dest: transM)


subsubsection{*Trivial Absoluteness Proofs: Empty Set, Pairs, etc.*}

lemma (in M_trivial) empty_abs [simp]:
     "M(z) ==> empty(M,z) \<longleftrightarrow> z=0"
apply (simp add: empty_def)
apply (blast intro: transM)
done

lemma (in M_trivial) subset_abs [simp]:
     "M(A) ==> subset(M,A,B) \<longleftrightarrow> A \<subseteq> B"
apply (simp add: subset_def)
apply (blast intro: transM)
done

lemma (in M_trivial) upair_abs [simp]:
     "M(z) ==> upair(M,a,b,z) \<longleftrightarrow> z={a,b}"
apply (simp add: upair_def)
apply (blast intro: transM)
done

lemma (in M_trivial) upair_in_M_iff [iff]:
     "M({a,b}) \<longleftrightarrow> M(a) & M(b)"
apply (insert upair_ax, simp add: upair_ax_def)
apply (blast intro: transM)
done

lemma (in M_trivial) singleton_in_M_iff [iff]:
     "M({a}) \<longleftrightarrow> M(a)"
by (insert upair_in_M_iff [of a a], simp)

lemma (in M_trivial) pair_abs [simp]:
     "M(z) ==> pair(M,a,b,z) \<longleftrightarrow> z=<a,b>"
apply (simp add: pair_def ZF.Pair_def)
apply (blast intro: transM)
done

lemma (in M_trivial) pair_in_M_iff [iff]:
     "M(<a,b>) \<longleftrightarrow> M(a) & M(b)"
by (simp add: ZF.Pair_def)

lemma (in M_trivial) pair_components_in_M:
     "[| <x,y> \<in> A; M(A) |] ==> M(x) & M(y)"
apply (simp add: Pair_def)
apply (blast dest: transM)
done

lemma (in M_trivial) cartprod_abs [simp]:
     "[| M(A); M(B); M(z) |] ==> cartprod(M,A,B,z) \<longleftrightarrow> z = A*B"
apply (simp add: cartprod_def)
apply (rule iffI)
 apply (blast intro!: equalityI intro: transM dest!: rspec)
apply (blast dest: transM)
done

subsubsection{*Absoluteness for Unions and Intersections*}

lemma (in M_trivial) union_abs [simp]:
     "[| M(a); M(b); M(z) |] ==> union(M,a,b,z) \<longleftrightarrow> z = a \<union> b"
apply (simp add: union_def)
apply (blast intro: transM)
done

lemma (in M_trivial) inter_abs [simp]:
     "[| M(a); M(b); M(z) |] ==> inter(M,a,b,z) \<longleftrightarrow> z = a \<inter> b"
apply (simp add: inter_def)
apply (blast intro: transM)
done

lemma (in M_trivial) setdiff_abs [simp]:
     "[| M(a); M(b); M(z) |] ==> setdiff(M,a,b,z) \<longleftrightarrow> z = a-b"
apply (simp add: setdiff_def)
apply (blast intro: transM)
done

lemma (in M_trivial) Union_abs [simp]:
     "[| M(A); M(z) |] ==> big_union(M,A,z) \<longleftrightarrow> z = \<Union>(A)"
apply (simp add: big_union_def)
apply (blast intro!: equalityI dest: transM)
done

lemma (in M_trivial) Union_closed [intro,simp]:
     "M(A) ==> M(\<Union>(A))"
by (insert Union_ax, simp add: Union_ax_def)

lemma (in M_trivial) Un_closed [intro,simp]:
     "[| M(A); M(B) |] ==> M(A \<union> B)"
by (simp only: Un_eq_Union, blast)

lemma (in M_trivial) cons_closed [intro,simp]:
     "[| M(a); M(A) |] ==> M(cons(a,A))"
by (subst cons_eq [symmetric], blast)

lemma (in M_trivial) cons_abs [simp]:
     "[| M(b); M(z) |] ==> is_cons(M,a,b,z) \<longleftrightarrow> z = cons(a,b)"
by (simp add: is_cons_def, blast intro: transM)

lemma (in M_trivial) successor_abs [simp]:
     "[| M(a); M(z) |] ==> successor(M,a,z) \<longleftrightarrow> z = succ(a)"
by (simp add: successor_def, blast)

lemma (in M_trivial) succ_in_M_iff [iff]:
     "M(succ(a)) \<longleftrightarrow> M(a)"
apply (simp add: succ_def)
apply (blast intro: transM)
done

subsubsection{*Absoluteness for Separation and Replacement*}

lemma (in M_trivial) separation_closed [intro,simp]:
     "[| separation(M,P); M(A) |] ==> M(Collect(A,P))"
apply (insert separation, simp add: separation_def)
apply (drule rspec, assumption, clarify)
apply (subgoal_tac "y = Collect(A,P)", blast)
apply (blast dest: transM)
done

lemma separation_iff:
     "separation(M,P) \<longleftrightarrow> (\<forall>z[M]. \<exists>y[M]. is_Collect(M,z,P,y))"
by (simp add: separation_def is_Collect_def)

lemma (in M_trivial) Collect_abs [simp]:
     "[| M(A); M(z) |] ==> is_Collect(M,A,P,z) \<longleftrightarrow> z = Collect(A,P)"
apply (simp add: is_Collect_def)
apply (blast intro!: equalityI dest: transM)
done

text{*Probably the premise and conclusion are equivalent*}
lemma (in M_trivial) strong_replacementI [rule_format]:
    "[| \<forall>B[M]. separation(M, %u. \<exists>x[M]. x\<in>B & P(x,u)) |]
     ==> strong_replacement(M,P)"
apply (simp add: strong_replacement_def, clarify)
apply (frule replacementD [OF replacement], assumption, clarify)
apply (drule_tac x=A in rspec, clarify)
apply (drule_tac z=Y in separationD, assumption, clarify)
apply (rule_tac x=y in rexI, force, assumption)
done

subsubsection{*The Operator @{term is_Replace}*}


lemma is_Replace_cong [cong]:
     "[| A=A';
         !!x y. [| M(x); M(y) |] ==> P(x,y) \<longleftrightarrow> P'(x,y);
         z=z' |]
      ==> is_Replace(M, A, %x y. P(x,y), z) \<longleftrightarrow>
          is_Replace(M, A', %x y. P'(x,y), z')"
by (simp add: is_Replace_def)

lemma (in M_trivial) univalent_Replace_iff:
     "[| M(A); univalent(M,A,P);
         !!x y. [| x\<in>A; P(x,y) |] ==> M(y) |]
      ==> u \<in> Replace(A,P) \<longleftrightarrow> (\<exists>x. x\<in>A & P(x,u))"
apply (simp add: Replace_iff univalent_def)
apply (blast dest: transM)
done

(*The last premise expresses that P takes M to M*)
lemma (in M_trivial) strong_replacement_closed [intro,simp]:
     "[| strong_replacement(M,P); M(A); univalent(M,A,P);
         !!x y. [| x\<in>A; P(x,y) |] ==> M(y) |] ==> M(Replace(A,P))"
apply (simp add: strong_replacement_def)
apply (drule_tac x=A in rspec, safe)
apply (subgoal_tac "Replace(A,P) = Y")
 apply simp
apply (rule equality_iffI)
apply (simp add: univalent_Replace_iff)
apply (blast dest: transM)
done

lemma (in M_trivial) Replace_abs:
     "[| M(A); M(z); univalent(M,A,P);
         !!x y. [| x\<in>A; P(x,y) |] ==> M(y)  |]
      ==> is_Replace(M,A,P,z) \<longleftrightarrow> z = Replace(A,P)"
apply (simp add: is_Replace_def)
apply (rule iffI)
 apply (rule equality_iffI)
 apply (simp_all add: univalent_Replace_iff)
 apply (blast dest: transM)+
done


(*The first premise can't simply be assumed as a schema.
  It is essential to take care when asserting instances of Replacement.
  Let K be a nonconstructible subset of nat and define
  f(x) = x if x \<in> K and f(x)=0 otherwise.  Then RepFun(nat,f) = cons(0,K), a
  nonconstructible set.  So we cannot assume that M(X) implies M(RepFun(X,f))
  even for f \<in> M -> M.
*)
lemma (in M_trivial) RepFun_closed:
     "[| strong_replacement(M, \<lambda>x y. y = f(x)); M(A); \<forall>x\<in>A. M(f(x)) |]
      ==> M(RepFun(A,f))"
apply (simp add: RepFun_def)
apply (rule strong_replacement_closed)
apply (auto dest: transM  simp add: univalent_def)
done

lemma Replace_conj_eq: "{y . x \<in> A, x\<in>A & y=f(x)} = {y . x\<in>A, y=f(x)}"
by simp

text{*Better than @{text RepFun_closed} when having the formula @{term "x\<in>A"}
      makes relativization easier.*}
lemma (in M_trivial) RepFun_closed2:
     "[| strong_replacement(M, \<lambda>x y. x\<in>A & y = f(x)); M(A); \<forall>x\<in>A. M(f(x)) |]
      ==> M(RepFun(A, %x. f(x)))"
apply (simp add: RepFun_def)
apply (frule strong_replacement_closed, assumption)
apply (auto dest: transM  simp add: Replace_conj_eq univalent_def)
done

subsubsection {*Absoluteness for @{term Lambda}*}

definition
 is_lambda :: "[i=>o, i, [i,i]=>o, i] => o" where
    "is_lambda(M, A, is_b, z) ==
       \<forall>p[M]. p \<in> z \<longleftrightarrow>
        (\<exists>u[M]. \<exists>v[M]. u\<in>A & pair(M,u,v,p) & is_b(u,v))"

lemma (in M_trivial) lam_closed:
     "[| strong_replacement(M, \<lambda>x y. y = <x,b(x)>); M(A); \<forall>x\<in>A. M(b(x)) |]
      ==> M(\<lambda>x\<in>A. b(x))"
by (simp add: lam_def, blast intro: RepFun_closed dest: transM)

text{*Better than @{text lam_closed}: has the formula @{term "x\<in>A"}*}
lemma (in M_trivial) lam_closed2:
  "[|strong_replacement(M, \<lambda>x y. x\<in>A & y = \<langle>x, b(x)\<rangle>);
     M(A); \<forall>m[M]. m\<in>A \<longrightarrow> M(b(m))|] ==> M(Lambda(A,b))"
apply (simp add: lam_def)
apply (blast intro: RepFun_closed2 dest: transM)
done

lemma (in M_trivial) lambda_abs2:
     "[| Relation1(M,A,is_b,b); M(A); \<forall>m[M]. m\<in>A \<longrightarrow> M(b(m)); M(z) |]
      ==> is_lambda(M,A,is_b,z) \<longleftrightarrow> z = Lambda(A,b)"
apply (simp add: Relation1_def is_lambda_def)
apply (rule iffI)
 prefer 2 apply (simp add: lam_def)
apply (rule equality_iffI)
apply (simp add: lam_def)
apply (rule iffI)
 apply (blast dest: transM)
apply (auto simp add: transM [of _ A])
done

lemma is_lambda_cong [cong]:
     "[| A=A';  z=z';
         !!x y. [| x\<in>A; M(x); M(y) |] ==> is_b(x,y) \<longleftrightarrow> is_b'(x,y) |]
      ==> is_lambda(M, A, %x y. is_b(x,y), z) \<longleftrightarrow>
          is_lambda(M, A', %x y. is_b'(x,y), z')"
by (simp add: is_lambda_def)

lemma (in M_trivial) image_abs [simp]:
     "[| M(r); M(A); M(z) |] ==> image(M,r,A,z) \<longleftrightarrow> z = r``A"
apply (simp add: image_def)
apply (rule iffI)
 apply (blast intro!: equalityI dest: transM, blast)
done

text{*What about @{text Pow_abs}?  Powerset is NOT absolute!
      This result is one direction of absoluteness.*}

lemma (in M_trivial) powerset_Pow:
     "powerset(M, x, Pow(x))"
by (simp add: powerset_def)

text{*But we can't prove that the powerset in @{text M} includes the
      real powerset.*}
lemma (in M_trivial) powerset_imp_subset_Pow:
     "[| powerset(M,x,y); M(y) |] ==> y \<subseteq> Pow(x)"
apply (simp add: powerset_def)
apply (blast dest: transM)
done

subsubsection{*Absoluteness for the Natural Numbers*}

lemma (in M_trivial) nat_into_M [intro]:
     "n \<in> nat ==> M(n)"
by (induct n rule: nat_induct, simp_all)

lemma (in M_trivial) nat_case_closed [intro,simp]:
  "[|M(k); M(a); \<forall>m[M]. M(b(m))|] ==> M(nat_case(a,b,k))"
apply (case_tac "k=0", simp)
apply (case_tac "\<exists>m. k = succ(m)", force)
apply (simp add: nat_case_def)
done

lemma (in M_trivial) quasinat_abs [simp]:
     "M(z) ==> is_quasinat(M,z) \<longleftrightarrow> quasinat(z)"
by (auto simp add: is_quasinat_def quasinat_def)

lemma (in M_trivial) nat_case_abs [simp]:
     "[| relation1(M,is_b,b); M(k); M(z) |]
      ==> is_nat_case(M,a,is_b,k,z) \<longleftrightarrow> z = nat_case(a,b,k)"
apply (case_tac "quasinat(k)")
 prefer 2
 apply (simp add: is_nat_case_def non_nat_case)
 apply (force simp add: quasinat_def)
apply (simp add: quasinat_def is_nat_case_def)
apply (elim disjE exE)
 apply (simp_all add: relation1_def)
done

(*NOT for the simplifier.  The assumption M(z') is apparently necessary, but
  causes the error "Failed congruence proof!"  It may be better to replace
  is_nat_case by nat_case before attempting congruence reasoning.*)
lemma is_nat_case_cong:
     "[| a = a'; k = k';  z = z';  M(z');
       !!x y. [| M(x); M(y) |] ==> is_b(x,y) \<longleftrightarrow> is_b'(x,y) |]
      ==> is_nat_case(M, a, is_b, k, z) \<longleftrightarrow> is_nat_case(M, a', is_b', k', z')"
by (simp add: is_nat_case_def)


subsection{*Absoluteness for Ordinals*}
text{*These results constitute Theorem IV 5.1 of Kunen (page 126).*}

lemma (in M_trivial) lt_closed:
     "[| j<i; M(i) |] ==> M(j)"
by (blast dest: ltD intro: transM)

lemma (in M_trivial) transitive_set_abs [simp]:
     "M(a) ==> transitive_set(M,a) \<longleftrightarrow> Transset(a)"
by (simp add: transitive_set_def Transset_def)

lemma (in M_trivial) ordinal_abs [simp]:
     "M(a) ==> ordinal(M,a) \<longleftrightarrow> Ord(a)"
by (simp add: ordinal_def Ord_def)

lemma (in M_trivial) limit_ordinal_abs [simp]:
     "M(a) ==> limit_ordinal(M,a) \<longleftrightarrow> Limit(a)"
apply (unfold Limit_def limit_ordinal_def)
apply (simp add: Ord_0_lt_iff)
apply (simp add: lt_def, blast)
done

lemma (in M_trivial) successor_ordinal_abs [simp]:
     "M(a) ==> successor_ordinal(M,a) \<longleftrightarrow> Ord(a) & (\<exists>b[M]. a = succ(b))"
apply (simp add: successor_ordinal_def, safe)
apply (drule Ord_cases_disj, auto)
done

lemma finite_Ord_is_nat:
      "[| Ord(a); ~ Limit(a); \<forall>x\<in>a. ~ Limit(x) |] ==> a \<in> nat"
by (induct a rule: trans_induct3, simp_all)

lemma (in M_trivial) finite_ordinal_abs [simp]:
     "M(a) ==> finite_ordinal(M,a) \<longleftrightarrow> a \<in> nat"
apply (simp add: finite_ordinal_def)
apply (blast intro: finite_Ord_is_nat intro: nat_into_Ord
             dest: Ord_trans naturals_not_limit)
done

lemma Limit_non_Limit_implies_nat:
     "[| Limit(a); \<forall>x\<in>a. ~ Limit(x) |] ==> a = nat"
apply (rule le_anti_sym)
apply (rule all_lt_imp_le, blast, blast intro: Limit_is_Ord)
 apply (simp add: lt_def)
 apply (blast intro: Ord_in_Ord Ord_trans finite_Ord_is_nat)
apply (erule nat_le_Limit)
done

lemma (in M_trivial) omega_abs [simp]:
     "M(a) ==> omega(M,a) \<longleftrightarrow> a = nat"
apply (simp add: omega_def)
apply (blast intro: Limit_non_Limit_implies_nat dest: naturals_not_limit)
done

lemma (in M_trivial) number1_abs [simp]:
     "M(a) ==> number1(M,a) \<longleftrightarrow> a = 1"
by (simp add: number1_def)

lemma (in M_trivial) number2_abs [simp]:
     "M(a) ==> number2(M,a) \<longleftrightarrow> a = succ(1)"
by (simp add: number2_def)

lemma (in M_trivial) number3_abs [simp]:
     "M(a) ==> number3(M,a) \<longleftrightarrow> a = succ(succ(1))"
by (simp add: number3_def)

text{*Kunen continued to 20...*}

(*Could not get this to work.  The \<lambda>x\<in>nat is essential because everything
  but the recursion variable must stay unchanged.  But then the recursion
  equations only hold for x\<in>nat (or in some other set) and not for the
  whole of the class M.
  consts
    natnumber_aux :: "[i=>o,i] => i"

  primrec
      "natnumber_aux(M,0) = (\<lambda>x\<in>nat. if empty(M,x) then 1 else 0)"
      "natnumber_aux(M,succ(n)) =
           (\<lambda>x\<in>nat. if (\<exists>y[M]. natnumber_aux(M,n)`y=1 & successor(M,y,x))
                     then 1 else 0)"

  definition
    natnumber :: "[i=>o,i,i] => o"
      "natnumber(M,n,x) == natnumber_aux(M,n)`x = 1"

  lemma (in M_trivial) [simp]:
       "natnumber(M,0,x) == x=0"
*)

subsection{*Some instances of separation and strong replacement*}

locale M_basic = M_trivial +
assumes Inter_separation:
     "M(A) ==> separation(M, \<lambda>x. \<forall>y[M]. y\<in>A \<longrightarrow> x\<in>y)"
  and Diff_separation:
     "M(B) ==> separation(M, \<lambda>x. x \<notin> B)"
  and cartprod_separation:
     "[| M(A); M(B) |]
      ==> separation(M, \<lambda>z. \<exists>x[M]. x\<in>A & (\<exists>y[M]. y\<in>B & pair(M,x,y,z)))"
  and image_separation:
     "[| M(A); M(r) |]
      ==> separation(M, \<lambda>y. \<exists>p[M]. p\<in>r & (\<exists>x[M]. x\<in>A & pair(M,x,y,p)))"
  and converse_separation:
     "M(r) ==> separation(M,
         \<lambda>z. \<exists>p[M]. p\<in>r & (\<exists>x[M]. \<exists>y[M]. pair(M,x,y,p) & pair(M,y,x,z)))"
  and restrict_separation:
     "M(A) ==> separation(M, \<lambda>z. \<exists>x[M]. x\<in>A & (\<exists>y[M]. pair(M,x,y,z)))"
  and comp_separation:
     "[| M(r); M(s) |]
      ==> separation(M, \<lambda>xz. \<exists>x[M]. \<exists>y[M]. \<exists>z[M]. \<exists>xy[M]. \<exists>yz[M].
                  pair(M,x,z,xz) & pair(M,x,y,xy) & pair(M,y,z,yz) &
                  xy\<in>s & yz\<in>r)"
  and pred_separation:
     "[| M(r); M(x) |] ==> separation(M, \<lambda>y. \<exists>p[M]. p\<in>r & pair(M,y,x,p))"
  and Memrel_separation:
     "separation(M, \<lambda>z. \<exists>x[M]. \<exists>y[M]. pair(M,x,y,z) & x \<in> y)"
  and funspace_succ_replacement:
     "M(n) ==>
      strong_replacement(M, \<lambda>p z. \<exists>f[M]. \<exists>b[M]. \<exists>nb[M]. \<exists>cnbf[M].
                pair(M,f,b,p) & pair(M,n,b,nb) & is_cons(M,nb,f,cnbf) &
                upair(M,cnbf,cnbf,z))"
  and is_recfun_separation:
     --{*for well-founded recursion: used to prove @{text is_recfun_equal}*}
     "[| M(r); M(f); M(g); M(a); M(b) |]
     ==> separation(M,
            \<lambda>x. \<exists>xa[M]. \<exists>xb[M].
                pair(M,x,a,xa) & xa \<in> r & pair(M,x,b,xb) & xb \<in> r &
                (\<exists>fx[M]. \<exists>gx[M]. fun_apply(M,f,x,fx) & fun_apply(M,g,x,gx) &
                                   fx \<noteq> gx))"

lemma (in M_basic) cartprod_iff_lemma:
     "[| M(C);  \<forall>u[M]. u \<in> C \<longleftrightarrow> (\<exists>x\<in>A. \<exists>y\<in>B. u = {{x}, {x,y}});
         powerset(M, A \<union> B, p1); powerset(M, p1, p2);  M(p2) |]
       ==> C = {u \<in> p2 . \<exists>x\<in>A. \<exists>y\<in>B. u = {{x}, {x,y}}}"
apply (simp add: powerset_def)
apply (rule equalityI, clarify, simp)
 apply (frule transM, assumption)
 apply (frule transM, assumption, simp (no_asm_simp))
 apply blast
apply clarify
apply (frule transM, assumption, force)
done

lemma (in M_basic) cartprod_iff:
     "[| M(A); M(B); M(C) |]
      ==> cartprod(M,A,B,C) \<longleftrightarrow>
          (\<exists>p1[M]. \<exists>p2[M]. powerset(M,A \<union> B,p1) & powerset(M,p1,p2) &
                   C = {z \<in> p2. \<exists>x\<in>A. \<exists>y\<in>B. z = <x,y>})"
apply (simp add: Pair_def cartprod_def, safe)
defer 1
  apply (simp add: powerset_def)
 apply blast
txt{*Final, difficult case: the left-to-right direction of the theorem.*}
apply (insert power_ax, simp add: power_ax_def)
apply (frule_tac x="A \<union> B" and P="\<lambda>x. rex(M,?Q(x))" in rspec)
apply (blast, clarify)
apply (drule_tac x=z and P="\<lambda>x. rex(M,?Q(x))" in rspec)
apply assumption
apply (blast intro: cartprod_iff_lemma)
done

lemma (in M_basic) cartprod_closed_lemma:
     "[| M(A); M(B) |] ==> \<exists>C[M]. cartprod(M,A,B,C)"
apply (simp del: cartprod_abs add: cartprod_iff)
apply (insert power_ax, simp add: power_ax_def)
apply (frule_tac x="A \<union> B" and P="\<lambda>x. rex(M,?Q(x))" in rspec)
apply (blast, clarify)
apply (drule_tac x=z and P="\<lambda>x. rex(M,?Q(x))" in rspec, auto)
apply (intro rexI conjI, simp+)
apply (insert cartprod_separation [of A B], simp)
done

text{*All the lemmas above are necessary because Powerset is not absolute.
      I should have used Replacement instead!*}
lemma (in M_basic) cartprod_closed [intro,simp]:
     "[| M(A); M(B) |] ==> M(A*B)"
by (frule cartprod_closed_lemma, assumption, force)

lemma (in M_basic) sum_closed [intro,simp]:
     "[| M(A); M(B) |] ==> M(A+B)"
by (simp add: sum_def)

lemma (in M_basic) sum_abs [simp]:
     "[| M(A); M(B); M(Z) |] ==> is_sum(M,A,B,Z) \<longleftrightarrow> (Z = A+B)"
by (simp add: is_sum_def sum_def singleton_0 nat_into_M)

lemma (in M_trivial) Inl_in_M_iff [iff]:
     "M(Inl(a)) \<longleftrightarrow> M(a)"
by (simp add: Inl_def)

lemma (in M_trivial) Inl_abs [simp]:
     "M(Z) ==> is_Inl(M,a,Z) \<longleftrightarrow> (Z = Inl(a))"
by (simp add: is_Inl_def Inl_def)

lemma (in M_trivial) Inr_in_M_iff [iff]:
     "M(Inr(a)) \<longleftrightarrow> M(a)"
by (simp add: Inr_def)

lemma (in M_trivial) Inr_abs [simp]:
     "M(Z) ==> is_Inr(M,a,Z) \<longleftrightarrow> (Z = Inr(a))"
by (simp add: is_Inr_def Inr_def)


subsubsection {*converse of a relation*}

lemma (in M_basic) M_converse_iff:
     "M(r) ==>
      converse(r) =
      {z \<in> \<Union>(\<Union>(r)) * \<Union>(\<Union>(r)).
       \<exists>p\<in>r. \<exists>x[M]. \<exists>y[M]. p = \<langle>x,y\<rangle> & z = \<langle>y,x\<rangle>}"
apply (rule equalityI)
 prefer 2 apply (blast dest: transM, clarify, simp)
apply (simp add: Pair_def)
apply (blast dest: transM)
done

lemma (in M_basic) converse_closed [intro,simp]:
     "M(r) ==> M(converse(r))"
apply (simp add: M_converse_iff)
apply (insert converse_separation [of r], simp)
done

lemma (in M_basic) converse_abs [simp]:
     "[| M(r); M(z) |] ==> is_converse(M,r,z) \<longleftrightarrow> z = converse(r)"
apply (simp add: is_converse_def)
apply (rule iffI)
 prefer 2 apply blast
apply (rule M_equalityI)
  apply simp
  apply (blast dest: transM)+
done


subsubsection {*image, preimage, domain, range*}

lemma (in M_basic) image_closed [intro,simp]:
     "[| M(A); M(r) |] ==> M(r``A)"
apply (simp add: image_iff_Collect)
apply (insert image_separation [of A r], simp)
done

lemma (in M_basic) vimage_abs [simp]:
     "[| M(r); M(A); M(z) |] ==> pre_image(M,r,A,z) \<longleftrightarrow> z = r-``A"
apply (simp add: pre_image_def)
apply (rule iffI)
 apply (blast intro!: equalityI dest: transM, blast)
done

lemma (in M_basic) vimage_closed [intro,simp]:
     "[| M(A); M(r) |] ==> M(r-``A)"
by (simp add: vimage_def)


subsubsection{*Domain, range and field*}

lemma (in M_basic) domain_abs [simp]:
     "[| M(r); M(z) |] ==> is_domain(M,r,z) \<longleftrightarrow> z = domain(r)"
apply (simp add: is_domain_def)
apply (blast intro!: equalityI dest: transM)
done

lemma (in M_basic) domain_closed [intro,simp]:
     "M(r) ==> M(domain(r))"
apply (simp add: domain_eq_vimage)
done

lemma (in M_basic) range_abs [simp]:
     "[| M(r); M(z) |] ==> is_range(M,r,z) \<longleftrightarrow> z = range(r)"
apply (simp add: is_range_def)
apply (blast intro!: equalityI dest: transM)
done

lemma (in M_basic) range_closed [intro,simp]:
     "M(r) ==> M(range(r))"
apply (simp add: range_eq_image)
done

lemma (in M_basic) field_abs [simp]:
     "[| M(r); M(z) |] ==> is_field(M,r,z) \<longleftrightarrow> z = field(r)"
by (simp add: domain_closed range_closed is_field_def field_def)

lemma (in M_basic) field_closed [intro,simp]:
     "M(r) ==> M(field(r))"
by (simp add: domain_closed range_closed Un_closed field_def)


subsubsection{*Relations, functions and application*}

lemma (in M_basic) relation_abs [simp]:
     "M(r) ==> is_relation(M,r) \<longleftrightarrow> relation(r)"
apply (simp add: is_relation_def relation_def)
apply (blast dest!: bspec dest: pair_components_in_M)+
done

lemma (in M_basic) function_abs [simp]:
     "M(r) ==> is_function(M,r) \<longleftrightarrow> function(r)"
apply (simp add: is_function_def function_def, safe)
   apply (frule transM, assumption)
  apply (blast dest: pair_components_in_M)+
done

lemma (in M_basic) apply_closed [intro,simp]:
     "[|M(f); M(a)|] ==> M(f`a)"
by (simp add: apply_def)

lemma (in M_basic) apply_abs [simp]:
     "[| M(f); M(x); M(y) |] ==> fun_apply(M,f,x,y) \<longleftrightarrow> f`x = y"
apply (simp add: fun_apply_def apply_def, blast)
done

lemma (in M_basic) typed_function_abs [simp]:
     "[| M(A); M(f) |] ==> typed_function(M,A,B,f) \<longleftrightarrow> f \<in> A -> B"
apply (auto simp add: typed_function_def relation_def Pi_iff)
apply (blast dest: pair_components_in_M)+
done

lemma (in M_basic) injection_abs [simp]:
     "[| M(A); M(f) |] ==> injection(M,A,B,f) \<longleftrightarrow> f \<in> inj(A,B)"
apply (simp add: injection_def apply_iff inj_def apply_closed)
apply (blast dest: transM [of _ A])
done

lemma (in M_basic) surjection_abs [simp]:
     "[| M(A); M(B); M(f) |] ==> surjection(M,A,B,f) \<longleftrightarrow> f \<in> surj(A,B)"
by (simp add: surjection_def surj_def)

lemma (in M_basic) bijection_abs [simp]:
     "[| M(A); M(B); M(f) |] ==> bijection(M,A,B,f) \<longleftrightarrow> f \<in> bij(A,B)"
by (simp add: bijection_def bij_def)


subsubsection{*Composition of relations*}

lemma (in M_basic) M_comp_iff:
     "[| M(r); M(s) |]
      ==> r O s =
          {xz \<in> domain(s) * range(r).
            \<exists>x[M]. \<exists>y[M]. \<exists>z[M]. xz = \<langle>x,z\<rangle> & \<langle>x,y\<rangle> \<in> s & \<langle>y,z\<rangle> \<in> r}"
apply (simp add: comp_def)
apply (rule equalityI)
 apply clarify
 apply simp
 apply  (blast dest:  transM)+
done

lemma (in M_basic) comp_closed [intro,simp]:
     "[| M(r); M(s) |] ==> M(r O s)"
apply (simp add: M_comp_iff)
apply (insert comp_separation [of r s], simp)
done

lemma (in M_basic) composition_abs [simp]:
     "[| M(r); M(s); M(t) |] ==> composition(M,r,s,t) \<longleftrightarrow> t = r O s"
apply safe
 txt{*Proving @{term "composition(M, r, s, r O s)"}*}
 prefer 2
 apply (simp add: composition_def comp_def)
 apply (blast dest: transM)
txt{*Opposite implication*}
apply (rule M_equalityI)
  apply (simp add: composition_def comp_def)
  apply (blast del: allE dest: transM)+
done

text{*no longer needed*}
lemma (in M_basic) restriction_is_function:
     "[| restriction(M,f,A,z); function(f); M(f); M(A); M(z) |]
      ==> function(z)"
apply (simp add: restriction_def ball_iff_equiv)
apply (unfold function_def, blast)
done

lemma (in M_basic) restriction_abs [simp]:
     "[| M(f); M(A); M(z) |]
      ==> restriction(M,f,A,z) \<longleftrightarrow> z = restrict(f,A)"
apply (simp add: ball_iff_equiv restriction_def restrict_def)
apply (blast intro!: equalityI dest: transM)
done


lemma (in M_basic) M_restrict_iff:
     "M(r) ==> restrict(r,A) = {z \<in> r . \<exists>x\<in>A. \<exists>y[M]. z = \<langle>x, y\<rangle>}"
by (simp add: restrict_def, blast dest: transM)

lemma (in M_basic) restrict_closed [intro,simp]:
     "[| M(A); M(r) |] ==> M(restrict(r,A))"
apply (simp add: M_restrict_iff)
apply (insert restrict_separation [of A], simp)
done

lemma (in M_basic) Inter_abs [simp]:
     "[| M(A); M(z) |] ==> big_inter(M,A,z) \<longleftrightarrow> z = \<Inter>(A)"
apply (simp add: big_inter_def Inter_def)
apply (blast intro!: equalityI dest: transM)
done

lemma (in M_basic) Inter_closed [intro,simp]:
     "M(A) ==> M(\<Inter>(A))"
by (insert Inter_separation, simp add: Inter_def)

lemma (in M_basic) Int_closed [intro,simp]:
     "[| M(A); M(B) |] ==> M(A \<inter> B)"
apply (subgoal_tac "M({A,B})")
apply (frule Inter_closed, force+)
done

lemma (in M_basic) Diff_closed [intro,simp]:
     "[|M(A); M(B)|] ==> M(A-B)"
by (insert Diff_separation, simp add: Diff_def)

subsubsection{*Some Facts About Separation Axioms*}

lemma (in M_basic) separation_conj:
     "[|separation(M,P); separation(M,Q)|] ==> separation(M, \<lambda>z. P(z) & Q(z))"
by (simp del: separation_closed
         add: separation_iff Collect_Int_Collect_eq [symmetric])

(*???equalities*)
lemma Collect_Un_Collect_eq:
     "Collect(A,P) \<union> Collect(A,Q) = Collect(A, %x. P(x) | Q(x))"
by blast

lemma Diff_Collect_eq:
     "A - Collect(A,P) = Collect(A, %x. ~ P(x))"
by blast

lemma (in M_trivial) Collect_rall_eq:
     "M(Y) ==> Collect(A, %x. \<forall>y[M]. y\<in>Y \<longrightarrow> P(x,y)) =
               (if Y=0 then A else (\<Inter>y \<in> Y. {x \<in> A. P(x,y)}))"
apply simp
apply (blast intro!: equalityI dest: transM)
done

lemma (in M_basic) separation_disj:
     "[|separation(M,P); separation(M,Q)|] ==> separation(M, \<lambda>z. P(z) | Q(z))"
by (simp del: separation_closed
         add: separation_iff Collect_Un_Collect_eq [symmetric])

lemma (in M_basic) separation_neg:
     "separation(M,P) ==> separation(M, \<lambda>z. ~P(z))"
by (simp del: separation_closed
         add: separation_iff Diff_Collect_eq [symmetric])

lemma (in M_basic) separation_imp:
     "[|separation(M,P); separation(M,Q)|]
      ==> separation(M, \<lambda>z. P(z) \<longrightarrow> Q(z))"
by (simp add: separation_neg separation_disj not_disj_iff_imp [symmetric])

text{*This result is a hint of how little can be done without the Reflection
  Theorem.  The quantifier has to be bounded by a set.  We also need another
  instance of Separation!*}
lemma (in M_basic) separation_rall:
     "[|M(Y); \<forall>y[M]. separation(M, \<lambda>x. P(x,y));
        \<forall>z[M]. strong_replacement(M, \<lambda>x y. y = {u \<in> z . P(u,x)})|]
      ==> separation(M, \<lambda>x. \<forall>y[M]. y\<in>Y \<longrightarrow> P(x,y))"
apply (simp del: separation_closed rall_abs
         add: separation_iff Collect_rall_eq)
apply (blast intro!: Inter_closed RepFun_closed dest: transM)
done


subsubsection{*Functions and function space*}

text{*The assumption @{term "M(A->B)"} is unusual, but essential: in
all but trivial cases, A->B cannot be expected to belong to @{term M}.*}
lemma (in M_basic) is_funspace_abs [simp]:
     "[|M(A); M(B); M(F); M(A->B)|] ==> is_funspace(M,A,B,F) \<longleftrightarrow> F = A->B";
apply (simp add: is_funspace_def)
apply (rule iffI)
 prefer 2 apply blast
apply (rule M_equalityI)
  apply simp_all
done

lemma (in M_basic) succ_fun_eq2:
     "[|M(B); M(n->B)|] ==>
      succ(n) -> B =
      \<Union>{z. p \<in> (n->B)*B, \<exists>f[M]. \<exists>b[M]. p = <f,b> & z = {cons(<n,b>, f)}}"
apply (simp add: succ_fun_eq)
apply (blast dest: transM)
done

lemma (in M_basic) funspace_succ:
     "[|M(n); M(B); M(n->B) |] ==> M(succ(n) -> B)"
apply (insert funspace_succ_replacement [of n], simp)
apply (force simp add: succ_fun_eq2 univalent_def)
done

text{*@{term M} contains all finite function spaces.  Needed to prove the
absoluteness of transitive closure.  See the definition of
@{text rtrancl_alt} in in @{text WF_absolute.thy}.*}
lemma (in M_basic) finite_funspace_closed [intro,simp]:
     "[|n\<in>nat; M(B)|] ==> M(n->B)"
apply (induct_tac n, simp)
apply (simp add: funspace_succ nat_into_M)
done


subsection{*Relativization and Absoluteness for Boolean Operators*}

definition
  is_bool_of_o :: "[i=>o, o, i] => o" where
   "is_bool_of_o(M,P,z) == (P & number1(M,z)) | (~P & empty(M,z))"

definition
  is_not :: "[i=>o, i, i] => o" where
   "is_not(M,a,z) == (number1(M,a)  & empty(M,z)) |
                     (~number1(M,a) & number1(M,z))"

definition
  is_and :: "[i=>o, i, i, i] => o" where
   "is_and(M,a,b,z) == (number1(M,a)  & z=b) |
                       (~number1(M,a) & empty(M,z))"

definition
  is_or :: "[i=>o, i, i, i] => o" where
   "is_or(M,a,b,z) == (number1(M,a)  & number1(M,z)) |
                      (~number1(M,a) & z=b)"

lemma (in M_trivial) bool_of_o_abs [simp]:
     "M(z) ==> is_bool_of_o(M,P,z) \<longleftrightarrow> z = bool_of_o(P)"
by (simp add: is_bool_of_o_def bool_of_o_def)


lemma (in M_trivial) not_abs [simp]:
     "[| M(a); M(z)|] ==> is_not(M,a,z) \<longleftrightarrow> z = not(a)"
by (simp add: Bool.not_def cond_def is_not_def)

lemma (in M_trivial) and_abs [simp]:
     "[| M(a); M(b); M(z)|] ==> is_and(M,a,b,z) \<longleftrightarrow> z = a and b"
by (simp add: Bool.and_def cond_def is_and_def)

lemma (in M_trivial) or_abs [simp]:
     "[| M(a); M(b); M(z)|] ==> is_or(M,a,b,z) \<longleftrightarrow> z = a or b"
by (simp add: Bool.or_def cond_def is_or_def)


lemma (in M_trivial) bool_of_o_closed [intro,simp]:
     "M(bool_of_o(P))"
by (simp add: bool_of_o_def)

lemma (in M_trivial) and_closed [intro,simp]:
     "[| M(p); M(q) |] ==> M(p and q)"
by (simp add: and_def cond_def)

lemma (in M_trivial) or_closed [intro,simp]:
     "[| M(p); M(q) |] ==> M(p or q)"
by (simp add: or_def cond_def)

lemma (in M_trivial) not_closed [intro,simp]:
     "M(p) ==> M(not(p))"
by (simp add: Bool.not_def cond_def)


subsection{*Relativization and Absoluteness for List Operators*}

definition
  is_Nil :: "[i=>o, i] => o" where
     --{* because @{prop "[] \<equiv> Inl(0)"}*}
    "is_Nil(M,xs) == \<exists>zero[M]. empty(M,zero) & is_Inl(M,zero,xs)"

definition
  is_Cons :: "[i=>o,i,i,i] => o" where
     --{* because @{prop "Cons(a, l) \<equiv> Inr(\<langle>a,l\<rangle>)"}*}
    "is_Cons(M,a,l,Z) == \<exists>p[M]. pair(M,a,l,p) & is_Inr(M,p,Z)"


lemma (in M_trivial) Nil_in_M [intro,simp]: "M(Nil)"
by (simp add: Nil_def)

lemma (in M_trivial) Nil_abs [simp]: "M(Z) ==> is_Nil(M,Z) \<longleftrightarrow> (Z = Nil)"
by (simp add: is_Nil_def Nil_def)

lemma (in M_trivial) Cons_in_M_iff [iff]: "M(Cons(a,l)) \<longleftrightarrow> M(a) & M(l)"
by (simp add: Cons_def)

lemma (in M_trivial) Cons_abs [simp]:
     "[|M(a); M(l); M(Z)|] ==> is_Cons(M,a,l,Z) \<longleftrightarrow> (Z = Cons(a,l))"
by (simp add: is_Cons_def Cons_def)


definition
  quasilist :: "i => o" where
    "quasilist(xs) == xs=Nil | (\<exists>x l. xs = Cons(x,l))"

definition
  is_quasilist :: "[i=>o,i] => o" where
    "is_quasilist(M,z) == is_Nil(M,z) | (\<exists>x[M]. \<exists>l[M]. is_Cons(M,x,l,z))"

definition
  list_case' :: "[i, [i,i]=>i, i] => i" where
    --{*A version of @{term list_case} that's always defined.*}
    "list_case'(a,b,xs) ==
       if quasilist(xs) then list_case(a,b,xs) else 0"

definition
  is_list_case :: "[i=>o, i, [i,i,i]=>o, i, i] => o" where
    --{*Returns 0 for non-lists*}
    "is_list_case(M, a, is_b, xs, z) ==
       (is_Nil(M,xs) \<longrightarrow> z=a) &
       (\<forall>x[M]. \<forall>l[M]. is_Cons(M,x,l,xs) \<longrightarrow> is_b(x,l,z)) &
       (is_quasilist(M,xs) | empty(M,z))"

definition
  hd' :: "i => i" where
    --{*A version of @{term hd} that's always defined.*}
    "hd'(xs) == if quasilist(xs) then hd(xs) else 0"

definition
  tl' :: "i => i" where
    --{*A version of @{term tl} that's always defined.*}
    "tl'(xs) == if quasilist(xs) then tl(xs) else 0"

definition
  is_hd :: "[i=>o,i,i] => o" where
     --{* @{term "hd([]) = 0"} no constraints if not a list.
          Avoiding implication prevents the simplifier's looping.*}
    "is_hd(M,xs,H) ==
       (is_Nil(M,xs) \<longrightarrow> empty(M,H)) &
       (\<forall>x[M]. \<forall>l[M]. ~ is_Cons(M,x,l,xs) | H=x) &
       (is_quasilist(M,xs) | empty(M,H))"

definition
  is_tl :: "[i=>o,i,i] => o" where
     --{* @{term "tl([]) = []"}; see comments about @{term is_hd}*}
    "is_tl(M,xs,T) ==
       (is_Nil(M,xs) \<longrightarrow> T=xs) &
       (\<forall>x[M]. \<forall>l[M]. ~ is_Cons(M,x,l,xs) | T=l) &
       (is_quasilist(M,xs) | empty(M,T))"

subsubsection{*@{term quasilist}: For Case-Splitting with @{term list_case'}*}

lemma [iff]: "quasilist(Nil)"
by (simp add: quasilist_def)

lemma [iff]: "quasilist(Cons(x,l))"
by (simp add: quasilist_def)

lemma list_imp_quasilist: "l \<in> list(A) ==> quasilist(l)"
by (erule list.cases, simp_all)

subsubsection{*@{term list_case'}, the Modified Version of @{term list_case}*}

lemma list_case'_Nil [simp]: "list_case'(a,b,Nil) = a"
by (simp add: list_case'_def quasilist_def)

lemma list_case'_Cons [simp]: "list_case'(a,b,Cons(x,l)) = b(x,l)"
by (simp add: list_case'_def quasilist_def)

lemma non_list_case: "~ quasilist(x) ==> list_case'(a,b,x) = 0"
by (simp add: quasilist_def list_case'_def)

lemma list_case'_eq_list_case [simp]:
     "xs \<in> list(A) ==>list_case'(a,b,xs) = list_case(a,b,xs)"
by (erule list.cases, simp_all)

lemma (in M_basic) list_case'_closed [intro,simp]:
  "[|M(k); M(a); \<forall>x[M]. \<forall>y[M]. M(b(x,y))|] ==> M(list_case'(a,b,k))"
apply (case_tac "quasilist(k)")
 apply (simp add: quasilist_def, force)
apply (simp add: non_list_case)
done

lemma (in M_trivial) quasilist_abs [simp]:
     "M(z) ==> is_quasilist(M,z) \<longleftrightarrow> quasilist(z)"
by (auto simp add: is_quasilist_def quasilist_def)

lemma (in M_trivial) list_case_abs [simp]:
     "[| relation2(M,is_b,b); M(k); M(z) |]
      ==> is_list_case(M,a,is_b,k,z) \<longleftrightarrow> z = list_case'(a,b,k)"
apply (case_tac "quasilist(k)")
 prefer 2
 apply (simp add: is_list_case_def non_list_case)
 apply (force simp add: quasilist_def)
apply (simp add: quasilist_def is_list_case_def)
apply (elim disjE exE)
 apply (simp_all add: relation2_def)
done


subsubsection{*The Modified Operators @{term hd'} and @{term tl'}*}

lemma (in M_trivial) is_hd_Nil: "is_hd(M,[],Z) \<longleftrightarrow> empty(M,Z)"
by (simp add: is_hd_def)

lemma (in M_trivial) is_hd_Cons:
     "[|M(a); M(l)|] ==> is_hd(M,Cons(a,l),Z) \<longleftrightarrow> Z = a"
by (force simp add: is_hd_def)

lemma (in M_trivial) hd_abs [simp]:
     "[|M(x); M(y)|] ==> is_hd(M,x,y) \<longleftrightarrow> y = hd'(x)"
apply (simp add: hd'_def)
apply (intro impI conjI)
 prefer 2 apply (force simp add: is_hd_def)
apply (simp add: quasilist_def is_hd_def)
apply (elim disjE exE, auto)
done

lemma (in M_trivial) is_tl_Nil: "is_tl(M,[],Z) \<longleftrightarrow> Z = []"
by (simp add: is_tl_def)

lemma (in M_trivial) is_tl_Cons:
     "[|M(a); M(l)|] ==> is_tl(M,Cons(a,l),Z) \<longleftrightarrow> Z = l"
by (force simp add: is_tl_def)

lemma (in M_trivial) tl_abs [simp]:
     "[|M(x); M(y)|] ==> is_tl(M,x,y) \<longleftrightarrow> y = tl'(x)"
apply (simp add: tl'_def)
apply (intro impI conjI)
 prefer 2 apply (force simp add: is_tl_def)
apply (simp add: quasilist_def is_tl_def)
apply (elim disjE exE, auto)
done

lemma (in M_trivial) relation1_tl: "relation1(M, is_tl(M), tl')"
by (simp add: relation1_def)

lemma hd'_Nil: "hd'([]) = 0"
by (simp add: hd'_def)

lemma hd'_Cons: "hd'(Cons(a,l)) = a"
by (simp add: hd'_def)

lemma tl'_Nil: "tl'([]) = []"
by (simp add: tl'_def)

lemma tl'_Cons: "tl'(Cons(a,l)) = l"
by (simp add: tl'_def)

lemma iterates_tl_Nil: "n \<in> nat ==> tl'^n ([]) = []"
apply (induct_tac n)
apply (simp_all add: tl'_Nil)
done

lemma (in M_basic) tl'_closed: "M(x) ==> M(tl'(x))"
apply (simp add: tl'_def)
apply (force simp add: quasilist_def)
done


end
