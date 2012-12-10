(*  Title:      AVL Trees

    Author:     Tobias Nipkow and Cornelia Pusch,
                converted to Isar by Gerwin Klein
                contributions by Achim Brucker, Burkhart Wolff and Jan Smaus
    Maintainer: Gerwin Klein <gerwin.klein at nicta.com.au>

    see the file Changelog for a list of changes
*)

header {* AVL Trees in 2 Stages *}

theory AVL2
imports Main
begin

text {*
  This development of AVL trees leads to the same implementation
  as the monolithic one (in theorey AVL) but via an intermediate
  abstraction: AVL trees where the height is recomputed rather than
  stored in the tree. This two-stage devlopment is longer than the
  monolithic one but each individual step is simpler. It should really
  be viewed as a blueprint for the development of data structures where
  some of the fields contain redundant information (for efficiency
  reasons).
*}

subsection {* Step 1: Pure binary and AVL trees *}

text {*
  The basic formulation of AVL trees builds on pure binary trees
  and recomputes all height information whenever it is required. This
  simplifies the correctness proofs.
*}

datatype 'a tree\<^isub>0 = ET\<^isub>0 |  MKT\<^isub>0 'a "'a tree\<^isub>0" "'a tree\<^isub>0"

subsubsection {* Auxiliary functions *}

primrec height :: "'a tree\<^isub>0 \<Rightarrow> nat" where
  "height ET\<^isub>0 = 0"
  | "height (MKT\<^isub>0 n l r) = 1 + max (height l) (height r)"

primrec set_of :: "'a tree\<^isub>0 \<Rightarrow> 'a set"  where
  "set_of ET\<^isub>0 = {}"
  | "set_of (MKT\<^isub>0 n l r) = insert n (set_of l \<union> set_of r)"

primrec is_ord :: "('a::preorder) tree\<^isub>0 \<Rightarrow> bool" where
  "is_ord ET\<^isub>0 = True"
  | "is_ord (MKT\<^isub>0 n l r) =
     ((\<forall>n'\<in> set_of l. n' < n) \<and> (\<forall>n'\<in> set_of r. n < n') \<and> is_ord l \<and> is_ord r)"

primrec is_bal :: "'a tree\<^isub>0 \<Rightarrow> bool" where
  "is_bal ET\<^isub>0 = True"
  | "is_bal (MKT\<^isub>0 n l r) =
   ((height l = height r \<or> height l = 1+height r \<or> height r = 1+height l) \<and>
     is_bal l \<and> is_bal r)"


subsubsection {* AVL interface and simple implementation *}

primrec is_in\<^isub>0 :: "('a::preorder) \<Rightarrow> 'a tree\<^isub>0 \<Rightarrow> bool" where
  "is_in\<^isub>0 k ET\<^isub>0 = False"
  | "is_in\<^isub>0 k (MKT\<^isub>0 n l r) = (if k = n then True else
                         if k<n then (is_in\<^isub>0 k l)
                         else (is_in\<^isub>0 k r))"

primrec l_bal\<^isub>0 :: "'a \<Rightarrow> 'a tree\<^isub>0 \<Rightarrow> 'a tree\<^isub>0 \<Rightarrow> 'a tree\<^isub>0" where
  "l_bal\<^isub>0 n (MKT\<^isub>0 ln ll lr) r =
   (if height ll < height lr
    then case lr of ET\<^isub>0 \<Rightarrow> ET\<^isub>0 (* impossible *)
                  | MKT\<^isub>0 lrn lrl lrr \<Rightarrow> MKT\<^isub>0 lrn (MKT\<^isub>0 ln ll lrl) (MKT\<^isub>0 n lrr r)
    else MKT\<^isub>0 ln ll (MKT\<^isub>0 n lr r))"


primrec r_bal\<^isub>0 :: "'a \<Rightarrow> 'a tree\<^isub>0 \<Rightarrow> 'a tree\<^isub>0 \<Rightarrow> 'a tree\<^isub>0" where
  "r_bal\<^isub>0 n l (MKT\<^isub>0 rn rl rr) =
   (if height rl > height rr
    then case rl of ET\<^isub>0 \<Rightarrow> ET\<^isub>0 (* impossible *)
                  | MKT\<^isub>0 rln rll rlr \<Rightarrow> MKT\<^isub>0 rln (MKT\<^isub>0 n l rll) (MKT\<^isub>0 rn rlr rr)
    else MKT\<^isub>0 rn (MKT\<^isub>0 n l rl) rr)"

