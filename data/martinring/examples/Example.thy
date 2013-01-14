theory Example imports Main begin

theorem and_comms: "A & B --> B & A"
proof
  assume "A & B"
  then show "B & A"
  proof
    assume "B" and "A"
      then show ?thesis ..
  qed
qed

theorem "A \<and> B --> B \<and> A"
  apply (rule impI)
  apply (erule conjE)
  apply (rule conjI)
  apply assumption
  apply assumption
done

end