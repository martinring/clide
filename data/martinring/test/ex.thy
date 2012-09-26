(*
    $Id: ex.thy,v 1.2 2004/11/23 15:14:34 webertj Exp $
    Author: Martin Strecker
*)

header {* Searching in Lists *}

(*<*) theory ex imports Main begin (*>*)

text {* Define a function @{text first_pos} that computes the index
of the first element in a list that satisfies a given predicate: *}

(*<*) consts (*>*)
  first_pos :: "('a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> nat"

text {* The smallest index is @{text 0}.  If no element in the
list satisfies the predicate, the behaviour of @{text first_pos} should
be as described below. *}


text {* Verify your definition by computing
\begin{itemize}
\item the index of the first number equal to @{text 3} in the list
  @{text "[1::nat, 3, 5, 3, 1]"},
\item the index of the first number greater than @{text 4} in the list
  @{text "[1::nat, 3, 5, 7]"},
\item the index of  the first list with more than one element in the list
  @{text "[[], [1, 2], [3]]"}.
\end{itemize}

\emph{Note:} Isabelle does not know the operators @{text ">"} and @{text
"\<ge>"}.  Use @{text "<"} and @{text "\<le>"} instead. *}


text {* Prove that @{text first_pos} returns the length of the list if
and only if no element in the list satisfies the given predicate. *}


text {* Now prove: *}

lemma "list_all (\<lambda> x. \<not> P x) (take (first_pos P xs) xs)"
(*<*) oops (*>*)


text {* How can @{text "first_pos (\<lambda> x. P x \<or> Q x) xs"} be computed from
@{text "first_pos P xs"} and @{text "first_pos Q xs"}?  Can something
similar be said for the conjunction of @{text P} and @{text Q}?  Prove
your statement(s). *}


text {* Suppose @{text P} implies @{text Q}. What can be said about the
relation between @{text "first_pos P xs"} and @{text "first_pos Q xs"}?
Prove your statement. *}


text {* Define a function @{text count} that counts the number of
elements in a list that satisfy a given predicate. *}

(*<*) consts (*>*)
  count :: "('a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> nat"


text {* Show: The number of elements with a given property stays the
same when one reverses a list with @{text rev}.  The proof will require
a lemma. *}


text {* Find and prove a connection between the two functions @{text filter}
and @{text count}. *}


(*<*) end (*>*)
