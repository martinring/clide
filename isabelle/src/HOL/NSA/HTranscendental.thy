(*  Title       : HTranscendental.thy
    Author      : Jacques D. Fleuriot
    Copyright   : 2001 University of Edinburgh

Converted to Isar and polished by lcp
*)

header{*Nonstandard Extensions of Transcendental Functions*}

theory HTranscendental
imports Transcendental HSeries HDeriv
begin

definition
  exphr :: "real => hypreal" where
    --{*define exponential function using standard part *}
  "exphr x =  st(sumhr (0, whn, %n. inverse(real (fact n)) * (x ^ n)))"

definition
  sinhr :: "real => hypreal" where
  "sinhr x = st(sumhr (0, whn, %n. sin_coeff n * x ^ n))"
  
definition
  coshr :: "real => hypreal" where
  "coshr x = st(sumhr (0, whn, %n. cos_coeff n * x ^ n))"


subsection{*Nonstandard Extension of Square Root Function*}

lemma STAR_sqrt_zero [simp]: "( *f* sqrt) 0 = 0"
by (simp add: starfun star_n_zero_num)

lemma STAR_sqrt_one [simp]: "( *f* sqrt) 1 = 1"
by (simp add: starfun star_n_one_num)

lemma hypreal_sqrt_pow2_iff: "(( *f* sqrt)(x) ^ 2 = x) = (0 \<le> x)"
apply (cases x)
apply (auto simp add: star_n_le star_n_zero_num starfun hrealpow star_n_eq_iff
            simp del: hpowr_Suc power_Suc)
done

lemma hypreal_sqrt_gt_zero_pow2: "!!x. 0 < x ==> ( *f* sqrt) (x) ^ 2 = x"
by (transfer, simp)

lemma hypreal_sqrt_pow2_gt_zero: "0 < x ==> 0 < ( *f* sqrt) (x) ^ 2"
by (frule hypreal_sqrt_gt_zero_pow2, auto)

lemma hypreal_sqrt_not_zero: "0 < x ==> ( *f* sqrt) (x) \<noteq> 0"
apply (frule hypreal_sqrt_pow2_gt_zero)
apply (auto simp add: numeral_2_eq_2)
done

lemma hypreal_inverse_sqrt_pow2:
     "0 < x ==> inverse (( *f* sqrt)(x)) ^ 2 = inverse x"
apply (cut_tac n = 2 and a = "( *f* sqrt) x" in power_inverse [symmetric])
apply (auto dest: hypreal_sqrt_gt_zero_pow2)
done

lemma hypreal_sqrt_mult_distrib: 
    "!!x y. [|0 < x; 0 <y |] ==>
      ( *f* sqrt)(x*y) = ( *f* sqrt)(x) * ( *f* sqrt)(y)"
apply transfer
apply (auto intro: real_sqrt_mult_distrib) 
done

lemma hypreal_sqrt_mult_distrib2:
     "[|0\<le>x; 0\<le>y |] ==>  
     ( *f* sqrt)(x*y) =  ( *f* sqrt)(x) * ( *f* sqrt)(y)"
by (auto intro: hypreal_sqrt_mult_distrib simp add: order_le_less)

lemma hypreal_sqrt_approx_zero [simp]:
     "0 < x ==> (( *f* sqrt)(x) @= 0) = (x @= 0)"
apply (auto simp add: mem_infmal_iff [symmetric])
apply (rule hypreal_sqrt_gt_zero_pow2 [THEN subst])
apply (auto intro: Infinitesimal_mult 
            dest!: hypreal_sqrt_gt_zero_pow2 [THEN ssubst] 
            simp add: numeral_2_eq_2)
done

lemma hypreal_sqrt_approx_zero2 [simp]:
     "0 \<le> x ==> (( *f* sqrt)(x) @= 0) = (x @= 0)"
by (auto simp add: order_le_less)

