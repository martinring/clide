header {* Very Simple Propositional Logic *}
theory VSPL
imports Pure
begin

text{* 
  Hier wird der Typ o deklariert; für die einfache Aussagenlogik 
  gibt es nur einen einzigen Typ. *} 
typedecl o

text{* Dieser Teil ist rein technischer Natur. *}
judgment
  Trueprop  :: "o => prop"                  ("(_)" 5)

text{* 
  Deklaration der Konstanten False, And, Implies.
  (Der Teil in Klammern sorgt für schicke Syntax, e.g. A & B).
  *}
consts
  False   :: o
  And     :: "[o, o] => o"                (infixr "&" 35)
  Implies :: "[o, o] => o"                (infixr "-->" 25)

text{* 
  Die sieben Grundregeln der einfachen Aussagenlogik.
  *}

axioms
  conjI:  "[| P;  Q |] ==> P&Q"
  conjE1: "[| P&Q |] ==> P"
  conjE2: "[| P&Q |] ==> Q"

  impI:   "(P ==> Q) ==> P -->Q"
  impE:   "[| P-->Q ; P|] ==> Q"

  False:  "[| False |] ==> P"
  Raa:    "[| P--> False ==> False |] ==> P"

text{* 
  Das erste Lemma: Konjunktivität der Konjunktion. 
  *}
lemma conj_comm: "X & Y --> Y & X"
  apply (rule impI)
  apply (rule conjI)
  apply (rule conjE2 [where P="X"]) 
       --{* Angabe der Instantiierung, um Variable ?P5 im Beweisziel 
            zu vermeiden. *}
  apply (assumption) --{* Beweis durch Benutzung der Annahme *}
  apply (erule conjE1)
      --{* erule conjE1 fasst die beiden Schritte apply(rule ...), assumption
           zusammen. *}
done

lemma tafelbeweis: "(A --> (B--> C))--> (A & B --> C)"
  apply (rule impI)
  apply (rule impI)
  apply (rule impE [where P="B"]) --{* Konkrete Instantiierung für P *} 
  apply (rule impE [where P="A"]) 
  apply (assumption) 
  apply (erule conjE1)
  apply (erule conjE2)
  done



lemma doubleneg: "((A --> False)--> False)--> A"
  apply (rule impI)
  apply (rule Raa)
  apply (rule impE [where P="A--> False"])
  apply (assumption)
  apply (assumption)
  done

text{*
  Hier wird eine Konstante \emph{definiert}, d.h. sie wird als
  abkürzende Schreibweise vereinbart:
  *}

definition
  Not    :: "o => o"                     ("~ _" [40] 40)
where
  "~P    == P --> False"

lemma notnot: "~~ P--> P"
  apply (unfold Not_def) 
    --{* Mit unfold wird die linke Seite einer Konstantendefinition durch 
         die rechte Seite ersetzt; die Konstante wird 'aufgefaltet'. 
       *}
  apply (rule doubleneg)
  done

lemma notnot2: "P --> ~~P"
  sorry --{* Übungsblatt *}


text{*
  Hier wird das Lemma Raa' definiert als das Lemma Raa, in dem alle Vorkommen
  von P--> False durch ~P ersetzt werden ("einfalten" der Konstantendefinition).
  *}
lemmas Raa' = Raa [folded Not_def]

text{*
  Auf dieselbe Art und Weise erhalten wir die Einführungs- und 
  Eleminationsregeln für die Negation: wir ersetzen Q in notI und notE
  durch False, und falten die Definition ein:
  *}

lemmas notI = impI [where Q="False", folded Not_def]
lemmas notE = impE [where Q="False", folded Not_def]



text{*
  Definition der Disjunktion, sowie die Einführungs- und Elemininationsregeln.
  *}

definition
  Or  :: "[o, o] => o"                (infixr "|" 30)
where
  "P | Q == ~(~P & ~Q)"

theorem disjI1: "P ==> P | Q"
  apply (unfold Or_def)
  apply (rule notI)
  apply (rule notE [where P="P"])
  apply (erule conjE1) 
  apply (assumption)
  done

lemma disjI2: "Q ==> P | Q"
  apply (unfold Or_def)
  apply (rule notI)
  apply (rule notE [where P="Q"])
  apply (erule conjE2) 
  apply (assumption)
  done

lemma disjE: "[| P | Q; P==> R; Q ==> R |] ==> R"
  apply (unfold Or_def)
  apply (rule Raa')
  apply (rule notE [where P="~P & ~Q"])
  apply (assumption)
  apply (rule conjI)
  apply (rule notI)
  apply (rule notE [where P="R"])
  apply (assumption)
  apply (drule impI)
  apply (erule impE [where P="P"])
  apply (assumption)
  apply (rule notI)
  apply (rule notE [where P="R"])
  apply (assumption)
  apply (drule impI [where P="Q"])
  apply (rule impE [where P="Q"])
  apply (assumption, assumption)
  done


text{*
  Definition der Äquivalenz (Biimplikation) mit seinen Regeln. 
  *}
definition
  Iff :: "[o, o] => o"               (infixr "<-->" 20)
where
  "P <--> Q == ((P --> Q) & (Q --> P))"

lemma iffI: "[| P--> Q; Q --> P |] ==> P <--> Q"
  apply (unfold Iff_def)
  apply (rule conjI)
  apply (assumption)
  apply (assumption)
  done

lemma iffE1: "[| P <--> Q |] ==> (P --> Q)"
  apply (unfold Iff_def)
  apply (erule conjE1)
  done

lemma iffE2: "[| P <--> Q |] ==> (Q --> P)"
  apply (unfold Iff_def)
  apply (erule conjE2)
  done

lemma iff_notnot: "~~ P <--> P"
  apply (rule iffI)
  apply (rule notnot)
  apply (rule notnot2)
  done

lemma imp_refl: "P --> P"
  apply (rule impI)
  apply (assumption)
  done


lemma iff_refl: "P <--> P"
  apply (rule iffI)
  apply (rule imp_refl)
  apply (rule imp_refl)
  done

end
