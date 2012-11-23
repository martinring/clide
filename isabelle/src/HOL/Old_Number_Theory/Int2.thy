(*  Title:      HOL/Old_Number_Theory/Int2.thy
    Authors:    Jeremy Avigad, David Gray, and Adam Kramer
*)

header {*Integers: Divisibility and Congruences*}

theory Int2
imports Finite2 WilsonRuss
begin

definition MultInv :: "int => int => int"
  where "MultInv p x = x ^ nat (p - 2)"


subsection {* Useful lemmas about dvd and powers *}

lemma zpower_zdvd_prop1:
  "0 < n \<Longrightarrow> p dvd y \<Longrightarrow> p dvd ((y::int) ^ n)"
  by (induct n) (auto simp add: dvd_mult2 [of p y])

lemma zdvd_bounds: "n dvd m ==> m \<le> (0::int) | n \<le> m"
proof -
  assume "n dvd m"
  then have "~(0 < m & m < n)"
    using zdvd_not_zless [of m n] by auto
  then show ?thesis by auto
qed

lemma zprime_zdvd_zmult_better: "[| zprime p;  p dvd (m * n) |] ==>
    (p dvd m) | (p dvd n)"
  apply (cases "0 \<le> m")
  apply (simp add: zprime_zdvd_zmult)
  apply (insert zprime_zdvd_zmult [of "-m" p n])
  apply auto
  done

lemma zpower_zdvd_prop2:
    "zprime p \<Longrightarrow> p dvd ((y::int) ^ n) \<Longrightarrow> 0 < n \<Longrightarrow> p dvd y"
  apply (induct n)
   apply simp
  apply (frule zprime_zdvd_zmult_better)
   apply simp
  apply (force simp del:dvd_mult)
  done

lemma div_prop1:
  assumes "0 < z" and "(x::int) < y * z"
  shows "x div z < y"
proof -
  from `0 < z` have modth: "x mod z \<ge> 0" by simp
  have "(x div z) * z \<le> (x div z) * z" by simp
  then have "(x div z) * z \<le> (x div z) * z + x mod z" using modth by arith 
  also have "\<dots> = x"
    by (auto simp add: zmod_zdiv_equality [symmetric] mult_ac)
  also note `x < y * z`
  finally show ?thesis
    apply (auto simp add: mult_less_cancel_right)
    using assms apply arith
    done
qed

lemma div_prop2:
  assumes "0 < z" and "(x::int) < (y * z) + z"
  shows "x div z \<le> y"
proof -
  from assms have "x < (y + 1) * z" by (auto simp add: int_distrib)
  then have "x div z < y + 1"
    apply (rule_tac y = "y + 1" in div_prop1)
    apply (auto simp add: `0 < z`)
    done
  then show ?thesis by auto
qed

lemma zdiv_leq_prop: assumes "0 < y" shows "y * (x div y) \<le> (x::int)"
proof-
  from zmod_zdiv_equality have "x = y * (x div y) + x mod y" by auto
  moreover have "0 \<le> x mod y" by (auto simp add: assms)
  ultimately show ?thesis by arith
qed


subsection {* Useful properties of congruences *}

lemma zcong_eq_zdvd_prop: "[x = 0](mod p) = (p dvd x)"
  by (auto simp add: zcong_def)

lemma zcong_id: "[m = 0] (mod m)"
  by (auto simp add: zcong_def)

lemma zcong_shift: "[a = b] (mod m) ==> [a + c = b + c] (mod m)"
  by (auto simp add: zcong_zadd)

lemma zcong_zpower: "[x = y](mod m) ==> [x^z = y^z](mod m)"
  by (induct z) (auto simp add: zcong_zmult)

lemma zcong_eq_trans: "[| [a = b](mod m); b = c; [c = d](mod m) |] ==>
    [a = d](mod m)"
  apply (erule zcong_trans)
  apply simp
  done

lemma aux1: "a - b = (c::int) ==> a = c + b"
  by auto

lemma zcong_zmult_prop1: "[a = b](mod m) ==> ([c = a * d](mod m) =
    [c = b * d] (mod m))"
  apply (auto simp add: zcong_def dvd_def)
  apply (rule_tac x = "ka + k * d" in exI)
  apply (drule aux1)+
  apply (auto simp add: int_distrib)
  apply (rule_tac x = "ka - k * d" in exI)
  apply (drule aux1)+
  apply (auto simp add: int_distrib)
  done

lemma zcong_zmult_prop2: "[a = b](mod m) ==>
    ([c = d * a](mod m) = [c = d * b] (mod m))"
  by (auto simp add: mult_ac zcong_zmult_prop1)

