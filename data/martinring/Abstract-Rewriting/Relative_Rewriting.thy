(*  Title:       Abstract Rewriting
    Author:      Christian Sternagel <christian.sternagel@uibk.ac.at>
                 Rene Thiemann       <rene.tiemann@uibk.ac.at>
    Maintainer:  Christian Sternagel and Rene Thiemann
    License:     LGPL
*)

(*
Copyright 2010 Christian Sternagel and René Thiemann

This file is part of IsaFoR/CeTA.

IsaFoR/CeTA is free software: you can redistribute it and/or modify it under the
terms of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

IsaFoR/CeTA is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with IsaFoR/CeTA. If not, see <http://www.gnu.org/licenses/>.
*)

header {* Relative Rewriting *}

theory Relative_Rewriting
imports Abstract_Rewriting
begin

text {*Considering a relation @{term R} relative to another relation @{term S}, i.e.,
@{term R}-steps may be preceded and followd by arbitrary many @{term S}-steps.*}
abbreviation (input) relto :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a rel" where
  "relto R S \<equiv> S^* O R O S^*"

definition SN_rel_on :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a set \<Rightarrow> bool" where
  "SN_rel_on R S \<equiv> SN_on (relto R S)"

definition SN_rel_on_alt :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a set \<Rightarrow> bool" where
  "SN_rel_on_alt R S T = (\<forall>f. chain (R \<union> S) f \<and> f 0 \<in> T \<longrightarrow> \<not> (INFM j. (f j, f (Suc j)) \<in> R))"

abbreviation SN_rel :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> bool" where
  "SN_rel R S \<equiv> SN_rel_on R S UNIV"

abbreviation SN_rel_alt :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> bool" where
  "SN_rel_alt R S \<equiv> SN_rel_on_alt R S UNIV"


lemma steps_preserve_SN_on_relto:
  assumes steps: "(a, b) \<in> (R \<union> S)^*"
    and SN: "SN_on (relto R S) {a}"
  shows "SN_on (relto R S) {b}"
proof -
  let ?RS = "relto R S"
  have "(R \<union> S)^* \<subseteq> S^* \<union> ?RS^*" by regexp
  with steps have "(a,b) \<in> S^* \<or> (a,b) \<in> ?RS^*" by auto
  thus ?thesis
  proof
    assume "(a,b) \<in> ?RS^*"
    from steps_preserve_SN_on[OF this SN] show ?thesis .
  next
    assume Ssteps: "(a,b) \<in> S^*"
    show ?thesis
    proof
      fix f
      assume "f 0 \<in> {b}" and "chain ?RS f"
      hence f0: "f 0 = b" and steps: "\<And>i. (f i, f (Suc i)) \<in> ?RS" by auto
      let ?g = "\<lambda> i. if i = 0 then a else f i"
      have "\<not> SN_on ?RS {a}" unfolding SN_on_def not_not
      proof (rule exI[of _ ?g], intro conjI allI)
        fix i
        show "(?g i, ?g (Suc i)) \<in> ?RS"
        proof (cases i)
          case (Suc j)
          show ?thesis using steps[of i] unfolding Suc by simp
        next
          case 0
          from steps[of 0, unfolded f0] Ssteps have steps: "(a,f (Suc 0)) \<in> S^* O ?RS" by auto
          have "(a,f (Suc 0)) \<in> ?RS" 
            by (rule set_mp[OF _ steps], regexp)
          thus ?thesis unfolding 0 by simp
        qed
      qed simp
      with SN show False by simp
    qed
  qed
qed

lemma SN_rel_on_imp_SN_rel_on_alt: "SN_rel_on R S T \<Longrightarrow> SN_rel_on_alt R S T"
proof (unfold SN_rel_on_def)
  assume SN: "SN_on (relto R S) T"
  show ?thesis
  proof (unfold SN_rel_on_alt_def, intro allI impI)
    fix f
    assume steps: "chain (R \<union> S) f \<and> f 0 \<in> T"
    with SN have SN: "SN_on (relto R S) {f 0}" 
      and steps: "\<And> i. (f i, f (Suc i)) \<in> R \<union> S" unfolding SN_defs by auto
    obtain r where  r: "\<And> j. r j \<equiv>  (f j, f (Suc j)) \<in> R" by auto
    show "\<not> (INFM j. (f j, f (Suc j)) \<in> R)"
    proof (rule ccontr)
      assume "\<not> ?thesis"
      hence ih: "infinitely_many r" unfolding infinitely_many_def r by blast
      obtain r_index where "r_index = infinitely_many.index r" by simp
      with infinitely_many.index_p[OF ih] infinitely_many.index_ordered[OF ih] infinitely_many.index_not_p_between[OF ih] 
      have r_index: "\<And> i. r (r_index i) \<and> r_index i < r_index (Suc i) \<and> (\<forall> j. r_index i < j \<and> j < r_index (Suc i) \<longrightarrow> \<not> r j)" by auto
      obtain g where g: "\<And> i. g i \<equiv> f (r_index i)" ..
      {
        fix i
        let ?ri = "r_index i"
        let ?rsi = "r_index (Suc i)"
        from r_index have isi: "?ri < ?rsi" by auto
        obtain ri rsi where ri: "ri = ?ri" and rsi: "rsi = ?rsi" by auto
        with r_index[of i] steps have inter: "\<And> j. ri < j \<and> j < rsi \<Longrightarrow> (f j, f (Suc j)) \<in> S" unfolding r by auto
        from ri isi rsi have risi: "ri < rsi" by simp                      
        {
          fix n
          assume "Suc n \<le> rsi - ri"
          hence "(f (Suc ri), f (Suc (n + ri))) \<in> S^*"
          proof (induct n, simp)
            case (Suc n)
            hence stepps: "(f (Suc ri), f (Suc (n+ri))) \<in> S^*" by simp
            have "(f (Suc (n+ri)), f (Suc (Suc n + ri))) \<in> S"
              using inter[of "Suc n + ri"] Suc(2) by auto
            with stepps show ?case by simp
          qed
        }
        from this[of "rsi - ri - 1"] risi have 
          "(f (Suc ri), f rsi) \<in> S^*" by simp
        with ri rsi have ssteps: "(f (Suc ?ri), f ?rsi) \<in> S^*" by simp
        with r_index[of i] have "(f ?ri, f ?rsi) \<in> R O S^*" unfolding r by auto
        hence "(g i, g (Suc i)) \<in> S^* O R O S^*" using rtrancl_refl unfolding g by auto        
      } 
      hence nSN: "\<not> SN_on (S^* O R O S^*) {g 0}" unfolding SN_defs by blast
      have SN: "SN_on (S^* O R O S^*) {f (r_index 0)}"
      proof (rule steps_preserve_SN_on_relto[OF _ SN])
        show "(f 0, f (r_index 0)) \<in> (R \<union> S)^*"
          unfolding rtrancl_fun_conv
          by (rule exI[of _ f], rule exI[of _ "r_index 0"], insert steps, auto)
      qed
      with nSN show False unfolding g ..
    qed
  qed
qed
        