lemma hypreal_sqrt_sum_squares [simp]:
     "(( *f* sqrt)(x*x + y*y + z*z) @= 0) = (x*x + y*y + z*z @= 0)"
apply (rule hypreal_sqrt_approx_zero2)
apply (rule add_nonneg_nonneg)+
apply (auto)
done

lemma hypreal_sqrt_sum_squares2 [simp]:
     "(( *f* sqrt)(x*x + y*y) @= 0) = (x*x + y*y @= 0)"
apply (rule hypreal_sqrt_approx_zero2)
apply (rule add_nonneg_nonneg)
apply (auto)
done

lemma hypreal_sqrt_gt_zero: "!!x. 0 < x ==> 0 < ( *f* sqrt)(x)"
apply transfer
apply (auto intro: real_sqrt_gt_zero)
done

lemma hypreal_sqrt_ge_zero: "0 \<le> x ==> 0 \<le> ( *f* sqrt)(x)"
by (auto intro: hypreal_sqrt_gt_zero simp add: order_le_less)

lemma hypreal_sqrt_hrabs [simp]: "!!x. ( *f* sqrt)(x ^ 2) = abs(x)"
by (transfer, simp)

lemma hypreal_sqrt_hrabs2 [simp]: "!!x. ( *f* sqrt)(x*x) = abs(x)"
by (transfer, simp)

lemma hypreal_sqrt_hyperpow_hrabs [simp]:
     "!!x. ( *f* sqrt)(x pow (hypnat_of_nat 2)) = abs(x)"
by (transfer, simp)

lemma star_sqrt_HFinite: "\<lbrakk>x \<in> HFinite; 0 \<le> x\<rbrakk> \<Longrightarrow> ( *f* sqrt) x \<in> HFinite"
apply (rule HFinite_square_iff [THEN iffD1])
apply (simp only: hypreal_sqrt_mult_distrib2 [symmetric], simp) 
done

lemma st_hypreal_sqrt:
     "[| x \<in> HFinite; 0 \<le> x |] ==> st(( *f* sqrt) x) = ( *f* sqrt)(st x)"
apply (rule power_inject_base [where n=1])
apply (auto intro!: st_zero_le hypreal_sqrt_ge_zero)
apply (rule st_mult [THEN subst])
apply (rule_tac [3] hypreal_sqrt_mult_distrib2 [THEN subst])
apply (rule_tac [5] hypreal_sqrt_mult_distrib2 [THEN subst])
apply (auto simp add: st_hrabs st_zero_le star_sqrt_HFinite)
done

lemma hypreal_sqrt_sum_squares_ge1 [simp]: "!!x y. x \<le> ( *f* sqrt)(x ^ 2 + y ^ 2)"
by transfer (rule real_sqrt_sum_squares_ge1)

lemma HFinite_hypreal_sqrt:
     "[| 0 \<le> x; x \<in> HFinite |] ==> ( *f* sqrt) x \<in> HFinite"
apply (auto simp add: order_le_less)
apply (rule HFinite_square_iff [THEN iffD1])
apply (drule hypreal_sqrt_gt_zero_pow2)
apply (simp add: numeral_2_eq_2)
done

lemma HFinite_hypreal_sqrt_imp_HFinite:
     "[| 0 \<le> x; ( *f* sqrt) x \<in> HFinite |] ==> x \<in> HFinite"
apply (auto simp add: order_le_less)
apply (drule HFinite_square_iff [THEN iffD2])
apply (drule hypreal_sqrt_gt_zero_pow2)
apply (simp add: numeral_2_eq_2 del: HFinite_square_iff)
done

lemma HFinite_hypreal_sqrt_iff [simp]:
     "0 \<le> x ==> (( *f* sqrt) x \<in> HFinite) = (x \<in> HFinite)"
by (blast intro: HFinite_hypreal_sqrt HFinite_hypreal_sqrt_imp_HFinite)

lemma HFinite_sqrt_sum_squares [simp]:
     "(( *f* sqrt)(x*x + y*y) \<in> HFinite) = (x*x + y*y \<in> HFinite)"
