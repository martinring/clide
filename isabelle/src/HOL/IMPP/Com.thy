(*  Title:    HOL/IMPP/Com.thy
    Author:   David von Oheimb (based on a theory by Tobias Nipkow et al), TUM
*)

header {* Semantics of arithmetic and boolean expressions, Syntax of commands *}

theory Com
imports Main
begin

type_synonym val = nat
  (* for the meta theory, this may be anything, but types cannot be refined later *)

typedecl glb
typedecl loc

axiomatization
  Arg :: loc and
  Res :: loc

datatype vname  = Glb glb | Loc loc
type_synonym globs = "glb => val"
type_synonym locals = "loc => val"
datatype state  = st globs locals
(* for the meta theory, the following would be sufficient:
typedecl state
consts   st :: "[globs , locals] => state"
*)
type_synonym aexp = "state => val"
type_synonym bexp = "state => bool"

typedecl pname

datatype com
      = SKIP
      | Ass   vname aexp        ("_:==_"                [65, 65    ] 60)
      | Local loc aexp com      ("LOCAL _:=_ IN _"      [65,  0, 61] 60)
      | Semi  com  com          ("_;; _"                [59, 60    ] 59)
      | Cond  bexp com com      ("IF _ THEN _ ELSE _"   [65, 60, 61] 60)
      | While bexp com          ("WHILE _ DO _"         [65,     61] 60)
      | BODY  pname
      | Call  vname pname aexp  ("_:=CALL _'(_')"       [65, 65,  0] 60)

consts bodies :: "(pname  *  com) list"(* finitely many procedure definitions *)
definition
  body :: " pname ~=> com" where
  "body = map_of bodies"


(* Well-typedness: all procedures called must exist *)

inductive WT  :: "com => bool" where

    Skip:    "WT SKIP"

  | Assign:  "WT (X :== a)"

  | Local:   "WT c ==>
              WT (LOCAL Y := a IN c)"

  | Semi:    "[| WT c0; WT c1 |] ==>
              WT (c0;; c1)"

  | If:      "[| WT c0; WT c1 |] ==>
              WT (IF b THEN c0 ELSE c1)"

  | While:   "WT c ==>
              WT (WHILE b DO c)"

  | Body:    "body pn ~= None ==>
              WT (BODY pn)"

  | Call:    "WT (BODY pn) ==>
              WT (X:=CALL pn(a))"

inductive_cases WTs_elim_cases:
  "WT SKIP"  "WT (X:==a)"  "WT (LOCAL Y:=a IN c)"
  "WT (c1;;c2)"  "WT (IF b THEN c1 ELSE c2)"  "WT (WHILE b DO c)"
  "WT (BODY P)"  "WT (X:=CALL P(a))"

definition
  WT_bodies :: bool where
  "WT_bodies = (!(pn,b):set bodies. WT b)"


ML {* val make_imp_tac = EVERY'[rtac mp, fn i => atac (i+1), etac thin_rl] *}

lemma finite_dom_body: "finite (dom body)"
apply (unfold body_def)
apply (rule finite_dom_map_of)
done

lemma WT_bodiesD: "[| WT_bodies; body pn = Some b |] ==> WT b"
apply (unfold WT_bodies_def body_def)
apply (drule map_of_SomeD)
apply fast
done

declare WTs_elim_cases [elim!]

end
