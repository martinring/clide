theory Ta_impl_codegen
imports Ta_impl
begin

(*
  Code generation with actual directories as targets.
  As there is no way to reference the project directory for code generation targets,
  the code generation has been put into this file so that it is not
  invoked when Ta_impl is included from other projects (In which case the code generation targets would be 
  errounously interpreted relative to the including project's path).
*)

(* CAUTION: If this statement fails because the directory cannot be found, 
  you are probably including this library from another project, and the 
  relative path refers to that project's directory. As there seems to be 
  no way to reference a project's directory in the path, the only known 
  workaround is to disable writing the code to a file, by simply replacing
  the filename by "-" *)
export_code 
  hta_mem hta_mem' hta_prod hta_prod' hta_prodWR hta_union 
  hta_empty hta_add_qi hta_add_rule
  hta_reduce hta_bwd_reduce hta_is_empty_witness
  hta_ensure_idx_f hta_ensure_idx_s hta_ensure_idx_sf

  htai_mem htai_prod htai_prodWR htai_union 
  htai_empty htai_add_qi htai_add_rule
  htai_bwd_reduce htai_is_empty_witness
  htai_ensure_idx_f htai_ensure_idx_s htai_ensure_idx_sf

  ls_size hs_size rs_size
  in SML 
  module_name Ta
  file "code/ml/generated/Ta.ML"


(* CAUTION: If this statement fails because the directory cannot be found, 
  you are probably including this library from another project, and the 
  relative path refers to that project's directory. As there seems to be 
  no way to reference a project's directory in the path, the only known 
  workaround is to disable writing the code to a file, by simply replacing
  the filename by "-" *)
export_code 
  hta_mem hta_mem' hta_prod hta_prod' hta_prodWR hta_union 
  hta_empty hta_add_qi hta_add_rule
  hta_reduce hta_bwd_reduce hta_is_empty_witness
  hta_ensure_idx_f hta_ensure_idx_s hta_ensure_idx_sf

  htai_mem htai_prod htai_prodWR htai_union 
  htai_empty htai_add_qi htai_add_rule
  htai_bwd_reduce htai_is_empty_witness
  htai_ensure_idx_f htai_ensure_idx_s htai_ensure_idx_sf

  ls_size hs_size rs_size
  in Haskell 
  module_name Ta
  file "code/haskell/generated"
  (string_classes)

(* CAUTION: If this statement fails because the directory cannot be found, 
  you are probably including this library from another project, and the 
  relative path refers to that project's directory. As there seems to be 
  no way to reference a project's directory in the path, the only known 
  workaround is to disable writing the code to a file, by simply replacing
  the filename by "-" *)
export_code 
  hta_mem hta_mem' hta_prod hta_prod' hta_prodWR hta_union 
  hta_empty hta_add_qi hta_add_rule
  hta_reduce hta_bwd_reduce hta_is_empty_witness
  hta_ensure_idx_f hta_ensure_idx_s hta_ensure_idx_sf

  htai_mem htai_prod htai_prodWR htai_union 
  htai_empty htai_add_qi htai_add_rule
  htai_bwd_reduce htai_is_empty_witness
  htai_ensure_idx_f htai_ensure_idx_s htai_ensure_idx_sf

  ls_size hs_size rs_size
  in OCaml 
  module_name Ta
  file "code/ocaml/generated/Ta.ml"

end