lemma SN_rel_on_alt_imp_SN_rel_on: "SN_rel_on_alt R S T \<Longrightarrow> SN_rel_on R S T"
proof (unfold SN_rel_on_def)
  assume SN: "SN_rel_on_alt R S T"
  show "SN_on (relto R S) T"
  proof
    fix f
    assume start: "f 0 \<in> T" and  "chain (relto R S) f"
    hence steps: "\<And> i. (f i, f (Suc i)) \<in> S^* O R O S^*" by auto
    let ?prop = "\<lambda> i ai bi. (f i, bi) \<in> S^* \<and> (bi, ai) \<in> R \<and> (ai, f (Suc (i))) \<in> S^*"
    {
      fix i
      from steps obtain bi ai where "?prop i ai bi" by blast
      hence "\<exists> ai bi. ?prop i ai bi" by blast
    }
    hence "\<forall> i. \<exists> bi ai. ?prop i ai bi" by blast
    from choice[OF this] obtain b where "\<forall> i. \<exists> ai. ?prop i ai (b i)" by blast
    from choice[OF this] obtain a where steps: "\<And> i. ?prop i (a i) (b i)" by blast
    from steps[of 0] have fa0: "(f 0, a 0) \<in> S^* O R" by auto
    let ?prop = "\<lambda> i li. (b i, a i) \<in> R \<and> (\<forall> j < length li. ((a i # li) ! j, (a i # li) ! Suc j) \<in> S) \<and> last (a i # li) = b (Suc i)"
    {
      fix i
      from steps[of i] steps[of "Suc i"] have "(a i, f (Suc i)) \<in> S^*" and "(f (Suc i), b (Suc i)) \<in> S^*" by auto
      from rtrancl_trans[OF this] steps[of i] have R: "(b i, a i) \<in> R" and S: "(a i, b (Suc i)) \<in> S^*" by blast+
      from S[unfolded rtrancl_list_conv] obtain li where "last (a i # li) = b (Suc i) \<and> (\<forall> j < length li. ((a i # li) ! j, (a i # li) ! Suc j) \<in> S)" ..
      with R have "?prop i li" by blast
      hence "\<exists> li. ?prop i li" ..
    }
    hence "\<forall> i. \<exists> li. ?prop i li" ..
    from choice[OF this] obtain l where steps: "\<And> i. ?prop i (l i)" by auto
    let ?p = "\<lambda> i. ?prop i (l i)"
    from steps have steps: "\<And> i. ?p i" by blast
    let ?l = "\<lambda> i. a i # l i"    
    let ?l' = "\<lambda> i. length (?l i)"
    let ?g = "\<lambda> i. inf_concat_simple ?l' i"
    obtain g where g: "\<And> i. g i = (let (ii,jj) = ?g i in ?l ii ! jj)" by auto   
    have g0: "g 0 = a 0" unfolding g Let_def by simp
    with fa0 have fg0: "(f 0, g 0) \<in> S^* O R" by auto
    have fg0: "(f 0, g 0) \<in> (R \<union> S)^*"
      by (rule set_mp[OF _ fg0], regexp)
    have len: "\<And> i j n. ?g n = (i,j) \<Longrightarrow> j < length (?l i)"
    proof -
      fix i j n
      assume n: "?g n = (i,j)"
      show "j < length (?l i)" 
      proof (cases n)
        case 0
        with n have "j = 0" by auto
        thus ?thesis by simp
      next
        case (Suc nn)
        obtain ii jj where nn: "?g nn = (ii,jj)" by (cases "?g nn", auto)
        show ?thesis 
        proof (cases "Suc jj < length (?l ii)")
          case True
          with nn Suc have "?g n = (ii, Suc jj)" by auto
          with n True show ?thesis by simp
        next
          case False 
          with nn Suc have "?g n = (Suc ii, 0)" by auto
          with n show ?thesis by simp
        qed
      qed
    qed      
    have gsteps: "\<And> i. (g i, g (Suc i)) \<in> R \<union> S"
    proof -
      fix n
      obtain i j where n: "?g n = (i, j)" by (cases "?g n", auto)
      show "(g n, g (Suc n)) \<in> R \<union> S"
      proof (cases "Suc j < length (?l i)")
        case True
        with n have "?g (Suc n) = (i, Suc j)" by auto
        with n have gn: "g n = ?l i ! j" and gsn: "g (Suc n) = ?l i ! (Suc j)" unfolding g by auto
        thus ?thesis using steps[of i] True by auto
      next
        case False
        with n have "?g (Suc n) = (Suc i, 0)" by auto
        with n have gn: "g n = ?l i ! j" and gsn: "g (Suc n) = a (Suc i)" unfolding g by auto
        from gn len[OF n] False have "j = length (?l i) - 1" by auto
        with gn have gn: "g n = last (?l i)" using last_conv_nth[of "?l i"] by auto
        from gn gsn show ?thesis using steps[of i] steps[of "Suc i"] by auto
      qed
    qed
    have infR:  "INFM j. (g j, g (Suc j)) \<in> R" unfolding INFM_nat_le
    proof
      fix n
      obtain i j where n: "?g n = (i,j)" by (cases "?g n", auto)
      from len[OF n] have j: "j < ?l' i" .
      let ?k = "?l' i - 1 - j"
      obtain k where k: "k = j + ?k" by auto
      from j k have k2: "k = ?l' i - 1" and k3: "j + ?k < ?l' i" by auto
      from inf_concat_simple_add[OF n, of ?k, OF k3] 
      have gnk: "?g (n + ?k) = (i, k)" by (simp only: k)
      hence "g (n + ?k) = ?l i ! k" unfolding g by auto
      hence gnk2: "g (n + ?k) = last (?l i)" using last_conv_nth[of "?l i"] k2 by auto
      from k2 gnk have "?g (Suc (n+?k)) = (Suc i, 0)" by auto
      hence gnsk2: "g (Suc (n+?k)) = a (Suc i)" unfolding g by auto
      from steps[of i] steps[of "Suc i"] have main: "(g (n+?k), g (Suc (n+?k))) \<in> R" 
        by (simp only: gnk2 gnsk2)
      show "\<exists> j \<ge> n. (g j, g (Suc j)) \<in> R" 
        by (rule exI[of _ "n + ?k"], auto simp: main[simplified])
    qed
    from fg0[unfolded rtrancl_fun_conv] obtain gg n where start: "gg 0 = f 0" 
      and n: "gg n = g 0" and steps: "\<And> i. i < n \<Longrightarrow> (gg i, gg (Suc i)) \<in> R \<union> S" by auto
    let ?h = "\<lambda> i. if i < n then gg i else g (i - n)"
    obtain h where h: "h = ?h" by auto
    {
      fix i
      assume i: "i \<le> n"
      have "h i = gg i" using i unfolding h
        by (cases "i < n", auto simp: n)
    } note gg = this
    from gg[of 0]  `f 0 \<in> T` have h0: "h 0 \<in> T" unfolding start by auto
    {
      fix i
      have "(h i, h (Suc i)) \<in> R \<union> S"
      proof (cases "i < n")
        case True
        from steps[of i] gg[of i] gg[of "Suc i"] True show ?thesis by auto
      next
        case False
        hence "i = n + (i - n)" by auto
        then obtain k where i: "i = n + k" by auto
        from gsteps[of k] show ?thesis unfolding h i by simp
      qed
    } note hsteps = this
    from SN[unfolded SN_rel_on_alt_def, rule_format, OF conjI[OF allI[OF hsteps] h0]]
    have "\<not> (INFM j. (h j, h (Suc j)) \<in> R)" .
    moreover have "INFM j. (h j, h (Suc j)) \<in> R" unfolding INFM_nat_le
    proof (rule)
      fix m
      from infR[unfolded INFM_nat_le, rule_format, of m]
      obtain i where i: "i \<ge> m" and g: "(g i, g (Suc i)) \<in> R" by auto
      show "\<exists> n \<ge> m. (h n , h (Suc n)) \<in> R"
        by (rule exI[of _ "i + n"], unfold h, insert g i, auto)
    qed
    ultimately show False ..
  qed
qed


lemma SN_rel_on_conv: "SN_rel_on = SN_rel_on_alt"
  by (intro ext) (blast intro: SN_rel_on_imp_SN_rel_on_alt SN_rel_on_alt_imp_SN_rel_on)

lemmas SN_rel_defs = SN_rel_on_def SN_rel_on_alt_def

lemma SN_rel_on_alt_r_empty : "SN_rel_on_alt {} S T"
  unfolding SN_rel_defs by auto

lemma SN_rel_on_alt_s_empty : "SN_rel_on_alt R {} = SN_on R"
  by (intro ext, unfold SN_rel_defs SN_defs, auto)

lemma SN_rel_on_mono':
  assumes R: "R \<subseteq> R'" and S: "S \<subseteq> R' \<union> S'" and SN: "SN_rel_on R' S' T"
  shows "SN_rel_on R S T"
proof -
  note conv = SN_rel_on_conv SN_rel_on_alt_def INFM_nat_le
  show ?thesis unfolding conv
  proof(intro allI impI)
    fix f
    assume "chain (R \<union> S) f \<and> f 0 \<in> T"
    with R S have "chain (R' \<union> S') f \<and> f 0 \<in> T" by auto
    from SN[unfolded conv, rule_format, OF this]
    show "\<not> (\<forall> m. \<exists> n \<ge> m. (f n, f (Suc n)) \<in> R)" using R by auto
  qed
qed

lemma relto_mono:
  assumes "R \<subseteq> R'" and "S \<subseteq> S'"
  shows "relto R S \<subseteq> relto R' S'"
  using assms rtrancl_mono by blast

lemma SN_rel_on_mono:
  assumes R: "R \<subseteq> R'" and S: "S \<subseteq> S'"
    and SN: "SN_rel_on R' S' T"
  shows "SN_rel_on R S T"
  using SN
  unfolding SN_rel_on_def using SN_on_mono[OF _ relto_mono[OF R S]] by blast

lemmas SN_rel_on_alt_mono = SN_rel_on_mono[unfolded SN_rel_on_conv]

lemma SN_rel_on_imp_SN_on:
  assumes "SN_rel_on R S T" shows  "SN_on R T"
proof
  fix f
  assume "chain R f"
  and f0: "f 0 \<in> T"
  hence "\<And>i. (f i, f (Suc i)) \<in> relto R S" by blast
  thus False using assms f0 unfolding SN_rel_on_def SN_defs by blast
qed

lemma relto_Id: "relto R (S \<union> Id) = relto R S" by simp

lemma SN_rel_on_Id:
  shows "SN_rel_on R (S \<union> Id) T = SN_rel_on R S T"
  unfolding SN_rel_on_def by (simp only: relto_Id)

lemma SN_rel_on_empty[simp]: "SN_rel_on R {} T = SN_on R T"
  unfolding SN_rel_on_def by auto

lemma SN_rel_on_ideriv: "SN_rel_on R S T = (\<not> (\<exists> as. ideriv R S as \<and> as 0 \<in> T))" (is "?L = ?R")
proof
  assume ?L
  show ?R
  proof
    assume "\<exists> as. ideriv R S as \<and> as 0 \<in> T"
    then obtain as where id: "ideriv R S as" and T: "as 0 \<in> T" by auto
    note id = id[unfolded ideriv_def]
    from `?L`[unfolded SN_rel_on_conv SN_rel_on_alt_def, THEN spec[of _ as]]
      id T obtain i where i: "\<And> j. j \<ge> i \<Longrightarrow> (as j, as (Suc j)) \<notin> R" by auto
    with id[unfolded INFM_nat, THEN conjunct2, THEN spec[of _ "Suc i"]] show False by auto
  qed
next
  assume ?R
  show ?L
    unfolding SN_rel_on_conv SN_rel_on_alt_def
  proof(intro allI impI)
    fix as
    assume "chain (R \<union> S) as \<and> as 0 \<in> T"
    with `?R`[unfolded ideriv_def] have "\<not> (INFM i. (as i, as (Suc i)) \<in> R)" by auto
    from this[unfolded INFM_nat] obtain i where i: "\<And>j. i < j \<Longrightarrow> (as j, as (Suc j)) \<notin> R" by auto
    show "\<not> (INFM j. (as j, as (Suc j)) \<in> R)" unfolding INFM_nat using i by blast
  qed
qed

