(*  Title:      CTT/ex/Typechecking.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1991  University of Cambridge
*)

header "Easy examples: type checking and type deduction"

theory Typechecking
imports CTT
begin

subsection {* Single-step proofs: verifying that a type is well-formed *}

schematic_lemma "?A type"
apply (rule form_rls)
done

schematic_lemma "?A type"
apply (rule form_rls)
back
apply (rule form_rls)
apply (rule form_rls)
done

schematic_lemma "PROD z:?A . N + ?B(z) type"
apply (rule form_rls)
apply (rule form_rls)
apply (rule form_rls)
apply (rule form_rls)
apply (rule form_rls)
done


subsection {* Multi-step proofs: Type inference *}

lemma "PROD w:N. N + N type"
apply (tactic form_tac)
done

schematic_lemma "<0, succ(0)> : ?A"
apply (tactic "intr_tac []")
done

schematic_lemma "PROD w:N . Eq(?A,w,w) type"
apply (tactic "typechk_tac []")
done

schematic_lemma "PROD x:N . PROD y:N . Eq(?A,x,y) type"
apply (tactic "typechk_tac []")
done

text "typechecking an application of fst"
schematic_lemma "(lam u. split(u, %v w. v)) ` <0, succ(0)> : ?A"
apply (tactic "typechk_tac []")
done

text "typechecking the predecessor function"
schematic_lemma "lam n. rec(n, 0, %x y. x) : ?A"
apply (tactic "typechk_tac []")
done

text "typechecking the addition function"
schematic_lemma "lam n. lam m. rec(n, m, %x y. succ(y)) : ?A"
apply (tactic "typechk_tac []")
done

(*Proofs involving arbitrary types.
  For concreteness, every type variable left over is forced to be N*)
ML {* val N_tac = TRYALL (rtac @{thm NF}) *}

schematic_lemma "lam w. <w,w> : ?A"
apply (tactic "typechk_tac []")
apply (tactic N_tac)
done

schematic_lemma "lam x. lam y. x : ?A"
apply (tactic "typechk_tac []")
apply (tactic N_tac)
done

text "typechecking fst (as a function object)"
schematic_lemma "lam i. split(i, %j k. j) : ?A"
apply (tactic "typechk_tac []")
apply (tactic N_tac)
done

end
