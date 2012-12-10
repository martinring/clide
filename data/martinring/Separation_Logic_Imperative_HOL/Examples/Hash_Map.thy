header "Hash-Maps"
theory Hash_Map
  imports Hash_Table
begin

subsection {* Auxiliary Lemmas *}
lemma map_of_ls_update: 
  "map_of (fst (ls_update k v l)) = (map_of l)(k \<mapsto> v)"
  apply (induct l rule: ls_update.induct)
  by (auto simp add: ext Let_def)

lemma map_of_concat:
  "k \<in> dom (map_of(concat l)) 
  \<Longrightarrow> \<exists>i. k \<in> dom (map_of(l!i)) \<and> i < length l"
  apply (induct l)
  apply simp
  apply auto
  apply (rule_tac x = 0 in exI)
  apply auto
  by (metis Suc_mono domI nth_Cons_Suc)

lemma map_of_concat':
  "k \<in> dom (map_of(l!i)) \<and> i < length l \<Longrightarrow> k \<in> dom (map_of(concat l))"
  apply (induct l arbitrary: i)
  apply simp
  apply auto
  apply (case_tac i)
  apply auto
  done

lemma map_of_concat''':
  "\<exists>i. k \<in> dom (map_of(l!i)) \<and> i < length l 
  \<Longrightarrow> k \<in> dom (map_of(concat l))"
proof -
  case goal1
  from this obtain i where "k \<in> dom (map_of (l ! i)) \<and> i < length l" by blast
  from map_of_concat'[OF this] show ?thesis .
qed
 
lemma map_of_concat'':
  "(k \<in> dom (map_of(concat l))) 
  \<longleftrightarrow> (\<exists>i. k \<in> dom (map_of(l!i)) \<and> i < length l)"
  apply rule
  using map_of_concat[of k l]
  apply simp
  using map_of_concat'[of k l]
  by blast

lemma abs_update_length: "length (abs_update k v l) = length l"
  by (simp add: abs_update_def)

lemma ls_update_map_of_eq:
  "map_of (fst (ls_update k v ls)) k = Some v"
  apply (induct ls rule: ls_update.induct)
  by (simp_all add: Let_def)

lemma ls_update_map_of_neq:
  "x \<noteq> k \<Longrightarrow> map_of (fst (ls_update k v ls)) x = map_of ls x"
  apply (induct ls rule: ls_update.induct)
  by (auto simp add: Let_def)

subsection {* Main Definitions and Lemmas *}

definition is_hashmap' 
  :: "('k, 'v) map 
    \<Rightarrow> ('k \<times> 'v) list list 
    \<Rightarrow> ('k\<Colon>{heap,hashable}, 'v\<Colon>heap) hashtable
    \<Rightarrow> assn" 
  where
  "is_hashmap' m l ht = is_hashtable l ht * \<up> (map_of (concat l) = m)"


definition is_hashmap 
  :: "('k, 'v) map \<Rightarrow> ('k\<Colon>{heap,hashable}, 'v\<Colon>heap) hashtable \<Rightarrow> assn" 
  where
  "is_hashmap m ht = (\<exists>\<^sub>Al. is_hashmap' m l ht)"

lemma is_hashmap'_prec:
  "\<forall>s s'. h\<Turnstile>(is_hashmap' m l ht * F1) \<and>\<^sub>A (is_hashmap' m' l' ht * F2)
  \<longrightarrow> l=l' \<and> m=m'"
  unfolding is_hashmap'_def
  apply (auto simp add: is_hashtable_prec)
  apply (subgoal_tac "l = l'")
  by (auto simp add: is_hashtable_prec)

lemma is_hashmap_prec:
  "\<forall>m m'. h\<Turnstile>(is_hashmap m ht * F1) \<and>\<^sub>A (is_hashmap m' ht * F2) \<longrightarrow> m=m'"
  unfolding is_hashmap_def
  by (auto simp add: is_hashmap'_prec)

abbreviation "hm_new \<equiv> ht_new"
lemma hm_new_rule': 
  "<emp> 
  hm_new::('k\<Colon>{heap,hashable}, 'v\<Colon>heap) hashtable Heap 
  <is_hashmap' Map.empty (replicate (def_hashmap_size TYPE('k)) [])>"
  apply (rule cons_post_rule)
  using complete_ht_new
  apply simp
  apply (simp add: is_hashmap'_def)
  done 

lemma hm_new_rule: 
  "<emp> hm_new <is_hashmap Map.empty>"
  apply (rule cons_post_rule)
  using complete_ht_new
  apply simp
  apply (simp add: is_hashmap_def is_hashmap'_def)
  apply sep_auto
  done

lemma ht_hash_distinct:
  "ht_hash l 
  \<Longrightarrow> \<forall>i j . i\<noteq>j \<and> i < length l \<and> j < length l 
    \<longrightarrow> set (l!i) \<inter> set (l!j) = {}"
  apply (auto simp add: ht_hash_def)
  apply metis
  done

lemma ht_hash_in_dom_in_dom_bounded_hashcode:
  assumes "ht_hash l"
  assumes "k \<in> dom (map_of(concat l))"
  shows "k \<in> dom (map_of(l!bounded_hashcode (length l) k))"
proof -
  from map_of_concat[OF assms(2)] obtain i 
    where i: "k \<in> dom (map_of (l ! i)) \<and> i < length l" 
    by blast
  thm ht_hash_def
  hence "\<exists>v. (k,v)\<in>set(l!i)" by (auto dest: map_of_SomeD)
  from this obtain v where v: "(k,v)\<in>set(l!i)" by blast
  from assms(1)[unfolded ht_hash_def] i v bounded_hashcode_bounds 
  have "bounded_hashcode (length l) k = i"
    by (metis fst_conv)
  with i show ?thesis by simp
qed

lemma ht_hash_in_dom_bounded_hashcode_in_dom:
  assumes "ht_hash l"
  assumes "1 < length l"
  assumes "k \<in> dom (map_of(l!bounded_hashcode (length l) k))"
  shows "k \<in> dom (map_of(concat l))"
  using map_of_concat'[of k l "bounded_hashcode (length l) k"] 
    assms(2,3) bounded_hashcode_bounds[of "length l" k]
  by simp


lemma ht_hash_in_dom_in_dom_bounded_hashcode_eq:
  assumes "ht_hash l"
  assumes "1 < length l"
  shows "(k \<in> dom (map_of(concat l))) 
  = (k \<in> dom (map_of(l!bounded_hashcode (length l) k)))"
  apply rule
  using ht_hash_in_dom_in_dom_bounded_hashcode[OF assms(1)] 
    ht_hash_in_dom_bounded_hashcode_in_dom[OF assms]
  by simp_all


lemma ht_hash_in_dom_i_bounded_hashcode_i:
  assumes "ht_hash l"
  assumes "1 < length l"
  assumes "i < length l"
  assumes "k \<in> dom (map_of (l!i))" 
  shows "i = bounded_hashcode (length l) k"
  using assms
  using bounded_hashcode_bounds
  by (auto simp add: ht_hash_def ht_distinct_def dom_map_of_conv_image_fst)

lemma ht_hash_in_bounded_hashcode_not_i_not_in_dom_i:
  assumes "ht_hash l"
  assumes "1 < length l"
  assumes "i < length l"
  assumes "i \<noteq> bounded_hashcode (length l) k"
  shows "k \<notin> dom (map_of (l!i))" 
  using assms
  using bounded_hashcode_bounds
  by (auto simp add: ht_hash_def ht_distinct_def dom_map_of_conv_image_fst)

lemma ht_hash_ht_distinct_in_dom_unique_value:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  assumes "k \<in> dom (map_of (concat l))"
  shows "\<exists>!v. (k,v) \<in> set (concat l)"
proof -
  from assms(4) have ex: "\<exists>v. (k,v) \<in> set (concat l)"  
    by (auto dest!: map_of_SomeD)
  have "\<forall>v w. (k,v) \<in> set (concat l) \<and> (k,w) \<in> set (concat l) 
    \<longrightarrow> v = w"
  proof (intro allI impI, elim conjE)
    case goal1
    from ht_hash_in_dom_in_dom_bounded_hashcode[OF assms(1,4)] 
    have a: "k \<in> dom (map_of (l ! bounded_hashcode (length l) k))" .
    have "\<forall>i. i < length l \<and> i \<noteq> bounded_hashcode (length l) k 
      \<longrightarrow> k \<notin> dom(map_of(l!i))"
    proof (intro allI impI, elim conjE)
      case goal1
      from ht_hash_in_bounded_hashcode_not_i_not_in_dom_i[
        OF assms(1,3) goal1]
      show ?case .
    qed
    from goal1(1) a 
    have v: "(k,v) \<in> set (l ! bounded_hashcode (length l) k)"
    proof -
      case goal1
      from goal1(1) have "\<exists>i. i < length l \<and> (k, v) \<in> set (l!i)" 
        by auto (metis in_set_conv_nth)
      from this obtain i where i: "i < length l \<and> (k, v) \<in> set (l!i)"
        by blast
      hence "k \<in> dom (map_of (l!i))"
        by (metis (no_types) PairE a assms(1) fst_conv ht_hash_def) 
      from i ht_hash_in_dom_i_bounded_hashcode_i[OF assms(1,3) _ this] 
      have "i = bounded_hashcode (length l) k" by simp
      with i show ?case by simp
    qed
    from goal1(2) a 
    have w: "(k,w) \<in> set (l ! bounded_hashcode (length l) k)"
    proof -
      case goal1
      from goal1(1) have "\<exists>i. i < length l \<and> (k, w) \<in> set (l!i)" 
        by auto (metis in_set_conv_nth)
      from this obtain i where i: "i < length l \<and> (k, w) \<in> set (l!i)"
        by blast
      hence "k \<in> dom (map_of (l!i))"
        by (metis (no_types) PairE a assms(1) fst_conv ht_hash_def) 
      from i ht_hash_in_dom_i_bounded_hashcode_i[OF assms(1,3) _ this] 
      have "i = bounded_hashcode (length l) k" by simp
      with i show ?case by simp
    qed
    from assms(2,3) have 
      "distinct (map fst (l ! bounded_hashcode (length l) k))"
      by (simp add: ht_distinct_def bounded_hashcode_bounds)
    from Map.map_of_is_SomeI[OF this v] Map.map_of_is_SomeI[OF this w]
    show "v = w" by simp
  qed    
  with ex show ?thesis by blast
qed


lemma ht_hash_ht_distinct_map_of:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  shows "map_of (concat l) k 
  = map_of(l!bounded_hashcode (length l) k) k"
proof (cases "k \<in> dom (map_of(concat l))")
  case False
  hence a: "map_of (concat l) k = None" by auto
  from ht_hash_in_dom_in_dom_bounded_hashcode_eq[OF assms(1,3)] False 
  have "k \<notin> dom (map_of (l ! bounded_hashcode (length l) k))" by simp
  hence "map_of(l!bounded_hashcode (length l) k) k = None" by auto
  with a show ?thesis by simp
next
  case True
  from True obtain y where y: "map_of (concat l) k = Some y" by auto
  hence a: "(k,y) \<in> set (concat l)" by (metis map_of_SomeD)
  from ht_hash_in_dom_in_dom_bounded_hashcode_eq[OF assms(1,3)] True 
  have "k \<in> dom (map_of (l ! bounded_hashcode (length l) k))" by simp
  from this obtain z where 
    z: "map_of(l!bounded_hashcode (length l) k) k = Some z" by auto
  hence "(k,z) \<in> set (l ! bounded_hashcode (length l) k)"
    by (metis map_of_SomeD) 
  with bounded_hashcode_bounds[OF assms(3), of k] 
  have b: "(k,z) \<in> set (concat l)" by auto
  from ht_hash_ht_distinct_in_dom_unique_value[OF assms True] a b 
  have "y = z" by auto
  with y z show ?thesis by simp
qed

lemma ls_lookup_map_of_pre:
  "distinct (map fst l) \<Longrightarrow> ls_lookup k l = map_of l k"
  apply (induct l)
  apply simp
  apply (case_tac a)
  by simp

lemma ls_lookup_map_of:
  assumes "ht_hash l"
  assumes "ht_distinct l" 
  assumes "1 < length l" 
  shows "ls_lookup k (l ! bounded_hashcode (length l) k) 
  = map_of (concat l) k"  
proof -
  from assms(2,3) 
  have "distinct (map fst (l ! bounded_hashcode (length l) k))" 
    by (simp add: ht_distinct_def bounded_hashcode_bounds)
  from ls_lookup_map_of_pre[OF this] 
  have "ls_lookup k (l ! bounded_hashcode (length l) k) 
    = map_of (l ! bounded_hashcode (length l) k) k" .
  also from ht_hash_ht_distinct_map_of[OF assms] 
  have "map_of (l ! bounded_hashcode (length l) k) k 
    = map_of (concat l) k"
    by simp
  finally show ?thesis .
qed

abbreviation "hm_lookup \<equiv> ht_lookup"
lemma hm_lookup_rule':
  "<is_hashmap' m l ht> hm_lookup k ht 
    <\<lambda>r. is_hashmap' m l ht * 
      \<up>(r = m k)>"
  unfolding is_hashmap'_def
  apply sep_auto
  apply (rule cons_post_rule)
  using complete_ht_lookup[of l ht k]
  apply simp
  apply sep_auto
  by (simp add: ls_lookup_map_of is_hashtable_def)

lemma hm_lookup_rule:
  "<is_hashmap m ht> hm_lookup k ht 
    <\<lambda>r. is_hashmap m ht * 
      \<up>(r = m k)>"
  unfolding is_hashmap_def
  apply sep_auto
  apply (rule cons_post_rule[OF hm_lookup_rule'])
  by sep_auto

lemma abs_update_map_of'':
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  shows "map_of (concat (abs_update k v l)) k = Some v"
proof -
  from ht_hash_ht_distinct_map_of[
    OF ht_hash_update[OF assms(1)] 
       ht_distinct_update[OF assms(2)] 
       length_update[OF assms(3)], 
    of k v k]
  have "map_of (concat (abs_update k v l)) k 
    = map_of ((abs_update k v l) ! bounded_hashcode (length l) k) k"
    by (simp add: abs_update_length)
  also have 
    "\<dots> = map_of (fst (ls_update k v 
                        (l ! bounded_hashcode (length l) k))) k"
    by (simp add: abs_update_def bounded_hashcode_bounds[OF assms(3)])
  also have "... = Some v" by (simp add: ls_update_map_of_eq)
  finally show ?thesis .
qed

lemma abs_update_map_of_hceq:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  assumes "x \<noteq> k"
  assumes "bounded_hashcode (length l) x 
    = bounded_hashcode (length l) k"
  shows "map_of (concat (abs_update k v l)) x = map_of (concat l) x"
proof -
  from ht_hash_ht_distinct_map_of[
    OF ht_hash_update[OF assms(1)] 
       ht_distinct_update[OF assms(2)] 
       length_update[OF assms(3)], 
    of k v x]
  have "map_of (concat (abs_update k v l)) x 
    = map_of ((abs_update k v l) ! bounded_hashcode (length l) x) x"
    by (simp add: abs_update_length)
  also from assms(5) have 
    "\<dots> = map_of (fst (ls_update k v 
                        (l ! bounded_hashcode (length l) k))) x"
    by (simp add: abs_update_def bounded_hashcode_bounds[OF assms(3)])
  also have 
    "\<dots> = map_of (l ! bounded_hashcode (length l) x) x" 
    by (simp add: ls_update_map_of_neq[OF assms(4)] assms(5))
  also from ht_hash_ht_distinct_map_of[OF assms(1-3)] have 
    "\<dots> = map_of (concat l) x"
    by simp
  finally show ?thesis .
qed

lemma abs_update_map_of_hcneq:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  assumes "x \<noteq> k"
  assumes "bounded_hashcode (length l) x 
    \<noteq> bounded_hashcode (length l) k"
  shows "map_of (concat (abs_update k v l)) x = map_of (concat l) x"
proof -
  from ht_hash_ht_distinct_map_of[
    OF ht_hash_update[OF assms(1)] 
        ht_distinct_update[OF assms(2)] 
        length_update[OF assms(3)], 
    of k v x]
  have "map_of (concat (abs_update k v l)) x 
    = map_of ((abs_update k v l) ! bounded_hashcode (length l) x) x"
    by (simp add: abs_update_length)
  also from assms(5) 
  have "\<dots> = map_of (l ! bounded_hashcode (length l) x) x"
    by (simp add: abs_update_def bounded_hashcode_bounds[OF assms(3)])
  also from ht_hash_ht_distinct_map_of[OF assms(1-3)] 
  have "\<dots> = map_of (concat l) x"
    by simp
  finally show ?thesis .
qed  
 

lemma abs_update_map_of''':
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  assumes "x \<noteq> k"
  shows "map_of (concat (abs_update k v l)) x = map_of (concat l) x"
  apply (cases 
    "bounded_hashcode (length l) x = bounded_hashcode (length l) k")
  by (auto simp add: abs_update_map_of_hceq[OF assms] 
    abs_update_map_of_hcneq[OF assms])