lemma zcong_zmult_prop3: "[| zprime p; ~[x = 0] (mod p);
    ~[y = 0] (mod p) |] ==> ~[x * y = 0] (mod p)"
  apply (auto simp add: zcong_def)
  apply (drule zprime_zdvd_zmult_better, auto)
  done

lemma zcong_less_eq: "[| 0 < x; 0 < y; 0 < m; [x = y] (mod m);
    x < m; y < m |] ==> x = y"
  by (metis zcong_not zcong_sym less_linear)

lemma zcong_neg_1_impl_ne_1:
  assumes "2 < p" and "[x = -1] (mod p)"
  shows "~([x = 1] (mod p))"
proof
  assume "[x = 1] (mod p)"
  with assms have "[1 = -1] (mod p)"
    apply (auto simp add: zcong_sym)
    apply (drule zcong_trans, auto)
    done
  then have "[1 + 1 = -1 + 1] (mod p)"
    by (simp only: zcong_shift)
  then have "[2 = 0] (mod p)"
    by auto
  then have "p dvd 2"
    by (auto simp add: dvd_def zcong_def)
  with `2 < p` show False
    by (auto simp add: zdvd_not_zless)
qed

lemma zcong_zero_equiv_div: "[a = 0] (mod m) = (m dvd a)"
  by (auto simp add: zcong_def)

lemma zcong_zprime_prod_zero: "[| zprime p; 0 < a |] ==>
    [a * b = 0] (mod p) ==> [a = 0] (mod p) | [b = 0] (mod p)"
  by (auto simp add: zcong_zero_equiv_div zprime_zdvd_zmult)

lemma zcong_zprime_prod_zero_contra: "[| zprime p; 0 < a |] ==>
  ~[a = 0](mod p) & ~[b = 0](mod p) ==> ~[a * b = 0] (mod p)"
  apply auto
  apply (frule_tac a = a and b = b and p = p in zcong_zprime_prod_zero)
  apply auto
  done

lemma zcong_not_zero: "[| 0 < x; x < m |] ==> ~[x = 0] (mod m)"
  by (auto simp add: zcong_zero_equiv_div zdvd_not_zless)

lemma zcong_zero: "[| 0 \<le> x; x < m; [x = 0](mod m) |] ==> x = 0"
  apply (drule order_le_imp_less_or_eq, auto)
  apply (frule_tac m = m in zcong_not_zero)
  apply auto
  done

lemma all_relprime_prod_relprime: "[| finite A; \<forall>x \<in> A. zgcd x y = 1 |]
    ==> zgcd (setprod id A) y = 1"
  by (induct set: finite) (auto simp add: zgcd_zgcd_zmult)


subsection {* Some properties of MultInv *}

lemma MultInv_prop1: "[| 2 < p; [x = y] (mod p) |] ==>
    [(MultInv p x) = (MultInv p y)] (mod p)"
  by (auto simp add: MultInv_def zcong_zpower)

lemma MultInv_prop2: "[| 2 < p; zprime p; ~([x = 0](mod p)) |] ==>
  [(x * (MultInv p x)) = 1] (mod p)"
proof (simp add: MultInv_def zcong_eq_zdvd_prop)
  assume 1: "2 < p" and 2: "zprime p" and 3: "~ p dvd x"
  have "x * x ^ nat (p - 2) = x ^ (nat (p - 2) + 1)"
    by auto
  also from 1 have "nat (p - 2) + 1 = nat (p - 2 + 1)"
    by (simp only: nat_add_distrib)
  also have "p - 2 + 1 = p - 1" by arith
  finally have "[x * x ^ nat (p - 2) = x ^ nat (p - 1)] (mod p)"
    by (rule ssubst, auto)
  also from 2 3 have "[x ^ nat (p - 1) = 1] (mod p)"
    by (auto simp add: Little_Fermat)
  finally (zcong_trans) show "[x * x ^ nat (p - 2) = 1] (mod p)" .
qed

lemma MultInv_prop2a: "[| 2 < p; zprime p; ~([x = 0](mod p)) |] ==>
    [(MultInv p x) * x = 1] (mod p)"
  by (auto simp add: MultInv_prop2 mult_ac)

lemma aux_1: "2 < p ==> ((nat p) - 2) = (nat (p - 2))"
  by (simp add: nat_diff_distrib)

lemma aux_2: "2 < p ==> 0 < nat (p - 2)"
  by auto

lemma MultInv_prop3: "[| 2 < p; zprime p; ~([x = 0](mod p)) |] ==>
    ~([MultInv p x = 0](mod p))"
  apply (auto simp add: MultInv_def zcong_eq_zdvd_prop aux_1)
  apply (drule aux_2)
  apply (drule zpower_zdvd_prop2, auto)
  done

