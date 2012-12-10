header {* The Ping Pong lemma *}

theory "PingPongLemma"
imports
   "~~/src/HOL/Algebra/Bij"
   "FreeGroups"
begin

text {*
The Ping Pong Lemma is a way to recognice a Free Group by its action on
a set (often a topological space or a graph). The name stems from the way that
elements of the set are passed forth and back between the subsets given there.
*}

text {*
We start with two auxillary lemmas, one about the identity of the group of
bijections, and one about sets of cardinality larger than one.
*}

lemma Bij_one[simp]:
  assumes "x \<in> X"
  shows "\<one>\<^bsub>BijGroup X\<^esub> x = x"
using assms by (auto simp add: BijGroup_def)

lemma other_member:
   assumes "I \<noteq> {}" and "i \<in> I" and "card I \<noteq> 1"
   obtains j where "j\<in>I" and "j\<noteq>i"
proof(cases "finite I")
  case True
  hence "I - {i} \<noteq> {}" using `card I \<noteq> 1` and `i\<in>I` by (metis Suc_eq_plus1_left card_Diff_subset_Int card_Suc_Diff1 diff_add_inverse2 diff_self_eq_0 empty_Diff finite.emptyI inf_bot_left minus_nat.diff_0)
  thus ?thesis using that by auto
next
  case False
  hence "I - {i} \<noteq> {}" by (metis Diff_empty finite.emptyI finite_Diff_insert)
  thus ?thesis using that by auto
qed

text {*
And now we can attempt the lemma. The gencount condition is a weaker variant
of ``x has to lie outside all subsets'' that is only required if the set of
generators is one. Otherwise, we will be able to find a suitable x to start
with in the proof.
*}

lemma ping_pong_lemma:
  assumes "group G"
  and "act \<in> hom G (BijGroup X)"
  and "g \<in> (I \<rightarrow> carrier G)"
  and "\<langle>g ` I\<rangle>\<^bsub>G\<^esub> = carrier G"
  and sub1: "\<forall>i\<in>I. Xout i \<subseteq> X"
  and sub2: "\<forall>i\<in>I. Xin i \<subseteq> X"
  and disj1: "\<forall>i\<in>I. \<forall>j\<in>I. i \<noteq> j \<longrightarrow> Xout i \<inter> Xout j = {}"
  and disj2: "\<forall>i\<in>I. \<forall>j\<in>I. i \<noteq> j \<longrightarrow> Xin i \<inter> Xin j = {}"
  and disj3: "\<forall>i\<in>I. \<forall>j\<in>I. Xin i \<inter> Xout j = {}"
  and "x \<in> X"
  and gencount: "\<forall> i . I = {i} \<longrightarrow> (x \<notin> Xout i \<and> x \<notin> Xin i)"
  and ping: "\<forall>i\<in>I. act (g i) ` (X - Xout i) \<subseteq> Xin i"
  and pong: "\<forall>i\<in>I. act (inv\<^bsub>G\<^esub> (g i)) ` (X - Xin i) \<subseteq> Xout i"
  shows "group.lift G g \<in> iso (\<F>\<^bsub>I\<^esub>) G"
