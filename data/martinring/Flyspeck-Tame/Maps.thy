theory Maps
imports Worklist Quasi_Order
begin

locale maps =
fixes empty :: "'m"
and up :: "'m \<Rightarrow> 'a \<Rightarrow> 'b list \<Rightarrow> 'm"
and map_of :: "'m \<Rightarrow> 'a \<Rightarrow> 'b list"
and M :: "'m \<Rightarrow> bool"
assumes map_empty: "map_of empty = (%a. [])"
and map_up: "map_of (up m a b) = (map_of m)(a := b)"
and M_empty: "M empty"
and M_up: "M m \<Longrightarrow> M (up m a b)"
begin

definition "set_of m = (UN x. set(map_of m x))"

end

locale set_mod_maps = maps empty up map_of M + quasi_order qle
for empty :: "'m"
and up :: "'m \<Rightarrow> 'a \<Rightarrow> 'b list \<Rightarrow> 'm"
and map_of :: "'m \<Rightarrow> 'a \<Rightarrow> 'b list"
and M :: "'m \<Rightarrow> bool"
and qle :: "'b \<Rightarrow> 'b \<Rightarrow> bool" (infix "\<preceq>" 60)
+
fixes subsumed :: "'b \<Rightarrow> 'b \<Rightarrow> bool"
and I :: "'b \<Rightarrow> bool"
and key :: "'b \<Rightarrow> 'a"
assumes equiv_iff_qle: "I x \<Longrightarrow> I y \<Longrightarrow> subsumed x y = (x \<preceq> y)"
and "key=key"
begin

definition "insert_mod x m =
  (let k = key x; ys = map_of m k
   in if (EX y : set ys. subsumed x y) then m else up m k (x#ys))"

end

sublocale
  set_mod_maps <
  set_by_maps: set_modulo qle empty insert_mod set_of I M
proof
  case goal1 show ?case by(simp add:set_of_def map_empty)
next
  case goal2 thus ?case
    by (auto simp: Let_def insert_mod_def set_of_def map_up equiv_iff_qle
      split:split_if_asm)
next
  case goal3 show ?case by(simp add: M_empty)
next
  case goal4 thus ?case
    by(simp add: insert_mod_def Let_def M_up)
qed

end