primrec insrt\<^isub>0 :: "'a::preorder \<Rightarrow> 'a tree\<^isub>0 \<Rightarrow> 'a tree\<^isub>0" where
  "insrt\<^isub>0 x ET\<^isub>0 = MKT\<^isub>0 x ET\<^isub>0 ET\<^isub>0"
  | "insrt\<^isub>0 x (MKT\<^isub>0 n l r) = 
     (if x=n
      then MKT\<^isub>0 n l r
      else if x<n
           then let l' = insrt\<^isub>0 x l
                in if height l' = 2+height r
                   then l_bal\<^isub>0 n l' r
                   else MKT\<^isub>0 n l' r
           else let r' = insrt\<^isub>0 x r
                in if height r' = 2+height l
                   then r_bal\<^isub>0 n l r'
                   else MKT\<^isub>0 n l r')"


subsubsection {* Insertion maintains AVL balance *}

lemma height_l_bal:
 "height l = height r + 2
  \<Longrightarrow> height (l_bal\<^isub>0 n l r) = height r + 2 \<or>
      height (l_bal\<^isub>0 n l r)  = height r + 3"
  by (cases l) (auto split: tree\<^isub>0.split split_if_asm)

lemma height_r_bal:
 "height r = height l + 2
  \<Longrightarrow> height (r_bal\<^isub>0 n l r) = height l + 2 \<or>
      height (r_bal\<^isub>0 n l r) = height l + 3"
  by (cases r) (auto split: tree\<^isub>0.split split_if_asm)

lemma height_insrt:
 "is_bal t
  \<Longrightarrow> height (insrt\<^isub>0 x t) = height t \<or> height (insrt\<^isub>0 x t) = height t + 1"
proof (induct t)
  case ET\<^isub>0 show ?case by simp
next
  case (MKT\<^isub>0 n t1 t2) then show ?case proof (cases "x < n")
    case True show ?thesis
    proof (cases "height (insrt\<^isub>0 x t1) = height t2 + 2")
      case True with height_l_bal [of _ _ n]
      have "height (l_bal\<^isub>0 n (insrt\<^isub>0 x t1) t2) =
        height t2 + 2 \<or> height (l_bal\<^isub>0 n (insrt\<^isub>0 x t1) t2) = height t2 + 3" by simp
      with `x < n` MKT\<^isub>0 show ?thesis by auto
    next
      case False with `x < n` MKT\<^isub>0 show ?thesis by auto
    qed
  next
    case False show ?thesis
    proof (cases "height (insrt\<^isub>0 x t2) = height t1 + 2")
      case True with height_r_bal [of _ _ n]
      have "height (r_bal\<^isub>0 n t1 (insrt\<^isub>0 x t2)) = height t1 + 2 \<or>
        height (r_bal\<^isub>0 n t1 (insrt\<^isub>0 x t2)) = height t1 + 3" by simp
      with `\<not> x < n` MKT\<^isub>0 show ?thesis by auto
    next
      case False with `\<not> x < n` MKT\<^isub>0 show ?thesis by auto
    qed
  qed
qed

lemma is_bal_l_bal:
  "is_bal l \<Longrightarrow> is_bal r \<Longrightarrow> height l = height r + 2 \<Longrightarrow> is_bal (l_bal\<^isub>0 n l r)"
  by (cases l) (auto, auto split: tree\<^isub>0.split)  -- "separating the two auto's is just for speed"

lemma is_bal_r_bal:
  "is_bal l \<Longrightarrow> is_bal r \<Longrightarrow> height r = height l + 2 \<Longrightarrow> is_bal (r_bal\<^isub>0 n l r)"
  by (cases r) (auto, auto split: tree\<^isub>0.split)  -- "separating the two auto's is just for speed"

theorem is_bal_insrt: 
  "is_bal t \<Longrightarrow> is_bal(insrt\<^isub>0 x t)"
proof (induct t)
  case ET\<^isub>0 show ?case by simp
next
  case (MKT\<^isub>0 n t1 t2) show ?case proof (cases "x < n")
    case True show ?thesis
    proof (cases "height (insrt\<^isub>0 x t1) = height t2 + 2")
      case True with `x < n` MKT\<^isub>0 show ?thesis
        by (simp add: is_bal_l_bal)
    next
      case False with `x < n` MKT\<^isub>0 show ?thesis
        using height_insrt [of t1 x] by auto
    qed
  next
    case False show ?thesis
    proof (cases "height (insrt\<^isub>0 x t2) = height t1 + 2")
      case True with `\<not> x < n` MKT\<^isub>0 show ?thesis
        by (simp add: is_bal_r_bal)
    next
      case False with `\<not> x < n` MKT\<^isub>0 show ?thesis
        using height_insrt [of t2 x] by auto
    qed
  qed
qed


subsubsection {* Correctness of insertion *}

lemma set_of_l_bal: "height l = height r + 2 \<Longrightarrow>
  set_of (l_bal\<^isub>0 x l r) = insert x (set_of l \<union> set_of r)"
  by (cases l) (auto split: tree\<^isub>0.splits)

lemma set_of_r_bal: "height r = height l + 2 \<Longrightarrow>
  set_of (r_bal\<^isub>0 x l r) = insert x (set_of l \<union> set_of r)"
  by (cases r) (auto split: tree\<^isub>0.splits)

theorem set_of_insrt: 
  "set_of (insrt\<^isub>0 x t) = insert x (set_of t)"
  by (induct t) (auto simp add:set_of_l_bal set_of_r_bal Let_def)


subsubsection {* Correctness of lookup *}

theorem is_in_correct: "is_ord t \<Longrightarrow> is_in\<^isub>0 k t = (k : set_of t)"
  by (induct t) (auto simp add: less_le_not_le)
  

subsubsection {* Insertion maintains order *}

lemma is_ord_l_bal:
 "is_ord (MKT\<^isub>0 x l r) \<Longrightarrow> height l = Suc (Suc (height r)) \<Longrightarrow>
  is_ord (l_bal\<^isub>0 x l r)"
  by (cases l) (auto split: tree\<^isub>0.splits intro: order_less_trans)

lemma is_ord_r_bal:
 "is_ord (MKT\<^isub>0 x l r) \<Longrightarrow> height r = height l + 2 \<Longrightarrow>
  is_ord (r_bal\<^isub>0 x l r)"
  by (cases r) (auto split:tree\<^isub>0.splits intro: order_less_trans)


text {* If the order is linear, @{const insrt\<^isub>0} maintains the order: *}

theorem is_ord_insrt:
 "is_ord t \<Longrightarrow> is_ord (insrt\<^isub>0 (x::'a::linorder) t)"
  by (induct t) (simp_all add:is_ord_l_bal is_ord_r_bal set_of_insrt
    linorder_not_less order_neq_le_trans Let_def)


subsection {* Step 2: Binary and AVL trees with height information *}

datatype 'a tree = ET |  MKT 'a "'a tree" "'a tree" nat


subsubsection {* Auxiliary functions *}

primrec erase :: "'a tree \<Rightarrow> 'a tree\<^isub>0" where
  "erase ET = ET\<^isub>0"
  | "erase (MKT x l r h) = MKT\<^isub>0 x (erase l) (erase r)"

primrec hinv :: "'a tree \<Rightarrow> bool" where
  "hinv ET \<longleftrightarrow> True"
  | "hinv (MKT x l r h) \<longleftrightarrow> h = 1 + max (height (erase l)) (height (erase r))
                        \<and> hinv l \<and> hinv r"

definition avl :: "'a tree \<Rightarrow> bool" where
  "avl t \<longleftrightarrow> is_bal (erase t) \<and> hinv t"


subsubsection {* AVL interface and efficient implementation *}

primrec is_in :: "('a::preorder) \<Rightarrow> 'a tree \<Rightarrow> bool" where
  "is_in k ET \<longleftrightarrow> False"
  | "is_in k (MKT n l r h) \<longleftrightarrow> (if k = n then True else
                            if k < n then (is_in k l)
                            else (is_in k r))"

