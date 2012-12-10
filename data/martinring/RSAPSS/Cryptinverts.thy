(*  Title:      RSAPSS/Cryptinverts.thy
    Author:     Christina Lindenberg, Kai Wirt, Technische Universität Darmstadt
    Copyright:  2005 - Technische Universität Darmstadt 
*)

header "Correctness proof for RSA"

theory Cryptinverts
imports Fermat Crypt
begin

text {* 
  In this theory we show, that a RSA encrypted message can be decrypted
*}

lemma cryptinverts_hilf1: "prime p \<Longrightarrow> (m * m ^(k * pred p)) mod p = m mod p"
  apply (cases "m mod p = 0")
  apply (simp add: mod_mult_left_eq)
  apply (simp only: mult_commute [of k "pred p"]
    power_mult mod_mult_right_eq [of "m" "(m^pred p)^k" "p"]
    remainderexp [of "m^pred p" "p" "k", symmetric])
  apply (insert fermat [of p m])
  apply (simp add: predd)
  apply (subst One_nat_def [symmetric])
  apply (subst onemodprime)
  apply auto
  done

lemma cryptinverts_hilf2: "prime p \<Longrightarrow> m*(m^(k * (pred p) * (pred q))) mod p = m mod p"
  apply (simp add: mult_commute [of "k * pred p" "pred q"] mult_assoc [symmetric])
  apply (rule cryptinverts_hilf1 [of "p" "m" "(pred q) * k"])
  apply simp
  done

lemma cryptinverts_hilf3: "prime q \<Longrightarrow> m*(m^(k * (pred p) * (pred q))) mod q = m mod q"
  apply (simp only: mult_assoc)
  apply (simp add: mult_commute [of "pred p" "pred q"])
  apply (simp only: mult_assoc [symmetric])
  apply (rule cryptinverts_hilf2)
  apply simp
  done

lemma cryptinverts_hilf4:
    "\<lbrakk>prime p; prime q; p \<noteq> q; m < p*q; x mod ((pred p)*(pred q)) = 1\<rbrakk> \<Longrightarrow> m^x mod (p*q) = m"
  apply (frule cryptinverts_hilf2 [of p m k q])
  apply (frule cryptinverts_hilf3 [of q m k p])
  apply (frule mod_eqD)
  apply (elim exE)
  apply (rule specializedtoprimes1a)
  apply (simp add: cryptinverts_hilf2 cryptinverts_hilf3 mult_assoc [symmetric])+
  done

lemma primmultgreater: "\<lbrakk> prime p; prime q; p \<noteq> 2; q \<noteq> 2\<rbrakk> \<Longrightarrow> 2 < p*q"
  apply (simp add:prime_def)
  apply (insert mult_le_mono [of 2 p 2 q])
  apply auto
  done

lemma primmultgreater2: "\<lbrakk>prime p; prime q; p \<noteq> q\<rbrakk> \<Longrightarrow>  2 < p*q"
  apply (cases "p = 2")
   apply simp+
  apply (simp add: prime_def)
  apply (cases "q = 2")
   apply (simp add: prime_def)
  apply (erule primmultgreater)
  apply auto
  done

lemma cryptinverts: "\<lbrakk> prime p; prime q; p \<noteq> q; n = p*q; m < n;
    e*d mod ((pred p)*(pred q)) = 1\<rbrakk> \<Longrightarrow> rsa_crypt (rsa_crypt m e n) d n = m"
  apply (insert cryptinverts_hilf4 [of p q m "e*d"])
  apply (insert cryptcorrect [of "p*q" "rsa_crypt m e (p * q)" d])
  apply (insert cryptcorrect [of "p*q" m e])
  apply (insert primmultgreater2 [of p q])
  apply (simp add: prime_def)
  apply (simp add: remainderexp [of "m^e" "p*q" d] power_mult [symmetric])
  done

end
