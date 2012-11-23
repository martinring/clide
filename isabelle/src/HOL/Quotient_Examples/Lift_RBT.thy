(*  Title:      HOL/Quotient_Examples/Lift_RBT.thy
    Author:     Lukas Bulwahn and Ondrej Kuncar
*)

header {* Lifting operations of RBT trees *}

theory Lift_RBT 
imports Main "~~/src/HOL/Library/RBT_Impl"
begin

subsection {* Type definition *}

typedef (open) ('a, 'b) rbt = "{t :: ('a\<Colon>linorder, 'b) RBT_Impl.rbt. is_rbt t}"
  morphisms impl_of RBT
proof -
  have "RBT_Impl.Empty \<in> ?rbt" by simp
  then show ?thesis ..
qed

lemma rbt_eq_iff:
  "t1 = t2 \<longleftrightarrow> impl_of t1 = impl_of t2"
  by (simp add: impl_of_inject)

lemma rbt_eqI:
  "impl_of t1 = impl_of t2 \<Longrightarrow> t1 = t2"
  by (simp add: rbt_eq_iff)

lemma is_rbt_impl_of [simp, intro]:
  "is_rbt (impl_of t)"
  using impl_of [of t] by simp

lemma RBT_impl_of [simp, code abstype]:
  "RBT (impl_of t) = t"
  by (simp add: impl_of_inverse)

subsection {* Primitive operations *}

setup_lifting type_definition_rbt

lift_definition lookup :: "('a\<Colon>linorder, 'b) rbt \<Rightarrow> 'a \<rightharpoonup> 'b" is "rbt_lookup" 
by simp

lift_definition empty :: "('a\<Colon>linorder, 'b) rbt" is RBT_Impl.Empty 
by (simp add: empty_def)

lift_definition insert :: "'a\<Colon>linorder \<Rightarrow> 'b \<Rightarrow> ('a, 'b) rbt \<Rightarrow> ('a, 'b) rbt" is "rbt_insert" 
by simp

lift_definition delete :: "'a\<Colon>linorder \<Rightarrow> ('a, 'b) rbt \<Rightarrow> ('a, 'b) rbt" is "rbt_delete" 
by simp

lift_definition entries :: "('a\<Colon>linorder, 'b) rbt \<Rightarrow> ('a \<times> 'b) list" is RBT_Impl.entries
by simp

lift_definition keys :: "('a\<Colon>linorder, 'b) rbt \<Rightarrow> 'a list" is RBT_Impl.keys 
by simp

lift_definition bulkload :: "('a\<Colon>linorder \<times> 'b) list \<Rightarrow> ('a, 'b) rbt" is "rbt_bulkload" 
by simp

lift_definition map_entry :: "'a \<Rightarrow> ('b \<Rightarrow> 'b) \<Rightarrow> ('a\<Colon>linorder, 'b) rbt \<Rightarrow> ('a, 'b) rbt" is rbt_map_entry 
by simp

lift_definition map :: "('a \<Rightarrow> 'b \<Rightarrow> 'b) \<Rightarrow> ('a\<Colon>linorder, 'b) rbt \<Rightarrow> ('a, 'b) rbt" is RBT_Impl.map
by simp

lift_definition fold :: "('a \<Rightarrow> 'b \<Rightarrow> 'c \<Rightarrow> 'c) \<Rightarrow> ('a\<Colon>linorder, 'b) rbt \<Rightarrow> 'c \<Rightarrow> 'c"  is RBT_Impl.fold 
by simp

export_code lookup empty insert delete entries keys bulkload map_entry map fold in SML

subsection {* Derived operations *}

definition is_empty :: "('a\<Colon>linorder, 'b) rbt \<Rightarrow> bool" where
  [code]: "is_empty t = (case impl_of t of RBT_Impl.Empty \<Rightarrow> True | _ \<Rightarrow> False)"


subsection {* Abstract lookup properties *}

(* TODO: obtain the following lemmas by lifting existing theorems. *)

lemma lookup_RBT:
  "is_rbt t \<Longrightarrow> lookup (RBT t) = rbt_lookup t"
  by (simp add: lookup_def RBT_inverse)

lemma lookup_impl_of:
  "rbt_lookup (impl_of t) = lookup t"
  by (simp add: lookup_def)

lemma entries_impl_of:
  "RBT_Impl.entries (impl_of t) = entries t"
  by (simp add: entries_def)

lemma keys_impl_of:
  "RBT_Impl.keys (impl_of t) = keys t"
  by (simp add: keys_def)

lemma lookup_empty [simp]:
  "lookup empty = Map.empty"
  by (simp add: empty_def lookup_RBT fun_eq_iff)

lemma lookup_insert [simp]:
  "lookup (insert k v t) = (lookup t)(k \<mapsto> v)"
  by (simp add: insert_def lookup_RBT rbt_lookup_rbt_insert lookup_impl_of)

lemma lookup_delete [simp]:
  "lookup (delete k t) = (lookup t)(k := None)"
  by (simp add: delete_def lookup_RBT rbt_lookup_rbt_delete lookup_impl_of restrict_complement_singleton_eq)

lemma map_of_entries [simp]:
  "map_of (entries t) = lookup t"
  by (simp add: entries_def map_of_entries lookup_impl_of)

lemma entries_lookup:
  "entries t1 = entries t2 \<longleftrightarrow> lookup t1 = lookup t2"
  by (simp add: entries_def lookup_def entries_rbt_lookup)

lemma lookup_bulkload [simp]:
  "lookup (bulkload xs) = map_of xs"
  by (simp add: bulkload_def lookup_RBT rbt_lookup_rbt_bulkload)

lemma lookup_map_entry [simp]:
  "lookup (map_entry k f t) = (lookup t)(k := Option.map f (lookup t k))"
  by (simp add: map_entry_def lookup_RBT rbt_lookup_rbt_map_entry lookup_impl_of)

lemma lookup_map [simp]:
  "lookup (map f t) k = Option.map (f k) (lookup t k)"
  by (simp add: map_def lookup_RBT rbt_lookup_map lookup_impl_of)

lemma fold_fold:
  "fold f t = List.fold (prod_case f) (entries t)"
  by (simp add: fold_def fun_eq_iff RBT_Impl.fold_def entries_impl_of)

lemma impl_of_empty:
  "impl_of empty = RBT_Impl.Empty"
  by (simp add: empty_def RBT_inverse)

lemma is_empty_empty [simp]:
  "is_empty t \<longleftrightarrow> t = empty"
  by (simp add: rbt_eq_iff is_empty_def impl_of_empty split: rbt.split)

lemma RBT_lookup_empty [simp]: (*FIXME*)
  "rbt_lookup t = Map.empty \<longleftrightarrow> t = RBT_Impl.Empty"
  by (cases t) (auto simp add: fun_eq_iff)

lemma lookup_empty_empty [simp]:
  "lookup t = Map.empty \<longleftrightarrow> t = empty"
  by (cases t) (simp add: empty_def lookup_def RBT_inject RBT_inverse)

lemma sorted_keys [iff]:
  "sorted (keys t)"
  by (simp add: keys_def RBT_Impl.keys_def rbt_sorted_entries)

lemma distinct_keys [iff]:
  "distinct (keys t)"
  by (simp add: keys_def RBT_Impl.keys_def distinct_entries)


end