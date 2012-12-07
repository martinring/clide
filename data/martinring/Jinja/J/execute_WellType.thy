(*  Title:      Jinja/J/execute_WellType.thy
    ID:         $Id: execute_WellType.thy,v 1.4 2009-07-14 09:00:10 fhaftmann Exp $
    Author:     Christoph Petzinger
    Copyright   2004 Technische Universitaet Muenchen
*)

header {* \isaheader{Code Generation For WellType} *}

theory execute_WellType
imports
  WellType Examples
begin

(* Replace WT_WTs.WTCond with new intros WT_WTs.WTCond1 and WT_WTs.WTCond2 *)

lemma WTCond1:
  "\<lbrakk>P,E \<turnstile> e :: Boolean;  P,E \<turnstile> e\<^isub>1::T\<^isub>1;  P,E \<turnstile> e\<^isub>2::T\<^isub>2; P \<turnstile> T\<^isub>1 \<le> T\<^isub>2;
    P \<turnstile> T\<^isub>2 \<le> T\<^isub>1 \<longrightarrow> T\<^isub>2 = T\<^isub>1 \<rbrakk> \<Longrightarrow> P,E \<turnstile> if (e) e\<^isub>1 else e\<^isub>2 :: T\<^isub>2"
by (fastforce)

lemma WTCond2:
  "\<lbrakk>P,E \<turnstile> e :: Boolean;  P,E \<turnstile> e\<^isub>1::T\<^isub>1;  P,E \<turnstile> e\<^isub>2::T\<^isub>2; P \<turnstile> T\<^isub>2 \<le> T\<^isub>1;
    P \<turnstile> T\<^isub>1 \<le> T\<^isub>2 \<longrightarrow> T\<^isub>1 = T\<^isub>2 \<rbrakk> \<Longrightarrow> P,E \<turnstile> if (e) e\<^isub>1 else e\<^isub>2 :: T\<^isub>1"
by (fastforce)

lemmas [code_pred_intro] =
  WT_WTs.WTNew
  WT_WTs.WTCast
  WT_WTs.WTVal
  WT_WTs.WTVar
  WT_WTs.WTBinOpEq
  WT_WTs.WTBinOpAdd
  WT_WTs.WTLAss
  WT_WTs.WTFAcc
  WT_WTs.WTFAss
  WT_WTs.WTCall
  WT_WTs.WTBlock
  WT_WTs.WTSeq

declare
  WTCond1 [code_pred_intro WTCond1]
  WTCond2 [code_pred_intro WTCond2]

lemmas [code_pred_intro] =
  WT_WTs.WTWhile
  WT_WTs.WTThrow
  WT_WTs.WTTry
  WT_WTs.WTNil
  WT_WTs.WTCons

code_pred
  (modes: i \<Rightarrow> i \<Rightarrow> i \<Rightarrow> i \<Rightarrow> bool as type_check, i \<Rightarrow> i \<Rightarrow> i \<Rightarrow> o \<Rightarrow> bool as infer_type)
  WT
proof -
  case WT
  from WT.prems show thesis
  proof(cases (no_simp))
    case (WTCond E e e1 T1 e2 T2 T)
    from `x \<turnstile> T1 \<le> T2 \<or> x \<turnstile> T2 \<le> T1` show thesis
    proof
      assume "x \<turnstile> T1 \<le> T2"
      with `x \<turnstile> T1 \<le> T2 \<longrightarrow> T = T2` have "T = T2" ..
      from `xa = E` `xb = if (e) e1 else e2` `xc = T` `x,E \<turnstile> e :: Boolean` 
        `x,E \<turnstile> e1 :: T1` `x,E \<turnstile> e2 :: T2` `x \<turnstile> T1 \<le> T2` `x \<turnstile> T2 \<le> T1 \<longrightarrow> T = T1`
      show ?thesis unfolding `T = T2` by(rule WTCond1[OF refl])
    next
      assume "x \<turnstile> T2 \<le> T1"
      with `x \<turnstile> T2 \<le> T1 \<longrightarrow> T = T1` have "T = T1" ..
      from `xa = E` `xb = if (e) e1 else e2` `xc = T` `x,E \<turnstile> e :: Boolean` 
        `x,E \<turnstile> e1 :: T1` `x,E \<turnstile> e2 :: T2` `x \<turnstile> T2 \<le> T1` `x \<turnstile> T1 \<le> T2 \<longrightarrow> T = T2`
      show ?thesis unfolding `T = T1` by(rule WTCond2[OF refl])
    qed
  qed(assumption|erule (2) that[OF refl])+
next
  case WTs
  from WTs.prems show thesis
    by(cases (no_simp))(assumption|erule (2) that[OF refl])+
qed

notation infer_type ("_,_ \<turnstile> _ :: '_" [51,51,51]100)

definition test1 where "test1 = [],empty \<turnstile> testExpr1 :: _"
definition test2 where "test2 = [], empty  \<turnstile> testExpr2 :: _"
definition test3 where "test3 = [], empty(''V'' \<mapsto> Integer)  \<turnstile> testExpr3 :: _"
definition test4 where "test4 = [], empty(''V'' \<mapsto> Integer)  \<turnstile> testExpr4 :: _"
definition test5 where "test5 = [classObject, (''C'',(''Object'',[(''F'',Integer)],[]))], empty  \<turnstile> testExpr5 :: _"
definition test6 where "test6 = [classObject, classI], empty  \<turnstile> testExpr6 :: _"

ML {*
  val SOME(@{code Integer}, _) = Predicate.yield @{code test1};
  val SOME(@{code Integer}, _) = Predicate.yield @{code test2};
  val SOME(@{code Integer}, _) = Predicate.yield @{code test3};
  val SOME(@{code Void}, _) = Predicate.yield @{code test4};
  val SOME(@{code Void}, _) = Predicate.yield @{code test5};
  val SOME(@{code Integer}, _) = Predicate.yield @{code test6};
*}

definition testmb_isNull where "testmb_isNull = [classObject, classA], empty([this] [\<mapsto>] [Class ''A'']) \<turnstile> mb_isNull :: _"
definition testmb_add where "testmb_add = [classObject, classA], empty([this,''i''] [\<mapsto>] [Class ''A'',Integer]) \<turnstile> mb_add :: _"
definition testmb_mult_cond where "testmb_mult_cond = [classObject, classA], empty([this,''j''] [\<mapsto>] [Class ''A'',Integer]) \<turnstile> mb_mult_cond :: _"
definition testmb_mult_block where "testmb_mult_block = [classObject, classA], empty([this,''i'',''j'',''temp''] [\<mapsto>] [Class ''A'',Integer,Integer,Integer]) \<turnstile> mb_mult_block :: _"
definition testmb_mult where "testmb_mult = [classObject, classA], empty([this,''i'',''j''] [\<mapsto>] [Class ''A'',Integer,Integer]) \<turnstile> mb_mult :: _"

ML {*
  val SOME(@{code Boolean}, _) = Predicate.yield @{code testmb_isNull};
  val SOME(@{code Integer}, _) = Predicate.yield @{code testmb_add};
  val SOME(@{code Boolean}, _) = Predicate.yield @{code testmb_mult_cond};
  val SOME(@{code Void}, _) = Predicate.yield @{code testmb_mult_block};
  val SOME(@{code Integer}, _) = Predicate.yield @{code testmb_mult};
*}

definition test where "test = [classObject, classA], empty \<turnstile> testExpr_ClassA :: _"

ML {*
  val SOME(@{code Integer}, _) = Predicate.yield @{code test};
*}

end