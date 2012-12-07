(*  Title:       An Isabelle/HOL Formalization of the Textbook Proof of Huffman's Algorithm
    Author:      Jasmin Christian Blanchette <blanchette at in.tum.de>, 2008
    Maintainer:  Jasmin Christian Blanchette <blanchette at in.tum.de>
*)

(*<*)
theory Huffman
imports Main
begin
(*>*)

section {* Introduction *}

subsection {* Binary Codes
              \label{binary-codes} *}

text {*
Suppose we want to encode strings over a finite source alphabet to sequences
of bits. The approach used by ASCII and most other charsets is to map each
source symbol to a distinct $k$-bit code word, where $k$ is fixed and is
typically 8 or 16. To encode a string of symbols, we simply encode each symbol
in turn. Decoding involves mapping each $k$-bit block back to the symbol it
represents.

Fixed-length codes are simple and fast, but they generally waste space. If
we know the frequency $w_a$ of each source symbol $a$, we can save space
by using shorter code words for the most frequent symbols. We
say that a (variable-length) code is {\sl optimum\/} if it minimizes the sum
$\sum_a w_a \vthinspace\delta_a$, where $\delta_a$ is the length of the binary
code word for $a$. Information theory tells us that a code is optimum if
for each source symbol $c$ the code word representing $c$ has length
$$\textstyle \delta_c = \log_2 {1 \over p_c}, \qquad
  \hbox{where}\enskip p_c = {w_c \over \sum_a w_a}.$$
This number is generally not an integer, so we cannot use it directly.
Nonetheless, the above criterion is a useful yardstick and paves the way for
arithmetic coding \cite{rissanen-1976}, a generalization of the method
presented here.

\def\xabacabad{\xa\xb\xa\xc\xa\xb\xa\xd}%
As an example, consider the source string `$\xabacabad$'. We have
$$p_{\xa} = \tfrac{1}{2},\,\; p_{\xb} = \tfrac{1}{4},\,\;
  p_{\xc} = \tfrac{1}{8},\,\; p_{\xd} = \tfrac{1}{8}.$$
The optimum lengths for the binary code words are all integers, namely
$$\delta_{\xa} = 1,\,\; \delta_{\xb} = 2,\,\; \delta_{\xc} = 3,\,\;
  \delta_{\xd} = 3,$$
and they are realized by the code
$$C_1 = \{ \xa \mapsto 0,\, \xb \mapsto 10,\, \xc \mapsto 110,\,
           \xd \mapsto 111 \}.$$
Encoding `$\xabacabad$' produces the 14-bit code word 01001100100111. The code
$C_1$ is optimum: No code that unambiguously encodes source symbols one at a
time could do better than $C_1$ on the input `$\xa\xb\xa\xc\xa\xb\xa\xd$'. In
particular, with a fixed-length code such as
$$C_2 = \{ \xa \mapsto 00,\, \xb \mapsto 01,\, \xc \mapsto 10,\,
           \xd \mapsto 11 \}$$
we need at least 16~bits to encode `$\xabacabad$'.
*}

subsection {* Binary Trees *}

text {*
Inside a program, binary codes can be represented by binary trees. For example,
the trees\strut
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-abcd-unbalanced.pdf}}}
  \qquad \hbox{and} \qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-abcd-balanced.pdf}}}$$
correspond to $C_1$ and $C_2$. The code word for a given
symbol can be obtained as follows: Start at the root and descend toward the leaf
node associated with the symbol one node at a time; generate a 0 whenever the
left child of the current node is chosen and a 1 whenever the right child is
chosen. The generated sequence of 0s and 1s is the code word.

To avoid ambiguities, we require that only leaf nodes are labeled with symbols.
This ensures that no code word is a prefix of another, thereby eliminating the
source of all ambiguities.%
\footnote{Strictly speaking, there is another potential source of ambiguity.
If the alphabet consists of a single symbol $a$, that symbol could be mapped
to the empty code word, and then any string $aa\ldots a$ would map to the
empty bit sequence, giving the decoder no way to recover the original string's
length. This scenario can be ruled out by requiring that the alphabet has
cardinality 2 or more.}
Codes that have this property are called {\sl prefix codes}. As an example of a
code that doesn't have this property, consider the code associated with the
tree\strut
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-abcd-non-prefix.pdf}}}$$
and observe that `$\xb\xb\xb$', `$\xb\xd$', and `$\xd\xb$' all map to the
code word 111.

Each node in a code tree is assigned a {\sl weight}. For a leaf node, the
weight is the frequency of its symbol; for an inner node, it is the sum of the
weights of its subtrees. Code trees can be annotated with their weights:\strut
$$\vcenter{\hbox{\includegraphics[scale=1.25]%
    {tree-abcd-unbalanced-weighted.pdf}}}
  \qquad\qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]%
    {tree-abcd-balanced-weighted.pdf}}}$$
For our purposes, it is sufficient to consider only full binary trees (trees
whose inner nodes all have two children). This is because any inner node with
only one child can advantageously be eliminated; for example,\strut
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-abc-non-full.pdf}}}
  \qquad \hbox{becomes} \qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-abc-full.pdf}}}$$
*}

subsection {* Huffman's Algorithm *}

text {*
David Huffman \cite{huffman-1952} discovered a simple algorithm for
constructing an optimum code tree for specified symbol frequencies:
Create a forest consisting of only leaf nodes, one for each symbol in the
alphabet, taking the given symbol frequencies as initial weights for the nodes.
Then pick the two trees
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1.pdf}}}
  \qquad \hbox{and} \qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-w2.pdf}}}$$

\noindent\strut
with the lowest weights and replace them with the tree
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-w2.pdf}}}$$
Repeat this process until only one tree is left.

As an illustration, executing the algorithm for the frequencies
$$f_{\xd} = 3,\,\; f_{\xe} = 11,\,\; f_{\xf} = 5,\,\; f_{\xs} = 7,\,\;
  f_{\xz} = 2$$
gives rise to the following sequence of states:\strut

\def\myscale{1}%
\setbox\myboxi=\hbox{(9)\strut}%
\setbox\myboxii=\hbox{\includegraphics[scale=\myscale]{tree-prime-step1.pdf}}%
\setbox\myboxiii=\hbox{\includegraphics[scale=\myscale]{tree-prime-step2.pdf}}%
$$(1)\quad\lower\ht\myboxii\hbox{\raise\ht\myboxi\box\myboxii} \qquad\qquad
  (2)\enskip\lower\ht\myboxiii\hbox{\raise\ht\myboxi\box\myboxiii}$$

\vskip.5\smallskipamount

\noindent
\setbox\myboxii=\hbox{\includegraphics[scale=\myscale]{tree-prime-step3.pdf}}%
\setbox\myboxiii=\hbox{\includegraphics[scale=\myscale]{tree-prime-step4.pdf}}%
\setbox\myboxiv=\hbox{\includegraphics[scale=\myscale]{tree-prime-step5.pdf}}%
(3)\quad\lower\ht\myboxii\hbox{\raise\ht\myboxi\box\myboxii}\hfill\quad
  (4)\quad\lower\ht\myboxiii\hbox{\raise\ht\myboxi\box\myboxiii}\hfill
  (5)\enskip\lower\ht\myboxiv\hbox{\raise\ht\myboxi\box\myboxiv\,}

\smallskip
\noindent
Tree~(5) is an optimum tree for the given frequencies.
*}

subsection {* The Textbook Proof *}

text {*
Why does the algorithm work? In his article, Huffman gave some motivation but
no real proof. For a proof sketch, we turn to Donald Knuth
\cite[p.~403--404]{knuth-1997}:

\begin{quote}
It is not hard to prove that this method does in fact minimize the weighted
path length [i.e., $\sum_a w_a \vthinspace\delta_a$], by induction on $m$.
Suppose we have $w_1 \le w_2 \le w_3 \le \cdots \le w_m$, where $m \ge 2$, and
suppose that we are given a tree that minimizes the weighted path length.
(Such a tree certainly exists, since only finitely many binary trees with $m$
terminal nodes are possible.) Let $V$ be an internal node of maximum distance
from the root. If $w_1$ and $w_2$ are not the weights already attached to the
children of $V$, we can interchange them with the values that are already
there; such an interchange does not increase the weighted path length. Thus
there is a tree that minimizes the weighted path length and contains the
subtree\strut
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-w2-leaves.pdf}}}$$
Now it is easy to prove that the weighted path length of such a tree is
minimized if and only if the tree with
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-w2-leaves.pdf}}}
  \qquad \hbox{replaced by} \qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-plus-w2.pdf}}}$$
has minimum path length for the weights $w_1 + w_2$, $w_3$, $\ldots\,$, $w_m$.
\end{quote}

\noindent
There is, however, a small oddity in this proof: It is not clear why we must
assert the existence of an optimum tree that contains the subtree
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-w2-leaves.pdf}}}$$
Indeed, the formalization works without it.

Cormen et al.\ \cite[p.~385--391]{cormen-et-al-2001} provide a very similar
proof, articulated around the following propositions:

\begin{quote}
\textsl{\textbf{Lemma 16.2}} \\
Let $C$ be an alphabet in which each character $c \in C$ has frequency $f[c]$.
Let $x$ and $y$ be two characters in $C$ having the lowest frequencies. Then
there exists an optimal prefix code for $C$ in which the codewords for $x$ and
$y$ have the same length and differ only in the last bit.

\medskip

\textsl{\textbf{Lemma 16.3}} \\
Let $C$ be a given alphabet with frequency $f[c]$ defined for each character
$c \in C$. Let $x$ and $y$ be two characters in $C$ with minimum frequency. Let
$C'$ be the alphabet $C$ with characters $x$, $y$ removed and (new) character
$z$ added, so that $C' = C - \{x, y\} \cup {\{z\}}$; define $f$ for $C'$ as for
$C$, except that $f[z] = f[x] + f[y]$. Let $T'$ be any tree representing an
optimal prefix code for the alphabet $C'$. Then the tree $T$, obtained from
$T'$ by replacing the leaf node for $z$ with an internal node having $x$ and
$y$ as children, represents an optimal prefix code for the alphabet $C$.

\medskip

\textsl{\textbf{Theorem 16.4}} \\
Procedure \textsc{Huffman} produces an optimal prefix code.
\end{quote}
*}

subsection {* Overview of the Formalization *}

text {*
This report presents a formalization of the proof of Huffman's algorithm
written using Isabelle/HOL \cite{nipkow-et-al-2008}. Our proof is based on the
informal proofs given by Knuth and Cormen et al. The development was done
independently of Laurent Th\'ery's Coq proof \cite{thery-2003,thery-2004},
which through its ``cover'' concept represents a considerable departure from
the textbook proof.

The development consists of 90 lemmas and 5 theorems. Most of them have very
short proofs thanks to the extensive use of simplification rules and custom
induction rules. The remaining proofs are written using the structured proof
format Isar \cite{wenzel-2008} and are accompanied by informal arguments and
diagrams.

The report is organized as follows. Section~\ref{trees-and-forests} defines
the datatypes for binary code trees and forests and develops a small library of
related functions. (Incidentally, there is nothing special about binary codes
and binary trees. Huffman's algorithm and its proof can be generalized to
$n$-ary trees \cite[p.~405 and 595]{knuth-1997}.) Section~\ref{implementation}
presents a functional implementation of the algorithm. Section~\ref{auxiliary}
defines several tree manipulation functions needed for the proof.
Section~\ref{formalization} presents three key lemmas and concludes with the
optimality theorem. Section~\ref{related-work} compares our work with Th\'ery's
Coq proof. Finally, Section~\ref{conclusion} concludes the report.
*}

