(*  Title:      JinjaThreads/Execute/Java2Jinja.thy
    Author:     Andreas Lochbihler
*)

header {* \isaheader{Setup for converter Java2Jinja} *}
theory Java2Jinja 
imports
  Code_Generation
  ToString
begin

code_modulename SML
  Java2Jinja Code_Generation

definition j_Program :: "addr J_mb cdecl list \<Rightarrow> addr J_prog"
where "j_Program = Program"

export_code wf_J_prog' j_Program in SML file "JWellForm.ML" 

text {* Functions for extracting calls to the native print method *}

definition purge where
  "\<And>run.
  purge run = 
  lmap (\<lambda>obs. case obs of ExternalCall _ _ (Cons (Intg i) _) v \<Rightarrow> i)
  (lfilter
    (\<lambda>obs. case obs of ExternalCall _ M (Cons (Intg i) Nil) _ \<Rightarrow> M = print | _ \<Rightarrow> False) 
    (lconcat (lmap (llist_of \<circ> snd) (llist_of_tllist run))))"

text {* Various other functions *}

instantiation heapobj :: toString begin
primrec toString_heapobj :: "heapobj \<Rightarrow> String.literal" where
  "toString (Obj C fs) = Aux.concat [STR ''(Obj '', toString C, STR '', '', toString fs, STR '')'']"
| "toString (Arr T si fs el) = 
   Aux.concat [STR ''(['', toString si, STR '']'', toString T, STR '', '', toString fs, STR '', '', toString (map snd (rm_to_list el)), STR '')'']"
instance proof qed
end

definition llist_case' where "llist_case' = llist_case"
definition tllist_case' where "tllist_case' = tllist_case"
definition terminal' where "terminal' = terminal"
definition llist_of_tllist' where "llist_of_tllist' = llist_of_tllist"
definition thr' where "thr' = thr"
definition shr' where "shr' = shr"

definition heap_toString :: "heap \<Rightarrow> String.literal"
where "heap_toString = toString"

definition thread_toString :: "(thread_id, (addr expr \<times> addr locals) \<times> (addr \<Rightarrow>\<^isub>f nat)) rbt \<Rightarrow> String.literal"
where "thread_toString = toString"

definition thread_toString' :: "(thread_id, addr jvm_thread_state' \<times> (addr \<Rightarrow>\<^isub>f nat)) rbt \<Rightarrow> String.literal"
where "thread_toString' = toString"

definition trace_toString :: "thread_id \<times> (addr, thread_id) obs_event list \<Rightarrow> String.literal"
where "trace_toString = toString"

export_code
  wf_J_prog' exec_J_rr exec_J_rnd 
  j_Program
  purge llist_case' tllist_case' terminal' llist_of_tllist'
  thr' shr' heap_toString thread_toString trace_toString
  in SML
  file "J_Execute.ML"

definition j2jvm :: "addr J_prog \<Rightarrow> addr jvm_prog" where "j2jvm = J2JVM"

export_code
  wf_jvm_prog' exec_JVM_rr exec_JVM_rnd j2jvm
  j_Program 
  purge llist_case' tllist_case' terminal' llist_of_tllist'
  thr' shr' heap_toString thread_toString' trace_toString
  in SML
  file "JVM_Execute2.ML"

end