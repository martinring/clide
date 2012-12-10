(*  Title:      JinjaThreads/MM/JMM_Spec.thy
    Author:     Andreas Lochbihler
*)

header {* \isaheader{Axiomatic specification of the JMM} *}

theory JMM_Spec
imports
  Orders
  "../Common/Observable_Events"
  "../../Coinductive/Coinductive_List_Lib"
begin

section {* Definitions *}

type_synonym JMM_action = nat
type_synonym ('addr, 'thread_id) execution = "('thread_id \<times> ('addr, 'thread_id) obs_event action) llist"

definition "actions" :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action set"
where "actions E = {n. enat n < llength E}"

definition action_tid :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> 'thread_id"
where "action_tid E a = fst (lnth E a)"

definition action_obs :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> ('addr, 'thread_id) obs_event action"
where "action_obs E a = snd (lnth E a)"

definition tactions :: "('addr, 'thread_id) execution \<Rightarrow> 'thread_id \<Rightarrow> JMM_action set"
where "tactions E t = {a. a \<in> actions E \<and> action_tid E a = t}"

inductive is_new_action :: "('addr, 'thread_id) obs_event action \<Rightarrow> bool"
where
  NewHeapElem: "is_new_action (NormalAction (NewHeapElem a hT))"

inductive is_write_action :: "('addr, 'thread_id) obs_event action \<Rightarrow> bool"
where
  NewHeapElem: "is_write_action (NormalAction (NewHeapElem ad hT))"
| WriteMem: "is_write_action (NormalAction (WriteMem ad al v))"

text {*
  Initialisation actions are synchronisation actions iff they initialize volatile
  fields -- cf. JMM mailing list, message no. 62 (5 Nov. 2006).
  However, intuitively correct programs might not be correctly synchronized:
\begin{verbatim}
     x = 0
---------------
r1 = x | r2 = x
\end{verbatim}
  Here, if x is not volatile, the initial write can belong to at most one thread.
  Hence, it is happens-before to either r1 = x or r2 = x, but not both.
  In any sequentially consistent execution, both reads must read from the initilisation
  action x = 0, but it is not happens-before ordered to one of them.

  Moreover, if only volatile initialisations synchronize-with all thread-start actions,
  this breaks the proof of the DRF guarantee since it assumes that the happens-before relation
  $<=hb$ a for an action $a$ in a topologically sorted action sequence depends only on the 
  actions before it. Counter example: (y is volatile)

  [(t1, start), (t1, init x), (t2, start), (t1, init y), ...

  Here, (t1, init x) $<=hb$ (t2, start) via: (t1, init x) $<=po$ (t1, init y) $<=sw$ (t2, start),
  but in [(t1, start), (t1, init x), (t2, start)], not (t1, init x) $<=hb$ (t2, start).

  Sevcik speculated that one might add an initialisation thread which performs all initialisation
  actions. All normal threads' start action would then synchronize on the final action of the initialisation thread.
  However, this contradicts the memory chain condition in the final field extension to the JMM
  (threads must read addresses of objects that they have not created themselves before they can
  access the fields of the object at that address) -- not modelled here.

  Instead, we leave every initialisation action in the thread it belongs to, but order it explicitly
  before the thread's start action and add synchronizes-with edges from \emph{all} initialisation
  actions to \emph{all} thread start actions.
*}

inductive saction :: "'m prog \<Rightarrow> ('addr, 'thread_id) obs_event action \<Rightarrow> bool"
for P :: "'m prog"
where
  NewHeapElem: "saction P (NormalAction (NewHeapElem a hT))"
| Read: "is_volatile P al \<Longrightarrow> saction P (NormalAction (ReadMem a al v))"
| Write: "is_volatile P al \<Longrightarrow> saction P (NormalAction (WriteMem a al v))"
| ThreadStart: "saction P (NormalAction (ThreadStart t))"
| ThreadJoin: "saction P (NormalAction (ThreadJoin t))"
| SyncLock: "saction P (NormalAction (SyncLock a))"
| SyncUnlock: "saction P (NormalAction (SyncUnlock a))"
| ObsInterrupt: "saction P (NormalAction (ObsInterrupt t))"
| ObsInterrupted: "saction P (NormalAction (ObsInterrupted t))"
| InitialThreadAction: "saction P InitialThreadAction"
| ThreadFinishAction: "saction P ThreadFinishAction"


definition sactions :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action set"
where "sactions P E = {a. a \<in> actions E \<and> saction P (action_obs E a)}"

inductive_set write_actions :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action set"
for E :: "('addr, 'thread_id) execution"
where 
  write_actionsI: "\<lbrakk> a \<in> actions E; is_write_action (action_obs E a) \<rbrakk> \<Longrightarrow> a \<in> write_actions E"

text {*
  @{term NewObj} and @{term NewArr} actions only initialize those fields and array cells that
  are in fact in the object or array. Hence, they are not a write for
  - reads from addresses for which no object/array is created during the whole execution
  - reads from fields/cells that are not part of the object/array at the specified address.
*}

primrec addr_locs :: "'m prog \<Rightarrow> htype \<Rightarrow> addr_loc set"
where 
  "addr_locs P (Class_type C) = {CField D F|D F. \<exists>fm T. P \<turnstile> C has F:T (fm) in D}"
| "addr_locs P (Array_type T n) = ({ACell n'|n'. n' < n} \<union> {CField Object F|F. \<exists>fm T. P \<turnstile> Object has F:T (fm) in Object})"

text {*
  @{text "action_loc_aux"} would naturally be an inductive set,
  but inductive\_set does not allow to pattern match on parameters.
  Hence, specify it using function and derive the setup manually.
*}

fun action_loc_aux :: "'m prog \<Rightarrow> ('addr, 'thread_id) obs_event action \<Rightarrow> ('addr \<times> addr_loc) set"
where
  "action_loc_aux P (NormalAction (NewHeapElem ad (Class_type C))) = 
  {(ad, CField D F)|D F T fm. P \<turnstile> C has F:T (fm) in D}"
| "action_loc_aux P (NormalAction (NewHeapElem ad (Array_type T n'))) = 
  {(ad, ACell n)|n. n < n'} \<union> {(ad, CField D F)|D F T fm. P \<turnstile> Object has F:T (fm) in D}"
| "action_loc_aux P (NormalAction (WriteMem ad al v)) = {(ad, al)}"
| "action_loc_aux P (NormalAction (ReadMem ad al v)) = {(ad, al)}"
| "action_loc_aux _ _ = {}"

lemma action_loc_aux_intros [intro?]:
  "P \<turnstile> class_type_of hT has F:T (fm) in D \<Longrightarrow> (ad, CField D F) \<in> action_loc_aux P (NormalAction (NewHeapElem ad hT))"
  "n < n' \<Longrightarrow> (ad, ACell n) \<in> action_loc_aux P (NormalAction (NewHeapElem ad (Array_type T n')))"
  "(ad, al) \<in> action_loc_aux P (NormalAction (WriteMem ad al v))"
  "(ad, al) \<in> action_loc_aux P (NormalAction (ReadMem ad al v))"
by(cases hT) auto

lemma action_loc_aux_cases [elim?, cases set: action_loc_aux]:
  assumes "adal \<in> action_loc_aux P obs"
  obtains (NewHeapElem) hT F T fm D ad where "obs = NormalAction (NewHeapElem ad hT)" "adal = (ad, CField D F)" "P \<turnstile> class_type_of hT has F:T (fm) in D"
  | (NewArr) n n' ad T where "obs = NormalAction (NewHeapElem ad (Array_type T n'))" "adal = (ad, ACell n)" "n < n'"
  | (WriteMem) ad al v where "obs = NormalAction (WriteMem ad al v)" "adal = (ad, al)"
  | (ReadMem) ad al v where "obs = NormalAction (ReadMem ad al v)" "adal = (ad, al)"
using assms by(cases "(P, obs)" rule: action_loc_aux.cases) fastforce+

lemma action_loc_aux_simps [simp]:
  "(ad', al') \<in> action_loc_aux P (NormalAction (NewHeapElem ad hT)) \<longleftrightarrow> 
   (\<exists>D F T fm. ad = ad' \<and> al' = CField D F \<and> P \<turnstile> class_type_of hT has F:T (fm) in D) \<or> 
   (\<exists>n T n'. ad = ad' \<and> al' = ACell n \<and> hT = Array_type T n' \<and> n < n')"
  "(ad', al') \<in> action_loc_aux P (NormalAction (WriteMem ad al v)) \<longleftrightarrow> ad = ad' \<and> al = al'"
  "(ad', al') \<in> action_loc_aux P (NormalAction (ReadMem ad al v)) \<longleftrightarrow> ad = ad' \<and> al = al'"
  "(ad', al') \<notin> action_loc_aux P InitialThreadAction"
  "(ad', al') \<notin> action_loc_aux P ThreadFinishAction"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (ExternalCall a m vs v))"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (ThreadStart t))"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (ThreadJoin t))"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (SyncLock a))"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (SyncUnlock a))"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (ObsInterrupt t))"
  "(ad', al') \<notin> action_loc_aux P (NormalAction (ObsInterrupted t))"
by(cases hT) auto

declare action_loc_aux.simps [simp del]

