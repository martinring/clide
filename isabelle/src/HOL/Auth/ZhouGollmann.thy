(*  Title:      HOL/Auth/ZhouGollmann.thy
    Author:     Giampaolo Bella and L C Paulson, Cambridge Univ Computer Lab
    Copyright   2003  University of Cambridge

The protocol of
  Jianying Zhou and Dieter Gollmann,
  A Fair Non-Repudiation Protocol,
  Security and Privacy 1996 (Oakland)
  55-61
*)

theory ZhouGollmann imports Public begin

abbreviation
  TTP :: agent where "TTP == Server"

abbreviation f_sub :: nat where "f_sub == 5"
abbreviation f_nro :: nat where "f_nro == 2"
abbreviation f_nrr :: nat where "f_nrr == 3"
abbreviation f_con :: nat where "f_con == 4"


definition broken :: "agent set" where    
    --{*the compromised honest agents; TTP is included as it's not allowed to
        use the protocol*}
   "broken == bad - {Spy}"

declare broken_def [simp]

inductive_set zg :: "event list set"
  where

  Nil:  "[] \<in> zg"

| Fake: "[| evsf \<in> zg;  X \<in> synth (analz (spies evsf)) |]
         ==> Says Spy B X  # evsf \<in> zg"

| Reception:  "[| evsr \<in> zg; Says A B X \<in> set evsr |] ==> Gets B X # evsr \<in> zg"

  (*L is fresh for honest agents.
    We don't require K to be fresh because we don't bother to prove secrecy!
    We just assume that the protocol's objective is to deliver K fairly,
    rather than to keep M secret.*)
| ZG1: "[| evs1 \<in> zg;  Nonce L \<notin> used evs1; C = Crypt K (Number m);
           K \<in> symKeys;
           NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, C|}|]
       ==> Says A B {|Number f_nro, Agent B, Nonce L, C, NRO|} # evs1 \<in> zg"

  (*B must check that NRO is A's signature to learn the sender's name*)
| ZG2: "[| evs2 \<in> zg;
           Gets B {|Number f_nro, Agent B, Nonce L, C, NRO|} \<in> set evs2;
           NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, C|};
           NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, C|}|]
       ==> Says B A {|Number f_nrr, Agent A, Nonce L, NRR|} # evs2  \<in>  zg"

  (*A must check that NRR is B's signature to learn the sender's name;
    without spy, the matching label would be enough*)
| ZG3: "[| evs3 \<in> zg; C = Crypt K M; K \<in> symKeys;
           Says A B {|Number f_nro, Agent B, Nonce L, C, NRO|} \<in> set evs3;
           Gets A {|Number f_nrr, Agent A, Nonce L, NRR|} \<in> set evs3;
           NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, C|};
           sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|}|]
       ==> Says A TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|}
             # evs3 \<in> zg"

 (*TTP checks that sub_K is A's signature to learn who issued K, then
   gives credentials to A and B.  The Notes event models the availability of
   the credentials, but the act of fetching them is not modelled.  We also
   give con_K to the Spy. This makes the threat model more dangerous, while 
   also allowing lemma @{text Crypt_used_imp_spies} to omit the condition
   @{term "K \<noteq> priK TTP"}. *)
| ZG4: "[| evs4 \<in> zg; K \<in> symKeys;
           Gets TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|}
             \<in> set evs4;
           sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
           con_K = Crypt (priK TTP) {|Number f_con, Agent A, Agent B,
                                      Nonce L, Key K|}|]
       ==> Says TTP Spy con_K
           #
           Notes TTP {|Number f_con, Agent A, Agent B, Nonce L, Key K, con_K|}
           # evs4 \<in> zg"


declare Says_imp_knows_Spy [THEN analz.Inj, dest]
declare Fake_parts_insert_in_Un  [dest]
declare analz_into_parts [dest]

declare symKey_neq_priEK [simp]
declare symKey_neq_priEK [THEN not_sym, simp]


text{*A "possibility property": there are traces that reach the end*}
lemma "[|A \<noteq> B; TTP \<noteq> A; TTP \<noteq> B; K \<in> symKeys|] ==>
     \<exists>L. \<exists>evs \<in> zg.
           Notes TTP {|Number f_con, Agent A, Agent B, Nonce L, Key K,
               Crypt (priK TTP) {|Number f_con, Agent A, Agent B, Nonce L, Key K|} |}
               \<in> set evs"