lemma SN_rel_to_SN_rel_alt: "SN_rel R S \<Longrightarrow> SN_rel_alt R S"
proof (unfold SN_rel_on_def)
  assume SN: "SN (relto R S)"
  show ?thesis
  proof (unfold SN_rel_on_alt_def, intro allI impI)
    fix f
    presume steps: "chain (R \<union> S) f"
    obtain r where  r: "\<And>j. r j \<equiv>  (f j, f (Suc j)) \<in> R" by auto
    show "\<not> (INFM j. (f j, f (Suc j)) \<in> R)"
    proof (rule ccontr)
      assume "\<not> ?thesis"
      hence ih: "infinitely_many r" unfolding infinitely_many_def r by blast
      obtain r_index where "r_index = infinitely_many.index r" by simp
      with infinitely_many.index_p[OF ih] infinitely_many.index_ordered[OF ih] infinitely_many.index_not_p_between[OF ih] 
      have r_index: "\<And> i. r (r_index i) \<and> r_index i < r_index (Suc i) \<and> (\<forall> j. r_index i < j \<and> j < r_index (Suc i) \<longrightarrow> \<not> r j)" by auto
      obtain g where g: "\<And> i. g i \<equiv> f (r_index i)" ..
      {
        fix i
        let ?ri = "r_index i"
        let ?rsi = "r_index (Suc i)"
        from r_index have isi: "?ri < ?rsi" by auto
        obtain ri rsi where ri: "ri = ?ri" and rsi: "rsi = ?rsi" by auto
        with r_index[of i] steps have inter: "\<And> j. ri < j \<and> j < rsi \<Longrightarrow> (f j, f (Suc j)) \<in> S" unfolding r by auto
        from ri isi rsi have risi: "ri < rsi" by simp                      
        {
          fix n
          assume "Suc n \<le> rsi - ri"
          hence "(f (Suc ri), f (Suc (n + ri))) \<in> S^*"
          proof (induct n, simp)
            case (Suc n)
            hence stepps: "(f (Suc ri), f (Suc (n+ri))) \<in> S^*" by simp
            have "(f (Suc (n+ri)), f (Suc (Suc n + ri))) \<in> S"
              using inter[of "Suc n + ri"] Suc(2) by auto
            with stepps show ?case by simp
          qed
        }
        from this[of "rsi - ri - 1"] risi have 
          "(f (Suc ri), f rsi) \<in> S^*" by simp
        with ri rsi have ssteps: "(f (Suc ?ri), f ?rsi) \<in> S^*" by simp
        with r_index[of i] have "(f ?ri, f ?rsi) \<in> R O S^*" unfolding r by auto
        hence "(g i, g (Suc i)) \<in> S^* O R O S^*" using rtrancl_refl unfolding g by auto           
      } 
      hence "\<not> SN (S^* O R O S^*)" unfolding SN_defs by blast
      with SN show False by simp
    qed
  qed simp
qed

lemma SN_rel_alt_to_SN_rel : "SN_rel_alt R S \<Longrightarrow> SN_rel R S"
proof (unfold SN_rel_on_def)
  assume SN: "SN_rel_alt R S"
  show "SN (relto R S)"
  proof
    fix f
    assume "chain (relto R S) f"
    hence steps: "\<And>i. (f i, f (Suc i)) \<in> S^* O R O S^*" by auto
    let ?prop = "\<lambda> i ai bi. (f i, bi) \<in> S^* \<and> (bi, ai) \<in> R \<and> (ai, f (Suc (i))) \<in> S^*"
    {
      fix i
      from steps obtain bi ai where "?prop i ai bi" by blast
      hence "\<exists> ai bi. ?prop i ai bi" by blast
    }
    hence "\<forall> i. \<exists> bi ai. ?prop i ai bi" by blast
    from choice[OF this] obtain b where "\<forall> i. \<exists> ai. ?prop i ai (b i)" by blast
    from choice[OF this] obtain a where steps: "\<And> i. ?prop i (a i) (b i)" by blast
    let ?prop = "\<lambda> i li. (b i, a i) \<in> R \<and> (\<forall> j < length li. ((a i # li) ! j, (a i # li) ! Suc j) \<in> S) \<and> last (a i # li) = b (Suc i)"
    {
      fix i
      from steps[of i] steps[of "Suc i"] have "(a i, f (Suc i)) \<in> S^*" and "(f (Suc i), b (Suc i)) \<in> S^*" by auto
      from rtrancl_trans[OF this] steps[of i] have R: "(b i, a i) \<in> R" and S: "(a i, b (Suc i)) \<in> S^*" by blast+
      from S[unfolded rtrancl_list_conv] obtain li where "last (a i # li) = b (Suc i) \<and> (\<forall> j < length li. ((a i # li) ! j, (a i # li) ! Suc j) \<in> S)" ..
      with R have "?prop i li" by blast
      hence "\<exists> li. ?prop i li" ..
    }
    hence "\<forall> i. \<exists> li. ?prop i li" ..
    from choice[OF this] obtain l where steps: "\<And> i. ?prop i (l i)" by auto
    let ?p = "\<lambda> i. ?prop i (l i)"
    from steps have steps: "\<And> i. ?p i" by blast
    let ?l = "\<lambda> i. a i # l i"    
    let ?l' = "\<lambda> i. length (?l i)"
    let ?g = "\<lambda> i. inf_concat_simple ?l' i"
    obtain g where g: "\<And> i. g i = (let (ii,jj) = ?g i in ?l ii ! jj)" by auto    
    have len: "\<And> i j n. ?g n = (i,j) \<Longrightarrow> j < length (?l i)"
    proof -
      fix i j n
      assume n: "?g n = (i,j)"
      show "j < length (?l i)" 
      proof (cases n)
        case 0
        with n have "j = 0" by auto
        thus ?thesis by simp
      next
        case (Suc nn)
        obtain ii jj where nn: "?g nn = (ii,jj)" by (cases "?g nn", auto)
        show ?thesis 
        proof (cases "Suc jj < length (?l ii)")
          case True
          with nn Suc have "?g n = (ii, Suc jj)" by auto
          with n True show ?thesis by simp
        next
          case False 
          with nn Suc have "?g n = (Suc ii, 0)" by auto
          with n show ?thesis by simp
        qed
      qed
    qed      
    have gsteps: "\<And> i. (g i, g (Suc i)) \<in> R \<union> S"
    proof -
      fix n
      obtain i j where n: "?g n = (i, j)" by (cases "?g n", auto)
      show "(g n, g (Suc n)) \<in> R \<union> S"
      proof (cases "Suc j < length (?l i)")
        case True
        with n have "?g (Suc n) = (i, Suc j)" by auto
        with n have gn: "g n = ?l i ! j" and gsn: "g (Suc n) = ?l i ! (Suc j)" unfolding g by auto
        thus ?thesis using steps[of i] True by auto
      next
        case False
        with n have "?g (Suc n) = (Suc i, 0)" by auto
        with n have gn: "g n = ?l i ! j" and gsn: "g (Suc n) = a (Suc i)" unfolding g by auto
        from gn len[OF n] False have "j = length (?l i) - 1" by auto
        with gn have gn: "g n = last (?l i)" using last_conv_nth[of "?l i"] by auto
        from gn gsn show ?thesis using steps[of i] steps[of "Suc i"] by auto
      qed
    qed
    have infR:  "INFM j. (g j, g (Suc j)) \<in> R" unfolding INFM_nat_le
    proof
      fix n
      obtain i j where n: "?g n = (i,j)" by (cases "?g n", auto)
      from len[OF n] have j: "j < ?l' i" .
      let ?k = "?l' i - 1 - j"
      obtain k where k: "k = j + ?k" by auto
      from j k have k2: "k = ?l' i - 1" and k3: "j + ?k < ?l' i" by auto
      from inf_concat_simple_add[OF n, of ?k, OF k3] 
      have gnk: "?g (n + ?k) = (i, k)" by (simp only: k)
      hence "g (n + ?k) = ?l i ! k" unfolding g by auto
      hence gnk2: "g (n + ?k) = last (?l i)" using last_conv_nth[of "?l i"] k2 by auto
      from k2 gnk have "?g (Suc (n+?k)) = (Suc i, 0)" by auto
      hence gnsk2: "g (Suc (n+?k)) = a (Suc i)" unfolding g by auto
      from steps[of i] steps[of "Suc i"] have main: "(g (n+?k), g (Suc (n+?k))) \<in> R" 
        by (simp only: gnk2 gnsk2)
      show "\<exists> j \<ge> n. (g j, g (Suc j)) \<in> R" 
        by (rule exI[of _ "n + ?k"], auto simp: main[simplified])
    qed
    from SN[unfolded SN_rel_on_alt_def] gsteps infR show False by blast
  qed
qed

lemma SN_rel_alt_r_empty : "SN_rel_alt {} S"
  unfolding SN_rel_defs by auto

lemma SN_rel_alt_s_empty : "SN_rel_alt R {} = SN R"
  unfolding SN_rel_defs SN_defs by auto

lemma SN_rel_mono':
  "R \<subseteq> R' \<Longrightarrow> S \<subseteq> R' \<union> S' \<Longrightarrow> SN_rel R' S' \<Longrightarrow> SN_rel R S"
  unfolding SN_rel_on_conv SN_rel_defs INFM_nat_le by fast

lemma SN_rel_mono:
  assumes R: "R \<subseteq> R'" and S: "S \<subseteq> S'" and SN: "SN_rel R' S'"
  shows "SN_rel R S"
  using SN unfolding SN_rel_defs using SN_subset[OF _ relto_mono[OF R S]] by blast

lemmas SN_rel_alt_mono = SN_rel_mono[unfolded SN_rel_on_conv]

lemma SN_rel_imp_SN : assumes "SN_rel R S" shows  "SN R"
proof
  fix f
  assume "\<forall> i. (f i, f (Suc i)) \<in> R"
  hence "\<And> i. (f i, f (Suc i)) \<in> relto R S" by blast  
  thus False using assms unfolding SN_rel_defs SN_defs by fast
qed

