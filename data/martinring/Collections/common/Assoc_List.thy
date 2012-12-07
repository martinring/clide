header {* \isaheader{The type of associative lists} *}
theory Assoc_List 
  imports 
  "~~/src/HOL/Library/AList" 
  "../iterator/SetIterator" 
  "../iterator/SetIteratorOperations" 
begin

subsection {* Additional operations for associative lists *}

primrec update_with_aux :: "'val \<Rightarrow> 'key \<Rightarrow> ('val \<Rightarrow> 'val) \<Rightarrow> ('key \<times> 'val) list \<Rightarrow> ('key \<times> 'val) list"
where
  "update_with_aux v k f [] = [(k, f v)]"
| "update_with_aux v k f (p # ps) = (if (fst p = k) then (k, f (snd p)) # ps else p # update_with_aux v k f ps)"

text {*
  Do not use @{term "AList.delete"} because this traverses all the list even if it has found the key.
  We do not have to keep going because we use the invariant that keys are distinct.
*}
fun delete_aux :: "'key \<Rightarrow> ('key \<times> 'val) list \<Rightarrow> ('key \<times> 'val) list"
where
  "delete_aux k [] = []"
| "delete_aux k ((k', v) # xs) = (if k = k' then xs else (k', v) # delete_aux k xs)"

lemma map_of_update_with_aux':
  "map_of (update_with_aux v k f ps) k' = ((map_of ps)(k \<mapsto> (case map_of ps k of None \<Rightarrow> f v | Some v \<Rightarrow> f v))) k'"
by(induct ps) auto

lemma map_of_update_with_aux:
  "map_of (update_with_aux v k f ps) = (map_of ps)(k \<mapsto> (case map_of ps k of None \<Rightarrow> f v | Some v \<Rightarrow> f v))"
by(simp add: fun_eq_iff map_of_update_with_aux')

lemma dom_update_with_aux: "fst ` set (update_with_aux v k f ps) = {k} \<union> fst ` set ps"
  by (induct ps) auto

lemma distinct_update_with_aux [simp]:
  "distinct (map fst (update_with_aux v k f ps)) = distinct (map fst ps)"
by(induct ps)(auto simp add: dom_update_with_aux)

lemma set_update_with_aux:
  "distinct (map fst xs) 
  \<Longrightarrow> set (update_with_aux v k f xs) = (set xs - {k} \<times> UNIV \<union> {(k, f (case map_of xs k of None \<Rightarrow> v | Some v \<Rightarrow> v))})"
by(induct xs)(auto intro: rev_image_eqI)

lemma set_delete_aux: "distinct (map fst xs) \<Longrightarrow> set (delete_aux k xs) = set xs - {k} \<times> UNIV"
apply(induct xs)
apply simp_all
apply clarsimp
apply(fastforce intro: rev_image_eqI)
done

lemma dom_delete_aux: "distinct (map fst ps) \<Longrightarrow> fst ` set (delete_aux k ps) = fst ` set ps - {k}"
by(auto simp add: set_delete_aux)

lemma distinct_delete_aux [simp]:
  "distinct (map fst ps) \<Longrightarrow> distinct (map fst (delete_aux k ps))"
proof(induct ps)
  case Nil thus ?case by simp
next
  case (Cons a ps)
  obtain k' v where a: "a = (k', v)" by(cases a)
  show ?case
  proof(cases "k' = k")
    case True with Cons a show ?thesis by simp
  next
    case False
    with Cons a have "k' \<notin> fst ` set ps" "distinct (map fst ps)" by simp_all
    with False a have "k' \<notin> fst ` set (delete_aux k ps)"
      by(auto dest!: dom_delete_aux[where k=k])
    with Cons a show ?thesis by simp
  qed
qed

lemma map_of_delete_aux':
  "distinct (map fst xs) \<Longrightarrow> map_of (delete_aux k xs) = (map_of xs)(k := None)"
  apply (induct xs)
  apply (fastforce intro: ext simp add: map_of_eq_None_iff fun_upd_twist)
  apply (auto intro!: ext simp del: map_upd_eq_restrict )
  apply (simp add: map_of_eq_None_iff)
  done

lemma map_of_delete_aux:
  "distinct (map fst xs) \<Longrightarrow> map_of (delete_aux k xs) k' = ((map_of xs)(k := None)) k'"