apply (intro exI bexI)
apply (rule_tac [2] zg.Nil
                    [THEN zg.ZG1, THEN zg.Reception [of _ A B],
                     THEN zg.ZG2, THEN zg.Reception [of _ B A],
                     THEN zg.ZG3, THEN zg.Reception [of _ A TTP], 
                     THEN zg.ZG4])
apply (possibility, auto)
done

subsection {*Basic Lemmas*}

lemma Gets_imp_Says:
     "[| Gets B X \<in> set evs; evs \<in> zg |] ==> \<exists>A. Says A B X \<in> set evs"
apply (erule rev_mp)
apply (erule zg.induct, auto)
done

lemma Gets_imp_knows_Spy:
     "[| Gets B X \<in> set evs; evs \<in> zg |]  ==> X \<in> spies evs"
by (blast dest!: Gets_imp_Says Says_imp_knows_Spy)


text{*Lets us replace proofs about @{term "used evs"} by simpler proofs 
about @{term "parts (spies evs)"}.*}
lemma Crypt_used_imp_spies:
     "[| Crypt K X \<in> used evs; evs \<in> zg |]
      ==> Crypt K X \<in> parts (spies evs)"
apply (erule rev_mp)
apply (erule zg.induct)
apply (simp_all add: parts_insert_knows_A) 
done

lemma Notes_TTP_imp_Gets:
     "[|Notes TTP {|Number f_con, Agent A, Agent B, Nonce L, Key K, con_K |}
           \<in> set evs;
        sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
        evs \<in> zg|]
    ==> Gets TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|} \<in> set evs"
apply (erule rev_mp)
apply (erule zg.induct, auto)
done

text{*For reasoning about C, which is encrypted in message ZG2*}
lemma ZG2_msg_in_parts_spies:
     "[|Gets B {|F, B', L, C, X|} \<in> set evs; evs \<in> zg|]
      ==> C \<in> parts (spies evs)"
by (blast dest: Gets_imp_Says)

(*classical regularity lemma on priK*)
lemma Spy_see_priK [simp]:
     "evs \<in> zg ==> (Key (priK A) \<in> parts (spies evs)) = (A \<in> bad)"
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, auto)
done

text{*So that blast can use it too*}
declare  Spy_see_priK [THEN [2] rev_iffD1, dest!]

lemma Spy_analz_priK [simp]:
     "evs \<in> zg ==> (Key (priK A) \<in> analz (spies evs)) = (A \<in> bad)"
by auto 


subsection{*About NRO: Validity for @{term B}*}

text{*Below we prove that if @{term NRO} exists then @{term A} definitely
sent it, provided @{term A} is not broken.*}

text{*Strong conclusion for a good agent*}
lemma NRO_validity_good:
     "[|NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, C|};
        NRO \<in> parts (spies evs);
        A \<notin> bad;  evs \<in> zg |]
     ==> Says A B {|Number f_nro, Agent B, Nonce L, C, NRO|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, auto)  
done

lemma NRO_sender:
     "[|Says A' B {|n, b, l, C, Crypt (priK A) X|} \<in> set evs; evs \<in> zg|]
    ==> A' \<in> {A,Spy}"
apply (erule rev_mp)  
apply (erule zg.induct, simp_all)
done

text{*Holds also for @{term "A = Spy"}!*}
theorem NRO_validity:
     "[|Gets B {|Number f_nro, Agent B, Nonce L, C, NRO|} \<in> set evs;
        NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, C|};
        A \<notin> broken;  evs \<in> zg |]
     ==> Says A B {|Number f_nro, Agent B, Nonce L, C, NRO|} \<in> set evs"
apply (drule Gets_imp_Says, assumption) 
apply clarify 
apply (frule NRO_sender, auto)
txt{*We are left with the case where the sender is @{term Spy} and not
  equal to @{term A}, because @{term "A \<notin> bad"}. 
  Thus theorem @{text NRO_validity_good} applies.*}
apply (blast dest: NRO_validity_good [OF refl])
done


subsection{*About NRR: Validity for @{term A}*}

text{*Below we prove that if @{term NRR} exists then @{term B} definitely
sent it, provided @{term B} is not broken.*}

text{*Strong conclusion for a good agent*}
lemma NRR_validity_good:
     "[|NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, C|};
        NRR \<in> parts (spies evs);
        B \<notin> bad;  evs \<in> zg |]
     ==> Says B A {|Number f_nrr, Agent A, Nonce L, NRR|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule zg.induct) 