lemma aux__1: "[| 2 < p; zprime p; ~([x = 0](mod p))|] ==>
    [(MultInv p (MultInv p x)) = (x * (MultInv p x) *
      (MultInv p (MultInv p x)))] (mod p)"
  apply (drule MultInv_prop2, auto)
  apply (drule_tac k = "MultInv p (MultInv p x)" in zcong_scalar, auto)
  apply (auto simp add: zcong_sym)
  done

lemma aux__2: "[| 2 < p; zprime p; ~([x = 0](mod p))|] ==>
    [(x * (MultInv p x) * (MultInv p (MultInv p x))) = x] (mod p)"
  apply (frule MultInv_prop3, auto)
  apply (insert MultInv_prop2 [of p "MultInv p x"], auto)
  apply (drule MultInv_prop2, auto)
  apply (drule_tac k = x in zcong_scalar2, auto)
  apply (auto simp add: mult_ac)
  done

lemma MultInv_prop4: "[| 2 < p; zprime p; ~([x = 0](mod p)) |] ==>
    [(MultInv p (MultInv p x)) = x] (mod p)"
  apply (frule aux__1, auto)
  apply (drule aux__2, auto)
  apply (drule zcong_trans, auto)
  done

lemma MultInv_prop5: "[| 2 < p; zprime p; ~([x = 0](mod p));
    ~([y = 0](mod p)); [(MultInv p x) = (MultInv p y)] (mod p) |] ==>
    [x = y] (mod p)"
  apply (drule_tac a = "MultInv p x" and b = "MultInv p y" and
    m = p and k = x in zcong_scalar)
  apply (insert MultInv_prop2 [of p x], simp)
  apply (auto simp only: zcong_sym [of "MultInv p x * x"])
  apply (auto simp add: mult_ac)
  apply (drule zcong_trans, auto)
  apply (drule_tac a = "x * MultInv p y" and k = y in zcong_scalar, auto)
  apply (insert MultInv_prop2a [of p y], auto simp add: mult_ac)
  apply (insert zcong_zmult_prop2 [of "y * MultInv p y" 1 p y x])
  apply (auto simp add: zcong_sym)
  done

lemma MultInv_zcong_prop1: "[| 2 < p; [j = k] (mod p) |] ==>
    [a * MultInv p j = a * MultInv p k] (mod p)"
  by (drule MultInv_prop1, auto simp add: zcong_scalar2)

lemma aux___1: "[j = a * MultInv p k] (mod p) ==>
    [j * k = a * MultInv p k * k] (mod p)"
  by (auto simp add: zcong_scalar)

lemma aux___2: "[|2 < p; zprime p; ~([k = 0](mod p));
    [j * k = a * MultInv p k * k] (mod p) |] ==> [j * k = a] (mod p)"
  apply (insert MultInv_prop2a [of p k] zcong_zmult_prop2
    [of "MultInv p k * k" 1 p "j * k" a])
  apply (auto simp add: mult_ac)
  done

lemma aux___3: "[j * k = a] (mod p) ==> [(MultInv p j) * j * k =
     (MultInv p j) * a] (mod p)"
  by (auto simp add: mult_assoc zcong_scalar2)

lemma aux___4: "[|2 < p; zprime p; ~([j = 0](mod p));
    [(MultInv p j) * j * k = (MultInv p j) * a] (mod p) |]
       ==> [k = a * (MultInv p j)] (mod p)"
  apply (insert MultInv_prop2a [of p j] zcong_zmult_prop1
    [of "MultInv p j * j" 1 p "MultInv p j * a" k])
  apply (auto simp add: mult_ac zcong_sym)
  done

lemma MultInv_zcong_prop2: "[| 2 < p; zprime p; ~([k = 0](mod p));
    ~([j = 0](mod p)); [j = a * MultInv p k] (mod p) |] ==>
    [k = a * MultInv p j] (mod p)"
  apply (drule aux___1)
  apply (frule aux___2, auto)
  by (drule aux___3, drule aux___4, auto)

lemma MultInv_zcong_prop3: "[| 2 < p; zprime p; ~([a = 0](mod p));
    ~([k = 0](mod p)); ~([j = 0](mod p));
    [a * MultInv p j = a * MultInv p k] (mod p) |] ==>
      [j = k] (mod p)"
  apply (auto simp add: zcong_eq_zdvd_prop [of a p])
  apply (frule zprime_imp_zrelprime, auto)
  apply (insert zcong_cancel2 [of p a "MultInv p j" "MultInv p k"], auto)
  apply (drule MultInv_prop5, auto)
  done

end
