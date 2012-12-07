(*  Title:      JinjaThreads/J/SmallTypeSafe.thy
    Author:     Tobias Nipkow, Andreas Lochbihler
*)

header {* \isaheader{Type Safety Proof} *}

theory TypeSafe
imports
  Progress
  DefAssPreservation
begin

subsection{*Basic preservation lemmas*}

text{* First two easy preservation lemmas. *}

theorem (in J_conf_read)
  shows red_preserves_hconf:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>; P,E,hp s \<turnstile> e : T; hconf (hp s) \<rbrakk> \<Longrightarrow> hconf (hp s')"
  and reds_preserves_hconf:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>es,s\<rangle> [-ta\<rightarrow>] \<langle>es',s'\<rangle>; P,E,hp s \<turnstile> es [:] Ts; hconf (hp s) \<rbrakk> \<Longrightarrow> hconf (hp s')"
proof (induct arbitrary: T E and Ts E rule: red_reds.inducts)
  case RedNew thus ?case
    by(auto intro: hconf_heap_ops_mono)
next
  case RedNewFail thus ?case
    by(auto intro: hconf_heap_ops_mono)
next
  case RedNewArray thus ?case
    by(auto intro: hconf_heap_ops_mono)
next
  case RedNewArrayFail thus ?case
    by(auto intro: hconf_heap_ops_mono)
next
  case (RedAAss h a U n i v U' h' l)
  from `sint i < int n` `0 <=s i`
  have "nat (sint i) < n" by(metis nat_less_iff sint_0 word_sle_def)
  thus ?case using RedAAss
    by(fastforce elim: hconf_heap_write_mono intro: addr_loc_type.intros simp add: conf_def)
next
  case RedFAss thus ?case
    by(fastforce elim: hconf_heap_write_mono intro: addr_loc_type.intros simp add: conf_def)
next
  case (RedCallExternal s a U M Ts T' D vs ta va h' ta' e' s')
  hence "P,hp s \<turnstile> a\<bullet>M(vs) : T"
    by(fastforce simp add: external_WT'_iff dest: sees_method_fun)
  with RedCallExternal show ?case by(auto dest: external_call_hconf)
qed auto

theorem (in J_heap) red_preserves_lconf:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>; P,E,hp s \<turnstile> e:T; P,hp s \<turnstile> lcl s (:\<le>) E \<rbrakk> \<Longrightarrow> P,hp s' \<turnstile> lcl s' (:\<le>) E"
  and reds_preserves_lconf:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>es,s\<rangle> [-ta\<rightarrow>] \<langle>es',s'\<rangle>; P,E,hp s \<turnstile> es[:]Ts; P,hp s \<turnstile> lcl s (:\<le>) E \<rbrakk> \<Longrightarrow> P,hp s' \<turnstile> lcl s' (:\<le>) E"
proof(induct arbitrary: T E and Ts E rule:red_reds.inducts)
  case RedNew thus ?case
    by(fastforce intro:lconf_hext hext_heap_ops simp del: fun_upd_apply)
next
  case RedNewFail thus ?case
    by(auto intro:lconf_hext hext_heap_ops simp del: fun_upd_apply)
next
  case RedNewArray thus ?case
    by(fastforce intro:lconf_hext hext_heap_ops simp del: fun_upd_apply)
next
  case RedNewArrayFail thus ?case
    by(fastforce intro:lconf_hext hext_heap_ops simp del: fun_upd_apply)
next
  case RedLAss thus ?case 
    by(fastforce elim: lconf_upd simp add: conf_def simp del: fun_upd_apply )
next
  case RedAAss thus ?case
    by(fastforce intro:lconf_hext hext_heap_ops simp del: fun_upd_apply)
next
  case RedFAss thus ?case
    by(fastforce intro:lconf_hext hext_heap_ops simp del: fun_upd_apply)
next
  case (BlockRed e h x V vo ta e' h' x' T T' E)
  note red = `extTA,P,t \<turnstile> \<langle>e,(h, x(V := vo))\<rangle> -ta\<rightarrow> \<langle>e',(h', x')\<rangle>`
  note IH = `\<And>T E. \<lbrakk>P,E,hp (h, x(V := vo)) \<turnstile> e : T;
               P,hp (h, x(V := vo)) \<turnstile> lcl (h, x(V := vo)) (:\<le>) E\<rbrakk>
              \<Longrightarrow> P,hp (h', x') \<turnstile> lcl (h', x') (:\<le>) E`
  note wt = `P,E,hp (h, x) \<turnstile> {V:T=vo; e} : T'`
  note lconf = `P,hp (h, x) \<turnstile> lcl (h, x) (:\<le>) E`
  from lconf_hext[OF lconf[simplified] red_hext_incr[OF red, simplified]]
  have "P,h' \<turnstile> x (:\<le>) E" .
  moreover from wt have "P,E(V\<mapsto>T),h \<turnstile> e : T'" by(cases vo, auto)
  moreover from lconf wt have "P,h \<turnstile> x(V := vo) (:\<le>) E(V \<mapsto> T)"
    by(cases vo)(simp add: lconf_def,auto intro: lconf_upd2 simp add: conf_def)
  ultimately have "P,h' \<turnstile> x' (:\<le>) E(V\<mapsto>T)" 
    by(auto intro: IH[simplified])
  with `P,h' \<turnstile> x (:\<le>) E` show ?case
    by(auto simp add: lconf_def split: split_if_asm)
next
  case (RedCallExternal s a U M Ts T' D vs ta va h' ta' e' s')
  from `P,t \<turnstile> \<langle>a\<bullet>M(vs),hp s\<rangle> -ta\<rightarrow>ext \<langle>va,h'\<rangle>` have "hp s \<unlhd> h'" by(rule red_external_hext)
  with `s' = (h', lcl s)` `P,hp s \<turnstile> lcl s (:\<le>) E` show ?case by(auto intro: lconf_hext)
qed auto

text{* Combining conformance of heap and local variables: *}

definition (in J_heap_conf_base) sconf :: "env \<Rightarrow> ('addr, 'heap) Jstate \<Rightarrow> bool" ("_ \<turnstile> _ \<surd>"   [51,51]50)
  where "E \<turnstile> s \<surd>  \<equiv>  let (h,l) = s in hconf h \<and> P,h \<turnstile> l (:\<le>) E \<and> preallocated h"

context J_conf_read begin

lemma red_preserves_sconf:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>e,s\<rangle> -tas\<rightarrow> \<langle>e',s'\<rangle>; P,E,hp s \<turnstile> e : T; E \<turnstile> s \<surd> \<rbrakk> \<Longrightarrow> E \<turnstile> s' \<surd>"
apply(auto dest: red_preserves_hconf red_preserves_lconf simp add:sconf_def)
apply(fastforce dest: red_hext_incr intro: preallocated_hext)
done

lemma reds_preserves_sconf:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>es,s\<rangle> [-ta\<rightarrow>] \<langle>es',s'\<rangle>; P,E,hp s \<turnstile> es [:] Ts; E \<turnstile> s \<surd> \<rbrakk> \<Longrightarrow> E \<turnstile> s' \<surd>"
apply(auto dest: reds_preserves_hconf reds_preserves_lconf simp add: sconf_def)
apply(fastforce dest: reds_hext_incr intro: preallocated_hext)
done

end

lemma (in J_heap_base) wt_external_call:
  "\<lbrakk> conf_extRet P h va T; P,E,h \<turnstile> e : T \<rbrakk> \<Longrightarrow> \<exists>T'. P,E,h \<turnstile> extRet2J e va : T' \<and> P \<turnstile> T' \<le> T"
by(cases va)(auto simp add: conf_def)

subsection "Subject reduction"

theorem (in J_conf_read) assumes wf: "wf_J_prog P"
  shows subject_reduction:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>; E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e:T; P,hp s \<turnstile> t \<surd>t \<rbrakk>
  \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e':T' \<and> P \<turnstile> T' \<le> T"
  and subjects_reduction:
  "\<lbrakk> extTA,P,t \<turnstile> \<langle>es,s\<rangle> [-ta\<rightarrow>] \<langle>es',s'\<rangle>; E \<turnstile> s \<surd>; P,E,hp s \<turnstile> es[:]Ts; P,hp s \<turnstile> t \<surd>t \<rbrakk>
  \<Longrightarrow> \<exists>Ts'. P,E,hp s' \<turnstile> es'[:]Ts' \<and> P \<turnstile> Ts' [\<le>] Ts"
proof (induct arbitrary: T E and Ts E rule:red_reds.inducts)
  case RedNew
  thus ?case by(auto dest: allocate_SomeD)
next
  case RedNewFail thus ?case unfolding sconf_def
    by(fastforce intro:typeof_OutOfMemory preallocated_heap_ops simp add: xcpt_subcls_Throwable[OF _ wf]) 
next
  case NewArrayRed
  thus ?case by fastforce
next
  case RedNewArray
  thus ?case by(auto dest: allocate_SomeD)
next
  case RedNewArrayNegative thus ?case unfolding sconf_def
    by(fastforce intro: preallocated_heap_ops simp add: xcpt_subcls_Throwable[OF _ wf]) 
next
  case RedNewArrayFail thus ?case unfolding sconf_def
    by(fastforce intro:typeof_OutOfMemory preallocated_heap_ops simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (CastRed e s ta e' s' C T E)
  have esse: "extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>" 
    and IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T"
    and hconf: "E \<turnstile> s \<surd>"
    and wtc: "P,E,hp s \<turnstile> Cast C e : T" by fact+
  thus ?case
  proof(clarsimp)
    fix T'
    assume wte: "P,E,hp s \<turnstile> e : T'" "is_type P T"
    from wte and hconf and IH and `P,hp s \<turnstile> t \<surd>t` have "\<exists>U. P,E,hp s' \<turnstile> e' : U \<and> P \<turnstile> U \<le> T'" by simp
    then obtain U where wtee: "P,E,hp s' \<turnstile> e' : U" and UsTT: "P \<turnstile> U \<le> T'" by blast
    from wtee `is_type P T` have "P,E,hp s' \<turnstile> Cast T e' : T" by(rule WTrtCast)
    thus "\<exists>T'. P,E,hp s' \<turnstile> Cast T e' : T' \<and> P \<turnstile> T' \<le> T" by blast
  qed
next
  case RedCast thus ?case
    by(clarsimp simp add: is_refT_def)
next
  case RedCastFail thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (InstanceOfRed e s ta e' s' U T E)
  have IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T"
    and hconf: "E \<turnstile> s \<surd>"
    and wtc: "P,E,hp s \<turnstile> e instanceof U : T" 
    and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wtc obtain T' where "P,E,hp s \<turnstile> e : T'" by auto
  from IH[OF hconf this tconf] obtain T'' where "P,E,hp s' \<turnstile> e' : T''" by auto
  with wtc show ?case by auto
next
  case RedInstanceOf thus ?case
    by(clarsimp)
next
  case (BinOpRed1 e\<^isub>1 s ta e\<^isub>1' s' bop e\<^isub>2 T E)
  have red: "extTA,P,t \<turnstile> \<langle>e\<^isub>1, s\<rangle> -ta\<rightarrow> \<langle>e\<^isub>1', s'\<rangle>"
   and IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e\<^isub>1:T; P,hp s \<turnstile> t \<surd>t\<rbrakk>
                 \<Longrightarrow> \<exists>U. P,E,hp s' \<turnstile> e\<^isub>1' : U \<and> P \<turnstile> U \<le> T"
   and conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> e\<^isub>1 \<guillemotleft>bop\<guillemotright> e\<^isub>2 : T" 
   and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt obtain T1 T2 where wt1: "P,E,hp s \<turnstile> e\<^isub>1 : T1"
    and wt2: "P,E,hp s \<turnstile> e\<^isub>2 : T2" and wtbop: "P \<turnstile> T1\<guillemotleft>bop\<guillemotright>T2 : T" by auto
  from IH[OF conf wt1 tconf] obtain T1' where wt1': "P,E,hp s' \<turnstile> e\<^isub>1' : T1'"
    and sub: "P \<turnstile> T1' \<le> T1" by blast
  from WTrt_binop_widen_mono[OF wtbop sub widen_refl]
  obtain T' where wtbop': "P \<turnstile> T1'\<guillemotleft>bop\<guillemotright>T2 : T'" and sub': "P \<turnstile> T' \<le> T" by blast
  from wt1' WTrt_hext_mono[OF wt2 red_hext_incr[OF red]] wtbop'
  have "P,E,hp s' \<turnstile> e\<^isub>1' \<guillemotleft>bop\<guillemotright> e\<^isub>2 : T'" by(rule WTrtBinOp)
  with sub' show ?case by blast
next
  case (BinOpRed2 e\<^isub>2 s ta e\<^isub>2' s' v\<^isub>1 bop T E)
  have red: "extTA,P,t \<turnstile> \<langle>e\<^isub>2,s\<rangle> -ta\<rightarrow> \<langle>e\<^isub>2',s'\<rangle>" by fact
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e\<^isub>2:T; P,hp s \<turnstile> t \<surd>t\<rbrakk>
                 \<Longrightarrow> \<exists>U. P,E,hp s' \<turnstile> e\<^isub>2' : U \<and> P \<turnstile> U \<le> T" 
    and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  have conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> (Val v\<^isub>1) \<guillemotleft>bop\<guillemotright> e\<^isub>2 : T" by fact+
  from wt obtain T1 T2 where wt1: "P,E,hp s \<turnstile> Val v\<^isub>1 : T1"
    and wt2: "P,E,hp s \<turnstile> e\<^isub>2 : T2" and wtbop: "P \<turnstile> T1\<guillemotleft>bop\<guillemotright>T2 : T" by auto
  from IH[OF conf wt2 tconf] obtain T2' where wt2': "P,E,hp s' \<turnstile> e\<^isub>2' : T2'"
    and sub: "P \<turnstile> T2' \<le> T2" by blast
  from WTrt_binop_widen_mono[OF wtbop widen_refl sub]
  obtain T' where wtbop': "P \<turnstile> T1\<guillemotleft>bop\<guillemotright>T2' : T'" and sub': "P \<turnstile> T' \<le> T" by blast
  from WTrt_hext_mono[OF wt1 red_hext_incr[OF red]] wt2' wtbop'
  have "P,E,hp s' \<turnstile> Val v\<^isub>1 \<guillemotleft>bop\<guillemotright> e\<^isub>2' : T'" by(rule WTrtBinOp)
  with sub' show ?case by blast
next
  case (RedBinOp bop v1 v2 v s)
  from `E \<turnstile> s \<surd>` have preh: "preallocated (hp s)" by(cases s)(simp add: sconf_def)
  from `P,E,hp s \<turnstile> Val v1 \<guillemotleft>bop\<guillemotright> Val v2 : T` obtain T1 T2
    where "typeof\<^bsub>hp s\<^esub> v1 = \<lfloor>T1\<rfloor>" "typeof\<^bsub>hp s\<^esub> v2 = \<lfloor>T2\<rfloor>" "P \<turnstile> T1\<guillemotleft>bop\<guillemotright>T2 : T" by auto
  with wf preh have "P,hp s \<turnstile> v :\<le> T" using `binop bop v1 v2 = \<lfloor>Inl v\<rfloor>`
    by(rule binop_type)
  thus ?case by(auto simp add: conf_def)
next
  case (RedBinOpFail bop v1 v2 a s)
  from `E \<turnstile> s \<surd>` have preh: "preallocated (hp s)" by(cases s)(simp add: sconf_def)
  from `P,E,hp s \<turnstile> Val v1 \<guillemotleft>bop\<guillemotright> Val v2 : T` obtain T1 T2
    where "typeof\<^bsub>hp s\<^esub> v1 = \<lfloor>T1\<rfloor>" "typeof\<^bsub>hp s\<^esub> v2 = \<lfloor>T2\<rfloor>" "P \<turnstile> T1\<guillemotleft>bop\<guillemotright>T2 : T" by auto
  with wf preh have "P,hp s \<turnstile> Addr a :\<le> Class Throwable" using `binop bop v1 v2 = \<lfloor>Inr a\<rfloor>`
    by(rule binop_type)
  thus ?case by(auto simp add: conf_def)
next
  case RedVar thus ?case by (fastforce simp:sconf_def lconf_def conf_def)
next
  case LAssRed thus ?case by(blast intro:widen_trans)
next
  case RedLAss thus ?case by fastforce
next
  case (AAccRed1 a s ta a' s' i T E)
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> a : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> a' : T' \<and> P \<turnstile> T' \<le> T"
    and assa: "extTA,P,t \<turnstile> \<langle>a,s\<rangle> -ta\<rightarrow> \<langle>a',s'\<rangle>"
    and wt: "P,E,hp s \<turnstile> a\<lfloor>i\<rceil> : T"
    and hconf: "E \<turnstile> s \<surd>" 
    and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have wti: "P,E,hp s \<turnstile> i : Integer" by auto
  from wti red_hext_incr[OF assa] have wti': "P,E,hp s' \<turnstile> i : Integer" by - (rule WTrt_hext_mono)
  { assume wta: "P,E,hp s \<turnstile> a : T\<lfloor>\<rceil>"
    from IH[OF hconf wta tconf]
    obtain U where wta': "P,E,hp s' \<turnstile> a' : U" and UsubT: "P \<turnstile> U \<le> T\<lfloor>\<rceil>" by fastforce
    with wta' wti' have ?case by(cases U, auto simp add: widen_Array) }
  moreover
  { assume wta: "P,E,hp s \<turnstile> a : NT"
    from IH[OF hconf wta tconf] have "P,E,hp s' \<turnstile> a' : NT" by fastforce
    from this wti' have ?case
      by(fastforce intro:WTrtAAccNT) }
  ultimately show ?case using wt by auto
next
  case (AAccRed2 i s ta i' s' a T E)
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> i : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> i' : T' \<and> P \<turnstile> T' \<le> T"
    and issi: "extTA,P,t \<turnstile> \<langle>i,s\<rangle> -ta\<rightarrow> \<langle>i',s'\<rangle>"
    and wt: "P,E,hp s \<turnstile> Val a\<lfloor>i\<rceil> : T"
    and sconf: "E \<turnstile> s \<surd>" 
    and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have wti: "P,E,hp s \<turnstile> i : Integer" by auto
  from wti IH sconf tconf have wti': "P,E,hp s' \<turnstile> i' : Integer" by blast
  from wt show ?case
  proof (rule WTrt_elim_cases)
    assume wta: "P,E,hp s \<turnstile> Val a : T\<lfloor>\<rceil>"
    from wta red_hext_incr[OF issi] have wta': "P,E,hp s' \<turnstile> Val a : T\<lfloor>\<rceil>" by (rule WTrt_hext_mono)
    from wta' wti' show ?case by(fastforce)
  next
    assume wta: "P,E,hp s \<turnstile> Val a : NT"
    from wta red_hext_incr[OF issi] have wta': "P,E,hp s' \<turnstile> Val a : NT" by (rule WTrt_hext_mono)
    from wta' wti' show ?case
      by(fastforce elim:WTrtAAccNT)
  qed
next
  case RedAAccNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case RedAAccBounds thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (RedAAcc h a T n i v l T' E)
  from `E \<turnstile> (h, l) \<surd>` have "hconf h" by(clarsimp simp add: sconf_def)
  from `0 <=s i` `sint i < int n`
  have "nat (sint i) < n" by(metis nat_less_iff sint_0 word_sle_def)
  with `typeof_addr h a = \<lfloor>Array_type T n\<rfloor>` have "P,h \<turnstile> a@ACell (nat (sint i)) : T"
    by(auto intro: addr_loc_type.intros)
  from heap_read_conf[OF `heap_read h a (ACell (nat (sint i))) v` this] `hconf h`
  have "P,h \<turnstile> v :\<le> T" by simp
  thus ?case using RedAAcc by(auto simp add: conf_def)
next
  case (AAssRed1 a s ta a' s' i e T E)
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> a : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> a' : T' \<and> P \<turnstile> T' \<le> T"
    and assa: "extTA,P,t \<turnstile> \<langle>a,s\<rangle> -ta\<rightarrow> \<langle>a',s'\<rangle>"
    and wt: "P,E,hp s \<turnstile> a\<lfloor>i\<rceil> := e : T"
    and sconf: "E \<turnstile> s \<surd>" 
    and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have void: "T = Void" by blast
  from wt have wti: "P,E,hp s \<turnstile> i : Integer" by auto
  from wti red_hext_incr[OF assa] have wti': "P,E,hp s' \<turnstile> i : Integer" by - (rule WTrt_hext_mono)
  { assume wta: "P,E,hp s \<turnstile> a : NT"
    from IH[OF sconf wta tconf] have wta': "P,E,hp s' \<turnstile> a' : NT" by fastforce
    from wt wta obtain V where wte: "P,E,hp s \<turnstile> e : V" by(auto)
    from wte red_hext_incr[OF assa] have wte': "P,E,hp s' \<turnstile> e : V" by - (rule WTrt_hext_mono)
    from wta' wti' wte' void have ?case
      by(fastforce elim: WTrtAAssNT) }
  moreover
  { fix U
    assume wta: "P,E,hp s \<turnstile> a : U\<lfloor>\<rceil>"
    from IH[OF sconf wta tconf]
    obtain U' where wta': "P,E,hp s' \<turnstile> a' : U'" and UsubT: "P \<turnstile> U' \<le> U\<lfloor>\<rceil>" by fastforce
    with wta' have ?case
    proof(cases U')
      case NT
      assume UNT: "U' = NT"
      from UNT wt wta obtain V where wte: "P,E,hp s \<turnstile> e : V" by(auto)
      from wte red_hext_incr[OF assa] have wte': "P,E,hp s' \<turnstile> e : V" by - (rule WTrt_hext_mono)
      from wta' UNT wti' wte' void show ?thesis
	by(fastforce elim: WTrtAAssNT)
    next
      case (Array A)
      have UA: "U' = A\<lfloor>\<rceil>" by fact
      with UA UsubT wt wta obtain V where wte: "P,E,hp s \<turnstile> e : V" by auto
      from wte red_hext_incr[OF assa] have wte': "P,E,hp s' \<turnstile> e : V" by - (rule WTrt_hext_mono)
      with wta' wte' UA wti' void show ?thesis by (fast elim:WTrtAAss)
    qed(simp_all add: widen_Array) }
  ultimately show ?case using wt by blast
next
  case (AAssRed2 i s ta i' s' a e T E)
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> i : T; P,hp s \<turnstile> t \<surd>t \<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> i' : T' \<and> P \<turnstile> T' \<le> T" 
    and issi: "extTA,P,t \<turnstile> \<langle>i,s\<rangle> -ta\<rightarrow> \<langle>i',s'\<rangle>" 
    and wt: "P,E,hp s \<turnstile> Val a\<lfloor>i\<rceil> := e : T" 
    and sconf: "E \<turnstile> s \<surd>" and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have void: "T = Void" by blast
  from wt have wti: "P,E,hp s \<turnstile> i : Integer" by auto
  from IH[OF sconf wti tconf] have wti': "P,E,hp s' \<turnstile> i' : Integer" by fastforce
  from wt show ?case
  proof(rule WTrt_elim_cases)
    fix U T'
    assume wta: "P,E,hp s \<turnstile> Val a : U\<lfloor>\<rceil>"
      and wte: "P,E,hp s \<turnstile> e : T'"
    from wte red_hext_incr[OF issi] have wte': "P,E,hp s' \<turnstile> e : T'" by - (rule WTrt_hext_mono)
    from wta red_hext_incr[OF issi] have wta': "P,E,hp s' \<turnstile> Val a : U\<lfloor>\<rceil>" by - (rule WTrt_hext_mono)
    from wta' wti' wte' void show ?case by (fastforce elim:WTrtAAss)
  next
    fix T'
    assume wta: "P,E,hp s \<turnstile> Val a : NT"
      and wte: "P,E,hp s \<turnstile> e : T'"
    from wte red_hext_incr[OF issi] have wte': "P,E,hp s' \<turnstile> e : T'" by - (rule WTrt_hext_mono)
    from wta red_hext_incr[OF issi] have wta': "P,E,hp s' \<turnstile> Val a : NT" by - (rule WTrt_hext_mono)
    from wta' wti' wte' void show ?case by (fastforce elim:WTrtAAss)
  qed
next
  case (AAssRed3 e s ta e' s' a i T E)
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T" 
    and issi: "extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>" 
    and wt: "P,E,hp s \<turnstile> Val a\<lfloor>Val i\<rceil> := e : T" 
    and sconf: "E \<turnstile> s \<surd>" and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have void: "T = Void" by blast
  from wt have wti: "P,E,hp s \<turnstile> Val i : Integer" by auto
  from wti red_hext_incr[OF issi] have wti': "P,E,hp s' \<turnstile> Val i : Integer" by - (rule WTrt_hext_mono)
  from wt show ?case
  proof(rule WTrt_elim_cases)
    fix U T'
    assume wta: "P,E,hp s \<turnstile> Val a : U\<lfloor>\<rceil>"
      and wte: "P,E,hp s \<turnstile> e : T'"
    from wta red_hext_incr[OF issi] have wta': "P,E,hp s' \<turnstile> Val a : U\<lfloor>\<rceil>" by - (rule WTrt_hext_mono)
    from IH[OF sconf wte tconf]
    obtain V where wte': "P,E,hp s' \<turnstile> e' : V" by fastforce
    from wta' wti' wte' void show ?case by (fastforce elim:WTrtAAss)
  next
    fix T'
    assume wta: "P,E,hp s \<turnstile> Val a : NT"
      and wte: "P,E,hp s \<turnstile> e : T'"
    from wta red_hext_incr[OF issi] have wta': "P,E,hp s' \<turnstile> Val a : NT" by - (rule WTrt_hext_mono)
    from IH[OF sconf wte tconf]
    obtain V where wte': "P,E,hp s' \<turnstile> e' : V" by fastforce
    from wta' wti' wte' void show ?case by (fastforce elim:WTrtAAss)
  qed
next
  case RedAAssNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case RedAAssBounds thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case RedAAssStore thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case RedAAss thus ?case
    by(auto simp del:fun_upd_apply)
next
  case (ALengthRed a s ta a' s' T E)
  note IH = `\<And>T'. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> a : T'; P,hp s \<turnstile> t \<surd>t\<rbrakk>
      \<Longrightarrow> \<exists>T''. P,E,hp s' \<turnstile> a' : T'' \<and> P \<turnstile> T'' \<le> T'`
  from `P,E,hp s \<turnstile> a\<bullet>length : T`
  show ?case
  proof(rule WTrt_elim_cases)
    fix T'
    assume [simp]: "T = Integer"
      and wta: "P,E,hp s \<turnstile> a : T'\<lfloor>\<rceil>"
    from wta `E \<turnstile> s \<surd>` IH `P,hp s \<turnstile> t \<surd>t`
    obtain T'' where wta': "P,E,hp s' \<turnstile> a' : T''" 
      and sub: "P \<turnstile> T'' \<le> T'\<lfloor>\<rceil>" by blast
    from sub have "P,E,hp s' \<turnstile> a'\<bullet>length : Integer"
      unfolding widen_Array
    proof(rule disjE)
      assume "T'' = NT"
      with wta' show ?thesis by(auto)
    next
      assume "\<exists>V. T'' = V\<lfloor>\<rceil> \<and> P \<turnstile> V \<le> T'"
      then obtain V where "T'' = V\<lfloor>\<rceil>" "P \<turnstile> V \<le> T'" by blast
      with wta' show ?thesis by -(rule WTrtALength, simp)
    qed
    thus ?thesis by(simp)
  next
    assume "P,E,hp s \<turnstile> a : NT"
    with `E \<turnstile> s \<surd>` IH `P,hp s \<turnstile> t \<surd>t`
    obtain T'' where wta': "P,E,hp s' \<turnstile> a' : T''" 
      and sub: "P \<turnstile> T'' \<le> NT" by blast
    from sub have "T'' = NT" by auto
    with wta' show ?thesis by(auto)
  qed
next
  case (RedALength h a T n l T' E)
  from `P,E,hp (h, l) \<turnstile> addr a\<bullet>length : T'` `typeof_addr h a = \<lfloor>Array_type T n\<rfloor>`
  have [simp]: "T' = Integer" by(auto)
  thus ?case by(auto)
next
  case RedALengthNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (FAccRed e s ta e' s' F D T E)
  have IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk>
                 \<Longrightarrow> \<exists>U. P,E,hp s' \<turnstile> e' : U \<and> P \<turnstile> U \<le> T"
   and conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> e\<bullet>F{D} : T" 
   and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  -- "Now distinguish the two cases how wt can have arisen."
  { fix T' C fm
    assume wte: "P,E,hp s \<turnstile> e : T'"
      and icto: "class_type_of' T' = \<lfloor>C\<rfloor>"
      and has: "P \<turnstile> C has F:T (fm) in D"
    from IH[OF conf wte tconf]
    obtain U where wte': "P,E,hp s' \<turnstile> e' : U" and UsubC: "P \<turnstile> U \<le> T'" by auto
    -- "Now distinguish what @{term U} can be."
    with UsubC have ?case
    proof(cases "U = NT")
      case True
      thus ?thesis using wte' by(blast intro:WTrtFAccNT widen_refl) 
    next
      case False
      with icto UsubC obtain C' where icto': "class_type_of' U = \<lfloor>C'\<rfloor>"
        and C'subC: "P \<turnstile> C' \<preceq>\<^sup>* C"
        by(rule widen_is_class_type_of)
      from has_field_mono[OF has C'subC] wte' icto'
      show ?thesis by(auto intro!:WTrtFAcc) 
    qed }
  moreover
  { assume "P,E,hp s \<turnstile> e : NT"
    hence "P,E,hp s' \<turnstile> e' : NT" using IH[OF conf _ tconf] by fastforce
    hence ?case  by(fastforce intro:WTrtFAccNT widen_refl) }
  ultimately show ?case using wt by blast
next
  case RedFAcc thus ?case unfolding sconf_def
    by(fastforce dest: heap_read_conf intro: addr_loc_type.intros simp add: conf_def)
next
  case RedFAccNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (FAssRed1 e s ta e' s' F D e\<^isub>2)
  have red: "extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>"
   and IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk>
                 \<Longrightarrow> \<exists>U. P,E,hp s' \<turnstile> e' : U \<and> P \<turnstile> U \<le> T"
   and conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> e\<bullet>F{D}:=e\<^isub>2 : T"
   and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have void: "T = Void" by blast
  -- "We distinguish if @{term e} has type @{term NT} or a Class type"
  { assume "P,E,hp s \<turnstile> e : NT"
    hence "P,E,hp s' \<turnstile> e' : NT" using IH[OF conf _ tconf] by fastforce
    moreover obtain T\<^isub>2 where "P,E,hp s \<turnstile> e\<^isub>2 : T\<^isub>2" using wt by auto
    from this red_hext_incr[OF red] have  "P,E,hp s' \<turnstile> e\<^isub>2 : T\<^isub>2"
      by(rule WTrt_hext_mono)
    ultimately have ?case using void by(blast intro!:WTrtFAssNT)
  }
  moreover
  { fix T' C TF T\<^isub>2 fm
    assume wt\<^isub>1: "P,E,hp s \<turnstile> e : T'" and icto: "class_type_of' T' = \<lfloor>C\<rfloor>" and wt\<^isub>2: "P,E,hp s \<turnstile> e\<^isub>2 : T\<^isub>2"
      and has: "P \<turnstile> C has F:TF (fm) in D" and sub: "P \<turnstile> T\<^isub>2 \<le> TF"
    obtain U where wt\<^isub>1': "P,E,hp s' \<turnstile> e' : U" and UsubC: "P \<turnstile> U \<le> T'"
      using IH[OF conf wt\<^isub>1 tconf] by blast
    have wt\<^isub>2': "P,E,hp s' \<turnstile> e\<^isub>2 : T\<^isub>2"
      by(rule WTrt_hext_mono[OF wt\<^isub>2 red_hext_incr[OF red]])
    -- "Is @{term U} the null type or a class type?"
    have ?case
    proof(cases "U = NT")
      case True
      with wt\<^isub>1' wt\<^isub>2' void show ?thesis by(blast intro!:WTrtFAssNT)
    next
      case False
      with icto UsubC obtain C' where icto': "class_type_of' U = \<lfloor>C'\<rfloor>"
        and "subclass": "P \<turnstile> C' \<preceq>\<^sup>* C" by(rule widen_is_class_type_of)
      have "P \<turnstile> C' has F:TF (fm) in D" by(rule has_field_mono[OF has "subclass"])
      with wt\<^isub>1' show ?thesis using wt\<^isub>2' sub void icto' by(blast intro:WTrtFAss)
    qed }
  ultimately show ?case using wt by blast
next
  case (FAssRed2 e\<^isub>2 s ta e\<^isub>2' s' v F D T E)
  have red: "extTA,P,t \<turnstile> \<langle>e\<^isub>2,s\<rangle> -ta\<rightarrow> \<langle>e\<^isub>2',s'\<rangle>"
   and IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e\<^isub>2 : T; P,hp s \<turnstile> t \<surd>t\<rbrakk>
                 \<Longrightarrow> \<exists>U. P,E,hp s' \<turnstile> e\<^isub>2' : U \<and> P \<turnstile> U \<le> T"
   and conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> Val v\<bullet>F{D}:=e\<^isub>2 : T" 
   and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt have [simp]: "T = Void" by auto
  from wt show ?case
  proof (rule WTrt_elim_cases)
    fix U C TF T\<^isub>2 fm
    assume wt\<^isub>1: "P,E,hp s \<turnstile> Val v : U"
      and icto: "class_type_of' U = \<lfloor>C\<rfloor>"
      and has: "P \<turnstile> C has F:TF (fm) in D"
      and wt\<^isub>2: "P,E,hp s \<turnstile> e\<^isub>2 : T\<^isub>2" and TsubTF: "P \<turnstile> T\<^isub>2 \<le> TF"
    have wt\<^isub>1': "P,E,hp s' \<turnstile> Val v : U"
      by(rule WTrt_hext_mono[OF wt\<^isub>1 red_hext_incr[OF red]])
    obtain T\<^isub>2' where wt\<^isub>2': "P,E,hp s' \<turnstile> e\<^isub>2' : T\<^isub>2'" and T'subT: "P \<turnstile> T\<^isub>2' \<le> T\<^isub>2"
      using IH[OF conf wt\<^isub>2 tconf] by blast
    have "P,E,hp s' \<turnstile> Val v\<bullet>F{D}:=e\<^isub>2' : Void"
      by(rule WTrtFAss[OF wt\<^isub>1' icto has wt\<^isub>2' widen_trans[OF T'subT TsubTF]])
    thus ?case by auto
  next
    fix T\<^isub>2 assume null: "P,E,hp s \<turnstile> Val v : NT" and wt\<^isub>2: "P,E,hp s \<turnstile> e\<^isub>2 : T\<^isub>2"
    from null have "v = Null" by simp
    moreover
    obtain T\<^isub>2' where "P,E,hp s' \<turnstile> e\<^isub>2' : T\<^isub>2' \<and> P \<turnstile> T\<^isub>2' \<le> T\<^isub>2"
      using IH[OF conf wt\<^isub>2 tconf] by blast
    ultimately show ?thesis by(fastforce intro:WTrtFAssNT)
  qed
next
  case RedFAss thus ?case by(auto simp del:fun_upd_apply)
next
  case RedFAssNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (CallObj e s ta e' s' M es T E)
  have red: "extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>"
   and IH: "\<And>E T. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk>
                 \<Longrightarrow> \<exists>U. P,E,hp s' \<turnstile> e' : U \<and> P \<turnstile> U \<le> T"
   and conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> e\<bullet>M(es) : T"
   and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  -- "We distinguish if @{term e} has type @{term NT} or a Class type"
  from wt show ?case
  proof(rule WTrt_elim_cases)
    fix T' C Ts meth D Us
    assume wte: "P,E,hp s \<turnstile> e : T'" and icto: "class_type_of' T' = \<lfloor>C\<rfloor>"
      and method: "P \<turnstile> C sees M:Ts\<rightarrow>T = meth in D"
      and wtes: "P,E,hp s \<turnstile> es [:] Us" and subs: "P \<turnstile> Us [\<le>] Ts"
    obtain U where wte': "P,E,hp s' \<turnstile> e' : U" and UsubC: "P \<turnstile> U \<le> T'"
      using IH[OF conf wte tconf] by blast
    show ?thesis
    proof(cases "U = NT")
      case True
      moreover have "P,E,hp s' \<turnstile> es [:] Us"
	by(rule WTrts_hext_mono[OF wtes red_hext_incr[OF red]])
      ultimately show ?thesis using wte' by(blast intro!:WTrtCallNT)
    next
      case False
      with icto UsubC obtain C'
        where icto': "class_type_of' U = \<lfloor>C'\<rfloor>" and "subclass": "P \<turnstile> C' \<preceq>\<^sup>* C"
        by(rule widen_is_class_type_of)

      obtain Ts' T' meth' D'
	where method': "P \<turnstile> C' sees M:Ts'\<rightarrow>T' = meth' in D'"
	and subs': "P \<turnstile> Ts [\<le>] Ts'" and sub': "P \<turnstile> T' \<le> T"
	using Call_lemma[OF method "subclass" wf] by fast
      have wtes': "P,E,hp s' \<turnstile> es [:] Us"
	by(rule WTrts_hext_mono[OF wtes red_hext_incr[OF red]])
      show ?thesis using wtes' wte' icto' subs method' subs' sub' by(blast intro:widens_trans)
    qed
  next
    fix Ts
    assume "P,E,hp s \<turnstile> e:NT"
    hence "P,E,hp s' \<turnstile> e' : NT" using IH[OF conf _ tconf] by fastforce
    moreover
    fix Ts assume wtes: "P,E,hp s \<turnstile> es [:] Ts"
    have "P,E,hp s' \<turnstile> es [:] Ts"
      by(rule WTrts_hext_mono[OF wtes red_hext_incr[OF red]])
    ultimately show ?thesis by(blast intro!:WTrtCallNT)
  qed
next
  case (CallParams es s ta es' s' v M T E)
  have reds: "extTA,P,t \<turnstile> \<langle>es,s\<rangle> [-ta\<rightarrow>] \<langle>es',s'\<rangle>"
   and IH: "\<And>Ts E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> es [:] Ts; P,hp s \<turnstile> t \<surd>t\<rbrakk>
           \<Longrightarrow> \<exists>Ts'. P,E,hp s' \<turnstile> es' [:] Ts' \<and> P \<turnstile> Ts' [\<le>] Ts"
   and conf: "E \<turnstile> s \<surd>" and wt: "P,E,hp s \<turnstile> Val v\<bullet>M(es) : T" 
   and tconf: "P,hp s \<turnstile> t \<surd>t" by fact+
  from wt show ?case
  proof (rule WTrt_elim_cases)
    fix U C Ts meth D Us
    assume wte: "P,E,hp s \<turnstile> Val v : U" and icto: "class_type_of' U = \<lfloor>C\<rfloor>"
      and "P \<turnstile> C sees M:Ts\<rightarrow>T = meth in D"
      and wtes: "P,E,hp s \<turnstile> es [:] Us" and "P \<turnstile> Us [\<le>] Ts"
    moreover have "P,E,hp s' \<turnstile> Val v : U"
      by(rule WTrt_hext_mono[OF wte reds_hext_incr[OF reds]])
    moreover obtain Us' where "P,E,hp s' \<turnstile> es' [:] Us'" "P \<turnstile> Us' [\<le>] Us"
      using IH[OF conf wtes tconf] by blast
    ultimately show ?thesis by(fastforce intro:WTrtCall widens_trans)
  next
    fix Us
    assume null: "P,E,hp s \<turnstile> Val v : NT" and wtes: "P,E,hp s \<turnstile> es [:] Us"
    from null have "v = Null" by simp
    moreover
    obtain Us' where "P,E,hp s' \<turnstile> es' [:] Us' \<and> P \<turnstile> Us' [\<le>] Us"
      using IH[OF conf wtes tconf] by blast
    ultimately show ?thesis by(fastforce intro:WTrtCallNT)
  qed
next
  case (RedCall s a U M Ts T pns body D vs T' E)
  have hp: "typeof_addr (hp s) a = \<lfloor>U\<rfloor>"
    and method: "P \<turnstile> class_type_of U sees M: Ts\<rightarrow>T = \<lfloor>(pns,body)\<rfloor> in D"
    and wt: "P,E,hp s \<turnstile> addr a\<bullet>M(map Val vs) : T'" by fact+
  obtain Ts' where wtes: "P,E,hp s \<turnstile> map Val vs [:] Ts'"
    and subs: "P \<turnstile> Ts' [\<le>] Ts" and T'isT: "T' = T"
    using wt method hp wf by(auto 4 3 dest: sees_method_fun)
  from wtes subs have length_vs: "length vs = length Ts"
    by(auto simp add: WTrts_conv_list_all2 dest!: list_all2_lengthD)
  have UsubD: "P \<turnstile> ty_of_htype U \<le> Class (class_type_of U)"
    by(cases U)(simp_all add: widen_array_object)
  from sees_wf_mdecl[OF wf method] obtain T''
    where wtabody: "P,[this#pns [\<mapsto>] Class D#Ts] \<turnstile> body :: T''"
    and T''subT: "P \<turnstile> T'' \<le> T" and length_pns: "length pns = length Ts"
    by(fastforce simp:wf_mdecl_def simp del:map_upds_twist)
  from wtabody have "P,empty(this#pns [\<mapsto>] Class D#Ts),hp s \<turnstile> body : T''"
    by(rule WT_implies_WTrt)
  hence "P,E(this#pns [\<mapsto>] Class D#Ts),hp s \<turnstile> body : T''"
    by(rule WTrt_env_mono) simp
  hence "P,E,hp s \<turnstile> blocks (this#pns) (Class D#Ts) (Addr a#vs) body : T''"
    using wtes subs hp sees_method_decl_above[OF method] length_vs length_pns UsubD
    by(auto simp add:wt_blocks rel_list_all2_Cons2 intro: widen_trans)
  with T''subT T'isT show ?case by blast
next
  case (RedCallExternal s a U M Ts T' D vs ta va h' ta' e' s')
  from `P,t \<turnstile> \<langle>a\<bullet>M(vs),hp s\<rangle> -ta\<rightarrow>ext \<langle>va,h'\<rangle>` have "hp s \<unlhd> h'" by(rule red_external_hext)
  with `P,E,hp s \<turnstile> addr a\<bullet>M(map Val vs) : T`
  have "P,E,h' \<turnstile> addr a\<bullet>M(map Val vs) : T" by(rule WTrt_hext_mono)
  moreover from `typeof_addr (hp s) a = \<lfloor>U\<rfloor>` `P \<turnstile> class_type_of U sees M: Ts\<rightarrow>T' = Native in D` `P,E,hp s \<turnstile> addr a\<bullet>M(map Val vs) : T`
  have "P,hp s \<turnstile> a\<bullet>M(vs) : T'"
    by(fastforce simp add: external_WT'_iff dest: sees_method_fun)
  ultimately show ?case using RedCallExternal
    by(auto 4 3 intro: red_external_conf_extRet[OF wf] intro!: wt_external_call simp add: sconf_def dest: sees_method_fun[where C="class_type_of U"])
next
  case RedCallNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (BlockRed e h x V vo ta e' h' x' T T' E)
  note IH = `\<And>T E. \<lbrakk>E \<turnstile> (h, x(V := vo)) \<surd>; P,E,hp (h, x(V := vo)) \<turnstile> e : T; P,hp (h, x(V := vo)) \<turnstile> t \<surd>t\<rbrakk>
             \<Longrightarrow> \<exists>T'. P,E,hp (h', x') \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T`[simplified]
  from `P,E,hp (h, x) \<turnstile> {V:T=vo; e} : T'` have "P,E(V\<mapsto>T),h \<turnstile> e : T'" by(cases vo, auto)
  moreover from `E \<turnstile> (h, x) \<surd>` `P,E,hp (h, x) \<turnstile> {V:T=vo; e} : T'`
  have "(E(V \<mapsto> T)) \<turnstile> (h, x(V := vo)) \<surd>"
    by(cases vo)(simp add: lconf_def sconf_def,auto simp add: sconf_def conf_def intro: lconf_upd2)
  ultimately obtain T'' where wt': "P,E(V\<mapsto>T),h' \<turnstile> e' : T''" "P \<turnstile> T'' \<le> T'" using `P,hp (h, x) \<turnstile> t \<surd>t`
    by(auto dest: IH)
  { fix v
    assume vo: "x' V = \<lfloor>v\<rfloor>"
    from `(E(V \<mapsto> T)) \<turnstile> (h, x(V := vo)) \<surd>` `extTA,P,t \<turnstile> \<langle>e,(h, x(V := vo))\<rangle> -ta\<rightarrow> \<langle>e',(h', x')\<rangle>` `P,E(V\<mapsto>T),h \<turnstile> e : T'`
    have "P,h' \<turnstile> x' (:\<le>) (E(V \<mapsto> T))" by(auto simp add: sconf_def dest: red_preserves_lconf)
    with vo have "\<exists>T'. typeof\<^bsub>h'\<^esub> v = \<lfloor>T'\<rfloor> \<and> P \<turnstile> T' \<le> T" by(fastforce simp add: sconf_def lconf_def conf_def)
    then obtain T' where "typeof\<^bsub>h'\<^esub> v = \<lfloor>T'\<rfloor>" "P \<turnstile> T' \<le> T" by blast
    hence ?case using wt' vo by(auto) }
  moreover
  { assume "x' V = None" with wt' have ?case by(auto) }
  ultimately show ?case by blast
next 
  case RedBlock thus ?case by auto
next
  case (SynchronizedRed1 o' s ta o'' s' e T E)
  have red: "extTA,P,t \<turnstile> \<langle>o',s\<rangle> -ta\<rightarrow> \<langle>o'',s'\<rangle>" by fact
  have IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> o' : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> o'' : T' \<and> P \<turnstile> T' \<le> T" by fact
  have conf: "E \<turnstile> s \<surd>" by fact
  have wt: "P,E,hp s \<turnstile> sync(o') e : T" by fact+
  thus ?case
  proof(rule WTrt_elim_cases)
    fix To
    assume wto: "P,E,hp s \<turnstile> o' : To"
      and refT: "is_refT To" 
      and wte: "P,E,hp s \<turnstile> e : T"
    from IH[OF conf wto `P,hp s \<turnstile> t \<surd>t`] obtain To' where "P,E,hp s' \<turnstile> o'' : To'" and sub: "P \<turnstile> To' \<le> To" by auto
    moreover have "P,E,hp s' \<turnstile> e : T"
      by(rule WTrt_hext_mono[OF wte red_hext_incr[OF red]])
    moreover have "is_refT To'" using refT sub by(auto intro: widen_refT)
    ultimately show ?thesis by(auto)
  qed
next
  case SynchronizedNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case LockSynchronized thus ?case by(auto)
next
  case (SynchronizedRed2 e s ta e' s' a T E)
  have red: "extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>" by fact
  have IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T" by fact
  have conf: "E \<turnstile> s \<surd>" by fact
  have wt: "P,E,hp s \<turnstile> insync(a) e : T" by fact
  thus ?case
  proof(rule WTrt_elim_cases)
    fix Ta
    assume "P,E,hp s \<turnstile> e : T"
      and hpa: "typeof_addr (hp s) a = \<lfloor>Ta\<rfloor>"
    from `P,E,hp s \<turnstile> e : T` conf `P,hp s \<turnstile> t \<surd>t` obtain T'
      where "P,E,hp s' \<turnstile> e' : T'" "P \<turnstile> T' \<le> T" by(blast dest: IH)
    moreover from red have hext: "hp s \<unlhd> hp s'" by(auto dest: red_hext_incr)
    with hpa have "P,E,hp s' \<turnstile> addr a : ty_of_htype Ta"
      by(auto intro: typeof_addr_hext_mono)
    ultimately show ?thesis by auto
  qed
next
  case UnlockSynchronized thus ?case by(auto)
next
  case SeqRed thus ?case
    apply(auto)
    apply(drule WTrt_hext_mono[OF _ red_hext_incr], assumption)
    by auto
next
  case (CondRed b s ta b' s' e1 e2 T E)
  have red: "extTA,P,t \<turnstile> \<langle>b,s\<rangle> -ta\<rightarrow> \<langle>b',s'\<rangle>" by fact
  have IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> b : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> b' : T' \<and> P \<turnstile> T' \<le> T" by fact
  have conf: "E \<turnstile> s \<surd>" by fact
  have wt: "P,E,hp s \<turnstile> if (b) e1 else e2 : T" by fact
  thus ?case
  proof(rule WTrt_elim_cases)
    fix T1 T2
    assume wtb: "P,E,hp s \<turnstile> b : Boolean"
      and wte1: "P,E,hp s \<turnstile> e1 : T1"
      and wte2: "P,E,hp s \<turnstile> e2 : T2"
      and lub: "P \<turnstile> lub(T1, T2) = T"
    from IH[OF conf wtb `P,hp s \<turnstile> t \<surd>t`] have "P,E,hp s' \<turnstile> b' : Boolean" by(auto)
    moreover have "P,E,hp s' \<turnstile> e1 : T1"
      by(rule WTrt_hext_mono[OF wte1 red_hext_incr[OF red]])
    moreover have "P,E,hp s' \<turnstile> e2 : T2"
      by(rule WTrt_hext_mono[OF wte2 red_hext_incr[OF red]])
    ultimately show ?thesis using lub by auto
  qed
next
  case (ThrowRed e s ta e' s' T E)
  have IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T" by fact
  have conf: "E \<turnstile> s \<surd>" by fact
  have wt: "P,E,hp s \<turnstile> throw e : T" by fact
  then obtain T'
    where wte: "P,E,hp s \<turnstile> e : T'" 
    and nobject: "P \<turnstile> T' \<le> Class Throwable" by auto
  from IH[OF conf wte `P,hp s \<turnstile> t \<surd>t`] obtain T'' 
    where wte': "P,E,hp s' \<turnstile> e' : T''"
    and PT'T'': "P \<turnstile> T'' \<le> T'" by blast
  from nobject PT'T'' have "P \<turnstile> T'' \<le> Class Throwable"
    by(auto simp add: widen_Class)(erule notE, rule rtranclp_trans)
  hence "P,E,hp s' \<turnstile> throw e' : T" using wte' PT'T''
    by -(erule WTrtThrow)
  thus ?case by(auto)
next
  case RedThrowNull thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case (TryRed e s ta e' s' C V e2 T E)
  have red: "extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>" by fact
  have IH: "\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T" by fact
  have conf: "E \<turnstile> s \<surd>" by fact
  have wt: "P,E,hp s \<turnstile> try e catch(C V) e2 : T" by fact
  thus ?case
  proof(rule WTrt_elim_cases)
    fix T1
    assume wte: "P,E,hp s \<turnstile> e : T1"
      and wte2: "P,E(V \<mapsto> Class C),hp s \<turnstile> e2 : T"
      and sub: "P \<turnstile> T1 \<le> T"
    from IH[OF conf wte `P,hp s \<turnstile> t \<surd>t`] obtain T1' where "P,E,hp s' \<turnstile> e' : T1'" and "P \<turnstile> T1' \<le> T1" by(auto)
    moreover have "P,E(V \<mapsto> Class C),hp s' \<turnstile> e2 : T"
      by(rule WTrt_hext_mono[OF wte2 red_hext_incr[OF red]])
    ultimately show ?thesis using sub by(auto elim: widen_trans)
  qed
next
  case RedTryFail thus ?case unfolding sconf_def
    by(fastforce simp add: xcpt_subcls_Throwable[OF _ wf])
next
  case RedSeq thus ?case by auto
next
  case RedCondT thus ?case by(auto dest: is_lub_upper)
next
  case RedCondF thus ?case by(auto dest: is_lub_upper)
next
  case RedWhile thus ?case by(fastforce) 
next
  case RedTry thus ?case by auto
next
  case RedTryCatch thus ?case by(fastforce)
next
  case (ListRed1 e s ta e' s' es Ts E)
  note IH = `\<And>T E. \<lbrakk>E \<turnstile> s \<surd>; P,E,hp s \<turnstile> e : T; P,hp s \<turnstile> t \<surd>t\<rbrakk> \<Longrightarrow> \<exists>T'. P,E,hp s' \<turnstile> e' : T' \<and> P \<turnstile> T' \<le> T`
  from `P,E,hp s \<turnstile> e # es [:] Ts` obtain T Ts' where "Ts = T # Ts'" "P,E,hp s \<turnstile> e : T" "P,E,hp s \<turnstile> es [:] Ts'" by auto
  with IH[of E T] `E \<turnstile> s \<surd>` WTrts_hext_mono[OF `P,E,hp s \<turnstile> es [:] Ts'` red_hext_incr[OF `extTA,P,t \<turnstile> \<langle>e,s\<rangle> -ta\<rightarrow> \<langle>e',s'\<rangle>`]]
  show ?case using `P,hp s \<turnstile> t \<surd>t` by(auto simp add: list_all2_Cons2 intro: widens_refl)
next
  case ListRed2 thus ?case
    by(fastforce dest: hext_typeof_mono[OF reds_hext_incr])
qed(fastforce)+

end