lemma relto_trancl_conv : "(relto R S)^+ = ((R \<union> S))^* O R O ((R \<union> S))^*" (is "_ = ?RS^* O ?R O _")
proof
  show "?RS^* O ?R O ?RS^* \<subseteq> (relto R S)^+"
  proof(clarify, simp)
    fix x1 x2 x3 x4
    assume x12: "(x1,x2) \<in> ((R \<union> S))^*" and x23: "(x2,x3) \<in> R" and x34: "(x3,x4) \<in> ((R \<union> S))^*"
    let ?S = "S^*"
    {
      fix x y z
      assume "(y,z) \<in> ((R \<union> S))^*"
      hence "(x,y) \<in> relto R S \<longrightarrow> (x,z) \<in> (relto R S)^+"
      proof (induct)
        case base
        show ?case by auto
      next
        case (step u z)
        show ?case
        proof
          assume "(x,y) \<in> relto R S"
          with step have nearly: "(x,u) \<in> (relto R S)^+" by simp
          from step(2)
          show "(x,z) \<in> (relto R S)^+"
          proof
            assume "(u,z) \<in> R"
            hence "(u,z) \<in> relto R S" by auto
            with nearly show ?thesis by auto
          next
            assume uz: "(u,z) \<in> S"
            from nearly[unfolded trancl_unfold_right]
            obtain v where xv: "(x,v) \<in> (relto R S)^*" and vu: "(v,u) \<in> relto R S" by auto
            from vu obtain w where vw: "(v,w) \<in> ?S O R" and wu: "(w,u) \<in> ?S" by auto
            from wu uz have wz: "(w,z) \<in> ?S" by auto
            with vw have vz: "(v,z) \<in> relto R S" by auto
            with xv show ?thesis by auto
          qed
        qed
      qed
    } note steps_right = this
    from x23 have "(x2,x3) \<in> relto R S" by auto
    from mp[OF steps_right[OF x34] this] have x24: "(x2,x4) \<in> (relto R S)^+" .
    with x12 show "(x1,x4) \<in> (relto R S)^+" 
    proof (induct arbitrary: x4, simp)
      case (step y z) 
      from step(2)
      have "(y,x4) \<in> (relto R S)^+"
      proof
        assume "(y,z) \<in> R"
        hence "(y,z) \<in> relto R S" by auto
        with step(4) show ?thesis by auto
      next
        assume yz: "(y,z) \<in> S"
        from step(4)[unfolded trancl_unfold_left]
        obtain v where zv: "(z,v) \<in> relto R S" and vx4: "(v,x4) \<in> (relto R S)^*" by auto
        from zv obtain w where zw: "(z,w) \<in> ?S" and wv: "(w,v) \<in> R O ?S" by auto
        from yz zw have "(y,w) \<in> ?S" by auto
        with wv have "(y,v) \<in> relto R S" by auto
        with vx4 show ?thesis by auto
      qed
      from step(3)[OF this] show ?case .
    qed
  qed 
next
  have S: "S^* \<subseteq> ?RS^*" by (rule rtrancl_mono[of S "R \<union> S", simplified])
  have R: "R \<subseteq> ?RS^*" by auto
  show "(relto R S)^+ \<subseteq> ?RS^* O ?R O ?RS^*"
  proof
    fix x y
    assume "(x,y) \<in> (S^* O R O S^*)^+"
    thus "(x,y) \<in> ?RS^* O ?R O ?RS^*"
    proof (induct)
      case (base y)
      thus ?case using S by blast 
    next
      case (step y z)
      from step(2) have "(y,z) \<in> ?RS^* O ?RS^* O ?RS^*" using R S by blast
      hence "(y,z) \<in> ?RS^*" by auto
      with step (3) show ?case by force
    qed
  qed
qed

lemma SN_rel_Id:
  shows "SN_rel R (S \<union> Id) = SN_rel R S"
  unfolding SN_rel_defs by (simp only: relto_Id)

lemma relto_rtrancl: "relto R (S^*) = relto R S"
  unfolding rtrancl_idemp by simp

lemma SN_rel_empty[simp]: "SN_rel R {} = SN R"
  unfolding SN_rel_defs by auto

lemma SN_rel_ideriv: "SN_rel R S = (\<not> (\<exists> as. ideriv R S as))" (is "?L = ?R")
proof
  assume ?L
  show ?R
  proof
    assume "\<exists> as. ideriv R S as"
    then obtain as where id: "ideriv R S as" by auto
    note id = id[unfolded ideriv_def]
    from `?L`[unfolded SN_rel_on_conv SN_rel_defs, THEN spec[of _ as]]
      id obtain i where i: "\<And> j. j \<ge> i \<Longrightarrow> (as j, as (Suc j)) \<notin> R" by auto
    with id[unfolded INFM_nat, THEN conjunct2, THEN spec[of _ "Suc i"]] show False by auto
  qed
next
  assume ?R
  show ?L
    unfolding SN_rel_on_conv SN_rel_defs
  proof (intro allI impI)
    fix as
    presume "chain (R \<union> S) as"
    with `?R`[unfolded ideriv_def] have "\<not> (INFM i. (as i, as (Suc i)) \<in> R)" by auto
    from this[unfolded INFM_nat] obtain i where i: "\<And> j. i < j \<Longrightarrow> (as j, as (Suc j)) \<notin> R" by auto
    show "\<not> (INFM j. (as j, as (Suc j)) \<in> R)" unfolding INFM_nat using i by blast
  qed simp
qed

lemma SN_rel_map:
  fixes R Rw R' Rw' :: "'a rel" 
  defines A: "A \<equiv> R' \<union> Rw'"
  assumes SN: "SN_rel R' Rw'" 
  and R: "\<And>s t. (s,t) \<in> R \<Longrightarrow> (f s, f t) \<in> A^* O R' O A^*"
  and Rw: "\<And>s t. (s,t) \<in> Rw \<Longrightarrow> (f s, f t) \<in> A^*"
  shows "SN_rel R Rw"
  unfolding SN_rel_defs
proof
  fix g
  assume steps: "chain (relto R Rw) g"
  let ?f = "\<lambda>i. (f (g i))"
  obtain h where h: "h = ?f" by auto
  {
    fix i
    let ?m = "\<lambda> (x,y). (f x, f y)"
    {
      fix s t
      assume "(s,t) \<in> Rw^*"
      hence "?m (s,t) \<in> A^*"
      proof (induct)
        case base show ?case by simp
      next
        case (step t u)
        from Rw[OF step(2)] step(3)
        show ?case by auto
      qed
    } note Rw = this
    from steps have "(g i, g (Suc i)) \<in> relto R Rw" ..
    from this
    obtain s t where gs: "(g i,s) \<in> Rw^*" and st: "(s,t) \<in> R" and tg: "(t, g (Suc i)) \<in> Rw^*" by auto
    from Rw[OF gs] R[OF st] Rw[OF tg]
    have step: "(?f i, ?f (Suc i)) \<in> A^* O (A^* O R' O A^*) O A^*"
      by auto
    have "(?f i, ?f (Suc i)) \<in> A^* O R' O A^*"
      by (rule set_mp[OF _ step], regexp)
    hence "(h i, h (Suc i)) \<in> (relto R' Rw')^+"
      unfolding A h relto_trancl_conv .
  }
  hence "\<not> SN ((relto R' Rw')^+)" by auto
  with SN_imp_SN_trancl[OF SN[unfolded SN_rel_on_def]]
  show False by simp
qed

datatype SN_rel_ext_type = top_s | top_ns | normal_s | normal_ns

fun SN_rel_ext_step :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a rel \<Rightarrow> SN_rel_ext_type \<Rightarrow> 'a rel" where
  "SN_rel_ext_step P Pw R Rw top_s = P"
| "SN_rel_ext_step P Pw R Rw top_ns = Pw"
| "SN_rel_ext_step P Pw R Rw normal_s = R"
| "SN_rel_ext_step P Pw R Rw normal_ns = Rw"

(* relative termination with four relations as required in DP-framework *)
definition SN_rel_ext :: "'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a rel \<Rightarrow> 'a rel \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> bool" where
  "SN_rel_ext P Pw R Rw M \<equiv> (\<not> (\<exists>f t. 
    (\<forall> i. (f i, f (Suc i)) \<in> SN_rel_ext_step P Pw R Rw (t i))
    \<and> (\<forall> i. M (f i))
    \<and> (INFM i. t i \<in> {top_s,top_ns})
    \<and> (INFM i. t i \<in> {top_s,normal_s})))"

lemma SN_rel_ext_trans:
  fixes P Pw R Rw :: "'a rel" and M :: "'a \<Rightarrow> bool"
  defines M': "M' \<equiv> {(s,t). M t}"
  defines A: "A \<equiv> (P \<union> Pw \<union> R \<union> Rw) \<inter> M'"
  assumes "SN_rel_ext P Pw R Rw M" 
  shows "SN_rel_ext (A^* O (P \<inter> M') O A^*) (A^* O ((P \<union> Pw) \<inter> M') O A^*) (A^* O ((P \<union> R) \<inter> M') O A^*) (A^*) M" (is "SN_rel_ext ?P ?Pw ?R ?Rw M")