primrec ht :: "'a tree \<Rightarrow> nat" where
  "ht ET = 0"
  | "ht (MKT x l r h) = h"

definition mkt :: "'a \<Rightarrow> 'a tree \<Rightarrow> 'a tree \<Rightarrow> 'a tree" where
  "mkt x l r = MKT x l r (max (ht l) (ht r) + 1)"

primrec l_bal :: "'a \<Rightarrow> 'a tree \<Rightarrow> 'a tree \<Rightarrow> 'a tree" where
  "l_bal n (MKT ln ll lr h) r =
   (if ht ll < ht lr
    then case lr of ET \<Rightarrow> ET (* impossible *)
                  | MKT lrn lrl lrr lrh \<Rightarrow>
                    mkt lrn (mkt ln ll lrl) (mkt n lrr r)
    else mkt ln ll (mkt n lr r))"

primrec r_bal :: "'a \<Rightarrow> 'a tree \<Rightarrow> 'a tree \<Rightarrow> 'a tree" where
 "r_bal n l (MKT rn rl rr h) =
   (if ht rl > ht rr
    then case rl of ET \<Rightarrow> ET (* impossible *)
                  | MKT rln rll rlr h \<Rightarrow> mkt rln (mkt n l rll) (mkt rn rlr rr)
    else mkt rn (mkt n l rl) rr)"