proof-
  interpret F: group "\<F>\<^bsub>I\<^esub>"
    using assms by (auto simp add: free_group_is_group)
  interpret G: group G by fact
  interpret B: group "BijGroup X" using group_BijGroup by auto
  interpret act: group_hom G "BijGroup X" act by (unfold_locales) fact
  interpret h: group_hom "\<F>\<^bsub>I\<^esub>" G "G.lift g" 
    using F.is_group G.is_group G.lift_is_hom assms
    by (auto intro!: group_hom.intro group_hom_axioms.intro)

  show ?thesis
  proof(rule h.group_hom_isoI)
    txt {* Injectivity is the hard part of the proof. *}
    show "\<forall>x\<in>carrier \<F>\<^bsub>I\<^esub>. G.lift g x = \<one>\<^bsub>G\<^esub> \<longrightarrow> x = \<one>\<^bsub>\<F>\<^bsub>I\<^esub>\<^esub>"
       proof(rule+)

         txt {* We lift the Xout and Xin sets to generators and their inveres, and
         create variants of the disj-conditions: *}
         def Xout' \<equiv> "\<lambda>(b,i::'d). if b then Xin i else Xout i"
         def Xin' \<equiv> "\<lambda>(b,i::'d). if b then Xout i else Xin i"

         have disj1': "\<forall>i\<in>(UNIV \<times> I). \<forall>j\<in>(UNIV \<times> I). i \<noteq> j \<longrightarrow> Xout' i \<inter> Xout' j = {}"
           using disj1[rule_format] disj2[rule_format] disj3[rule_format]
           by (auto simp add:Xout'_def Xin'_def split:if_splits, blast+)
         have disj2': "\<forall>i\<in>(UNIV \<times> I). \<forall>j\<in>(UNIV \<times> I). i \<noteq> j \<longrightarrow> Xin' i \<inter> Xin' j = {}"
           using disj1[rule_format] disj2[rule_format] disj3[rule_format]
           by (auto simp add:Xout'_def Xin'_def split:if_splits, blast+)
         have disj3': "\<forall>i\<in>(UNIV \<times> I). \<forall>j\<in>(UNIV \<times> I). \<not> canceling i j \<longrightarrow> Xin' i \<inter> Xout' j = {}"
           using disj1[rule_format] disj2[rule_format] disj3[rule_format]
           by (auto simp add:canceling_def Xout'_def Xin'_def split:if_splits, blast)

         txt {* We need to pick a suitable element of the set to play ping pong
         with. In particular, it needs to be outside of the Xout-set of the last
         generator in the list, and outside the in-set of the first element. This
         part of the proof is surprisingly tedious, because there are several
         cases, some similar but not the same.
         *}

         fix w
         assume w: "w \<in> carrier \<F>\<^bsub>I\<^esub>"

         obtain x where "x \<in> X"
           and x1: "w = [] \<or> x \<notin> Xout' (last w)" 
           and x2: "w = [] \<or> x \<notin> Xin' (hd w)"
         proof-
           { assume "I = {}"
             hence "w = []" using w by (auto simp add:free_group_def)
             hence ?thesis using that `x\<in>X` by auto
           }
           moreover
           { assume "card I = 1"
             then obtain i where "I={i}" by (auto dest: card_eq_SucD)
             assume "w\<noteq>[]"
             hence "snd (hd w) = i" and "snd (last w) = i"
               using w `I={i}`
               apply (cases w, auto simp add:free_group_def)
               apply (cases w rule:rev_exhaust, auto simp add:free_group_def)
               done
             hence ?thesis using gencount[rule_format, OF `I={i}`] that[OF `x\<in>X`] `w\<noteq>[]`
             by (cases "last w", cases "hd w", auto simp add:Xout'_def Xin'_def split:if_splits)
           }
           moreover
           { assume "I \<noteq> {}" and "card I \<noteq> 1" and "w \<noteq> []"

             from `w \<noteq> []` and w
             obtain b i where hd: "hd w = (b,i)" and "i\<in>I"
               by (cases w, auto simp add:free_group_def)
             from `w \<noteq> []` and w
             obtain b' i' where last: "last w = (b',i')" and "i'\<in>I"
               by (cases w rule: rev_exhaust, auto simp add:free_group_def)

             txt {* What follows are two very similar cases, but the correct
             choice of variables depends on where we find x. *}
             {
             obtain b'' i'' where
               "(b'',i'') \<noteq> (b,i)" and
               "(b'',i'') \<noteq> (b',i')" and
               "\<not> canceling (b'', i'') (b',i')" and
               "i''\<in>I"
             proof(cases "i=i'")
               case True
               obtain j where "j\<in>I" and "j\<noteq>i" using  `card I \<noteq> 1` and `i\<in>I`
                 by -(rule other_member, auto)
               with True show ?thesis using that by (auto simp add:canceling_def)
             next
               case False thus ?thesis using that `i\<in>I` `i' \<in> I`
               by (simp add:canceling_def, metis)
             qed
             let ?g = "(b'',i'')"

             assume "x \<in> Xout' (last w)"
             hence "x \<notin> Xout' ?g"
               using disj1'[rule_format, OF _ _ `?g \<noteq> (b',i')`]
                   `i \<in> I` `i'\<in>I` `i''\<in>I` hd last
               by auto 
             hence "act (G.lift_gi g ?g) x \<in> Xin' ?g" (is "?x \<in> _") using `i'' \<in> I` `x \<in> X`
               ping[rule_format, OF `i'' \<in> I`, THEN subsetD]
               pong[rule_format, OF `i'' \<in> I`, THEN subsetD]
               by (auto simp add:G.lift_def G.lift_gi_def Xout'_def Xin'_def)
             hence "?x \<notin> Xout' (last w) \<and> ?x \<notin> Xin' (hd w)"
               using 
                 disj3'[rule_format, OF _ _ `\<not> canceling (b'', i'') (b',i')`]
                 disj2'[rule_format, OF _ _  `?g \<noteq> (b,i)`]
                 `i \<in> I` `i'\<in>I` `i''\<in>I` hd last
               by (auto simp add: canceling_def) 
             moreover
             note `i'' \<in> I`
             hence "g i'' \<in> carrier G" using `g \<in> (I \<rightarrow> carrier G)` by auto
             hence "G.lift_gi g ?g \<in> carrier G"
               by (auto simp add:G.lift_gi_def inv1_def)
             hence "act (G.lift_gi g ?g) \<in> carrier (BijGroup X)"
               using `act \<in> hom G (BijGroup X)` by auto
             hence "?x \<in> X" using `x\<in>X` 
               by (auto simp add:BijGroup_def Bij_def bij_betw_def)
             ultimately have ?thesis using that[of ?x] by auto
             }
             moreover
             {
             obtain b'' i'' where
               "\<not> canceling (b'',i'') (b,i)" and
               "\<not> canceling (b'',i'') (b',i')" and
               "(b,i) \<noteq> (b'',i'')" and
               "i''\<in>I"
             proof(cases "i=i'")
               case True
               obtain j where "j\<in>I" and "j\<noteq>i" using  `card I \<noteq> 1` and `i\<in>I`
                 by -(rule other_member, auto)
               with True show ?thesis using that by (auto simp add:canceling_def)
             next
               case False thus ?thesis using that `i\<in>I` `i' \<in> I`
               by (simp add:canceling_def, metis)
             qed
             let ?g = "(b'',i'')" 
             note cancel_sym_neg[OF `\<not> canceling (b'',i'') (b,i)`]
             note cancel_sym_neg[OF `\<not> canceling (b'',i'') (b',i')`]

             assume "x \<in> Xin' (hd w)"
             hence "x \<notin> Xout' ?g"
               using disj3'[rule_format, OF _ _ `\<not> canceling (b,i) ?g`]
                   `i \<in> I` `i'\<in>I` `i''\<in>I` hd last
               by auto 
             hence "act (G.lift_gi g ?g) x \<in> Xin' ?g" (is "?x \<in> _") using `i'' \<in> I` `x \<in> X`
               ping[rule_format, OF `i'' \<in> I`, THEN subsetD]
               pong[rule_format, OF `i'' \<in> I`, THEN subsetD]
               by (auto simp add:G.lift_def G.lift_gi_def Xout'_def Xin'_def)
             hence "?x \<notin> Xout' (last w) \<and> ?x \<notin> Xin' (hd w)"
               using 
                 disj3'[rule_format, OF _ _ `\<not> canceling ?g (b',i')`]
                 disj2'[rule_format, OF _ _  `(b,i) \<noteq> ?g`]
                 `i \<in> I` `i'\<in>I` `i''\<in>I` hd last
               by (auto simp add: canceling_def) 
             moreover
             note `i'' \<in> I`
             hence "g i'' \<in> carrier G" using `g \<in> (I \<rightarrow> carrier G)` by auto
             hence "G.lift_gi g ?g \<in> carrier G"
               by (auto simp add:G.lift_gi_def)
             hence "act (G.lift_gi g ?g) \<in> carrier (BijGroup X)"
               using `act \<in> hom G (BijGroup X)` by auto
             hence "?x \<in> X" using `x\<in>X` 
               by (auto simp add:BijGroup_def Bij_def bij_betw_def)
             ultimately have ?thesis using that[of ?x] by auto
             }
             moreover note calculation
           }
           ultimately show ?thesis using `x\<in> X` that by auto
         qed
    
         txt {* The proof works by induction over the length of the word. Each
         inductive step is one ping as in ping pong. At the end, we land in one
         of the subsets of X, so the word cannot be the identity. *}
         from x1 and w
         have "w = [] \<or> act (G.lift g w) x \<in> Xin' (hd w)"
         proof(induct w)
           case Nil show ?case by simp
         next case (Cons w ws)
           note C = Cons

           txt {* The following lemmas establish all ``obvious'' element relations that will be required during the proof. *}
           note calculation = Cons(3)
           moreover have "x\<in>X" by fact
           moreover have "snd w \<in> I" using calculation by (auto simp add:free_group_def) 
           moreover have "g \<in> (I \<rightarrow> carrier G)" by fact
           moreover have "g (snd w) \<in> carrier G" using calculation by auto
           moreover have "ws \<in> carrier \<F>\<^bsub>I\<^esub>"
              using calculation by (auto intro:cons_canceled simp add:free_group_def)
           moreover have "G.lift g ws \<in> carrier G" and "G.lift g [w] \<in> carrier G"
              using calculation by (auto simp add: free_group_def)
           moreover have "act (G.lift g ws) \<in> carrier (BijGroup X)"
                     and "act (G.lift g [w]) \<in> carrier (BijGroup X)"
                     and "act (G.lift g (w#ws)) \<in> carrier (BijGroup X)"
                     and "act (g (snd w)) \<in> carrier (BijGroup X)"
              using calculation by auto
           moreover have "act (g (snd w)) \<in> Bij X"
              using calculation by (auto simp add:BijGroup_def)
           moreover have "act (G.lift g ws) x \<in> X" (is "?x2 \<in> X")
              using calculation by (auto simp add:BijGroup_def Bij_def bij_betw_def)
           moreover have "act (G.lift g [w]) ?x2 \<in> X"
              using calculation by (auto simp add:BijGroup_def Bij_def bij_betw_def)
           moreover have "act (G.lift g (w#ws)) x \<in> X"
              using calculation by (auto simp add:BijGroup_def Bij_def bij_betw_def)
           moreover note mems = calculation
          
           have "act (G.lift g ws) x \<notin> Xout' w"
           proof(cases ws)
             case Nil             
               moreover have "x \<notin> Xout' w" using Cons(2) Nil
                 unfolding Xout'_def using mems
                 by (auto split:if_splits)
               ultimately show "act (G.lift g ws) x \<notin> Xout' w"
                 using mems by auto
           next case (Cons ww wws)
             hence "act (G.lift g ws) x \<in> Xin' (hd ws)"
               using C mems by simp
             moreover have "Xin' (hd ws) \<inter> Xout' w = {}"
             proof-
               have "\<not> canceling (hd ws) w"
               proof
                 assume "canceling (hd ws) w"
                 hence "cancels_to_1 (w#ws) wws" using Cons
                    by(auto simp add:cancel_sym cancels_to_1_def cancels_to_1_at_def cancel_at_def)
                 thus False using `w#ws \<in> carrier \<F>\<^bsub>I\<^esub>`
                    by(auto simp add:free_group_def canceled_def)
               qed  

               have "w \<in> UNIV \<times> I" "hd ws \<in> UNIV \<times> I"
                 using `snd w \<in> I` mems Cons
                 by (cases w, auto, cases "hd ws", auto simp add:free_group_def)
               thus ?thesis
                 by- (rule disj3'[rule_format, OF _ _ `\<not> canceling (hd ws) w`], auto)
             qed
             ultimately show "act (G.lift g ws) x \<notin> Xout' w" using Cons by auto
           qed
           show ?case
           proof-
             have "act (G.lift g (w # ws)) x = act (G.lift g ([w] @ ws)) x" by simp
             also have "\<dots> = act (G.lift g [w] \<otimes>\<^bsub>G\<^esub> G.lift g ws) x" 
               using mems by (subst G.lift_append, auto simp add:free_group_def)
             also have "\<dots> = (act (G.lift g [w]) \<otimes>\<^bsub>BijGroup X\<^esub> act (G.lift g ws)) x"
               using mems by (auto simp add:act.hom_mult free_group_def intro!:G.lift_closed)
             also have "\<dots> = act (G.lift g [w]) (act (G.lift g ws) x)"
               using mems by (auto simp add:BijGroup_def compose_def)
             also have "\<dots> \<notin> act (G.lift g [w]) ` Xout' w"
               apply(rule ccontr)
               apply simp
               apply (erule imageE)
               apply (subst (asm) inj_on_eq_iff[of "act (G.lift g [w])" "X"])
               using mems `act (G.lift g ws) x \<notin> Xout' w` `\<forall>i\<in>I. Xout i \<subseteq> X` `\<forall>i\<in>I. Xin i \<subseteq> X` 
               apply (auto simp add:BijGroup_def Bij_def bij_betw_def free_group_def Xout'_def split:if_splits)
               apply blast+
               done
             finally            
             have "act (G.lift g (w # ws)) x \<in> Xin' w"
             proof-
               assume "act (G.lift g (w # ws)) x \<notin> act (G.lift g [w]) ` Xout' w"
               hence "act (G.lift g (w # ws)) x \<in> (X - act (G.lift g [w]) ` Xout' w)"
                 using mems by auto
               also have "\<dots> \<subseteq> act (G.lift g [w]) ` X - act (G.lift g [w]) ` Xout' w"
                     using `act (G.lift g [w]) \<in> carrier (BijGroup X)`
                     by (auto simp add:BijGroup_def Bij_def bij_betw_def)
               also have "\<dots> \<subseteq> act (G.lift g [w]) ` (X - Xout' w)"
                      by (rule image_diff_subset)
               also have "... \<subseteq> Xin' w"
               proof(cases "fst w")
                 assume "\<not> fst w"
                 thus ?thesis
                   using mems
                   by (auto intro!: ping[rule_format, THEN subsetD] simp add: Xout'_def Xin'_def G.lift_def G.lift_gi_def free_group_def) 
               next assume "fst w"
                 thus ?thesis
                   using mems
                   by (auto intro!: pong[rule_format, THEN subsetD] simp add: restrict_def inv_BijGroup Xout'_def Xin'_def G.lift_def G.lift_gi_def free_group_def) 
               qed
               finally show ?thesis .
             qed
             thus ?thesis by simp
           qed
         qed
           moreover assume "G.lift g w = \<one>\<^bsub>G\<^esub>"
         ultimately show "w = \<one>\<^bsub>\<F>\<^bsub>I\<^esub>\<^esub>"
           using `x\<in>X` Cons(1) x2 `w \<in> carrier \<F>\<^bsub>I\<^esub>`
         by (cases w, auto simp add:free_group_def Xin'_def split:if_splits)       
       qed
    next
    txt {* Surjectivity is relatively simple, and ofen not even mentioned in
    human proofs. *}
    have "G.lift g ` carrier \<F>\<^bsub>I\<^esub> =
          G.lift g ` \<langle>\<iota> ` I\<rangle>\<^bsub>\<F>\<^bsub>I\<^esub>\<^esub>"
      by (metis gens_span_free_group)
    also have "... = \<langle>G.lift g ` (\<iota> ` I) \<rangle>\<^bsub>G\<^esub>"
       by (auto intro!:h.hom_span simp add: insert_closed)
    also have "\<dots> = \<langle>g ` I \<rangle>\<^bsub>G\<^esub>"
       proof-
         have "\<forall> i \<in> I. G.lift g (\<iota> i) = g i"
           using `g \<in> (I \<rightarrow> carrier G)`         
           by (auto simp add:insert_def G.lift_def G.lift_gi_def intro:G.r_one)
         hence "G.lift g ` (\<iota> ` I) = g ` I "
           by (auto intro!: image_cong simp add: image_compose[THEN sym])
         thus ?thesis by simp
       qed
     also have "\<dots> = carrier G" using assms by simp
     finally show "G.lift g ` carrier \<F>\<^bsub>I\<^esub> = carrier G".
  qed
qed

end