apply (rule HFinite_hypreal_sqrt_iff)
apply (rule add_nonneg_nonneg)
apply (auto)
done

lemma Infinitesimal_hypreal_sqrt:
     "[| 0 \<le> x; x \<in> Infinitesimal |] ==> ( *f* sqrt) x \<in> Infinitesimal"
apply (auto simp add: order_le_less)
apply (rule Infinitesimal_square_iff [THEN iffD2])
apply (drule hypreal_sqrt_gt_zero_pow2)
apply (simp add: numeral_2_eq_2)
done

lemma Infinitesimal_hypreal_sqrt_imp_Infinitesimal:
     "[| 0 \<le> x; ( *f* sqrt) x \<in> Infinitesimal |] ==> x \<in> Infinitesimal"
apply (auto simp add: order_le_less)
apply (drule Infinitesimal_square_iff [THEN iffD1])
apply (drule hypreal_sqrt_gt_zero_pow2)
apply (simp add: numeral_2_eq_2 del: Infinitesimal_square_iff [symmetric])
done

lemma Infinitesimal_hypreal_sqrt_iff [simp]:
     "0 \<le> x ==> (( *f* sqrt) x \<in> Infinitesimal) = (x \<in> Infinitesimal)"
by (blast intro: Infinitesimal_hypreal_sqrt_imp_Infinitesimal Infinitesimal_hypreal_sqrt)

lemma Infinitesimal_sqrt_sum_squares [simp]:
     "(( *f* sqrt)(x*x + y*y) \<in> Infinitesimal) = (x*x + y*y \<in> Infinitesimal)"
apply (rule Infinitesimal_hypreal_sqrt_iff)
apply (rule add_nonneg_nonneg)
apply (auto)
done

lemma HInfinite_hypreal_sqrt:
     "[| 0 \<le> x; x \<in> HInfinite |] ==> ( *f* sqrt) x \<in> HInfinite"
apply (auto simp add: order_le_less)
apply (rule HInfinite_square_iff [THEN iffD1])
apply (drule hypreal_sqrt_gt_zero_pow2)
apply (simp add: numeral_2_eq_2)
done

lemma HInfinite_hypreal_sqrt_imp_HInfinite:
     "[| 0 \<le> x; ( *f* sqrt) x \<in> HInfinite |] ==> x \<in> HInfinite"
apply (auto simp add: order_le_less)
apply (drule HInfinite_square_iff [THEN iffD2])
apply (drule hypreal_sqrt_gt_zero_pow2)
apply (simp add: numeral_2_eq_2 del: HInfinite_square_iff)
done

lemma HInfinite_hypreal_sqrt_iff [simp]:
     "0 \<le> x ==> (( *f* sqrt) x \<in> HInfinite) = (x \<in> HInfinite)"
by (blast intro: HInfinite_hypreal_sqrt HInfinite_hypreal_sqrt_imp_HInfinite)

lemma HInfinite_sqrt_sum_squares [simp]:
     "(( *f* sqrt)(x*x + y*y) \<in> HInfinite) = (x*x + y*y \<in> HInfinite)"
apply (rule HInfinite_hypreal_sqrt_iff)
apply (rule add_nonneg_nonneg)
apply (auto)
done

lemma HFinite_exp [simp]:
     "sumhr (0, whn, %n. inverse (real (fact n)) * x ^ n) \<in> HFinite"
unfolding sumhr_app
apply (simp only: star_zero_def starfun2_star_of)
apply (rule NSBseqD2)
apply (rule NSconvergent_NSBseq)
apply (rule convergent_NSconvergent_iff [THEN iffD1])
apply (rule summable_convergent_sumr_iff [THEN iffD1])
apply (rule summable_exp)
done

lemma exphr_zero [simp]: "exphr 0 = 1"
apply (simp add: exphr_def sumhr_split_add
                   [OF hypnat_one_less_hypnat_omega, symmetric])
