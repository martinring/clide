(*  Title:      HOL/Predicate_Compile.thy
    Author:     Stefan Berghofer, Lukas Bulwahn, Florian Haftmann, TU Muenchen
*)

header {* A compiler for predicates defined by introduction rules *}

theory Predicate_Compile
imports Predicate New_Random_Sequence Quickcheck_Exhaustive
keywords "code_pred" :: thy_goal and "values" :: diag
uses
  "Tools/Predicate_Compile/predicate_compile_aux.ML"
  "Tools/Predicate_Compile/predicate_compile_compilations.ML"
  "Tools/Predicate_Compile/core_data.ML"
  "Tools/Predicate_Compile/mode_inference.ML"
  "Tools/Predicate_Compile/predicate_compile_proof.ML"
  "Tools/Predicate_Compile/predicate_compile_core.ML"
  "Tools/Predicate_Compile/predicate_compile_data.ML"
  "Tools/Predicate_Compile/predicate_compile_fun.ML"
  "Tools/Predicate_Compile/predicate_compile_pred.ML"
  "Tools/Predicate_Compile/predicate_compile_specialisation.ML"
  "Tools/Predicate_Compile/predicate_compile.ML"
begin

setup Predicate_Compile.setup

end