proof (rule ccontr)
  let ?relt = "SN_rel_ext_step ?P ?Pw ?R ?Rw"
  let ?rel = "SN_rel_ext_step P Pw R Rw" 
  assume "\<not> ?thesis"
  from this[unfolded SN_rel_ext_def]
  obtain f ty
    where steps: "\<And> i. (f i, f (Suc i)) \<in> ?relt (ty i)" 
    and min: "\<And> i. M (f i)"
    and inf1: "INFM i. ty i \<in> {top_s, top_ns}"
    and inf2: "INFM i. ty i \<in> {top_s, normal_s}"
    by auto
  let ?Un = "\<lambda> tt. \<Union> ?rel ` tt"
  let ?UnM = "\<lambda> tt. (\<Union> ?rel ` tt) \<inter> M'"
  let ?A = "?UnM {top_s,top_ns,normal_s,normal_ns}"
  let ?P' = "?UnM {top_s}"
  let ?Pw' = "?UnM {top_s,top_ns}"
  let ?R' = "?UnM {top_s,normal_s}"
  let ?Rw' = "?UnM {top_s,top_ns,normal_s,normal_ns}"
  have A: "A = ?A" unfolding A by auto
  have P: "(P \<inter> M') = ?P'" by auto
  have Pw: "(P \<union> Pw) \<inter> M' = ?Pw'" by auto
  have R: "(P \<union> R) \<inter> M' = ?R'" by auto
  have Rw: "A = ?Rw'" unfolding A ..
  {
    fix s t tt
    assume m: "M s" and st: "(s,t) \<in> ?UnM tt"
    hence "\<exists> typ \<in> tt. (s,t) \<in> ?rel typ \<and> M s \<and> M t" unfolding M' by auto
  } note one_step = this
  let ?seq = "\<lambda> s t g n ty. s = g 0 \<and> t = g n \<and> (\<forall> i < n. (g i, g (Suc i)) \<in> ?rel (ty i)) \<and> (\<forall> i \<le> n. M (g i))"
  {
    fix s t
    assume m: "M s" and st: "(s,t) \<in> A^*"
    from st[unfolded rtrancl_fun_conv]
    obtain g n where g0: "g 0 = s" and gn: "g n = t" and steps: "\<And> i. i < n \<Longrightarrow> (g i, g (Suc i)) \<in> ?A" unfolding A by auto
    {
      fix i
      assume "i \<le> n"
      have "M (g i)"
      proof (cases i)
        case 0
        show ?thesis unfolding 0 g0 by (rule m)
      next
        case (Suc j)
        with `i \<le> n` have "j < n" by auto
        from steps[OF this] show ?thesis unfolding Suc M' by auto
      qed
    } note min = this
    {
      fix i
      assume i: "i < n" hence i': "i \<le> n" by auto
      from i' one_step[OF min steps[OF i]]
      have "\<exists> ty. (g i, g (Suc i)) \<in> ?rel ty" by blast
    }
    hence "\<forall> i. (\<exists> ty. i < n \<longrightarrow> (g i, g (Suc i)) \<in> ?rel ty)" by auto
    from choice[OF this]
    obtain tt where steps: "\<And> i. i < n \<Longrightarrow> (g i, g (Suc i)) \<in> ?rel (tt i)" by auto
    from g0 gn steps min
    have "?seq s t g n tt" by auto
    hence "\<exists> g n tt. ?seq s t g n tt" by blast
  } note A_steps = this
  let ?seqtt = "\<lambda> s t tt g n ty. s = g 0 \<and> t = g n \<and> n > 0 \<and> (\<forall> i<n. (g i, g (Suc i)) \<in> ?rel (ty i)) \<and> (\<forall> i \<le> n. M (g i)) \<and> (\<exists> i < n. ty i \<in> tt)"
  {
    fix s t tt
    assume m: "M s" and st: "(s,t) \<in> A^* O ?UnM tt O A^*"
    then obtain u v where su: "(s,u) \<in> A^*" and uv: "(u,v) \<in> ?UnM tt" and vt: "(v,t) \<in> A^*"
      by auto
    from A_steps[OF m su] obtain g1 n1 ty1 where seq1: "?seq s u g1 n1 ty1" by auto
    from uv have "M v" unfolding M' by auto
    from A_steps[OF this vt] obtain g2 n2 ty2 where seq2: "?seq v t g2 n2 ty2" by auto
    from seq1 have "M u" by auto
    from one_step[OF this uv] obtain ty where ty: "ty \<in> tt" and uv: "(u,v) \<in> ?rel ty" by auto
    let ?g = "\<lambda> i. if i \<le> n1 then g1 i else g2 (i - (Suc n1))"
    let ?ty = "\<lambda> i. if i < n1 then ty1 i else if i = n1 then ty else ty2 (i - (Suc n1))"
    let ?n = "Suc (n1 + n2)"
    have ex: "\<exists> i < ?n. ?ty i \<in> tt"
      by (rule exI[of _ n1], simp add: ty)
    have steps: "\<forall> i < ?n. (?g i, ?g (Suc i)) \<in> ?rel (?ty i)"
    proof (intro allI impI)
      fix i
      assume "i < ?n"
      show "(?g i, ?g (Suc i)) \<in> ?rel (?ty i)"
      proof (cases "i \<le> n1")
        case True
        with seq1 seq2 uv show ?thesis by auto
      next
        case False
        hence "i = Suc n1 + (i - Suc n1)" by auto
        then obtain k where i: "i = Suc n1 + k" by auto
        with `i < ?n` have "k < n2" by auto
        thus ?thesis using seq2 unfolding i by auto
      qed
    qed
    from steps seq1 seq2 ex 
    have seq: "?seqtt s t tt ?g ?n ?ty" by auto
    have "\<exists> g n ty. ?seqtt s t tt g n ty" 
      by (intro exI, rule seq)
  } note A_tt_A = this
  let ?tycon = "\<lambda> ty1 ty2 tt ty' n. ty1 = ty2 \<longrightarrow> (\<exists>i < n. ty' i \<in> tt)"
  let ?seqt = "\<lambda> i ty g n ty'. f i = g 0 \<and> f (Suc i) = g n \<and> (\<forall> j < n. (g j, g (Suc j)) \<in> ?rel (ty' j)) \<and> (\<forall> j \<le> n. M (g j)) 
                \<and> (?tycon (ty i) top_s {top_s} ty' n)
                \<and> (?tycon (ty i) top_ns {top_s,top_ns} ty' n)
                \<and> (?tycon (ty i) normal_s {top_s,normal_s} ty' n)"
  {
    fix i
    have "\<exists> g n ty'. ?seqt i ty g n ty'"
    proof (cases "ty i")
      case top_s
      from steps[of i, unfolded top_s] 
      have "(f i, f (Suc i)) \<in> ?P" by auto
      from A_tt_A[OF min this[unfolded P]]
      show ?thesis unfolding top_s by auto
    next
      case top_ns
      from steps[of i, unfolded top_ns] 
      have "(f i, f (Suc i)) \<in> ?Pw" by auto
      from A_tt_A[OF min this[unfolded Pw]]
      show ?thesis unfolding top_ns by auto
    next
      case normal_s
      from steps[of i, unfolded normal_s] 
      have "(f i, f (Suc i)) \<in> ?R" by auto
      from A_tt_A[OF min this[unfolded R]]
      show ?thesis unfolding normal_s by auto
    next
      case normal_ns
      from steps[of i, unfolded normal_ns] 
      have "(f i, f (Suc i)) \<in> ?Rw" by auto
      from A_steps[OF min this]
      show ?thesis unfolding normal_ns by auto
    qed
  }
  hence "\<forall> i. \<exists> g n ty'. ?seqt i ty g n ty'" by auto
  from choice[OF this] obtain g where "\<forall> i. \<exists> n ty'. ?seqt i ty (g i) n ty'" by auto
  from choice[OF this] obtain n where "\<forall> i. \<exists> ty'. ?seqt i ty (g i) (n i) ty'" by auto
  from choice[OF this] obtain ty' where "\<forall> i. ?seqt i ty (g i) (n i) (ty' i)" by auto
  hence partial: "\<And> i. ?seqt i ty (g i) (n i) (ty' i)" ..
  (* it remains to concatenate all these finite sequences to an infinite one *)
  let ?ind = "inf_concat n"
  let ?g = "\<lambda> k. (\<lambda> (i,j). g i j) (?ind k)"
  let ?ty = "\<lambda> k. (\<lambda> (i,j). ty' i j) (?ind k)"
  have inf: "INFM i. 0 < n i"
    unfolding INFM_nat_le
  proof (intro allI)
    fix m
    from inf1[unfolded INFM_nat_le]
    obtain k where k: "k \<ge> m" and ty: "ty k \<in> {top_s, top_ns}" by auto
    show "\<exists> k \<ge> m. 0 < n k"
    proof (intro exI conjI, rule k)
      from partial[of k] ty show "0 < n k" by (cases "n k", auto)
    qed
  qed
  note bounds = inf_concat_bounds[OF inf]
  note inf_Suc = inf_concat_Suc[OF inf]
  note inf_mono = inf_concat_mono[OF inf]
  have "\<not> SN_rel_ext P Pw R Rw M"
    unfolding SN_rel_ext_def simp_thms
  proof (rule exI[of _ ?g], rule exI[of _ ?ty], intro conjI allI)
    fix k
    obtain i j where ik: "?ind k = (i,j)" by force
    from bounds[OF this] have j: "j < n i" by auto
    show "M (?g k)" unfolding ik using partial[of i] j by auto
  next
    fix k
    obtain i j where ik: "?ind k = (i,j)" by force
    from bounds[OF this] have j: "j < n i" by auto
    from partial[of i] j have step: "(g i j, g i (Suc j)) \<in> ?rel (ty' i j)" by auto
    obtain i' j' where isk: "?ind (Suc k) = (i',j')" by force
    have i'j': "g i' j' = g i (Suc j)"
    proof (rule inf_Suc[OF _ ik isk])
      fix i
      from partial[of i]
      have "g i (n i) = f (Suc i)" by simp
      also have "... = g (Suc i) 0" using partial[of "Suc i"] by simp
      finally show "g i (n i) = g (Suc i) 0" .
    qed
    show "(?g k, ?g (Suc k)) \<in> ?rel (?ty k)"
      unfolding ik isk split i'j'
      by (rule step)
  next
    show "INFM i. ?ty i \<in> {top_s, top_ns}"
      unfolding INFM_nat_le
    proof (intro allI)
      fix k
      obtain i j where ik: "?ind k = (i,j)" by force      
      from inf1[unfolded INFM_nat] obtain i' where i': "i' > i" and ty: "ty i' \<in> {top_s, top_ns}" by auto
      from partial[of i'] ty obtain j' where j': "j' < n i'" and ty': "ty' i' j' \<in> {top_s, top_ns}" by auto      
      from inf_concat_surj[of _ n, OF j'] obtain k' where ik': "?ind k' = (i',j')" ..        
      from inf_mono[OF ik ik' i'] have k: "k \<le> k'" by simp
      show "\<exists> k' \<ge> k. ?ty k' \<in> {top_s, top_ns}"
        by (intro exI conjI, rule k, unfold ik' split, rule ty')
    qed
  next
    show "INFM i. ?ty i \<in> {top_s, normal_s}"
      unfolding INFM_nat_le
    proof (intro allI)
      fix k
      obtain i j where ik: "?ind k = (i,j)" by force      
      from inf2[unfolded INFM_nat] obtain i' where i': "i' > i" and ty: "ty i' \<in> {top_s, normal_s}" by auto
      from partial[of i'] ty obtain j' where j': "j' < n i'" and ty': "ty' i' j' \<in> {top_s, normal_s}" by auto
      from inf_concat_surj[of _ n, OF j'] obtain k' where ik': "?ind k' = (i',j')" ..
      from inf_mono[OF ik ik' i'] have k: "k \<le> k'" by simp
      show "\<exists> k' \<ge> k. ?ty k' \<in> {top_s, normal_s}"
        by (intro exI conjI, rule k, unfold ik' split, rule ty')
    qed
  qed
  with assms show False by auto
qed


lemma SN_rel_ext_map: fixes P Pw R Rw P' Pw' R' Rw' :: "'a rel" and M M' :: "'a \<Rightarrow> bool"
  defines Ms: "Ms \<equiv> {(s,t). M' t}"
  defines A: "A \<equiv> (P' \<union> Pw' \<union> R' \<union> Rw') \<inter> Ms"
  assumes SN: "SN_rel_ext P' Pw' R' Rw' M'" 
  and P: "\<And> s t. M s \<Longrightarrow> M t \<Longrightarrow> (s,t) \<in> P \<Longrightarrow> (f s, f t) \<in> (A^* O (P' \<inter> Ms) O A^*) \<and> I t"
  and Pw: "\<And> s t. M s \<Longrightarrow> M t \<Longrightarrow> (s,t) \<in> Pw \<Longrightarrow> (f s, f t) \<in> (A^* O ((P' \<union> Pw') \<inter> Ms) O A^*) \<and> I t"
  and R: "\<And> s t. I s \<Longrightarrow> M s \<Longrightarrow> M t \<Longrightarrow> (s,t) \<in> R \<Longrightarrow> (f s, f t) \<in> (A^* O ((P' \<union> R') \<inter> Ms) O A^*) \<and> I t"
  and Rw: "\<And> s t. I s \<Longrightarrow> M s \<Longrightarrow> M t \<Longrightarrow> (s,t) \<in> Rw \<Longrightarrow> (f s, f t) \<in> A^* \<and> I t"
  shows "SN_rel_ext P Pw R Rw M" 
proof -
  note SN = SN_rel_ext_trans[OF SN]
  let ?P = "(A^* O (P' \<inter> Ms) O A^*)"
  let ?Pw = "(A^* O ((P' \<union> Pw') \<inter> Ms) O A^*)"
  let ?R = "(A^* O ((P' \<union> R') \<inter> Ms) O A^*)"
  let ?Rw = "A^*"
  let ?relt = "SN_rel_ext_step ?P ?Pw ?R ?Rw"
  let ?rel = "SN_rel_ext_step P Pw R Rw" 
  show ?thesis 
  proof (rule ccontr)
    assume "\<not> ?thesis"
    from this[unfolded SN_rel_ext_def]
    obtain g ty
      where steps: "\<And> i. (g i, g (Suc i)) \<in> ?rel (ty i)" 
      and min: "\<And> i. M (g i)"
      and inf1: "INFM i. ty i \<in> {top_s, top_ns}"
      and inf2: "INFM i. ty i \<in> {top_s, normal_s}"
      by auto
    from inf1[unfolded INFM_nat] obtain k where k: "ty k \<in> {top_s, top_ns}" by auto
    let ?k = "Suc k"
    let ?i = "shift id ?k"
    let ?f = "\<lambda> i. f (shift g ?k i)"
    let ?ty = "shift ty ?k"
    {
      fix i
      assume ty: "ty i \<in> {top_s,top_ns}"
      note m = min[of i] 
      note ms = min[of "Suc i"]
      from P[OF m ms]
        Pw[OF m ms]
        steps[of i]
        ty
      have "(f (g i), f (g (Suc i))) \<in> ?relt (ty i) \<and> I (g (Suc i))"
        by (cases "ty i", auto)
    } note stepsP = this
    {
      fix i
      assume I: "I (g i)"
      note m = min[of i] 
      note ms = min[of "Suc i"]
      from P[OF m ms]
        Pw[OF m ms]
        R[OF I m ms]
        Rw[OF I m ms]
        steps[of i]
      have "(f (g i), f (g (Suc i))) \<in> ?relt (ty i) \<and> I (g (Suc i))"
        by (cases "ty i", auto)
    } note stepsI = this
    {
      fix i
      have "I (g (?i i))"
      proof (induct i)
        case 0
        show ?case using stepsP[OF k] by simp
      next
        case (Suc i)
        from stepsI[OF Suc] show ?case by simp
      qed
    } note I = this
    have "\<not> SN_rel_ext ?P ?Pw ?R ?Rw M'"
      unfolding SN_rel_ext_def simp_thms
    proof (rule exI[of _ ?f], rule exI[of _ ?ty], intro allI conjI)
      fix i
      show "(?f i, ?f (Suc i)) \<in> ?relt (?ty i)"
        using stepsI[OF I[of i]] by auto
    next
      show "INFM i. ?ty i \<in> {top_s, top_ns}"
        unfolding Infm_shift[of "\<lambda>i. i \<in> {top_s,top_ns}" ty ?k]
        by (rule inf1)
    next
      show "INFM i. ?ty i \<in> {top_s, normal_s}"
        unfolding Infm_shift[of "\<lambda>i. i \<in> {top_s,normal_s}" ty ?k]
        by (rule inf2)
    next
      fix i
      have A: "A \<subseteq> Ms" unfolding A by auto
      from rtrancl_mono[OF this] have As: "A^* \<subseteq> Ms^*" by auto
      have PM: "?P \<subseteq> Ms^* O Ms O Ms^*" using As by auto
      have PwM: "?Pw \<subseteq> Ms^* O Ms O Ms^*" using As by auto
      have RM: "?R \<subseteq> Ms^* O Ms O Ms^*" using As by auto
      have RwM: "?Rw \<subseteq> Ms^*" using As by auto
      from PM PwM RM have "?P \<union> ?Pw \<union> ?R \<subseteq> Ms^* O Ms O Ms^*" (is "?PPR \<subseteq> _") by auto
      also have "... \<subseteq> Ms^+" by regexp
      also have "... = Ms"
      proof
        have "Ms^+ \<subseteq> Ms^* O Ms" by regexp
        also have "... \<subseteq> Ms" unfolding Ms by auto
        finally show "Ms^+ \<subseteq> Ms" .
      qed regexp
      finally have PPR: "?PPR \<subseteq> Ms" .
      show "M' (?f i)"
      proof (induct i)
        case 0
        from stepsP[OF k] k
        have "(f (g k), f (g (Suc k))) \<in> ?PPR" by (cases "ty k", auto)
        with PPR show ?case unfolding Ms by simp blast
      next
        case (Suc i)
        show ?case
        proof (cases "?ty i = normal_ns")
          case False
          hence "?ty i \<in> {top_s,top_ns,normal_s}"
            by (cases "?ty i", auto)
          with stepsI[OF I[of i]] have "(?f i, ?f (Suc i)) \<in> ?PPR"
            by auto
          from set_mp[OF PPR this] have "(?f i, ?f (Suc i)) \<in> Ms" .
          thus ?thesis unfolding Ms by auto
        next
          case True
          with stepsI[OF I[of i]] have "(?f i, ?f (Suc i)) \<in> ?Rw" by auto
          with RwM have mem: "(?f i, ?f (Suc i)) \<in> Ms^*" by auto
          thus ?thesis
          proof (cases)
            case base
            with Suc show ?thesis by simp
          next
            case step
            thus ?thesis unfolding Ms by simp
          qed
        qed
      qed
    qed
    with SN
    show False unfolding A Ms by simp
  qed
qed

(* and a version where it is assumed that f always preserves M and that R' and Rw' preserve M' *)
lemma SN_rel_ext_map_min: fixes P Pw R Rw P' Pw' R' Rw' :: "'a rel" and M M' :: "'a \<Rightarrow> bool"
  defines Ms: "Ms \<equiv> {(s,t). M' t}"
  defines A: "A \<equiv> P' \<inter> Ms \<union> Pw' \<inter> Ms \<union> R' \<union> Rw'"
  assumes SN: "SN_rel_ext P' Pw' R' Rw' M'" 
  and M: "\<And> t. M t \<Longrightarrow> M' (f t)"
  and M': "\<And> s t. M' s \<Longrightarrow> (s,t) \<in> R' \<union> Rw' \<Longrightarrow> M' t"
  and P: "\<And> s t. M s \<Longrightarrow> M t \<Longrightarrow> M' (f s) \<Longrightarrow> M' (f t) \<Longrightarrow> (s,t) \<in> P \<Longrightarrow> (f s, f t) \<in> (A^* O (P' \<inter> Ms) O A^*) \<and> I t"
  and Pw: "\<And> s t. M s \<Longrightarrow> M t \<Longrightarrow> M' (f s) \<Longrightarrow> M' (f t) \<Longrightarrow> (s,t) \<in> Pw \<Longrightarrow> (f s, f t) \<in> (A^* O (P' \<inter> Ms \<union> Pw' \<inter> Ms) O A^*) \<and> I t"
  and R: "\<And> s t. I s \<Longrightarrow> M s \<Longrightarrow> M t \<Longrightarrow> M' (f s) \<Longrightarrow> M' (f t) \<Longrightarrow> (s,t) \<in> R \<Longrightarrow> (f s, f t) \<in> (A^* O (P' \<inter> Ms \<union> R') O A^*) \<and> I t"
  and Rw: "\<And> s t. I s \<Longrightarrow> M s \<Longrightarrow> M t \<Longrightarrow> M' (f s) \<Longrightarrow> M' (f t) \<Longrightarrow> (s,t) \<in> Rw \<Longrightarrow> (f s, f t) \<in> A^* \<and> I t"
  shows "SN_rel_ext P Pw R Rw M"  
proof -
  let ?Ms = "{(s,t). M' t}"
  let ?A = "(P' \<union> Pw' \<union> R' \<union> Rw') \<inter> ?Ms"
  {
    fix s t
    assume s: "M' s" and "(s,t) \<in> A" 
    with M'[OF s, of t] have "(s,t) \<in> ?A \<and> M' t" unfolding Ms A by auto
  } note Aone = this
  {
    fix s t
    assume s: "M' s" and steps: "(s,t) \<in> A^*"
    from steps have "(s,t) \<in> ?A^* \<and> M' t"
    proof (induct)
      case base from s show ?case by simp
    next
      case (step t u)
      note one = Aone[OF step(3)[THEN conjunct2] step(2)] 
      from step(3) one
      have steps: "(s,u) \<in> ?A^* O ?A" by blast      
      have "(s,u) \<in> ?A^*" 
        by (rule set_mp[OF _ steps], regexp)
      with one show ?case by simp
    qed
  } note Amany = this      
  let ?P = "(A^* O (P' \<inter> Ms) O A^*)"
  let ?Pw = "(A^* O (P' \<inter> Ms \<union> Pw' \<inter> Ms) O A^*)"
  let ?R = "(A^* O (P' \<inter> Ms \<union> R') O A^*)"
  let ?Rw = "A^*"
  let ?P' = "(?A^* O (P' \<inter> ?Ms) O ?A^*)"
  let ?Pw' = "(?A^* O ((P' \<union> Pw') \<inter> ?Ms) O ?A^*)"
  let ?R' = "(?A^* O ((P' \<union> R') \<inter> ?Ms) O ?A^*)"
  let ?Rw' = "?A^*"
  show ?thesis 
  proof (rule SN_rel_ext_map[OF SN])
    fix s t
    assume s: "M s" and t: "M t" and step: "(s,t) \<in> P"
    from P[OF s t M[OF s] M[OF t] step]
    have "(f s, f t) \<in> ?P" and I: "I t"  by auto
    then obtain u v where su: "(f s, u) \<in> A^*" and uv: "(u,v) \<in> P' \<inter> Ms"
      and vt: "(v,f t) \<in> A^*" by auto
    from Amany[OF M[OF s] su] have su: "(f s, u) \<in> ?A^*" and u: "M' u" by auto
    from uv have v: "M' v" unfolding Ms by auto
    from Amany[OF v vt] have vt: "(v, f t) \<in> ?A^*" by auto
    from su uv vt I 
    show "(f s, f t) \<in> ?P' \<and> I t" unfolding Ms by auto
  next
    fix s t
    assume s: "M s" and t: "M t" and step: "(s,t) \<in> Pw"
    from Pw[OF s t M[OF s] M[OF t] step]
    have "(f s, f t) \<in> ?Pw" and I: "I t"  by auto
    then obtain u v where su: "(f s, u) \<in> A^*" and uv: "(u,v) \<in> P' \<inter> Ms \<union> Pw' \<inter> Ms"
      and vt: "(v,f t) \<in> A^*" by auto
    from Amany[OF M[OF s] su] have su: "(f s, u) \<in> ?A^*" and u: "M' u" by auto
    from uv have uv: "(u,v) \<in> (P' \<union> Pw') \<inter> ?Ms" and v: "M' v" unfolding Ms 
      by auto
    from Amany[OF v vt] have vt: "(v, f t) \<in> ?A^*" by auto
    from su uv vt I 
    show "(f s, f t) \<in> ?Pw' \<and> I t"  by auto
  next
    fix s t
    assume I: "I s" and s: "M s" and t: "M t" and step: "(s,t) \<in> R"
    from R[OF I s t M[OF s] M[OF t] step]
    have "(f s, f t) \<in> ?R" and I: "I t"  by auto
    then obtain u v where su: "(f s, u) \<in> A^*" and uv: "(u,v) \<in> P' \<inter> Ms \<union> R'"
      and vt: "(v,f t) \<in> A^*" by auto
    from Amany[OF M[OF s] su] have su: "(f s, u) \<in> ?A^*" and u: "M' u" by auto
    from uv M'[OF u, of v] have uv: "(u,v) \<in> (P' \<union> R') \<inter> ?Ms" and v: "M' v" unfolding Ms 
      by auto
    from Amany[OF v vt] have vt: "(v, f t) \<in> ?A^*" by auto
    from su uv vt I 
    show "(f s, f t) \<in> ?R' \<and> I t"  by auto
  next
    fix s t
    assume I: "I s" and s: "M s" and t: "M t" and step: "(s,t) \<in> Rw"
    from Rw[OF I s t M[OF s] M[OF t] step]
    have steps: "(f s, f t) \<in> ?Rw" and I: "I t"  by auto
    from Amany[OF M[OF s] steps] I
    show "(f s, f t) \<in> ?Rw' \<and> I t"  by auto
  qed
qed

(*OLD PART*)
lemma SN_relto_imp_SN_rel: "SN (relto R S) \<Longrightarrow> SN_rel R S"
proof -
  assume SN: "SN (relto R S)"
  show ?thesis
  proof (simp only: SN_rel_on_conv SN_rel_defs, intro allI impI)
    fix f
    presume steps: "chain (R \<union> S) f"
    obtain r where  r: "\<And> j. r j \<equiv>  (f j, f (Suc j)) \<in> R" by auto
    show "\<not> (INFM j. (f j, f (Suc j)) \<in> R)"
    proof (rule ccontr)
      assume "\<not> ?thesis"
      hence ih: "infinitely_many r" unfolding infinitely_many_def r INFM_nat_le by blast
      obtain r_index where "r_index = infinitely_many.index r" by simp
      with infinitely_many.index_p[OF ih] infinitely_many.index_ordered[OF ih] infinitely_many.index_not_p_between[OF ih] 
      have r_index: "\<And> i. r (r_index i) \<and> r_index i < r_index (Suc i) \<and> (\<forall> j. r_index i < j \<and> j < r_index (Suc i) \<longrightarrow> \<not> r j)" by auto
      obtain g where g: "\<And> i. g i \<equiv> f (r_index i)" ..
      {
        fix i
        let ?ri = "r_index i"
        let ?rsi = "r_index (Suc i)"
        from r_index have isi: "?ri < ?rsi" by auto
        obtain ri rsi where ri: "ri = ?ri" and rsi: "rsi = ?rsi" by auto
        with r_index[of i] steps have inter: "\<And> j. ri < j \<and> j < rsi \<Longrightarrow> (f j, f (Suc j)) \<in> S" unfolding r by auto
        from ri isi rsi have risi: "ri < rsi" by simp                      
        {
          fix n
          assume "Suc n \<le> rsi - ri"
          hence "(f (Suc ri), f (Suc (n + ri))) \<in> S^*"
          proof (induct n, simp)
            case (Suc n)
            hence stepps: "(f (Suc ri), f (Suc (n+ri))) \<in> S^*" by simp
            have "(f (Suc (n+ri)), f (Suc (Suc n + ri))) \<in> S"
              using inter[of "Suc n + ri"] Suc(2) by auto
            with stepps show ?case by simp
          qed
        }
        from this[of "rsi - ri - 1"] risi have 
          "(f (Suc ri), f rsi) \<in> S^*" by simp
        with ri rsi have ssteps: "(f (Suc ?ri), f ?rsi) \<in> S^*" by simp
        with r_index[of i] have "(f ?ri, f ?rsi) \<in> R O S^*" unfolding r by auto
        hence "(g i, g (Suc i)) \<in> S^* O R O S^*" using rtrancl_refl unfolding g by auto           
      } 
      hence "\<not> SN (S^* O R O S^*)" unfolding SN_defs by blast
      with SN show False by simp
    qed
  qed simp
qed

(*FIXME: move*)
lemma rtrancl_list_conv:
  "((s,t) \<in> R^*) = 
  (\<exists>list. last (s # list) = t \<and> (\<forall>i. i < length list \<longrightarrow> ((s # list) ! i, (s # list) ! Suc i) \<in> R))" (is "?l = ?r")
proof 
  assume ?r
  then obtain list where "last (s # list) = t \<and> (\<forall> i. i < length list \<longrightarrow> ((s # list) ! i, (s # list) ! Suc i) \<in> R)" ..
  thus ?l
  proof (induct list arbitrary: s, simp)
    case (Cons u ll)
    hence "last (u # ll) = t \<and> (\<forall> i. i < length ll \<longrightarrow> ((u # ll) ! i, (u # ll) ! Suc i) \<in> R)" by auto
    from Cons(1)[OF this] have rec: "(u,t) \<in> R^*" .
    from Cons have "(s, u) \<in> R" by auto
    with rec show ?case by auto
  qed
next
  assume ?l
  from rtrancl_imp_seq[OF this]
  obtain S n where s: "S 0 = s" and t: "S n = t" and steps: "\<forall> i<n. (S i, S (Suc i)) \<in> R" by auto
  let ?list = "map (\<lambda> i. S (Suc i)) [0 ..< n]"
  show ?r
  proof (rule exI[of _ ?list], intro conjI, 
      cases n, simp add: s[symmetric] t[symmetric], simp add: t[symmetric]) 
    show "\<forall> i < length ?list. ((s # ?list) ! i, (s # ?list) ! Suc i) \<in> R" 
    proof (intro allI impI)
      fix i
      assume i: "i < length ?list"
      thus "((s # ?list) ! i, (s # ?list) ! Suc i) \<in> R"
      proof (cases i, simp add: s[symmetric] steps)
        case (Suc j)
        with i steps show ?thesis by simp
      qed
    qed
  qed
qed

fun choice :: "(nat \<Rightarrow> 'a list) \<Rightarrow> nat \<Rightarrow> (nat \<times> nat)" where
  "choice f 0 = (0,0)"
| "choice f (Suc n) = (let (i, j) = choice f n in 
    if Suc j < length (f i) 
      then (i, Suc j)
      else (Suc i, 0))"
        
lemma SN_rel_imp_SN_relto : "SN_rel R S \<Longrightarrow> SN (relto R S)"
proof -
  assume SN: "SN_rel R S"
  show "SN (relto R S)"
  proof
    fix f
    assume  "\<forall> i. (f i, f (Suc i)) \<in> relto R S"
    hence steps: "\<And> i. (f i, f (Suc i)) \<in> S^* O R O S^*" by auto
    let ?prop = "\<lambda> i ai bi. (f i, bi) \<in> S^* \<and> (bi, ai) \<in> R \<and> (ai, f (Suc (i))) \<in> S^*"
    {
      fix i
      from steps obtain bi ai where "?prop i ai bi" by blast
      hence "\<exists> ai bi. ?prop i ai bi" by blast
    }
    hence "\<forall> i. \<exists> bi ai. ?prop i ai bi" by blast
    from choice[OF this] obtain b where "\<forall> i. \<exists> ai. ?prop i ai (b i)" by blast
    from choice[OF this] obtain a where steps: "\<And> i. ?prop i (a i) (b i)" by blast
    let ?prop = "\<lambda> i li. (b i, a i) \<in> R \<and> (\<forall> j < length li. ((a i # li) ! j, (a i # li) ! Suc j) \<in> S) \<and> last (a i # li) = b (Suc i)"
    {
      fix i
      from steps[of i] steps[of "Suc i"] have "(a i, f (Suc i)) \<in> S^*" and "(f (Suc i), b (Suc i)) \<in> S^*" by auto
      from rtrancl_trans[OF this] steps[of i] have R: "(b i, a i) \<in> R" and S: "(a i, b (Suc i)) \<in> S^*" by blast+
      from S[unfolded rtrancl_list_conv] obtain li where "last (a i # li) = b (Suc i) \<and> (\<forall> j < length li. ((a i # li) ! j, (a i # li) ! Suc j) \<in> S)" ..
      with R have "?prop i li" by blast
      hence "\<exists> li. ?prop i li" ..
    }
    hence "\<forall> i. \<exists> li. ?prop i li" ..
    from choice[OF this] obtain l where steps: "\<And> i. ?prop i (l i)" by auto
    let ?p = "\<lambda> i. ?prop i (l i)"
    from steps have steps: "\<And> i. ?p i" by blast
    let ?l = "\<lambda> i. a i # l i"
    let ?g = "\<lambda> i. choice (\<lambda> j. ?l j) i"
    obtain g where g: "\<And> i. g i = (let (ii,jj) = ?g i in ?l ii ! jj)" by auto
    have len: "\<And> i j n. ?g n = (i,j) \<Longrightarrow> j < length (?l i)"
    proof -
      fix i j n
      assume n: "?g n = (i,j)"
      show "j < length (?l i)" 
      proof (cases n)
        case 0
        with n have "j = 0" by auto
        thus ?thesis by simp
      next
        case (Suc nn)
        obtain ii jj where nn: "?g nn = (ii,jj)" by (cases "?g nn", auto)
        show ?thesis 
        proof (cases "Suc jj < length (?l ii)")
          case True
          with nn Suc have "?g n = (ii, Suc jj)" by auto
          with n True show ?thesis by simp
        next
          case False 
          with nn Suc have "?g n = (Suc ii, 0)" by auto
          with n show ?thesis by simp
        qed
      qed
    qed      
    have gsteps: "\<And> i. (g i, g (Suc i)) \<in> R \<union> S"
    proof -
      fix n
      obtain i j where n: "?g n = (i, j)" by (cases "?g n", auto)
      show "(g n, g (Suc n)) \<in> R \<union> S"
      proof (cases "Suc j < length (?l i)")
        case True
        with n have "?g (Suc n) = (i, Suc j)" by auto
        with n have gn: "g n = ?l i ! j" and gsn: "g (Suc n) = ?l i ! (Suc j)" unfolding g by auto
        thus ?thesis using steps[of i] True by auto
      next
        case False
        with n have "?g (Suc n) = (Suc i, 0)" by auto
        with n have gn: "g n = ?l i ! j" and gsn: "g (Suc n) = a (Suc i)" unfolding g by auto
        from gn len[OF n] False have "j = length (?l i) - 1" by auto
        with gn have gn: "g n = last (?l i)" using last_conv_nth[of "?l i"] by auto
        from gn gsn show ?thesis using steps[of i] steps[of "Suc i"] by auto
      qed
    qed
    have infR:  "\<forall> n. \<exists> j \<ge> n. (g j, g (Suc j)) \<in> R" 
    proof
      fix n
      obtain i j where n: "?g n = (i,j)" by (cases "?g n", auto)
      from len[OF n] have j: "j \<le> length (?l i) - 1" by simp
      let ?k = "length (?l i) - 1 - j"
      obtain k where k: "k = j + ?k" by auto
      from j k have k2: "k = length (?l i) - 1" and k3: "j + ?k < length (?l i)" by auto
      {
        fix n i j k l
        assume n: "choice l n = (i,j)" and "j + k < length (l i)"
        hence "choice l (n + k) = (i, j + k)"
          by (induct k arbitrary: j, simp, auto)
      }
      from this[OF n, of ?k, OF k3]
      have gnk: "?g (n + ?k) = (i, k)" by (simp only: k)
      hence "g (n + ?k) = ?l i ! k" unfolding g by auto
      hence gnk2: "g (n + ?k) = last (?l i)" using last_conv_nth[of "?l i"] k2 by auto
      from k2 gnk have "?g (Suc (n+?k)) = (Suc i, 0)" by auto
      hence gnsk2: "g (Suc (n+?k)) = a (Suc i)" unfolding g by auto
      from steps[of i] steps[of "Suc i"] have main: "(g (n+?k), g (Suc (n+?k))) \<in> R" 
        by (simp only: gnk2 gnsk2)
      show "\<exists> j \<ge> n. (g j, g (Suc j)) \<in> R" 
        by (rule exI[of _ "n + ?k"], auto simp: main[simplified])
    qed      
    from SN[simplified SN_rel_on_conv SN_rel_defs] gsteps infR show False
      unfolding INFM_nat_le by fast
  qed
qed

hide_const choice

lemma SN_relto_SN_rel_conv: "SN (relto R S) = SN_rel R S"
  by (blast intro: SN_relto_imp_SN_rel SN_rel_imp_SN_relto)

lemma SN_rel_empty1: "SN_rel {} S"
  unfolding SN_rel_defs by auto

lemma SN_rel_empty2: "SN_rel R {} = SN R"
  unfolding SN_rel_defs SN_defs by auto

lemma SN_relto_mono:
  assumes R: "R \<subseteq> R'" and S: "S \<subseteq> S'"
  and SN: "SN (relto R' S')"
  shows "SN (relto R S)"
  using SN SN_subset[OF _ relto_mono[OF R S]] by blast

lemma SN_relto_imp_SN:
  assumes "SN (relto R S)" shows "SN R"
proof
  fix f
  assume "\<forall>i. (f i, f (Suc i)) \<in> R"
  hence "\<And>i. (f i, f (Suc i)) \<in> relto R S" by blast
  thus False using assms unfolding SN_defs by force
qed

lemma SN_relto_Id:
  "SN (relto R (S \<union> Id)) = SN (relto R S)"
  by (simp only: relto_Id)


text {*Termination inheritance by transitivity (see, e.g., Geser's thesis).*}

lemma trans_subset_SN:
  assumes "trans R" and "R \<subseteq> (r \<union> s)" and "SN r" and "SN s"
  shows "SN R"
proof
  fix f :: "nat \<Rightarrow> 'a"
  assume "f 0 \<in> UNIV"
    and chain: "chain R f"
  have trans_seq: "\<forall>i j. i < j \<longrightarrow> (f i, f j) \<in> r \<union> s"
    using assms and chain_imp_trancl[OF chain] by auto
  let ?M = "{i::nat. \<forall>j>i. (f i, f j) \<notin> r}"
  show False
  proof (cases "finite ?M")
    case True
    let ?n = "Max ?M"
    from Max_ge[OF True] have "\<forall>i\<in>?M. i \<le> ?n" by simp
    hence "\<forall>k\<ge>Suc ?n. \<exists>k'>k. (f k, f k') \<in> r" by auto
    from steps_imp_chainp[of "Suc ?n" "\<lambda>x y. (x, y) \<in> r", OF this] and assms
      show False by auto
  next
    case False
    from choice[OF this[unfolded infinite_nat_iff_unbounded]]
      obtain g where 1: "\<forall>i. g i > i \<and> g i \<in> ?M" by auto
    with trans_seq have 2: "\<forall>i\<ge>0. g i > i \<and> (f i, f (g i)) \<in> r \<union> s" by auto
    let ?g = "\<lambda>i. (g ^^ Suc i) (Suc 0)"
    let ?f = "\<lambda>i. f (?g i)"
    have "\<forall>i. (?f i, ?f (Suc i)) \<in> s"
    proof
      fix i
      from 2 have "(g ^^ i) (Suc n) \<ge> 0" by (induct i) auto
      hence "?g i \<ge> 0" using assms by auto
      with 2[THEN spec[of _ "(g ^^ Suc i) (Suc 0)"]]
        show "(?f i, ?f (Suc i)) \<in> s" using 1 by auto
    qed
    with assms show False by best
  qed
qed

lemma SN_Un_conv:
  assumes "trans (r \<union> s)"
  shows "SN (r \<union> s) \<longleftrightarrow> SN r \<and> SN s"
    (is "SN ?r \<longleftrightarrow> ?rhs")
proof
  assume "SN (r \<union> s)" thus "SN r \<and> SN s"
    using SN_subset[of ?r] by blast
next
  assume "SN r \<and> SN s"
  with trans_subset_SN[OF assms subset_refl] show "SN ?r" by simp
qed

lemma SN_relto_Un:
  "SN (relto (R \<union> S) Q) \<longleftrightarrow> SN (relto R (S \<union> Q)) \<and> SN (relto S Q)"
    (is "SN ?a \<longleftrightarrow> SN ?b \<and> SN ?c")
proof -
  have eq: "?a^+ = ?b^+ \<union> ?c^+" by regexp
  from SN_Un_conv[of "?b^+" "?c^+", unfolded eq[symmetric]]
    show ?thesis unfolding SN_trancl_SN_conv by simp
qed

lemma SN_relto_split:
  assumes "SN (relto r (s \<union> q2) \<union> relto q1 (s \<union> q2))" (is "SN ?a")
    and "SN (relto s q2)" (is "SN ?b")
  shows "SN (relto r (q1 \<union> q2) \<union> relto s (q1 \<union> q2))" (is "SN ?c")
proof -
  have "?c^+ \<subseteq> ?a^+ \<union> ?b^+" by regexp
  from trans_subset_SN[OF _ this, unfolded SN_trancl_SN_conv, OF _ assms]
    show ?thesis by simp
qed

end