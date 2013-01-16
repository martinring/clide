theory Notepad
imports Main
begin

primrec app :: "nat => nat" where
  "app 0 = 0"
| "app (Suc n) = Suc n + (app n)"
lemma "app (Suc (Suc 0)) = 3" by simp


end