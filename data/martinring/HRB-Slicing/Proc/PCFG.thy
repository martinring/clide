header {* \isaheader{Definition of the CFG} *}

theory PCFG imports ProcState begin

definition Main :: "pname"
  where "Main = ''Main''"

datatype label = Label nat | Entry | Exit

subsection{* The CFG for every procedure *}

subsubsection {* Definition of @{text "\<oplus>"} *}

fun label_incr :: "label \<Rightarrow> nat \<Rightarrow> label" ("_ \<oplus> _" 60)
where "(Label l) \<oplus> i = Label (l + i)"
  | "Entry \<oplus> i       = Entry"
  | "Exit \<oplus> i        = Exit"


lemma Exit_label_incr [dest]: "Exit = n \<oplus> i \<Longrightarrow> n = Exit"
  by(cases n,auto)

lemma label_incr_Exit [dest]: "n \<oplus> i = Exit \<Longrightarrow> n = Exit"
  by(cases n,auto)

lemma Entry_label_incr [dest]: "Entry = n \<oplus> i \<Longrightarrow> n = Entry"
  by(cases n,auto)

lemma label_incr_Entry [dest]: "n \<oplus> i = Entry \<Longrightarrow> n = Entry"
  by(cases n,auto)

lemma label_incr_inj:
  "n \<oplus> c = n' \<oplus> c \<Longrightarrow> n = n'"
