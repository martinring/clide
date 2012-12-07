(* Title:     HOL/MiniML/Type.thy

   Author:    Wolfgang Naraschewski and Tobias Nipkow
   Copyright  1996 TU Muenchen
*)

header "MiniML-types and type substitutions"

theory Type
imports Maybe
begin

-- "type expressions"
datatype "typ" = TVar nat | Fun "typ" "typ" (infixr "->" 70)

-- "type schemata"
datatype type_scheme = FVar nat | BVar nat | SFun type_scheme type_scheme (infixr "=->" 70)

-- "embedding types into type schemata"
primrec mk_scheme :: "typ => type_scheme" where
  "mk_scheme (TVar n) = (FVar n)"
| "mk_scheme (t1 -> t2) = ((mk_scheme t1) =-> (mk_scheme t2))"

-- "type variable substitution"
type_synonym subst = "nat => typ"

class type_struct =
  fixes free_tv :: "'a => nat set"
    -- {* @{text "free_tv s"}: the type variables occuring freely in the type structure s *}
  fixes free_tv_ML :: "'a => nat list"
    -- {* executable version of @{text free_tv}: Implementation with lists *}
  fixes bound_tv :: "'a => nat set"
    -- {* @{text "bound_tv s"}: the type variables occuring bound in the type structure s *}
  fixes min_new_bound_tv :: "'a => nat"
    -- "minimal new free / bound variable"
  fixes app_subst :: "subst => 'a => 'a" ("$")
    -- "extension of substitution to type structures"

instantiation "typ" :: type_struct
begin

primrec free_tv_typ where
  free_tv_TVar:    "free_tv (TVar m) = {m}"
| free_tv_Fun:     "free_tv (t1 -> t2) = (free_tv t1) Un (free_tv t2)"

primrec app_subst_typ where
  app_subst_TVar: "$ S (TVar n) = S n" 
| app_subst_Fun:  "$ S (t1 -> t2) = ($ S t1) -> ($ S t2)" 

instance ..

end

instantiation type_scheme :: type_struct
begin

primrec free_tv_type_scheme where
  "free_tv (FVar m) = {m}"
| "free_tv (BVar m) = {}"
| "free_tv (S1 =-> S2) = (free_tv S1) Un (free_tv S2)"

primrec free_tv_ML_type_scheme where
  "free_tv_ML (FVar m) = [m]"
| "free_tv_ML (BVar m) = []"
| "free_tv_ML (S1 =-> S2) = (free_tv_ML S1) @ (free_tv_ML S2)"

primrec bound_tv_type_scheme where
  "bound_tv (FVar m) = {}"
| "bound_tv (BVar m) = {m}"
| "bound_tv (S1 =-> S2) = (bound_tv S1) Un (bound_tv S2)"

primrec min_new_bound_tv_type_scheme where
  "min_new_bound_tv (FVar n) = 0"
| "min_new_bound_tv (BVar n) = Suc n"
| "min_new_bound_tv (sch1 =-> sch2) = max (min_new_bound_tv sch1) (min_new_bound_tv sch2)"

primrec app_subst_type_scheme where
  "$ S (FVar n) = mk_scheme (S n)"
| "$ S (BVar n) = (BVar n)"
| "$ S (sch1 =-> sch2) = ($ S sch1) =-> ($ S sch2)"

instance ..

end

instantiation list :: (type_struct) type_struct
begin

primrec free_tv_list where
  "free_tv [] = {}"
| "free_tv (x#l) = (free_tv x) Un (free_tv l)"

primrec free_tv_ML_list where
  "free_tv_ML [] = []"
| "free_tv_ML (x#l) = (free_tv_ML x) @ (free_tv_ML l)"

primrec bound_tv_list where
  "bound_tv [] = {}"
| "bound_tv (x#l) = (bound_tv x) Un (bound_tv l)"

definition app_subst_list where
  app_subst_list: "$ S = map ($ S)"

instance ..

end

text  
{* @{text "new_tv s n"} computes whether n is a new type variable w.r.t. a type 
   structure s, i.e. whether n is greater than any type variable 
   occuring in the type structure *}
definition
  new_tv :: "[nat,'a::type_struct] => bool" where
  "new_tv n ts = (! m. m:(free_tv ts) --> m<n)"