apply (frule_tac [5] ZG2_msg_in_parts_spies, auto)  
done

lemma NRR_sender:
     "[|Says B' A {|n, a, l, Crypt (priK B) X|} \<in> set evs; evs \<in> zg|]
    ==> B' \<in> {B,Spy}"
apply (erule rev_mp)  
apply (erule zg.induct, simp_all)
done

text{*Holds also for @{term "B = Spy"}!*}
theorem NRR_validity:
     "[|Says B' A {|Number f_nrr, Agent A, Nonce L, NRR|} \<in> set evs;
        NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, C|};
        B \<notin> broken; evs \<in> zg|]
    ==> Says B A {|Number f_nrr, Agent A, Nonce L, NRR|} \<in> set evs"
apply clarify 
apply (frule NRR_sender, auto)
txt{*We are left with the case where @{term "B' = Spy"} and  @{term "B' \<noteq> B"},
  i.e. @{term "B \<notin> bad"}, when we can apply @{text NRR_validity_good}.*}
 apply (blast dest: NRR_validity_good [OF refl])
done


subsection{*Proofs About @{term sub_K}*}

text{*Below we prove that if @{term sub_K} exists then @{term A} definitely
sent it, provided @{term A} is not broken.  *}

text{*Strong conclusion for a good agent*}
lemma sub_K_validity_good:
     "[|sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
        sub_K \<in> parts (spies evs);
        A \<notin> bad;  evs \<in> zg |]
     ==> Says A TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, simp_all)
txt{*Fake*} 
apply (blast dest!: Fake_parts_sing_imp_Un)
done

lemma sub_K_sender:
     "[|Says A' TTP {|n, b, l, k, Crypt (priK A) X|} \<in> set evs;  evs \<in> zg|]
    ==> A' \<in> {A,Spy}"
apply (erule rev_mp)  
apply (erule zg.induct, simp_all)
done

text{*Holds also for @{term "A = Spy"}!*}
theorem sub_K_validity:
     "[|Gets TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|} \<in> set evs;
        sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
        A \<notin> broken;  evs \<in> zg |]
     ==> Says A TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|} \<in> set evs"
apply (drule Gets_imp_Says, assumption) 
apply clarify 
apply (frule sub_K_sender, auto)
txt{*We are left with the case where the sender is @{term Spy} and not
  equal to @{term A}, because @{term "A \<notin> bad"}. 
  Thus theorem @{text sub_K_validity_good} applies.*}
apply (blast dest: sub_K_validity_good [OF refl])
done



subsection{*Proofs About @{term con_K}*}

text{*Below we prove that if @{term con_K} exists, then @{term TTP} has it,
and therefore @{term A} and @{term B}) can get it too.  Moreover, we know
that @{term A} sent @{term sub_K}*}

lemma con_K_validity:
     "[|con_K \<in> used evs;
        con_K = Crypt (priK TTP)
                  {|Number f_con, Agent A, Agent B, Nonce L, Key K|};
        evs \<in> zg |]
    ==> Notes TTP {|Number f_con, Agent A, Agent B, Nonce L, Key K, con_K|}
          \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, simp_all)
txt{*Fake*}
apply (blast dest!: Fake_parts_sing_imp_Un)
txt{*ZG2*} 
apply (blast dest: parts_cut)
done

text{*If @{term TTP} holds @{term con_K} then @{term A} sent
 @{term sub_K}.  We assume that @{term A} is not broken.  Importantly, nothing
  needs to be assumed about the form of @{term con_K}!*}
lemma Notes_TTP_imp_Says_A:
     "[|Notes TTP {|Number f_con, Agent A, Agent B, Nonce L, Key K, con_K|}
           \<in> set evs;
        sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
        A \<notin> broken; evs \<in> zg|]
     ==> Says A TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, simp_all)
txt{*ZG4*}
apply clarify 
apply (rule sub_K_validity, auto) 
done

text{*If @{term con_K} exists, then @{term A} sent @{term sub_K}.  We again
   assume that @{term A} is not broken. *}
theorem B_sub_K_validity:
     "[|con_K \<in> used evs;
        con_K = Crypt (priK TTP) {|Number f_con, Agent A, Agent B,
                                   Nonce L, Key K|};
        sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
        A \<notin> broken; evs \<in> zg|]
     ==> Says A TTP {|Number f_sub, Agent B, Nonce L, Key K, sub_K|} \<in> set evs"