subsection {* Overview of Isabelle's HOL Logic *}

text {*
This section presents a brief overview of the Isabelle/HOL logic, so that
readers not familiar with the system can at least understand the lemmas and
theorems, if not the proofs. Readers who already know Isabelle are encouraged
to skip this section.

Isabelle is a generic theorem prover whose built-in metalogic is an
intuitionistic fragment of higher-order logic
\cite{gordon-melham-1994,nipkow-et-al-2008}. The metalogical operators are
material implication, written
\vthinspace@{text "\<lbrakk>\<phi>\<^isub>1; \<dots>; \<phi>\<^isub>n\<rbrakk> \<Longrightarrow> \<psi>"}\vthinspace{} (``if @{term \<phi>\<^isub>1} and
$\ldots$ and @{term \<phi>\<^isub>n}, then @{term \<psi>}''), universal quantification,
written \vthinspace@{text "\<And>x\<^isub>1 \<dots> x\<^isub>n. \<psi>"}\vthinspace{} (``for all $@{term x\<^isub>1},
\ldots, @{term x\<^isub>n}$ we have @{term \<psi>}''), and equality, written
\vthinspace@{text "t \<equiv> u"}.

The incarnation of Isabelle that we use in this development, Isabelle/HOL,
provides a more elaborate version of higher-order logic, complete with the
familiar connectives and quantifiers (@{text "\<not>"}, @{text "\<and>"}, @{text "\<or>"},
@{text "\<longrightarrow>"}, @{text "\<forall>"}, and @{text "\<exists>"}) on terms of type @{typ bool}. In
addition, $=$ expresses equivalence. The formulas
\vthinspace@{text "\<And>x\<^isub>1 \<dots> x\<^isub>m. \<lbrakk>\<phi>\<^isub>1; \<dots>; \<phi>\<^isub>n\<rbrakk> \<Longrightarrow> \<psi>"}\vthinspace{} and
\vthinspace@{text "\<forall>x\<^isub>1. \<dots> \<forall>x\<^isub>m. \<phi>\<^isub>1 \<and>"}$\,\cdots\,$@{text "\<and> \<phi>\<^isub>n \<longrightarrow> \<psi>"}%
\vthinspace{} are logically equivalent, but they interact differently with
Isabelle's proof tactics.

The term language consists of simply typed $\lambda$-terms written in an
ML-like syntax \cite{milner-et-al-1997}. Function application expects no
parentheses around the argument list and no commas between the arguments, as in
@{term "f x y"}. Syntactic sugar provides an infix syntax for common operators,
such as $x = y$ and $x + y$. Types are inferred automatically in most cases, but
they can always be supplied using an annotation @{text "t::\<tau>"}, where @{term t}
is a term and @{text \<tau>} is its type. The type of total functions from
@{typ 'a} to @{typ 'b} is written @{typ "'a \<Rightarrow> 'b"}. Variables may range
over functions.

The type of natural numbers is called @{typ nat}. The type of lists over type
@{text 'a}, written @{typ "'a list"}, features the empty list @{term "[]"},
the infix constructor @{term "x # xs"} (where @{term x} is an element of type
@{text 'a} and @{term xs} is a list over @{text 'a}), and the conversion
function @{term set} from lists to sets. The type of sets over @{text 'a} is
written @{typ "'a set"}. Operations on sets are written using traditional
mathematical notation.
*}

subsection {* Head of the Theory File *}

text {*
The Isabelle theory starts in the standard way.

\myskip

\noindent
\isacommand{theory} @{text "Huffman"} \\
\isacommand{imports} @{text "Main"} \\
\isacommand{begin}

\myskip

\noindent
We attach the @{text "simp"} attribute to some predefined lemmas to add them to
the default set of simplification rules.
*}

declare Int_Un_distrib [simp]
        Int_Un_distrib2 [simp]
        min_max.sup_absorb1 [simp]
        min_max.sup_absorb2 [simp]

section {* Definition of Prefix Code Trees and Forests
           \label{trees-and-forests} *}

subsection {* Tree Datatype *}

text {*
A {\sl prefix code tree\/} is a full binary tree in which leaf nodes are of the
form @{term "Leaf w a"}, where @{term a} is a symbol and @{term w} is the
frequency associated with @{term a}, and inner nodes are of the form
@{term "InnerNode w t\<^isub>1 t\<^isub>2"}, where @{term t\<^isub>1} and @{term t\<^isub>2} are the left and
right subtrees and @{term w} caches the sum of the weights of @{term t\<^isub>1} and
@{term t\<^isub>2}. Prefix code trees are polymorphic on the symbol datatype~@{typ 'a}.
*}

datatype 'a tree =
Leaf nat 'a |
InnerNode nat "('a tree)" "('a tree)"

subsection {* Forest Datatype *}

text {*
The intermediate steps of Huffman's algorithm involve a list of prefix code
trees, or {\sl prefix code forest}.
*}

type_synonym 'a forest = "'a tree list"

subsection {* Alphabet *}

text {*
The {\sl alphabet\/} of a code tree is the set of symbols appearing in the
tree's leaf nodes.
*}

primrec alphabet :: "'a tree \<Rightarrow> 'a set" where
"alphabet (Leaf w a) = {a}" |
"alphabet (InnerNode w t\<^isub>1 t\<^isub>2) = alphabet t\<^isub>1 \<union> alphabet t\<^isub>2"

text {*
For sets and predicates, Isabelle gives us the choice between inductive
definitions (\isakeyword{inductive\_set} and \isakeyword{inductive}) and
recursive functions (\isakeyword{primrec}, \isakeyword{fun}, and
\isakeyword{function}). In this development, we consistently favor recursion
over induction, for two reasons:

\begin{myitemize}
\item Recursion gives rise to simplification rules that greatly help automatic
proof tactics. In contrast, reasoning about inductively defined sets and
predicates involves introduction and elimination rules, which are more clumsy
than simplification rules.

\item Isabelle's counterexample generator \isakeyword{quickcheck}
\cite{berghofer-nipkow-2004}, which we used extensively during the top-down
development of the proof (together with \isakeyword{sorry}), has better support
for recursive definitions.
\end{myitemize}

The alphabet of a forest is defined as the union of the alphabets of the trees
that compose it. Although Isabelle supports overloading for non-overlapping
types, we avoid many type inference problems by attaching an
`\raise.3ex\hbox{@{text "\<^isub>F"}}' subscript to the forest generalizations of
functions defined on trees.
*}

primrec alphabet\<^isub>F :: "'a forest \<Rightarrow> 'a set" where
"alphabet\<^isub>F [] = {}" |
"alphabet\<^isub>F (t # ts) = alphabet t \<union> alphabet\<^isub>F ts"

text {*
Alphabets are central to our proofs, and we need the following basic facts
about them.
*}

lemma finite_alphabet [simp]:
"finite (alphabet t)"
by (induct t) auto

lemma exists_in_alphabet:
"\<exists>a. a \<in> alphabet t"
by (induct t) auto

subsection {* Consistency *}

text {*
A tree is {\sl consistent\/} if for each inner node the alphabets of the two
subtrees are disjoint. Intuitively, this means that every symbol in the
alphabet occurs in exactly one leaf node. Consistency is a sufficient condition
for $\delta_a$ (the length of the {\sl unique\/} code word for $a$) to be
defined. Although this well\-formed\-ness property isn't mentioned in algorithms
textbooks \cite{aho-et-al-1983,cormen-et-al-2001,knuth-1997}, it is essential
and appears as an assumption in many of our lemmas.
*}

primrec consistent :: "'a tree \<Rightarrow> bool" where
"consistent (Leaf w a) = True" |
"consistent (InnerNode w t\<^isub>1 t\<^isub>2) =
     (consistent t\<^isub>1 \<and> consistent t\<^isub>2 \<and> alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {})"

primrec consistent\<^isub>F :: "'a forest \<Rightarrow> bool" where
"consistent\<^isub>F [] = True" |
"consistent\<^isub>F (t # ts) =
     (consistent t \<and> consistent\<^isub>F ts \<and> alphabet t \<inter> alphabet\<^isub>F ts = {})"

text {*
Several of our proofs are by structural induction on consistent trees $t$ and
involve one symbol $a$. These proofs typically distinguish the following cases.

\begin{myitemize}
\item[] {\sc Base case:}\enspace $t = @{term "Leaf w b"}$.
\item[] {\sc Induction step:}\enspace $t = @{term "InnerNode w t\<^isub>1 t\<^isub>2"}$.
\item[] \noindent\kern\leftmargin {\sc Subcase 1:}\enspace $a$ belongs to
        @{term t\<^isub>1} but not to @{term t\<^isub>2}.
\item[] \noindent\kern\leftmargin {\sc Subcase 2:}\enspace $a$ belongs to
        @{term t\<^isub>2} but not to @{term t\<^isub>1}.
\item[] \noindent\kern\leftmargin {\sc Subcase 3:}\enspace $a$ belongs to
        neither @{term t\<^isub>1} nor @{term t\<^isub>2}.
\end{myitemize}

\noindent
Thanks to the consistency assumption, we can rule out the subcase where $a$
belongs to both subtrees.

Instead of performing the above case distinction manually, we encode it in a
custom induction rule. This saves us from writing repetitive proof scripts and
helps Isabelle's automatic proof tactics.
*}

lemma tree_induct_consistent [consumes 1, case_names base step\<^isub>1 step\<^isub>2 step\<^isub>3]:
"\<lbrakk>consistent t;
  \<And>w\<^isub>b b a. P (Leaf w\<^isub>b b) a;
  \<And>w t\<^isub>1 t\<^isub>2 a.
     \<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {};
      a \<in> alphabet t\<^isub>1; a \<notin> alphabet t\<^isub>2; P t\<^isub>1 a; P t\<^isub>2 a\<rbrakk> \<Longrightarrow>
     P (InnerNode w t\<^isub>1 t\<^isub>2) a;
  \<And>w t\<^isub>1 t\<^isub>2 a.
     \<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {};
      a \<notin> alphabet t\<^isub>1; a \<in> alphabet t\<^isub>2; P t\<^isub>1 a; P t\<^isub>2 a\<rbrakk> \<Longrightarrow>
     P (InnerNode w t\<^isub>1 t\<^isub>2) a;
  \<And>w t\<^isub>1 t\<^isub>2 a.
     \<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {};
      a \<notin> alphabet t\<^isub>1; a \<notin> alphabet t\<^isub>2; P t\<^isub>1 a; P t\<^isub>2 a\<rbrakk> \<Longrightarrow>
     P (InnerNode w t\<^isub>1 t\<^isub>2) a\<rbrakk> \<Longrightarrow>
 P t a"

txt {*
The proof relies on the \textit{induct\_scheme} and
\textit{lexicographic\_order} tactics, which automate the most tedious
aspects of deriving induction rules. The alternative would have been to perform
a standard structural induction on @{term t} and proceed by cases, which is
straightforward but long-winded.
*}

apply rotate_tac
apply induction_schema
       apply atomize_elim
       apply (case_tac t)
        apply fastforce
       apply fastforce
by lexicographic_order

text {*
The \textit{induct\_scheme} tactic reduces the putative induction rule to
simpler proof obligations.
Internally, it reuses the machinery that constructs the default induction
rules. The resulting proof obligations concern (a)~case completeness,
(b)~invariant preservation (in our case, tree consistency), and
(c)~wellfoundedness. For @{thm [source] tree_induct_consistent}, the obligations
(a)~and (b) can be discharged using
Isabelle's simplifier and classical reasoner, whereas (c) requires a single
invocation of \textit{lexicographic\_order}, a tactic that was originally
designed to prove termination of recursive functions
\cite{bulwahn-et-al-2007,krauss-2007,krauss-2009}.
*}

subsection {* Symbol Depths *}

text {*
The {\sl depth\/} of a symbol (which we denoted by $\delta_a$ in
Section~\ref{binary-codes}) is the length of the path from the root to the
leaf node labeled with that symbol, or equivalently the length of the code word
for the symbol. Symbols that don't occur in the tree or that occur at the root
of a one-node tree have depth 0. If a symbol occurs in several leaf nodes (which
may happen with inconsistent trees), the depth is arbitrarily defined in terms
of the leftmost node labeled with that symbol.
*}

primrec depth :: "'a tree \<Rightarrow> 'a \<Rightarrow> nat" where
"depth (Leaf w b) a = 0" |
"depth (InnerNode w t\<^isub>1 t\<^isub>2) a =
     (if a \<in> alphabet t\<^isub>1 then depth t\<^isub>1 a + 1
      else if a \<in> alphabet t\<^isub>2 then depth t\<^isub>2 a + 1
      else 0)"

text {*
The definition may seem very inefficient from a functional programming
point of view, but it does not matter, because unlike Huffman's algorithm, the
@{const depth} function is merely a reasoning tool and is never actually
executed.
*}

subsection {* Height *}

text {*
The {\sl height\/} of a tree is the length of the longest path from the root to
a leaf node, or equivalently the length of the longest code word. This is
readily generalized to forests by taking the maximum of the trees' heights. Note
that a tree has height 0 if and only if it is a leaf node, and that a forest has
height 0 if and only if all its trees are leaf nodes.
*}

primrec height :: "'a tree \<Rightarrow> nat" where
"height (Leaf w a) = 0" |
"height (InnerNode w t\<^isub>1 t\<^isub>2) = max (height t\<^isub>1) (height t\<^isub>2) + 1"

primrec height\<^isub>F :: "'a forest \<Rightarrow> nat" where
"height\<^isub>F [] = 0" |
"height\<^isub>F (t # ts) = max (height t) (height\<^isub>F ts)"

text {*
The depth of any symbol in the tree is bounded by the tree's height, and there
exists a symbol with a depth equal to the height.
*}

lemma depth_le_height:
"depth t a \<le> height t"
by (induct t) auto

lemma exists_at_height:
"consistent t \<Longrightarrow> \<exists>a \<in> alphabet t. depth t a = height t"
proof (induct t)
  case Leaf thus ?case by simp
next
  case (InnerNode w t\<^isub>1 t\<^isub>2)
  note hyps = InnerNode
  let ?t = "InnerNode w t\<^isub>1 t\<^isub>2"
  from hyps obtain b where b: "b \<in> alphabet t\<^isub>1" "depth t\<^isub>1 b = height t\<^isub>1" by auto
  from hyps obtain c where c: "c \<in> alphabet t\<^isub>2" "depth t\<^isub>2 c = height t\<^isub>2" by auto
  let ?a = "if height t\<^isub>1 \<ge> height t\<^isub>2 then b else c"
  from b c have "?a \<in> alphabet ?t" "depth ?t ?a = height ?t"
    using `consistent ?t` by auto
  thus "\<exists>a \<in> alphabet ?t. depth ?t a = height ?t" ..
qed

text {*
The following elimination rules help Isabelle's classical prover, notably the
\textit{auto} tactic. They are easy consequences of the inequation
@{thm depth_le_height [no_vars]}.
*}

lemma depth_max_heightE_left [elim!]:
"\<lbrakk>depth t\<^isub>1 a = max (height t\<^isub>1) (height t\<^isub>2);
  \<lbrakk>depth t\<^isub>1 a = height t\<^isub>1; height t\<^isub>1 \<ge> height t\<^isub>2\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow>
 P"
by (cut_tac t = t\<^isub>1 and a = a in depth_le_height) simp

lemma depth_max_heightE_right [elim!]:
"\<lbrakk>depth t\<^isub>2 a = max (height t\<^isub>1) (height t\<^isub>2);
  \<lbrakk>depth t\<^isub>2 a = height t\<^isub>2; height t\<^isub>2 \<ge> height t\<^isub>1\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow>
 P"
by (cut_tac t = t\<^isub>2 and a = a in depth_le_height) simp

text {*
We also need the following lemma.
*}

lemma height_gt_0_alphabet_eq_imp_height_gt_0:
assumes "height t > 0" "consistent t" "alphabet t = alphabet u"
shows "height u > 0"
proof (cases t)
  case Leaf thus ?thesis using assms by simp
next
  case (InnerNode w t\<^isub>1 t\<^isub>2)
  note t = InnerNode
  from exists_in_alphabet obtain b where b: "b \<in> alphabet t\<^isub>1" ..
  from exists_in_alphabet obtain c where c: "c \<in> alphabet t\<^isub>2" ..
  from b c have bc: "b \<noteq> c" using t `consistent t` by fastforce
  show ?thesis
  proof (cases u)
    case Leaf thus ?thesis using b c bc t assms by auto
  next
    case InnerNode thus ?thesis by simp
  qed
qed

subsection {* Symbol Frequencies *}

text {*
The {\sl frequency\/} of a symbol (which we denoted by $w_a$ in
Section~\ref{binary-codes}) is the sum of the weights attached to the
leaf nodes labeled with that symbol. If the tree is consistent, the sum
comprises at most one nonzero term. The frequency is then the weight of the leaf
node labeled with the symbol, or 0 if there is no such node. The generalization
to forests is straightforward.
*}

primrec freq :: "'a tree \<Rightarrow> 'a \<Rightarrow> nat" where
"freq (Leaf w a) = (\<lambda>b. if b = a then w else 0)" |
"freq (InnerNode w t\<^isub>1 t\<^isub>2) = (\<lambda>b. freq t\<^isub>1 b + freq t\<^isub>2 b)"

primrec freq\<^isub>F :: "'a forest \<Rightarrow> 'a \<Rightarrow> nat" where
"freq\<^isub>F [] = (\<lambda>b. 0)" |
"freq\<^isub>F (t # ts) = (\<lambda>b. freq t b + freq\<^isub>F ts b)"

text {*
Alphabet and symbol frequencies are intimately related. Simplification rules
ensure that sums of the form @{term "freq t\<^isub>1 a + freq t\<^isub>2 a"} collapse to a
single term when we know which tree @{term a} belongs to.
*}

lemma notin_alphabet_imp_freq_0 [simp]:
"a \<notin> alphabet t \<Longrightarrow> freq t a = 0"
by (induct t) simp+

lemma notin_alphabet\<^isub>F_imp_freq\<^isub>F_0 [simp]:
"a \<notin> alphabet\<^isub>F ts \<Longrightarrow> freq\<^isub>F ts a = 0"
by (induct ts) simp+

lemma freq_0_right [simp]:
"\<lbrakk>alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {}; a \<in> alphabet t\<^isub>1\<rbrakk> \<Longrightarrow> freq t\<^isub>2 a = 0"
by (auto intro: notin_alphabet_imp_freq_0 simp: disjoint_iff_not_equal)

lemma freq_0_left [simp]:
"\<lbrakk>alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {}; a \<in> alphabet t\<^isub>2\<rbrakk> \<Longrightarrow> freq t\<^isub>1 a = 0"
by (auto simp: disjoint_iff_not_equal)

text {*
Two trees are {\em comparable} if they have the same alphabet and symbol
frequencies. This is an important concept, because it allows us to state not
only that the tree constructed by Huffman's algorithm is optimal but also that
it has the expected alphabet and frequencies.

We close this section with a more technical lemma.
*}

lemma height\<^isub>F_0_imp_Leaf_freq\<^isub>F_in_set:
"\<lbrakk>consistent\<^isub>F ts; height\<^isub>F ts = 0; a \<in> alphabet\<^isub>F ts\<rbrakk> \<Longrightarrow>
 Leaf (freq\<^isub>F ts a) a \<in> set ts"
proof (induct ts)
  case Nil thus ?case by simp
next
  case (Cons t ts) show ?case using Cons
  proof (cases t)
    case Leaf thus ?thesis using Cons by clarsimp
  next
    case InnerNode thus ?thesis using Cons by clarsimp
  qed
qed

subsection {* Weight *}

text {*
The @{term weight} function returns the weight of a tree. In the
@{const InnerNode} case, we ignore the weight cached in the node and instead
compute the tree's weight recursively. This makes reasoning simpler because we
can then avoid specifying cache correctness as an assumption in our lemmas.
*}

primrec weight :: "'a tree \<Rightarrow> nat" where
"weight (Leaf w a) = w" |
"weight (InnerNode w t\<^isub>1 t\<^isub>2) = weight t\<^isub>1 + weight t\<^isub>2"

text {*
The weight of a tree is the sum of the frequencies of its symbols.

\myskip

\noindent
\isacommand{lemma} @{text "weight_eq_Sum_freq"}: \\
{\isachardoublequoteopen}$\displaystyle @{text "consistent t \<Longrightarrow> weight t"} =
\!\!\sum_{a\in @{term "alphabet t"}}^{\phantom{.}}\!\! @{term "freq t a"}$%
{\isachardoublequoteclose}

\vskip-\myskipamount
*}

(*<*)
lemma weight_eq_Sum_freq:
"consistent t \<Longrightarrow> weight t = (\<Sum>a \<in> alphabet t. freq t a)"
(*>*)
by (induct t) (auto simp: setsum_Un_disjoint)

text {*
The assumption @{term "consistent t"} is not necessary, but it simplifies the
proof by letting us invoke the lemma @{thm [source] setsum_Un_disjoint}:
$$@{text "\<lbrakk>finite A; finite B; A \<inter> B = {}\<rbrakk> \<Longrightarrow>"}~\!\sum_{x\in A} @{term "g x"}
\vthinspace \mathrel{+} \sum_{x\in B} @{term "g x"}\vthinspace = %
 \!\!\sum_{x\in A \cup B}\! @{term "g x"}.$$
*}

subsection {* Cost *}

text {*
The {\sl cost\/} of a consistent tree, sometimes called the {\sl weighted path
length}, is given by the sum $\sum_{a \in @{term "alphabet t"}\,}
@{term "freq t a"} \mathbin{@{text "*"}} @{term "depth t a"}$
(which we denoted by $\sum_a w_a \vthinspace\delta_a$ in
Section~\ref{binary-codes}). It obeys a simple recursive law.
*}

primrec cost :: "'a tree \<Rightarrow> nat" where
"cost (Leaf w a) = 0" |
"cost (InnerNode w t\<^isub>1 t\<^isub>2) = weight t\<^isub>1 + cost t\<^isub>1 + weight t\<^isub>2 + cost t\<^isub>2"

text {*
One interpretation of this recursive law is that the cost of a tree is the sum
of the weights of its inner nodes \cite[p.~405]{knuth-1997}. (Recall that
$@{term "weight (InnerNode w t\<^isub>1 t\<^isub>2)"} = @{term "weight t\<^isub>1 + weight t\<^isub>2"}$.) Since
the cost of a tree is such a fundamental concept, it seems necessary to prove
that the above function definition is correct.

\myskip

\noindent
\isacommand{theorem} @{text "cost_eq_Sum_freq_mult_depth"}: \\
{\isachardoublequoteopen}$\displaystyle @{text "consistent t \<Longrightarrow> cost t"} =
\!\!\sum_{a\in @{term "alphabet t"}}^{\phantom{.}}\!\!
@{term "freq t a * depth t a"}$%
{\isachardoublequoteclose}

\myskip

\noindent
The proof is by structural induction on $t$. If $t = @{term "Leaf w b"}$, both
sides of the equation simplify to 0. This leaves the case $@{term t} =
@{term "InnerNode w t\<^isub>1 t\<^isub>2"}$. Let $A$, $A_1$, and $A_2$ stand for
@{term "alphabet t"}, @{term "alphabet t\<^isub>1"}, and @{term "alphabet t\<^isub>2"},
respectively. We have
%
$$\begin{tabularx}{\textwidth}{@%
{\hskip\leftmargin}cX@%
{}}
    & @{term "cost t"} \\
\eq & \justif{definition of @{const cost}} \\
    & $@{term "weight t\<^isub>1 + cost t\<^isub>1 + weight t\<^isub>2 + cost t\<^isub>2"}$ \\
\eq & \justif{induction hypothesis} \\
    & $@{term "weight t\<^isub>1"} \mathrel{+}
       \sum_{a\in A_1\,} @{term "freq t\<^isub>1 a * depth t\<^isub>1 a"} \mathrel{+} {}$ \\
    & $@{term "weight t\<^isub>2"} \mathrel{+}
       \sum_{a\in A_2\,} @{term "freq t\<^isub>2 a * depth t\<^isub>2 a"}$ \\
\eq & \justif{definition of @{const depth}, consistency} \\[\extrah]
    & $@{term "weight t\<^isub>1"} \mathrel{+}
       \sum_{a\in A_1\,} @{term "freq t\<^isub>1 a * (depth t a - 1)"} \mathrel{+}
       {}$ \\
    & $@{term "weight t\<^isub>2"} \mathrel{+}
       \sum_{a\in A_2\,} @{term "freq t\<^isub>2 a * (depth t a - 1)"}$ \\[\extrah]
\eq & \justif{distributivity of @{text "*"} and $\sum$ over $-$} \\[\extrah]
    & $@{term "weight t\<^isub>1"} \mathrel{+}
       \sum_{a\in A_1\,} @{term "freq t\<^isub>1 a * depth t a"} \mathrel{-}
       \sum_{a\in A_1\,} @{term "freq t\<^isub>1 a"} \mathrel{+} {}$ \\
    & $@{term "weight t\<^isub>2"} \mathrel{+}
       \sum_{a\in A_2\,} @{term "freq t\<^isub>2 a * depth t a"} \mathrel{-}
       \sum_{a\in A_2\,} @{term "freq t\<^isub>2 a"}$ \\[\extrah]
\eq & \justif{@{thm [source] weight_eq_Sum_freq}} \\[\extrah]
    & $\sum_{a\in A_1\,} @{term "freq t\<^isub>1 a * depth t a"} \mathrel{+}
       \sum_{a\in A_2\,} @{term "freq t\<^isub>2 a * depth t a"}$ \\[\extrah]
\eq & \justif{definition of @{const freq}, consistency} \\[\extrah]
    & $\sum_{a\in A_1\,} @{term "freq t a * depth t a"} \mathrel{+}
       \sum_{a\in A_2\,} @{term "freq t a * depth t a"}$ \\[\extrah]
\eq & \justif{@{thm [source] setsum_Un_disjoint}, consistency} \\
    & $\sum_{a\in A_1\cup A_2\,} @{term "freq t a * depth t a"}$ \\
\eq & \justif{definition of @{const alphabet}} \\
    & $\sum_{a\in A\,} @{term "freq t a * depth t a"}$.
\end{tabularx}$$

\noindent
The structured proof closely follows this argument.
*}

(*<*)
theorem cost_eq_Sum_freq_mult_depth:
"consistent t \<Longrightarrow> cost t = (\<Sum>a \<in> alphabet t. freq t a * depth t a)"
(*>*)
proof (induct t)
  case Leaf thus ?case by simp
next
  case (InnerNode w t\<^isub>1 t\<^isub>2)
  let ?t = "InnerNode w t\<^isub>1 t\<^isub>2"
  let ?A = "alphabet ?t" and ?A\<^isub>1 = "alphabet t\<^isub>1" and ?A\<^isub>2 = "alphabet t\<^isub>2"
  note c = `consistent ?t`
  note hyps = InnerNode
  have d\<^isub>2: "\<And>a. \<lbrakk>?A\<^isub>1 \<inter> ?A\<^isub>2 = {}; a \<in> ?A\<^isub>2\<rbrakk> \<Longrightarrow> depth ?t a = depth t\<^isub>2 a + 1"
    by auto
  have "cost ?t = weight t\<^isub>1 + cost t\<^isub>1 + weight t\<^isub>2 + cost t\<^isub>2" by simp
  also have "\<dots> = weight t\<^isub>1 + (\<Sum>a \<in> ?A\<^isub>1. freq t\<^isub>1 a * depth t\<^isub>1 a) +
                  weight t\<^isub>2 + (\<Sum>a \<in> ?A\<^isub>2. freq t\<^isub>2 a * depth t\<^isub>2 a)"
    using hyps by simp
  also have "\<dots> = weight t\<^isub>1 + (\<Sum>a \<in> ?A\<^isub>1. freq t\<^isub>1 a * (depth ?t a - 1)) +
                  weight t\<^isub>2 + (\<Sum>a \<in> ?A\<^isub>2. freq t\<^isub>2 a * (depth ?t a - 1))"
    using c d\<^isub>2 by simp
  also have "\<dots> = weight t\<^isub>1 + (\<Sum>a \<in> ?A\<^isub>1. freq t\<^isub>1 a * depth ?t a)
                            - (\<Sum>a \<in> ?A\<^isub>1. freq t\<^isub>1 a) +
                  weight t\<^isub>2 + (\<Sum>a \<in> ?A\<^isub>2. freq t\<^isub>2 a * depth ?t a)
                            - (\<Sum>a \<in> ?A\<^isub>2. freq t\<^isub>2 a)"
    using c d\<^isub>2 by (simp add: setsum_addf)
  also have "\<dots> = (\<Sum>a \<in> ?A\<^isub>1. freq t\<^isub>1 a * depth ?t a) +
                  (\<Sum>a \<in> ?A\<^isub>2. freq t\<^isub>2 a * depth ?t a)"
    using c by (simp add: weight_eq_Sum_freq)
  also have "\<dots> = (\<Sum>a \<in> ?A\<^isub>1. freq ?t a * depth ?t a) +
                  (\<Sum>a \<in> ?A\<^isub>2. freq ?t a * depth ?t a)"
    using c by auto
  also have "\<dots> = (\<Sum>a \<in> ?A\<^isub>1 \<union> ?A\<^isub>2. freq ?t a * depth ?t a)"
    using c by (simp add: setsum_Un_disjoint)
  also have "\<dots> = (\<Sum>a \<in> ?A. freq ?t a * depth ?t a)" by simp
  finally show ?case .
qed

text {*
Finally, it should come as no surprise that trees with height 0 have cost 0.
*}

lemma height_0_imp_cost_0 [simp]:
"height t = 0 \<Longrightarrow> cost t = 0"
by (case_tac t) simp+

subsection {* Optimality *}

text {*
A tree is optimum if and only if its cost is not greater than that of any
comparable tree. We can ignore inconsistent trees without loss of generality.
*}

definition optimum :: "'a tree \<Rightarrow> bool" where
"optimum t \<equiv>
     \<forall>u. consistent u \<longrightarrow> alphabet t = alphabet u \<longrightarrow> freq t = freq u \<longrightarrow>
         cost t \<le> cost u"

section {* Functional Implementation of Huffman's Algorithm
           \label{implementation} *}

subsection {* Cached Weight *}

text {*
The {\sl cached weight\/} of a node is the weight stored directly in the node.
Our arguments rely on the computed weight (embodied by the @{const weight}
function) rather than the cached weight, but the implementation of Huffman's
algorithm uses the cached weight for performance reasons.
*}

primrec cachedWeight :: "'a tree \<Rightarrow> nat" where
"cachedWeight (Leaf w a) = w" |
"cachedWeight (InnerNode w t\<^isub>1 t\<^isub>2) = w"

text {*
The cached weight of a leaf node is identical to its computed weight.
*}

lemma height_0_imp_cachedWeight_eq_weight [simp]:
"height t = 0 \<Longrightarrow> cachedWeight t = weight t"
by (case_tac t) simp+

subsection {* Tree Union *}

text {*
The implementation of Huffman's algorithm builds on two additional auxiliary
functions. The first one, @{text uniteTrees}, takes two trees
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1.pdf}}}
  \qquad \hbox{and} \qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-w2.pdf}}}$$

\noindent
and returns the tree\strut
$$\includegraphics[scale=1.25]{tree-w1-w2.pdf}$$

\vskip-.5\myskipamount
*}

definition uniteTrees :: "'a tree \<Rightarrow> 'a tree \<Rightarrow> 'a tree" where
"uniteTrees t\<^isub>1 t\<^isub>2 \<equiv> InnerNode (cachedWeight t\<^isub>1 + cachedWeight t\<^isub>2) t\<^isub>1 t\<^isub>2"

text {*
The alphabet, consistency, and symbol frequencies of a united tree are easy to
connect to the homologous properties of the subtrees.
*}

lemma alphabet_uniteTrees [simp]:
"alphabet (uniteTrees t\<^isub>1 t\<^isub>2) = alphabet t\<^isub>1 \<union> alphabet t\<^isub>2"
by (simp add: uniteTrees_def)

lemma consistent_uniteTrees [simp]:
"\<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {}\<rbrakk> \<Longrightarrow>
 consistent (uniteTrees t\<^isub>1 t\<^isub>2)"
by (simp add: uniteTrees_def)

lemma freq_uniteTrees [simp]:
"freq (uniteTrees t\<^isub>1 t\<^isub>2) = (\<lambda>a. freq t\<^isub>1 a + freq t\<^isub>2 a)"
by (simp add: uniteTrees_def)

subsection {* Ordered Tree Insertion *}

text {*
The auxiliary function @{text insortTree} inserts a tree into a forest sorted
by cached weight, preserving the sort order.
*}

primrec insortTree :: "'a tree \<Rightarrow> 'a forest \<Rightarrow> 'a forest" where
"insortTree u [] = [u]" |
"insortTree u (t # ts) =
     (if cachedWeight u \<le> cachedWeight t then u # t # ts
                                         else t # insortTree u ts)"

text {*
The resulting forest contains one more tree than the original forest. Clearly,
it cannot be empty.
*}

lemma length_insortTree [simp]:
"length (insortTree t ts) = length ts + 1"
by (induct ts) simp+

lemma insortTree_ne_Nil [simp]:
"insortTree t ts \<noteq> []"
by (case_tac ts) simp+

text {*
The alphabet, consistency, symbol frequencies, and height of a forest after
insertion are easy to relate to the homologous properties of the original
forest and the inserted tree.
*}

lemma alphabet\<^isub>F_insortTree [simp]:
"alphabet\<^isub>F (insortTree t ts) = alphabet t \<union> alphabet\<^isub>F ts"
by (induct ts) auto

lemma consistent\<^isub>F_insortTree [simp]:
"consistent\<^isub>F (insortTree t ts) = consistent\<^isub>F (t # ts)"
by (induct ts) auto

lemma freq\<^isub>F_insortTree [simp]:
"freq\<^isub>F (insortTree t ts) = (\<lambda>a. freq t a + freq\<^isub>F ts a)"
by (induct ts) (simp add: ext)+

lemma height\<^isub>F_insortTree [simp]:
"height\<^isub>F (insortTree t ts) = max (height t) (height\<^isub>F ts)"
by (induct ts) auto

subsection {* The Main Algorithm *}

text {*
Huffman's algorithm repeatedly unites the first two trees of the forest it
receives as argument until a single tree is left. It should initially be
invoked with a list of leaf nodes sorted by weight. Note that it is not defined
for the empty list.
*}

fun huffman :: "'a forest \<Rightarrow> 'a tree" where
"huffman [t] = t" |
"huffman (t\<^isub>1 # t\<^isub>2 # ts) = huffman (insortTree (uniteTrees t\<^isub>1 t\<^isub>2) ts)"

text {*
The time complexity of the algorithm is quadratic in the size of the forest.
If we eliminated the inner node's cached weight component, and instead
recomputed the weight each time it is needed, the complexity would remain
quadratic, but with a larger constant. Using a binary search in @{const
insortTree}, the corresponding imperative algorithm is $O(n \log n)$ if we keep
the weight cache and $O(n^2)$ if we drop it. An $O(n)$ imperative implementation
is possible by maintaining two queues, one containing the unprocessed leaf nodes
and the other containing the combined trees \cite[p.~404]{knuth-1997}.

The tree returned by the algorithm preserves the alphabet, consistency, and
symbol frequencies of the original forest.
*}

theorem alphabet_huffman [simp]:
"ts \<noteq> [] \<Longrightarrow> alphabet (huffman ts) = alphabet\<^isub>F ts"
by (induct ts rule: huffman.induct) auto

theorem consistent_huffman [simp]:
"\<lbrakk>consistent\<^isub>F ts; ts \<noteq> []\<rbrakk> \<Longrightarrow> consistent (huffman ts)"
by (induct ts rule: huffman.induct) simp+

theorem freq_huffman [simp]:
"ts \<noteq> [] \<Longrightarrow> freq (huffman ts) = freq\<^isub>F ts"
by (induct ts rule: huffman.induct) (auto simp: ext)

section {* Definition of Auxiliary Functions Used in the Proof
           \label{auxiliary} *}

subsection {* Sibling of a Symbol *}

text {*
The {\sl sibling\/} of a symbol $a$ in a tree $t$ is the label of the node that
is the (left or right) sibling of the node labeled with $a$ in $t$. If the
symbol $a$ is not in $t$'s alphabet or it occurs in a node with no sibling
leaf, we define the sibling as being $a$ itself; this gives us the nice property
that if $t$ is consistent, then $@{term "sibling t a"} \not= a$ if and only if
$a$ has a sibling. As an illustration, we have
$@{term "sibling t a"} = b$,\vthinspace{} $@{term "sibling t b"} = a$,
and $@{term "sibling t c"} = c$ for the tree\strut
$$t \,= \vcenter{\hbox{\includegraphics[scale=1.25]{tree-sibling.pdf}}}$$
*}

fun sibling :: "'a tree \<Rightarrow> 'a \<Rightarrow> 'a" where
"sibling (Leaf w\<^isub>b b) a = a" |
"sibling (InnerNode w (Leaf w\<^isub>b b) (Leaf w\<^isub>c c)) a =
     (if a = b then c else if a = c then b else a)" |
"sibling (InnerNode w t\<^isub>1 t\<^isub>2) a =
     (if a \<in> alphabet t\<^isub>1 then sibling t\<^isub>1 a
      else if a \<in> alphabet t\<^isub>2 then sibling t\<^isub>2 a
      else a)"

text {*
Because @{const sibling} is defined using sequential pattern matching
\cite{krauss-2007,krauss-2009}, reasoning about it can become tedious.
Simplification rules therefore play an important role.
*}

lemma notin_alphabet_imp_sibling_id [simp]:
"a \<notin> alphabet t \<Longrightarrow> sibling t a = a"
by (cases rule: sibling.cases [where x = "(t, a)"]) simp+

lemma height_0_imp_sibling_id [simp]:
"height t = 0 \<Longrightarrow> sibling t a = a"
by (case_tac t) simp+

lemma height_gt_0_in_alphabet_imp_sibling_left [simp]:
"\<lbrakk>height t\<^isub>1 > 0; a \<in> alphabet t\<^isub>1\<rbrakk> \<Longrightarrow>
 sibling (InnerNode w t\<^isub>1 t\<^isub>2) a = sibling t\<^isub>1 a"
by (case_tac t\<^isub>1) simp+

lemma height_gt_0_in_alphabet_imp_sibling_right [simp]:
"\<lbrakk>height t\<^isub>2 > 0; a \<in> alphabet t\<^isub>1\<rbrakk> \<Longrightarrow>
 sibling (InnerNode w t\<^isub>1 t\<^isub>2) a = sibling t\<^isub>1 a"
by (case_tac t\<^isub>2) simp+

lemma height_gt_0_notin_alphabet_imp_sibling_left [simp]:
"\<lbrakk>height t\<^isub>1 > 0; a \<notin> alphabet t\<^isub>1\<rbrakk> \<Longrightarrow>
 sibling (InnerNode w t\<^isub>1 t\<^isub>2) a = sibling t\<^isub>2 a"
by (case_tac t\<^isub>1) simp+

lemma height_gt_0_notin_alphabet_imp_sibling_right [simp]:
"\<lbrakk>height t\<^isub>2 > 0; a \<notin> alphabet t\<^isub>1\<rbrakk> \<Longrightarrow>
 sibling (InnerNode w t\<^isub>1 t\<^isub>2) a = sibling t\<^isub>2 a"
by (case_tac t\<^isub>2) simp+

lemma either_height_gt_0_imp_sibling [simp]:
"height t\<^isub>1 > 0 \<or> height t\<^isub>2 > 0 \<Longrightarrow>
 sibling (InnerNode w t\<^isub>1 t\<^isub>2) a =
     (if a \<in> alphabet t\<^isub>1 then sibling t\<^isub>1 a else sibling t\<^isub>2 a)"
by auto

text {*
The following rules are also useful for reasoning about siblings and alphabets.
*}

lemma in_alphabet_imp_sibling_in_alphabet:
"a \<in> alphabet t \<Longrightarrow> sibling t a \<in> alphabet t"
by (induct t a rule: sibling.induct) auto

lemma sibling_ne_imp_sibling_in_alphabet:
"sibling t a \<noteq> a \<Longrightarrow> sibling t a \<in> alphabet t"
by (metis notin_alphabet_imp_sibling_id in_alphabet_imp_sibling_in_alphabet)

text {*
The default induction rule for @{const sibling} distinguishes four cases.

\begin{myitemize}
\item[] {\sc Base case:}\enskip $t = @{term "Leaf w b"}$.
\item[] {\sc Induction step 1:}\enskip
        $t = @{term "InnerNode w (Leaf w\<^isub>b b) (Leaf w\<^isub>c c)"}$.
\item[] {\sc Induction step 2:}\enskip
        $t = @{term "InnerNode w (InnerNode w\<^isub>1 t\<^isub>1\<^isub>1 t\<^isub>1\<^isub>2) t\<^isub>2"}$.
\item[] {\sc Induction step 3:}\enskip
        $t = @{term "InnerNode w t\<^isub>1 (InnerNode w\<^isub>2 t\<^isub>2\<^isub>1 t\<^isub>2\<^isub>2)"}$.
\end{myitemize}

\noindent
This rule leaves much to be desired. First, the last two cases overlap and
can normally be handled the same way, so they should be combined. Second, the
nested @{text InnerNode} constructors in the last two cases reduce readability.
Third, under the assumption that $t$ is consistent, we would like to perform
the same case distinction on $a$ as we did for
@{thm [source] tree_induct_consistent}, with the same benefits for automation.
These observations lead us to develop a custom induction rule that
distinguishes the following cases.

\begin{myitemize}
\item[] {\sc Base case:}\enskip $t = @{term "Leaf w b"}$.
\item[] {\sc Induction step 1:}\enskip
        $t = @{term "InnerNode w (Leaf w\<^isub>b b) (Leaf w\<^isub>c c)"}$ with
        @{prop "b \<noteq> c"}.
\item[] \begin{flushleft}
        {\sc Induction step 2:}\enskip
        $t = @{term "InnerNode w t\<^isub>1 t\<^isub>2"}$ and either @{term t\<^isub>1} or @{term t\<^isub>2}
        has nonzero height.
        \end{flushleft}
\item[] \noindent\kern\leftmargin {\sc Subcase 1:}\enspace $a$ belongs to
        @{term t\<^isub>1} but not to @{term t\<^isub>2}.
\item[] \noindent\kern\leftmargin {\sc Subcase 2:}\enspace $a$ belongs to
        @{term t\<^isub>2} but not to @{term t\<^isub>1}.
\item[] \noindent\kern\leftmargin {\sc Subcase 3:}\enspace $a$ belongs to
        neither @{term t\<^isub>1} nor @{term t\<^isub>2}.
\end{myitemize}

The statement of the rule and its proof are similar to what we did for
consistent trees, the main difference being that we now have two induction
steps instead of one.
*}

lemma sibling_induct_consistent
          [consumes 1, case_names base step\<^isub>1 step\<^isub>2\<^isub>1 step\<^isub>2\<^isub>2 step\<^isub>2\<^isub>3]:
"\<lbrakk>consistent t;
  \<And>w b a. P (Leaf w b) a;
  \<And>w w\<^isub>b b w\<^isub>c c a. b \<noteq> c \<Longrightarrow> P (InnerNode w (Leaf w\<^isub>b b) (Leaf w\<^isub>c c)) a;
  \<And>w t\<^isub>1 t\<^isub>2 a.
     \<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {};
      height t\<^isub>1 > 0 \<or> height t\<^isub>2 > 0; a \<in> alphabet t\<^isub>1;
      sibling t\<^isub>1 a \<in> alphabet t\<^isub>1; a \<notin> alphabet t\<^isub>2;
      sibling t\<^isub>1 a \<notin> alphabet t\<^isub>2; P t\<^isub>1 a\<rbrakk> \<Longrightarrow>
     P (InnerNode w t\<^isub>1 t\<^isub>2) a;
  \<And>w t\<^isub>1 t\<^isub>2 a.
     \<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {};
      height t\<^isub>1 > 0 \<or> height t\<^isub>2 > 0; a \<notin> alphabet t\<^isub>1;
      sibling t\<^isub>2 a \<notin> alphabet t\<^isub>1; a \<in> alphabet t\<^isub>2;
      sibling t\<^isub>2 a \<in> alphabet t\<^isub>2; P t\<^isub>2 a\<rbrakk> \<Longrightarrow>
     P (InnerNode w t\<^isub>1 t\<^isub>2) a;
  \<And>w t\<^isub>1 t\<^isub>2 a.
     \<lbrakk>consistent t\<^isub>1; consistent t\<^isub>2; alphabet t\<^isub>1 \<inter> alphabet t\<^isub>2 = {};
      height t\<^isub>1 > 0 \<or> height t\<^isub>2 > 0; a \<notin> alphabet t\<^isub>1; a \<notin> alphabet t\<^isub>2\<rbrakk> \<Longrightarrow>
     P (InnerNode w t\<^isub>1 t\<^isub>2) a\<rbrakk> \<Longrightarrow>
 P t a"
apply rotate_tac
apply induction_schema
   apply atomize_elim
   apply (case_tac t, simp)
   apply clarsimp
   apply (rename_tac a t\<^isub>1 t\<^isub>2)
   apply (case_tac "height t\<^isub>1 = 0 \<and> height t\<^isub>2 = 0")
    apply simp
    apply (case_tac t\<^isub>1)
     apply (case_tac t\<^isub>2)
      apply fastforce
     apply simp+
   apply (auto intro: in_alphabet_imp_sibling_in_alphabet)[1]
by lexicographic_order

text {*
The custom induction rule allows us to prove new properties of @{const sibling}
with little effort.
*}

lemma sibling_sibling_id [simp]:
"consistent t \<Longrightarrow> sibling t (sibling t a) = a"
by (induct t a rule: sibling_induct_consistent) simp+

lemma sibling_reciprocal:
"\<lbrakk>consistent t; sibling t a = b\<rbrakk> \<Longrightarrow> sibling t b = a"
by auto

lemma depth_height_imp_sibling_ne:
"\<lbrakk>consistent t; depth t a = height t; height t > 0; a \<in> alphabet t\<rbrakk> \<Longrightarrow>
 sibling t a \<noteq> a"
by (induct t a rule: sibling_induct_consistent) auto

lemma depth_sibling [simp]:
"consistent t \<Longrightarrow> depth t (sibling t a) = depth t a"
by (induct t a rule: sibling_induct_consistent) simp+

subsection {* Leaf Interchange *}

text {*
The @{text swapLeaves} function takes a tree $t$ together with two symbols
$a$, $b$ and their frequencies $@{term w\<^isub>a}$, $@{term w\<^isub>b}$, and returns the tree
$t$ in which the leaf nodes labeled with $a$ and $b$ are exchanged. When
invoking @{text swapLeaves}, we normally pass @{term "freq t a"} and
@{term "freq t b"} for @{term w\<^isub>a} and @{term w\<^isub>b}.

Note that we do not bother updating the cached weight of the ancestor nodes
when performing the interchange. The cached weight is used only in the
implementation of Huffman's algorithm, which doesn't invoke @{text swapLeaves}.
*}

primrec swapLeaves :: "'a tree \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a tree" where
"swapLeaves (Leaf w\<^isub>c c) w\<^isub>a a w\<^isub>b b =
     (if c = a then Leaf w\<^isub>b b else if c = b then Leaf w\<^isub>a a else Leaf w\<^isub>c c)" |
"swapLeaves (InnerNode w t\<^isub>1 t\<^isub>2) w\<^isub>a a w\<^isub>b b =
     InnerNode w (swapLeaves t\<^isub>1 w\<^isub>a a w\<^isub>b b) (swapLeaves t\<^isub>2 w\<^isub>a a w\<^isub>b b)"

text {*
Swapping a symbol~$a$ with itself leaves the tree $t$ unchanged if $a$ does not
belong to it or if the specified frequencies @{term w\<^isub>a} and @{term w\<^isub>b} equal
@{term "freq t a"}.
*}

lemma swapLeaves_id_when_notin_alphabet [simp]:
"a \<notin> alphabet t \<Longrightarrow> swapLeaves t w a w' a = t"
by (induct t) simp+

lemma swapLeaves_id [simp]:
"consistent t \<Longrightarrow> swapLeaves t (freq t a) a (freq t a) a = t"
by (induct t a rule: tree_induct_consistent) simp+

text {*
The alphabet, consistency, symbol depths, height, and symbol frequencies of the
tree @{term "swapLeaves t w\<^isub>a a w\<^isub>b b"} can be related to the homologous
properties of $t$.
*}

lemma alphabet_swapLeaves:
"alphabet (swapLeaves t w\<^isub>a a w\<^isub>b b) =
     (if a \<in> alphabet t then
        if b \<in> alphabet t then alphabet t else (alphabet t - {a}) \<union> {b}
      else
        if b \<in> alphabet t then (alphabet t - {b}) \<union> {a} else alphabet t)"
by (induct t) auto

lemma consistent_swapLeaves [simp]:
"consistent t \<Longrightarrow> consistent (swapLeaves t w\<^isub>a a w\<^isub>b b)"
by (induct t) (auto simp: alphabet_swapLeaves)

lemma depth_swapLeaves_neither [simp]:
"\<lbrakk>consistent t; c \<noteq> a; c \<noteq> b\<rbrakk> \<Longrightarrow> depth (swapLeaves t w\<^isub>a a w\<^isub>b b) c = depth t c"
by (induct t a rule: tree_induct_consistent) (auto simp: alphabet_swapLeaves)

lemma height_swapLeaves [simp]:
"height (swapLeaves t w\<^isub>a a w\<^isub>b b) = height t"
by (induct t) simp+

lemma freq_swapLeaves [simp]:
"\<lbrakk>consistent t; a \<noteq> b\<rbrakk> \<Longrightarrow>
 freq (swapLeaves t w\<^isub>a a w\<^isub>b b) =
     (\<lambda>c. if c = a then if b \<in> alphabet t then w\<^isub>a else 0
          else if c = b then if a \<in> alphabet t then w\<^isub>b else 0
          else freq t c)"
apply (rule ext)
apply (induct t)
by auto

text {*
For the lemmas concerned with the resulting tree's weight and cost, we avoid
subtraction on natural numbers by rearranging terms. For example, we write
$$@{prop "weight (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t a = weight t + w\<^isub>b"}$$
\noindent
rather than the more conventional
$$@{prop "weight (swapLeaves t w\<^isub>a a w\<^isub>b b) = weight t + w\<^isub>b - freq t a"}.$$
In Isabelle/HOL, these two equations are not equivalent, because by definition
$m - n = 0$ if $n > m$. We could use the second equation and additionally
assert that @{prop "weight t \<ge> freq t a"} (an easy consequence of
@{thm [source] weight_eq_Sum_freq}), and then apply the \textit{arith}
tactic, but it is much simpler to use the first equation and stay with
\textit{simp} and \textit{auto}. Another option would be to use
integers instead of natural numbers.
*}

lemma weight_swapLeaves:
"\<lbrakk>consistent t; a \<noteq> b\<rbrakk> \<Longrightarrow>
 if a \<in> alphabet t then
   if b \<in> alphabet t then
     weight (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t a + freq t b =
         weight t + w\<^isub>a + w\<^isub>b
   else
     weight (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t a = weight t + w\<^isub>b
 else
   if b \<in> alphabet t then
     weight (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t b = weight t + w\<^isub>a
   else
     weight (swapLeaves t w\<^isub>a a w\<^isub>b b) = weight t"
proof (induct t a rule: tree_induct_consistent)
  -- {* {\sc Base case:}\enspace $t = @{term "Leaf w b"}$ *}
  case base thus ?case by clarsimp
next
  -- {* {\sc Induction step:}\enspace $t = @{term "InnerNode w t\<^isub>1 t\<^isub>2"}$ *}
  -- {* {\sc Subcase 1:}\enspace $a$ belongs to @{term t\<^isub>1} but not to
        @{term t\<^isub>2} *}
  case (step\<^isub>1 w t\<^isub>1 t\<^isub>2 a) show ?case
  proof cases
    assume "b \<in> alphabet t\<^isub>1"
    moreover hence "b \<notin> alphabet t\<^isub>2" using step\<^isub>1 by auto
    ultimately show ?case using step\<^isub>1 by simp
  next
    assume "b \<notin> alphabet t\<^isub>1" thus ?case using step\<^isub>1 by auto
  qed
next
  -- {* {\sc Subcase 2:}\enspace $a$ belongs to @{term t\<^isub>2} but not to
        @{term t\<^isub>1} *}
  case (step\<^isub>2 w t\<^isub>1 t\<^isub>2 a) show ?case
  proof cases
    assume "b \<in> alphabet t\<^isub>1"
    moreover hence "b \<notin> alphabet t\<^isub>2" using step\<^isub>2 by auto
    ultimately show ?case using step\<^isub>2 by simp
  next
    assume "b \<notin> alphabet t\<^isub>1" thus ?case using step\<^isub>2 by auto
  qed
next
  -- {* {\sc Subcase 3:}\enspace $a$ belongs to neither @{term t\<^isub>1} nor
        @{term t\<^isub>2} *}
  case (step\<^isub>3 w t\<^isub>1 t\<^isub>2 a) show ?case
  proof cases
    assume "b \<in> alphabet t\<^isub>1"
    moreover hence "b \<notin> alphabet t\<^isub>2" using step\<^isub>3 by auto
    ultimately show ?case using step\<^isub>3 by simp
  next
    assume "b \<notin> alphabet t\<^isub>1" thus ?case using step\<^isub>3 by auto
  qed
qed

lemma cost_swapLeaves:
"\<lbrakk>consistent t; a \<noteq> b\<rbrakk> \<Longrightarrow>
 if a \<in> alphabet t then
   if b \<in> alphabet t then
     cost (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t a * depth t a
     + freq t b * depth t b =
         cost t + w\<^isub>a * depth t b + w\<^isub>b * depth t a
   else
     cost (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t a * depth t a =
         cost t + w\<^isub>b * depth t a
 else
   if b \<in> alphabet t then
     cost (swapLeaves t w\<^isub>a a w\<^isub>b b) + freq t b * depth t b =
         cost t + w\<^isub>a * depth t b
   else
     cost (swapLeaves t w\<^isub>a a w\<^isub>b b) = cost t"
proof (induct t)
  case Leaf show ?case by simp
next
  case (InnerNode w t\<^isub>1 t\<^isub>2)
  note c = `consistent (InnerNode w t\<^isub>1 t\<^isub>2)`
  note hyps = InnerNode
  have w\<^isub>1: "if a \<in> alphabet t\<^isub>1 then
              if b \<in> alphabet t\<^isub>1 then
                weight (swapLeaves t\<^isub>1 w\<^isub>a a w\<^isub>b b) + freq t\<^isub>1 a + freq t\<^isub>1 b =
                    weight t\<^isub>1 + w\<^isub>a + w\<^isub>b
                  else
                weight (swapLeaves t\<^isub>1 w\<^isub>a a w\<^isub>b b) + freq t\<^isub>1 a = weight t\<^isub>1 + w\<^isub>b
            else
              if b \<in> alphabet t\<^isub>1 then
                weight (swapLeaves t\<^isub>1 w\<^isub>a a w\<^isub>b b) + freq t\<^isub>1 b = weight t\<^isub>1 + w\<^isub>a
              else
                weight (swapLeaves t\<^isub>1 w\<^isub>a a w\<^isub>b b) = weight t\<^isub>1" using hyps
    by (simp add: weight_swapLeaves)
  have w\<^isub>2: "if a \<in> alphabet t\<^isub>2 then
              if b \<in> alphabet t\<^isub>2 then
                weight (swapLeaves t\<^isub>2 w\<^isub>a a w\<^isub>b b) + freq t\<^isub>2 a + freq t\<^isub>2 b =
                    weight t\<^isub>2 + w\<^isub>a + w\<^isub>b
              else
                weight (swapLeaves t\<^isub>2 w\<^isub>a a w\<^isub>b b) + freq t\<^isub>2 a = weight t\<^isub>2 + w\<^isub>b
            else
              if b \<in> alphabet t\<^isub>2 then
                weight (swapLeaves t\<^isub>2 w\<^isub>a a w\<^isub>b b) + freq t\<^isub>2 b = weight t\<^isub>2 + w\<^isub>a
              else
                weight (swapLeaves t\<^isub>2 w\<^isub>a a w\<^isub>b b) = weight t\<^isub>2" using hyps
    by (simp add: weight_swapLeaves)
  show ?case
  proof cases
    assume a\<^isub>1: "a \<in> alphabet t\<^isub>1"
    hence a\<^isub>2: "a \<notin> alphabet t\<^isub>2" using c by auto
    show ?case
    proof cases
      assume b\<^isub>1: "b \<in> alphabet t\<^isub>1"
      hence "b \<notin> alphabet t\<^isub>2" using c by auto
      thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
    next
      assume b\<^isub>1: "b \<notin> alphabet t\<^isub>1" show ?case
      proof cases
        assume "b \<in> alphabet t\<^isub>2" thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
      next
        assume "b \<notin> alphabet t\<^isub>2" thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
      qed
    qed
  next
    assume a\<^isub>1: "a \<notin> alphabet t\<^isub>1" show ?case
    proof cases
      assume a\<^isub>2: "a \<in> alphabet t\<^isub>2" show ?case
      proof cases
        assume b\<^isub>1: "b \<in> alphabet t\<^isub>1"
        hence "b \<notin> alphabet t\<^isub>2" using c by auto
        thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
      next
        assume b\<^isub>1: "b \<notin> alphabet t\<^isub>1" show ?case
        proof cases
          assume "b \<in> alphabet t\<^isub>2" thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
        next
          assume "b \<notin> alphabet t\<^isub>2" thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
        qed
      qed
    next
      assume a\<^isub>2: "a \<notin> alphabet t\<^isub>2" show ?case
      proof cases
        assume b\<^isub>1: "b \<in> alphabet t\<^isub>1"
        hence "b \<notin> alphabet t\<^isub>2" using c by auto
        thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
      next
        assume b\<^isub>1: "b \<notin> alphabet t\<^isub>1" show ?case
        proof cases
          assume "b \<in> alphabet t\<^isub>2" thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
        next
          assume "b \<notin> alphabet t\<^isub>2" thus ?case using a\<^isub>1 a\<^isub>2 b\<^isub>1 w\<^isub>1 w\<^isub>2 hyps by simp
        qed
      qed
    qed
  qed
qed

text {*
Common sense tells us that the following statement is valid: ``If Astrid
exchanges her house with Bernard's neighbor, Bernard becomes Astrid's new
neighbor.'' A similar property holds for binary trees.
*}

lemma sibling_swapLeaves_sibling [simp]:
"\<lbrakk>consistent t; sibling t b \<noteq> b; a \<noteq> b\<rbrakk> \<Longrightarrow>
 sibling (swapLeaves t w\<^isub>a a w\<^isub>s (sibling t b)) a = b"
proof (induct t)
  case Leaf thus ?case by simp
next
  case (InnerNode w t\<^isub>1 t\<^isub>2)
  note hyps = InnerNode
  show ?case
  proof (cases "height t\<^isub>1 = 0")
    case True
    note h\<^isub>1 = True
    show ?thesis
    proof (cases t\<^isub>1)
      case (Leaf w\<^isub>c c)
      note l\<^isub>1 = Leaf
      show ?thesis
      proof (cases "height t\<^isub>2 = 0")
        case True
        note h\<^isub>2 = True
        show ?thesis
        proof (cases t\<^isub>2)
          case Leaf thus ?thesis using l\<^isub>1 hyps by auto metis+
        next
          case InnerNode thus ?thesis using h\<^isub>2 by simp
        qed
      next
        case False
        note h\<^isub>2 = False
        show ?thesis
        proof cases
          assume "c = b" thus ?thesis using l\<^isub>1 h\<^isub>2 hyps by simp
        next
          assume "c \<noteq> b"
          have "sibling t\<^isub>2 b \<in> alphabet t\<^isub>2" using `c \<noteq> b` l\<^isub>1 h\<^isub>2 hyps
            by (simp add: sibling_ne_imp_sibling_in_alphabet)
          thus ?thesis using `c \<noteq> b` l\<^isub>1 h\<^isub>2 hyps by auto
        qed
      qed
    next
      case InnerNode thus ?thesis using h\<^isub>1 by simp
    qed
  next
    case False
    note h\<^isub>1 = False
    show ?thesis
    proof (cases "height t\<^isub>2 = 0")
      case True
      note h\<^isub>2 = True
      show ?thesis
      proof (cases t\<^isub>2)
        case (Leaf w\<^isub>d d)
        note l\<^isub>2 = Leaf
        show ?thesis
        proof cases
          assume "d = b" thus ?thesis using h\<^isub>1 l\<^isub>2 hyps by simp
        next
          assume "d \<noteq> b" show ?thesis
          proof (cases "b \<in> alphabet t\<^isub>1")
            case True
            hence "sibling t\<^isub>1 b \<in> alphabet t\<^isub>1" using `d \<noteq> b` h\<^isub>1 l\<^isub>2 hyps
              by (simp add: sibling_ne_imp_sibling_in_alphabet)
            thus ?thesis using True `d \<noteq> b` h\<^isub>1 l\<^isub>2 hyps
              by (simp add: alphabet_swapLeaves)
          next
            case False thus ?thesis using `d \<noteq> b` l\<^isub>2 hyps by simp
          qed
        qed
      next
        case InnerNode thus ?thesis using h\<^isub>2 by simp
      qed
    next
      case False
      note h\<^isub>2 = False
      show ?thesis
      proof (cases "b \<in> alphabet t\<^isub>1")
        case True thus ?thesis using h\<^isub>1 h\<^isub>2 hyps by auto
      next
        case False
        note b\<^isub>1 = False
        show ?thesis
        proof (cases "b \<in> alphabet t\<^isub>2")
          case True thus ?thesis using b\<^isub>1 h\<^isub>1 h\<^isub>2 hyps
            by (auto simp: in_alphabet_imp_sibling_in_alphabet
                           alphabet_swapLeaves)
        next
          case False thus ?thesis using b\<^isub>1 h\<^isub>1 h\<^isub>2 hyps by simp
        qed
      qed
    qed
  qed
qed

subsection {* Symbol Interchange *}

text {*
The @{text swapSyms} function provides a simpler interface to
@{const swapLeaves}, with @{term "freq t a"} and @{term "freq t b"} in place of
@{term "w\<^isub>a"} and @{term "w\<^isub>b"}. Most lemmas about @{text swapSyms} are directly
adapted from the homologous results about @{const swapLeaves}.
*}

definition swapSyms :: "'a tree \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a tree" where
"swapSyms t a b \<equiv> swapLeaves t (freq t a) a (freq t b) b"

lemma swapSyms_id [simp]:
"consistent t \<Longrightarrow> swapSyms t a a = t"
by (simp add: swapSyms_def)

lemma alphabet_swapSyms [simp]:
"\<lbrakk>a \<in> alphabet t; b \<in> alphabet t\<rbrakk> \<Longrightarrow> alphabet (swapSyms t a b) = alphabet t"
by (simp add: swapSyms_def alphabet_swapLeaves)

lemma consistent_swapSyms [simp]:
"consistent t \<Longrightarrow> consistent (swapSyms t a b)"
by (simp add: swapSyms_def)

lemma depth_swapSyms_neither [simp]:
"\<lbrakk>consistent t; c \<noteq> a; c \<noteq> b\<rbrakk> \<Longrightarrow>
 depth (swapSyms t a b) c = depth t c"
by (simp add: swapSyms_def)

lemma freq_swapSyms [simp]:
"\<lbrakk>consistent t; a \<in> alphabet t; b \<in> alphabet t\<rbrakk> \<Longrightarrow>
 freq (swapSyms t a b) = freq t"
by (case_tac "a = b") (simp add: swapSyms_def ext)+

lemma cost_swapSyms:
assumes "consistent t" "a \<in> alphabet t" "b \<in> alphabet t"
shows "cost (swapSyms t a b) + freq t a * depth t a + freq t b * depth t b =
           cost t + freq t a * depth t b + freq t b * depth t a"
proof cases
  assume "a = b" thus ?thesis using assms by simp
next
  assume "a \<noteq> b"
  moreover hence "cost (swapLeaves t (freq t a) a (freq t b) b)
                      + freq t a * depth t a + freq t b * depth t b =
                  cost t + freq t a * depth t b + freq t b * depth t a"
    using assms by (simp add: cost_swapLeaves)
  ultimately show ?thesis using assms by (simp add: swapSyms_def)
qed

text {*
If $a$'s frequency is lower than or equal to $b$'s, and $a$ is higher up in the
tree than $b$ or at the same level, then interchanging $a$ and $b$ does not
increase the tree's cost.
*}

lemma le_le_imp_sum_mult_le_sum_mult:
"\<lbrakk>i \<le> j; m \<le> (n::nat)\<rbrakk> \<Longrightarrow> i * n + j * m \<le> i * m + j * n"
apply (subgoal_tac "i * m + i * (n - m) + j * m \<le> i * m + j * m + j * (n - m)")
 apply (simp add: diff_mult_distrib2)
by simp

lemma cost_swapSyms_le:
assumes "consistent t" "a \<in> alphabet t" "b \<in> alphabet t" "freq t a \<le> freq t b"
        "depth t a \<le> depth t b"
shows "cost (swapSyms t a b) \<le> cost t"
proof -
  let ?aabb = "freq t a * depth t a + freq t b * depth t b"
  let ?abba = "freq t a * depth t b + freq t b * depth t a"
  have "?abba \<le> ?aabb" using assms(4-5)
    by (rule le_le_imp_sum_mult_le_sum_mult)
  have "cost (swapSyms t a b) + ?aabb = cost t + ?abba" using assms(1-3)
    by (simp add: cost_swapSyms nat_add_assoc [THEN sym])
  also have "\<dots> \<le> cost t + ?aabb" using `?abba \<le> ?aabb` by simp
  finally show ?thesis using assms(4-5) by simp
qed

text {*
As stated earlier, ``If Astrid exchanges her house with Bernard's neighbor,
Bernard becomes Astrid's new neighbor.''
*}

lemma sibling_swapSyms_sibling [simp]:
"\<lbrakk>consistent t; sibling t b \<noteq> b; a \<noteq> b\<rbrakk> \<Longrightarrow>
 sibling (swapSyms t a (sibling t b)) a = b"
by (simp add: swapSyms_def)

text {*
``If Astrid exchanges her house with Bernard, Astrid becomes Bernard's old
neighbor's new neighbor.''
*}

lemma sibling_swapSyms_other_sibling [simp]:
"\<lbrakk>consistent t; sibling t b \<noteq> a; sibling t b \<noteq> b; a \<noteq> b\<rbrakk> \<Longrightarrow>
 sibling (swapSyms t a b) (sibling t b) = a"
by (metis consistent_swapSyms sibling_swapSyms_sibling sibling_reciprocal)

subsection {* Four-Way Symbol Interchange
              \label{four-way-symbol-interchange} *}

text {*
The @{const swapSyms} function exchanges two symbols $a$ and $b$. We use it
to define the four-way symbol interchange function @{text swapFourSyms}, which
takes four symbols $a$, $b$, $c$, $d$ with $a \ne b$ and $c \ne d$, and
exchanges them so that $a$ and $b$ occupy $c$~and~$d$'s positions.

A naive definition of this function would be
$$@{prop "swapFourSyms t a b c d \<equiv> swapSyms (swapSyms t a c) b d"}.$$
This definition fails in the face of aliasing: If $a = d$, but
$b \ne c$, then @{text "swapFourSyms a b c d"} would leave $a$ in $b$'s
position.%
\footnote{Cormen et al.\ \cite[p.~390]{cormen-et-al-2001} forgot to consider
this case in their proof. Thomas Cormen indicated in a personal communication
that this will be corrected in the next edition of the book.}
*}

definition swapFourSyms :: "'a tree \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a tree" where
"swapFourSyms t a b c d \<equiv>
     if a = d then swapSyms t b c
     else if b = c then swapSyms t a d
     else swapSyms (swapSyms t a c) b d"

text {*
Lemmas about @{const swapFourSyms} are easy to prove by expanding its
definition.
*}

lemma alphabet_swapFourSyms [simp]:
"\<lbrakk>a \<in> alphabet t; b \<in> alphabet t; c \<in> alphabet t; d \<in> alphabet t\<rbrakk> \<Longrightarrow>
 alphabet (swapFourSyms t a b c d) = alphabet t"
by (simp add: swapFourSyms_def)

lemma consistent_swapFourSyms [simp]:
"consistent t \<Longrightarrow> consistent (swapFourSyms t a b c d)"
by (simp add: swapFourSyms_def)

lemma freq_swapFourSyms [simp]:
"\<lbrakk>consistent t; a \<in> alphabet t; b \<in> alphabet t; c \<in> alphabet t;
  d \<in> alphabet t\<rbrakk> \<Longrightarrow>
 freq (swapFourSyms t a b c d) = freq t"
by (auto simp: swapFourSyms_def)

text {*
More Astrid and Bernard insanity: ``If Astrid and Bernard exchange their houses
with Carmen and her neighbor, Astrid and Bernard will now be neighbors.''
*}

lemma sibling_swapFourSyms_when_4th_is_sibling:
assumes "consistent t" "a \<in> alphabet t" "b \<in> alphabet t" "c \<in> alphabet t"
        "a \<noteq> b" "sibling t c \<noteq> c"
shows "sibling (swapFourSyms t a b c (sibling t c)) a = b"
proof (cases "a \<noteq> sibling t c \<and> b \<noteq> c")
  case True show ?thesis
  proof -
    let ?d = "sibling t c"
    let ?t\<^isub>s = "swapFourSyms t a b c ?d"
    have abba: "(sibling ?t\<^isub>s a = b) = (sibling ?t\<^isub>s b = a)" using `consistent t`
      by (metis consistent_swapFourSyms sibling_reciprocal)
    have s: "sibling t c = sibling (swapSyms t a c) a" using True assms
      by (metis sibling_reciprocal sibling_swapSyms_sibling)
    have "sibling ?t\<^isub>s b = sibling (swapSyms t a c) ?d" using s True assms
      by (auto simp: swapFourSyms_def)
    also have "\<dots> = a" using True assms
      by (metis sibling_reciprocal sibling_swapSyms_other_sibling
          swapLeaves_id swapSyms_def)
    finally have "sibling ?t\<^isub>s b = a" .
    with abba show ?thesis ..
  qed
next
  case False thus ?thesis using assms
    by (auto intro: sibling_reciprocal simp: swapFourSyms_def)
qed

subsection {* Sibling Merge *}

text {*
Given a symbol $a$, the @{text mergeSibling} function transforms the tree
%
\setbox\myboxi=\hbox{\includegraphics[scale=1.25]{tree-splitLeaf-a.pdf}}%
\setbox\myboxii=\hbox{\includegraphics[scale=1.25]{tree-splitLeaf-ab.pdf}}%
\mydimeni=\ht\myboxii
$$\vcenter{\box\myboxii}
  \qquad \hbox{into} \qquad
  \smash{\lower\ht\myboxi\hbox{\raise.5\mydimeni\box\myboxi}}$$
The frequency of $a$ in the result is the sum of the original frequencies of
$a$ and $b$, so as not to alter the tree's weight.
*}

fun mergeSibling :: "'a tree \<Rightarrow> 'a \<Rightarrow> 'a tree" where
"mergeSibling (Leaf w\<^isub>b b) a = Leaf w\<^isub>b b" |
"mergeSibling (InnerNode w (Leaf w\<^isub>b b) (Leaf w\<^isub>c c)) a =
     (if a = b \<or> a = c then Leaf (w\<^isub>b + w\<^isub>c) a
      else InnerNode w (Leaf w\<^isub>b b) (Leaf w\<^isub>c c))" |
"mergeSibling (InnerNode w t\<^isub>1 t\<^isub>2) a =
     InnerNode w (mergeSibling t\<^isub>1 a) (mergeSibling t\<^isub>2 a)"

text {*
The definition of @{const mergeSibling} has essentially the same structure as
that of @{const sibling}. As a result, the custom induction rule that we
derived for @{const sibling} works equally well for reasoning about
@{const mergeSibling}.
*}

lemmas mergeSibling_induct_consistent = sibling_induct_consistent

text {*
The properties of @{const mergeSibling} echo those of @{const sibling}. Like
with @{const sibling}, simplification rules are crucial.
*}

lemma notin_alphabet_imp_mergeSibling_id [simp]:
"a \<notin> alphabet t \<Longrightarrow> mergeSibling t a = t"
by (induct t a rule: mergeSibling.induct) simp+

lemma height_gt_0_imp_mergeSibling_left [simp]:
"height t\<^isub>1 > 0 \<Longrightarrow>
 mergeSibling (InnerNode w t\<^isub>1 t\<^isub>2) a =
     InnerNode w (mergeSibling t\<^isub>1 a) (mergeSibling t\<^isub>2 a)"
by (case_tac t\<^isub>1) simp+

lemma height_gt_0_imp_mergeSibling_right [simp]:
"height t\<^isub>2 > 0 \<Longrightarrow>
 mergeSibling (InnerNode w t\<^isub>1 t\<^isub>2) a =
     InnerNode w (mergeSibling t\<^isub>1 a) (mergeSibling t\<^isub>2 a)"
by (case_tac t\<^isub>2) simp+

lemma either_height_gt_0_imp_mergeSibling [simp]:
"height t\<^isub>1 > 0 \<or> height t\<^isub>2 > 0 \<Longrightarrow>
 mergeSibling (InnerNode w t\<^isub>1 t\<^isub>2) a =
     InnerNode w (mergeSibling t\<^isub>1 a) (mergeSibling t\<^isub>2 a)"
by auto

lemma alphabet_mergeSibling [simp]:
"\<lbrakk>consistent t; a \<in> alphabet t\<rbrakk> \<Longrightarrow>
 alphabet (mergeSibling t a) = (alphabet t - {sibling t a}) \<union> {a}"
by (induct t a rule: mergeSibling_induct_consistent) auto

lemma consistent_mergeSibling [simp]:
"consistent t \<Longrightarrow> consistent (mergeSibling t a)"
by (induct t a rule: mergeSibling_induct_consistent) auto

lemma freq_mergeSibling:
"\<lbrakk>consistent t; a \<in> alphabet t; sibling t a \<noteq> a\<rbrakk> \<Longrightarrow>
 freq (mergeSibling t a) =
     (\<lambda>c. if c = a then freq t a + freq t (sibling t a)
          else if c = sibling t a then 0
          else freq t c)"
by (induct t a rule: mergeSibling_induct_consistent)
   (auto simp: fun_eq_iff)

lemma weight_mergeSibling [simp]:
"weight (mergeSibling t a) = weight t"
by (induct t a rule: mergeSibling.induct) simp+

text {*
If $a$ has a sibling, merging $a$ and its sibling reduces $t$'s cost by
@{term "freq t a + freq t (sibling t a)"}.
*}

lemma cost_mergeSibling:
"\<lbrakk>consistent t; sibling t a \<noteq> a\<rbrakk> \<Longrightarrow>
 cost (mergeSibling t a) + freq t a + freq t (sibling t a) = cost t"
by (induct t a rule: mergeSibling_induct_consistent) auto

subsection {* Leaf Split *}

text {*
The @{text splitLeaf} function undoes the merging performed by
@{const mergeSibling}: Given two symbols $a$, $b$ and two frequencies
$@{term w\<^isub>a}$, $@{term w\<^isub>b}$, it transforms
\setbox\myboxi=\hbox{\includegraphics[scale=1.25]{tree-splitLeaf-a.pdf}}%
\setbox\myboxii=\hbox{\includegraphics[scale=1.25]{tree-splitLeaf-ab.pdf}}%
$$\smash{\lower\ht\myboxi\hbox{\raise.5\ht\myboxii\box\myboxi}}
  \qquad \hbox{into} \qquad
  \vcenter{\box\myboxii}$$
In the resulting tree, $a$ has frequency @{term w\<^isub>a} and $b$ has frequency
@{term w\<^isub>b}. We normally invoke it with @{term w\<^isub>a}~and @{term w\<^isub>b} such that
@{prop "freq t a = w\<^isub>a + w\<^isub>b"}.
*}

primrec splitLeaf :: "'a tree \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a tree" where
"splitLeaf (Leaf w\<^isub>c c) w\<^isub>a a w\<^isub>b b =
     (if c = a then InnerNode w\<^isub>c (Leaf w\<^isub>a a) (Leaf w\<^isub>b b) else Leaf w\<^isub>c c)" |
"splitLeaf (InnerNode w t\<^isub>1 t\<^isub>2) w\<^isub>a a w\<^isub>b b =
     InnerNode w (splitLeaf t\<^isub>1 w\<^isub>a a w\<^isub>b b) (splitLeaf t\<^isub>2 w\<^isub>a a w\<^isub>b b)"

primrec splitLeaf\<^isub>F :: "'a forest \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a forest" where
"splitLeaf\<^isub>F [] w\<^isub>a a w\<^isub>b b = []" |
"splitLeaf\<^isub>F (t # ts) w\<^isub>a a w\<^isub>b b =
     splitLeaf t w\<^isub>a a w\<^isub>b b # splitLeaf\<^isub>F ts w\<^isub>a a w\<^isub>b b"

text {*
Splitting leaf nodes affects the alphabet, consistency, symbol frequencies,
weight, and cost in unsurprising ways.
*}

lemma notin_alphabet_imp_splitLeaf_id [simp]:
"a \<notin> alphabet t \<Longrightarrow> splitLeaf t w\<^isub>a a w\<^isub>b b = t"
by (induct t) simp+

lemma notin_alphabet\<^isub>F_imp_splitLeaf\<^isub>F_id [simp]:
"a \<notin> alphabet\<^isub>F ts \<Longrightarrow> splitLeaf\<^isub>F ts w\<^isub>a a w\<^isub>b b = ts"
by (induct ts) simp+

lemma alphabet_splitLeaf [simp]:
"alphabet (splitLeaf t w\<^isub>a a w\<^isub>b b) =
     (if a \<in> alphabet t then alphabet t \<union> {b} else alphabet t)"
by (induct t) simp+

lemma consistent_splitLeaf [simp]:
"\<lbrakk>consistent t; b \<notin> alphabet t\<rbrakk> \<Longrightarrow> consistent (splitLeaf t w\<^isub>a a w\<^isub>b b)"
by (induct t) auto

lemma freq_splitLeaf [simp]:
"\<lbrakk>consistent t; b \<notin> alphabet t\<rbrakk> \<Longrightarrow>
 freq (splitLeaf t w\<^isub>a a w\<^isub>b b) =
     (if a \<in> alphabet t then
        (\<lambda>c. if c = a then w\<^isub>a else if c = b then w\<^isub>b else freq t c)
      else
        freq t)"
by (induct t b rule: tree_induct_consistent) (rule ext, auto)+

lemma weight_splitLeaf [simp]:
"\<lbrakk>consistent t; a \<in> alphabet t; freq t a = w\<^isub>a + w\<^isub>b\<rbrakk> \<Longrightarrow>
 weight (splitLeaf t w\<^isub>a a w\<^isub>b b) = weight t"
by (induct t a rule: tree_induct_consistent) simp+

lemma cost_splitLeaf [simp]:
"\<lbrakk>consistent t; a \<in> alphabet t; freq t a = w\<^isub>a + w\<^isub>b\<rbrakk> \<Longrightarrow>
 cost (splitLeaf t w\<^isub>a a w\<^isub>b b) = cost t + w\<^isub>a + w\<^isub>b"
by (induct t a rule: tree_induct_consistent) simp+

subsection {* Weight Sort Order *}

text {*
An invariant of Huffman's algorithm is that the forest is sorted by weight.
This is expressed by the @{text sortedByWeight} function.
*}

fun sortedByWeight :: "'a forest \<Rightarrow> bool" where
"sortedByWeight [] = True" |
"sortedByWeight [t] = True" |
"sortedByWeight (t\<^isub>1 # t\<^isub>2 # ts) =
     (weight t\<^isub>1 \<le> weight t\<^isub>2 \<and> sortedByWeight (t\<^isub>2 # ts))"

text {*
The function obeys the following fairly obvious laws.
*}

lemma sortedByWeight_Cons_imp_sortedByWeight:
"sortedByWeight (t # ts) \<Longrightarrow> sortedByWeight ts"
by (case_tac ts) simp+

lemma sortedByWeight_Cons_imp_forall_weight_ge:
"sortedByWeight (t # ts) \<Longrightarrow> \<forall>u \<in> set ts. weight u \<ge> weight t"
proof (induct ts arbitrary: t)
  case Nil thus ?case by simp
next
  case (Cons u us) thus ?case by simp (metis le_trans)
qed

lemma sortedByWeight_insortTree:
"\<lbrakk>sortedByWeight ts; height t = 0; height\<^isub>F ts = 0\<rbrakk> \<Longrightarrow>
 sortedByWeight (insortTree t ts)"
by (induct ts rule: sortedByWeight.induct) auto

subsection {* Pair of Minimal Symbols *}

text {*
The @{text minima} predicate expresses that two symbols
$a$, $b \in @{term "alphabet t"}$ have the lowest frequencies in the tree $t$
and that @{prop "freq t a \<le> freq t b"}. Minimal symbols need not be uniquely
defined.
*}

definition minima :: "'a tree \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> bool" where
"minima t a b \<equiv>
     a \<in> alphabet t \<and> b \<in> alphabet t \<and> a \<noteq> b \<and> freq t a \<le> freq t b
     \<and> (\<forall>c \<in> alphabet t. c \<noteq> a \<longrightarrow> c \<noteq> b \<longrightarrow>
                         freq t c \<ge> freq t a \<and> freq t c \<ge> freq t b)"

section {* Formalization of the Textbook Proof
           \label{formalization} *}

subsection {* Four-Way Symbol Interchange Cost Lemma *}

text {*
If $a$ and $b$ are minima, and $c$ and $d$ are at the very bottom of the tree,
then exchanging $a$ and $b$ with $c$ and $d$ doesn't increase the cost.
Graphically, we have\strut
%
$${\it cost\/}
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-minima-abcd.pdf}}}
  \,\mathop{\le}\;\;\;
  {\it cost\/}
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-minima.pdf}}}$$

\noindent
This cost property is part of Knuth's proof:

\begin{quote}
Let $V$ be an internal node of maximum distance from the root. If $w_1$ and
$w_2$ are not the weights already attached to the children of $V$, we can
interchange them with the values that are already there; such an interchange
does not increase the weighted path length.
\end{quote}

\noindent
Lemma~16.2 in Cormen et al.~\cite[p.~389]{cormen-et-al-2001} expresses a
similar property, which turns out to be a corollary of our cost property:

\begin{quote}
Let $C$ be an alphabet in which each character $c \in C$ has frequency $f[c]$.
Let $x$ and $y$ be two characters in $C$ having the lowest frequencies. Then
there exists an optimal prefix code for $C$ in which the codewords for $x$ and
$y$ have the same length and differ only in the last bit.
\end{quote}

\vskip-.75\myskipamount
*}

lemma cost_swapFourSyms_le:
assumes "consistent t" "minima t a b" "c \<in> alphabet t" "d \<in> alphabet t"
        "depth t c = height t" "depth t d = height t" "c \<noteq> d"
shows "cost (swapFourSyms t a b c d) \<le> cost t"
proof -
  note lems = swapFourSyms_def minima_def cost_swapSyms_le depth_le_height
  show ?thesis
  proof (cases "a \<noteq> d \<and> b \<noteq> c")
    case True show ?thesis
    proof cases
      assume "a = c" show ?thesis
      proof cases
        assume "b = d" thus ?thesis using `a = c` True assms
          by (simp add: lems)
      next
        assume "b \<noteq> d" thus ?thesis using `a = c` True assms
          by (simp add: lems)
      qed
    next
      assume "a \<noteq> c" show ?thesis
      proof cases
        assume "b = d" thus ?thesis using `a \<noteq> c` True assms
          by (simp add: lems)
      next
        assume "b \<noteq> d"
        have "cost (swapFourSyms t a b c d) \<le> cost (swapSyms t a c)"
          using `b \<noteq> d` `a \<noteq> c` True assms by (clarsimp simp: lems)
        also have "\<dots> \<le> cost t" using `b \<noteq> d` `a \<noteq> c` True assms
          by (clarsimp simp: lems)
        finally show ?thesis .
      qed
    qed
  next
    case False thus ?thesis using assms by (clarsimp simp: lems)
  qed
qed

subsection {* Leaf Split Optimality Lemma
              \label{leaf-split-optimality} *}

text {*
The tree @{term "splitLeaf t w\<^isub>a a w\<^isub>b b"} is optimum if $t$ is optimum, under a
few assumptions, notably that $a$ and $b$ are minima of the new tree and
that @{prop "freq t a = w\<^isub>a + w\<^isub>b"}.
Graphically:\strut
%
\setbox\myboxi=\hbox{\includegraphics[scale=1.2]{tree-splitLeaf-a.pdf}}%
\setbox\myboxii=\hbox{\includegraphics[scale=1.2]{tree-splitLeaf-ab.pdf}}%
$${\it optimum\/} \smash{\lower\ht\myboxi\hbox{\raise.5\ht\myboxii\box\myboxi}}
  \,\mathop{\Longrightarrow}\;\;\;
  {\it optimum\/} \vcenter{\box\myboxii}$$
%
This corresponds to the following fragment of Knuth's proof:

\begin{quote}
Now it is easy to prove that the weighted path length of such a tree is
minimized if and only if the tree with
$$\vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-w2-leaves.pdf}}}
  \qquad \hbox{replaced by} \qquad
  \vcenter{\hbox{\includegraphics[scale=1.25]{tree-w1-plus-w2.pdf}}}$$
has minimum path length for the weights $w_1 + w_2$, $w_3$, $\ldots\,$, $w_m$.
\end{quote}

\noindent
We only need the ``if'' direction of Knuth's equivalence. Lemma~16.3 in
Cormen et al.~\cite[p.~391]{cormen-et-al-2001} expresses essentially the same
property:

\begin{quote}
Let $C$ be a given alphabet with frequency $f[c]$ defined for each character
$c \in C$. Let $x$ and $y$ be two characters in $C$ with minimum frequency. Let
$C'$ be the alphabet $C$ with characters $x$, $y$ removed and (new) character
$z$ added, so that $C' = C - \{x, y\} \cup {\{z\}}$; define $f$ for $C'$ as for
$C$, except that $f[z] = f[x] + f[y]$. Let $T'$ be any tree representing an
optimal prefix code for the alphabet $C'$. Then the tree $T$, obtained from
$T'$ by replacing the leaf node for $z$ with an internal node having $x$ and
$y$ as children, represents an optimal prefix code for the alphabet $C$.
\end{quote}

\noindent
The proof is as follows: We assume that $t$ has a cost less than or equal to
that of any other comparable tree~$v$ and show that
@{term "splitLeaf t w\<^isub>a a w\<^isub>b b"} has a cost less than or equal to that of any
other comparable tree $u$. By @{thm [source] exists_at_height} and
@{thm [source] depth_height_imp_sibling_ne}, we know that some symbols $c$ and
$d$ appear in sibling nodes at the very bottom of~$u$:
$$\includegraphics[scale=1.25]{tree-splitLeaf-cd.pdf}$$
(The question mark is there to remind us that we know nothing specific about
$u$'s structure.) From $u$ we construct a new tree
@{term "swapFourSyms u a b c d"} in which the minima $a$ and $b$ are siblings:
$$\includegraphics[scale=1.25]{tree-splitLeaf-abcd.pdf}$$
Merging $a$ and $b$ gives a tree comparable with $t$, which we can use to
instantiate $v$ in the assumption:
$$\includegraphics[scale=1.25]{tree-splitLeaf-abcd-aba.pdf}$$
With this instantiation, the proof is easy:
$$\begin{tabularx}{\textwidth}{@%
{\hskip\leftmargin}cX@%
{}}
    & @{term "cost (splitLeaf t a w\<^isub>a b w\<^isub>b)"} \\
\eq & \justif{@{thm [source] cost_splitLeaf}} \\
    & @{term "cost t + w\<^isub>a + w\<^isub>b"} \\
\kern-1em$\leq$\kern-1em & \justif{assumption} \\[-2ex]
    & $@{text "cost ("}
       \overbrace{\strut\!@{term "mergeSibling (swapFourSyms u a b c d) a"}\!}
       ^{\smash{\hbox{$v$}}}@{text ") + w\<^isub>a + w\<^isub>b"}$ \\[\extrah]
\eq & \justif{@{thm [source] cost_mergeSibling}} \\
    & @{term "cost (swapFourSyms u a b c d)"} \\
\kern-1em$\leq$\kern-1em & \justif{@{thm [source] cost_swapFourSyms_le}} \\
    & @{term "cost u"}. \\
\end{tabularx}$$

\noindent
In contrast, the proof in Cormen et al.\ is by contradiction: Essentially, they
assume that there exists a tree $u$ with a lower cost than
@{term "splitLeaf t a w\<^isub>a b w\<^isub>b"} and show that there exists a tree~$v$
with a lower cost than~$t$, contradicting the hypothesis that $t$ is optimum. In
place of @{thm [source] cost_swapFourSyms_le}, they invoke their lemma~16.2,
which is questionable since $u$ is not necessarily optimum.%
\footnote{Thomas Cormen commented that this step will be clarified in the
next edition of the book.}

Our proof relies on the following lemma, which asserts that $a$ and $b$ are
minima of $u$.
*}

lemma twice_freq_le_imp_minima:
"\<lbrakk>\<forall>c \<in> alphabet t. w\<^isub>a \<le> freq t c \<and> w\<^isub>b \<le> freq t c;
  alphabet u = alphabet t \<union> {b}; a \<in> alphabet u; a \<noteq> b;
  freq u = (\<lambda>c. if c = a then w\<^isub>a else if c = b then w\<^isub>b else freq t c);
  w\<^isub>a \<le> w\<^isub>b\<rbrakk> \<Longrightarrow>
 minima u a b"
by (simp add: minima_def)

text {*
Now comes the key lemma.
*}

lemma optimum_splitLeaf:
assumes "consistent t" "optimum t" "a \<in> alphabet t" "b \<notin> alphabet t"
        "freq t a = w\<^isub>a + w\<^isub>b" "\<forall>c \<in> alphabet t. freq t c \<ge> w\<^isub>a \<and> freq t c \<ge> w\<^isub>b"
        "w\<^isub>a \<le> w\<^isub>b"
shows "optimum (splitLeaf t w\<^isub>a a w\<^isub>b b)"
proof (unfold optimum_def, clarify)
  fix u
  let ?t' = "splitLeaf t w\<^isub>a a w\<^isub>b b"
  assume c\<^isub>u: "consistent u"
         and a\<^isub>u: "alphabet ?t' = alphabet u"
         and f\<^isub>u: "freq ?t' = freq u"
  show "cost ?t' \<le> cost u"
  proof (cases "height ?t' = 0")
    case True thus ?thesis by simp
  next
    case False
    hence h\<^isub>u: "height u > 0" using a\<^isub>u assms
      by (auto intro: height_gt_0_alphabet_eq_imp_height_gt_0)
    have a\<^isub>a: "a \<in> alphabet u" using a\<^isub>u assms by fastforce
    have a\<^isub>b: "b \<in> alphabet u" using a\<^isub>u assms by fastforce
    have ab: "a \<noteq> b" using assms by blast
    from exists_at_height [OF c\<^isub>u]
    obtain c where a\<^isub>c: "c \<in> alphabet u" and d\<^isub>c: "depth u c = height u" ..
    let ?d = "sibling u c"
    have dc: "?d \<noteq> c" using d\<^isub>c c\<^isub>u h\<^isub>u a\<^isub>c by (metis depth_height_imp_sibling_ne)
    have a\<^isub>d: "?d \<in> alphabet u" using dc
      by (rule sibling_ne_imp_sibling_in_alphabet)
    have d\<^isub>d: "depth u ?d = height u" using d\<^isub>c c\<^isub>u by simp

    let ?u' = "swapFourSyms u a b c ?d"
    have c\<^isub>u\<^isub>': "consistent ?u'" using c\<^isub>u by simp
    have a\<^isub>u\<^isub>': "alphabet ?u' = alphabet u" using a\<^isub>a a\<^isub>b a\<^isub>c a\<^isub>d a\<^isub>u by simp
    have f\<^isub>u\<^isub>': "freq ?u' = freq u" using a\<^isub>a a\<^isub>b a\<^isub>c a\<^isub>d c\<^isub>u f\<^isub>u by simp
    have s\<^isub>a: "sibling ?u' a = b" using c\<^isub>u a\<^isub>a a\<^isub>b a\<^isub>c ab dc
      by (rule sibling_swapFourSyms_when_4th_is_sibling)

    let ?v = "mergeSibling ?u' a"
    have c\<^isub>v: "consistent ?v" using c\<^isub>u\<^isub>' by simp
    have a\<^isub>v: "alphabet ?v = alphabet t" using s\<^isub>a c\<^isub>u\<^isub>' a\<^isub>u\<^isub>' a\<^isub>a a\<^isub>u assms by auto
    have f\<^isub>v: "freq ?v = freq t"
      using s\<^isub>a c\<^isub>u\<^isub>' a\<^isub>u\<^isub>' f\<^isub>u\<^isub>' f\<^isub>u [THEN sym] ab a\<^isub>u [THEN sym] assms
      by (simp add: freq_mergeSibling ext)

    have "cost ?t' = cost t + w\<^isub>a + w\<^isub>b" using assms by simp
    also have "\<dots> \<le> cost ?v + w\<^isub>a + w\<^isub>b" using c\<^isub>v a\<^isub>v f\<^isub>v `optimum t`
      by (simp add: optimum_def)
    also have "\<dots> = cost ?u'"
      proof -
        have "cost ?v + freq ?u' a + freq ?u' (sibling ?u' a) = cost ?u'"
          using c\<^isub>u\<^isub>' s\<^isub>a assms by (subst cost_mergeSibling) auto
        moreover have "w\<^isub>a = freq ?u' a" "w\<^isub>b = freq ?u' b"
          using f\<^isub>u\<^isub>' f\<^isub>u [THEN sym] assms by clarsimp+
        ultimately show ?thesis using s\<^isub>a by simp
      qed
    also have "\<dots> \<le> cost u"
      proof -
        have "minima u a b" using a\<^isub>u f\<^isub>u assms
          by (subst twice_freq_le_imp_minima) auto
        with c\<^isub>u show ?thesis using a\<^isub>c a\<^isub>d d\<^isub>c d\<^isub>d dc [THEN not_sym]
          by (rule cost_swapFourSyms_le)
      qed
    finally show ?thesis .
  qed
qed

subsection {* Leaf Split Commutativity Lemma
              \label{leaf-split-commutativity} *}

text {*
A key property of Huffman's algorithm is that once it has combined two
lowest-weight trees using @{const uniteTrees}, it doesn't visit these trees
ever again. This suggests that splitting a leaf node before applying the
algorithm should give the same result as applying the algorithm first and
splitting the leaf node afterward. The diagram below illustrates the
situation:\strut

\def\myscale{1.05}%
\setbox\myboxi=\hbox{(9)\strut}%
\setbox\myboxii=\hbox{\includegraphics[scale=\myscale]{forest-a.pdf}}%
$$(1)\,\lower\ht\myboxii\hbox{\raise\ht\myboxi\box\myboxii}$$

\smallskip

\setbox\myboxii=\hbox{\includegraphics[scale=\myscale]{tree-splitLeaf-a.pdf}}%
\setbox\myboxiii=\hbox{\includegraphics[scale=\myscale]%
  {forest-splitLeaf-ab.pdf}}%
\mydimeni=\wd\myboxii

\noindent
(2a)\,\lower\ht\myboxii\hbox{\raise\ht\myboxi\box\myboxii}%
  \qquad\qquad\quad
  (2b)\,\lower\ht\myboxiii\hbox{\raise\ht\myboxi\box\myboxiii}\quad{}

\setbox\myboxiii=\hbox{\includegraphics[scale=\myscale]%
  {tree-splitLeaf-ab.pdf}}%
\setbox\myboxiv=\hbox{\includegraphics[scale=\myscale]%
  {tree-huffman-splitLeaf-ab.pdf}}%
\mydimenii=\wd\myboxiii
\vskip1.5\smallskipamount
\noindent
(3a)\,\lower\ht\myboxiii\hbox{\raise\ht\myboxi\box\myboxiii}%
  \qquad\qquad\quad
  (3b)\,\hfill\lower\ht\myboxiv\hbox{\raise\ht\myboxi\box\myboxiv}%
  \quad\hfill{}

\noindent
From the original forest (1), we can either run the algorithm (2a) and then
split $a$ (3a) or split $a$ (2b) and then run the algorithm (3b). Our goal is
to show that trees (3a) and (3b) are identical. Formally, we prove that
$$@{term "splitLeaf (huffman ts) w\<^isub>a a w\<^isub>b b"} =
  @{term "huffman (splitLeaf\<^isub>F ts w\<^isub>a a w\<^isub>b b)"}$$
when @{term ts} is consistent, @{term "a \<in> alphabet\<^isub>F ts"}, @{term
"b \<notin> alphabet\<^isub>F ts"}, and $@{term "freq\<^isub>F ts a"} = @{term w\<^isub>a}
\mathbin{@{text "+"}} @{term "w\<^isub>b"}$. But before we can prove this
commutativity lemma, we need to introduce a few simple lemmas.
*}

lemma cachedWeight_splitLeaf [simp]:
"cachedWeight (splitLeaf t w\<^isub>a a w\<^isub>b b) = cachedWeight t"
by (case_tac t) simp+

lemma splitLeaf\<^isub>F_insortTree_when_in_alphabet_left [simp]:
"\<lbrakk>a \<in> alphabet t; consistent t; a \<notin> alphabet\<^isub>F ts; freq t a = w\<^isub>a + w\<^isub>b\<rbrakk> \<Longrightarrow>
 splitLeaf\<^isub>F (insortTree t ts) w\<^isub>a a w\<^isub>b b = insortTree (splitLeaf t w\<^isub>a a w\<^isub>b b) ts"
by (induct ts) simp+

lemma splitLeaf\<^isub>F_insortTree_when_in_alphabet\<^isub>F_tail [simp]:
"\<lbrakk>a \<in> alphabet\<^isub>F ts; consistent\<^isub>F ts; a \<notin> alphabet t; freq\<^isub>F ts a = w\<^isub>a + w\<^isub>b\<rbrakk> \<Longrightarrow>
 splitLeaf\<^isub>F (insortTree t ts) w\<^isub>a a w\<^isub>b b =
     insortTree t (splitLeaf\<^isub>F ts w\<^isub>a a w\<^isub>b b)"
proof (induct ts)
  case Nil thus ?case by simp
next
  case (Cons u us) show ?case
  proof (cases "a \<in> alphabet u")
    case True
    moreover hence "a \<notin> alphabet\<^isub>F us" using Cons by auto
    ultimately show ?thesis using Cons by auto
  next
    case False thus ?thesis using Cons by simp
  qed
qed

text {*
We are now ready to prove the commutativity lemma.
*}

lemma splitLeaf_huffman_commute:
"\<lbrakk>consistent\<^isub>F ts; ts \<noteq> []; a \<in> alphabet\<^isub>F ts; freq\<^isub>F ts a = w\<^isub>a + w\<^isub>b\<rbrakk> \<Longrightarrow>
 splitLeaf (huffman ts) w\<^isub>a a w\<^isub>b b = huffman (splitLeaf\<^isub>F ts w\<^isub>a a w\<^isub>b b)"
proof (induct ts rule: huffman.induct)
  -- {* {\sc Base case 1:}\enskip $@{term ts} = []$ *}
  case 3 thus ?case by simp
next
  -- {* {\sc Base case 2:}\enskip $@{term ts} = @{term "[t]"}$ *}
  case (1 t) thus ?case by simp
next
  -- {* {\sc Induction step:}\enskip $@{term ts} = @{term "t\<^isub>1 # t\<^isub>2 # ts"}$ *}
  case (2 t\<^isub>1 t\<^isub>2 ts)
  note hyps = 2
  show ?case
  proof (cases "a \<in> alphabet t\<^isub>1")
    case True
    moreover hence "a \<notin> alphabet t\<^isub>2" "a \<notin> alphabet\<^isub>F ts" using hyps by auto
    ultimately show ?thesis using hyps by (simp add: uniteTrees_def)
  next
    case False
    note a\<^isub>1 = False
    show ?thesis
    proof (cases "a \<in> alphabet t\<^isub>2")
      case True
      moreover hence "a \<notin> alphabet\<^isub>F ts" using hyps by auto
      ultimately show ?thesis using a\<^isub>1 hyps by (simp add: uniteTrees_def)
    next
      case False
      thus ?thesis using a\<^isub>1 hyps by simp
    qed
  qed
qed

text {*
An important consequence of the commutativity lemma is that applying Huffman's
algorithm on a forest of the form
$$\vcenter{\hbox{\includegraphics[scale=1.25]{forest-uniteTrees.pdf}}}$$
gives the same result as applying the algorithm on the ``flat'' forest
$$\vcenter{\hbox{\includegraphics[scale=1.25]{forest-uniteTrees-flat.pdf}}}$$
followed by splitting the leaf node $a$ into two nodes $a$, $b$ with
frequencies $@{term w\<^isub>a}$, $@{term w\<^isub>b}$. The lemma effectively
provides a way to flatten the forest at each step of the algorithm. Its
invocation is implicit in the textbook proof.
*}

subsection {* Optimality Theorem *}

text {*
We are one lemma away from our main result.
*}

lemma max_0_imp_0 [simp]:
"(max x y = (0::nat)) = (x = 0 \<and> y = 0)"
by auto

theorem optimum_huffman:
"\<lbrakk>consistent\<^isub>F ts; height\<^isub>F ts = 0; sortedByWeight ts; ts \<noteq> []\<rbrakk> \<Longrightarrow>
 optimum (huffman ts)"

txt {*
The input @{term ts} is assumed to be a nonempty consistent list of leaf nodes
sorted by weight. The proof is by induction on the length of the forest
@{term ts}. Let @{term ts} be
$$\vcenter{\hbox{\includegraphics[scale=1.25]{forest-flat.pdf}}}$$
with $w_a \le w_b \le w_c \le w_d \le \cdots \le w_z$. If @{term ts} consists
of a single leaf node, the node has cost 0 and is therefore optimum. If
@{term ts} has length 2 or more, the first step of the algorithm leaves us with
the term
$${\it huffman\/}\enskip\; \vcenter{\hbox{\includegraphics[scale=1.25]%
    {forest-uniteTrees.pdf}}}$$
In the diagram, we put the newly created tree at position 2 in the forest; in
general, it could be anywhere. By @{thm [source] splitLeaf_huffman_commute},
the above tree equals\strut
$${\it splitLeaf\/}\;\left({\it huffman\/}\enskip\;
  \vcenter{\hbox{\includegraphics[scale=1.25]{forest-uniteTrees-flat.pdf}}}
  \;\right)\,@{text "w\<^isub>a a w\<^isub>b b"}.$$
To prove that this tree is optimum, it suffices by
@{thm [source] optimum_splitLeaf} to show that\strut
$${\it huffman\/}\enskip\;
  \vcenter{\hbox{\includegraphics[scale=1.25]{forest-uniteTrees-flat.pdf}}}$$
is optimum, which follows from the induction hypothesis.\strut
*}

proof (induct ts rule: length_induct)
  -- {* \sc Complete induction step *}
  case (1 ts)
  note hyps = 1
  show ?case
  proof (cases ts)
    case Nil thus ?thesis using `ts \<noteq> []` by fast
  next
    case (Cons t\<^isub>a ts')
    note ts = Cons
    show ?thesis
    proof (cases ts')
      case Nil thus ?thesis using ts hyps by (simp add: optimum_def)
    next
      case (Cons t\<^isub>b ts'')
      note ts' = Cons
      show ?thesis
      proof (cases t\<^isub>a)
        case (Leaf w\<^isub>a a)
        note l\<^isub>a = Leaf
        show ?thesis
        proof (cases t\<^isub>b)
          case (Leaf w\<^isub>b b)
          note l\<^isub>b = Leaf
          show ?thesis
          proof -
            let ?us = "insortTree (uniteTrees t\<^isub>a t\<^isub>b) ts''"
            let ?us' = "insortTree (Leaf (w\<^isub>a + w\<^isub>b) a) ts''"
            let ?t\<^isub>s = "splitLeaf (huffman ?us') w\<^isub>a a w\<^isub>b b"
            have e\<^isub>1: "huffman ts = huffman ?us" using ts' ts by simp
            have e\<^isub>2: "huffman ?us = ?t\<^isub>s" using l\<^isub>a l\<^isub>b ts' ts hyps
              by (auto simp: splitLeaf_huffman_commute uniteTrees_def)

            have "optimum (huffman ?us')" using l\<^isub>a ts' ts hyps
              by (drule_tac x = ?us' in spec)
                 (auto dest: sortedByWeight_Cons_imp_sortedByWeight
                       simp: sortedByWeight_insortTree)
            hence "optimum ?t\<^isub>s" using l\<^isub>a l\<^isub>b ts' ts hyps
              apply simp
              apply (rule optimum_splitLeaf)
              by (auto dest!: height\<^isub>F_0_imp_Leaf_freq\<^isub>F_in_set
                              sortedByWeight_Cons_imp_forall_weight_ge)
            thus "optimum (huffman ts)" using e\<^isub>1 e\<^isub>2 by simp
          qed
        next
          case InnerNode thus ?thesis using ts' ts hyps by simp
        qed
      next
        case InnerNode thus ?thesis using ts' ts hyps by simp
      qed
    qed
  qed
qed

text {*
\isakeyword{end}

\myskip

\noindent
So what have we achieved? Assuming that our definitions really mean what we
intend them to mean, we established that our functional implementation of
Huffman's algorithm, when invoked properly, constructs a binary tree that
represents an optimal prefix code for the specified alphabet and frequencies.
Using Isabelle's code generator \cite{haftmann-nipkow-2007}, we can convert the
Isabelle code into Standard ML, OCaml, or Haskell and use it in a real
application.

As a side note, the @{thm [source] optimum_huffman} theorem assumes that the
forest @{term ts} passed to @{const huffman} consists exclusively of leaf nodes.
It is tempting to relax this restriction, by requiring instead that the forest
@{term ts} has the lowest cost among forests of the same size. We would define
optimality of a forest as follows:
$$\begin{aligned}[t]
  @{prop "optimum\<^isub>F ts"}\,\;@{text "\<equiv>"}\;\,
  (@{text "\<forall>us."}\
    & @{text "length ts = length us \<longrightarrow> consistent\<^isub>F us \<longrightarrow>"} \\[-2.5pt]
    & @{text "alphabet\<^isub>F ts = alphabet\<^isub>F us \<longrightarrow> freq\<^isub>F ts = freq\<^isub>F us \<longrightarrow>"}
\\[-2.5pt]
    & @{prop "cost\<^isub>F ts \<le> cost\<^isub>F us"})\end{aligned}$$
with $@{text "cost\<^isub>F [] = 0"}$ and
$@{prop "cost\<^isub>F (t # ts) = cost t + cost\<^isub>F ts"}$. However, the modified
proposition does not hold. A counterexample is the optimum forest
$$\includegraphics{forest-optimal.pdf}$$
for which the algorithm constructs the tree
$$\vcenter{\hbox{\includegraphics{tree-suboptimal.pdf}}}
  \qquad \hbox{of greater cost than} \qquad
  \vcenter{\hbox{\includegraphics{tree-optimal.pdf}}}$$
*}

section {* Related Work
           \label{related-work} *}

text {*
Laurent Th\'ery's Coq formalization of Huffman's algorithm \cite{thery-2003,%
thery-2004} is an obvious yardstick for our work. It has a somewhat wider
scope, proving among others the isomorphism between prefix codes and full binary
trees. With 291 theorems, it is also much larger.

Th\'ery identified the following difficulties in formalizing the textbook
proof:

\begin{enumerate}
\item The leaf interchange process that brings the two minimal symbols together
      is tedious to formalize.

\item The sibling merging process requires introducing a new symbol for the
      merged node, which complicates the formalization.

\item The algorithm constructs the tree in a bottom-up fashion. While top-down
      procedures can usually be proved by structural induction, bottom-up
      procedures often require more sophisticated induction principles and
      larger invariants.

\item The informal proof relies on the notion of depth of a node. Defining this
      notion formally is problematic, because the depth can only be seen as a
      function if the tree is composed of distinct nodes.
\end{enumerate}

To circumvent these difficulties, Th\'ery introduced the ingenious concept of
cover. A forest @{term ts} is a {\em cover\/} of a tree~$t$ if $t$ can be built
from @{term ts} by adding inner nodes on top of the trees in @{term ts}. The
term ``cover'' is easier to understand if the binary trees are drawn with the
root at the bottom of the page, like natural trees. Huffman's algorithm is
a refinement of the cover concept. The main proof consists in showing that
the cost of @{term "huffman ts"} is less than or equal to that of any other
tree for which @{term ts} is a cover. It relies on a few auxiliary definitions,
notably an ``ordered cover'' concept that facilitates structural induction
and a four-argument depth predicate (confusingly called @{term height}).
Permutations also play a central role.

Incidentally, our experience suggests that the potential problems identified
by Th\'ery can be overcome more directly without too much work, leading to a
simpler proof:

\begin{enumerate}
\item Formalizing the leaf interchange did not prove overly tedious. Among our
      95~lemmas and theorems, 24 concern @{const swapLeaves},
      @{const swapSyms}, and @{const swapFourSyms}.

\item The generation of a new symbol for the resulting node when merging two
      sibling nodes in @{const mergeSibling} was trivially solved by reusing
      one of the two merged symbols.

\item The bottom-up nature of the tree construction process was addressed by
      using the length of the forest as the induction measure and by merging
      the two minimal symbols, as in Knuth's proof.

\item By restricting our attention to consistent trees, we were able to define
      the @{const depth} function simply and meaningfully.
\end{enumerate}
*}

section {* Conclusion
           \label{conclusion} *}

text {*
The goal of most formal proofs is to increase our confidence in a result. In
the case of Huffman's algorithm, however, the chances that a bug would have
gone unnoticed for the 56 years since its publication, under the scrutiny of
leading computer scientists, seem extremely low; and the existence of a Coq
proof should be sufficient to remove any remaining doubts.

The main contribution of this report has been to demonstrate that the textbook
proof of Huffman's algorithm can be elegantly formalized using
a state-of-the-art theorem prover such as Isabelle/HOL. In the process, we
uncovered a few minor snags in the proof given in Cormen et
al.~\cite{cormen-et-al-2001}.

We also found that custom induction rules, in combination with suitable
simplification rules, greatly help the automatic proof tactics, sometimes
reducing 30-line proof scripts to one-liners. We successfully applied this
approach for handling both the ubiquitous ``datatype + well\-formed\-ness
predicate'' combination (@{typ "'a tree"} + @{const consistent}) and functions
defined by sequential pattern matching (@{const sibling} and
@{const mergeSibling}). Our experience suggests that such rules, which are
uncommon in formalizations, are highly valuable and versatile. Moreover,
Isabelle's \textit{induct\_scheme} and \textit{lexicographic\_order} tactics
make these easy to prove.

Formalizing the proof of Huffman's algorithm also led to a deeper
understanding of this classic algorithm. Many of the lemmas, notably the leaf
split commutativity lemma of Section~\ref{leaf-split-commutativity}, have not
been found in the literature and express fundamental properties of the
algorithm. Other discoveries didn't find their way into the final proof. In
particular, each step of the algorithm appears to preserve the invariant that
the nodes in a forest are ordered by weight from left to right, bottom to top,
as in the example below:\strut
$$\vcenter{\hbox{\includegraphics[scale=1.25]{forest-zigzag.pdf}}}$$
It is not hard to prove formally that a tree exhibiting this property is
optimum. On the other hand, proving that the algorithm preserves this invariant
seems difficult---more difficult than formalizing the textbook proof---and
remains a suggestion for future work.

A few other directions for future work suggest themselves. First, we could
formalize some of our hypotheses, notably our restriction to full and
consistent binary trees. The current formalization says nothing about the
algorithm's application for data compression, so the next step could be to
extend the proof's scope to cover @{term encode}/@{term decode} functions
and show that full binary trees are isomorphic to prefix codes, as done in the
Coq development. Independently, we could generalize the development to $n$-ary
trees.
*}

(*<*)
end
(*>*)