by(cases n)(cases n',auto)+

lemma label_incr_simp:"n \<oplus> i = m \<oplus> (i + j) \<Longrightarrow> n = m \<oplus> j"
by(cases n,auto,cases m,auto)

lemma label_incr_simp_rev:"m \<oplus> (j + i) = n \<oplus> i \<Longrightarrow> m \<oplus> j = n"
by(cases n,auto,cases m,auto)

lemma label_incr_start_Node_smaller:
  "Label l = n \<oplus> i \<Longrightarrow> n = Label (l - i)"
by(cases n,auto)

lemma label_incr_start_Node_smaller_rev:
  "n \<oplus> i = Label l \<Longrightarrow> n = Label (l - i)"
by(cases n,auto)


lemma label_incr_ge:"Label l = n \<oplus> i \<Longrightarrow> l \<ge> i"
by(cases n) auto

lemma label_incr_0 [dest]:
  "\<lbrakk>Label 0 = n \<oplus> i; i > 0\<rbrakk> \<Longrightarrow> False" 
by(cases n) auto

lemma label_incr_0_rev [dest]:
  "\<lbrakk>n \<oplus> i = Label 0; i > 0\<rbrakk> \<Longrightarrow> False" 
by(cases n) auto

subsubsection {* The edges of the procedure CFG *}

text {* Control flow information in this language is the node, to which we return
  after the calles procedure is finished. *}

datatype p_edge_kind = 
  IEdge "(vname,val,pname \<times> label,pname) edge_kind"
| CEdge "pname \<times> expr list \<times> vname list"


type_synonym p_edge = "(label \<times> p_edge_kind \<times> label)"

inductive Proc_CFG :: "cmd \<Rightarrow> label \<Rightarrow> p_edge_kind \<Rightarrow> label \<Rightarrow> bool"
("_ \<turnstile> _ -_\<rightarrow>\<^isub>p _")
where

  Proc_CFG_Entry_Exit:
  "prog \<turnstile> Entry -IEdge (\<lambda>s. False)\<^isub>\<surd>\<rightarrow>\<^isub>p Exit"

| Proc_CFG_Entry:
  "prog \<turnstile> Entry -IEdge (\<lambda>s. True)\<^isub>\<surd>\<rightarrow>\<^isub>p Label 0"

| Proc_CFG_Skip: 
  "Skip \<turnstile> Label 0 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit"

| Proc_CFG_LAss: 
  "V:=e \<turnstile> Label 0 -IEdge \<Up>(\<lambda>cf. update cf V e)\<rightarrow>\<^isub>p Label 1"

| Proc_CFG_LAssSkip:
  "V:=e \<turnstile> Label 1 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit"

| Proc_CFG_SeqFirst:
  "\<lbrakk>c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p n'; n' \<noteq> Exit\<rbrakk> \<Longrightarrow> c\<^isub>1;;c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'"

| Proc_CFG_SeqConnect: 
  "\<lbrakk>c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p Exit; n \<noteq> Entry\<rbrakk> \<Longrightarrow> c\<^isub>1;;c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p Label #:c\<^isub>1"

| Proc_CFG_SeqSecond: 
  "\<lbrakk>c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'; n \<noteq> Entry\<rbrakk> \<Longrightarrow> c\<^isub>1;;c\<^isub>2 \<turnstile> n \<oplus> #:c\<^isub>1 -et\<rightarrow>\<^isub>p n' \<oplus> #:c\<^isub>1"

| Proc_CFG_CondTrue:
    "if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> Label 0 
  -IEdge (\<lambda>cf. state_check cf b (Some true))\<^isub>\<surd>\<rightarrow>\<^isub>p Label 1"

| Proc_CFG_CondFalse:
    "if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> Label 0 -IEdge (\<lambda>cf. state_check cf b (Some false))\<^isub>\<surd>\<rightarrow>\<^isub>p 
                        Label (#:c\<^isub>1 + 1)"

| Proc_CFG_CondThen:
  "\<lbrakk>c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p n'; n \<noteq> Entry\<rbrakk> \<Longrightarrow> if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> 1 -et\<rightarrow>\<^isub>p n' \<oplus> 1"

| Proc_CFG_CondElse:
  "\<lbrakk>c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'; n \<noteq> Entry\<rbrakk> 
  \<Longrightarrow> if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> (#:c\<^isub>1 + 1) -et\<rightarrow>\<^isub>p n' \<oplus> (#:c\<^isub>1 + 1)"

| Proc_CFG_WhileTrue:
    "while (b) c' \<turnstile> Label 0 -IEdge (\<lambda>cf. state_check cf b (Some true))\<^isub>\<surd>\<rightarrow>\<^isub>p Label 2"

| Proc_CFG_WhileFalse:
    "while (b) c' \<turnstile> Label 0 -IEdge (\<lambda>cf. state_check cf b (Some false))\<^isub>\<surd>\<rightarrow>\<^isub>p Label 1"

| Proc_CFG_WhileFalseSkip:
  "while (b) c' \<turnstile> Label 1 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit"

| Proc_CFG_WhileBody:
  "\<lbrakk>c' \<turnstile> n -et\<rightarrow>\<^isub>p n'; n \<noteq> Entry; n' \<noteq> Exit\<rbrakk> 
  \<Longrightarrow> while (b) c' \<turnstile> n \<oplus> 2 -et\<rightarrow>\<^isub>p n' \<oplus> 2"

| Proc_CFG_WhileBodyExit:
  "\<lbrakk>c' \<turnstile> n -et\<rightarrow>\<^isub>p Exit; n \<noteq> Entry\<rbrakk> \<Longrightarrow> while (b) c' \<turnstile> n \<oplus> 2 -et\<rightarrow>\<^isub>p Label 0"

| Proc_CFG_Call:
  "Call p es rets \<turnstile> Label 0 -CEdge (p,es,rets)\<rightarrow>\<^isub>p Label 1"

| Proc_CFG_CallSkip:
  "Call p es rets \<turnstile> Label 1 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit"


subsubsection{* Some lemmas about the procedure CFG *}

lemma Proc_CFG_Exit_no_sourcenode [dest]:
  "prog \<turnstile> Exit -et\<rightarrow>\<^isub>p n' \<Longrightarrow> False"
by(induct prog n\<equiv>"Exit" et n' rule:Proc_CFG.induct,auto)


lemma Proc_CFG_Entry_no_targetnode [dest]:
  "prog \<turnstile> n -et\<rightarrow>\<^isub>p Entry \<Longrightarrow> False"
by(induct prog n et n'\<equiv>"Entry" rule:Proc_CFG.induct,auto)


lemma Proc_CFG_IEdge_intra_kind:
  "prog \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> intra_kind et"
by(induct prog n x\<equiv>"IEdge et" n' rule:Proc_CFG.induct,auto simp:intra_kind_def)


lemma [dest]:"prog \<turnstile> n -IEdge (Q:r\<hookrightarrow>\<^bsub>p\<^esub>fs)\<rightarrow>\<^isub>p n' \<Longrightarrow> False"
by(fastforce dest:Proc_CFG_IEdge_intra_kind simp:intra_kind_def)

lemma [dest]:"prog \<turnstile> n -IEdge (Q\<hookleftarrow>\<^bsub>p\<^esub>f)\<rightarrow>\<^isub>p n' \<Longrightarrow> False"
by(fastforce dest:Proc_CFG_IEdge_intra_kind simp:intra_kind_def)


lemma Proc_CFG_sourcelabel_less_num_nodes:
  "prog \<turnstile> Label l -et\<rightarrow>\<^isub>p n' \<Longrightarrow> l < #:prog"
proof(induct prog "Label l" et n' arbitrary:l rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 et n' c\<^isub>2 l)
  thus ?case by simp
next
  case (Proc_CFG_SeqConnect c\<^isub>1 et c\<^isub>2 l)
  thus ?case by simp
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n et n' c\<^isub>1 l) 
  note n = `n \<oplus> #:c\<^isub>1 = Label l` 
  note IH = `\<And>l. n = Label l \<Longrightarrow> l < #:c\<^isub>2`
  from n obtain l' where l':"n = Label l'" by(cases n) auto
  from IH[OF this] have "l' < #:c\<^isub>2" .
  with n l' show ?case by simp
next
  case (Proc_CFG_CondThen c\<^isub>1 n et n' b c\<^isub>2 l) 
  note n = `n \<oplus> 1 = Label l`
  note IH = `\<And>l. n = Label l \<Longrightarrow> l < #:c\<^isub>1`
  from n obtain l' where l':"n = Label l'" by(cases n) auto
  from IH[OF this] have "l' < #:c\<^isub>1" .
  with n l' show ?case by simp
next
  case (Proc_CFG_CondElse c\<^isub>2 n et n' b c\<^isub>1 l)
  note n = `n \<oplus> (#:c\<^isub>1 + 1) = Label l`
  note IH = `\<And>l. n = Label l \<Longrightarrow> l < #:c\<^isub>2`
  from n obtain l' where l':"n = Label l'" by(cases n) auto
  from IH[OF this] have "l' < #:c\<^isub>2" .
  with n l' show ?case by simp
next
  case (Proc_CFG_WhileBody c' n et n' b l)
  note n = `n \<oplus> 2 = Label l` 
  note IH = `\<And>l. n = Label l \<Longrightarrow> l < #:c'`
  from n obtain l' where l':"n = Label l'" by(cases n) auto
  from IH[OF this] have "l' < #:c'" .
  with n l' show ?case by simp
next
  case (Proc_CFG_WhileBodyExit c' n et b l)
  note n = `n \<oplus> 2 = Label l` 
  note IH = `\<And>l. n = Label l \<Longrightarrow> l < #:c'`
  from n obtain l' where l':"n = Label l'" by(cases n) auto
  from IH[OF this] have "l' < #:c'" .
  with n l' show ?case by simp
qed (auto simp:num_inner_nodes_gr_0)


lemma Proc_CFG_targetlabel_less_num_nodes:
  "prog \<turnstile> n -et\<rightarrow>\<^isub>p Label l \<Longrightarrow> l < #:prog"
proof(induct prog n et "Label l" arbitrary:l rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n et c\<^isub>2 l)
 thus ?case by simp
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n et n' c\<^isub>1 l)
  note n' = `n' \<oplus> #:c\<^isub>1 = Label l` 
  note IH = `\<And>l. n' = Label l \<Longrightarrow> l < #:c\<^isub>2`
  from n' obtain l' where l':"n' = Label l'" by(cases n') auto
  from IH[OF this] have "l' < #:c\<^isub>2" .
  with n' l' show ?case by simp
next
  case (Proc_CFG_CondThen c\<^isub>1 n et n' b c\<^isub>2 l)
  note n' = `n' \<oplus> 1 = Label l` 
  note IH = `\<And>l. n' = Label l \<Longrightarrow> l < #:c\<^isub>1`
  from n' obtain l' where l':"n' = Label l'" by(cases n') auto
  from IH[OF this] have "l' < #:c\<^isub>1" .
  with n' l' show ?case by simp
next
  case (Proc_CFG_CondElse c\<^isub>2 n et n' b c\<^isub>1 l)
  note n' = `n' \<oplus> (#:c\<^isub>1 + 1) = Label l` 
  note IH = `\<And>l. n' = Label l \<Longrightarrow> l < #:c\<^isub>2`
  from n' obtain l' where l':"n' = Label l'" by(cases n') auto
  from IH[OF this] have "l' < #:c\<^isub>2" .
  with n' l' show ?case by simp
next
  case (Proc_CFG_WhileBody c' n et n' b l)
  note n' = `n' \<oplus> 2 = Label l` 
note IH = `\<And>l. n' = Label l \<Longrightarrow> l < #:c'`
  from n' obtain l' where l':"n' = Label l'" by(cases n') auto
  from IH[OF this] have "l' < #:c'" .
  with n' l' show ?case by simp
qed (auto simp:num_inner_nodes_gr_0)


lemma Proc_CFG_EntryD:
  "prog \<turnstile> Entry -et\<rightarrow>\<^isub>p n' 
  \<Longrightarrow> (n' = Exit \<and> et = IEdge(\<lambda>s. False)\<^isub>\<surd>) \<or> (n' = Label 0 \<and> et = IEdge (\<lambda>s. True)\<^isub>\<surd>)"
by(induct prog n\<equiv>"Entry" et n' rule:Proc_CFG.induct,auto)


lemma Proc_CFG_Exit_edge:
  obtains l et where "prog \<turnstile> Label l -IEdge et\<rightarrow>\<^isub>p Exit" and "l \<le> #:prog"
proof(atomize_elim)
  show "\<exists>l et. prog \<turnstile> Label l -IEdge et\<rightarrow>\<^isub>p Exit \<and> l \<le> #:prog"
  proof(induct prog)
    case Skip
    have "Skip \<turnstile> Label 0 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit" by(rule Proc_CFG_Skip)
    thus ?case by fastforce
  next
    case (LAss V e)
    have "V:=e \<turnstile> Label 1 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit" by(rule Proc_CFG_LAssSkip)
    thus ?case by fastforce
  next
    case (Seq c\<^isub>1 c\<^isub>2)
    from `\<exists>l et. c\<^isub>2 \<turnstile> Label l -IEdge et\<rightarrow>\<^isub>p Exit \<and> l \<le> #:c\<^isub>2`
    obtain l et where "c\<^isub>2 \<turnstile> Label l -IEdge et\<rightarrow>\<^isub>p Exit" and "l \<le> #:c\<^isub>2" by blast
    hence "c\<^isub>1;;c\<^isub>2 \<turnstile> Label l \<oplus> #:c\<^isub>1 -IEdge et\<rightarrow>\<^isub>p Exit \<oplus> #:c\<^isub>1"
      by(fastforce intro:Proc_CFG_SeqSecond)
    with `l \<le> #:c\<^isub>2` show ?case by fastforce
  next
    case (Cond b c\<^isub>1 c\<^isub>2)
    from `\<exists>l et. c\<^isub>1 \<turnstile> Label l -IEdge et\<rightarrow>\<^isub>p Exit \<and> l \<le> #:c\<^isub>1`
    obtain l et where "c\<^isub>1 \<turnstile> Label l -IEdge et\<rightarrow>\<^isub>p Exit" and "l \<le> #:c\<^isub>1" by blast
    hence "if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> Label l \<oplus> 1 -IEdge et\<rightarrow>\<^isub>p Exit \<oplus> 1"
      by(fastforce intro:Proc_CFG_CondThen)
    with `l \<le> #:c\<^isub>1` show ?case by fastforce
  next
    case (While b c')
    have "while (b) c' \<turnstile> Label 1 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit" by(rule Proc_CFG_WhileFalseSkip)
    thus ?case by fastforce
  next
    case (Call p es rets)
    have "Call p es rets \<turnstile> Label 1 -IEdge \<Up>id\<rightarrow>\<^isub>p Exit" by(rule Proc_CFG_CallSkip)
    thus ?case by fastforce
  qed
qed


text {* Lots of lemmas for call edges @{text "\<dots>"} *}

lemma Proc_CFG_Call_Labels:
  "prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n' \<Longrightarrow> \<exists>l. n = Label l \<and> n' = Label (Suc l)"
by(induct prog n et\<equiv>"CEdge (p,es,rets)" n' rule:Proc_CFG.induct,auto)


lemma Proc_CFG_Call_target_0:
  "prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p Label 0 \<Longrightarrow> n = Entry"
by(induct prog n et\<equiv>"CEdge (p,es,rets)" n'\<equiv>"Label 0" rule:Proc_CFG.induct)
  (auto dest:Proc_CFG_Call_Labels)


lemma Proc_CFG_Call_Intra_edge_not_same_source:
  "\<lbrakk>prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; prog \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n''\<rbrakk> \<Longrightarrow> False"
proof(induct prog n "CEdge (p,es,rets)" n' arbitrary:n'' rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n n' c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'` 
    `n' \<noteq> Exit`
  obtain nx where "c\<^isub>1 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG_Entry_Exit Proc_CFG_Entry)
    by(case_tac n)(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n c\<^isub>2)
  from `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit`
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n n' c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n \<oplus> #:c\<^isub>1 -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>2 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'` 
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>2 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
      apply(cases n) apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
     apply(cases n) apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(cases n,auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondThen c\<^isub>1 n n' b c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> 1 -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>1 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(cases n) apply auto apply(case_tac n) apply auto
    apply(cases n) apply auto
    by(case_tac n)(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondElse c\<^isub>2 n n' b c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> #:c\<^isub>1 + 1 -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>2 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>2 \<turnstile> n -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(cases n) apply auto
     apply(case_tac n) apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(cases n,auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBody c' n n' b)
  note IH = `\<And>n''. c' \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `while (b) c' \<turnstile> n \<oplus> 2 -IEdge et\<rightarrow>\<^isub>p n''` `c' \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry` `n' \<noteq> Exit`
  obtain nx where "c' \<turnstile> n -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
      apply(drule label_incr_ge[OF sym]) apply simp
     apply(cases n) apply auto apply(case_tac n) apply auto
    by(cases n,auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBodyExit c' n b)
  from `c' \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit`
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case Proc_CFG_Call
  from `Call p es rets \<turnstile> Label 0 -IEdge et\<rightarrow>\<^isub>p n''`
  show ?case by(fastforce elim:Proc_CFG.cases)
qed


lemma Proc_CFG_Call_Intra_edge_not_same_target:
  "\<lbrakk>prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; prog \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n'\<rbrakk> \<Longrightarrow> False"
proof(induct prog n "CEdge (p,es,rets)" n' arbitrary:n'' rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n n' c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> False`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n'` `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'` 
    `n' \<noteq> Exit`
  have "c\<^isub>1 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n'"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG_Entry dest:Proc_CFG_targetlabel_less_num_nodes) 
    by(case_tac n')(auto dest:Proc_CFG_targetlabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n c\<^isub>2)
  from `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit`
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n n' c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> False`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<oplus> #:c\<^isub>1` `c\<^isub>2 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'` 
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>2 \<turnstile> nx -IEdge et\<rightarrow>\<^isub>p n'"
    apply - apply(erule Proc_CFG.cases,auto)
       apply(fastforce intro:Proc_CFG_Entry_Exit)
      apply(cases n') apply(auto dest:Proc_CFG_targetlabel_less_num_nodes)
     apply(cases n') apply(auto dest:Proc_CFG_Call_target_0)
    apply(cases n') apply(auto dest:Proc_CFG_Call_Labels)
    by(case_tac n') auto
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondThen c\<^isub>1 n n' b c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> False`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<oplus> 1` `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>1 \<turnstile> nx -IEdge et\<rightarrow>\<^isub>p n'"
    apply - apply(erule Proc_CFG.cases,auto)
        apply(cases n') apply(auto intro:Proc_CFG_Entry_Exit)
       apply(cases n') apply(auto dest:Proc_CFG_Call_target_0)
      apply(cases n') apply(auto dest:Proc_CFG_targetlabel_less_num_nodes)
     apply(cases n') apply auto apply(case_tac n') apply auto
    apply(cases n') apply auto
    apply(case_tac n') apply(auto dest:Proc_CFG_targetlabel_less_num_nodes)
    by(case_tac n')(auto dest:Proc_CFG_Call_Labels)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondElse c\<^isub>2 n n' b c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> False`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<oplus> #:c\<^isub>1 + 1` `c\<^isub>2 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>2 \<turnstile> nx -IEdge et\<rightarrow>\<^isub>p n'"
    apply - apply(erule Proc_CFG.cases,auto)
        apply(cases n') apply(auto intro:Proc_CFG_Entry_Exit)
       apply(cases n') apply(auto dest:Proc_CFG_Call_target_0)
      apply(cases n') apply(auto dest:Proc_CFG_Call_target_0)
     apply(cases n') apply auto
      apply(case_tac n') apply(auto dest:Proc_CFG_targetlabel_less_num_nodes)
     apply(case_tac n') apply(auto dest:Proc_CFG_Call_Labels)
    by(cases n',auto,case_tac n',auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBody c' n n' b)
  note IH = `\<And>n''. c' \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> False`
  from `while (b) c' \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p n' \<oplus> 2` `c' \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry` `n' \<noteq> Exit`
  obtain nx where "c' \<turnstile> nx -IEdge et\<rightarrow>\<^isub>p n'"
    apply - apply(erule Proc_CFG.cases,auto)
      apply(cases n') apply(auto dest:Proc_CFG_Call_target_0)
     apply(cases n') apply auto
    by(cases n',auto,case_tac n',auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBodyExit c' n b)
  from `c' \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit`
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case Proc_CFG_Call
  from `Call p es rets \<turnstile> n'' -IEdge et\<rightarrow>\<^isub>p Label 1`
  show ?case by(fastforce elim:Proc_CFG.cases)
qed


lemma Proc_CFG_Call_nodes_eq:
  "\<lbrakk>prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; prog \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''\<rbrakk>
  \<Longrightarrow> n' = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'"
proof(induct prog n "CEdge (p,es,rets)" n' arbitrary:n'' rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n n' c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''
    \<Longrightarrow> n' = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `c\<^isub>1;; c\<^isub>2 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  have "c\<^isub>1 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(fastforce dest:Proc_CFG_Call_Labels)
    by(case_tac n,(fastforce dest:Proc_CFG_sourcelabel_less_num_nodes)+)
  then show ?case by (rule IH)
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n c\<^isub>2)
  from `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p Exit` have False
    by(fastforce dest:Proc_CFG_Call_Labels)
  thus ?case by simp
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n n' c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''
    \<Longrightarrow> n' = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n \<oplus> #:c\<^isub>1 -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''` `n \<noteq> Entry`
  obtain nx where edge:"c\<^isub>2 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx" and nx:"nx \<oplus> #:c\<^isub>1 = n''"
    apply - apply(erule Proc_CFG.cases,auto)
    by(cases n,auto dest:Proc_CFG_sourcelabel_less_num_nodes label_incr_inj)+
  from edge have "n' = nx \<and> p = p' \<and> es = es' \<and> rets = rets'" by (rule IH)
  with nx show ?case by auto
next
  case (Proc_CFG_CondThen c\<^isub>1 n n' b c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''
    \<Longrightarrow> n' = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> 1 -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''`
  obtain nx where "c\<^isub>1 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx \<and> nx \<oplus> 1 = n''"
  proof(rule Proc_CFG.cases)
    fix c\<^isub>2' nx etx nx' bx c\<^isub>1'
    assume "if (b) c\<^isub>1 else c\<^isub>2 = if (bx) c\<^isub>1' else c\<^isub>2'"
      and "n \<oplus> 1 = nx \<oplus> #:c\<^isub>1' + 1" and "nx \<noteq> Entry"
    with `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'` obtain l where "n = Label l" and "l \<ge> #:c\<^isub>1"
      by(cases n,auto,cases nx,auto)
    with `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'` have False
      by(fastforce dest:Proc_CFG_sourcelabel_less_num_nodes)
    thus ?thesis by simp
  qed (auto dest:label_incr_inj)
  then obtain nx where edge:"c\<^isub>1 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx" 
    and nx:"nx \<oplus> 1 = n''" by blast
  from IH[OF edge] nx show ?case by simp
next
  case (Proc_CFG_CondElse c\<^isub>2 n n' b c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''
    \<Longrightarrow> n' = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> #:c\<^isub>1 + 1 -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''`
  obtain nx where "c\<^isub>2 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx \<and> nx \<oplus> #:c\<^isub>1 + 1 = n''"
  proof(rule Proc_CFG.cases)
    fix c\<^isub>1' nx etx nx' bx c\<^isub>2'
    assume ifs:"if (b) c\<^isub>1 else c\<^isub>2 = if (bx) c\<^isub>1' else c\<^isub>2'"
      and "n \<oplus> #:c\<^isub>1 + 1 = nx \<oplus> 1" and "nx \<noteq> Entry"
      and edge:"c\<^isub>1' \<turnstile> nx -etx\<rightarrow>\<^isub>p nx'"
    then obtain l where "nx = Label l" and "l \<ge> #:c\<^isub>1"
      by(cases n,auto,cases nx,auto)
    with edge ifs have False
      by(fastforce dest:Proc_CFG_sourcelabel_less_num_nodes)
    thus ?thesis by simp
  qed (auto dest:label_incr_inj)
  then obtain nx where edge:"c\<^isub>2 \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx"
    and nx:"nx \<oplus> #:c\<^isub>1 + 1 = n''"
    by blast
  from IH[OF edge] nx show ?case by simp
next
  case (Proc_CFG_WhileBody c' n n' b)
  note IH = `\<And>n''. c' \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''
    \<Longrightarrow> n' = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `while (b) c' \<turnstile> n \<oplus> 2 -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''`
  obtain nx where "c' \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx \<and> nx \<oplus> 2 = n''"
    by(rule Proc_CFG.cases,auto dest:label_incr_inj Proc_CFG_Call_Labels)
  then obtain nx where edge:"c' \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx" 
    and nx:"nx \<oplus> 2 = n''" by blast
  from IH[OF edge] nx show ?case by simp
next
  case (Proc_CFG_WhileBodyExit c' n b)
  from `c' \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p Exit` have False
    by(fastforce dest:Proc_CFG_Call_Labels)
  thus ?case by simp
next
  case Proc_CFG_Call
  from `Call p es rets \<turnstile> Label 0 -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''`
  have "p = p' \<and> es = es' \<and> rets = rets' \<and> n'' = Label 1"
    by(auto elim:Proc_CFG.cases)
  then show ?case by simp
qed


lemma Proc_CFG_Call_nodes_eq':
  "\<lbrakk>prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; prog \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'\<rbrakk>
  \<Longrightarrow> n = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'"
proof(induct prog n "CEdge (p,es,rets)" n' arbitrary:n'' rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n n' c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'
    \<Longrightarrow> n = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'` `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  have "c\<^isub>1 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(fastforce dest:Proc_CFG_Call_Labels)
    by(case_tac n',auto dest:Proc_CFG_targetlabel_less_num_nodes Proc_CFG_Call_Labels)
  then show ?case by (rule IH)
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n c\<^isub>2)
  from `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p Exit` have False
    by(fastforce dest:Proc_CFG_Call_Labels)
  thus ?case by simp
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n n' c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'
    \<Longrightarrow> n = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n' \<oplus> #:c\<^isub>1`
  obtain nx where edge:"c\<^isub>2 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'" and nx:"nx \<oplus> #:c\<^isub>1 = n''"
    apply - apply(erule Proc_CFG.cases,auto)
    by(cases n',
       auto dest:Proc_CFG_targetlabel_less_num_nodes Proc_CFG_Call_Labels 
                 label_incr_inj)
  from edge have "n = nx \<and> p = p' \<and> es = es' \<and> rets = rets'" by (rule IH)
  with nx show ?case by auto
next
  case (Proc_CFG_CondThen c\<^isub>1 n n' b c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'
    \<Longrightarrow> n = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n' \<oplus> 1`
  obtain nx where "c\<^isub>1 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p n' \<and> nx \<oplus> 1 = n''"
  proof(cases)
    case (Proc_CFG_CondElse nx nx')
    from `n' \<oplus> 1 = nx' \<oplus> #:c\<^isub>1 + 1`
      `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
    obtain l where "n' = Label l" and "l \<ge> #:c\<^isub>1"
      by(cases n', auto dest:Proc_CFG_Call_Labels,cases nx',auto)
    with `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'` have False
      by(fastforce dest:Proc_CFG_targetlabel_less_num_nodes)
    thus ?thesis by simp
  qed (auto dest:label_incr_inj)
  then obtain nx where edge:"c\<^isub>1 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'" 
    and nx:"nx \<oplus> 1 = n''"
    by blast
  from IH[OF edge] nx show ?case by simp
next
  case (Proc_CFG_CondElse c\<^isub>2 n n' b c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'
    \<Longrightarrow> n = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n' \<oplus> #:c\<^isub>1 + 1`
  obtain nx where "c\<^isub>2 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p n' \<and> nx \<oplus> #:c\<^isub>1 + 1 = n''"
  proof(cases)
    case (Proc_CFG_CondThen nx nx')
    from `n' \<oplus> #:c\<^isub>1 + 1 = nx' \<oplus> 1`
      `c\<^isub>1 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx'`
    obtain l where "nx' = Label l" and "l \<ge> #:c\<^isub>1"
      by(cases n',auto,cases nx',auto dest:Proc_CFG_Call_Labels)
    with `c\<^isub>1 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx'`
    have False by(fastforce dest:Proc_CFG_targetlabel_less_num_nodes)
    thus ?thesis by simp
  qed (auto dest:label_incr_inj)
  then obtain nx where edge:"c\<^isub>2 \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'" 
    and nx:"nx \<oplus> #:c\<^isub>1 + 1 = n''"
    by blast
  from IH[OF edge] nx show ?case by simp
next
  case (Proc_CFG_WhileBody c' n n' b)
  note IH = `\<And>n''. c' \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'
    \<Longrightarrow> n = n'' \<and> p = p' \<and> es = es' \<and> rets = rets'`
  from `while (b) c' \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n' \<oplus> 2`
  obtain nx where edge:"c' \<turnstile> nx -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'" and nx:"nx \<oplus> 2 = n''"
    by(rule Proc_CFG.cases,auto dest:label_incr_inj)
  from IH[OF edge] nx show ?case by simp
next
  case (Proc_CFG_WhileBodyExit c' n b)
  from `c' \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p Exit`
  have False by(fastforce dest:Proc_CFG_Call_Labels)
  thus ?case by simp
next
  case Proc_CFG_Call
  from `Call p es rets \<turnstile> n'' -CEdge (p',es',rets')\<rightarrow>\<^isub>p Label 1`
  have "p = p' \<and> es = es' \<and> rets = rets' \<and> n'' = Label 0"
    by(auto elim:Proc_CFG.cases)
  then show ?case by simp
qed


lemma Proc_CFG_Call_targetnode_no_Call_sourcenode:
  "\<lbrakk>prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; prog \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''\<rbrakk> 
  \<Longrightarrow> False"
proof(induct prog n "CEdge (p,es,rets)" n' arbitrary:n'' rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n n' c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n' -CEdge (p', es', rets')\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `c\<^isub>1;; c\<^isub>2 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  have "c\<^isub>1 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n''"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(fastforce dest:Proc_CFG_Call_Labels)
    by(case_tac n)(auto dest:Proc_CFG_targetlabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n c\<^isub>2)
  from `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p Exit` have False
    by(fastforce dest:Proc_CFG_Call_Labels)
  thus ?case by simp
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n n' c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n' -CEdge (p', es', rets')\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `c\<^isub>1;; c\<^isub>2 \<turnstile> n' \<oplus> #:c\<^isub>1 -CEdge (p', es', rets')\<rightarrow>\<^isub>p n''` `c\<^isub>2 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c\<^isub>2 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
      apply(cases n') apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
     apply(fastforce dest:Proc_CFG_Call_Labels)
    by(cases n',auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondThen c\<^isub>1 n n' b c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n' \<oplus> 1 -CEdge (p', es', rets')\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c\<^isub>1 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(cases n') apply auto apply(case_tac n) apply auto
    apply(cases n') apply auto
    by(case_tac n)(auto dest:Proc_CFG_targetlabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondElse c\<^isub>2 n n' b c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n' \<oplus> #:c\<^isub>1 + 1 -CEdge (p', es', rets')\<rightarrow>\<^isub>p n''` 
    `c\<^isub>2 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c\<^isub>2 \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(cases n') apply auto
     apply(case_tac n) apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(cases n',auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBody c' n n' b)
  note IH = `\<And>n''. c' \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'' \<Longrightarrow> False`
  from `while (b) c' \<turnstile> n' \<oplus> 2 -CEdge (p', es', rets')\<rightarrow>\<^isub>p n''` `c' \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c' \<turnstile> n' -CEdge (p',es',rets')\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
    by(cases n',auto,case_tac n,auto)+
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBodyExit c' n b)
  from `c' \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit` 
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case Proc_CFG_Call
  from `Call p es rets \<turnstile> Label 1 -CEdge (p', es', rets')\<rightarrow>\<^isub>p n''`
  show ?case by(fastforce elim:Proc_CFG.cases)
qed


lemma Proc_CFG_Call_follows_id_edge:
  "\<lbrakk>prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; prog \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n''\<rbrakk> \<Longrightarrow> et = \<Up>id"
proof(induct prog n "CEdge (p,es,rets)" n' arbitrary:n'' rule:Proc_CFG.induct)
  case (Proc_CFG_SeqFirst c\<^isub>1 n n' c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> et = \<Up>id`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'` `n' \<noteq> Exit`
  obtain nx where "c\<^isub>1 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
    by(case_tac n)(auto dest:Proc_CFG_targetlabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n c\<^isub>2)
  from `c\<^isub>1 \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit`
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n n' c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> et = \<Up>id`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n' \<oplus> #:c\<^isub>1 -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>2 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c\<^isub>2 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
      apply(cases n') apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
     apply(cases n') apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(cases n',auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondThen c\<^isub>1 n n' b c\<^isub>2)
  note IH = `\<And>n''. c\<^isub>1 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> et = \<Up>id`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n' \<oplus> 1 -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>1 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
    `n \<noteq> Entry`
  obtain nx where "c\<^isub>1 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(cases n') apply auto apply(case_tac n) apply auto
    apply(cases n') apply auto
    by(case_tac n)(auto dest:Proc_CFG_targetlabel_less_num_nodes)
  then show ?case by (rule IH)
next
  case (Proc_CFG_CondElse c\<^isub>2 n n' b c\<^isub>1)
  note IH = `\<And>n''. c\<^isub>2 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> et = \<Up>id`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n' \<oplus> #:c\<^isub>1 + 1 -IEdge et\<rightarrow>\<^isub>p n''` `c\<^isub>2 \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c\<^isub>2 \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
     apply(cases n') apply auto
     apply(case_tac n) apply(auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(cases n',auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBody c' n n' b)
  note IH = `\<And>n''. c' \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p n'' \<Longrightarrow> et = \<Up>id`
  from `while (b) c' \<turnstile> n' \<oplus> 2 -IEdge et\<rightarrow>\<^isub>p n''` `c' \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'`
  obtain nx where "c' \<turnstile> n' -IEdge et\<rightarrow>\<^isub>p nx"
    apply - apply(erule Proc_CFG.cases,auto)
      apply(cases n') apply auto
     apply(cases n') apply auto apply(case_tac n) apply auto
    by(cases n',auto,case_tac n,auto)
  then show ?case by (rule IH)
next
  case (Proc_CFG_WhileBodyExit c' n et' b)
  from `c' \<turnstile> n -CEdge (p, es, rets)\<rightarrow>\<^isub>p Exit` 
  show ?case by(fastforce dest:Proc_CFG_Call_Labels)
next
  case Proc_CFG_Call
  from `Call p es rets \<turnstile> Label 1 -IEdge et\<rightarrow>\<^isub>p n''` show ?case
    by(fastforce elim:Proc_CFG.cases)
qed


lemma Proc_CFG_edge_det:
  "\<lbrakk>prog \<turnstile> n -et\<rightarrow>\<^isub>p n'; prog \<turnstile> n -et'\<rightarrow>\<^isub>p n'\<rbrakk> \<Longrightarrow> et = et'"
proof(induct rule:Proc_CFG.induct)
  case Proc_CFG_Entry_Exit thus ?case by(fastforce dest:Proc_CFG_EntryD)
next
  case Proc_CFG_Entry thus ?case by(fastforce dest:Proc_CFG_EntryD)
next
  case Proc_CFG_Skip thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case Proc_CFG_LAss thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case Proc_CFG_LAssSkip thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case (Proc_CFG_SeqFirst c\<^isub>1 n et n' c\<^isub>2)
  note edge = `c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p n'` 
  note IH = `c\<^isub>1 \<turnstile> n -et'\<rightarrow>\<^isub>p n' \<Longrightarrow> et = et'`
  from edge `n' \<noteq> Exit` obtain l where l:"n' = Label l" by (cases n') auto
  with edge have "l < #:c\<^isub>1" by(fastforce intro:Proc_CFG_targetlabel_less_num_nodes)
  with `c\<^isub>1;;c\<^isub>2 \<turnstile> n -et'\<rightarrow>\<^isub>p n'` l have "c\<^isub>1 \<turnstile> n -et'\<rightarrow>\<^isub>p n'"
    by(fastforce elim:Proc_CFG.cases intro:Proc_CFG.intros dest:label_incr_ge)
  from IH[OF this] show ?case .
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n et c\<^isub>2)
  note edge = `c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p Exit`
  note IH = `c\<^isub>1 \<turnstile> n -et'\<rightarrow>\<^isub>p Exit \<Longrightarrow> et = et'`
  from edge `n \<noteq> Entry` obtain l where l:"n = Label l" by (cases n) auto
  with edge have "l < #:c\<^isub>1" by(fastforce intro: Proc_CFG_sourcelabel_less_num_nodes)
  with `c\<^isub>1;;c\<^isub>2 \<turnstile> n -et'\<rightarrow>\<^isub>p Label #:c\<^isub>1` l have "c\<^isub>1 \<turnstile> n -et'\<rightarrow>\<^isub>p Exit"
    by(fastforce elim:Proc_CFG.cases 
                dest:Proc_CFG_targetlabel_less_num_nodes label_incr_ge)
  from IH[OF this] show ?case .
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n et n' c\<^isub>1)
  note edge = `c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'` 
  note IH = `c\<^isub>2 \<turnstile> n -et'\<rightarrow>\<^isub>p n' \<Longrightarrow> et = et'`
  from edge `n \<noteq> Entry` obtain l where l:"n = Label l" by (cases n) auto
  with edge have "l < #:c\<^isub>2" by(fastforce intro:Proc_CFG_sourcelabel_less_num_nodes)
  with `c\<^isub>1;;c\<^isub>2 \<turnstile> n \<oplus> #:c\<^isub>1 -et'\<rightarrow>\<^isub>p n' \<oplus> #:c\<^isub>1` l have "c\<^isub>2 \<turnstile> n -et'\<rightarrow>\<^isub>p n'"
    by -(erule Proc_CFG.cases,
    (fastforce dest:Proc_CFG_sourcelabel_less_num_nodes label_incr_ge
              dest!:label_incr_inj)+)
  from IH[OF this] show ?case .
next
  case Proc_CFG_CondTrue thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case Proc_CFG_CondFalse thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case (Proc_CFG_CondThen c\<^isub>1 n et n' b c\<^isub>2)
  note edge = `c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p n'`
  note IH = `c\<^isub>1 \<turnstile> n -et'\<rightarrow>\<^isub>p n' \<Longrightarrow> et = et'`
  from edge `n \<noteq> Entry` obtain l where l:"n = Label l" by (cases n) auto
  with edge have "l < #:c\<^isub>1" by(fastforce intro:Proc_CFG_sourcelabel_less_num_nodes)
  with `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> 1 -et'\<rightarrow>\<^isub>p n' \<oplus> 1` l have "c\<^isub>1 \<turnstile> n -et'\<rightarrow>\<^isub>p n'"
    by -(erule Proc_CFG.cases,(fastforce dest:label_incr_ge label_incr_inj)+)
  from IH[OF this] show ?case .
next
  case (Proc_CFG_CondElse c\<^isub>2 n et n' b c\<^isub>1)
  note edge = `c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'`
  note IH = `c\<^isub>2 \<turnstile> n -et'\<rightarrow>\<^isub>p n' \<Longrightarrow> et = et'`
  from edge `n \<noteq> Entry` obtain l where l:"n = Label l" by (cases n) auto
  with edge have "l < #:c\<^isub>2" by(fastforce intro:Proc_CFG_sourcelabel_less_num_nodes)
  with `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n \<oplus> (#:c\<^isub>1 + 1) -et'\<rightarrow>\<^isub>p n' \<oplus> (#:c\<^isub>1 + 1)` l 
  have "c\<^isub>2 \<turnstile> n -et'\<rightarrow>\<^isub>p n'"
    by -(erule Proc_CFG.cases,(fastforce dest:Proc_CFG_sourcelabel_less_num_nodes 
                             label_incr_inj label_incr_ge label_incr_simp_rev)+)
  from IH[OF this] show ?case .
next
  case Proc_CFG_WhileTrue thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case Proc_CFG_WhileFalse thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case Proc_CFG_WhileFalseSkip thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case (Proc_CFG_WhileBody c' n et n' b)
  note edge = `c' \<turnstile> n -et\<rightarrow>\<^isub>p n'`
  note IH = `c' \<turnstile> n -et'\<rightarrow>\<^isub>p n' \<Longrightarrow> et = et'`
  from edge `n \<noteq> Entry` obtain l where l:"n = Label l" by (cases n) auto
  with edge have less:"l < #:c'" 
    by(fastforce intro:Proc_CFG_sourcelabel_less_num_nodes)
  from edge `n' \<noteq> Exit` obtain l' where l':"n' = Label l'" by (cases n') auto
  with edge have "l' < #:c'" by(fastforce intro:Proc_CFG_targetlabel_less_num_nodes)
  with `while (b) c' \<turnstile> n \<oplus> 2 -et'\<rightarrow>\<^isub>p n' \<oplus> 2` l less l' have "c' \<turnstile> n -et'\<rightarrow>\<^isub>p n'"
    by(fastforce elim:Proc_CFG.cases dest:label_incr_start_Node_smaller)
  from IH[OF this] show ?case .
next
  case (Proc_CFG_WhileBodyExit c' n et b)
  note edge = `c' \<turnstile> n -et\<rightarrow>\<^isub>p Exit`
  note IH = `c' \<turnstile> n -et'\<rightarrow>\<^isub>p Exit \<Longrightarrow> et = et'`
  from edge `n \<noteq> Entry` obtain l where l:"n = Label l" by (cases n) auto
  with edge have "l < #:c'" by(fastforce intro:Proc_CFG_sourcelabel_less_num_nodes)
  with `while (b) c' \<turnstile> n \<oplus> 2 -et'\<rightarrow>\<^isub>p Label 0` l have "c' \<turnstile> n -et'\<rightarrow>\<^isub>p Exit"
    by -(erule Proc_CFG.cases,auto dest:label_incr_start_Node_smaller)
  from IH[OF this] show ?case .
next
  case Proc_CFG_Call thus ?case by(fastforce elim:Proc_CFG.cases)
next
  case Proc_CFG_CallSkip thus ?case by(fastforce elim:Proc_CFG.cases)
qed


lemma WCFG_deterministic:
  "\<lbrakk>prog \<turnstile> n\<^isub>1 -et\<^isub>1\<rightarrow>\<^isub>p n\<^isub>1'; prog \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n\<^isub>1 = n\<^isub>2; n\<^isub>1' \<noteq> n\<^isub>2'\<rbrakk>
  \<Longrightarrow> \<exists>Q Q'. et\<^isub>1 = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
            (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))"
proof(induct arbitrary:n\<^isub>2 n\<^isub>2' rule:Proc_CFG.induct)
  case (Proc_CFG_Entry_Exit prog)
  from `prog \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Entry = n\<^isub>2` `Exit \<noteq> n\<^isub>2'`
  have "et\<^isub>2 = IEdge (\<lambda>s. True)\<^isub>\<surd>" by(fastforce dest:Proc_CFG_EntryD)
  thus ?case by simp
next
  case (Proc_CFG_Entry prog)
  from `prog \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Entry = n\<^isub>2` `Label 0 \<noteq> n\<^isub>2'`
  have "et\<^isub>2 = IEdge (\<lambda>s. False)\<^isub>\<surd>" by(fastforce dest:Proc_CFG_EntryD)
  thus ?case by simp
next
  case Proc_CFG_Skip
  from `Skip \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 0 = n\<^isub>2` `Exit \<noteq> n\<^isub>2'`
  have False by(fastforce elim:Proc_CFG.cases)
  thus ?case by simp
next
  case (Proc_CFG_LAss V e)
  from `V:=e \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 0 = n\<^isub>2` `Label 1 \<noteq> n\<^isub>2'`
  have False by -(erule Proc_CFG.cases,auto)
  thus ?case by simp
next
  case (Proc_CFG_LAssSkip V e)
  from `V:=e \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 1 = n\<^isub>2` `Exit \<noteq> n\<^isub>2'`
  have False by -(erule Proc_CFG.cases,auto)
  thus ?case by simp
next
  case (Proc_CFG_SeqFirst c\<^isub>1 n et n' c\<^isub>2)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; n' \<noteq> n\<^isub>2'\<rbrakk>
  \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
            (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p n'` `n = n\<^isub>2` `n' \<noteq> n\<^isub>2'`
  have "c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2' \<or> (c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p Exit \<and> n\<^isub>2' = Label #:c\<^isub>1)"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros)
    by(case_tac n,auto dest:Proc_CFG_sourcelabel_less_num_nodes)+
  thus ?case
  proof
    assume "c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'"
    from IH[OF this `n = n\<^isub>2` `n' \<noteq> n\<^isub>2'`] show ?case .
  next
    assume "c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p Exit \<and> n\<^isub>2' = Label #:c\<^isub>1"
    hence edge:"c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p Exit" and n2':"n\<^isub>2' = Label #:c\<^isub>1" by simp_all
    from IH[OF edge `n = n\<^isub>2` `n' \<noteq> Exit`] show ?case .
  qed
next
  case (Proc_CFG_SeqConnect c\<^isub>1 n et c\<^isub>2)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; Exit \<noteq> n\<^isub>2'\<rbrakk>
  \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
            (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p Exit` `n = n\<^isub>2` `n \<noteq> Entry`
    `Label #:c\<^isub>1 \<noteq> n\<^isub>2'` have "c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2' \<and> Exit \<noteq> n\<^isub>2'"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros)
    by(case_tac n,auto dest:Proc_CFG_sourcelabel_less_num_nodes)+
  from IH[OF this[THEN conjunct1] `n = n\<^isub>2` this[THEN conjunct2]]
  show ?case .
next
  case (Proc_CFG_SeqSecond c\<^isub>2 n et n' c\<^isub>1)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; n' \<noteq> n\<^isub>2'\<rbrakk>
  \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
            (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `c\<^isub>1;;c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'` `n \<oplus> #:c\<^isub>1 = n\<^isub>2`
    `n' \<oplus> #:c\<^isub>1 \<noteq> n\<^isub>2'` `n \<noteq> Entry`
  obtain nx where "c\<^isub>2 \<turnstile> n -et\<^isub>2\<rightarrow>\<^isub>p nx \<and> nx \<oplus> #:c\<^isub>1 = n\<^isub>2'"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros)
      apply(cases n,auto dest:Proc_CFG_sourcelabel_less_num_nodes)
     apply(cases n,auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(fastforce dest:label_incr_inj)
  with `n' \<oplus> #:c\<^isub>1 \<noteq> n\<^isub>2'` have edge:"c\<^isub>2 \<turnstile> n -et\<^isub>2\<rightarrow>\<^isub>p nx" and neq:"n' \<noteq> nx"
    by auto
  from IH[OF edge _ neq] show ?case by simp
next
  case (Proc_CFG_CondTrue b c\<^isub>1 c\<^isub>2)
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 0 = n\<^isub>2` `Label 1 \<noteq> n\<^isub>2'`
  show ?case by -(erule Proc_CFG.cases,auto)
next
  case (Proc_CFG_CondFalse b c\<^isub>1 c\<^isub>2)
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 0 = n\<^isub>2` `Label (#:c\<^isub>1 + 1) \<noteq> n\<^isub>2'`
  show ?case by -(erule Proc_CFG.cases,auto)
next
  case (Proc_CFG_CondThen c\<^isub>1 n et n' b c\<^isub>2)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c\<^isub>1 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; n' \<noteq> n\<^isub>2'\<rbrakk>
    \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
              (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c\<^isub>1 \<turnstile> n -et\<rightarrow>\<^isub>p n'` `n \<noteq> Entry` 
    `n \<oplus> 1 = n\<^isub>2` `n' \<oplus> 1 \<noteq> n\<^isub>2'`
  obtain nx where "c\<^isub>1 \<turnstile> n -et\<^isub>2\<rightarrow>\<^isub>p nx \<and> n' \<noteq> nx"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros simp del:One_nat_def)
     apply(drule label_incr_inj) apply(auto simp del:One_nat_def)
    apply(drule label_incr_simp_rev[OF sym])
    by(case_tac na,auto dest:Proc_CFG_sourcelabel_less_num_nodes)
  from IH[OF this[THEN conjunct1] _ this[THEN conjunct2]] show ?case by simp
next
  case (Proc_CFG_CondElse c\<^isub>2 n et n' b c\<^isub>1)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; n' \<noteq> n\<^isub>2'\<rbrakk>
    \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
              (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `if (b) c\<^isub>1 else c\<^isub>2 \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c\<^isub>2 \<turnstile> n -et\<rightarrow>\<^isub>p n'` `n \<noteq> Entry` 
    `n \<oplus> #:c\<^isub>1 + 1 = n\<^isub>2` `n' \<oplus> #:c\<^isub>1 + 1 \<noteq> n\<^isub>2'`
  obtain nx where "c\<^isub>2 \<turnstile> n -et\<^isub>2\<rightarrow>\<^isub>p nx \<and> n' \<noteq> nx"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros simp del:One_nat_def)
     apply(drule label_incr_simp_rev)
     apply(case_tac na,auto,cases n,auto dest:Proc_CFG_sourcelabel_less_num_nodes)
    by(fastforce dest:label_incr_inj)
  from IH[OF this[THEN conjunct1] _ this[THEN conjunct2]] show ?case by simp
next
  case (Proc_CFG_WhileTrue b c')
  from `while (b) c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 0 = n\<^isub>2` `Label 2 \<noteq> n\<^isub>2'`
  show ?case by -(erule Proc_CFG.cases,auto)
next
  case (Proc_CFG_WhileFalse b c')
  from `while (b) c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 0 = n\<^isub>2` `Label 1 \<noteq> n\<^isub>2'`
  show ?case by -(erule Proc_CFG.cases,auto)
next
  case (Proc_CFG_WhileFalseSkip b c')
  from `while (b) c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `Label 1 = n\<^isub>2` `Exit \<noteq> n\<^isub>2'`
  show ?case by -(erule Proc_CFG.cases,auto dest:label_incr_ge)
next
  case (Proc_CFG_WhileBody c' n et n' b)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; n' \<noteq> n\<^isub>2'\<rbrakk>
    \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
              (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `while (b) c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c' \<turnstile> n -et\<rightarrow>\<^isub>p n'` `n \<noteq> Entry`
    `n' \<noteq> Exit` `n \<oplus> 2 = n\<^isub>2` `n' \<oplus> 2 \<noteq> n\<^isub>2'`
  obtain nx where "c' \<turnstile> n -et\<^isub>2\<rightarrow>\<^isub>p nx \<and> n' \<noteq> nx"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros)
      apply(fastforce dest:label_incr_ge[OF sym])
     apply(fastforce dest:label_incr_inj)
    by(fastforce dest:label_incr_inj)
  from IH[OF this[THEN conjunct1] _ this[THEN conjunct2]] show ?case by simp
next
  case (Proc_CFG_WhileBodyExit c' n et b)
  note IH = `\<And>n\<^isub>2 n\<^isub>2'. \<lbrakk>c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'; n = n\<^isub>2; Exit \<noteq> n\<^isub>2'\<rbrakk>
    \<Longrightarrow> \<exists>Q Q'. et = IEdge (Q)\<^isub>\<surd> \<and> et\<^isub>2 = IEdge (Q')\<^isub>\<surd> \<and> 
              (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))`
  from `while (b) c' \<turnstile> n\<^isub>2 -et\<^isub>2\<rightarrow>\<^isub>p n\<^isub>2'` `c' \<turnstile> n -et\<rightarrow>\<^isub>p Exit` `n \<noteq> Entry`
    `n \<oplus> 2 = n\<^isub>2` `Label 0 \<noteq> n\<^isub>2'`
  obtain nx where "c' \<turnstile> n -et\<^isub>2\<rightarrow>\<^isub>p nx \<and> Exit \<noteq> nx"
    apply - apply(erule Proc_CFG.cases)
    apply(auto intro:Proc_CFG.intros)
     apply(fastforce dest:label_incr_ge[OF sym])
    by(fastforce dest:label_incr_inj)
  from IH[OF this[THEN conjunct1] _ this[THEN conjunct2]] show ?case by simp
next
  case Proc_CFG_Call thus ?case by -(erule Proc_CFG.cases,auto)
next
  case Proc_CFG_CallSkip thus ?case by -(erule Proc_CFG.cases,auto)
qed


subsection {* And now: the interprocedural CFG *}

subsubsection {* Statements containing calls *}

text {* A procedure is a tuple composed of its name, its input and output variables
  and its method body *}

type_synonym proc = "(pname \<times> vname list \<times> vname list \<times> cmd)"
type_synonym procs = "proc list"


text {* @{text "containsCall"} guarantees that a call to procedure p is in
  a certain statement. *}

declare conj_cong[fundef_cong]

function containsCall :: 
  "procs \<Rightarrow> cmd \<Rightarrow> pname list \<Rightarrow> pname \<Rightarrow> bool"
where "containsCall procs Skip ps p \<longleftrightarrow> False"
  | "containsCall procs (V:=e) ps p \<longleftrightarrow> False"
  | "containsCall procs (c\<^isub>1;;c\<^isub>2) ps p \<longleftrightarrow> 
       containsCall procs c\<^isub>1 ps p \<or> containsCall procs c\<^isub>2 ps p"
  | "containsCall procs (if (b) c\<^isub>1 else c\<^isub>2) ps p \<longleftrightarrow> 
       containsCall procs c\<^isub>1 ps p \<or> containsCall procs c\<^isub>2 ps p"
  | "containsCall procs (while (b) c) ps p \<longleftrightarrow> 
       containsCall procs c ps p"
  | "containsCall procs (Call q es' rets') ps p \<longleftrightarrow> p = q \<and> ps = [] \<or> 
       (\<exists>ins outs c ps'. ps = q#ps' \<and> (q,ins,outs,c) \<in> set procs \<and>
                     containsCall procs c ps' p)"
by pat_completeness auto
termination containsCall
by(relation "measures [\<lambda>(procs,c,ps,p). length ps, 
  \<lambda>(procs,c,ps,p). size c]") auto


lemmas containsCall_induct[case_names Skip LAss Seq Cond While Call] = 
  containsCall.induct


lemma containsCallcases: 
  "containsCall procs prog ps p
  \<Longrightarrow> ps = [] \<and> containsCall procs prog ps p \<or> 
  (\<exists>q ins outs c ps'. ps = ps'@[q] \<and> (q,ins,outs,c) \<in> set procs \<and>
  containsCall procs c [] p \<and> containsCall procs prog ps' q)"
proof(induct procs prog ps p rule:containsCall_induct)
  case (Call procs q es' rets' ps p)
  note IH = `\<And>x y z ps'. \<lbrakk>ps = q#ps'; (q,x,y,z) \<in> set procs;
    containsCall procs z ps' p\<rbrakk>
    \<Longrightarrow> ps' = [] \<and> containsCall procs z ps' p \<or> 
    (\<exists>qx ins outs c psx. ps' = psx@[qx] \<and> (qx,ins,outs,c) \<in> set procs \<and>
    containsCall procs c [] p \<and> 
    containsCall procs z psx qx)`
  from `containsCall procs (Call q es' rets') ps p`
  have "p = q \<and> ps = [] \<or> 
    (\<exists>ins outs c ps'. ps = q#ps' \<and> (q,ins,outs,c) \<in> set procs \<and>
                  containsCall procs c ps' p)" by simp
  thus ?case
  proof
    assume assms:"p = q \<and> ps = []"
    hence "containsCall procs (Call q es' rets') ps p" by simp
    with assms show ?thesis by simp
  next
    assume "\<exists>ins outs c ps'. ps = q#ps' \<and> (q,ins,outs,c) \<in> set procs \<and>
      containsCall procs c ps' p"
    then obtain ins outs c ps' where "ps = q#ps'" and "(q,ins,outs,c) \<in> set procs"
      and "containsCall procs c ps' p" by blast
    from IH[OF this] have "ps' = [] \<and> containsCall procs c ps' p \<or>
      (\<exists>qx insx outsx cx psx. 
         ps' = psx @ [qx] \<and> (qx,insx,outsx,cx) \<in> set procs \<and>
         containsCall procs cx [] p \<and> containsCall procs c psx qx)" .
    thus ?thesis
    proof
      assume assms:"ps' = [] \<and> containsCall procs c ps' p"
      have "containsCall procs (Call q es' rets') [] q" by simp
      with assms `ps = q#ps'` `(q,ins,outs,c) \<in> set procs` show ?thesis by fastforce
    next
      assume "\<exists>qx insx outsx cx psx. 
        ps' = psx@[qx] \<and> (qx,insx,outsx,cx) \<in> set procs \<and>
        containsCall procs cx [] p \<and> containsCall procs c psx qx"
      then obtain qx insx outsx cx psx
        where "ps' = psx@[qx]" and "(qx,insx,outsx,cx) \<in> set procs"
        and "containsCall procs cx [] p"
        and "containsCall procs c psx qx" by blast
      from `(q,ins,outs,c) \<in> set procs` `containsCall procs c psx qx`
      have "containsCall procs (Call q es' rets') (q#psx) qx" by fastforce
      with `ps' = psx@[qx]` `ps = q#ps'` `(qx,insx,outsx,cx) \<in> set procs`
        `containsCall procs cx [] p` show ?thesis by fastforce
    qed
  qed
qed auto



lemma containsCallE:
  "\<lbrakk>containsCall procs prog ps p; 
    \<lbrakk>ps = []; containsCall procs prog ps p\<rbrakk> \<Longrightarrow> P procs prog ps p;
    \<And>q ins outs c es' rets' ps'. \<lbrakk>ps = ps'@[q]; (q,ins,outs,c) \<in> set procs; 
      containsCall procs c [] p; containsCall procs prog ps' q\<rbrakk> 
     \<Longrightarrow> P procs prog ps p\<rbrakk> \<Longrightarrow> P procs prog ps p"
  by(auto dest:containsCallcases)


lemma containsCall_in_proc: 
  "\<lbrakk>containsCall procs prog qs q; (q,ins,outs,c) \<in> set procs; 
  containsCall procs c [] p\<rbrakk>
  \<Longrightarrow> containsCall procs prog (qs@[q]) p"
proof(induct procs prog qs q rule:containsCall_induct)
  case (Call procs qx esx retsx ps p')
  note IH = `\<And>x y z psx. \<lbrakk>ps = qx#psx; (qx,x,y,z) \<in> set procs;
    containsCall procs z psx p'; (p',ins,outs,c) \<in> set procs; 
    containsCall procs c [] p\<rbrakk> \<Longrightarrow> containsCall procs z (psx@[p']) p`
  from `containsCall procs (Call qx esx retsx) ps p'`
  have "p' = qx \<and> ps = [] \<or>
    (\<exists>insx outsx cx psx. ps = qx#psx \<and> (qx,insx,outsx,cx) \<in> set procs \<and>
    containsCall procs cx psx p')" by simp
  thus ?case
  proof
    assume assms:"p' = qx \<and> ps = []"
    with `(p', ins, outs, c) \<in> set procs` `containsCall procs c [] p`
    have "containsCall procs (Call qx esx retsx) [p'] p" by fastforce
    with assms show ?thesis by simp
  next
    assume "\<exists>insx outsx cx psx. ps = qx#psx \<and> (qx,insx,outsx,cx) \<in> set procs \<and>
      containsCall procs cx psx p'"
    then obtain insx outsx cx psx where "ps = qx#psx" 
      and "(qx,insx,outsx,cx) \<in> set procs"
      and "containsCall procs cx psx p'" by blast
    from IH[OF this `(p', ins, outs, c) \<in> set procs` 
      `containsCall procs c [] p`] 
    have "containsCall procs cx (psx @ [p']) p" .
    with `ps = qx#psx` `(qx,insx,outsx,cx) \<in> set procs`
    show ?thesis by fastforce
  qed
qed auto
    

lemma containsCall_indirection:
  "\<lbrakk>containsCall procs prog qs q; containsCall procs c ps p;
  (q,ins,outs,c) \<in> set procs\<rbrakk>
  \<Longrightarrow> containsCall procs prog (qs@q#ps) p"
proof(induct procs prog qs q rule:containsCall_induct)
  case (Call procs px esx retsx ps' p')
  note IH = `\<And>x y z psx. \<lbrakk>ps' = px # psx; (px, x, y, z) \<in> set procs;
    containsCall procs z psx p'; containsCall procs c ps p;
    (p', ins, outs, c) \<in> set procs\<rbrakk>
    \<Longrightarrow> containsCall procs z (psx @ p' # ps) p`
  from `containsCall procs (Call px esx retsx) ps' p'`
  have "p' = px \<and> ps' = [] \<or>
    (\<exists>insx outsx cx psx. ps' = px#psx \<and> (px,insx,outsx,cx) \<in> set procs \<and>
    containsCall procs cx psx p')" by simp
  thus ?case
  proof
    assume "p' = px \<and> ps' = []"
    with `containsCall procs c ps p` `(p', ins, outs, c) \<in> set procs`
    show ?thesis by fastforce
  next
    assume "\<exists>insx outsx cx psx. ps' = px#psx \<and> (px,insx,outsx,cx) \<in> set procs \<and>
      containsCall procs cx psx p'"
    then obtain insx outsx cx psx where "ps' = px#psx" 
      and "(px,insx,outsx,cx) \<in> set procs"
      and "containsCall procs cx psx p'" by blast
    from IH[OF this `containsCall procs c ps p`
      `(p', ins, outs, c) \<in> set procs`] 
    have "containsCall procs cx (psx @ p' # ps) p" .
    with `ps' = px#psx` `(px,insx,outsx,cx) \<in> set procs`
    show ?thesis by fastforce
  qed
qed auto


lemma Proc_CFG_Call_containsCall:
  "prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n' \<Longrightarrow> containsCall procs prog [] p"
by(induct prog n et\<equiv>"CEdge (p,es,rets)" n' rule:Proc_CFG.induct,auto)


lemma containsCall_empty_Proc_CFG_Call_edge: 
  assumes "containsCall procs prog [] p"
  obtains l es rets l' where "prog \<turnstile> Label l -CEdge (p,es,rets)\<rightarrow>\<^isub>p Label l'"
proof(atomize_elim)
  from `containsCall procs prog [] p`
  show "\<exists>l es rets l'. prog \<turnstile> Label l -CEdge (p,es,rets)\<rightarrow>\<^isub>p Label l'"
  proof(induct procs prog ps\<equiv>"[]::pname list" p rule:containsCall_induct)
    case Seq thus ?case
      by auto(fastforce dest:Proc_CFG_SeqFirst,fastforce dest:Proc_CFG_SeqSecond)
  next
    case Cond thus ?case
      by auto(fastforce dest:Proc_CFG_CondThen,fastforce dest:Proc_CFG_CondElse)
  next
    case While thus ?case by(fastforce dest:Proc_CFG_WhileBody)
  next
    case Call thus ?case by(fastforce intro:Proc_CFG_Call)
  qed auto
qed


subsubsection{* The edges of the combined CFG *}

type_synonym node = "(pname \<times> label)"
type_synonym edge = "(node \<times> (vname,val,node,pname) edge_kind \<times> node)"

fun get_proc :: "node \<Rightarrow> pname"
  where "get_proc (p,l) = p"


inductive PCFG :: 
  "cmd \<Rightarrow> procs \<Rightarrow> node \<Rightarrow> (vname,val,node,pname) edge_kind \<Rightarrow> node \<Rightarrow> bool" 
("_,_ \<turnstile> _ -_\<rightarrow> _" [51,51,0,0,0] 81)
for prog::cmd and procs::procs
where

  Main:
  "prog \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n' \<Longrightarrow> prog,procs \<turnstile> (Main,n) -et\<rightarrow> (Main,n')"

| Proc:
  "\<lbrakk>(p,ins,outs,c) \<in> set procs; c \<turnstile> n -IEdge et\<rightarrow>\<^isub>p n'; 
    containsCall procs prog ps p\<rbrakk> 
  \<Longrightarrow> prog,procs \<turnstile> (p,n) -et\<rightarrow> (p,n')"


| MainCall:
  "\<lbrakk>prog \<turnstile> Label l -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'; (p,ins,outs,c) \<in> set procs\<rbrakk>
  \<Longrightarrow> prog,procs \<turnstile> (Main,Label l) 
                  -(\<lambda>s. True):(Main,n')\<hookrightarrow>\<^bsub>p\<^esub>map (\<lambda>e cf. interpret e cf) es\<rightarrow> (p,Entry)"

| ProcCall:
  "\<lbrakk>(p,ins,outs,c) \<in> set procs; c \<turnstile> Label l -CEdge (p',es',rets')\<rightarrow>\<^isub>p Label l';
    (p',ins',outs',c') \<in> set procs; containsCall procs prog ps p\<rbrakk>
  \<Longrightarrow> prog,procs \<turnstile> (p,Label l) 
               -(\<lambda>s. True):(p,Label l')\<hookrightarrow>\<^bsub>p'\<^esub>map (\<lambda>e cf. interpret e cf) es'\<rightarrow> (p',Entry)"

| MainReturn:
  "\<lbrakk>prog \<turnstile> Label l -CEdge (p,es,rets)\<rightarrow>\<^isub>p Label l'; (p,ins,outs,c) \<in> set procs\<rbrakk>
  \<Longrightarrow> prog,procs \<turnstile> (p,Exit) -(\<lambda>cf. snd cf = (Main,Label l'))\<hookleftarrow>\<^bsub>p\<^esub>
       (\<lambda>cf cf'. cf'(rets [:=] map cf outs))\<rightarrow> (Main,Label l')"

| ProcReturn:
  "\<lbrakk>(p,ins,outs,c) \<in> set procs; c \<turnstile> Label l -CEdge (p',es',rets')\<rightarrow>\<^isub>p Label l'; 
   (p',ins',outs',c') \<in> set procs; containsCall procs prog ps p\<rbrakk>
  \<Longrightarrow> prog,procs \<turnstile> (p',Exit) -(\<lambda>cf. snd cf = (p,Label l'))\<hookleftarrow>\<^bsub>p'\<^esub>
       (\<lambda>cf cf'. cf'(rets' [:=] map cf outs'))\<rightarrow> (p,Label l')"

| MainCallReturn:
  "prog \<turnstile> n -CEdge (p,es,rets)\<rightarrow>\<^isub>p n'
  \<Longrightarrow> prog,procs \<turnstile> (Main,n) -(\<lambda>s. False)\<^isub>\<surd>\<rightarrow> (Main,n')"

| ProcCallReturn:
  "\<lbrakk>(p,ins,outs,c) \<in> set procs; c \<turnstile> n -CEdge (p',es',rets')\<rightarrow>\<^isub>p n'; 
    containsCall procs prog ps p\<rbrakk> 
  \<Longrightarrow> prog,procs \<turnstile> (p,n) -(\<lambda>s. False)\<^isub>\<surd>\<rightarrow> (p,n')"


end