lemma abs_update_map_of':  
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  shows "map_of (concat (abs_update k v l)) x 
    = (map_of (concat l)(k \<mapsto> v)) x"
  apply (cases "x = k")
  apply (simp add: abs_update_map_of''[OF assms])
  by (simp add: abs_update_map_of'''[OF assms])

lemma abs_update_map_of:  
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  shows "map_of (concat (abs_update k v l)) 
    = map_of (concat l)(k \<mapsto> v) "
  apply (rule ext)
  by (simp add: abs_update_map_of'[OF assms])


lemma ls_insls_map_of:
  assumes "ht_hash ld"
  assumes "ht_distinct ld"
  assumes "1 < length ld"
  assumes "distinct (map fst xs)"
  shows "map_of (concat (ls_insls xs ld)) 
    = map_of (concat ld) ++ map_of xs"
  using assms
  apply (induct xs arbitrary: ld)
  apply simp
  apply (case_tac a)
  apply (simp only: ls_insls.simps)
proof -
  case goal1
  from goal1(5) goal1(1)[OF ht_hash_update[OF goal1(2)] 
    ht_distinct_update[OF goal1(3)] 
    length_update[OF goal1(4)]] 
    abs_update_map_of[OF goal1(2-4)] 
  show ?case
    apply simp
    apply (rule map_add_upd2)
    by (metis dom_map_of_conv_image_fst)
qed

lemma ls_insls_map_of':
  assumes "ht_hash ls"
  assumes "ht_distinct ls"
  assumes "ht_hash ld"
  assumes "ht_distinct ld"
  assumes "1 < length ld"
  assumes "n < length ls"
  shows "map_of (concat (ls_insls (ls ! n) ld)) 
      ++ map_of (concat (take n ls))
    = map_of (concat ld) ++ map_of (concat (take (Suc n) ls))"
proof -
  from assms(2,6) have "distinct (map fst (ls ! n))" 
    by (simp add: ht_distinct_def)
  from ls_insls_map_of[OF assms(3-5) this] assms(6) show ?thesis
    by (simp add: List.take_Suc_conv_app_nth)
qed

lemma ls_copy_map_of:
  assumes "ht_hash ls"
  assumes "ht_distinct ls"
  assumes "ht_hash ld"
  assumes "ht_distinct ld"
  assumes "1 < length ld"
  assumes "n \<le> length ls"
  shows "map_of (concat (ls_copy n ls ld)) 
  = map_of (concat ld) ++ map_of (concat (take n ls))"
  using assms
  apply (induct n arbitrary: ld)
  apply simp
proof -
  case goal1
  thm ht_hash_ls_insls[OF goal1(4)]
  note a = ht_hash_ls_insls[OF goal1(4), of "ls ! n"]
  note b = ht_distinct_ls_insls[OF goal1(5), of "ls ! n"]
  note c = length_ls_insls[OF goal1(6), of "ls ! n"]
  from goal1 have "n < length ls" by simp
  with 
    ls_insls_map_of'[OF goal1(2-6) this] 
    goal1(1)[OF assms(1,2) a b c]
  show ?case by simp
qed


lemma ls_rehash_map_of:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  shows "map_of (concat (ls_rehash l)) = map_of (concat l)"
  using assms(3) ls_copy_map_of[OF assms(1,2) 
    ht_hash_replicate ht_distinct_replicate]
  by (simp add: ls_rehash_def)


lemma abs_update_rehash_map_of:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "1 < length l"
  shows "map_of (concat (abs_update k v (ls_rehash l))) 
  = map_of (concat l)(k \<mapsto> v)"
proof -
  note a = ht_hash_ls_rehash[of l]
  note b = ht_distinct_ls_rehash[of l]
  note c = length_ls_rehash[OF assms(3)]
  from abs_update_map_of[OF a b c] ls_rehash_map_of[OF assms] 
  show ?thesis by simp
qed

abbreviation "hm_update \<equiv> ht_update"
lemma hm_update_rule':
  "<is_hashmap' m l ht> 
    hm_update k v ht 
  <\<lambda>r. is_hashmap (m(k \<mapsto> v)) r * true>"
proof (cases "length l * load_factor \<le> the_size ht * 100")
  case True
  show ?thesis
    unfolding is_hashmap'_def
    apply sep_auto    
    apply (rule cons_post_rule[OF complete_ht_update_rehash[OF True]])
    unfolding is_hashmap_def is_hashmap'_def
    apply sep_auto
    apply (simp add: abs_update_rehash_map_of is_hashtable_def)
    done
next
  case False
  show ?thesis    
    unfolding is_hashmap'_def is_hashtable_def
    apply sep_auto
    apply (rule cons_post_rule)
    using complete_ht_update_normal[OF False, simplified is_hashtable_def, 
      simplified, of k v]
    apply auto
    unfolding is_hashmap_def is_hashmap'_def
    apply sep_auto
    by (simp add: abs_update_map_of is_hashtable_def)
qed

lemma hm_update_rule:
  "<is_hashmap m ht> 
    hm_update k v ht 
  <\<lambda>r. is_hashmap (m(k \<mapsto> v)) r * true>"
  unfolding is_hashmap_def[of m]
  by (sep_auto heap add: hm_update_rule')

lemma ls_delete_map_of:
  assumes "distinct (map fst l)"
  shows "map_of (fst (ls_delete k l)) x = ((map_of l) |` (- {k})) x"
  using assms
  apply (induct l rule: ls_delete.induct)
  apply simp
  apply (auto simp add: map_of_eq_None_iff Let_def)
  by (metis ComplD ComplI Compl_insert Option.set.simps(2) 
    insertE insertI2 map_upd_eq_restrict restrict_map_def)

lemma update_ls_delete_map_of: 
  assumes "ht_hash l"
  assumes "ht_distinct l"
  assumes "ht_hash (l[bounded_hashcode (length l) k 
  := fst (ls_delete k (l ! bounded_hashcode (length l) k))])"
  assumes "ht_distinct (l[bounded_hashcode (length l) k 
  := fst (ls_delete k (l ! bounded_hashcode (length l) k))])"
  assumes "1 < length l"
  shows "map_of (concat (l[bounded_hashcode (length l) k 
    := fst (ls_delete k (l ! bounded_hashcode (length l) k))])) x
  = ((map_of (concat l)) |` (- {k})) x"
proof -
  from assms(2) bounded_hashcode_bounds[OF assms(5)] have 
    distinct: "distinct (map fst (l ! bounded_hashcode (length l) k))"
    by (auto simp add: ht_distinct_def)
  note id1 = ht_hash_ht_distinct_map_of[OF assms(3,4), simplified, 
    OF assms(5)[simplified], of x]
  note id2 = ht_hash_ht_distinct_map_of[OF assms(1,2,5), of x]
  show ?thesis
  proof (cases 
      "bounded_hashcode (length l) x = bounded_hashcode (length l) k")
    case True
    with id1
    have "map_of (concat (l[bounded_hashcode (length l) k 
      := fst (ls_delete k (l ! bounded_hashcode (length l) k))])) x 
      =
      map_of (l[bounded_hashcode (length l) k 
        := fst (ls_delete k (l ! bounded_hashcode (length l) k))] 
      ! bounded_hashcode (length l) k) x"
      by simp
    also have 
      "\<dots> = map_of (fst (ls_delete k 
                          (l ! bounded_hashcode (length l) k))) x"
      by (simp add: bounded_hashcode_bounds[OF assms(5)])
    also from ls_delete_map_of[OF distinct] have 
      "\<dots> = (map_of (l ! bounded_hashcode (length l) k) |` (- {k})) x"
      by simp
    finally show ?thesis
      by (cases "x = k") (simp_all add: id2 True)
  next
    case False
    with bounded_hashcode_bounds[OF assms(5)] id1 id2[symmetric] 
    show ?thesis
      by (cases "x = k") simp_all
  qed
qed

abbreviation "hm_delete \<equiv> ht_delete"
lemma hm_delete_rule': 
  "<is_hashmap' m l ht> hm_delete k ht <is_hashmap (m |` (-{k}))>"
  unfolding is_hashmap'_def[of m] is_hashtable_def
  apply sep_auto
  apply (rule cons_post_rule)
  using complete_ht_delete[unfolded is_hashtable_def]
  apply sep_auto
  apply (simp add: is_hashmap_def is_hashmap'_def)
  apply (sep_auto)
  apply (simp add: is_hashtable_def)
  apply (sep_auto)
  by (auto simp add: update_ls_delete_map_of)

lemma hm_delete_rule: 
  "<is_hashmap m ht> hm_delete k ht <is_hashmap (m |` (-{k}))>"
  unfolding is_hashmap_def[of m]
  by (sep_auto heap add: hm_delete_rule')

definition hm_isEmpty :: "('k, 'v) hashtable \<Rightarrow> bool Heap" where
  "hm_isEmpty ht \<equiv> return (the_size ht = 0)"

lemma hm_isEmpty_rule': 
  "<is_hashmap' m l ht> 
  hm_isEmpty ht 
  <\<lambda>r. is_hashmap' m l ht * \<up>(r \<longleftrightarrow> m=Map.empty)>"
  unfolding hm_isEmpty_def
  unfolding is_hashmap_def is_hashmap'_def is_hashtable_def ht_size_def
  apply (cases ht, simp)
  apply sep_auto
  done

lemma hm_isEmpty_rule: 
  "<is_hashmap m ht> hm_isEmpty ht <\<lambda>r. is_hashmap m ht * \<up>(r \<longleftrightarrow> m=Map.empty)>"
  unfolding is_hashmap_def
  apply (sep_auto heap: hm_isEmpty_rule')
  done

definition hm_size :: "('k, 'v) hashtable \<Rightarrow> nat Heap" where
  "hm_size ht \<equiv> return (the_size ht)"

lemma length_card_dom_map_of:
  assumes "distinct (map fst l)"
  shows "length l = card (dom (map_of l))"
  using assms
  apply (induct l)
  apply simp
  apply simp
  apply (case_tac a)
  apply (auto intro!: fst_conv map_of_SomeD)
  apply (subgoal_tac "aa \<notin> dom (map_of l)")
  apply simp
  by (metis dom_map_of_conv_image_fst)

lemma ht_hash_dom_map_of_disj:
  assumes "ht_hash l"
  assumes "i < length l"
  assumes "j < length l"
  assumes "i \<noteq> j"
  shows "dom (map_of (l!i)) \<inter> dom (map_of(l!j)) = {}"
  using assms
  unfolding ht_hash_def
  apply auto
  by (metis fst_conv map_of_SomeD)


lemma ht_hash_dom_map_of_disj_drop:
  assumes "ht_hash l"
  assumes "i < length l"
  shows "dom (map_of (l!i)) \<inter> dom (map_of (concat (drop (Suc i) l)))
    = {}"
  apply auto
proof -
  case goal1
  from goal1(2) have "x \<in> dom (map_of (concat (drop (Suc i) l)))"
    by auto
  hence "\<exists>j. j < length (drop (Suc i) l) 
    \<and> x \<in> dom (map_of ((drop (Suc i) l)!j))"
    by (metis Hash_Map.map_of_concat 
      `x \<in> dom (map_of (concat (drop (Suc i) l)))` length_drop)
  from this obtain j where 
    j: "j < length (drop (Suc i) l) 
      \<and> x \<in> dom (map_of ((drop (Suc i) l)!j))" 
    by blast
  hence length: "(Suc i + j) < length l" by auto
  from j have neq: "i \<noteq> (Suc i + j)" by simp
  from j have in_dom: "x \<in> dom (map_of (l!(Suc i + j)))" by auto
  from goal1(1) have in_dom2: "x \<in> dom (map_of (l ! i))" by auto
  from ht_hash_dom_map_of_disj[OF assms length neq] in_dom in_dom2
  show ?case by auto
qed

lemma listsum_length_card_dom_map_of_concat:
  assumes "ht_hash l"
  assumes "ht_distinct l"
  shows "listsum (map length l) = card (dom (map_of (concat l)))"
  using assms
proof -
  from ht_hash_dom_map_of_disj_drop[OF assms(1)]
  have "\<forall>i. i < length l 
    \<longrightarrow> dom (map_of (l ! i)) \<inter> dom (map_of (concat (drop (Suc i) l)))
        = {}" 
    by auto
  with assms(2) show ?thesis
  proof (induct l)
    case Nil
    thus ?case by simp
  next
    case (Cons l ls)
    from Cons(2) have a: "ht_distinct ls" by (auto simp add: ht_distinct_def)
    from Cons(3) have b: "\<forall>i < length ls. dom (map_of (ls ! i)) 
      \<inter> dom (map_of (concat (drop (Suc i) ls))) = {}" 
      apply simp
      apply (rule allI)
      apply (rule_tac x="Suc i" and P="(\<lambda>i. i<Suc (length ls) \<longrightarrow>
             dom (map_of ((l # ls) ! i)) \<inter> dom (map_of (concat (drop i ls))) =
             {})" in allE)
      by simp_all
    from Cons(2) have "distinct (map fst l)" by (auto simp add: ht_distinct_def)
    note l = length_card_dom_map_of[OF this]
    from Cons(3) have c: "dom (map_of l) \<inter> dom (map_of (concat ls)) = {}"
      apply (rule_tac x="0" and P="(\<lambda>i. i<Suc (length ls) \<longrightarrow>
             dom (map_of ((l # ls) ! i)) 
               \<inter> dom (map_of (concat (drop i ls))) 
             = {})" in allE)
      by simp_all
    from Cons(1)[OF a b] l c show ?case by (simp add: card_Un_disjoint)
  qed
qed


lemma hm_size_rule': 
  "<is_hashmap' m l ht> 
  hm_size ht 
  <\<lambda>r. is_hashmap' m l ht * \<up>(r = card (dom m))>"
  unfolding hm_size_def is_hashmap_def is_hashmap'_def is_hashtable_def
  apply sep_auto
  apply (cases ht)
  apply (simp add: ht_size_def)
  apply sep_auto
  by (simp add: listsum_length_card_dom_map_of_concat)

lemma hm_size_rule: 
  "<is_hashmap m ht> 
    hm_size ht 
  <\<lambda>r. is_hashmap m ht * \<up>(r = card (dom m))>"
  unfolding is_hashmap_def
  by (sep_auto heap: hm_size_rule')

subsection {* Iterators *}

subsubsection {* Definitions *}
type_synonym ('k,'v) hm_it = "(nat \<times> ('k\<times>'v) list \<times> ('k,'v) hashtable)"

fun hm_it_adjust 
  :: "nat \<Rightarrow> ('k::{heap,hashable},'v::heap) hashtable \<Rightarrow> nat Heap"
  where
  "hm_it_adjust 0 ht = return 0"
| "hm_it_adjust n ht = do {
    l \<leftarrow> Array.nth (the_array ht) n;
    case l of 
      [] \<Rightarrow> hm_it_adjust (n - 1) ht
    | _ \<Rightarrow>  return n
  }"

definition hm_it_init 
  :: "('k::{heap,hashable},'v::heap) hashtable \<Rightarrow> ('k,'v) hm_it Heap"
  where 
  "hm_it_init ht \<equiv> do {
  n\<leftarrow>Array.len (the_array ht);
  if n = 0 then return (0,[],ht)
  else do {
    i\<leftarrow>hm_it_adjust (n - 1) ht;
    l\<leftarrow>Array.nth (the_array ht) i;
    return (i,l,ht)
  }
}"

definition hm_it_has_next 
  :: "('k::{heap,hashable},'v::heap) hm_it \<Rightarrow> bool Heap"
  where "hm_it_has_next it 
  \<equiv> return (case it of (0,[],_) \<Rightarrow> False | _ \<Rightarrow> True)"

definition hm_it_next :: 
  "('k::{heap,hashable},'v::heap) hm_it 
    \<Rightarrow> (('k\<times>'v)\<times>('k,'v) hm_it) Heap"
  where "hm_it_next it \<equiv> case it of 
    (i,a#b#l,ht) \<Rightarrow> return (a,(i,b#l,ht))
  | (0,[a],ht) \<Rightarrow> return (a,(0,[],ht))
  | (Suc i,[a],ht) \<Rightarrow> do {
    i \<leftarrow> hm_it_adjust i ht;
    l \<leftarrow> Array.nth (the_array ht) i;
    return (a,(i,rev l,ht))
  }
  "

definition "hm_is_it' l ht l' it \<equiv>  
  is_hashtable l ht * 
  \<up>(let (i,r,ht')=it in 
       ht = ht' 
     \<and> l' = (concat (take i l) @ rev r)
     \<and> distinct (map fst (l'))
     \<and> i \<le> length l \<and> (r=[] \<longrightarrow> i=0)
   )"

definition "hm_is_it m ht m' it \<equiv> \<exists>\<^sub>Al l'. 
  hm_is_it' l ht l' it 
  * \<up>(map_of (concat l) = m \<and> map_of l' = m') 
  "

subsubsection {* Auxiliary Lemmas *}
lemma concat_take_Suc_empty: "\<lbrakk> n < length l; l!n=[] \<rbrakk> 
  \<Longrightarrow> concat (take (Suc n) l) = concat (take n l)"
  apply (induct n arbitrary: l)
  apply (case_tac l)
  apply auto [2]
  apply (case_tac l)
  apply auto [2]
  done

lemma nth_concat_splitE:
  assumes "i<length (concat ls)"
  obtains j k where
  "j < length ls" 
  and "k < length (ls!j)" 
  and "concat ls ! i = ls!j!k"
  and "i = length (concat (take j ls)) + k"
  using assms
proof (induct ls arbitrary: i thesis)
  case Nil thus ?case by auto
next
  case (Cons l ls)
  show ?case proof (cases)
    assume L: "i < length l"
    hence "concat (l#ls) ! i = (l#ls)!0!i" by (auto simp: nth_append)
    thus ?thesis 
      apply (rule_tac Cons.prems(1)[of 0 i])
      apply (simp_all add: L)
      done
  next
    assume L: "\<not>(i < length l)"
    hence 1: "concat (l#ls)!i = concat ls ! (i - length l)"
      by (auto simp: nth_append)
    obtain j k where
      "j < length ls" and "k < length (ls!j)" 
      and "concat ls ! (i - length l) = ls!j!k"
      and "i - length l = length (concat (take j ls)) + k"
      apply (rule Cons.hyps[of "i - length l"])
      using Cons.prems L
      by auto
    thus ?case using L 
      apply (rule_tac Cons.prems(1)[of "Suc j" k])
      apply (auto simp: nth_append)
      done
  qed
qed

lemma is_hashmap'_distinct: 
  "is_hashtable l ht 
    \<Longrightarrow>\<^sub>A is_hashtable l ht * \<up>(distinct (map fst (concat l)))"
  apply (simp add: distinct_conv_nth)
proof (intro allI impI, elim exE)
  fix i j a b
  assume 1: "i < length (concat l)"
  assume 2: "j < length (concat l)"
  assume 3: "i\<noteq>j"
  
  assume HM: "(a,b) \<Turnstile> is_hashtable l ht"

  from 1 obtain ji ki where
    IFMT: "i = length (concat (take ji l)) + ki" 
    and JI_LEN: "ji < length l"
    and KI_LEN: "ki < length (l!ji)"
    and [simp]: "concat l ! i = l!ji!ki"
    by (blast elim: nth_concat_splitE)

  from 2 obtain jj kj where
    JFMT: "j = length (concat (take jj l)) + kj" 
    and JJ_LEN: "jj < length l"
    and KJ_LEN: "kj < length (l!jj)"
    and [simp]: "concat l ! j = l!jj!kj"
    by (blast elim: nth_concat_splitE)

  show "fst (concat l ! i) \<noteq> fst (concat l ! j)"
  proof cases
    assume [simp]: "ji=jj"
    with IFMT JFMT `i\<noteq>j` have "ki\<noteq>kj" by auto
    moreover from HM JJ_LEN have "distinct (map fst (l!jj))"
      unfolding is_hashmap'_def is_hashtable_def ht_distinct_def
      by auto
    ultimately show ?thesis using KI_LEN KJ_LEN
      by (simp add: distinct_conv_nth)
  next
    assume NE: "ji\<noteq>jj"
    from HM have 
      "\<forall>x\<in>set (l!ji). bounded_hashcode (length l) (fst x) = ji"
      "\<forall>x\<in>set (l!jj). bounded_hashcode (length l) (fst x) = jj"
      unfolding is_hashmap'_def is_hashtable_def ht_hash_def
      using JI_LEN JJ_LEN
      by auto
    with KI_LEN KJ_LEN NE show ?thesis 
      apply (auto) by (metis nth_mem)
  qed
qed

lemma take_set: "set (take n l) = { l!i | i. i<n \<and> i<length l }"
  apply (auto simp add: set_conv_nth)
  apply (rule_tac x=i in exI)
  apply auto
  done

lemma skip_empty_aux:
  assumes A: "concat (take (Suc n) l) = concat (take (Suc x) l)"
  assumes L[simp]: "Suc n \<le> length l" "x \<le> n"
  shows "\<forall>i. x<i \<and> i\<le>n \<longrightarrow> l!i=[]"
proof -
  have "take (Suc n) l = take (Suc x + (n - x)) l"
    by simp
  also have "\<dots> = take (Suc x) l @ take (n - x) (drop (Suc x) l)"
    by (simp only: take_add)
  finally   have 
    "concat (take (Suc x) l) = 
      concat (take (Suc x) l) @ concat (take (n - x) (drop (Suc x) l))"
    using A by simp
  hence 1: "\<forall>l\<in>set (take (n - x) (drop (Suc x) l)). l=[]" by simp
  show ?thesis
  proof safe
    fix i
    assume "x<i" and "i\<le>n"
    hence "l!i \<in> set (take (n - x) (drop (Suc x) l))"
      using L[simp del]
      apply (auto simp: take_set)
      apply (rule_tac x="i - Suc x" in exI)
      apply auto
      done
    with 1 show "l!i=[]" by blast
  qed
qed

lemma take_Suc0: 
  "l\<noteq>[] \<Longrightarrow> take (Suc 0) l = [l!0]" 
  "0 < length l \<Longrightarrow> take (Suc 0) l = [l!0]" 
  "Suc n \<le> length l \<Longrightarrow> take (Suc 0) l = [l!0]" 
  by (cases l, auto)+


lemma concat_take_Suc_app_nth:
  assumes "x < length l"
  shows "concat (take (Suc x) l) = concat (take x l) @ l ! x"
  using assms
  by (auto simp: take_Suc_conv_app_nth)

lemma hm_hashcode_eq:
  assumes "j < length (l!i)"
  assumes "i < length l"
  assumes "h \<Turnstile> is_hashtable l ht"
  shows "bounded_hashcode (length l) (fst (l!i!j)) = i"
  using assms
  unfolding is_hashtable_def ht_hash_def
  apply (cases "l!i!j")
  apply (force simp: set_conv_nth)
  done

lemma distinct_imp_distinct_take: 
  "distinct (map fst (concat l))
  \<Longrightarrow> distinct (map fst (concat (take x l)))"
  apply (subst (asm) append_take_drop_id[of x l,symmetric])
  apply (simp del: append_take_drop_id)
  done

lemma hm_it_adjust_rule:
  "i<length l \<Longrightarrow> <is_hashtable l ht> 
    hm_it_adjust i ht 
   <\<lambda>j. is_hashtable l ht * \<up>(
      j\<le>i \<and> 
      (concat (take (Suc i) l) = concat (take (Suc j) l)) \<and>
      (j=0 \<or> l!j \<noteq> [])
    )    
   >"
proof (induct i)
  case 0 thus ?case by sep_auto
next
  case (Suc n)
  show ?case using Suc.prems
    by (sep_auto 
      heap add: Suc.hyps
      simp: concat_take_Suc_empty
      split: list.split)
qed  

lemma hm_it_next_rule': "l'\<noteq>[] \<Longrightarrow> 
    <hm_is_it' l ht l' it> 
      hm_it_next it 
    <\<lambda>((k,v),it'). 
      hm_is_it' l ht (butlast l') it' 
    * \<up>(last l' = (k,v) \<and> distinct (map fst l') )>"
  unfolding hm_it_next_def hm_is_it'_def is_hashmap'_def
  apply (sep_auto (plain)
    split: nat.split list.split 
    heap: hm_it_adjust_rule
    simp: take_Suc0)
  apply (simp split: prod.split nat.split list.split)
  apply (intro allI impI conjI)
  apply auto []
  apply auto []
  apply sep_auto []

  apply (sep_auto (plain)
    heap: hm_it_adjust_rule)
  apply auto []
  apply sep_auto

  apply (cases l, auto) []
  apply (metis fst_conv imageI)

  apply (drule skip_empty_aux, simp_all) []
  defer
  apply (auto simp: concat_take_Suc_app_nth) []

  apply auto []
  apply sep_auto

  apply (auto simp: butlast_append) []
  apply (auto simp: butlast_append) []

  apply sep_auto
  apply (auto simp: butlast_append) []
  apply (auto simp: butlast_append) []
proof -
  case goal1
  from `xa\<in>set (take (Suc nat) l)` 
  obtain i where "i<Suc nat" "xa = l!i"
    by (auto simp: take_set)
  moreover with `(aa, ba) \<in> set xa` 
  have "l!i\<noteq>[]" and "aa\<in>fst`set (l!i)" 
    apply auto apply force done
  moreover note `\<forall>i. x < i \<and> i \<le> nat \<longrightarrow> l ! i = []`
  ultimately have "i \<le> x" by (rule_tac ccontr) auto
  hence "l!i \<in> set (take (Suc x) l)" using `Suc nat \<le> length l` `x\<le>nat`
    apply (auto simp: set_conv_nth)
    apply (rule_tac x=i in exI)
    apply auto
    done
  with `aa\<in>fst\`set (l!i)` have 
    "aa \<in> fst ` (\<Union>x\<in>set (take (Suc x) l). set x)"
    by auto
  with `aa \<notin> fst \` (\<Union>x\<in>set (take (Suc x) l). set x)` show False ..
qed

subsubsection {* Main Lemmas *}

lemma hm_it_next_rule: "m'\<noteq>Map.empty \<Longrightarrow> 
    <hm_is_it m ht m' it> 
      hm_it_next it 
    <\<lambda>((k,v),it'). hm_is_it m ht (m' |` (-{k})) it' * \<up>(m' k = Some v)>"
proof -
  { fix ys a
    have aux3: " 
      \<lbrakk>distinct (map fst ys); a \<notin> fst ` set ys\<rbrakk> \<Longrightarrow> map_of ys a = None"
      by (induct ys) auto
  } note aux3 = this

  assume "m'\<noteq>Map.empty"
  thus ?thesis
    unfolding hm_is_it_def 
    apply (sep_auto heap: hm_it_next_rule')
    apply (case_tac l' rule: rev_cases, 
      auto simp: restrict_map_def aux3 intro!: ext) []
    apply (case_tac l' rule: rev_cases, auto)
    done
qed

lemma hm_it_init_rule:
  fixes ht :: "('k::{heap,hashable},'v::heap) hashtable"
  shows "<is_hashmap m ht> hm_it_init ht <hm_is_it m ht m>\<^sub>t"
  unfolding hm_it_init_def is_hashmap_def is_hashmap'_def 
    hm_is_it_def hm_is_it'_def
  apply (sep_auto simp del: map_of_append heap add: hm_it_adjust_rule)
  apply (case_tac l, auto) []
  apply (sep_auto simp del: concat_eq_Nil_conv map_of_append)
  apply (auto simp: distinct_imp_distinct_take 
    dest: ent_fwd[OF _ is_hashmap'_distinct]) []

  apply (drule sym)
  apply (auto 
    simp: is_hashtable_def ht_distinct_def rev_map[symmetric]) []

  apply (auto simp: set_conv_nth) []
  apply (drule_tac j=ia in hm_hashcode_eq, simp_all) []
  apply (drule_tac j=ib in hm_hashcode_eq, simp_all) []

  apply (auto 
    simp: is_hashmap'_def is_hashtable_def ht_distinct_def) []

  apply (clarsimp)
  apply (drule ent_fwd[OF _ is_hashmap'_distinct])
  apply clarsimp
  apply (subst concat_take_Suc_app_nth)
  apply (case_tac l,auto) []
  apply (simp)
  apply (subst (asm) (2) concat_take_Suc_app_nth)
  apply (case_tac l,auto simp: map_append) []
  apply (subst map_of_rev_distinct)
  apply auto
  done

lemma hm_it_has_next_rule:
  "<hm_is_it m ht m' it> hm_it_has_next it 
    <\<lambda>r. hm_is_it m ht m' it * \<up>(r\<longleftrightarrow>m'\<noteq>Map.empty)>"
  unfolding is_hashmap'_def hm_is_it_def hm_is_it'_def hm_it_has_next_def
  by (sep_auto split: nat.split_asm nat.split list.split)

lemma hm_it_finish: "hm_is_it m p m' it \<Longrightarrow>\<^sub>A is_hashmap m p"
  unfolding hm_is_it_def hm_is_it'_def is_hashmap_def is_hashmap'_def
  by sep_auto

end