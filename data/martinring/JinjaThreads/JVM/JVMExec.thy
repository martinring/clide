(*  Title:      JinjaThreads/JVM/JVMExec.thy
    Author:     Cornelia Pusch, Gerwin Klein, Andreas Lochbihler
*)

header {* \isaheader{Program Execution in the JVM} *}

theory JVMExec
imports
  JVMExecInstr
  JVMExceptions
  "../Common/StartConfig"
begin

abbreviation instrs_of :: "'addr jvm_prog \<Rightarrow> cname \<Rightarrow> mname \<Rightarrow> 'addr instr list"
where "instrs_of P C M == fst(snd(snd(the(snd(snd(snd(method P C M)))))))"

section "single step execution"

context JVM_heap_base begin

fun exception_step :: "'addr jvm_prog \<Rightarrow> 'addr \<Rightarrow> 'heap \<Rightarrow> 'addr frame \<Rightarrow> 'addr frame list \<Rightarrow> ('addr, 'heap) jvm_state"
where
  "exception_step P a h (stk, loc, C, M, pc) frs = 
   (case match_ex_table P (cname_of h a) pc (ex_table_of P C M) of
          None \<Rightarrow> (\<lfloor>a\<rfloor>, h, frs)
        | Some (pc', d) \<Rightarrow> (None, h, (Addr a # drop (size stk - d) stk, loc, C, M, pc') # frs))"

lemma exception_step_def_raw:
  "exception_step = 
   (\<lambda>P a h (stk, loc, C, M, pc) frs.
    case match_ex_table P (cname_of h a) pc (ex_table_of P C M) of
      None \<Rightarrow> (\<lfloor>a\<rfloor>, h, frs)
    | Some (pc', d) \<Rightarrow> (None, h, (Addr a # drop (size stk - d) stk, loc, C, M, pc') # frs))"
by(intro ext) auto

fun exec :: "'addr jvm_prog \<Rightarrow> 'thread_id \<Rightarrow> ('addr, 'heap) jvm_state \<Rightarrow> ('addr, 'thread_id, 'heap) jvm_ta_state set" where
  "exec P t (xcp, h, []) = {}"
| "exec P t (None, h, (stk, loc, C, M, pc) # frs) = exec_instr (instrs_of P C M ! pc) P t h stk loc C M pc frs"
| "exec P t (\<lfloor>a\<rfloor>, h, fr # frs) = {(\<epsilon>, exception_step P a h fr frs)}"

section "relational view"

inductive exec_1 :: 
  "'addr jvm_prog \<Rightarrow> 'thread_id \<Rightarrow> ('addr, 'heap) jvm_state
  \<Rightarrow> ('addr, 'thread_id, 'heap) jvm_thread_action \<Rightarrow> ('addr, 'heap) jvm_state \<Rightarrow> bool"
  ("_,_ \<turnstile>/ _ -_-jvm\<rightarrow>/ _" [61,0,61,0,61] 60)
  for P :: "'addr jvm_prog" and t :: 'thread_id
where
  exec_1I:
  "(ta, \<sigma>') \<in> exec P t \<sigma> \<Longrightarrow> P,t \<turnstile> \<sigma> -ta-jvm\<rightarrow> \<sigma>'"

lemma exec_1_iff:
  "P,t \<turnstile> \<sigma> -ta-jvm\<rightarrow> \<sigma>' \<longleftrightarrow> (ta, \<sigma>') \<in> exec P t \<sigma>"
by(auto intro: exec_1I elim: exec_1.cases)

text {*
  The start configuration of the JVM: in the start heap, we call a 
  method @{text m} of class @{text C} in program @{text P} with parameters @{term "vs"}. The 
  @{text this} pointer of the frame is set to @{text Null} to simulate
  a static method invokation.
*}

abbreviation JVM_start_state :: 
  "'addr jvm_prog \<Rightarrow> cname \<Rightarrow> mname \<Rightarrow> 'addr val list \<Rightarrow> ('addr,'thread_id,'addr jvm_thread_state,'heap,'addr) state"
where
  "JVM_start_state \<equiv>
   start_state (\<lambda>C M Ts T (mxs, mxl0, b) vs. (None, [([], Null # vs @ replicate mxl0 undefined_value, C, M, 0)]))"

definition JVM_start_state' :: "'addr jvm_prog \<Rightarrow> cname \<Rightarrow> mname \<Rightarrow> 'addr val list \<Rightarrow> ('addr, 'heap) jvm_state"
where
  "JVM_start_state' P C M vs \<equiv>
   let (D, Ts, T, meth) = method P C M;
       (mxs, mxl0, ins, xt) = the meth
   in (None, start_heap, [([], Null # vs @ replicate mxl0 undefined_value, D, M, 0)])"

end

end
