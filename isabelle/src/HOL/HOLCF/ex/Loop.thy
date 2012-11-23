(*  Title:      HOL/HOLCF/ex/Loop.thy
    Author:     Franz Regensburger
*)

header {* Theory for a loop primitive like while *}

theory Loop
imports HOLCF
begin

definition
  step  :: "('a -> tr)->('a -> 'a)->'a->'a" where
  "step = (LAM b g x. If b$x then g$x else x)"

definition
  while :: "('a -> tr)->('a -> 'a)->'a->'a" where
  "while = (LAM b g. fix$(LAM f x. If b$x then f$(g$x) else x))"

(* ------------------------------------------------------------------------- *)
(* access to definitions                                                     *)
(* ------------------------------------------------------------------------- *)


lemma step_def2: "step$b$g$x = If b$x then g$x else x"
apply (unfold step_def)
apply simp
done

lemma while_def2: "while$b$g = fix$(LAM f x. If b$x then f$(g$x) else x)"
apply (unfold while_def)
apply simp
done


(* ------------------------------------------------------------------------- *)
(* rekursive properties of while                                             *)
(* ------------------------------------------------------------------------- *)

lemma while_unfold: "while$b$g$x = If b$x then while$b$g$(g$x) else x"
apply (rule trans)
apply (rule while_def2 [THEN fix_eq5])
apply simp
done

lemma while_unfold2: "ALL x. while$b$g$x = while$b$g$(iterate k$(step$b$g)$x)"
apply (induct_tac k)
apply simp
apply (rule allI)
apply (rule trans)
apply (rule while_unfold)
apply (subst iterate_Suc2)
apply (rule trans)
apply (erule_tac [2] spec)
apply (subst step_def2)
apply (rule_tac p = "b$x" in trE)
apply simp
apply (subst while_unfold)
apply (rule_tac s = "UU" and t = "b$UU" in ssubst)
apply (erule strictI)
apply simp
apply simp
apply simp
apply (subst while_unfold)
apply simp
done

lemma while_unfold3: "while$b$g$x = while$b$g$(step$b$g$x)"
apply (rule_tac s = "while$b$g$ (iterate (Suc 0) $ (step$b$g) $x) " in trans)
apply (rule while_unfold2 [THEN spec])
apply simp
done


(* ------------------------------------------------------------------------- *)
(* properties of while and iterations                                        *)
(* ------------------------------------------------------------------------- *)

lemma loop_lemma1: "[| EX y. b$y=FF; iterate k$(step$b$g)$x = UU |]
     ==>iterate(Suc k)$(step$b$g)$x=UU"
apply (simp (no_asm))
apply (rule trans)
apply (rule step_def2)
apply simp
apply (erule exE)
apply (erule flat_codom [THEN disjE])
apply simp_all
done

lemma loop_lemma2: "[|EX y. b$y=FF;iterate (Suc k)$(step$b$g)$x ~=UU |]==>
      iterate k$(step$b$g)$x ~=UU"
apply (blast intro: loop_lemma1)
done

lemma loop_lemma3 [rule_format (no_asm)]:
  "[| ALL x. INV x & b$x=TT & g$x~=UU --> INV (g$x);
         EX y. b$y=FF; INV x |]
      ==> iterate k$(step$b$g)$x ~=UU --> INV (iterate k$(step$b$g)$x)"
apply (induct_tac "k")
apply (simp (no_asm_simp))
apply (intro strip)
apply (simp (no_asm) add: step_def2)
apply (rule_tac p = "b$ (iterate n$ (step$b$g) $x) " in trE)
apply (erule notE)
apply (simp add: step_def2)
apply (simp (no_asm_simp))
apply (rule mp)
apply (erule spec)
apply (simp (no_asm_simp) del: iterate_Suc add: loop_lemma2)
apply (rule_tac s = "iterate (Suc n) $ (step$b$g) $x"
  and t = "g$ (iterate n$ (step$b$g) $x) " in ssubst)
prefer 2 apply (assumption)
apply (simp add: step_def2)
apply (drule (1) loop_lemma2, simp)
done

lemma loop_lemma4 [rule_format]:
  "ALL x. b$(iterate k$(step$b$g)$x)=FF --> while$b$g$x= iterate k$(step$b$g)$x"
apply (induct_tac k)
apply (simp (no_asm))
apply (intro strip)
apply (simplesubst while_unfold)
apply simp
apply (rule allI)
apply (simplesubst iterate_Suc2)
apply (intro strip)
apply (rule trans)
apply (rule while_unfold3)
apply simp
done

lemma loop_lemma5 [rule_format (no_asm)]:
  "ALL k. b$(iterate k$(step$b$g)$x) ~= FF ==>
    ALL m. while$b$g$(iterate m$(step$b$g)$x)=UU"
apply (simplesubst while_def2)
apply (rule fix_ind)
apply simp
apply simp
apply (rule allI)
apply (simp (no_asm))
apply (rule_tac p = "b$ (iterate m$ (step$b$g) $x) " in trE)
apply (simp (no_asm_simp))
apply (simp (no_asm_simp))
apply (rule_tac s = "xa$ (iterate (Suc m) $ (step$b$g) $x) " in trans)
apply (erule_tac [2] spec)
apply (rule cfun_arg_cong)
apply (rule trans)
apply (rule_tac [2] iterate_Suc [symmetric])
apply (simp add: step_def2)
apply blast
done

lemma loop_lemma6: "ALL k. b$(iterate k$(step$b$g)$x) ~= FF ==> while$b$g$x=UU"
apply (rule_tac t = "x" in iterate_0 [THEN subst])
apply (erule loop_lemma5)
done

lemma loop_lemma7: "while$b$g$x ~= UU ==> EX k. b$(iterate k$(step$b$g)$x) = FF"
apply (blast intro: loop_lemma6)
done


(* ------------------------------------------------------------------------- *)
(* an invariant rule for loops                                               *)
(* ------------------------------------------------------------------------- *)

lemma loop_inv2:
"[| (ALL y. INV y & b$y=TT & g$y ~= UU --> INV (g$y));
    (ALL y. INV y & b$y=FF --> Q y);
    INV x; while$b$g$x~=UU |] ==> Q (while$b$g$x)"
apply (rule_tac P = "%k. b$ (iterate k$ (step$b$g) $x) =FF" in exE)
apply (erule loop_lemma7)
apply (simplesubst loop_lemma4)
apply assumption
apply (drule spec, erule mp)
apply (rule conjI)
prefer 2 apply (assumption)
apply (rule loop_lemma3)
apply assumption
apply (blast intro: loop_lemma6)
apply assumption
apply (rotate_tac -1)
apply (simp add: loop_lemma4)
done

lemma loop_inv:
  assumes premP: "P(x)"
    and premI: "!!y. P y ==> INV y"
    and premTT: "!!y. [| INV y; b$y=TT; g$y~=UU|] ==> INV (g$y)"
    and premFF: "!!y. [| INV y; b$y=FF|] ==> Q y"
    and premW: "while$b$g$x ~= UU"
  shows "Q (while$b$g$x)"
apply (rule loop_inv2)
apply (rule_tac [3] premP [THEN premI])
apply (rule_tac [3] premW)
apply (blast intro: premTT)
apply (blast intro: premFF)
done

end

