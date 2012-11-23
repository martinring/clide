(*  Title:      HOL/Import/Import_Setup.thy
    Author:     Cezary Kaliszyk, University of Innsbruck
    Author:     Alexander Krauss, QAware GmbH
*)

header {* Importer machinery and required theorems *}

theory Import_Setup
imports "~~/src/HOL/Parity" "~~/src/HOL/Fact"
keywords
    "import_type_map" :: thy_decl and "import_const_map" :: thy_decl and
    "import_file" :: thy_decl
uses "import_data.ML" ("import_rule.ML")
begin

lemma light_ex_imp_nonempty:
  "P t \<Longrightarrow> \<exists>x. x \<in> Collect P"
  by auto

lemma typedef_hol2hollight:
  assumes a: "type_definition Rep Abs (Collect P)"
  shows "Abs (Rep a) = a \<and> P r = (Rep (Abs r) = r)"
  by (metis type_definition.Rep_inverse type_definition.Abs_inverse
      type_definition.Rep a mem_Collect_eq)

lemma ext2:
  "(\<And>x. f x = g x) \<Longrightarrow> f = g"
  by auto

use "import_rule.ML"

end