-- "identity"
definition
  id_subst :: subst where
  "id_subst = (%n. TVar n)"

-- "domain of a substitution"
definition
  dom :: "subst => nat set" where
  "dom S = {n. S n ~= TVar n}" 

-- "codomain of a substitution: the introduced variables"
definition
  cod :: "subst => nat set" where
  "cod S = (UN m:dom S. (free_tv (S m)))"

class of_nat =
  fixes of_nat :: "nat \<Rightarrow> 'a"

instantiation nat :: of_nat
begin

definition
  "of_nat n = n"

instance ..

end

class typ_of =
  fixes typ_of :: "'a \<Rightarrow> typ"

instantiation "typ" :: typ_of
begin

definition
  "typ_of T = T"

instance ..

end

instantiation "fun" :: (of_nat, typ_of) type_struct
begin

definition free_tv_fun where
  "free_tv f = (let S = \<lambda>n. typ_of (f (of_nat n)) in (dom S) Un (cod S))"

instance ..

end

lemma free_tv_subst:
  "free_tv S = (dom S) Un (cod S)"
  by (simp add: free_tv_fun_def of_nat_nat_def typ_of_typ_def )

-- "unification algorithm mgu"
axiomatization mgu :: "typ \<Rightarrow> typ \<Rightarrow> subst option" where
  mgu_eq:   "mgu t1 t2 = Some U ==> $U t1 = $U t2"
  and mgu_mg:   "[| (mgu t1 t2) = Some U; $S t1 = $S t2 |] ==> ? R. S = $R o U"
  and mgu_Some: "$S t1 = $S t2 ==> ? U. mgu t1 t2 = Some U"
  and mgu_free: "mgu t1 t2 = Some U ==> (free_tv U) <= (free_tv t1) Un (free_tv t2)"


declare mgu_eq [simp] mgu_mg [simp] mgu_free [simp]
lemma mk_scheme_Fun [rule_format]: "mk_scheme t = sch1 =-> sch2 --> (? t1 t2. sch1 = mk_scheme t1 & sch2 = mk_scheme t2)"
apply (induct_tac "t")
apply (simp (no_asm))
apply simp
apply fast
done

lemma mk_scheme_injective [rule_format]: "!t'. mk_scheme t = mk_scheme t' --> t=t'"
apply (induct_tac "t")
 apply (rule allI)
 apply (induct_tac "t'")
  apply (simp (no_asm))
 apply simp
apply (rule allI)
apply (induct_tac "t'")
 apply (simp (no_asm))
apply simp
done

lemma free_tv_mk_scheme: "free_tv (mk_scheme t) = free_tv t"
apply (induct_tac "t")
apply (simp_all (no_asm_simp))
done

declare free_tv_mk_scheme [simp]

lemma subst_mk_scheme: "$ S (mk_scheme t) = mk_scheme ($ S t)"
apply (induct_tac "t")
apply (simp_all (no_asm_simp))
done

declare subst_mk_scheme [simp]


-- "constructor laws for @{text app_subst}"

lemma app_subst_Nil: 
  "$ S [] = []"

apply (unfold app_subst_list)
apply (simp (no_asm))
done

lemma app_subst_Cons: 
  "$ S (x#l) = ($ S x)#($ S l)"
apply (unfold app_subst_list)
apply (simp (no_asm))
done

declare app_subst_Nil [simp] app_subst_Cons [simp]


-- {* constructor laws for @{text new_tv} *}

lemma new_tv_TVar: 
  "new_tv n (TVar m) = (m<n)"

apply (unfold new_tv_def)
apply (fastforce)
done

lemma new_tv_FVar: 
  "new_tv n (FVar m) = (m<n)"
apply (unfold new_tv_def)
apply (fastforce)
done

lemma new_tv_BVar: 
  "new_tv n (BVar m) = True"
apply (unfold new_tv_def)
apply (simp (no_asm))
done

lemma new_tv_Fun: 
  "new_tv n (t1 -> t2) = (new_tv n t1 & new_tv n t2)"
apply (unfold new_tv_def)
apply (fastforce)
done

lemma new_tv_Fun2: 
  "new_tv n (t1 =-> t2) = (new_tv n t1 & new_tv n t2)"
apply (unfold new_tv_def)
apply (fastforce)
done