primrec insrt :: "'a::preorder \<Rightarrow> 'a tree \<Rightarrow> 'a tree" where
  "insrt x ET = MKT x ET ET 1"
  | "insrt x (MKT n l r h) = 
     (if x=n
      then MKT n l r h
      else if x<n
           then let l' = insrt x l; hl' = ht l'; hr = ht r
                in if hl' = 2+hr then l_bal n l' r
                   else MKT n l' r (1 + max hl' hr)
           else let r' = insrt x r; hl = ht l; hr' = ht r'
                in if hr' = 2+hl then r_bal n l r'
                   else MKT n l r' (1 + max hl hr'))"


subsubsection {* Correctness proof *}

text{* The auxiliary functions are implemented correctly: *}

lemma height_hinv: "hinv t \<Longrightarrow> ht t = height (erase t)"
  by (induct t) simp_all

lemma erase_mkt: "erase (mkt n l r) = MKT\<^isub>0 n (erase l) (erase r)"
  by (simp add: mkt_def)

lemma erase_l_bal:
 "hinv l \<Longrightarrow> hinv r \<Longrightarrow> height (erase l) = height(erase r) + 2 \<Longrightarrow>
  erase (l_bal n l r) = l_bal\<^isub>0 n (erase l) (erase r)"
  by (cases l) (simp_all add: height_hinv erase_mkt split: tree.split)

lemma erase_r_bal:
 "hinv l \<Longrightarrow> hinv r \<Longrightarrow> height(erase r) = height(erase l) + 2 \<Longrightarrow>
  erase (r_bal n l r) = r_bal\<^isub>0 n (erase l) (erase r)"
  by (cases r) (simp_all add: height_hinv erase_mkt split: tree.split)

text {* Function @{const insrt} maintains the invariant: *}

lemma hinv_mkt: "hinv l \<Longrightarrow> hinv r \<Longrightarrow> hinv (mkt x l r)"
  by (simp add: height_hinv mkt_def)

lemma hinv_l_bal:
 "hinv l \<Longrightarrow> hinv r \<Longrightarrow> height(erase l) = height(erase r) + 2 \<Longrightarrow>
  hinv (l_bal n l r)"
  by (cases l) (auto simp add: hinv_mkt split: tree.splits)

lemma hinv_r_bal:
 "hinv l \<Longrightarrow> hinv r \<Longrightarrow> height(erase r) = height(erase l) + 2 \<Longrightarrow>
  hinv (r_bal n l r)"
  by (cases r) (auto simp add: hinv_mkt split: tree.splits)

theorem hinv_insrt: "hinv t \<Longrightarrow> hinv (insrt x t)"
  by (induct t) (simp_all add: Let_def height_hinv hinv_l_bal hinv_r_bal)


text{* Function @{const insrt} implements @{const insrt\<^isub>0}: *}
lemma erase_insrt: "hinv t \<Longrightarrow> erase (insrt x t) = insrt\<^isub>0 x (erase t)"
  by (induct t) (simp_all add: Let_def hinv_insrt height_hinv erase_l_bal erase_r_bal)

text{* Function @{const insrt} meets its spec: *}

corollary "avl t \<Longrightarrow> set_of (erase (insrt x t)) = insert x (set_of (erase t))"
  by (simp add: avl_def erase_insrt set_of_insrt)

text{* Function @{const insrt} preserves the invariants: *}

corollary "avl t \<Longrightarrow> avl (insrt x t)"
  by (simp add: hinv_insrt avl_def erase_insrt is_bal_insrt)

corollary
  "avl t \<Longrightarrow> is_ord (erase t) \<Longrightarrow> is_ord (erase (insrt (x::'a::linorder) t))"
  by (simp add: avl_def erase_insrt is_ord_insrt)

text{* Function @{const is_in} implements @{const is_in}: *}

theorem is_in: "is_in x t = is_in\<^isub>0 x (erase t)"
  by (induct t) simp_all

text{* Function @{const is_in} meets its spec: *}

corollary "is_ord (erase t) \<Longrightarrow> is_in x t \<longleftrightarrow> x \<in> set_of (erase t)"
  by (simp add:is_in is_in_correct)

end
