(*  Title:      HOL/ex/Lagrange.thy
    Author:     Tobias Nipkow
    Copyright   1996 TU Muenchen
*)

header {* A lemma for Lagrange's theorem *}

theory Lagrange imports Main begin

text {* This theory only contains a single theorem, which is a lemma
in Lagrange's proof that every natural number is the sum of 4 squares.
Its sole purpose is to demonstrate ordered rewriting for commutative
rings.

The enterprising reader might consider proving all of Lagrange's
theorem.  *}

definition sq :: "'a::times => 'a" where "sq x == x*x"

text {* The following lemma essentially shows that every natural
number is the sum of four squares, provided all prime numbers are.
However, this is an abstract theorem about commutative rings.  It has,
a priori, nothing to do with nat. *}

lemma Lagrange_lemma: fixes x1 :: "'a::comm_ring" shows
  "(sq x1 + sq x2 + sq x3 + sq x4) * (sq y1 + sq y2 + sq y3 + sq y4) =
   sq (x1*y1 - x2*y2 - x3*y3 - x4*y4)  +
   sq (x1*y2 + x2*y1 + x3*y4 - x4*y3)  +
   sq (x1*y3 - x2*y4 + x3*y1 + x4*y2)  +
   sq (x1*y4 + x2*y3 - x3*y2 + x4*y1)"
by (simp only: sq_def field_simps)


text {* A challenge by John Harrison. Takes about 12s on a 1.6GHz machine. *}

lemma fixes p1 :: "'a::comm_ring" shows
  "(sq p1 + sq q1 + sq r1 + sq s1 + sq t1 + sq u1 + sq v1 + sq w1) * 
   (sq p2 + sq q2 + sq r2 + sq s2 + sq t2 + sq u2 + sq v2 + sq w2) 
    = sq (p1*p2 - q1*q2 - r1*r2 - s1*s2 - t1*t2 - u1*u2 - v1*v2 - w1*w2) + 
      sq (p1*q2 + q1*p2 + r1*s2 - s1*r2 + t1*u2 - u1*t2 - v1*w2 + w1*v2) +
      sq (p1*r2 - q1*s2 + r1*p2 + s1*q2 + t1*v2 + u1*w2 - v1*t2 - w1*u2) +
      sq (p1*s2 + q1*r2 - r1*q2 + s1*p2 + t1*w2 - u1*v2 + v1*u2 - w1*t2) +
      sq (p1*t2 - q1*u2 - r1*v2 - s1*w2 + t1*p2 + u1*q2 + v1*r2 + w1*s2) +
      sq (p1*u2 + q1*t2 - r1*w2 + s1*v2 - t1*q2 + u1*p2 - v1*s2 + w1*r2) +
      sq (p1*v2 + q1*w2 + r1*t2 - s1*u2 - t1*r2 + u1*s2 + v1*p2 - w1*q2) +
      sq (p1*w2 - q1*v2 + r1*u2 + s1*t2 - t1*s2 - u1*r2 + v1*q2 + w1*p2)"
by (simp only: sq_def field_simps)

end