apply (rule st_unique, simp)
apply (rule subst [where P="\<lambda>x. 1 \<approx> x", OF _ approx_refl])
apply (rule rev_mp [OF hypnat_one_less_hypnat_omega])
apply (rule_tac x="whn" in spec)
apply (unfold sumhr_app, transfer, simp)
done

lemma coshr_zero [simp]: "coshr 0 = 1"
apply (simp add: coshr_def sumhr_split_add
                   [OF hypnat_one_less_hypnat_omega, symmetric]) 
apply (rule st_unique, simp)
apply (rule subst [where P="\<lambda>x. 1 \<approx> x", OF _ approx_refl])
apply (rule rev_mp [OF hypnat_one_less_hypnat_omega])
apply (rule_tac x="whn" in spec)
apply (unfold sumhr_app, transfer, simp add: cos_coeff_def)
done

lemma STAR_exp_zero_approx_one [simp]: "( *f* exp) (0::hypreal) @= 1"
apply (subgoal_tac "( *f* exp) (0::hypreal) = 1", simp)
apply (transfer, simp)
done

lemma STAR_exp_Infinitesimal: "x \<in> Infinitesimal ==> ( *f* exp) (x::hypreal) @= 1"
apply (case_tac "x = 0")
apply (cut_tac [2] x = 0 in DERIV_exp)
apply (auto simp add: NSDERIV_DERIV_iff [symmetric] nsderiv_def)
apply (drule_tac x = x in bspec, auto)
apply (drule_tac c = x in approx_mult1)
apply (auto intro: Infinitesimal_subset_HFinite [THEN subsetD] 
            simp add: mult_assoc)
apply (rule approx_add_right_cancel [where d="-1"])
apply (rule approx_sym [THEN [2] approx_trans2])
apply (auto simp add: diff_minus mem_infmal_iff)
done

lemma STAR_exp_epsilon [simp]: "( *f* exp) epsilon @= 1"
by (auto intro: STAR_exp_Infinitesimal)

lemma STAR_exp_add: "!!x y. ( *f* exp)(x + y) = ( *f* exp) x * ( *f* exp) y"
by transfer (rule exp_add)

lemma exphr_hypreal_of_real_exp_eq: "exphr x = hypreal_of_real (exp x)"
apply (simp add: exphr_def)
apply (rule st_unique, simp)
apply (subst starfunNat_sumr [symmetric])
apply (rule NSLIMSEQ_D [THEN approx_sym])
apply (rule LIMSEQ_NSLIMSEQ)
apply (subst sums_def [symmetric])
apply (cut_tac exp_converges [where x=x], simp)
apply (rule HNatInfinite_whn)
done

lemma starfun_exp_ge_add_one_self [simp]: "!!x::hypreal. 0 \<le> x ==> (1 + x) \<le> ( *f* exp) x"
by transfer (rule exp_ge_add_one_self_aux)

(* exp (oo) is infinite *)
lemma starfun_exp_HInfinite:
     "[| x \<in> HInfinite; 0 \<le> x |] ==> ( *f* exp) (x::hypreal) \<in> HInfinite"
apply (frule starfun_exp_ge_add_one_self)
apply (rule HInfinite_ge_HInfinite, assumption)
apply (rule order_trans [of _ "1+x"], auto) 
done

lemma starfun_exp_minus: "!!x. ( *f* exp) (-x) = inverse(( *f* exp) x)"
by transfer (rule exp_minus)

(* exp (-oo) is infinitesimal *)
lemma starfun_exp_Infinitesimal:
     "[| x \<in> HInfinite; x \<le> 0 |] ==> ( *f* exp) (x::hypreal) \<in> Infinitesimal"
apply (subgoal_tac "\<exists>y. x = - y")
apply (rule_tac [2] x = "- x" in exI)
apply (auto intro!: HInfinite_inverse_Infinitesimal starfun_exp_HInfinite
            simp add: starfun_exp_minus HInfinite_minus_iff)
