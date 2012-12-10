header {* Exception-Aware Relational Framework *}
theory Run
imports "~~/src/HOL/Imperative_HOL/Imperative_HOL"
begin

  text {*
    With Imperative HOL comes a relational framework. 
    However, this can only be used if exception freeness is already assumed.
    This results in some proof duplication, because exception freeness and 
    correctness need to be shown separately.

    In this theory, we develop a relational framework that is aware of 
    exceptions, and makes it possible to show correctness and exception 
    freeness in one run.
    *}

  
  text {*
    There are two types of states:
    \begin{enumerate}
      \item A normal (Some) state contains the current heap.
      \item An exception state is None
    \end{enumerate}
    The two states exactly correspond to the option monad in Imperative HOL.
    *}

type_synonym state = "Heap.heap option"

primrec is_exn where
  "is_exn (Some _) = False" |
  "is_exn None = True"

primrec the_state where
  "the_state (Some h) = h" 

-- "The exception-aware, relational semantics"

inductive run :: "'a Heap \<Rightarrow> state \<Rightarrow> state \<Rightarrow> 'a \<Rightarrow> bool" where
  push_exn: "is_exn \<sigma> \<Longrightarrow> run c \<sigma> \<sigma> r " |
  new_exn:  "\<lbrakk>\<not> is_exn \<sigma>; execute c (the_state \<sigma>) = None\<rbrakk> 
    \<Longrightarrow> run c \<sigma> None r" |
  regular:  "\<lbrakk>\<not> is_exn \<sigma>; execute c (the_state \<sigma>) = Some (r, h')\<rbrakk> 
    \<Longrightarrow> run c \<sigma> (Some h') r"


subsubsection "Link with @{text effect} and @{text success}"

lemma run_effectE: 
  assumes "run c \<sigma> \<sigma>' r"
  assumes "\<not>is_exn \<sigma>'"
  obtains h h' where
    "\<sigma>=Some h" "\<sigma>' = Some h'"
    "effect c h h' r"
  using assms
  unfolding effect_def
  apply (cases \<sigma>)
  by (auto simp add: run.simps)


lemma run_effectI: 
  assumes  "run c (Some h) (Some h') r"
  shows  "effect c h h' r"
  using run_effectE[OF assms] by auto

lemma effect_run:
  assumes "effect c h h' r"
  shows "run c (Some h) (Some h') r"
  using assms
  unfolding effect_def
  by (auto intro: run.intros) 

lemma success_run:
  assumes "success f h"
  obtains h' r where "run f (Some h) (Some h') r" 
proof -
  case goal1
  from assms(1) obtain r h' 
    where "Heap_Monad.execute f h = Some (r, h')" 
    unfolding success_def by auto
  from goal1[OF regular[of "Some h", simplified, OF this]] 
  show ?thesis .
qed


text {* run always yields a result *}
lemma run_complete:
  obtains \<sigma>' r where "run c \<sigma> \<sigma>' r"
  apply (cases "is_exn \<sigma>")
  apply (auto intro: run.intros)
  apply (cases "execute c (the_state \<sigma>)")  
  by (auto intro: run.intros)

lemma run_detE:
  assumes "run c \<sigma> \<sigma>' r" "run c \<sigma> \<tau> s"
          "\<not>is_exn \<sigma>"
  obtains "is_exn \<sigma>'" "\<sigma>' = \<tau>" | "\<not> is_exn \<sigma>'" "\<sigma>' = \<tau>" "r = s"
  using assms
  by (auto simp add: run.simps)
   
lemma run_detI:
  assumes "run c (Some h) (Some h') r" "run c (Some h) \<sigma> s"
  shows "\<sigma> = Some h' \<and> r = s"
  using assms
  by (auto simp add: run.simps)

lemma run_exn: 
  assumes "run f \<sigma> \<sigma>' r"
          "is_exn \<sigma>"
  obtains "\<sigma>'=\<sigma>"
  using assms
  apply (cases \<sigma>)
  apply (auto elim!: run.cases intro: that)
  done

subsubsection {* Elimination Rules for Basic Combinators *}

ML {* structure Run_Elims = Named_Thms(
  val name = @{binding "run_elims"}
  val description = "elemination rules for run"
) *}

