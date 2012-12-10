(*  Title:      JinjaThreads/Framework/FWProgress.thy
    Author:     Andreas Lochbihler
*)

header {* \isaheader{Progress theorem for the multithreaded semantics} *}

theory FWProgress
imports
  FWDeadlock
begin

locale progress = multithreaded final r convert_RA 
  for final :: "'x \<Rightarrow> bool"
  and r :: "('l,'t,'x,'m,'w,'o) semantics" ("_ \<turnstile> _ -_\<rightarrow> _" [50,0,0,50] 80)
  and convert_RA :: "'l released_locks \<Rightarrow> 'o list"
  +
  fixes wf_state :: "('l,'t,'x,'m,'w) state set"
  assumes invariant3p_wf_state: "invariant3p redT wf_state"
  and wf_stateD: "s \<in> wf_state \<Longrightarrow> lock_thread_ok (locks s) (thr s) \<and> wset_final_ok (wset s) (thr s)"
  and wf_red:
  "\<lbrakk> s \<in> wf_state; thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>;
     t \<turnstile> (x, shr s) -ta\<rightarrow> (x', m'); \<not> waiting (wset s t) \<rbrakk>
  \<Longrightarrow> \<exists>ta' x' m'. t \<turnstile> (x, shr s) -ta'\<rightarrow> (x', m') \<and> (actions_ok s t ta' \<or> actions_ok' s t ta' \<and> actions_subset ta' ta)"

  and red_wait_set_not_final:
  "\<lbrakk> s \<in> wf_state; thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>; 
    t \<turnstile> (x, shr s) -ta\<rightarrow> (x', m'); \<not> waiting (wset s t); Suspend w \<in> set \<lbrace>ta\<rbrace>\<^bsub>w\<^esub> \<rbrakk> 
  \<Longrightarrow> \<not> final x'"

  and wf_progress:
  "\<lbrakk> s \<in> wf_state; thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>; \<not> final x \<rbrakk>
  \<Longrightarrow> \<exists>ta x' m'. t \<turnstile> \<langle>x, shr s\<rangle> -ta\<rightarrow> \<langle>x', m'\<rangle>"

  and ta_Wakeup_no_join_no_lock_no_interrupt: 
  "\<lbrakk> s \<in> wf_state; thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>; t \<turnstile> xm -ta\<rightarrow> xm'; Notified \<in> set \<lbrace>ta\<rbrace>\<^bsub>w\<^esub> \<or> WokenUp \<in> set \<lbrace>ta\<rbrace>\<^bsub>w\<^esub> \<rbrakk> 
  \<Longrightarrow> collect_waits ta = {}"

  and ta_satisfiable:
  "\<lbrakk> s \<in> wf_state; thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>; t \<turnstile> \<langle>x, shr s\<rangle> -ta\<rightarrow> \<langle>x', m'\<rangle> \<rbrakk>
  \<Longrightarrow> \<exists>s'. actions_ok s' t ta"
begin

lemma wf_redE:
  assumes "s \<in> wf_state" "thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>"
  and "t \<turnstile> \<langle>x, shr s\<rangle> -ta\<rightarrow> \<langle>x'', m''\<rangle>" "\<not> waiting (wset s t)"
  obtains ta' x' m'
  where "t \<turnstile> \<langle>x, shr s\<rangle> -ta'\<rightarrow> \<langle>x', m'\<rangle>" "actions_ok' s t ta'" "actions_subset ta' ta"
  | ta' x' m' where "t \<turnstile> \<langle>x, shr s\<rangle> -ta'\<rightarrow> \<langle>x', m'\<rangle>" "actions_ok s t ta'"
using wf_red[OF assms] by blast

lemma wf_progressE:
  assumes "s \<in> wf_state"
  and "thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>" "\<not> final x"
  obtains ta x' m' where "t \<turnstile> \<langle>x, shr s\<rangle> -ta\<rightarrow> \<langle>x', m'\<rangle>"
using assms
by(blast dest: wf_progress)

lemma wf_progress_satisfiable:
  "\<lbrakk> s \<in> wf_state; thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>; \<not> final x \<rbrakk> 
  \<Longrightarrow> \<exists>ta x' m' s'. t \<turnstile> \<langle>x, shr s\<rangle> -ta\<rightarrow> \<langle>x', m'\<rangle> \<and> actions_ok s' t ta"