done

lemma starfun_exp_gt_one [simp]: "!!x::hypreal. 0 < x ==> 1 < ( *f* exp) x"
by transfer (rule exp_gt_one)

lemma starfun_ln_exp [simp]: "!!x. ( *f* ln) (( *f* exp) x) = x"
by transfer (rule ln_exp)

lemma starfun_exp_ln_iff [simp]: "!!x. (( *f* exp)(( *f* ln) x) = x) = (0 < x)"
by transfer (rule exp_ln_iff)

lemma starfun_exp_ln_eq: "!!u x. ( *f* exp) u = x ==> ( *f* ln) x = u"
by transfer (rule ln_unique)

lemma starfun_ln_less_self [simp]: "!!x. 0 < x ==> ( *f* ln) x < x"
by transfer (rule ln_less_self)

lemma starfun_ln_ge_zero [simp]: "!!x. 1 \<le> x ==> 0 \<le> ( *f* ln) x"
by transfer (rule ln_ge_zero)

lemma starfun_ln_gt_zero [simp]: "!!x .1 < x ==> 0 < ( *f* ln) x"
by transfer (rule ln_gt_zero)

lemma starfun_ln_not_eq_zero [simp]: "!!x. [| 0 < x; x \<noteq> 1 |] ==> ( *f* ln) x \<noteq> 0"
by transfer simp

lemma starfun_ln_HFinite: "[| x \<in> HFinite; 1 \<le> x |] ==> ( *f* ln) x \<in> HFinite"
apply (rule HFinite_bounded)
apply assumption 
apply (simp_all add: starfun_ln_less_self order_less_imp_le)
done

lemma starfun_ln_inverse: "!!x. 0 < x ==> ( *f* ln) (inverse x) = -( *f* ln) x"
by transfer (rule ln_inverse)

lemma starfun_abs_exp_cancel: "\<And>x. \<bar>( *f* exp) (x::hypreal)\<bar> = ( *f* exp) x"
by transfer (rule abs_exp_cancel)

lemma starfun_exp_less_mono: "\<And>x y::hypreal. x < y \<Longrightarrow> ( *f* exp) x < ( *f* exp) y"
by transfer (rule exp_less_mono)

lemma starfun_exp_HFinite: "x \<in> HFinite ==> ( *f* exp) (x::hypreal) \<in> HFinite"
apply (auto simp add: HFinite_def, rename_tac u)
apply (rule_tac x="( *f* exp) u" in rev_bexI)
apply (simp add: Reals_eq_Standard)
apply (simp add: starfun_abs_exp_cancel)
apply (simp add: starfun_exp_less_mono)
done

lemma starfun_exp_add_HFinite_Infinitesimal_approx:
     "[|x \<in> Infinitesimal; z \<in> HFinite |] ==> ( *f* exp) (z + x::hypreal) @= ( *f* exp) z"
apply (simp add: STAR_exp_add)
apply (frule STAR_exp_Infinitesimal)
apply (drule approx_mult2)
apply (auto intro: starfun_exp_HFinite)
done

(* using previous result to get to result *)
lemma starfun_ln_HInfinite:
     "[| x \<in> HInfinite; 0 < x |] ==> ( *f* ln) x \<in> HInfinite"
apply (rule ccontr, drule HFinite_HInfinite_iff [THEN iffD2])
apply (drule starfun_exp_HFinite)
apply (simp add: starfun_exp_ln_iff [THEN iffD2] HFinite_HInfinite_iff)
done

lemma starfun_exp_HInfinite_Infinitesimal_disj:
 "x \<in> HInfinite ==> ( *f* exp) x \<in> HInfinite | ( *f* exp) (x::hypreal) \<in> Infinitesimal"
apply (insert linorder_linear [of x 0]) 
apply (auto intro: starfun_exp_HInfinite starfun_exp_Infinitesimal)
done