by(simp add: map_of_delete_aux')

lemma delete_aux_eq_Nil_conv: "delete_aux k ts = [] \<longleftrightarrow> ts = [] \<or> (\<exists>v. ts = [(k, v)])"
by(cases ts)(auto split: split_if_asm)

subsection {* Type @{text "('a, 'b) assoc_list" } *}

typedef (open) ('k, 'v) assoc_list = "{xs :: ('k \<times> 'v) list. distinct (map fst xs)}"
morphisms impl_of Assoc_List
by(rule exI[where x="[]"]) simp

lemma assoc_list_ext: "impl_of xs = impl_of ys \<Longrightarrow> xs = ys"
by(simp add: impl_of_inject)

lemma expand_assoc_list_eq: "xs = ys \<longleftrightarrow> impl_of xs = impl_of ys"
by(simp add: impl_of_inject)

lemma impl_of_distinct [simp, intro]: "distinct (map fst (impl_of al))"
using impl_of[of al] by simp

lemma impl_of_distinct_full [simp, intro]: "distinct (impl_of al)"
using impl_of_distinct[of al] 
unfolding distinct_map by simp

lemma Assoc_List_impl_of [code abstype]: "Assoc_List (impl_of al) = al"
by(rule impl_of_inverse)

subsection {* Primitive operations *}

definition empty :: "('k, 'v) assoc_list"
where [code del]: "empty = Assoc_List []"

definition lookup :: "('k, 'v) assoc_list \<Rightarrow> 'k \<Rightarrow> 'v option"
where [code]: "lookup al = map_of (impl_of al)" 

definition update_with :: "'v \<Rightarrow> 'k \<Rightarrow> ('v \<Rightarrow> 'v) \<Rightarrow> ('k, 'v) assoc_list \<Rightarrow> ('k, 'v) assoc_list"
where [code del]: "update_with v k f al = Assoc_List (update_with_aux v k f (impl_of al))"

definition delete :: "'k \<Rightarrow> ('k, 'v) assoc_list \<Rightarrow> ('k, 'v) assoc_list"
where [code del]: "delete k al = Assoc_List (delete_aux k (impl_of al))"

definition iteratei :: "('k, 'v) assoc_list \<Rightarrow> ('s\<Rightarrow>bool) \<Rightarrow> ('k \<times> 'v \<Rightarrow> 's \<Rightarrow> 's) \<Rightarrow> 's \<Rightarrow> 's" 
where [code]: "iteratei al c f = foldli (impl_of al) c f"

lemma impl_of_empty [code abstract]: "impl_of empty = []"
by(simp add: empty_def Assoc_List_inverse)

lemma impl_of_update_with [code abstract]:
  "impl_of (update_with v k f al) = update_with_aux v k f (impl_of al)"
by(simp add: update_with_def Assoc_List_inverse)

lemma impl_of_delete [code abstract]:
  "impl_of (delete k al) = delete_aux k (impl_of al)"
by(simp add: delete_def Assoc_List_inverse)

subsection {* Abstract operation properties *}

lemma lookup_empty [simp]: "lookup empty k = None"
by(simp add: empty_def lookup_def Assoc_List_inverse)

lemma lookup_empty': "lookup empty = Map.empty"
by(rule ext) simp

lemma lookup_update_with [simp]: 
  "lookup (update_with v k f al) = (lookup al)(k \<mapsto> case lookup al k of None \<Rightarrow> f v | Some v \<Rightarrow> f v)"
by(simp add: lookup_def update_with_def Assoc_List_inverse map_of_update_with_aux)

lemma lookup_delete [simp]: "lookup (delete k al) = (lookup al)(k := None)"
by(simp add: lookup_def delete_def Assoc_List_inverse distinct_delete map_of_delete_aux')

lemma finite_dom_lookup [simp, intro!]: "finite (dom (lookup m))"
by(simp add: lookup_def finite_dom_map_of)

lemma iteratei_correct:
  "map_iterator (iteratei m) (lookup m)"
unfolding iteratei_def[abs_def] lookup_def map_to_set_def
by (simp add: set_iterator_foldli_correct)


subsection {* Derived operations *}

definition update :: "'key \<Rightarrow> 'val \<Rightarrow> ('key, 'val) assoc_list \<Rightarrow> ('key, 'val) assoc_list"
where "update k v = update_with v k (\<lambda>_. v)"

definition set :: "('key, 'val) assoc_list \<Rightarrow> ('key \<times> 'val) set"
where "set al = List.set (impl_of al)"


lemma lookup_update [simp]: "lookup (update k v al) = (lookup al)(k \<mapsto> v)"
by(simp add: update_def split: option.split)

lemma set_empty [simp]: "set empty = {}"
by(simp add: set_def empty_def Assoc_List_inverse)

lemma set_update_with:
  "set (update_with v k f al) = 
  (set al - {k} \<times> UNIV \<union> {(k, f (case lookup al k of None \<Rightarrow> v | Some v \<Rightarrow> v))})"
by(simp add: set_def update_with_def Assoc_List_inverse set_update_with_aux lookup_def)

lemma set_update: "set (update k v al) = (set al - {k} \<times> UNIV \<union> {(k, v)})"
by(simp add: update_def set_update_with)

lemma set_delete: "set (delete k al) = set al - {k} \<times> UNIV"
by(simp add: set_def delete_def Assoc_List_inverse set_delete_aux)

subsection {* Type classes *}

instantiation assoc_list :: (equal, equal) equal begin

definition "equal_class.equal (al :: ('a, 'b) assoc_list) al' == impl_of al = impl_of al'"

instance
proof
qed (simp add: equal_assoc_list_def impl_of_inject)

end

instantiation assoc_list :: (type, type) size begin

definition "size (al :: ('a, 'b) assoc_list) = length (impl_of al)"

instance ..
end

hide_const (open) impl_of empty lookup update_with set update delete iteratei 

subsection {* @{const map_ran} *}

text {* @{term map_ran} with more general type - lemmas replicated from AList in HOL/Library *}

hide_const (open) map_ran

primrec
  map_ran :: "('key \<Rightarrow> 'val \<Rightarrow> 'val') \<Rightarrow> ('key \<times> 'val) list \<Rightarrow> ('key \<times> 'val') list"
where
    "map_ran f [] = []"
  | "map_ran f (p#ps) = (fst p, f (fst p) (snd p)) # map_ran f ps"

lemma map_ran_conv: "map_of (map_ran f al) k = Option.map (f k) (map_of al k)"
  by (induct al) auto

lemma dom_map_ran: "fst ` set (map_ran f al) = fst ` set al"
  by (induct al) auto

lemma distinct_map_ran: "distinct (map fst al) \<Longrightarrow> distinct (map fst (map_ran f al))"
  by (induct al) (auto simp add: dom_map_ran)

lemma map_ran_filter: "map_ran f [(a, _)\<leftarrow>ps. fst p \<noteq> a] = [(a, _)\<leftarrow>map_ran f ps. fst p \<noteq> a]"
  by (induct ps) auto

lemma clearjunk_map_ran: "AList.clearjunk (map_ran f al) 
  = map_ran f (AList.clearjunk al)"
  by (induct al rule: clearjunk.induct) (simp_all add: delete_eq map_ran_filter)

text {* new lemmas and definitions *}

lemma map_ran_cong [fundef_cong]:
  "\<lbrakk> al = al'; \<And>k v. (k, v) \<in> set al \<Longrightarrow> f k v = g k v \<rbrakk> \<Longrightarrow> map_ran f al = map_ran g al'"
by clarify (induct al', auto)

lemma list_size_delete: "list_size f (AList.delete a al) \<le> list_size f al"
by(induct al) simp_all

lemma list_size_clearjunk: "list_size f (AList.clearjunk al) \<le> list_size f al"
by(induct al)(auto simp add: clearjunk_delete intro: le_trans[OF list_size_delete])

lemma set_delete_conv: "set (AList.delete a al) = set al - ({a} \<times> UNIV)"
proof(induct al)
  case (Cons kv al)
  thus ?case by(cases kv) auto
qed simp

lemma set_clearjunk_subset: "set (AList.clearjunk al) \<subseteq> set al"
by(induct al)(auto simp add: clearjunk_delete set_delete_conv)

lemma map_ran_conv_map:
  "map_ran f xs = map (\<lambda>(k, v). (k, f k v)) xs"
by(induct xs) auto

lemma card_dom_map_of: "distinct (map fst al) \<Longrightarrow> card (dom (map_of al)) = length al"
by(induct al)(auto simp add: card_insert_if finite_dom_map_of dom_map_of_conv_image_fst)

lemma map_of_map_inj_fst:
  assumes "inj f"
  shows "map_of (map (\<lambda>(k, v). (f k, v)) xs) (f x) = map_of xs x"
by(induct xs)(auto dest: injD[OF `inj f`])

lemma length_map_ran [simp]: "length (map_ran f xs) = length xs"
by(induct xs) simp_all

lemma length_update: 
  "length (AList.update k v xs) 
  = (if k \<in> fst ` set xs then length xs else Suc (length xs))"
by(induct xs) simp_all

lemma length_distinct: 
  "distinct (map fst xs) \<Longrightarrow> length (AList.delete k xs) 
  = (if k \<in> fst ` set xs then length xs - 1 else length xs)"
  by(induct xs)(auto split: split_if_asm simp add: in_set_conv_nth)

end
