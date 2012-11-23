theory Lambda_mu 
  imports "../Nominal" 
begin

section {* Lambda-Mu according to a paper by Gavin Bierman *}

atom_decl var mvar

nominal_datatype trm = 
    Var   "var" 
  | Lam  "\<guillemotleft>var\<guillemotright>trm"   ("Lam [_]._" [100,100] 100)
  | App  "trm" "trm" 
  | Pss  "mvar" "trm"                                   (* passivate *)
  | Act  "\<guillemotleft>mvar\<guillemotright>trm"  ("Act [_]._" [100,100] 100)       (* activate  *)


end