apply(frule (2) wf_progress)
apply(blast dest: ta_satisfiable)
done

theorem redT_progress:
  assumes wfs: "s \<in> wf_state" 
  and ndead: "\<not> deadlock s"
  shows "\<exists>t' ta' s'. s -t'\<triangleright>ta'\<rightarrow> s'"
proof -
  from wfs have lok: "lock_thread_ok (locks s) (thr s)"
    and wfin: "wset_final_ok (wset s) (thr s)"
    by(auto dest: wf_stateD)
  from ndead
  have "\<exists>t x ln l. thr s t = \<lfloor>(x, ln)\<rfloor> \<and> 
          (wset s t = None \<and> ln = no_wait_locks \<and> \<not> final x \<and> (\<exists>LT. t \<turnstile> \<langle>x, shr s\<rangle> LT \<wrong> \<and> (\<forall>lt \<in> LT. \<not> must_wait s t lt (dom (thr s)))) \<or>
           \<not> waiting (wset s t) \<and> ln\<^sub>f l > 0 \<and> (\<forall>l. ln\<^sub>f l > 0 \<longrightarrow> may_lock ((locks s)\<^sub>f l) t) \<or>
          (\<exists>w. ln = no_wait_locks \<and> wset s t = \<lfloor>PostWS w\<rfloor>))"
    by(rule contrapos_np)(blast intro!: all_waiting_implies_deadlock[OF lok] intro: must_syncI[OF wf_progress_satisfiable[OF wfs]])
  then obtain t x ln l
    where tst: "thr s t = \<lfloor>(x, ln)\<rfloor>"
    and a: "wset s t = None \<and> ln = no_wait_locks \<and> \<not> final x \<and> 
              (\<exists>LT. t \<turnstile> \<langle>x, shr s\<rangle> LT \<wrong> \<and> (\<forall>lt \<in> LT. \<not> must_wait s t lt (dom (thr s)))) \<or>
            \<not> waiting (wset s t) \<and> ln\<^sub>f l > 0 \<and> (\<forall>l. ln\<^sub>f l > 0 \<longrightarrow> may_lock ((locks s)\<^sub>f l) t) \<or>
            (\<exists>w. ln = no_wait_locks \<and> wset s t = \<lfloor>PostWS w\<rfloor>)"
    by blast
  from a have cases[case_names normal acquire wakeup]:
    "\<And>thesis. 
        \<lbrakk> \<And>LT. \<lbrakk> wset s t = None; ln = no_wait_locks; \<not> final x; t \<turnstile> \<langle>x, shr s\<rangle> LT \<wrong>; 
                 \<And>lt. lt \<in> LT \<Longrightarrow> \<not> must_wait s t lt (dom (thr s)) \<rbrakk> \<Longrightarrow> thesis;
          \<lbrakk> \<not> waiting (wset s t); ln\<^sub>f l > 0; \<And>l. ln\<^sub>f l > 0 \<Longrightarrow> may_lock ((locks s)\<^sub>f l) t \<rbrakk> \<Longrightarrow> thesis;
          \<And>w. \<lbrakk> ln = no_wait_locks; wset s t = \<lfloor>PostWS w\<rfloor> \<rbrakk> \<Longrightarrow> thesis \<rbrakk> \<Longrightarrow> thesis"
    by auto
  show ?thesis
  proof(cases rule: cases)
    case (normal LT)
    note [simp] = `ln = no_wait_locks` 
      and nfine' = `\<not> final x`
      and cl' = `t \<turnstile> \<langle>x, shr s\<rangle> LT \<wrong>` 
      and mw = `\<And>lt. lt\<in>LT \<Longrightarrow> \<not> must_wait s t lt (dom (thr s))`
    from tst nfine' obtain x'' m'' ta'
      where red: "t \<turnstile> \<langle>x, shr s\<rangle> -ta'\<rightarrow> \<langle>x'', m''\<rangle>"
      by(auto intro: wf_progressE[OF wfs])
    from cl'
    have "\<exists>ta''' x''' m'''. t \<turnstile> \<langle>x, shr s\<rangle> -ta'''\<rightarrow> \<langle>x''', m'''\<rangle> \<and> 
            LT = collect_waits ta'''"
      by (fastforce elim!: can_syncE)
    then obtain ta''' x''' m'''
      where red'': "t \<turnstile> \<langle>x, shr s\<rangle> -ta'''\<rightarrow> \<langle>x''', m'''\<rangle>"
      and L: "LT = collect_waits ta'''"
      by blast
    from `wset s t = None` have "\<not> waiting (wset s t)" by(simp add: not_waiting_iff)
    with tst obtain ta'' x'' m''
      where red': "t \<turnstile> \<langle>x, shr s\<rangle> -ta''\<rightarrow> \<langle>x'', m''\<rangle>"
      and aok': "actions_ok s t ta'' \<or> actions_ok' s t ta'' \<and> actions_subset ta'' ta'''"
      by -(rule wf_redE[OF wfs _ red''], auto)
    from aok' have "actions_ok s t ta''"
    proof
      assume "actions_ok' s t ta'' \<and> actions_subset ta'' ta'''"
      hence aok': "actions_ok' s t ta''" and aos: "actions_subset ta'' ta'''" by simp_all

      { fix l
        assume "Inl l \<in> LT"
        { fix t'
          assume "t \<noteq> t'"
          have "\<not> has_lock ((locks s)\<^sub>f l) t'"
          proof
            assume "has_lock ((locks s)\<^sub>f l) t'"
            moreover with lok have "thr s t' \<noteq> None" by(auto dest: lock_thread_okD)
            ultimately have "must_wait s t (Inl l) (dom (thr s))" using `t \<noteq> t'` by(auto)
            moreover from `Inl l \<in> LT` have "\<not> must_wait s t (Inl l) (dom (thr s))" by(rule mw)
            ultimately show False by contradiction
          qed }
        hence "may_lock ((locks s)\<^sub>f l) t"
	  by-(rule classical, auto simp add: not_may_lock_conv) }
      note mayl = this
      { fix t'
        assume t'LT: "Inr (Inl t') \<in> LT"
        hence "\<not> not_final_thread s t' \<and> t' \<noteq> t"
        proof(cases "t' = t")
	  case False with t'LT mw L show ?thesis by(fastforce)
        next
	  case True with tst mw[OF t'LT] nfine' L have False
	    by(auto intro!: must_wait.intros simp add: not_final_thread_iff)
	  thus ?thesis ..
        qed }
      note mayj = this
      { fix t'
        assume t': "Inr (Inr t') \<in> LT"
        from t' have "\<not> must_wait s t (Inr (Inr t')) (dom (thr s))" by(rule mw)
        hence "t' \<in> interrupts s"
          by(rule contrapos_np)(fastforce intro: all_final_exceptI simp add: not_final_thread_iff) }
      note interrupt = this
      from aos L mayl
      have "\<And>l. l \<in> collect_locks' \<lbrace>ta''\<rbrace>\<^bsub>l\<^esub> \<Longrightarrow> may_lock ((locks s)\<^sub>f l) t" by auto
      with aok' have "lock_ok_las (locks s) t \<lbrace>ta''\<rbrace>\<^bsub>l\<^esub>" by(auto intro: lock_ok_las'_into_lock_on_las)
      moreover
      from mayj aos L
      have "cond_action_oks s t \<lbrace>ta''\<rbrace>\<^bsub>c\<^esub>"
        by(fastforce intro: may_join_cond_action_oks)
      moreover
      from ta_satisfiable[OF wfs tst[simplified] red']
      obtain is' where "interrupt_actions_ok is' \<lbrace>ta''\<rbrace>\<^bsub>i\<^esub>" by auto
      with interrupt aos aok' L have "interrupt_actions_ok (interrupts s) \<lbrace>ta''\<rbrace>\<^bsub>i\<^esub>"
        by(auto 5 2 intro: interrupt_actions_ok'_collect_interrupts_imp_interrupt_actions_ok)
      ultimately show "actions_ok s t ta''" using aok' by auto
    qed
    moreover obtain ws'' where "redT_updWs t (wset s) \<lbrace>ta''\<rbrace>\<^bsub>w\<^esub> ws''"
      using redT_updWs_total[of t "wset s" "\<lbrace>ta''\<rbrace>\<^bsub>w\<^esub>"] ..
    then obtain s' where "redT_upd s t ta'' x'' m'' s'" by fastforce
    ultimately have "s -t\<triangleright>ta''\<rightarrow> s'"
      using red' tst `wset s t = None` by(auto intro: redT_normal)
    thus ?thesis by blast
  next
    case acquire
    hence "may_acquire_all (locks s) t ln" by(auto intro: may_acquire_allI)
    with tst `\<not> waiting (wset s t)` `0 < ln\<^sub>f l`
    show ?thesis by(fastforce intro: redT_acquire)
  next
    case (wakeup w)
    from `wset s t = \<lfloor>PostWS w\<rfloor>`
    have "\<not> waiting (wset s t)" by(simp add: not_waiting_iff)
    from tst wakeup have tst: "thr s t = \<lfloor>(x, no_wait_locks)\<rfloor>" by simp
    from wakeup tst wfin have "\<not> final x" by(auto dest: wset_final_okD)
    from wf_progress[OF wfs tst this]
    obtain ta x' m' where red: "t \<turnstile> \<langle>x, shr s\<rangle> -ta\<rightarrow> \<langle>x', m'\<rangle>" by auto
    from wf_red[OF wfs tst red `\<not> waiting (wset s t)`]
    obtain ta' x'' m'' 
      where red': "t \<turnstile> \<langle>x, shr s\<rangle> -ta'\<rightarrow> \<langle>x'', m''\<rangle>"
      and aok': "actions_ok s t ta' \<or> actions_ok' s t ta' \<and> actions_subset ta' ta" by blast
    from aok' have "actions_ok s t ta'"
    proof
      assume "actions_ok' s t ta' \<and> actions_subset ta' ta"
      hence aok': "actions_ok' s t ta'"
        and subset: "actions_subset ta' ta" by simp_all
      from wakeup aok' have "Notified \<in> set \<lbrace>ta'\<rbrace>\<^bsub>w\<^esub> \<or> WokenUp \<in> set \<lbrace>ta'\<rbrace>\<^bsub>w\<^esub>"
        by(auto simp add: wset_actions_ok_def split: split_if_asm)
      from ta_Wakeup_no_join_no_lock_no_interrupt[OF wfs tst red' this]
      have no_join: "collect_cond_actions \<lbrace>ta'\<rbrace>\<^bsub>c\<^esub> = {}" 
        and no_lock: "collect_locks \<lbrace>ta'\<rbrace>\<^bsub>l\<^esub> = {}" 
        and no_interrupt: "collect_interrupts \<lbrace>ta'\<rbrace>\<^bsub>i\<^esub> = {}" by auto
      from no_lock have no_lock': "collect_locks' \<lbrace>ta'\<rbrace>\<^bsub>l\<^esub> = {}"
        using collect_locks'_subset_collect_locks[of "\<lbrace>ta'\<rbrace>\<^bsub>l\<^esub>"] by auto
      from aok' have "lock_ok_las' (locks s) t \<lbrace>ta'\<rbrace>\<^bsub>l\<^esub>" by auto
      hence "lock_ok_las (locks s) t \<lbrace>ta'\<rbrace>\<^bsub>l\<^esub>"
        by(rule lock_ok_las'_into_lock_on_las)(simp add: no_lock')
      moreover from subset aok' no_join have "cond_action_oks s t \<lbrace>ta'\<rbrace>\<^bsub>c\<^esub>"
        by(auto intro: may_join_cond_action_oks)
      moreover from ta_satisfiable[OF wfs tst[simplified] red']
      obtain is' where "interrupt_actions_ok is' \<lbrace>ta'\<rbrace>\<^bsub>i\<^esub>" by auto
      with aok' no_interrupt have "interrupt_actions_ok (interrupts s) \<lbrace>ta'\<rbrace>\<^bsub>i\<^esub>"
        by(auto intro: interrupt_actions_ok'_collect_interrupts_imp_interrupt_actions_ok)
      ultimately show "actions_ok s t ta'" using aok' by auto
    qed
    moreover obtain ws'' where "redT_updWs t (wset s) \<lbrace>ta'\<rbrace>\<^bsub>w\<^esub> ws''"
      using redT_updWs_total[of t "wset s" "\<lbrace>ta'\<rbrace>\<^bsub>w\<^esub>"] ..
    then obtain s' where "redT_upd s t ta' x'' m'' s'" by fastforce
    ultimately have "s -t\<triangleright>ta'\<rightarrow> s'" using tst red' wakeup
      by(auto intro: redT_normal)
    thus ?thesis by blast
  qed
qed

end

end