lemma new_tv_Nil: 
  "new_tv n []"
apply (unfold new_tv_def)
apply (simp (no_asm))
done

lemma new_tv_Cons: 
  "new_tv n (x#l) = (new_tv n x & new_tv n l)"
apply (unfold new_tv_def)
apply (fastforce)
done

lemma new_tv_TVar_subst: "new_tv n TVar"
apply (unfold new_tv_def)
apply (intro strip)
apply (simp add: free_tv_subst dom_def cod_def)
done

declare 
  new_tv_TVar [simp] new_tv_FVar [simp] new_tv_BVar [simp] 
  new_tv_Fun [simp] new_tv_Fun2 [simp] new_tv_Nil [simp] 
  new_tv_Cons [simp] new_tv_TVar_subst [simp]

lemma new_tv_id_subst [simp]: "new_tv n id_subst"
  by (simp add: id_subst_def new_tv_def free_tv_subst dom_def cod_def)

lemma new_if_subst_type_scheme [simp]: "new_tv n (sch::type_scheme) \<Longrightarrow>
    $(%k. if k<n then S k else S' k) sch = $S sch"
  by (induct sch) simp_all

lemma new_if_subst_type_scheme_list [simp]: "new_tv n (A::type_scheme list) \<Longrightarrow>
    $(%k. if k<n then S k else S' k) A = $S A"
  by (induct A) simp_all


-- "constructor laws for @{text dom} and @{text cod}"

lemma dom_id_subst [simp]: "dom id_subst = {}"
  unfolding dom_def id_subst_def empty_def by simp

lemma cod_id_subst [simp]: "cod id_subst = {}"
  unfolding cod_def by simp


lemma free_tv_id_subst [simp]: "free_tv id_subst = {}"
  unfolding free_tv_subst by simp

lemma free_tv_nth_A_impl_free_tv_A [rule_format, simp]:
  "!n. n < length A --> x : free_tv (A!n) --> x : free_tv A"
apply (induct A)
apply simp
apply (rule allI)
apply (induct_tac n)
apply simp
apply simp
done

lemma free_tv_nth_nat_A [rule_format]:
  "!nat. nat < length A --> x : free_tv (A!nat) --> x : free_tv A"
apply (induct A)
apply simp
apply (rule allI)
apply (induct_tac nat)
apply (intro strip)
apply simp
apply simp
done

text
{* if two substitutions yield the same result if applied to a type
   structure the substitutions coincide on the free type variables
   occurring in the type structure *}

lemma typ_substitutions_only_on_free_variables: 
  "(!x:free_tv t. (S x) = (S' x)) \<Longrightarrow> $ S (t::typ) = $ S' t"
  by (induct t) simp_all

lemma eq_free_eq_subst_te: "(!n. n:(free_tv t) --> S1 n = S2 n) ==> $ S1 (t::typ) = $ S2 t"
apply (rule typ_substitutions_only_on_free_variables)
apply simp
done

lemma scheme_substitutions_only_on_free_variables:
  "(!x:free_tv sch. (S x) = (S' x)) \<Longrightarrow> $ S (sch::type_scheme) = $ S' sch"
  by (induct sch) simp_all

lemma eq_free_eq_subst_type_scheme: 
  "(!n. n:(free_tv sch) --> S1 n = S2 n) ==> $ S1 (sch::type_scheme) = $ S2 sch"
apply (rule scheme_substitutions_only_on_free_variables)
apply simp
done

lemma eq_free_eq_subst_scheme_list:
  "(!n. n:(free_tv A) --> S1 n = S2 n) \<Longrightarrow> $S1 (A::type_scheme list) = $S2 A"
proof (induct A)
  case Nil then show ?case by fastforce
next
  case Cons then show ?case by (fastforce intro: eq_free_eq_subst_type_scheme)
qed

lemma weaken_asm_Un: "((!x:A. (P x)) --> Q) ==> ((!x:A Un B. (P x)) --> Q)"
  by fast

lemma scheme_list_substitutions_only_on_free_variables [rule_format]:
  "(!x:free_tv A. (S x) = (S' x)) --> $ S (A::type_scheme list) = $ S' A"
apply (induct_tac A)
apply simp
apply simp
apply (rule weaken_asm_Un)
apply (intro strip)
apply (erule scheme_substitutions_only_on_free_variables)
done

lemma eq_subst_te_eq_free:
  "$ S1 (t::typ) = $ S2 t \<Longrightarrow> n:(free_tv t) \<Longrightarrow> S1 n = S2 n"
  by (induct t) auto

lemma eq_subst_type_scheme_eq_free [rule_format]: 
  "$ S1 (sch::type_scheme) = $ S2 sch --> n:(free_tv sch) --> S1 n = S2 n"
apply (induct_tac "sch")
(* case TVar n *)
apply simp
(* case BVar n *)
apply (intro strip)
apply (erule mk_scheme_injective)
apply simp
(* case Fun t1 t2 *)
apply simp
done

lemma eq_subst_scheme_list_eq_free:
  "$S1 (A::type_scheme list) = $S2 A \<Longrightarrow> n:(free_tv A) \<Longrightarrow> S1 n = S2 n"
proof (induct A)
  case Nil
  then show ?case by fastforce
next
  case Cons
  then show ?case by (fastforce intro: eq_subst_type_scheme_eq_free)
qed

lemma codD: "v : cod S ==> v : free_tv S"
  unfolding free_tv_subst by blast

lemma not_free_impl_id: "x ~: free_tv S ==> S x = TVar x"
  unfolding free_tv_subst dom_def by blast

lemma free_tv_le_new_tv: "[| new_tv n t; m:free_tv t |] ==> m<n"
  unfolding new_tv_def by blast

lemma cod_app_subst [simp]:
  "[| v : free_tv(S n); v~=n |] ==> v : cod S"
apply (unfold dom_def cod_def UNION_eq Bex_def)
apply (simp (no_asm))
apply (safe intro!: exI)
prefer 2 apply (assumption)
apply simp
done

lemma free_tv_subst_var: "free_tv (S (v::nat)) <= insert v (cod S)"
apply (cases "v:dom S")
apply (fastforce simp add: cod_def)
apply (fastforce simp add: dom_def)
done

lemma free_tv_app_subst_te: "free_tv ($ S (t::typ)) <= cod S Un free_tv t"
proof (induct t)
  case (TVar n) then show ?case by (simp add: free_tv_subst_var)
next
  case (Fun t1 t2) then show ?case by fastforce
qed

lemma free_tv_app_subst_type_scheme:
    "free_tv ($ S (sch::type_scheme)) <= cod S Un free_tv sch"
proof (induct sch)
  case (FVar n)
  then show ?case by (simp add: free_tv_subst_var)
next
  case (BVar n)
  then show ?case by simp
next
  case (SFun t1 t2)
  then show ?case by fastforce
qed

lemma free_tv_app_subst_scheme_list: "free_tv ($ S (A::type_scheme list)) <= cod S Un free_tv A"
proof (induct A)
  case Nil then show ?case by simp
next
  case (Cons a al)
  with free_tv_app_subst_type_scheme
  show ?case by fastforce
qed

lemma free_tv_comp_subst: 
  "free_tv (%u::nat. $ s1 (s2 u) :: typ) <=    
    free_tv s1 Un free_tv s2"
  unfolding free_tv_subst dom_def
  by (force simp add: cod_def dom_def
    dest!:free_tv_app_subst_te [THEN subsetD])

lemma free_tv_o_subst: 
    "free_tv ($ S1 o S2) <= free_tv S1 Un free_tv (S2 :: nat => typ)"
  unfolding o_def by (rule free_tv_comp_subst)

lemma free_tv_of_substitutions_extend_to_types:
    "n : free_tv t \<Longrightarrow> free_tv (S n) <= free_tv ($ S t::typ)"
  by (induct t) auto

lemma free_tv_of_substitutions_extend_to_schemes:
    "n : free_tv sch \<Longrightarrow> free_tv (S n) <= free_tv ($ S sch::type_scheme)"
  by (induct sch) auto

lemma free_tv_of_substitutions_extend_to_scheme_lists [simp]:
    "n : free_tv A \<Longrightarrow> free_tv (S n) <= free_tv ($ S A::type_scheme list)"
  by (induct A) (auto dest: free_tv_of_substitutions_extend_to_schemes)

lemma free_tv_ML_scheme:
  fixes sch :: type_scheme
  shows "(n : free_tv sch) = (n: set (free_tv_ML sch))"
  by (induct sch) simp_all

lemma free_tv_ML_scheme_list:
  fixes A :: "type_scheme list"
  shows "(n : free_tv A) = (n: set (free_tv_ML A))"
  by (induct_tac A) (simp_all add: free_tv_ML_scheme)


-- "lemmata for @{text bound_tv}"

lemma bound_tv_mk_scheme [simp]: "bound_tv (mk_scheme t) = {}"
  by (induct t) simp_all

lemma bound_tv_subst_scheme [simp]:
  fixes sch :: type_scheme
  shows "bound_tv ($ S sch) = bound_tv sch"
  by (induct sch) simp_all

lemma bound_tv_subst_scheme_list [simp]: 
  fixes A :: "type_scheme list"
  shows "bound_tv ($ S A) = bound_tv A"
  by (induct A) simp_all


-- "lemmata for @{text new_tv}"

lemma new_tv_subst: 
  "new_tv n S = ((!m. n <= m --> (S m = TVar m)) &  
                 (! l. l < n --> new_tv n (S l) ))"

apply (unfold new_tv_def)
apply (safe)
  (* ==> *)
  apply (fastforce dest: leD simp add: free_tv_subst dom_def)
 apply (subgoal_tac "m:cod S | S l = TVar l")
  apply safe
   apply (fastforce dest: UnI2 simp add: free_tv_subst)
  apply (drule_tac P = "%x. m:free_tv x" in subst , assumption)
  apply simp
 apply (fastforce simp add: free_tv_subst cod_def dom_def)
(* <== *)
apply (unfold free_tv_subst cod_def dom_def) 
apply safe
apply (metis not_leE)+
done

lemma new_tv_list: "new_tv n x = (!y:set x. new_tv n y)"
  by (induct x) simp_all

-- "substitution affects only variables occurring freely"
lemma subst_te_new_tv [simp]:
    "new_tv n (t::typ) --> $(%x. if x=n then t' else S x) t = $S t"
  by (induct t) simp_all

lemma subst_te_new_type_scheme [simp]:
    "new_tv n (sch::type_scheme) \<Longrightarrow> $(%x. if x=n then sch' else S x) sch = $S sch"
  by (induct sch) simp_all

lemma subst_tel_new_scheme_list [simp]:
    "new_tv n (A::type_scheme list) \<Longrightarrow> $(%x. if x=n then t else S x) A = $S A"
  by (induct A) simp_all


-- "all greater variables are also new"
lemma new_tv_le: 
  "n<=m ==> new_tv n t ==> new_tv m t"
apply (unfold new_tv_def)
apply safe
apply (drule spec)
apply (erule (1) notE impE)
apply (simp (no_asm))
done

lemma [simp]: "new_tv n t \<Longrightarrow> new_tv (Suc n) t"
  by (rule lessI [THEN less_imp_le [THEN new_tv_le]])

lemma new_tv_typ_le: "n<=m ==> new_tv n (t::typ) ==> new_tv m t"
  by (simp add: new_tv_le)

lemma new_scheme_list_le: "n<=m ==> new_tv n (A::type_scheme list) ==> new_tv m A"
  by (simp add: new_tv_le)

lemma new_tv_subst_le: "n<=m ==> new_tv n (S::subst) ==> new_tv m S"
  by (simp add: new_tv_le)

-- "@{text new_tv} property remains if a substitution is applied"
lemma new_tv_subst_var: 
  "[| n<m; new_tv m (S::subst) |] ==> new_tv m (S n)"
  by (simp add: new_tv_subst)

lemma new_tv_subst_te [simp]:
    "new_tv n S \<Longrightarrow> new_tv n (t::typ) \<Longrightarrow> new_tv n ($ S t)"
  by (induct t) (auto simp add: new_tv_subst)

lemma new_tv_subst_type_scheme [rule_format, simp]: 
  "new_tv n S --> new_tv n (sch::type_scheme) --> new_tv n ($ S sch)"
apply (induct sch)
apply (simp_all)
apply (unfold new_tv_def)
apply (simp (no_asm) add: free_tv_subst dom_def cod_def)
apply (intro strip)
apply (case_tac "S nat = TVar nat")
apply simp
apply (drule_tac x = "m" in spec)
apply fast
done

lemma new_tv_subst_scheme_list [simp]:
    "new_tv n S \<Longrightarrow> new_tv n (A::type_scheme list) \<Longrightarrow> new_tv n ($ S A)"
  by (induct A) auto

lemma new_tv_Suc_list: "new_tv n A --> new_tv (Suc n) ((TVar n)#A)"
  by (simp add: new_tv_list)

lemma new_tv_only_depends_on_free_tv_type_scheme:
  fixes sch :: type_scheme
  shows "free_tv sch = free_tv sch' \<Longrightarrow> new_tv n sch \<Longrightarrow> new_tv n sch'"
  unfolding new_tv_def by simp

lemma new_tv_only_depends_on_free_tv_scheme_list:
  fixes A :: "type_scheme list"
  shows "free_tv A = free_tv A' \<Longrightarrow> new_tv n A \<Longrightarrow> new_tv n A'"
  unfolding new_tv_def by simp

lemma new_tv_nth_nat_A [rule_format]: 
  "!nat. nat < length A --> new_tv n A --> (new_tv n (A!nat))"
apply (unfold new_tv_def)
apply (induct A)
apply simp
apply (rule allI)
apply (induct_tac "nat")
apply (intro strip)
apply simp
apply (simp (no_asm))
done


-- "composition of substitutions preserves @{text new_tv} proposition"
lemma new_tv_subst_comp_1 [simp]: 
  "[| new_tv n (S::subst); new_tv n R |] ==> new_tv n (($ R) o S)"
  by (simp add: new_tv_subst)

lemma new_tv_subst_comp_2 [simp]:
  "[| new_tv n (S::subst); new_tv n R |] ==> new_tv n (%v.$ R (S v))"
  by (simp add: new_tv_subst)

-- "new type variables do not occur freely in a type structure"
lemma new_tv_not_free_tv [simp]:
    "new_tv n A ==> n~:(free_tv A)"
  by (auto simp add: new_tv_def)

lemma fresh_variable_types [simp]: "!!t::typ. ? n. (new_tv n t)"
apply (unfold new_tv_def)
apply (induct_tac t)
apply (rule_tac x = "Suc nat" in exI)
apply (simp (no_asm_simp))
apply (erule exE)+
apply (rename_tac "n'")
apply (rule_tac x = "max n n'" in exI)
apply (simp add: less_max_iff_disj)
done

lemma fresh_variable_type_schemes [simp]:
  "!!sch::type_scheme. ? n. (new_tv n sch)"
apply (unfold new_tv_def)
apply (induct_tac sch)
apply (rule_tac x = "Suc nat" in exI)
apply (simp (no_asm))
apply (rule_tac x = "Suc nat" in exI)
apply (simp (no_asm))
apply (erule exE)+
apply (rename_tac "n'")
apply (rule_tac x = "max n n'" in exI)
apply (simp add: less_max_iff_disj)
done

lemma fresh_variable_type_scheme_lists [simp]: 
  "!!A::type_scheme list. ? n. (new_tv n A)"
apply (induct_tac A)
apply (simp (no_asm))
apply (simp (no_asm))
apply (erule exE)
apply (cut_tac sch = "a" in fresh_variable_type_schemes)
apply (erule exE)
apply (rename_tac "n'")
apply (rule_tac x = " (max n n') " in exI)
apply (subgoal_tac "n <= (max n n') ")
apply (subgoal_tac "n' <= (max n n') ")
apply (fast dest: new_tv_le)
apply (simp_all add: le_max_iff_disj)
done

lemma make_one_new_out_of_two: 
  "[| ? n1. (new_tv n1 x); ? n2. (new_tv n2 y)|] ==> ? n. (new_tv n x) & (new_tv n y)"
apply (erule exE)+
apply (rename_tac "n1" "n2")
apply (rule_tac x = " (max n1 n2) " in exI)
apply (subgoal_tac "n1 <= max n1 n2")
apply (subgoal_tac "n2 <= max n1 n2")
apply (fast dest: new_tv_le)
apply (simp_all (no_asm) add: le_max_iff_disj)
done

lemma ex_fresh_variable: 
  "!!(A::type_scheme list) (A'::type_scheme list) (t::typ) (t'::typ).  
          ? n. (new_tv n A) & (new_tv n A') & (new_tv n t) & (new_tv n t')"
apply (cut_tac t = "t" in fresh_variable_types)
apply (cut_tac t = "t'" in fresh_variable_types)
apply (drule make_one_new_out_of_two)
apply assumption
apply (erule_tac V = "? n. new_tv n t'" in thin_rl)
apply (cut_tac A = "A" in fresh_variable_type_scheme_lists)
apply (cut_tac A = "A'" in fresh_variable_type_scheme_lists)
apply (rotate_tac 1)
apply (drule make_one_new_out_of_two)
apply assumption
apply (erule_tac V = "? n. new_tv n A'" in thin_rl)
apply (erule exE)+
apply (rename_tac n2 n1)
apply (rule_tac x = " (max n1 n2) " in exI)
apply (unfold new_tv_def)
apply (simp (no_asm) add: less_max_iff_disj)
apply blast
done

-- "mgu does not introduce new type variables"
lemma mgu_new: 
      "[|mgu t1 t2 = Some u; new_tv n t1; new_tv n t2|] ==> new_tv n u"
apply (unfold new_tv_def)
apply (fast dest: mgu_free)
done


(* lemmata for substitutions *)

lemma length_app_subst_list [simp]:
   "!!A:: ('a::type_struct) list. length ($ S A) = length A"
  unfolding app_subst_list by simp

lemma subst_TVar_scheme [simp]:
  fixes sch :: type_scheme
  shows "$ TVar sch = sch"
  by (induct sch) simp_all

lemma subst_TVar_scheme_list [simp]:
  fixes A :: "type_scheme list"
  shows "$ TVar A = A"
  by (induct A) (simp_all add: app_subst_list)

-- "application of @{text id_subst} does not change type expression"
lemma app_subst_id_te [simp]: "$ id_subst = (%t::typ. t)"
apply (unfold id_subst_def)
apply (rule ext)
apply (induct_tac "t")
apply simp_all
done

lemma app_subst_id_type_scheme [simp]:
  "$ id_subst = (%sch::type_scheme. sch)"
apply (unfold id_subst_def)
apply (rule ext)
apply (induct_tac "sch")
apply simp_all
done

-- "application of @{text id_subst} does not change list of type expressions"
lemma app_subst_id_tel [simp]: 
  "$ id_subst = (%A::type_scheme list. A)"
apply (unfold app_subst_list)
apply (rule ext)
apply (induct_tac "A")
apply simp_all
done

lemma id_subst_sch [simp]:
  fixes sch :: type_scheme
  shows "$ id_subst sch = sch"
  by (induct sch) (simp_all add: id_subst_def)

lemma id_subst_A [simp]:
  fixes A :: "type_scheme list"
  shows "$ id_subst A = A"
  by (induct A) simp_all

-- "composition of substitutions"
lemma o_id_subst [simp]: "$S o id_subst = S"
  unfolding id_subst_def o_def by simp

lemma subst_comp_te: "$ R ($ S t::typ) = $ (%x. $ R (S x) ) t"
  by (induct t) simp_all

lemma subst_comp_type_scheme: 
  "$ R ($ S sch::type_scheme) = $ (%x. $ R (S x) ) sch"
  by (induct sch) simp_all

lemma subst_comp_scheme_list: 
  "$ R ($ S A::type_scheme list) = $ (%x. $ R (S x)) A"
unfolding app_subst_list
proof (induct A)
  case Nil then show ?case by simp
next
  case (Cons x xl)
  then show ?case by (simp add: subst_comp_type_scheme)
qed

lemma subst_id_on_type_scheme_list': 
  fixes A :: "type_scheme list"
  shows "!x : free_tv A. S x = (TVar x) ==> $ S A = $ id_subst A"
apply (rule scheme_list_substitutions_only_on_free_variables)
apply (simp add: id_subst_def)
done

lemma subst_id_on_type_scheme_list: 
  fixes A :: "type_scheme list"
  shows "!x : free_tv A. S x = (TVar x) ==> $ S A = A"
apply (subst subst_id_on_type_scheme_list')
apply assumption
apply simp
done

lemma nth_subst [rule_format]: 
  "!n. n < length A --> ($ S A)!n = $S (A!n)"
apply (induct A)
apply simp
apply (rule allI)
apply (rename_tac "n1")
apply (induct_tac "n1")
apply simp
apply simp
done

end