(* check out this proof!!! *)
lemma starfun_ln_HFinite_not_Infinitesimal:
     "[| x \<in> HFinite - Infinitesimal; 0 < x |] ==> ( *f* ln) x \<in> HFinite"
apply (rule ccontr, drule HInfinite_HFinite_iff [THEN iffD2])
apply (drule starfun_exp_HInfinite_Infinitesimal_disj)
apply (simp add: starfun_exp_ln_iff [symmetric] HInfinite_HFinite_iff
            del: starfun_exp_ln_iff)
done

(* we do proof by considering ln of 1/x *)
lemma starfun_ln_Infinitesimal_HInfinite:
     "[| x \<in> Infinitesimal; 0 < x |] ==> ( *f* ln) x \<in> HInfinite"
apply (drule Infinitesimal_inverse_HInfinite)
apply (frule positive_imp_inverse_positive)
apply (drule_tac [2] starfun_ln_HInfinite)
apply (auto simp add: starfun_ln_inverse HInfinite_minus_iff)
done

lemma starfun_ln_less_zero: "!!x. [| 0 < x; x < 1 |] ==> ( *f* ln) x < 0"
by transfer (rule ln_less_zero)

lemma starfun_ln_Infinitesimal_less_zero:
     "[| x \<in> Infinitesimal; 0 < x |] ==> ( *f* ln) x < 0"
by (auto intro!: starfun_ln_less_zero simp add: Infinitesimal_def)

lemma starfun_ln_HInfinite_gt_zero:
     "[| x \<in> HInfinite; 0 < x |] ==> 0 < ( *f* ln) x"
by (auto intro!: starfun_ln_gt_zero simp add: HInfinite_def)


(*
Goalw [NSLIM_def] "(%h. ((x powr h) - 1) / h) -- 0 --NS> ln x"
*)

lemma HFinite_sin [simp]: "sumhr (0, whn, %n. sin_coeff n * x ^ n) \<in> HFinite"
unfolding sumhr_app
apply (simp only: star_zero_def starfun2_star_of)
apply (rule NSBseqD2)
apply (rule NSconvergent_NSBseq)
apply (rule convergent_NSconvergent_iff [THEN iffD1])
apply (rule summable_convergent_sumr_iff [THEN iffD1])
apply (rule summable_sin)
done

lemma STAR_sin_zero [simp]: "( *f* sin) 0 = 0"
by transfer (rule sin_zero)

lemma STAR_sin_Infinitesimal [simp]: "x \<in> Infinitesimal ==> ( *f* sin) x @= x"
apply (case_tac "x = 0")
apply (cut_tac [2] x = 0 in DERIV_sin)
apply (auto simp add: NSDERIV_DERIV_iff [symmetric] nsderiv_def)
apply (drule bspec [where x = x], auto)
apply (drule approx_mult1 [where c = x])
apply (auto intro: Infinitesimal_subset_HFinite [THEN subsetD]
           simp add: mult_assoc)
done

lemma HFinite_cos [simp]: "sumhr (0, whn, %n. cos_coeff n * x ^ n) \<in> HFinite"
unfolding sumhr_app
apply (simp only: star_zero_def starfun2_star_of)
apply (rule NSBseqD2)
apply (rule NSconvergent_NSBseq)
apply (rule convergent_NSconvergent_iff [THEN iffD1])
apply (rule summable_convergent_sumr_iff [THEN iffD1])
apply (rule summable_cos)
done

lemma STAR_cos_zero [simp]: "( *f* cos) 0 = 1"
by transfer (rule cos_zero)

lemma STAR_cos_Infinitesimal [simp]: "x \<in> Infinitesimal ==> ( *f* cos) x @= 1"
apply (case_tac "x = 0")
apply (cut_tac [2] x = 0 in DERIV_cos)
apply (auto simp add: NSDERIV_DERIV_iff [symmetric] nsderiv_def)
apply (drule bspec [where x = x])
apply auto
apply (drule approx_mult1 [where c = x])
apply (auto intro: Infinitesimal_subset_HFinite [THEN subsetD]
            simp add: mult_assoc)
