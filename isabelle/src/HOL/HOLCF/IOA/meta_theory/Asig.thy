(*  Title:      HOL/HOLCF/IOA/meta_theory/Asig.thy
    Author:     Olaf Müller, Tobias Nipkow & Konrad Slind
*)

header {* Action signatures *}

theory Asig
imports Main
begin

type_synonym
  'a signature = "('a set * 'a set * 'a set)"

definition
  inputs :: "'action signature => 'action set" where
  asig_inputs_def: "inputs = fst"

definition
  outputs :: "'action signature => 'action set" where
  asig_outputs_def: "outputs = (fst o snd)"

definition
  internals :: "'action signature => 'action set" where
  asig_internals_def: "internals = (snd o snd)"

definition
  actions :: "'action signature => 'action set" where
  "actions(asig) = (inputs(asig) Un outputs(asig) Un internals(asig))"

definition
  externals :: "'action signature => 'action set" where
  "externals(asig) = (inputs(asig) Un outputs(asig))"

definition
  locals :: "'action signature => 'action set" where
  "locals asig = ((internals asig) Un (outputs asig))"

definition
  is_asig :: "'action signature => bool" where
  "is_asig(triple) =
     ((inputs(triple) Int outputs(triple) = {}) &
      (outputs(triple) Int internals(triple) = {}) &
      (inputs(triple) Int internals(triple) = {}))"

definition
  mk_ext_asig :: "'action signature => 'action signature" where
  "mk_ext_asig(triple) = (inputs(triple), outputs(triple), {})"


lemmas asig_projections = asig_inputs_def asig_outputs_def asig_internals_def

lemma asig_triple_proj:
 "(outputs    (a,b,c) = b)   &
  (inputs     (a,b,c) = a) &
  (internals  (a,b,c) = c)"
  apply (simp add: asig_projections)
  done

lemma int_and_ext_is_act: "[| a~:internals(S) ;a~:externals(S)|] ==> a~:actions(S)"
apply (simp add: externals_def actions_def)
done

lemma ext_is_act: "[|a:externals(S)|] ==> a:actions(S)"
apply (simp add: externals_def actions_def)
done

lemma int_is_act: "[|a:internals S|] ==> a:actions S"
apply (simp add: asig_internals_def actions_def)
done

lemma inp_is_act: "[|a:inputs S|] ==> a:actions S"
apply (simp add: asig_inputs_def actions_def)
done

lemma out_is_act: "[|a:outputs S|] ==> a:actions S"
apply (simp add: asig_outputs_def actions_def)
done

lemma ext_and_act: "(x: actions S & x : externals S) = (x: externals S)"
apply (fast intro!: ext_is_act)
done

lemma not_ext_is_int: "[|is_asig S;x: actions S|] ==> (x~:externals S) = (x: internals S)"
apply (simp add: actions_def is_asig_def externals_def)
apply blast
done

lemma not_ext_is_int_or_not_act: "is_asig S ==> (x~:externals S) = (x: internals S | x~:actions S)"
apply (simp add: actions_def is_asig_def externals_def)
apply blast
done

lemma int_is_not_ext:
 "[| is_asig (S); x:internals S |] ==> x~:externals S"
apply (unfold externals_def actions_def is_asig_def)
apply simp
apply blast
done


end