abbreviation action_loc :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> ('addr \<times> addr_loc) set"
where "action_loc P E a \<equiv> action_loc_aux P (action_obs E a)"

inductive_set read_actions :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action set"
for E :: "('addr, 'thread_id) execution"
where 
  ReadMem: "\<lbrakk> a \<in> actions E; action_obs E a = NormalAction (ReadMem ad al v) \<rbrakk> \<Longrightarrow> a \<in> read_actions E"

fun addr_loc_default :: "'m prog \<Rightarrow> htype \<Rightarrow> addr_loc \<Rightarrow> 'addr val"
where
  "addr_loc_default P (Class_type C) (CField D F) = default_val (fst (the (map_of (fields P C) (F, D))))"
| "addr_loc_default P (Array_type T n) (ACell n') = default_val T"
| addr_loc_default_Array_CField: 
  "addr_loc_default P (Array_type T n) (CField D F) = default_val (fst (the (map_of (fields P Object) (F, Object))))"
| "addr_loc_default P _ _ = undefined"

definition new_actions_for :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> ('addr \<times> addr_loc) \<Rightarrow> JMM_action set"
where 
  "new_actions_for P E adal =
   {a. a \<in> actions E \<and> adal \<in> action_loc P E a \<and> is_new_action (action_obs E a)}"

inductive_set external_actions :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action set"
for E :: "('addr, 'thread_id) execution"
where
  "\<lbrakk> a \<in> actions E; action_obs E a = NormalAction (ExternalCall ad M vs v) \<rbrakk> 
  \<Longrightarrow> a \<in> external_actions E"

fun value_written_aux :: "'m prog \<Rightarrow> ('addr, 'thread_id) obs_event action \<Rightarrow> addr_loc \<Rightarrow> 'addr val"
where
  "value_written_aux P (NormalAction (NewHeapElem ad' hT)) al = addr_loc_default P hT al"
| value_written_aux_WriteMem':
  "value_written_aux P (NormalAction (WriteMem ad al' v)) al = (if al = al' then v else undefined)"
| value_written_aux_undefined:
  "value_written_aux P _ al = undefined"

primrec value_written :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> ('addr \<times> addr_loc) \<Rightarrow> 'addr val"
where "value_written P E a (ad, al) = value_written_aux P (action_obs E a) al"

definition value_read :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> 'addr val"
where
  "value_read E a = 
  (case action_obs E a of
     NormalAction obs \<Rightarrow>
        (case obs of
           ReadMem ad al v \<Rightarrow> v
         | _ \<Rightarrow> undefined)
   | _ \<Rightarrow> undefined)"

definition action_order :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool" ("_ \<turnstile> _ \<le>a _" [51,0,50] 50)
where
  "E \<turnstile> a \<le>a a' \<longleftrightarrow>
   a \<in> actions E \<and> a' \<in> actions E \<and> 
   (if is_new_action (action_obs E a)
    then is_new_action (action_obs E a') \<longrightarrow> a \<le> a'
    else \<not> is_new_action (action_obs E a') \<and> a \<le> a')"

definition program_order :: "('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool" ("_ \<turnstile> _ \<le>po _" [51,0,50] 50)
where
  "E \<turnstile> a \<le>po a' \<longleftrightarrow> E \<turnstile> a \<le>a a' \<and> action_tid E a = action_tid E a'"

inductive synchronizes_with :: 
  "('thread_id \<times> ('addr, 'thread_id) obs_event action) \<Rightarrow> ('thread_id \<times> ('addr, 'thread_id) obs_event action) \<Rightarrow> bool" 
  ("_ \<leadsto>sw _" [51, 51] 50)
where
  ThreadStart: "(t, NormalAction (ThreadStart t')) \<leadsto>sw (t', InitialThreadAction)"
| ThreadFinish: "(t, ThreadFinishAction) \<leadsto>sw (t', NormalAction (ThreadJoin t))"
| UnlockLock: "(t, NormalAction (SyncUnlock a)) \<leadsto>sw (t', NormalAction (SyncLock a))"
| -- {* 
       Only volatile writes synchronize with volatile reads. 
       We could check volatility of @{term "al"} here, but this is checked by @{term "sactions"}
       in @{text sync_with} anyway. *}
  Volatile: "(t, NormalAction (WriteMem a al v)) \<leadsto>sw (t', NormalAction (ReadMem a al v'))"
| VolatileNew: "(t, NormalAction (NewHeapElem a (Class_type C))) \<leadsto>sw (t', NormalAction (ReadMem a al v))"
| NewHeapElem: "(t, NormalAction (NewHeapElem a hT)) \<leadsto>sw (t', InitialThreadAction)"
| Interrupt: "(t, NormalAction (ObsInterrupt t')) \<leadsto>sw (t'', NormalAction (ObsInterrupted t'))"

definition sync_order :: 
  "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool"
  ("_,_ \<turnstile> _ \<le>so _" [51,0,0,50] 50)
where
  "P,E \<turnstile> a \<le>so a' \<longleftrightarrow> a \<in> sactions P E \<and> a' \<in> sactions P E \<and> E \<turnstile> a \<le>a a'"

definition sync_with :: 
  "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool"
  ("_,_ \<turnstile> _ \<le>sw _" [51, 0, 0, 50] 50)
where
  "P,E \<turnstile> a \<le>sw a' \<longleftrightarrow> P,E \<turnstile> a \<le>so a' \<and> (action_tid E a, action_obs E a) \<leadsto>sw (action_tid E a', action_obs E a')"

definition po_sw :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool"
where "po_sw P E a a' \<longleftrightarrow> E \<turnstile> a \<le>po a' \<or> P,E \<turnstile> a \<le>sw a'"

abbreviation happens_before :: 
  "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool"
  ("_,_ \<turnstile> _ \<le>hb _" [51, 0, 0, 50] 50)
where "happens_before P E \<equiv> (po_sw P E)^++"

type_synonym write_seen = "JMM_action \<Rightarrow> JMM_action"

definition is_write_seen :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> write_seen \<Rightarrow> bool"
where 
  "is_write_seen P E ws \<longleftrightarrow>
   (\<forall>a \<in> read_actions E. \<forall>ad al v. action_obs E a = NormalAction (ReadMem ad al v) \<longrightarrow> 
       ws a \<in> write_actions E \<and> (ad, al) \<in> action_loc P E (ws a) \<and>
       value_written P E (ws a) (ad, al) = v \<and> \<not> P,E \<turnstile> a \<le>hb ws a \<and>
       (is_volatile P al \<longrightarrow> \<not> P,E \<turnstile> a \<le>so ws a) \<and>
       (\<forall>w' \<in> write_actions E. (ad, al) \<in> action_loc P E w' \<longrightarrow> (P,E \<turnstile> ws a \<le>hb w' \<and> P,E \<turnstile> w' \<le>hb a \<or> is_volatile P al \<and> P,E \<turnstile> ws a \<le>so w' \<and> P,E \<turnstile> w' \<le>so a) \<longrightarrow> w' = ws a))"

definition thread_start_actions_ok :: "('addr, 'thread_id) execution \<Rightarrow> bool"
where
  "thread_start_actions_ok E \<longleftrightarrow> 
  (\<forall>a \<in> actions E. \<not> is_new_action (action_obs E a) \<longrightarrow> 
     (\<exists>i. i \<le> a \<and> action_obs E i = InitialThreadAction \<and> action_tid E i = action_tid E a))"

primrec wf_exec :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<times> write_seen \<Rightarrow> bool" ("_ \<turnstile> _ \<surd>" [51, 50] 51)
where "P \<turnstile> (E, ws) \<surd> \<longleftrightarrow> is_write_seen P E ws \<and> thread_start_actions_ok E"

inductive most_recent_write_for :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool"
  ("_,_ \<turnstile> _ \<leadsto>mrw _" [50, 0, 51] 51)
for P :: "'m prog" and E :: "('addr, 'thread_id) execution" and ra :: JMM_action and wa :: JMM_action
where
  "\<lbrakk> ra \<in> read_actions E; adal \<in> action_loc P E ra; E \<turnstile> wa \<le>a ra;
     wa \<in> write_actions E; adal \<in> action_loc P E wa;
     \<And>wa'. \<lbrakk> wa' \<in> write_actions E; adal \<in> action_loc P E wa' \<rbrakk>
     \<Longrightarrow> E \<turnstile> wa' \<le>a wa \<or> E \<turnstile> ra \<le>a wa' \<rbrakk>
  \<Longrightarrow> P,E \<turnstile> ra \<leadsto>mrw wa"

primrec sequentially_consistent :: "'m prog \<Rightarrow> (('addr, 'thread_id) execution \<times> write_seen) \<Rightarrow> bool"
where 
  "sequentially_consistent P (E, ws) \<longleftrightarrow> (\<forall>r \<in> read_actions E. P,E \<turnstile> r \<leadsto>mrw ws r)"


section {* Actions *}

inductive_cases is_new_action_cases [elim!]:
  "is_new_action (NormalAction (ExternalCall a M vs v))"
  "is_new_action (NormalAction (ReadMem a al v))"
  "is_new_action (NormalAction (WriteMem a al v))"
  "is_new_action (NormalAction (NewHeapElem a hT))"
  "is_new_action (NormalAction (ThreadStart t))"
  "is_new_action (NormalAction (ThreadJoin t))"
  "is_new_action (NormalAction (SyncLock a))"
  "is_new_action (NormalAction (SyncUnlock a))"
  "is_new_action (NormalAction (ObsInterrupt t))"
  "is_new_action (NormalAction (ObsInterrupted t))"
  "is_new_action InitialThreadAction"
  "is_new_action ThreadFinishAction"

inductive_simps is_new_action_simps [simp]:
  "is_new_action (NormalAction (NewHeapElem a hT))"
  "is_new_action (NormalAction (ExternalCall a M vs v))"
  "is_new_action (NormalAction (ReadMem a al v))"
  "is_new_action (NormalAction (WriteMem a al v))"
  "is_new_action (NormalAction (ThreadStart t))"
  "is_new_action (NormalAction (ThreadJoin t))"
  "is_new_action (NormalAction (SyncLock a))"
  "is_new_action (NormalAction (SyncUnlock a))"
  "is_new_action (NormalAction (ObsInterrupt t))"
  "is_new_action (NormalAction (ObsInterrupted t))"
  "is_new_action InitialThreadAction"
  "is_new_action ThreadFinishAction"

lemmas is_new_action_iff = is_new_action.simps

inductive_simps is_write_action_simps [simp]:
  "is_write_action InitialThreadAction"
  "is_write_action ThreadFinishAction"
  "is_write_action (NormalAction (ExternalCall a m vs v))"
  "is_write_action (NormalAction (ReadMem a al v))"
  "is_write_action (NormalAction (WriteMem a al v))"
  "is_write_action (NormalAction (NewHeapElem a hT))"
  "is_write_action (NormalAction (ThreadStart t))"
  "is_write_action (NormalAction (ThreadJoin t))"
  "is_write_action (NormalAction (SyncLock a))"
  "is_write_action (NormalAction (SyncUnlock a))"
  "is_write_action (NormalAction (ObsInterrupt t))"
  "is_write_action (NormalAction (ObsInterrupted t))"

declare saction.intros [intro!]

inductive_cases saction_cases [elim!]:
  "saction P (NormalAction (ExternalCall a M vs v))"
  "saction P (NormalAction (ReadMem a al v))"
  "saction P (NormalAction (WriteMem a al v))"
  "saction P (NormalAction (NewHeapElem a hT))"
  "saction P (NormalAction (ThreadStart t))"
  "saction P (NormalAction (ThreadJoin t))"
  "saction P (NormalAction (SyncLock a))"
  "saction P (NormalAction (SyncUnlock a))"
  "saction P (NormalAction (ObsInterrupt t))"
  "saction P (NormalAction (ObsInterrupted t))"
  "saction P InitialThreadAction"
  "saction P ThreadFinishAction"

inductive_simps saction_simps [simp]:
  "saction P (NormalAction (ExternalCall a M vs v))"
  "saction P (NormalAction (ReadMem a al v))"
  "saction P (NormalAction (WriteMem a al v))"
  "saction P (NormalAction (NewHeapElem a hT))"
  "saction P (NormalAction (ThreadStart t))"
  "saction P (NormalAction (ThreadJoin t))"
  "saction P (NormalAction (SyncLock a))"
  "saction P (NormalAction (SyncUnlock a))"
  "saction P (NormalAction (ObsInterrupt t))"
  "saction P (NormalAction (ObsInterrupted t))"
  "saction P InitialThreadAction"
  "saction P ThreadFinishAction"

lemma new_action_saction [simp, intro]: "is_new_action a \<Longrightarrow> saction P a"
by(blast elim: is_new_action.cases)

lemmas saction_iff = saction.simps

lemma actionsD: "a \<in> actions E \<Longrightarrow> enat a < llength E"
unfolding actions_def by blast

lemma actionsE: 
  assumes "a \<in> actions E"
  obtains "enat a < llength E"
using assms unfolding actions_def by blast

lemma actions_lappend:
  "llength xs = enat n \<Longrightarrow> actions (lappend xs ys) = actions xs \<union> (op + n) ` actions ys"
unfolding actions_def
apply safe
  apply(erule contrapos_np)
  apply(rule_tac x="x - n" in image_eqI)
   apply simp_all
  apply(case_tac [!] "llength ys")
 apply simp_all
done

lemma tactionsE:
  assumes "a \<in> tactions E t"
  obtains obs where "a \<in> actions E" "action_tid E a = t" "action_obs E a = obs"
using assms
by(cases "lnth E a")(auto simp add: tactions_def action_tid_def action_obs_def)

lemma sactionsI:
  "\<lbrakk> a \<in> actions E; saction P (action_obs E a) \<rbrakk> \<Longrightarrow> a \<in> sactions P E"
unfolding sactions_def by blast

lemma sactionsE:
  assumes "a \<in> sactions P E"
  obtains "a \<in> actions E" "saction P (action_obs E a)"
using assms unfolding sactions_def by blast

lemma sactions_actions [simp]:
  "a \<in> sactions P E \<Longrightarrow> a \<in> actions E"
by(rule sactionsE)

lemma value_written_aux_WriteMem [simp]:
  "value_written_aux P (NormalAction (WriteMem ad al v)) al = v"
by simp

declare value_written_aux_undefined [simp del]
declare value_written_aux_WriteMem' [simp del]

inductive_simps is_write_action_iff:
  "is_write_action a"

inductive_simps write_actions_iff:
  "a \<in> write_actions E"

lemma write_actions_actions [simp]:
  "a \<in> write_actions E \<Longrightarrow> a \<in> actions E"
by(rule write_actions.induct)

inductive_simps read_actions_iff:
  "a \<in> read_actions E"

lemma read_actions_actions [simp]:
  "a \<in> read_actions E \<Longrightarrow> a \<in> actions E"
by(rule read_actions.induct)

lemma read_action_action_locE:
  assumes "r \<in> read_actions E"
  obtains ad al where "(ad, al) \<in> action_loc P E r"
using assms by cases auto

lemma read_actions_not_write_actions:
  "\<lbrakk> a \<in> read_actions E; a \<in> write_actions E \<rbrakk> \<Longrightarrow> False"
by(auto elim!: read_actions.cases write_actions.cases)

lemma read_actions_Int_write_actions [simp]:
  "read_actions E \<inter> write_actions E = {}"
  "write_actions E \<inter> read_actions E = {}"
by(blast dest: read_actions_not_write_actions)+

lemma action_loc_addr_fun:
  "\<lbrakk> (ad, al) \<in> action_loc P E a; (ad', al') \<in> action_loc P E a \<rbrakk> \<Longrightarrow> ad = ad'"
by(auto elim!: action_loc_aux_cases)

lemma value_written_cong [cong]:
  "\<lbrakk> P = P'; a = a'; action_obs E a' = action_obs E' a' \<rbrakk> 
  \<Longrightarrow> value_written P E a = value_written P' E' a'"
by(rule ext)(auto split: action.splits)

declare value_written.simps [simp del]

lemma new_actionsI:
  "\<lbrakk> a \<in> actions E; adal \<in> action_loc P E a; is_new_action (action_obs E a) \<rbrakk>
  \<Longrightarrow> a \<in> new_actions_for P E adal"
unfolding new_actions_for_def by blast

lemma new_actionsE:
  assumes "a \<in> new_actions_for P E adal"
  obtains "a \<in> actions E" "adal \<in> action_loc P E a" "is_new_action (action_obs E a)"
using assms unfolding new_actions_for_def by blast

lemma action_loc_read_action_singleton:
  "\<lbrakk> r \<in> read_actions E; adal \<in> action_loc P E r; adal' \<in> action_loc P E r \<rbrakk> \<Longrightarrow> adal = adal'"
by(cases adal, cases adal')(fastforce elim: read_actions.cases action_loc_aux_cases)

lemma addr_locsI:
  "P \<turnstile> class_type_of hT has F:T (fm) in D \<Longrightarrow> CField D F \<in> addr_locs P hT"
  "\<lbrakk> hT = Array_type T n; n' < n \<rbrakk> \<Longrightarrow> ACell n' \<in> addr_locs P hT"
by(cases hT)(auto dest: has_field_decl_above)

section {* Orders *}
subsection {* Action order *}

lemma action_orderI:
  assumes "a \<in> actions E" "a' \<in> actions E"
  and "\<lbrakk> is_new_action (action_obs E a); is_new_action (action_obs E a') \<rbrakk> \<Longrightarrow> a \<le> a'"
  and "\<not> is_new_action (action_obs E a) \<Longrightarrow> \<not> is_new_action (action_obs E a') \<and> a \<le> a'"
  shows "E \<turnstile> a \<le>a a'"
using assms unfolding action_order_def by simp

lemma action_orderE:
  assumes "E \<turnstile> a \<le>a a'"
  obtains "a \<in> actions E" "a' \<in> actions E" 
          "is_new_action (action_obs E a)" "is_new_action (action_obs E a') \<longrightarrow> a \<le> a'"
        | "a \<in> actions E" "a' \<in> actions E" 
          "\<not> is_new_action (action_obs E a)" "\<not> is_new_action (action_obs E a')" "a \<le> a'"
using assms unfolding action_order_def by(simp split: split_if_asm)

lemma refl_action_order:
  "refl_onP (actions E) (action_order E)"
by(rule refl_onPI)(auto elim: action_orderE intro: action_orderI)

lemma antisym_action_order:
  "antisymP (action_order E)"
by(rule antisymI)(auto elim!: action_orderE)

lemma trans_action_order:
  "transP (action_order E)"
by(rule transI)(auto elim!: action_orderE intro: action_orderI)

lemma porder_action_order:
  "porder_on (actions E) (action_order E)"
by(blast intro: porder_onI refl_action_order antisym_action_order trans_action_order)

lemma total_action_order:
  "total_onP (actions E) (action_order E)"
by(rule total_onPI)(auto simp add: action_order_def)

lemma torder_action_order:
  "torder_on (actions E) (action_order E)"
by(blast intro: torder_onI total_action_order porder_action_order)

lemma wf_action_order: "wfP (action_order E)\<^sup>\<noteq>\<^sup>\<noteq>"
unfolding wfP_eq_minimal
proof(intro strip)
  fix Q and x :: JMM_action
  assume "x \<in> Q"
  show "\<exists>z \<in> Q. \<forall>y. (action_order E)\<^sup>\<noteq>\<^sup>\<noteq> y z \<longrightarrow> y \<notin> Q"
  proof(cases "\<exists>a \<in> Q. a \<in> actions E \<and> is_new_action (action_obs E a)")
    case True
    then obtain a where a: "a \<in> actions E \<and> is_new_action (action_obs E a) \<and> a \<in> Q" by blast
    def a' == "LEAST a'. a' \<in> actions E \<and> is_new_action (action_obs E a') \<and> a' \<in> Q"
    from a have a': "a' \<in> actions E \<and> is_new_action (action_obs E a') \<and> a' \<in> Q"
      unfolding a'_def by(rule LeastI)
    { fix y
      assume y_le_a': "(action_order E)\<^sup>\<noteq>\<^sup>\<noteq> y a'"
      have "y \<notin> Q"
      proof
        assume "y \<in> Q"
        with y_le_a' a' have y: "y \<in> actions E \<and> is_new_action (action_obs E y) \<and> y \<in> Q"
          by(auto elim: action_orderE)
        hence "a' \<le> y" unfolding a'_def by(rule Least_le)
        with y_le_a' a' show False by(auto elim: action_orderE)
      qed }
    with a' show ?thesis by blast
  next
    case False
    hence not_new: "\<And>a. \<lbrakk> a \<in> Q; a \<in> actions E \<rbrakk> \<Longrightarrow> \<not> is_new_action (action_obs E a)" by blast
    show ?thesis
    proof(cases "Q \<inter> actions E = {}")
      case True
      with `x \<in> Q` show ?thesis by(auto elim: action_orderE)
    next
      case False
      def a' == "LEAST a'. a' \<in> Q \<and> a' \<in> actions E \<and> \<not> is_new_action (action_obs E a')"
      from False obtain a where "a \<in> Q" "a \<in> actions E" by blast
      with not_new[OF this] have "a \<in> Q \<and> a \<in> actions E \<and> \<not> is_new_action (action_obs E a)" by blast
      hence a': "a' \<in> Q \<and> a' \<in> actions E \<and> \<not> is_new_action (action_obs E a')"
        unfolding a'_def by(rule LeastI)
      { fix y
        assume y_le_a': "(action_order E)\<^sup>\<noteq>\<^sup>\<noteq> y a'"
        hence "y \<in> actions E" by(auto elim: action_orderE)
        have "y \<notin> Q"
        proof
          assume "y \<in> Q"
          hence y_not_new: "\<not> is_new_action (action_obs E y)"
            using `y \<in> actions E` by(rule not_new)
          with `y \<in> Q` `y \<in> actions E` have "a' \<le> y"
            unfolding a'_def by -(rule Least_le, blast)
          with y_le_a' y_not_new show False by(auto elim: action_orderE)
        qed }
      with a' show ?thesis by blast
    qed
  qed
qed

lemma action_order_is_new_actionD:
  "\<lbrakk> E \<turnstile> a \<le>a a'; is_new_action (action_obs E a') \<rbrakk> \<Longrightarrow> is_new_action (action_obs E a)"
by(auto elim: action_orderE)

subsection {* Program order *}

lemma program_orderI:
  assumes "E \<turnstile> a \<le>a a'" and "action_tid E a = action_tid E a'"
  shows "E \<turnstile> a \<le>po a'"
using assms unfolding program_order_def by auto

lemma program_orderE:
  assumes "E \<turnstile> a \<le>po a'"
  obtains t obs obs'
  where "E \<turnstile> a \<le>a a'"
  and "action_tid E a = t" "action_obs E a = obs"
  and "action_tid E a' = t" "action_obs E a' = obs'"
using assms unfolding program_order_def
by(cases "lnth E a")(cases "lnth E a'", auto simp add: action_obs_def action_tid_def)

lemma refl_on_program_order:
  "refl_onP (actions E) (program_order E)"
by(rule refl_onPI)(auto elim: action_orderE program_orderE intro: program_orderI refl_onPD[OF refl_action_order])

lemma antisym_program_order:
  "antisymP (program_order E)"
using antisymD[OF antisym_action_order]
by(auto intro: antisymI elim!: program_orderE)

lemma trans_program_order:
  "transP (program_order E)"
by(rule transI)(auto elim!: program_orderE intro: program_orderI dest: transPD[OF trans_action_order])

lemma porder_program_order:
  "porder_on (actions E) (program_order E)"
by(blast intro: porder_onI refl_on_program_order antisym_program_order trans_program_order)

lemma total_program_order_on_tactions:
  "total_onP (tactions E t) (program_order E)"
by(rule total_onPI)(auto elim: tactionsE simp add: program_order_def dest: total_onD[OF total_action_order])


subsection {* Synchronization order *}

lemma sync_orderI:
  "\<lbrakk> E \<turnstile> a \<le>a a'; a \<in> sactions P E; a' \<in> sactions P E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<le>so a'"
unfolding sync_order_def by blast

lemma sync_orderE:
  assumes "P,E \<turnstile> a \<le>so a'"
  obtains "a \<in> sactions P E" "a' \<in> sactions P E" "E \<turnstile> a \<le>a a'"
using assms unfolding sync_order_def by blast

lemma refl_on_sync_order:
  "refl_onP (sactions P E) (sync_order P E)"
by(rule refl_onPI)(fastforce elim: sync_orderE intro: sync_orderI refl_onPD[OF refl_action_order])+

lemma antisym_sync_order:
  "antisymP (sync_order P E)"
using antisymD[OF antisym_action_order]
by(rule antisymI)(auto elim!: sync_orderE)

lemma trans_sync_order:
  "transP (sync_order P E)"
by(rule transI)(auto elim!: sync_orderE intro: sync_orderI dest: transPD[OF trans_action_order])

lemma porder_sync_order:
  "porder_on (sactions P E) (sync_order P E)"
by(blast intro: porder_onI refl_on_sync_order antisym_sync_order trans_sync_order)

lemma total_sync_order:
  "total_onP (sactions P E) (sync_order P E)"
apply(rule total_onPI)
apply(simp add: sync_order_def)
apply(rule total_onPD[OF total_action_order])
apply simp_all
done

lemma torder_sync_order:
  "torder_on (sactions P E) (sync_order P E)"
by(blast intro: torder_onI porder_sync_order total_sync_order)

subsection {* Synchronizes with *}

lemma sync_withI:
  "\<lbrakk> P,E \<turnstile> a \<le>so a'; (action_tid E a, action_obs E a) \<leadsto>sw (action_tid E a', action_obs E a') \<rbrakk>
  \<Longrightarrow> P,E \<turnstile> a \<le>sw a'"
unfolding sync_with_def by blast

lemma sync_withE:
  assumes "P,E \<turnstile> a \<le>sw a'"
  obtains "P,E \<turnstile> a \<le>so a'" "(action_tid E a, action_obs E a) \<leadsto>sw (action_tid E a', action_obs E a')"
using assms unfolding sync_with_def by blast

lemma irrefl_synchronizes_with:
  "irreflP synchronizes_with"
by(rule irreflPI)(auto elim: synchronizes_with.cases)

lemma irrefl_sync_with:
  "irreflP (sync_with P E)"
by(rule irreflPI)(auto elim: sync_withE intro: irreflPD[OF irrefl_synchronizes_with])

lemma anitsym_sync_with:
  "antisymP (sync_with P E)"
using antisymPD[OF antisym_sync_order, of P E]
by -(rule antisymPI, auto elim: sync_withE)

lemma consistent_program_order_sync_order:
  "order_consistent (program_order E) (sync_order P E)"
apply(rule order_consistent_subset)
apply(rule antisym_order_consistent_self[OF antisym_action_order[of E]])
apply(blast elim: program_orderE sync_orderE)+
done

lemma consistent_program_order_sync_with:
  "order_consistent (program_order E) (sync_with P E)"
by(rule order_consistent_subset[OF consistent_program_order_sync_order])(blast elim: sync_withE)+

section {* Happens before *}

lemma porder_happens_before:
  "porder_on (actions E) (happens_before P E)"
unfolding po_sw_def [abs_def]
by(rule porder_on_sub_torder_on_tranclp_porder_onI[OF porder_program_order torder_sync_order consistent_program_order_sync_order])(auto elim: sync_withE)

lemma porder_tranclp_po_so:
  "porder_on (actions E) (\<lambda>a a'. program_order E a a' \<or> sync_order P E a a')^++"
by(rule porder_on_torder_on_tranclp_porder_onI[OF porder_program_order torder_sync_order consistent_program_order_sync_order]) auto

lemma happens_before_refl:
  assumes "a \<in> actions E"
  shows "P,E \<turnstile> a \<le>hb a"
using porder_happens_before[of E P]
by(rule porder_onE)(erule refl_onPD[OF _ assms])

lemma happens_before_into_po_so_tranclp:
  assumes "P,E \<turnstile> a \<le>hb a'"
  shows "(\<lambda>a a'. E \<turnstile> a \<le>po a' \<or> P,E \<turnstile> a \<le>so a')^++ a a'"
using assms unfolding po_sw_def [abs_def]
by(induct)(blast elim: sync_withE intro: tranclp.trancl_into_trancl)+

lemma po_so_extend_torder:
  obtains s
  where "torder_on (actions E) s"
  and "order_consistent (happens_before P E) s"
  and "order_consistent (sync_order P E) s"
proof -
  have "porder_on (actions E) (\<lambda>a a'. E \<turnstile> a \<le>po a' \<or> P,E \<turnstile> a \<le>so a')^++"
    by(rule porder_tranclp_po_so)
  then obtain s where tot: "torder_on (actions E) s"
    and consist: "order_consistent (\<lambda>a a'. E \<turnstile> a \<le>po a' \<or> P,E \<turnstile> a \<le>so a')^++ s"
    by(rule porder_extend_to_torder)
  note tot
  moreover from consist
  have "order_consistent (happens_before P E) s"
    by(rule order_consistent_subset)(rule happens_before_into_po_so_tranclp)
  moreover from consist
  have "order_consistent (sync_order P E) s"
    by(rule order_consistent_subset) blast
  ultimately show thesis by(rule that)
qed

lemma po_sw_into_action_order:
  "po_sw P E a a' \<Longrightarrow> E \<turnstile> a \<le>a a'"
by(auto elim: program_orderE sync_withE sync_orderE simp add: po_sw_def)

lemma happens_before_into_action_order:
  assumes "P,E \<turnstile> a \<le>hb a'"
  shows "E \<turnstile> a \<le>a a'"
using assms
by induct(blast intro: po_sw_into_action_order transPD[OF trans_action_order])+

lemma action_order_consistent_with_happens_before:
  "order_consistent (action_order E) (happens_before P E)"
by(blast intro: order_consistent_subset antisym_order_consistent_self antisym_action_order happens_before_into_action_order)

lemma happens_before_new_actionD:
  assumes hb: "P,E \<turnstile> a \<le>hb a'"
  and new: "is_new_action (action_obs E a')"
  shows "is_new_action (action_obs E a)" "action_tid E a = action_tid E a'" "a \<le> a'"
using hb
proof(induct rule: converse_tranclp_induct)
  case (base a)

  case 1 from new base show ?case
    by(auto dest: po_sw_into_action_order elim: action_orderE)
  case 2 from new base show ?case
    by(auto simp add: po_sw_def elim!: sync_withE elim: program_orderE synchronizes_with.cases)
  case 3 from new base show ?case
    by(auto dest: po_sw_into_action_order elim: action_orderE)
next
  case (step a a'')
  
  note po_sw = `po_sw P E a a''`
    and new = `is_new_action (action_obs E a'')`
    and tid = `action_tid E a'' = action_tid E a'`
  
  case 1 from new po_sw show ?case
    by(auto dest: po_sw_into_action_order elim: action_orderE)
  case 2 from new po_sw tid show ?case
    by(auto simp add: po_sw_def elim!: sync_withE elim: program_orderE synchronizes_with.cases)
  case 3 from new po_sw `a'' \<le> a'` show ?case
    by(auto dest!: po_sw_into_action_order elim!: action_orderE)
qed

lemma external_actions_not_new:
  "\<lbrakk> a \<in> external_actions E; is_new_action (action_obs E a) \<rbrakk> \<Longrightarrow> False"
by(erule external_actions.cases)(simp)

section {* Most recent writes and sequential consistency *}

lemma most_recent_write_for_fun:
  "\<lbrakk> P,E \<turnstile> ra \<leadsto>mrw wa; P,E \<turnstile> ra \<leadsto>mrw wa' \<rbrakk> \<Longrightarrow> wa = wa'"
apply(erule most_recent_write_for.cases)+
apply clarsimp
apply(erule meta_allE)+
apply(erule meta_impE)
 apply(rotate_tac 3)
 apply assumption
apply(erule (1) meta_impE)
apply(frule (1) action_loc_read_action_singleton)
 apply(rotate_tac 1)
 apply assumption
apply(fastforce dest: antisymPD[OF antisym_action_order] elim: write_actions.cases read_actions.cases)
done

lemma THE_most_recent_writeI: "P,E \<turnstile> r \<leadsto>mrw w \<Longrightarrow> (THE w. P,E \<turnstile> r \<leadsto>mrw w) = w"
by(blast dest: most_recent_write_for_fun)+

lemma most_recent_write_for_write_actionsD:
  assumes "P,E \<turnstile> ra \<leadsto>mrw wa"
  shows "wa \<in> write_actions E"
using assms by cases

lemma most_recent_write_recent:
  "\<lbrakk> P,E \<turnstile> r \<leadsto>mrw w; adal \<in> action_loc P E r; w' \<in> write_actions E; adal \<in> action_loc P E w' \<rbrakk> 
  \<Longrightarrow> E \<turnstile> w' \<le>a w \<or> E \<turnstile> r \<le>a w'"
apply(erule most_recent_write_for.cases)
apply(drule (1) action_loc_read_action_singleton)
 apply(rotate_tac 1)
 apply assumption
apply clarsimp
done

lemma is_write_seenI:
  "\<lbrakk> \<And>a ad al v. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v) \<rbrakk>
     \<Longrightarrow> ws a \<in> write_actions E;
     \<And>a ad al v. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v) \<rbrakk>
     \<Longrightarrow> (ad, al) \<in> action_loc P E (ws a);
     \<And>a ad al v. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v) \<rbrakk>
     \<Longrightarrow> value_written P E (ws a) (ad, al) = v;
     \<And>a ad al v. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v) \<rbrakk>
     \<Longrightarrow> \<not> P,E \<turnstile> a \<le>hb ws a;
     \<And>a ad al v. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v); is_volatile P al \<rbrakk>
     \<Longrightarrow> \<not> P,E \<turnstile> a \<le>so ws a;
     \<And>a ad al v a'. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v);
                      a' \<in> write_actions E; (ad, al) \<in> action_loc P E a'; P,E \<turnstile> ws a \<le>hb a';
                      P,E \<turnstile> a' \<le>hb a \<rbrakk> \<Longrightarrow> a' = ws a;
     \<And>a ad al v a'. \<lbrakk> a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v);
                      a' \<in> write_actions E; (ad, al) \<in> action_loc P E a'; is_volatile P al; P,E \<turnstile> ws a \<le>so a';
                      P,E \<turnstile> a' \<le>so a \<rbrakk> \<Longrightarrow> a' = ws a \<rbrakk>
  \<Longrightarrow> is_write_seen P E ws"
unfolding is_write_seen_def
by(blast 30)

lemma is_write_seenD:
  "\<lbrakk> is_write_seen P E ws; a \<in> read_actions E; action_obs E a = NormalAction (ReadMem ad al v) \<rbrakk>
  \<Longrightarrow> ws a \<in> write_actions E \<and> (ad, al) \<in> action_loc P E (ws a) \<and> value_written P E (ws a) (ad, al) = v \<and> \<not> P,E \<turnstile> a \<le>hb ws a \<and> (is_volatile P al \<longrightarrow> \<not> P,E \<turnstile> a \<le>so ws a) \<and>
     (\<forall>a' \<in> write_actions E. (ad, al) \<in> action_loc P E a' \<and> (P,E \<turnstile> ws a \<le>hb a' \<and> P,E \<turnstile> a' \<le>hb a \<or> is_volatile P al \<and> P,E \<turnstile> ws a \<le>so a' \<and> P,E \<turnstile> a' \<le>so a) \<longrightarrow> a' = ws a)"
unfolding is_write_seen_def by blast

lemma thread_start_actions_okI:
  "(\<And>a. \<lbrakk> a \<in> actions E; \<not> is_new_action (action_obs E a) \<rbrakk> 
    \<Longrightarrow> \<exists>i. i \<le> a \<and> action_obs E i = InitialThreadAction \<and> action_tid E i = action_tid E a)
  \<Longrightarrow> thread_start_actions_ok E"
unfolding thread_start_actions_ok_def by blast

lemma thread_start_actions_okD:
  "\<lbrakk> thread_start_actions_ok E; a \<in> actions E; \<not> is_new_action (action_obs E a) \<rbrakk> 
  \<Longrightarrow> \<exists>i. i \<le> a \<and> action_obs E i = InitialThreadAction \<and> action_tid E i = action_tid E a"
unfolding thread_start_actions_ok_def by blast

lemma thread_start_actions_ok_prefix:
  "\<lbrakk> thread_start_actions_ok E'; lprefix E E' \<rbrakk> \<Longrightarrow> thread_start_actions_ok E"
apply(clarsimp simp add: lprefix_def)
apply(rule thread_start_actions_okI)
apply(drule_tac a=a in thread_start_actions_okD)
  apply(simp add: actions_def)
  apply(metis Suc_ile_eq enat_le_plus_same(1) xtr6)
apply(auto simp add: action_obs_def lnth_lappend1 actions_def action_tid_def le_less_trans[where y="enat a", standard])
done

lemma wf_execI [intro?]:
  "\<lbrakk> is_write_seen P E ws;
    thread_start_actions_ok E \<rbrakk>
  \<Longrightarrow> P \<turnstile> (E, ws) \<surd>"
by simp

lemma wf_exec_is_write_seenD:
  "P \<turnstile> (E, ws) \<surd> \<Longrightarrow> is_write_seen P E ws"
by simp

lemma wf_exec_thread_start_actions_okD:
  "P \<turnstile> (E, ws) \<surd> \<Longrightarrow> thread_start_actions_ok E"
by simp

lemma sequentially_consistentI:
  "(\<And>r. r \<in> read_actions E \<Longrightarrow> P,E \<turnstile> r \<leadsto>mrw ws r)
  \<Longrightarrow> sequentially_consistent P (E, ws)"
by simp

lemma sequentially_consistentE:
  assumes "sequentially_consistent P (E, ws)" "a \<in> read_actions E"
  obtains "P,E \<turnstile> a \<leadsto>mrw ws a"
using assms by simp

declare sequentially_consistent.simps [simp del]

section {* Similar actions *}

text {* Similar actions differ only in the values written/read *}

inductive sim_action :: 
  "('addr, 'thread_id) obs_event action \<Rightarrow> ('addr, 'thread_id) obs_event action \<Rightarrow> bool" 
  ("_ \<approx> _" [50, 50] 51)
where
  InitialThreadAction: "InitialThreadAction \<approx> InitialThreadAction"
| ThreadFinishAction: "ThreadFinishAction \<approx> ThreadFinishAction"
| NewHeapElem: "NormalAction (NewHeapElem a hT) \<approx> NormalAction (NewHeapElem a hT)"
| ReadMem: "NormalAction (ReadMem ad al v) \<approx> NormalAction (ReadMem ad al v')"
| WriteMem: "NormalAction (WriteMem ad al v) \<approx> NormalAction (WriteMem ad al v')"
| ThreadStart: "NormalAction (ThreadStart t) \<approx> NormalAction (ThreadStart t)"
| ThreadJoin: "NormalAction (ThreadJoin t) \<approx> NormalAction (ThreadJoin t)"
| SyncLock: "NormalAction (SyncLock a) \<approx> NormalAction (SyncLock a)"
| SyncUnlock: "NormalAction (SyncUnlock a) \<approx> NormalAction (SyncUnlock a)"
| ExternalCall: "NormalAction (ExternalCall a M vs v) \<approx> NormalAction (ExternalCall a M vs v)"
| ObsInterrupt: "NormalAction (ObsInterrupt t) \<approx> NormalAction (ObsInterrupt t)"
| ObsInterrupted: "NormalAction (ObsInterrupted t) \<approx> NormalAction (ObsInterrupted t)"

definition sim_actions :: "('addr, 'thread_id) execution \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> bool" ("_ [\<approx>] _" [51, 50] 51)
where "sim_actions = llist_all2 (\<lambda>(t, a) (t', a'). t = t' \<and> a \<approx> a')"

lemma sim_action_refl [intro!, simp]:
  "obs \<approx> obs"
apply(cases obs)
 apply(rename_tac obs')
 apply(case_tac "obs'")
apply(auto intro: sim_action.intros)
done

inductive_cases sim_action_cases [elim!]:
  "InitialThreadAction \<approx> obs"
  "ThreadFinishAction \<approx> obs"
  "NormalAction (NewHeapElem a hT) \<approx> obs"
  "NormalAction (ReadMem ad al v) \<approx> obs"
  "NormalAction (WriteMem ad al v) \<approx> obs"
  "NormalAction (ThreadStart t) \<approx> obs"
  "NormalAction (ThreadJoin t) \<approx> obs"
  "NormalAction (SyncLock a) \<approx> obs"
  "NormalAction (SyncUnlock a) \<approx> obs"
  "NormalAction (ObsInterrupt t) \<approx> obs"
  "NormalAction (ObsInterrupted t) \<approx> obs"
  "NormalAction (ExternalCall a M vs v) \<approx> obs"

  "obs \<approx> InitialThreadAction"
  "obs \<approx> ThreadFinishAction"
  "obs \<approx> NormalAction (NewHeapElem a hT)"
  "obs \<approx> NormalAction (ReadMem ad al v')"
  "obs \<approx> NormalAction (WriteMem ad al v')"
  "obs \<approx> NormalAction (ThreadStart t)"
  "obs \<approx> NormalAction (ThreadJoin t)"
  "obs \<approx> NormalAction (SyncLock a)"
  "obs \<approx> NormalAction (SyncUnlock a)"
  "obs \<approx> NormalAction (ObsInterrupt t)"
  "obs \<approx> NormalAction (ObsInterrupted t)"
  "obs \<approx> NormalAction (ExternalCall a M vs v)"

inductive_simps sim_action_simps [simp]:
  "InitialThreadAction \<approx> obs"
  "ThreadFinishAction \<approx> obs"
  "NormalAction (NewHeapElem a hT) \<approx> obs"
  "NormalAction (ReadMem ad al v) \<approx> obs"
  "NormalAction (WriteMem ad al v) \<approx> obs"
  "NormalAction (ThreadStart t) \<approx> obs"
  "NormalAction (ThreadJoin t) \<approx> obs"
  "NormalAction (SyncLock a) \<approx> obs"
  "NormalAction (SyncUnlock a) \<approx> obs"
  "NormalAction (ObsInterrupt t) \<approx> obs"
  "NormalAction (ObsInterrupted t) \<approx> obs"
  "NormalAction (ExternalCall a M vs v) \<approx> obs"

  "obs \<approx> InitialThreadAction"
  "obs \<approx> ThreadFinishAction"
  "obs \<approx> NormalAction (NewHeapElem a hT)"
  "obs \<approx> NormalAction (ReadMem ad al v')"
  "obs \<approx> NormalAction (WriteMem ad al v')"
  "obs \<approx> NormalAction (ThreadStart t)"
  "obs \<approx> NormalAction (ThreadJoin t)"
  "obs \<approx> NormalAction (SyncLock a)"
  "obs \<approx> NormalAction (SyncUnlock a)"
  "obs \<approx> NormalAction (ObsInterrupt t)"
  "obs \<approx> NormalAction (ObsInterrupted t)"
  "obs \<approx> NormalAction (ExternalCall a M vs v)"

lemma sim_action_trans [trans]:
  "\<lbrakk> obs \<approx> obs'; obs' \<approx> obs'' \<rbrakk> \<Longrightarrow> obs \<approx> obs''"
by(erule sim_action.cases) auto

lemma sim_action_sym [sym]:
  assumes "obs \<approx> obs'"
  shows "obs' \<approx> obs"
using assms by cases simp_all

lemma sim_actions_sym [sym]:
  "E [\<approx>] E' \<Longrightarrow> E' [\<approx>] E"
unfolding sim_actions_def
by(auto simp add: llist_all2_conv_all_lnth split_beta intro: sim_action_sym)

lemma sim_actions_action_obsD:
  "E [\<approx>] E' \<Longrightarrow> action_obs E a \<approx> action_obs E' a"
unfolding sim_actions_def action_obs_def
by(cases "enat a < llength E")(auto dest: llist_all2_lnthD llist_all2_llengthD simp add: split_beta lnth_beyond split: enat.split)

lemma sim_actions_action_tidD:
  "E [\<approx>] E' \<Longrightarrow> action_tid E a = action_tid E' a"
unfolding sim_actions_def action_tid_def
by(cases "enat a < llength E")(auto dest: llist_all2_lnthD llist_all2_llengthD simp add: lnth_beyond split: enat.split)

lemma eq_into_sim_actions: 
  assumes "E = E'"
  shows "E [\<approx>] E'"
unfolding sim_actions_def assms
by(rule llist_all2_reflI)(auto)

section {* Well-formedness conditions for execution sets *}

locale executions_base =
  fixes \<E> :: "('addr, 'thread_id) execution set"
  and P :: "'m prog"

locale drf =
  executions_base \<E> P
  for \<E> :: "('addr, 'thread_id) execution set"
  and P :: "'m prog" +
  assumes \<E>_new_actions_for_fun:
  "\<lbrakk> E \<in> \<E>; a \<in> new_actions_for P E adal; a' \<in> new_actions_for P E adal \<rbrakk> \<Longrightarrow> a = a'"
  and \<E>_sequential_completion:
  "\<lbrakk> E \<in> \<E>; P \<turnstile> (E, ws) \<surd>; \<And>a. \<lbrakk> a < r; a \<in> read_actions E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<leadsto>mrw ws a \<rbrakk>
  \<Longrightarrow> \<exists>E' \<in> \<E>. \<exists>ws'. P \<turnstile> (E', ws') \<surd> \<and> ltake (enat r) E = ltake (enat r) E' \<and> sequentially_consistent P (E', ws') \<and>
                 action_tid E r = action_tid E' r \<and> action_obs E r \<approx> action_obs E' r \<and>
                 (r \<in> actions E \<longrightarrow> r \<in> actions E')"

locale executions_aux =
  executions_base \<E> P
  for \<E> :: "('addr, 'thread_id) execution set"
  and P :: "'m prog" +
  assumes init_before_read:
  "\<lbrakk>  E \<in> \<E>; P \<turnstile> (E, ws) \<surd>; r \<in> read_actions E; adal \<in> action_loc P E r; 
      \<And>a. \<lbrakk> a < r; a \<in> read_actions E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<leadsto>mrw ws a \<rbrakk>
  \<Longrightarrow> \<exists>i<r. i \<in> new_actions_for P E adal"
  and \<E>_new_actions_for_fun:
  "\<lbrakk> E \<in> \<E>; a \<in> new_actions_for P E adal; a' \<in> new_actions_for P E adal \<rbrakk> \<Longrightarrow> a = a'"

locale sc_legal =
  executions_aux \<E> P
  for \<E> :: "('addr, 'thread_id) execution set"
  and P :: "'m prog" +
  assumes \<E>_hb_completion:
  "\<lbrakk> E \<in> \<E>; P \<turnstile> (E, ws) \<surd>; \<And>a. \<lbrakk> a < r; a \<in> read_actions E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<leadsto>mrw ws a \<rbrakk>
  \<Longrightarrow> \<exists>E' \<in> \<E>. \<exists>ws'. P \<turnstile> (E', ws') \<surd> \<and> ltake (enat r) E = ltake (enat r) E' \<and>
                 (\<forall>a \<in> read_actions E'. if a < r then ws' a = ws a else P,E' \<turnstile> ws' a \<le>hb a) \<and>
                 action_tid E' r = action_tid E r \<and> 
                 (if r \<in> read_actions E then sim_action else op =) (action_obs E' r) (action_obs E r) \<and>
                 (r \<in> actions E \<longrightarrow> r \<in> actions E')"

locale jmm_consistent =
  drf \<E> P +
  sc_legal \<E> P
  for \<E> :: "('addr, 'thread_id) execution set"
  and P :: "'m prog"

section {* Legal executions *}

type_synonym ('addr, 'thread_id) justifying_execution = 
  "JMM_action set \<times> ('addr, 'thread_id) execution \<times> write_seen \<times> (JMM_action \<Rightarrow> JMM_action)"
type_synonym ('addr, 'thread_id) justification = "nat \<Rightarrow> ('addr, 'thread_id) justifying_execution"

definition committed :: "('addr, 'thread_id) justifying_execution \<Rightarrow> JMM_action set"
where "committed = fst"

definition justifying_exec :: "('addr, 'thread_id) justifying_execution \<Rightarrow> ('addr, 'thread_id) execution"
where "justifying_exec = fst o snd"

definition justifying_ws :: "('addr, 'thread_id) justifying_execution \<Rightarrow> write_seen"
where "justifying_ws = fst o snd o snd"

definition action_translation :: "('addr, 'thread_id) justifying_execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action"
where "action_translation = snd o snd o snd"

definition wf_action_translation_on :: 
  "('addr, 'thread_id) execution \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action set \<Rightarrow> (JMM_action \<Rightarrow> JMM_action) \<Rightarrow> bool"
where
  "wf_action_translation_on E E' A f \<longleftrightarrow>
   A \<subseteq> actions E \<and> f ` A \<subseteq> actions E' \<and> inj_on f (actions E) \<and> 
   (\<forall>a \<in> A. action_tid E a = action_tid E' (f a) \<and> action_obs E a \<approx> action_obs E' (f a))"

text {*
  Rule 8 of the justification for the JMM is incorrect because there might be no
  transitive reduction of the happens-before relation for an infinite execution, if
  infinitely many initialisation actions have to be ordered before the start
  action of every thread.
  Hence, @{text "is_justified_by"} omits this constraint.
*}

abbreviation wf_action_translation :: "('addr, 'thread_id) execution \<Rightarrow> ('addr, 'thread_id) justifying_execution \<Rightarrow> bool"
where
  "wf_action_translation E J \<equiv> 
   wf_action_translation_on (justifying_exec J) E (committed J) (action_translation J)"

primrec is_justified_by ::
  "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<times> write_seen \<Rightarrow> ('addr, 'thread_id) justification \<Rightarrow> bool" 
  ("_ \<turnstile> _ justified'_by _" [51, 50, 50] 50)
where
  "P \<turnstile> (E, ws) justified_by J \<longleftrightarrow>

  (* Committed actions are an ascending chain with all actions of E as a limit *)
  (committed (J 0) = {} \<and>
   (\<forall>n. action_translation (J n) ` committed (J n) \<subseteq> action_translation (J (Suc n)) ` committed (J (Suc n))) \<and>
   actions E = (\<Union>n. action_translation (J n) ` committed (J n))) \<and>

  (* Only well-formed executions used in justification *)
  (\<forall>n. P \<turnstile> (justifying_exec (J n), justifying_ws (J n)) \<surd>) \<and>

  (* Committed actions must be actions -- JMM constraint 1 *)
  (\<forall>n. committed (J n) \<subseteq> actions (justifying_exec (J n))) \<and>

  (* happens-before for committed actions as in E -- JMM constraint 2 *)
  (\<forall>n. happens_before P (justifying_exec (J n)) |` committed (J n) =
       inv_imageP (happens_before P E) (action_translation (J n)) |` committed (J n)) \<and>

  (* synchronization order for committed actions as in E -- JMM constraint 3 *)
  (\<forall>n. sync_order P (justifying_exec (J n)) |` committed (J n) =
       inv_imageP (sync_order P E) (action_translation (J n)) |` committed (J n)) \<and>

  (* value-written for committed write actions as in E -- JMM constraint 4 *)
  (\<forall>n. \<forall>w \<in> write_actions (justifying_exec (J n)) \<inter> committed (J n). 
       let w' = action_translation (J n) w
       in (\<forall>adal \<in> action_loc P E w'. value_written P (justifying_exec (J n)) w adal = value_written P E w' adal)) \<and>

  (* write-seen for committed reads as in E -- JMM constraint 5 -- restricted to read actions *)
  (\<forall>n. \<forall>r' \<in> read_actions (justifying_exec (J n)) \<inter> committed (J n).
       let r = action_translation (J n) r';
           r'' = inv_into (actions (justifying_exec (J (Suc n)))) (action_translation (J (Suc n))) r
       in action_translation (J (Suc n)) (justifying_ws (J (Suc n)) r'') = ws r) \<and>

  (* uncommited reads see writes that happen before them -- JMM constraint 6 *)
  (\<forall>n. \<forall>r' \<in> read_actions (justifying_exec (J (Suc n))).
       action_translation (J (Suc n)) r' \<in> action_translation (J n) ` committed (J n) \<or> 
       P,justifying_exec (J (Suc n)) \<turnstile> justifying_ws (J (Suc n)) r' \<le>hb r') \<and>

  (* newly committed reads see already committed writes and write-seen
     relationship must not change any more  -- JMM constraint 7*)
  (\<forall>n. \<forall>r' \<in> read_actions (justifying_exec (J (Suc n))) \<inter> committed (J (Suc n)).
       let r = action_translation (J (Suc n)) r';
           committed_n = action_translation (J n) ` committed (J n)
       in r \<in> committed_n \<or>
          (action_translation (J (Suc n)) (justifying_ws (J (Suc n)) r') \<in> committed_n \<and> ws r \<in> committed_n)) \<and>

  (* external actions must be committed as soon as hb-subsequent actions are committed  -- JMM constraint 9 *)
  (\<forall>n. \<forall>a \<in> external_actions (justifying_exec (J n)). \<forall>a' \<in> committed (J n).
       P,justifying_exec (J n) \<turnstile> a \<le>hb a' \<longrightarrow> a \<in> committed (J n)) \<and>

  (* well-formedness conditions for action translations *)
  (\<forall>n. wf_action_translation_on (justifying_exec (J n)) E (committed (J n)) (action_translation (J n)))"

declare is_justified_by.simps [simp del]

definition conflict ::
  "'m prog \<Rightarrow> ('addr, 'thread_id) execution \<Rightarrow> JMM_action \<Rightarrow> JMM_action \<Rightarrow> bool" 
  ("_,_ \<turnstile>/(_)\<dagger>(_)" [51,50,50,50] 51)
where 
  "P,E \<turnstile> a \<dagger> a' \<longleftrightarrow>
   (a \<in> read_actions E \<and> a' \<in> write_actions E \<or>
    a \<in> write_actions E \<and> a' \<in> read_actions E \<or>
    a \<in> write_actions E \<and> a' \<in> write_actions E) \<and>
   (action_loc P E a \<inter> action_loc P E a' \<noteq> {})"

definition correctly_synchronized :: "'m prog \<Rightarrow> ('addr, 'thread_id) execution set \<Rightarrow> bool"
where
  "correctly_synchronized P \<E> \<longleftrightarrow>
  (\<forall>E \<in> \<E>. \<forall>ws. P \<turnstile> (E, ws) \<surd> \<longrightarrow> sequentially_consistent P (E, ws) \<longrightarrow> 
                   (\<forall>a \<in> actions E. \<forall>a' \<in> actions E. P,E \<turnstile> a \<dagger> a' \<longrightarrow> P,E \<turnstile> a \<le>hb a' \<or> P,E \<turnstile> a' \<le>hb a))"

primrec legal_execution :: 
  "'m prog \<Rightarrow> ('addr, 'thread_id) execution set \<Rightarrow> ('addr, 'thread_id) execution \<times> write_seen \<Rightarrow> bool"
where
  "legal_execution P \<E> (E, ws) \<longleftrightarrow>
   E \<in> \<E> \<and> P \<turnstile> (E, ws) \<surd> \<and> 
   (\<exists>J. P \<turnstile> (E, ws) justified_by J \<and> range (justifying_exec \<circ> J) \<subseteq> \<E>)"

declare legal_execution.simps [simp del]

lemma sym_conflict:
  "symP (conflict P E)"
unfolding conflict_def
by(rule symPI) blast

lemma legal_executionI:
  "\<lbrakk> E \<in> \<E>; P \<turnstile> (E, ws) \<surd>; P \<turnstile> (E, ws) justified_by J; range (justifying_exec \<circ> J) \<subseteq> \<E> \<rbrakk>
  \<Longrightarrow> legal_execution P \<E> (E, ws)"
unfolding legal_execution.simps by blast

lemma legal_executionE:
  assumes "legal_execution P \<E> (E, ws)"
  obtains J where "E \<in> \<E>" "P \<turnstile> (E, ws) \<surd>" "P \<turnstile> (E, ws) justified_by J" "range (justifying_exec \<circ> J) \<subseteq> \<E>"
using assms unfolding legal_execution.simps by blast

lemma legal_\<E>D: "legal_execution P \<E> (E, ws) \<Longrightarrow> E \<in> \<E>"
by(erule legal_executionE)

lemma legal_wf_execD:
  "legal_execution P \<E> Ews \<Longrightarrow> P \<turnstile> Ews \<surd>"
by(cases Ews)(auto elim: legal_executionE)

lemma correctly_synchronizedD:
  "\<lbrakk> correctly_synchronized P \<E>; E \<in> \<E>; P \<turnstile> (E, ws) \<surd>; sequentially_consistent P (E, ws) \<rbrakk>
  \<Longrightarrow> \<forall>a a'. a \<in> actions E \<longrightarrow> a' \<in> actions E \<longrightarrow> P,E \<turnstile> a \<dagger> a' \<longrightarrow> P,E \<turnstile> a \<le>hb a' \<or> P,E \<turnstile> a' \<le>hb a"
unfolding correctly_synchronized_def by blast

lemma committed_conv [simp]: "committed (A, E, ws, \<phi>) = A"
by(simp add: committed_def)

lemma justifying_exec_conv [simp]: "justifying_exec (A, E, ws, \<phi>) = E"
by(simp add: justifying_exec_def)

lemma justifying_ws_conv [simp]: "justifying_ws (A, E, ws, \<phi>) = ws"
by(simp add: justifying_ws_def)

lemma action_translation_conv [simp]: "action_translation (A, E, ws, \<phi>) = \<phi>"
by(simp add: action_translation_def)

lemma wf_action_translation_on_actionD:
  "\<lbrakk> wf_action_translation_on E E' A f; a \<in> A \<rbrakk> 
  \<Longrightarrow> action_tid E a = action_tid E' (f a) \<and> action_obs E a \<approx> action_obs E' (f a) \<and> f a \<in> actions E'"
unfolding wf_action_translation_on_def by blast

lemma wf_action_translation_on_inj_onD:
  "wf_action_translation_on E E' A f \<Longrightarrow> inj_on f (actions E)"
unfolding wf_action_translation_on_def by simp

lemma justified_write_seen_hb_read_committed:
  assumes J: "P \<turnstile> (E, ws) justified_by J"
  and r: "r \<in> read_actions (justifying_exec (J n))" "r \<in> committed (J n)"
  shows "justifying_ws (J n) r \<in> committed (J n)" (is ?thesis1)
  and "ws (action_translation (J n) r) \<in> action_translation (J n) ` committed (J n)" (is ?thesis2)
proof -
  have "justifying_ws (J n) r \<in> committed (J n) \<and>
    ws (action_translation (J n) r) \<in> action_translation (J n) ` committed (J n)"
    using r
  proof(induct n arbitrary: r)
    case 0
    from J have [simp]: "committed (J 0) = {}" by(simp add: is_justified_by.simps)
    with 0 show ?case by simp
  next
    case (Suc n)
    let ?E = "\<lambda>n. justifying_exec (J n)"
      and ?ws = "\<lambda>n. justifying_ws (J n)"
      and ?C = "\<lambda>n. committed (J n)"
      and ?\<phi> = "\<lambda>n. action_translation (J n)"
    
    note r = `r \<in> read_actions (?E (Suc n))`
    hence "r \<in> actions (?E (Suc n))" by simp
    
    from J have wfan: "wf_action_translation_on (?E n) E (?C n) (?\<phi> n)"
      and wfaSn: "wf_action_translation_on (?E (Suc n)) E (?C (Suc n)) (?\<phi> (Suc n))"
      by(simp_all add: is_justified_by.simps)
    
    from wfaSn have injSn: "inj_on (?\<phi> (Suc n)) (actions (?E (Suc n)))"
      by(rule wf_action_translation_on_inj_onD)
    from J have C_sub_A: "?C (Suc n) \<subseteq> actions (?E (Suc n))"
      by(simp add: is_justified_by.simps)
    from J have CnCSn: "?\<phi> n ` ?C n \<subseteq> ?\<phi> (Suc n) ` ?C (Suc n)"
      by(simp add: is_justified_by.simps)
    
    from J have wsSn: "is_write_seen P (?E (Suc n)) (?ws (Suc n))"
      by(simp add: is_justified_by.simps)
    from r obtain ad al v where "action_obs (?E (Suc n)) r = NormalAction (ReadMem ad al v)" by cases
    from is_write_seenD[OF wsSn r this]
    have wsSn: "?ws (Suc n) r \<in> actions (?E (Suc n))" by simp

    show ?case
    proof(cases "?\<phi> (Suc n) r \<in> ?\<phi> n ` ?C n")
      case True
      then obtain r' where r': "r' \<in> ?C n"
        and r_r': "?\<phi> (Suc n) r = ?\<phi> n r'" by(auto)
      from r' wfan have "action_tid (?E n) r' = action_tid E (?\<phi> n r')"
        and "action_obs (?E n) r' \<approx> action_obs E (?\<phi> n r')"
        by(blast dest: wf_action_translation_on_actionD)+
      moreover from r' CnCSn have "?\<phi> (Suc n) r \<in> ?\<phi> (Suc n) ` ?C (Suc n)" 
        unfolding r_r' by auto
      hence "r \<in> ?C (Suc n)"
        unfolding inj_on_image_mem_iff[OF injSn C_sub_A `r \<in> actions (?E (Suc n))`] .
      with wfaSn have "action_tid (?E (Suc n)) r = action_tid E (?\<phi> (Suc n) r)"
        and "action_obs (?E (Suc n)) r \<approx> action_obs E (?\<phi> (Suc n) r)"
        by(blast dest: wf_action_translation_on_actionD)+
      ultimately have tid: "action_tid (?E n) r' = action_tid (?E (Suc n)) r"
        and obs: "action_obs (?E n) r' \<approx> action_obs (?E (Suc n)) r"
        unfolding r_r' by(auto intro: sim_action_trans sim_action_sym)
      
      from J have "?C n \<subseteq> actions (?E n)" by(simp add: is_justified_by.simps)
      with r' have "r' \<in> actions (?E n)" by blast
      with r obs have "r' \<in> read_actions (?E n)"
        by cases(auto intro: read_actions.intros)
      hence "?ws n r' \<in> ?C n \<and> ws (?\<phi> n r') \<in> ?\<phi> n ` ?C n" using r' by(rule Suc)
      then obtain "?ws n r' \<in> ?C n" and ws: "ws (?\<phi> n r') \<in> ?\<phi> n ` ?C n" ..

      have r_conv_inv: "r = inv_into (actions (?E (Suc n))) (?\<phi> (Suc n)) (?\<phi> n r')"
        using `r \<in> actions (?E (Suc n))` unfolding r_r'[symmetric]
        by(simp add: inv_into_f_f[OF injSn])
      with `r' \<in> ?C n` r J `r' \<in> read_actions (?E n)`
      have ws_eq: "?\<phi> (Suc n) (?ws (Suc n) r) = ws (?\<phi> n r')"
        by(simp add: is_justified_by.simps Let_def)
      with ws CnCSn have "?\<phi> (Suc n) (?ws (Suc n) r) \<in> ?\<phi> (Suc n) ` ?C (Suc n)" by auto
      hence "?ws (Suc n) r \<in> ?C (Suc n)"
        by(subst (asm) inj_on_image_mem_iff[OF injSn C_sub_A wsSn])
      moreover from ws CnCSn have "ws (?\<phi> (Suc n) r) \<in> ?\<phi> (Suc n) ` ?C (Suc n)"
        unfolding r_r' by auto
      ultimately show ?thesis by simp
    next
      case False
      with r `r \<in> ?C (Suc n)` J
      have "?\<phi> (Suc n) (?ws (Suc n) r) \<in> ?\<phi> n ` ?C n" 
        and "ws (?\<phi> (Suc n) r) \<in> ?\<phi> n ` ?C n"
        unfolding is_justified_by.simps Let_def by blast+
      hence "?\<phi> (Suc n) (?ws (Suc n) r) \<in> ?\<phi> (Suc n) ` ?C (Suc n)"
        and "ws (?\<phi> (Suc n) r) \<in> ?\<phi> (Suc n) ` ?C (Suc n)"
        using CnCSn by blast+
      thus ?thesis by(simp add: inj_on_image_mem_iff[OF injSn C_sub_A wsSn])
    qed
  qed
  thus ?thesis1 ?thesis2 by simp_all
qed

section {* Executions with common prefix *}

lemma actions_change_prefix:
  assumes read: "a \<in> actions E"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and rn: "enat a < n"
  shows "a \<in> actions E'"
using llist_all2_llengthD[OF prefix[unfolded sim_actions_def]] read rn
by(simp add: actions_def min_def split: split_if_asm)

lemma action_obs_change_prefix:
  assumes prefix: "ltake n E [\<approx>] ltake n E'"
  and rn: "enat a < n"
  shows "action_obs E a \<approx> action_obs E' a"
proof -
  from rn have "action_obs E a = action_obs (ltake n E) a"
    by(simp add: action_obs_def lnth_ltake)
  also from prefix have "\<dots> \<approx> action_obs (ltake n E') a"
    by(rule sim_actions_action_obsD)
  also have "\<dots> = action_obs E' a" using rn
    by(simp add: action_obs_def lnth_ltake)
  finally show ?thesis .
qed

lemma action_obs_change_prefix_eq:
  assumes prefix: "ltake n E = ltake n E'"
  and rn: "enat a < n"
  shows "action_obs E a = action_obs E' a"
proof -
  from rn have "action_obs E a = action_obs (ltake n E) a"
    by(simp add: action_obs_def lnth_ltake)
  also from prefix have "\<dots> = action_obs (ltake n E') a"
    by(simp add: action_obs_def)
  also have "\<dots> = action_obs E' a" using rn
    by(simp add: action_obs_def lnth_ltake)
  finally show ?thesis .
qed

lemma read_actions_change_prefix:
  assumes read: "r \<in> read_actions E"
  and prefix: "ltake n E [\<approx>] ltake n E'" "enat r < n"
  shows "r \<in> read_actions E'"
using read action_obs_change_prefix[OF prefix] actions_change_prefix[OF _ prefix]
by(cases)(auto intro: read_actions.intros)

lemma sim_action_is_write_action_eq:
  assumes "obs \<approx> obs'"
  shows "is_write_action obs \<longleftrightarrow> is_write_action obs'"
using assms by cases simp_all

lemma write_actions_change_prefix:
  assumes "write": "w \<in> write_actions E"
  and prefix: "ltake n E [\<approx>] ltake n E'" "enat w < n"
  shows "w \<in> write_actions E'"
using "write" action_obs_change_prefix[OF prefix] actions_change_prefix[OF _ prefix]
by(cases)(auto intro: write_actions.intros dest: sim_action_is_write_action_eq)

lemma action_loc_change_prefix:
  assumes "ltake n E [\<approx>] ltake n E'" "enat a < n"
  shows "action_loc P E a = action_loc P E' a"
using action_obs_change_prefix[OF assms]
by(fastforce elim!: action_loc_aux_cases intro: action_loc_aux_intros)

lemma sim_action_is_new_action_eq:
  assumes "obs \<approx> obs'"
  shows "is_new_action obs = is_new_action obs'"
using assms by cases auto

lemma action_order_change_prefix:
  assumes ao: "E \<turnstile> a \<le>a a'"
  and prefix: "ltake n E [\<approx>] ltake n E'" 
  and an: "enat a < n"
  and a'n: "enat a' < n"
  shows "E' \<turnstile> a \<le>a a'"
using ao actions_change_prefix[OF _ prefix an] actions_change_prefix[OF _ prefix a'n] action_obs_change_prefix[OF prefix an] action_obs_change_prefix[OF prefix a'n]
by(auto simp add: action_order_def split: split_if_asm dest: sim_action_is_new_action_eq)


lemma value_written_change_prefix:
  assumes eq: "ltake n E = ltake n E'"
  and an: "enat a < n"
  shows "value_written P E a = value_written P E' a"
using action_obs_change_prefix_eq[OF eq an]
by(simp add: value_written_def fun_eq_iff)

lemma action_tid_change_prefix:
  assumes prefix: "ltake n E [\<approx>] ltake n E'" 
  and an: "enat a < n"
  shows "action_tid E a = action_tid E' a"
proof -
  from an have "action_tid E a = action_tid (ltake n E) a"
    by(simp add: action_tid_def lnth_ltake)
  also from prefix have "\<dots> = action_tid (ltake n E') a"
    by(rule sim_actions_action_tidD)
  also from an have "\<dots> = action_tid E' a"
    by(simp add: action_tid_def lnth_ltake)
  finally show ?thesis .
qed

lemma program_order_change_prefix:
  assumes po: "E \<turnstile> a \<le>po a'"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and an: "enat a < n"
  and a'n: "enat a' < n"
  shows "E' \<turnstile> a \<le>po a'"
using po action_order_change_prefix[OF _ prefix an a'n]
  action_tid_change_prefix[OF prefix an] action_tid_change_prefix[OF prefix a'n]
by(auto elim!: program_orderE intro: program_orderI)

lemma sim_action_sactionD:
  assumes "obs \<approx> obs'"
  shows "saction P obs \<longleftrightarrow> saction P obs'"
using assms by cases simp_all

lemma sactions_change_prefix:
  assumes sync: "a \<in> sactions P E"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and rn: "enat a < n"
  shows "a \<in> sactions P E'"
using sync action_obs_change_prefix[OF prefix rn] actions_change_prefix[OF _ prefix rn]
unfolding sactions_def by(simp add: sim_action_sactionD)

lemma sync_order_change_prefix:
  assumes so: "P,E \<turnstile> a \<le>so a'"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and an: "enat a < n"
  and a'n: "enat a' < n"
  shows "P,E' \<turnstile> a \<le>so a'"
using so action_order_change_prefix[OF _ prefix an a'n] sactions_change_prefix[OF _ prefix an, of P] sactions_change_prefix[OF _ prefix a'n, of P]
by(simp add: sync_order_def)

lemma sim_action_synchronizes_withD:
  assumes "obs \<approx> obs'" "obs'' \<approx> obs'''"
  shows "(t, obs) \<leadsto>sw (t', obs'') \<longleftrightarrow> (t, obs') \<leadsto>sw (t', obs''')"
using assms
by(auto elim!: sim_action.cases synchronizes_with.cases intro: synchronizes_with.intros)

lemma sync_with_change_prefix:
  assumes sw: "P,E \<turnstile> a \<le>sw a'"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and an: "enat a < n"
  and a'n: "enat a' < n"
  shows "P,E' \<turnstile> a \<le>sw a'"
using sw sync_order_change_prefix[OF _ prefix an a'n, of P] 
  action_tid_change_prefix[OF prefix an] action_tid_change_prefix[OF prefix a'n]
  action_obs_change_prefix[OF prefix an] action_obs_change_prefix[OF prefix a'n]
by(auto simp add: sync_with_def dest: sim_action_synchronizes_withD)


lemma po_sw_change_prefix:
  assumes posw: "po_sw P E a a'"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and an: "enat a < n"
  and a'n: "enat a' < n"
  shows "po_sw P E' a a'"
using posw sync_with_change_prefix[OF _ prefix an a'n, of P] program_order_change_prefix[OF _ prefix an a'n]
by(auto simp add: po_sw_def)


lemma happens_before_new_not_new:
  assumes tsa_ok: "thread_start_actions_ok E"
  and a: "a \<in> actions E" 
  and a': "a' \<in> actions E"
  and new_a: "is_new_action (action_obs E a)"
  and new_a': "\<not> is_new_action (action_obs E a')"
  shows "P,E \<turnstile> a \<le>hb a'"
proof -
  from thread_start_actions_okD[OF tsa_ok a' new_a']
  obtain i where "i \<le> a'"
    and obs_i: "action_obs E i = InitialThreadAction" 
    and "action_tid E i = action_tid E a'" by auto
  from `i \<le> a'` a' have "i \<in> actions E"
    by(auto simp add: actions_def le_less_trans[where y="enat a'"])
  with `i \<le> a'` obs_i a' new_a' have "E \<turnstile> i \<le>a a'" by(simp add: action_order_def)
  hence "E \<turnstile> i \<le>po a'" using `action_tid E i = action_tid E a'`
    by(rule program_orderI)
  
  moreover {
    from `i \<in> actions E` obs_i
    have "i \<in> sactions P E" by(auto intro: sactionsI)
    from a `i \<in> actions E` new_a obs_i have "E \<turnstile> a \<le>a i" by(simp add: action_order_def)
    moreover from a new_a have "a \<in> sactions P E" by(auto intro: sactionsI)
    ultimately have "P,E \<turnstile> a \<le>so i" using `i \<in> sactions P E` by(rule sync_orderI)
    moreover from new_a obs_i have "(action_tid E a, action_obs E a) \<leadsto>sw (action_tid E i, action_obs E i)"
      by cases(auto intro: synchronizes_with.intros)
    ultimately have "P,E \<turnstile> a \<le>sw i" by(rule sync_withI) }
  ultimately show ?thesis unfolding po_sw_def [abs_def] by(blast intro: tranclp.r_into_trancl tranclp_trans)
qed

lemma happens_before_change_prefix:
  assumes hb: "P,E \<turnstile> a \<le>hb a'"
  and tsa_ok: "thread_start_actions_ok E'"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and an: "enat a < n"
  and a'n: "enat a' < n"
  shows "P,E' \<turnstile> a \<le>hb a'"
using hb an a'n
proof induct
  case (base a')
  thus ?case by(rule tranclp.r_into_trancl[where r="po_sw P E'", OF po_sw_change_prefix[OF _ prefix]])
next
  case (step a' a'')
  show ?case
  proof(cases "is_new_action (action_obs E a') \<and> \<not> is_new_action (action_obs E a'')")
    case False
    from `po_sw P E a' a''` have "E \<turnstile> a' \<le>a a''" by(rule po_sw_into_action_order)
    with `enat a'' < n` False have "enat a' < n"
      by(safe elim!: action_orderE)(metis Suc_leI Suc_n_not_le_n enat_ord_simps(2) le_trans nat_neq_iff xtrans(10))+
    with `enat a < n` have "P,E' \<turnstile> a \<le>hb a'" by(rule step)
    moreover from `po_sw P E a' a''` prefix `enat a' < n` `enat a'' < n`
    have "po_sw P E' a' a''" by(rule po_sw_change_prefix)
    ultimately show ?thesis ..
  next
    case True
    then obtain new_a': "is_new_action (action_obs E a')"
      and "\<not> is_new_action (action_obs E a'')" ..
    from `P,E \<turnstile> a \<le>hb a'` new_a'
    have new_a: "is_new_action (action_obs E a)"
      and tid: "action_tid E a = action_tid E a'"
      and "a \<le> a'" by(rule happens_before_new_actionD)+
    
    note tsa_ok moreover
    from porder_happens_before[of E P] have "a \<in> actions E"
      by(rule porder_onE)(erule refl_onPD1, rule `P,E \<turnstile> a \<le>hb a'`)
    hence "a \<in> actions E'" using an by(rule actions_change_prefix[OF _ prefix])
    moreover
    from `po_sw P E a' a''` refl_on_program_order[of E] refl_on_sync_order[of P E]
    have "a'' \<in> actions E"
      unfolding po_sw_def by(auto dest: refl_onPD2 elim!: sync_withE)
    hence "a'' \<in> actions E'" using `enat a'' < n` by(rule actions_change_prefix[OF _ prefix])
    moreover
    from new_a action_obs_change_prefix[OF prefix an] 
    have "is_new_action (action_obs E' a)" by(cases) auto
    moreover
    from `\<not> is_new_action (action_obs E a'')` action_obs_change_prefix[OF prefix `enat a'' < n`]
    have "\<not> is_new_action (action_obs E' a'')" by(auto elim: is_new_action.cases)
    ultimately show "P,E' \<turnstile> a \<le>hb a''" by(rule happens_before_new_not_new)
  qed
qed

lemma thread_start_actions_ok_change:
  assumes tsa: "thread_start_actions_ok E"
  and sim: "E [\<approx>] E'"
  shows "thread_start_actions_ok E'"
proof(rule thread_start_actions_okI)
  fix a
  assume "a \<in> actions E'" "\<not> is_new_action (action_obs E' a)"
  from sim have len_eq: "llength E = llength E'" by(simp add: sim_actions_def)(rule llist_all2_llengthD)
  with sim have sim': "ltake (llength E) E [\<approx>] ltake (llength E) E'" by(simp add: ltake_all)

  from `a \<in> actions E'` len_eq have "enat a < llength E" by(simp add: actions_def)
  with `a \<in> actions E'` sim'[symmetric] have "a \<in> actions E" by(rule actions_change_prefix)
  moreover have "\<not> is_new_action (action_obs E a)"
    using action_obs_change_prefix[OF sim' `enat a < llength E`] `\<not> is_new_action (action_obs E' a)`
    by(auto elim!: is_new_action.cases)
  ultimately obtain i where "i \<le> a" "action_obs E i = InitialThreadAction" "action_tid E i = action_tid E a"
    by(blast dest: thread_start_actions_okD[OF tsa])
  thus "\<exists>i \<le> a. action_obs E' i = InitialThreadAction \<and> action_tid E' i = action_tid E' a"
    using action_tid_change_prefix[OF sim', of i] action_tid_change_prefix[OF sim', of a] `enat a < llength E`
      action_obs_change_prefix[OF sim', of i]
    by(cases "llength E")(auto intro!: exI[where x=i])
qed

context executions_aux begin

lemma \<E>_new_same_addr_singleton:
  assumes E: "E \<in> \<E>"
  shows "\<exists>a. new_actions_for P E adal \<subseteq> {a}"
by(blast dest: \<E>_new_actions_for_fun[OF E])

lemma new_action_before_read:
  assumes E: "E \<in> \<E>"
  and wf: "P \<turnstile> (E, ws) \<surd>"
  and ra: "ra \<in> read_actions E"
  and adal: "adal \<in> action_loc P E ra"
  and new: "wa \<in> new_actions_for P E adal"
  and sc: "\<And>a. \<lbrakk> a < ra; a \<in> read_actions E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<leadsto>mrw ws a"
  shows "wa < ra"
using \<E>_new_same_addr_singleton[OF E, of adal] init_before_read[OF E wf ra adal sc] new
by auto

lemma mrw_before:
  assumes E: "E \<in> \<E>"
  and wf: "P \<turnstile> (E, ws) \<surd>"
  and mrw: "P,E \<turnstile> r \<leadsto>mrw w"
  and sc: "\<And>a. \<lbrakk> a < r; a \<in> read_actions E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<leadsto>mrw ws a"
  shows "w < r"
using mrw read_actions_not_write_actions[of r E]
apply cases
apply(erule action_orderE)
 apply(erule (1) new_action_before_read[OF E wf])
  apply(simp add: new_actions_for_def)
 apply(erule (1) sc)
apply(cases "w = r")
apply auto
done

lemma mrw_change_prefix:
  assumes E': "E' \<in> \<E>"
  and mrw: "P,E \<turnstile> r \<leadsto>mrw w"
  and tsa_ok: "thread_start_actions_ok E'"
  and prefix: "ltake n E [\<approx>] ltake n E'"
  and an: "enat r < n"
  and a'n: "enat w < n"
  shows "P,E' \<turnstile> r \<leadsto>mrw w"
using mrw
proof cases
  fix adal
  assume r: "r \<in> read_actions E"
    and adal_r: "adal \<in> action_loc P E r"
    and war: "E \<turnstile> w \<le>a r"
    and w: "w \<in> write_actions E"
    and adal_w: "adal \<in> action_loc P E w"
    and mrw: "\<And>wa'. \<lbrakk>wa' \<in> write_actions E; adal \<in> action_loc P E wa'\<rbrakk>
              \<Longrightarrow> E \<turnstile> wa' \<le>a w \<or> E \<turnstile> r \<le>a wa'"
  show ?thesis
  proof(rule most_recent_write_for.intros)
    from r prefix an show r': "r \<in> read_actions E'"
      by(rule read_actions_change_prefix)
    from adal_r show "adal \<in> action_loc P E' r"
      by(simp add: action_loc_change_prefix[OF prefix[symmetric] an])
    from war prefix a'n an show "E' \<turnstile> w \<le>a r" by(rule action_order_change_prefix)
    from w prefix a'n show w': "w \<in> write_actions E'" by(rule write_actions_change_prefix)
    from adal_w show adal_w': "adal \<in> action_loc P E' w" by(simp add: action_loc_change_prefix[OF prefix[symmetric] a'n])

    fix wa'
    assume wa': "wa' \<in> write_actions E'" 
      and adal_wa': "adal \<in> action_loc P E' wa'"
    show "E' \<turnstile> wa' \<le>a w \<or> E' \<turnstile> r \<le>a wa'"
    proof(cases "enat wa' < n")
      case True
      note wa'n = this
      with wa' prefix[symmetric] have "wa' \<in> write_actions E" by(rule write_actions_change_prefix)
      moreover from adal_wa' have "adal \<in> action_loc P E wa'"
        by(simp add: action_loc_change_prefix[OF prefix wa'n])
      ultimately have "E \<turnstile> wa' \<le>a w \<or> E \<turnstile> r \<le>a wa'" by(rule mrw)
      thus ?thesis
      proof
        assume "E \<turnstile> wa' \<le>a w"
        hence "E' \<turnstile> wa' \<le>a w" using prefix wa'n a'n by(rule action_order_change_prefix)
        thus ?thesis ..
      next
        assume "E \<turnstile> r \<le>a wa'"
        hence "E' \<turnstile> r \<le>a wa'" using prefix an wa'n by(rule action_order_change_prefix)
        thus ?thesis ..
      qed
    next
      case False note wa'n = this
      show ?thesis
      proof(cases "is_new_action (action_obs E' wa')")
        case False
        hence "E' \<turnstile> r \<le>a wa'" using wa'n r' wa' an
          by(auto intro!: action_orderI) (metis enat_ord_code(1) linorder_le_cases order_le_less_trans)
        thus ?thesis ..
      next
        case True
        with wa' adal_wa' have new: "wa' \<in> new_actions_for P E' adal" by(simp add: new_actions_for_def)
        show ?thesis
        proof(cases "is_new_action (action_obs E' w)")
          case True
          with adal_w' a'n w' have "w \<in> new_actions_for P E' adal" by(simp add: new_actions_for_def)
          with E' new have "wa' = w" by(rule \<E>_new_actions_for_fun)
          thus ?thesis using w' by(auto intro: refl_onPD[OF refl_action_order])
        next
          case False
          with True wa' w' show ?thesis by(auto intro!: action_orderI)
        qed
      qed
    qed
  qed
qed

lemma action_order_read_before_write:
  assumes E: "E \<in> \<E>" "P \<turnstile> (E, ws) \<surd>"
  and ao: "E \<turnstile> w \<le>a r"
  and r: "r \<in> read_actions E"
  and w: "w \<in> write_actions E"
  and adal: "adal \<in> action_loc P E r" "adal \<in> action_loc P E w"
  and sc: "\<And>a. \<lbrakk> a < r; a \<in> read_actions E \<rbrakk> \<Longrightarrow> P,E \<turnstile> a \<leadsto>mrw ws a"
  shows "w < r"
using ao
proof(cases rule: action_orderE)
  case 1
  from init_before_read[OF E r adal(1) sc]
  obtain i where "i < r" "i \<in> new_actions_for P E adal" by blast
  moreover from `is_new_action (action_obs E w)` adal(2) `w \<in> actions E`
  have "w \<in> new_actions_for P E adal" by(simp add: new_actions_for_def)
  ultimately show "w < r" using E by(auto dest: \<E>_new_actions_for_fun)
next
  case 2
  with r w show ?thesis
    by(cases "w = r")(auto dest: read_actions_not_write_actions)
qed

end

end