apply (rule approx_add_right_cancel [where d = "-1"])
apply (simp add: diff_minus)
done

lemma STAR_tan_zero [simp]: "( *f* tan) 0 = 0"
by transfer (rule tan_zero)

lemma STAR_tan_Infinitesimal: "x \<in> Infinitesimal ==> ( *f* tan) x @= x"
apply (case_tac "x = 0")
apply (cut_tac [2] x = 0 in DERIV_tan)
apply (auto simp add: NSDERIV_DERIV_iff [symmetric] nsderiv_def)
apply (drule bspec [where x = x], auto)
apply (drule approx_mult1 [where c = x])
apply (auto intro: Infinitesimal_subset_HFinite [THEN subsetD]
             simp add: mult_assoc)
done

lemma STAR_sin_cos_Infinitesimal_mult:
     "x \<in> Infinitesimal ==> ( *f* sin) x * ( *f* cos) x @= x"
apply (insert approx_mult_HFinite [of "( *f* sin) x" _ "( *f* cos) x" 1]) 
apply (simp add: Infinitesimal_subset_HFinite [THEN subsetD])
done

lemma HFinite_pi: "hypreal_of_real pi \<in> HFinite"
by simp

(* lemmas *)

lemma lemma_split_hypreal_of_real:
     "N \<in> HNatInfinite  
      ==> hypreal_of_real a =  
          hypreal_of_hypnat N * (inverse(hypreal_of_hypnat N) * hypreal_of_real a)"
by (simp add: mult_assoc [symmetric] zero_less_HNatInfinite)

lemma STAR_sin_Infinitesimal_divide:
     "[|x \<in> Infinitesimal; x \<noteq> 0 |] ==> ( *f* sin) x/x @= 1"
apply (cut_tac x = 0 in DERIV_sin)
apply (simp add: NSDERIV_DERIV_iff [symmetric] nsderiv_def)
done

(*------------------------------------------------------------------------*) 
(* sin* (1/n) * 1/(1/n) @= 1 for n = oo                                   *)
(*------------------------------------------------------------------------*)

lemma lemma_sin_pi:
     "n \<in> HNatInfinite  
      ==> ( *f* sin) (inverse (hypreal_of_hypnat n))/(inverse (hypreal_of_hypnat n)) @= 1"
apply (rule STAR_sin_Infinitesimal_divide)
apply (auto simp add: zero_less_HNatInfinite)
done

lemma STAR_sin_inverse_HNatInfinite:
     "n \<in> HNatInfinite  
      ==> ( *f* sin) (inverse (hypreal_of_hypnat n)) * hypreal_of_hypnat n @= 1"
apply (frule lemma_sin_pi)
apply (simp add: divide_inverse)
done

lemma Infinitesimal_pi_divide_HNatInfinite: 
     "N \<in> HNatInfinite  
      ==> hypreal_of_real pi/(hypreal_of_hypnat N) \<in> Infinitesimal"
apply (simp add: divide_inverse)
apply (auto intro: Infinitesimal_HFinite_mult2)
done

lemma pi_divide_HNatInfinite_not_zero [simp]:
     "N \<in> HNatInfinite ==> hypreal_of_real pi/(hypreal_of_hypnat N) \<noteq> 0"
by (simp add: zero_less_HNatInfinite)

lemma STAR_sin_pi_divide_HNatInfinite_approx_pi:
     "n \<in> HNatInfinite  
      ==> ( *f* sin) (hypreal_of_real pi/(hypreal_of_hypnat n)) * hypreal_of_hypnat n  
          @= hypreal_of_real pi"
apply (frule STAR_sin_Infinitesimal_divide
               [OF Infinitesimal_pi_divide_HNatInfinite 
                   pi_divide_HNatInfinite_not_zero])
