(*  Title:      HOL/MicroJava/J/WellType.thy
    Author:     David von Oheimb
    Copyright   1999 Technische Universitaet Muenchen
*)

header {* \isaheader{Well-typedness Constraints} *}

theory WellType imports Term WellForm begin

text {*
the formulation of well-typedness of method calls given below (as well as
the Java Specification 1.0) is a little too restrictive: Is does not allow
methods of class Object to be called upon references of interface type.

\begin{description}
\item[simplifications:]\ \\
\begin{itemize}
\item the type rules include all static checks on expressions and statements, 
  e.g.\ definedness of names (of parameters, locals, fields, methods)
\end{itemize}
\end{description}
*}

text "local variables, including method parameters and This:"
type_synonym lenv = "vname \<rightharpoonup> ty"
type_synonym 'c env = "'c prog \<times> lenv"

abbreviation (input)
  prg :: "'c env => 'c prog"
  where "prg == fst"

abbreviation (input)
  localT :: "'c env => (vname \<rightharpoonup> ty)"
  where "localT == snd"

consts
  more_spec :: "'c prog => (ty \<times> 'x) \<times> ty list =>
                (ty \<times> 'x) \<times> ty list => bool"
  appl_methds :: "'c prog =>  cname => sig => ((ty \<times> ty) \<times> ty list) set"
  max_spec :: "'c prog =>  cname => sig => ((ty \<times> ty) \<times> ty list) set"

defs
  more_spec_def: "more_spec G == \<lambda>((d,h),pTs). \<lambda>((d',h'),pTs'). G\<turnstile>d\<preceq>d' \<and>
                                list_all2 (\<lambda>T T'. G\<turnstile>T\<preceq>T') pTs pTs'"
  
  -- "applicable methods, cf. 15.11.2.1"
  appl_methds_def: "appl_methds G C == \<lambda>(mn, pTs).
                     {((Class md,rT),pTs') |md rT mb pTs'.
                      method (G,C)  (mn, pTs') = Some (md,rT,mb) \<and>
                      list_all2 (\<lambda>T T'. G\<turnstile>T\<preceq>T') pTs pTs'}"

  -- "maximally specific methods, cf. 15.11.2.2"
  max_spec_def: "max_spec G C sig == {m. m \<in>appl_methds G C sig \<and> 
                                       (\<forall>m'\<in>appl_methds G C sig.
                                         more_spec G m' m --> m' = m)}"

lemma max_spec2appl_meths: 
  "x \<in> max_spec G C sig ==> x \<in> appl_methds G C sig"
apply (unfold max_spec_def)
apply (fast)
done

lemma appl_methsD: 
"((md,rT),pTs')\<in>appl_methds G C (mn, pTs) ==>  
  \<exists>D b. md = Class D \<and> method (G,C) (mn, pTs') = Some (D,rT,b)  
  \<and> list_all2 (\<lambda>T T'. G\<turnstile>T\<preceq>T') pTs pTs'"
apply (unfold appl_methds_def)
apply (fast)
done

lemmas max_spec2mheads = insertI1 [THEN [2] equalityD2 [THEN subsetD], 
                         THEN max_spec2appl_meths, THEN appl_methsD]


primrec typeof :: "(loc => ty option) => val => ty option"
where
  "typeof dt  Unit    = Some (PrimT Void)"
| "typeof dt  Null    = Some NT"
| "typeof dt (Bool b) = Some (PrimT Boolean)"
| "typeof dt (Intg i) = Some (PrimT Integer)"
| "typeof dt (Addr a) = dt a"

lemma is_type_typeof [rule_format (no_asm), simp]: 
  "(\<forall>a. v \<noteq> Addr a) --> (\<exists>T. typeof t v = Some T \<and> is_type G T)"
apply (rule val.induct)
apply     auto
done

lemma typeof_empty_is_type [rule_format (no_asm)]: 
  "typeof (\<lambda>a. None) v = Some T \<longrightarrow> is_type G T"
apply (rule val.induct)
apply     auto
done

lemma typeof_default_val: "\<exists>T. (typeof dt (default_val ty) = Some T) \<and> G\<turnstile> T \<preceq> ty"
apply (case_tac ty)
apply (case_tac prim_ty)
apply auto
done

type_synonym
  java_mb = "vname list \<times> (vname \<times> ty) list \<times> stmt \<times> expr"
-- "method body with parameter names, local variables, block, result expression."
-- "local variables might include This, which is hidden anyway"
  
inductive
  ty_expr :: "'c env => expr => ty => bool" ("_ \<turnstile> _ :: _" [51, 51, 51] 50)
  and ty_exprs :: "'c env => expr list => ty list => bool" ("_ \<turnstile> _ [::] _" [51, 51, 51] 50)
  and wt_stmt :: "'c env => stmt => bool" ("_ \<turnstile> _ \<surd>" [51, 51] 50)
where
  
  NewC: "[| is_class (prg E) C |] ==>
         E\<turnstile>NewC C::Class C"  -- "cf. 15.8"

  -- "cf. 15.15"
| Cast: "[| E\<turnstile>e::C; is_class (prg E) D;
            prg E\<turnstile>C\<preceq>? Class D |] ==>
         E\<turnstile>Cast D e:: Class D"

  -- "cf. 15.7.1"
| Lit:    "[| typeof (\<lambda>v. None) x = Some T |] ==>
         E\<turnstile>Lit x::T"

  
  -- "cf. 15.13.1"
| LAcc: "[| localT E v = Some T; is_type (prg E) T |] ==>
         E\<turnstile>LAcc v::T"

| BinOp:"[| E\<turnstile>e1::T;
            E\<turnstile>e2::T;
            if bop = Eq then T' = PrimT Boolean
                        else T' = T \<and> T = PrimT Integer|] ==>
            E\<turnstile>BinOp bop e1 e2::T'"

  -- "cf. 15.25, 15.25.1"
| LAss: "[| v ~= This;
            E\<turnstile>LAcc v::T;
            E\<turnstile>e::T';
            prg E\<turnstile>T'\<preceq>T |] ==>
         E\<turnstile>v::=e::T'"

  -- "cf. 15.10.1"
| FAcc: "[| E\<turnstile>a::Class C; 
            field (prg E,C) fn = Some (fd,fT) |] ==>
            E\<turnstile>{fd}a..fn::fT"

  -- "cf. 15.25, 15.25.1"
| FAss: "[| E\<turnstile>{fd}a..fn::T;
            E\<turnstile>v        ::T';
            prg E\<turnstile>T'\<preceq>T |] ==>
         E\<turnstile>{fd}a..fn:=v::T'"


  -- "cf. 15.11.1, 15.11.2, 15.11.3"
| Call: "[| E\<turnstile>a::Class C;
            E\<turnstile>ps[::]pTs;
            max_spec (prg E) C (mn, pTs) = {((md,rT),pTs')} |] ==>
         E\<turnstile>{C}a..mn({pTs'}ps)::rT"

-- "well-typed expression lists"

  -- "cf. 15.11.???"
| Nil: "E\<turnstile>[][::][]"

  -- "cf. 15.11.???"
| Cons:"[| E\<turnstile>e::T;
           E\<turnstile>es[::]Ts |] ==>
        E\<turnstile>e#es[::]T#Ts"

-- "well-typed statements"

| Skip:"E\<turnstile>Skip\<surd>"

| Expr:"[| E\<turnstile>e::T |] ==>
        E\<turnstile>Expr e\<surd>"

| Comp:"[| E\<turnstile>s1\<surd>; 
           E\<turnstile>s2\<surd> |] ==>
        E\<turnstile>s1;; s2\<surd>"

  -- "cf. 14.8"
| Cond:"[| E\<turnstile>e::PrimT Boolean;
           E\<turnstile>s1\<surd>;
           E\<turnstile>s2\<surd> |] ==>
         E\<turnstile>If(e) s1 Else s2\<surd>"

  -- "cf. 14.10"
| Loop:"[| E\<turnstile>e::PrimT Boolean;
           E\<turnstile>s\<surd> |] ==>
        E\<turnstile>While(e) s\<surd>"


definition wf_java_mdecl :: "'c prog => cname => java_mb mdecl => bool" where
"wf_java_mdecl G C == \<lambda>((mn,pTs),rT,(pns,lvars,blk,res)).
  length pTs = length pns \<and>
  distinct pns \<and>
  unique lvars \<and>
        This \<notin> set pns \<and> This \<notin> set (map fst lvars) \<and> 
  (\<forall>pn\<in>set pns. map_of lvars pn = None) \<and>
  (\<forall>(vn,T)\<in>set lvars. is_type G T) &
  (let E = (G,map_of lvars(pns[\<mapsto>]pTs)(This\<mapsto>Class C)) in
   E\<turnstile>blk\<surd> \<and> (\<exists>T. E\<turnstile>res::T \<and> G\<turnstile>T\<preceq>rT))"

abbreviation "wf_java_prog == wf_prog wf_java_mdecl"

lemma wf_java_prog_wf_java_mdecl: "\<lbrakk> 
  wf_java_prog G; (C, D, fds, mths) \<in> set G; jmdcl \<in> set mths \<rbrakk>
  \<Longrightarrow> wf_java_mdecl G C jmdcl"
apply (simp only: wf_prog_def) 
apply (erule conjE)+
apply (drule bspec, assumption)
apply (simp add: wf_cdecl_mdecl_def split_beta)
done


lemma wt_is_type: "(E\<turnstile>e::T \<longrightarrow> ws_prog (prg E) \<longrightarrow> is_type (prg E) T) \<and>  
       (E\<turnstile>es[::]Ts \<longrightarrow> ws_prog (prg E) \<longrightarrow> Ball (set Ts) (is_type (prg E))) \<and> 
       (E\<turnstile>c \<surd> \<longrightarrow> True)"
apply (rule ty_expr_ty_exprs_wt_stmt.induct)
apply auto
apply (   erule typeof_empty_is_type)
apply (  simp split add: split_if_asm)
apply ( drule field_fields)
apply ( drule (1) fields_is_type)
apply (  simp (no_asm_simp))
apply  (assumption)
apply (auto dest!: max_spec2mheads method_wf_mhead is_type_rTI 
            simp add: wf_mdecl_def)
done

lemmas ty_expr_is_type = wt_is_type [THEN conjunct1,THEN mp, rule_format]

lemma expr_class_is_class: "
  \<lbrakk>ws_prog (prg E); E \<turnstile> e :: Class C\<rbrakk> \<Longrightarrow> is_class (prg E) C"
  by (frule ty_expr_is_type, assumption, simp)


end