setup Run_Elims.setup

lemma runE[run_elims]:
  assumes "run (f \<guillemotright>= g) \<sigma> \<sigma>'' r"
  obtains \<sigma>' r' where 
    "run f \<sigma> \<sigma>' r'"
    "run (g r') \<sigma>' \<sigma>'' r"
using assms
apply (cases "is_exn \<sigma>")
apply (simp add: run.simps)
apply (cases "execute f (the_state \<sigma>)")
apply (simp add: run.simps bind_def)
apply (auto simp add: bind_def run.simps)
apply (cases \<sigma>)
by auto

lemma runE'[run_elims]:
  assumes "run (f >> g) \<sigma> \<sigma>'' res"
  obtains \<sigma>t rt where 
    "run f \<sigma> \<sigma>t rt"
    "run g \<sigma>t \<sigma>'' res"
  using assms
  by (rule_tac runE)


lemma run_return[run_elims]:
  assumes "run (return x) \<sigma> \<sigma>' r"
  obtains "r = x" "\<sigma>' = \<sigma>" "\<not> is_exn \<sigma>" | "\<sigma> = None"
  using assms  apply (cases \<sigma>) apply (simp add: run.simps)
  by (auto simp add: run.simps execute_simps)


lemma run_raise_iff: "run (raise s) \<sigma> \<sigma>' r \<longleftrightarrow> (\<sigma>'=None)"
  apply (cases \<sigma>)
  by (auto simp add: run.simps execute_simps)

lemma run_raise[run_elims]:
  assumes "run (raise s) \<sigma> \<sigma>' r"
  obtains "\<sigma>' = None"
  using assms by (simp add: run_raise_iff)

lemma run_raiseI:
  "run (raise s) \<sigma> None r" by (simp add: run_raise_iff)

lemma run_if[run_elims]:
  assumes "run (if c then t else e) h h' r"
  obtains "c" "run t h h' r"
        | "\<not>c" "run e h h' r"
  using assms
  by (auto split: split_if_asm)
  
lemma run_option_case[run_elims]:
  assumes "run (case x of None \<Rightarrow> n | Some y \<Rightarrow> s y) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "x = None" "run n \<sigma> \<sigma>' r"
        | y where "x = Some y" "run (s y) \<sigma> \<sigma>' r" 
  using assms
  by (cases x) simp_all

lemma run_heap[run_elims]:
  assumes "run (Heap_Monad.heap f) \<sigma> \<sigma>' res"
          "\<not>is_exn \<sigma>"
  obtains "\<sigma>' = Some (snd (f (the_state \<sigma>)))" 
  and "res = (fst (f (the_state \<sigma>)))"
  using assms
  apply (cases \<sigma>)
  apply simp
  apply (auto simp add: run.simps)
  apply (simp add: execute_simps)
  
  apply (simp only: execute_simps)
proof -
  case goal1
  from goal1(2) have "h' = snd (f a)" "res = fst (f a)" by simp_all
  from goal1(1)[OF this] show ?case .
qed

subsection {* Array Commands*}

lemma run_length[run_elims]:
  assumes "run (Array.len a) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<not>is_exn \<sigma>" "\<sigma>' = \<sigma>" "r = Array.length (the_state \<sigma>) a"
  using assms
  apply (cases \<sigma>)
  by (auto simp add: run.simps execute_simps)


lemma run_new_array[run_elims]:
  assumes "run (Array.new n x) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<sigma>' = Some (snd (Array.alloc (replicate n x) (the_state \<sigma>)))"
  and "r = fst (Array.alloc (replicate n x) (the_state \<sigma>))"
  and "Array.get (the_state \<sigma>') r = replicate n x"
  using assms 
  apply (cases \<sigma>)
  apply simp
  apply (auto simp add: run.simps)
  apply (simp add: execute_simps)
  apply (simp add: Array.get_alloc)
proof -
  case goal1
  from goal1(2) have "h' = snd (Array.alloc (replicate n x) a)" 
    "r = fst (Array.alloc (replicate n x) a)" by (auto simp add: execute_simps)
  from goal1(1)[OF this] show ?case .
qed