by (blast dest: con_K_validity Notes_TTP_imp_Says_A)


subsection{*Proving fairness*}

text{*Cannot prove that, if @{term B} has NRO, then  @{term A} has her NRR.
It would appear that @{term B} has a small advantage, though it is
useless to win disputes: @{term B} needs to present @{term con_K} as well.*}

text{*Strange: unicity of the label protects @{term A}?*}
lemma A_unicity: 
     "[|NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, Crypt K M|};
        NRO \<in> parts (spies evs);
        Says A B {|Number f_nro, Agent B, Nonce L, Crypt K M', NRO'|}
          \<in> set evs;
        A \<notin> bad; evs \<in> zg |]
     ==> M'=M"
apply clarify
apply (erule rev_mp)
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, auto) 
txt{*ZG1: freshness*}
apply (blast dest: parts.Body) 
done


text{*Fairness lemma: if @{term sub_K} exists, then @{term A} holds 
NRR.  Relies on unicity of labels.*}
lemma sub_K_implies_NRR:
     "[| NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, Crypt K M|};
         NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, Crypt K M|};
         sub_K \<in> parts (spies evs);
         NRO \<in> parts (spies evs);
         sub_K = Crypt (priK A) {|Number f_sub, Agent B, Nonce L, Key K|};
         A \<notin> bad;  evs \<in> zg |]
     ==> Gets A {|Number f_nrr, Agent A, Nonce L, NRR|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, simp_all)
txt{*Fake*}
apply blast 
txt{*ZG1: freshness*}
apply (blast dest: parts.Body) 
txt{*ZG3*} 
apply (blast dest: A_unicity [OF refl]) 
done


lemma Crypt_used_imp_L_used:
     "[| Crypt (priK TTP) {|F, A, B, L, K|} \<in> used evs; evs \<in> zg |]
      ==> L \<in> used evs"
apply (erule rev_mp)
apply (erule zg.induct, auto)
txt{*Fake*}
apply (blast dest!: Fake_parts_sing_imp_Un)
txt{*ZG2: freshness*}
apply (blast dest: parts.Body) 
done


text{*Fairness for @{term A}: if @{term con_K} and @{term NRO} exist, 
then @{term A} holds NRR.  @{term A} must be uncompromised, but there is no
assumption about @{term B}.*}
theorem A_fairness_NRO:
     "[|con_K \<in> used evs;
        NRO \<in> parts (spies evs);
        con_K = Crypt (priK TTP)
                      {|Number f_con, Agent A, Agent B, Nonce L, Key K|};
        NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, Crypt K M|};
        NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, Crypt K M|};
        A \<notin> bad;  evs \<in> zg |]
    ==> Gets A {|Number f_nrr, Agent A, Nonce L, NRR|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, simp_all)
   txt{*Fake*}
   apply (simp add: parts_insert_knows_A) 
   apply (blast dest: Fake_parts_sing_imp_Un) 
  txt{*ZG1*}
  apply (blast dest: Crypt_used_imp_L_used) 
 txt{*ZG2*}
 apply (blast dest: parts_cut)
txt{*ZG4*} 
apply (blast intro: sub_K_implies_NRR [OF refl] 
             dest: Gets_imp_knows_Spy [THEN parts.Inj])
done

text{*Fairness for @{term B}: NRR exists at all, then @{term B} holds NRO.
@{term B} must be uncompromised, but there is no assumption about @{term
A}. *}
theorem B_fairness_NRR:
     "[|NRR \<in> used evs;
        NRR = Crypt (priK B) {|Number f_nrr, Agent A, Nonce L, C|};
        NRO = Crypt (priK A) {|Number f_nro, Agent B, Nonce L, C|};
        B \<notin> bad; evs \<in> zg |]
    ==> Gets B {|Number f_nro, Agent B, Nonce L, C, NRO|} \<in> set evs"
apply clarify
apply (erule rev_mp)
apply (erule zg.induct)
apply (frule_tac [5] ZG2_msg_in_parts_spies, simp_all)
txt{*Fake*}
apply (blast dest!: Fake_parts_sing_imp_Un)
txt{*ZG2*}
apply (blast dest: parts_cut)
done


text{*If @{term con_K} exists at all, then @{term B} can get it, by @{text
con_K_validity}.  Cannot conclude that also NRO is available to @{term B},
because if @{term A} were unfair, @{term A} could build message 3 without
building message 1, which contains NRO. *}

end
