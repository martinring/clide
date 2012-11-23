(*  Title:      HOL/MicroJava/JVM/JVMExec.thy
    Author:     Cornelia Pusch, Gerwin Klein
    Copyright   1999 Technische Universitaet Muenchen
*)

header {* \isaheader{Program Execution in the JVM} *}

theory JVMExec imports JVMExecInstr JVMExceptions begin


fun
  exec :: "jvm_prog \<times> jvm_state => jvm_state option"
-- "exec is not recursive. fun is just used for pattern matching"
where
  "exec (G, xp, hp, []) = None"

| "exec (G, None, hp, (stk,loc,C,sig,pc)#frs) =
  (let 
     i = fst(snd(snd(snd(snd(the(method (G,C) sig)))))) ! pc;
     (xcpt', hp', frs') = exec_instr i G hp stk loc C sig pc frs
   in Some (find_handler G xcpt' hp' frs'))"

| "exec (G, Some xp, hp, frs) = None" 


definition exec_all :: "[jvm_prog,jvm_state,jvm_state] => bool"
              ("_ |- _ -jvm-> _" [61,61,61]60) where
  "G |- s -jvm-> t == (s,t) \<in> {(s,t). exec(G,s) = Some t}^*"


notation (xsymbols)
  exec_all  ("_ \<turnstile> _ -jvm\<rightarrow> _" [61,61,61]60)

text {*
  The start configuration of the JVM: in the start heap, we call a 
  method @{text m} of class @{text C} in program @{text G}. The 
  @{text this} pointer of the frame is set to @{text Null} to simulate
  a static method invokation.
*}
definition start_state :: "jvm_prog \<Rightarrow> cname \<Rightarrow> mname \<Rightarrow> jvm_state" where
  "start_state G C m \<equiv>
  let (C',rT,mxs,mxl,i,et) = the (method (G,C) (m,[])) in
    (None, start_heap G, [([], Null # replicate mxl undefined, C, (m,[]), 0)])"

end
