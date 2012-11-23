(*  Title       : NatStar.thy
    Author      : Jacques D. Fleuriot
    Copyright   : 1998  University of Cambridge

Converted to Isar and polished by lcp
*)

header{*Star-transforms for the Hypernaturals*}

theory NatStar
imports Star
begin

lemma star_n_eq_starfun_whn: "star_n X = ( *f* X) whn"
by (simp add: hypnat_omega_def starfun_def star_of_def Ifun_star_n)

lemma starset_n_Un: "*sn* (%n. (A n) Un (B n)) = *sn* A Un *sn* B"
apply (simp add: starset_n_def star_n_eq_starfun_whn Un_def)
apply (rule_tac x=whn in spec, transfer, simp)
done

lemma InternalSets_Un:
     "[| X \<in> InternalSets; Y \<in> InternalSets |]
      ==> (X Un Y) \<in> InternalSets"
by (auto simp add: InternalSets_def starset_n_Un [symmetric])

lemma starset_n_Int:
      "*sn* (%n. (A n) Int (B n)) = *sn* A Int *sn* B"
apply (simp add: starset_n_def star_n_eq_starfun_whn Int_def)
apply (rule_tac x=whn in spec, transfer, simp)
done

lemma InternalSets_Int:
     "[| X \<in> InternalSets; Y \<in> InternalSets |]
      ==> (X Int Y) \<in> InternalSets"
by (auto simp add: InternalSets_def starset_n_Int [symmetric])

lemma starset_n_Compl: "*sn* ((%n. - A n)) = -( *sn* A)"
apply (simp add: starset_n_def star_n_eq_starfun_whn Compl_eq)
apply (rule_tac x=whn in spec, transfer, simp)
done

lemma InternalSets_Compl: "X \<in> InternalSets ==> -X \<in> InternalSets"
by (auto simp add: InternalSets_def starset_n_Compl [symmetric])

lemma starset_n_diff: "*sn* (%n. (A n) - (B n)) = *sn* A - *sn* B"
apply (simp add: starset_n_def star_n_eq_starfun_whn set_diff_eq)
apply (rule_tac x=whn in spec, transfer, simp)
done

lemma InternalSets_diff:
     "[| X \<in> InternalSets; Y \<in> InternalSets |]
      ==> (X - Y) \<in> InternalSets"
by (auto simp add: InternalSets_def starset_n_diff [symmetric])

lemma NatStar_SHNat_subset: "Nats \<le> *s* (UNIV:: nat set)"
by simp

lemma NatStar_hypreal_of_real_Int:
     "*s* X Int Nats = hypnat_of_nat ` X"
by (auto simp add: SHNat_eq)

lemma starset_starset_n_eq: "*s* X = *sn* (%n. X)"
by (simp add: starset_n_starset)

lemma InternalSets_starset_n [simp]: "( *s* X) \<in> InternalSets"
by (auto simp add: InternalSets_def starset_starset_n_eq)

lemma InternalSets_UNIV_diff:
     "X \<in> InternalSets ==> UNIV - X \<in> InternalSets"
apply (subgoal_tac "UNIV - X = - X")
by (auto intro: InternalSets_Compl)


subsection{*Nonstandard Extensions of Functions*}

text{* Example of transfer of a property from reals to hyperreals
    --- used for limit comparison of sequences*}

lemma starfun_le_mono:
     "\<forall>n. N \<le> n --> f n \<le> g n
      ==> \<forall>n. hypnat_of_nat N \<le> n --> ( *f* f) n \<le> ( *f* g) n"
by transfer

(*****----- and another -----*****)
lemma starfun_less_mono:
     "\<forall>n. N \<le> n --> f n < g n
      ==> \<forall>n. hypnat_of_nat N \<le> n --> ( *f* f) n < ( *f* g) n"
by transfer

text{*Nonstandard extension when we increment the argument by one*}

lemma starfun_shift_one:
     "!!N. ( *f* (%n. f (Suc n))) N = ( *f* f) (N + (1::hypnat))"
by (transfer, simp)

text{*Nonstandard extension with absolute value*}

lemma starfun_abs: "!!N. ( *f* (%n. abs (f n))) N = abs(( *f* f) N)"
by (transfer, rule refl)

text{*The hyperpow function as a nonstandard extension of realpow*}

lemma starfun_pow: "!!N. ( *f* (%n. r ^ n)) N = (hypreal_of_real r) pow N"
by (transfer, rule refl)

lemma starfun_pow2:
     "!!N. ( *f* (%n. (X n) ^ m)) N = ( *f* X) N pow hypnat_of_nat m"
by (transfer, rule refl)

lemma starfun_pow3: "!!R. ( *f* (%r. r ^ n)) R = (R) pow hypnat_of_nat n"
by (transfer, rule refl)

text{*The @{term hypreal_of_hypnat} function as a nonstandard extension of
  @{term real_of_nat} *}

lemma starfunNat_real_of_nat: "( *f* real) = hypreal_of_hypnat"
by transfer (simp add: fun_eq_iff real_of_nat_def)

lemma starfun_inverse_real_of_nat_eq:
     "N \<in> HNatInfinite
   ==> ( *f* (%x::nat. inverse(real x))) N = inverse(hypreal_of_hypnat N)"
