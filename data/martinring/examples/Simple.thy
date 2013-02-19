theory Simple
imports Main
begin

lemma test: "P \<and> Q \<Longrightarrow> Q \<and> P"
  by simp_all

end