lemma run_upd[run_elims]:
  assumes "run (Array.upd i x a) \<sigma> \<sigma>' res"
          "\<not>is_exn \<sigma>"
  obtains "\<not> i < Array.length (the_state \<sigma>) a" 
          "\<sigma>' = None" 
  |
          "i < Array.length (the_state \<sigma>) a" 
          "\<sigma>' = Some (Array.update a i x (the_state \<sigma>))" 
          "res = a"
  using assms
  apply (cases \<sigma>)
  apply simp
  apply (cases "i < Array.length (the_state \<sigma>) a")
  apply (auto simp add: run.simps)
  apply (simp_all only: execute_simps)
  prefer 3
  apply auto[2]
proof -
  case (goal1 aa h')
  from goal1(4) have "h' = Array.update a i x aa" "res = a" by auto
  from goal1(2)[OF this] show ?case .
qed 


lemma run_nth[run_elims]:
  assumes "run (Array.nth a i) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<not>is_exn \<sigma>" 
    "i < Array.length (the_state \<sigma>) a" 
    "r = (Array.get (the_state \<sigma>) a) ! i" 
    "\<sigma>' = \<sigma>" 
  | 
    "\<not> i < Array.length (the_state \<sigma>) a" 
    "\<sigma>' = None"
  using assms
  apply (cases \<sigma>)
  apply simp
  apply (cases "i < Array.length (the_state \<sigma>) a")
  apply (auto simp add: run.simps)
  apply (simp_all only: execute_simps)
  prefer 3
  apply auto[2]
proof -
  case (goal1 aa h')
  from goal1(4) have "r = Array.get aa a ! i" "h' = aa" by auto
  from goal1(1)[OF this] show ?case .
qed 


lemma run_of_list[run_elims]:
  assumes "run (Array.of_list xs) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<sigma>' = Some (snd (Array.alloc xs (the_state \<sigma>)))"
          "r = fst (Array.alloc xs (the_state \<sigma>))"
          "Array.get (the_state \<sigma>') r = xs"
  using assms
  apply (cases \<sigma>)
  apply simp
  apply (auto simp add: run.simps)
  apply (simp add: execute_simps)
  apply (simp add: Array.get_alloc)
proof -
  case goal1
  from goal1(2) have "h' = snd (Array.alloc xs a)" 
    "r = fst (Array.alloc xs a)" by (auto simp add: execute_simps)
  from goal1(1)[OF this] show ?case .
qed

lemma run_freeze[run_elims]:
  assumes "run (Array.freeze a) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<sigma>' = \<sigma>"
          "r = Array.get (the_state \<sigma>) a"
  using assms
  apply (cases \<sigma>)
  by (auto simp add: run.simps execute_simps)



subsection {* Reference Commands*}

lemma run_new_ref[run_elims]:
  assumes "run (ref x) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<sigma>' = Some (snd (Ref.alloc x (the_state \<sigma>)))"
          "r = fst (Ref.alloc x (the_state \<sigma>))"
          "Ref.get (the_state \<sigma>') r = x"
  using assms
  apply (cases \<sigma>)
  apply simp
  apply (auto simp add: run.simps)
  apply (simp add: execute_simps)
proof -
  case goal1
  from goal1(2) have 
    "h' = snd (Ref.alloc x a)" 
    "r = fst (Ref.alloc x a)"
    by (auto simp add: execute_simps)
  from goal1(1)[OF this] show ?case .
qed

lemma "fst (Ref.alloc x h) = Ref (lim h)"
  unfolding alloc_def
  by (simp add: Let_def)

  
lemma run_update[run_elims]:
  assumes "run (p := x) \<sigma> \<sigma>' r"
          "\<not>is_exn \<sigma>"
  obtains "\<sigma>' = Some (Ref.set p x (the_state \<sigma>))" "r = ()"
  using assms
  unfolding Ref.update_def
  by (auto elim: run_heap)

lemma run_lookup[run_elims]:
  assumes "run (!p) \<sigma> \<sigma>' r"
          "\<not> is_exn \<sigma>"
  obtains "\<not>is_exn \<sigma>" "\<sigma>' = \<sigma>" "r = Ref.get (the_state \<sigma>) p"
  using assms
  apply (cases \<sigma>)
  by (auto simp add: run.simps execute_simps)
  
end