apply (rule_tac f1 = inverse in starfun_o2 [THEN subst])
apply (subgoal_tac "hypreal_of_hypnat N ~= 0")
apply (simp_all add: zero_less_HNatInfinite starfunNat_real_of_nat starfun_inverse_inverse)
done

text{*Internal functions - some redundancy with *f* now*}

lemma starfun_n: "( *fn* f) (star_n X) = star_n (%n. f n (X n))"
by (simp add: starfun_n_def Ifun_star_n)

text{*Multiplication: @{text "( *fn) x ( *gn) = *(fn x gn)"}*}

lemma starfun_n_mult:
     "( *fn* f) z * ( *fn* g) z = ( *fn* (% i x. f i x * g i x)) z"
apply (cases z)
apply (simp add: starfun_n star_n_mult)
done

text{*Addition: @{text "( *fn) + ( *gn) = *(fn + gn)"}*}

lemma starfun_n_add:
     "( *fn* f) z + ( *fn* g) z = ( *fn* (%i x. f i x + g i x)) z"
apply (cases z)
apply (simp add: starfun_n star_n_add)
done

text{*Subtraction: @{text "( *fn) - ( *gn) = *(fn + - gn)"}*}

lemma starfun_n_add_minus:
     "( *fn* f) z + -( *fn* g) z = ( *fn* (%i x. f i x + -g i x)) z"
apply (cases z)
apply (simp add: starfun_n star_n_minus star_n_add)
done


text{*Composition: @{text "( *fn) o ( *gn) = *(fn o gn)"}*}

lemma starfun_n_const_fun [simp]:
     "( *fn* (%i x. k)) z = star_of k"
apply (cases z)
apply (simp add: starfun_n star_of_def)
done

lemma starfun_n_minus: "- ( *fn* f) x = ( *fn* (%i x. - (f i) x)) x"
apply (cases x)
apply (simp add: starfun_n star_n_minus)
done

lemma starfun_n_eq [simp]:
     "( *fn* f) (star_of n) = star_n (%i. f i n)"
by (simp add: starfun_n star_of_def)

lemma starfun_eq_iff: "(( *f* f) = ( *f* g)) = (f = g)"
by (transfer, rule refl)

lemma starfunNat_inverse_real_of_nat_Infinitesimal [simp]:
     "N \<in> HNatInfinite ==> ( *f* (%x. inverse (real x))) N \<in> Infinitesimal"
apply (rule_tac f1 = inverse in starfun_o2 [THEN subst])
apply (subgoal_tac "hypreal_of_hypnat N ~= 0")
apply (simp_all add: zero_less_HNatInfinite starfunNat_real_of_nat)
done


subsection{*Nonstandard Characterization of Induction*}

lemma hypnat_induct_obj:
    "!!n. (( *p* P) (0::hypnat) &
            (\<forall>n. ( *p* P)(n) --> ( *p* P)(n + 1)))
       --> ( *p* P)(n)"
by (transfer, induct_tac n, auto)

lemma hypnat_induct:
  "!!n. [| ( *p* P) (0::hypnat);
      !!n. ( *p* P)(n) ==> ( *p* P)(n + 1)|]
     ==> ( *p* P)(n)"
by (transfer, induct_tac n, auto)

lemma starP2_eq_iff: "( *p2* (op =)) = (op =)"
by transfer (rule refl)

lemma starP2_eq_iff2: "( *p2* (%x y. x = y)) X Y = (X = Y)"
by (simp add: starP2_eq_iff)

lemma nonempty_nat_set_Least_mem:
  "c \<in> (S :: nat set) ==> (LEAST n. n \<in> S) \<in> S"
by (erule LeastI)

lemma nonempty_set_star_has_least:
    "!!S::nat set star. Iset S \<noteq> {} ==> \<exists>n \<in> Iset S. \<forall>m \<in> Iset S. n \<le> m"
apply (transfer empty_def)
apply (rule_tac x="LEAST n. n \<in> S" in bexI)
apply (simp add: Least_le)
apply (rule LeastI_ex, auto)
done

lemma nonempty_InternalNatSet_has_least:
    "[| (S::hypnat set) \<in> InternalSets; S \<noteq> {} |] ==> \<exists>n \<in> S. \<forall>m \<in> S. n \<le> m"
apply (clarsimp simp add: InternalSets_def starset_n_def)
apply (erule nonempty_set_star_has_least)
done

text{* Goldblatt page 129 Thm 11.3.2*}
lemma internal_induct_lemma:
     "!!X::nat set star. [| (0::hypnat) \<in> Iset X; \<forall>n. n \<in> Iset X --> n + 1 \<in> Iset X |]
      ==> Iset X = (UNIV:: hypnat set)"
apply (transfer UNIV_def)
apply (rule equalityI [OF subset_UNIV subsetI])
apply (induct_tac x, auto)
done

lemma internal_induct:
     "[| X \<in> InternalSets; (0::hypnat) \<in> X; \<forall>n. n \<in> X --> n + 1 \<in> X |]
      ==> X = (UNIV:: hypnat set)"
apply (clarsimp simp add: InternalSets_def starset_n_def)
apply (erule (1) internal_induct_lemma)
done


end