apply (auto)
apply (rule approx_SReal_mult_cancel [of "inverse (hypreal_of_real pi)"])
apply (auto intro: Reals_inverse simp add: divide_inverse mult_ac)
done

lemma STAR_sin_pi_divide_HNatInfinite_approx_pi2:
     "n \<in> HNatInfinite  
      ==> hypreal_of_hypnat n *  
          ( *f* sin) (hypreal_of_real pi/(hypreal_of_hypnat n))  
          @= hypreal_of_real pi"
apply (rule mult_commute [THEN subst])
apply (erule STAR_sin_pi_divide_HNatInfinite_approx_pi)
done

lemma starfunNat_pi_divide_n_Infinitesimal: 
     "N \<in> HNatInfinite ==> ( *f* (%x. pi / real x)) N \<in> Infinitesimal"
by (auto intro!: Infinitesimal_HFinite_mult2 
         simp add: starfun_mult [symmetric] divide_inverse
                   starfun_inverse [symmetric] starfunNat_real_of_nat)

lemma STAR_sin_pi_divide_n_approx:
     "N \<in> HNatInfinite ==>  
      ( *f* sin) (( *f* (%x. pi / real x)) N) @=  
      hypreal_of_real pi/(hypreal_of_hypnat N)"
apply (simp add: starfunNat_real_of_nat [symmetric])
apply (rule STAR_sin_Infinitesimal)
apply (simp add: divide_inverse)
apply (rule Infinitesimal_HFinite_mult2)
apply (subst starfun_inverse)
apply (erule starfunNat_inverse_real_of_nat_Infinitesimal)
apply simp
done

lemma NSLIMSEQ_sin_pi: "(%n. real n * sin (pi / real n)) ----NS> pi"
apply (auto simp add: NSLIMSEQ_def starfun_mult [symmetric] starfunNat_real_of_nat)
apply (rule_tac f1 = sin in starfun_o2 [THEN subst])
apply (auto simp add: starfun_mult [symmetric] starfunNat_real_of_nat divide_inverse)
apply (rule_tac f1 = inverse in starfun_o2 [THEN subst])
apply (auto dest: STAR_sin_pi_divide_HNatInfinite_approx_pi 
            simp add: starfunNat_real_of_nat mult_commute divide_inverse)
done

lemma NSLIMSEQ_cos_one: "(%n. cos (pi / real n))----NS> 1"
apply (simp add: NSLIMSEQ_def, auto)
apply (rule_tac f1 = cos in starfun_o2 [THEN subst])
apply (rule STAR_cos_Infinitesimal)
apply (auto intro!: Infinitesimal_HFinite_mult2 
            simp add: starfun_mult [symmetric] divide_inverse
                      starfun_inverse [symmetric] starfunNat_real_of_nat)
done

lemma NSLIMSEQ_sin_cos_pi:
     "(%n. real n * sin (pi / real n) * cos (pi / real n)) ----NS> pi"
by (insert NSLIMSEQ_mult [OF NSLIMSEQ_sin_pi NSLIMSEQ_cos_one], simp)


text{*A familiar approximation to @{term "cos x"} when @{term x} is small*}

lemma STAR_cos_Infinitesimal_approx:
     "x \<in> Infinitesimal ==> ( *f* cos) x @= 1 - x ^ 2"
apply (rule STAR_cos_Infinitesimal [THEN approx_trans])
apply (auto simp add: Infinitesimal_approx_minus [symmetric] 
            diff_minus add_assoc [symmetric] numeral_2_eq_2)
done

lemma STAR_cos_Infinitesimal_approx2:
     "x \<in> Infinitesimal ==> ( *f* cos) x @= 1 - (x ^ 2)/2"
apply (rule STAR_cos_Infinitesimal [THEN approx_trans])
apply (auto intro: Infinitesimal_SReal_divide 
            simp add: Infinitesimal_approx_minus [symmetric] numeral_2_eq_2)
done

end
