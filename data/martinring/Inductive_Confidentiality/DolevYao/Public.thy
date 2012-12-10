(*  Title:      HOL/Auth/Public.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1996  University of Cambridge*)

header{*Theory of Cryptographic Keys for Security Protocols against Dolev-Yao*}

theory Public
imports Event
begin

lemma invKey_K: "K \<in> symKeys ==> invKey K = K"
by (simp add: symKeys_def)

subsection{*Asymmetric Keys*}

datatype keymode = Signature | Encryption

consts
  publicKey :: "[keymode,agent] => key"

abbreviation
  pubEK :: "agent => key" where
  "pubEK == publicKey Encryption"

abbreviation
  pubSK :: "agent => key" where
  "pubSK == publicKey Signature"

abbreviation
  privateKey :: "[keymode, agent] => key" where
  "privateKey b A == invKey (publicKey b A)"

abbreviation
  (*BEWARE!! priEK, priSK DON'T WORK with inj, range, image, etc.*)
  priEK :: "agent => key" where
  "priEK A == privateKey Encryption A"

abbreviation
  priSK :: "agent => key" where
  "priSK A == privateKey Signature A"


text{*These abbreviations give backward compatibility.  They represent the
simple situation where the signature and encryption keys are the same.*}

abbreviation
  pubK :: "agent => key" where
  "pubK A == pubEK A"

abbreviation
  priK :: "agent => key" where
  "priK A == invKey (pubEK A)"


text{*By freeness of agents, no two agents have the same key.  Since
  @{term "True\<noteq>False"}, no agent has identical signing and encryption keys*}
specification (publicKey)
  injective_publicKey:
    "publicKey b A = publicKey c A' ==> b=c & A=A'"
   apply (rule exI [of _ 
       "%b A. 2 * agent_case 0 (\<lambda>n. n + 2) 1 A + keymode_case 0 1 b"])
   apply (auto simp add: inj_on_def split: agent.split keymode.split)
   apply presburger
   apply presburger
   done                       


axiomatization where
  (*No private key equals any public key (essential to ensure that private
    keys are private!) *)
  privateKey_neq_publicKey [iff]: "privateKey b A \<noteq> publicKey c A'"

lemmas publicKey_neq_privateKey = privateKey_neq_publicKey [THEN not_sym]
declare publicKey_neq_privateKey [iff]


subsection{*Basic properties of @{term pubK} and @{term priK}*}

lemma publicKey_inject [iff]: "(publicKey b A = publicKey c A') = (b=c & A=A')"
by (blast dest!: injective_publicKey) 

lemma not_symKeys_pubK [iff]: "publicKey b A \<notin> symKeys"
by (simp add: symKeys_def)

lemma not_symKeys_priK [iff]: "privateKey b A \<notin> symKeys"
by (simp add: symKeys_def)

lemma symKey_neq_priEK: "K \<in> symKeys ==> K \<noteq> priEK A"
by auto

lemma symKeys_neq_imp_neq: "(K \<in> symKeys) \<noteq> (K' \<in> symKeys) ==> K \<noteq> K'"
by blast

lemma symKeys_invKey_iff [iff]: "(invKey K \<in> symKeys) = (K \<in> symKeys)"
by (unfold symKeys_def, auto)

lemma analz_symKeys_Decrypt:
     "[| Crypt K X \<in> analz H;  K \<in> symKeys;  Key K \<in> analz H |]  
      ==> X \<in> analz H"
by (auto simp add: symKeys_def)



subsection{*"Image" equations that hold for injective functions*}

lemma invKey_image_eq [simp]: "(invKey x \<in> invKey`A) = (x \<in> A)"
by auto

(*holds because invKey is injective*)
lemma publicKey_image_eq [simp]:
     "(publicKey b x \<in> publicKey c ` AA) = (b=c & x \<in> AA)"
by auto

lemma privateKey_notin_image_publicKey [simp]: "privateKey b x \<notin> publicKey c ` AA"
by auto

lemma privateKey_image_eq [simp]:
     "(privateKey b A \<in> invKey ` publicKey c ` AS) = (b=c & A\<in>AS)"
by auto

lemma publicKey_notin_image_privateKey [simp]: "publicKey b A \<notin> invKey ` publicKey c ` AS"
by auto


subsection{*Symmetric Keys*}

text{*For some protocols, it is convenient to equip agents with symmetric as
well as asymmetric keys.  The theory @{text Shared} assumes that all keys
are symmetric.*}

consts
  shrK    :: "agent => key"    --{*long-term shared keys*}

specification (shrK)
  inj_shrK: "inj shrK"
  --{*No two agents have the same long-term key*}
   apply (rule exI [of _ "agent_case 0 (\<lambda>n. n + 2) 1"]) 
   apply (simp add: inj_on_def split: agent.split) 
   done

axiomatization where
  sym_shrK [iff]: "shrK X \<in> symKeys" --{*All shared keys are symmetric*}

text{*Injectiveness: Agents' long-term keys are distinct.*}
lemmas shrK_injective = inj_shrK [THEN inj_eq]
declare shrK_injective [iff]

lemma invKey_shrK [simp]: "invKey (shrK A) = shrK A"
by (simp add: invKey_K) 

lemma analz_shrK_Decrypt:
     "[| Crypt (shrK A) X \<in> analz H; Key(shrK A) \<in> analz H |] ==> X \<in> analz H"
by auto

lemma analz_Decrypt':
     "[| Crypt K X \<in> analz H; K \<in> symKeys; Key K \<in> analz H |] ==> X \<in> analz H"
by (auto simp add: invKey_K)

lemma priK_neq_shrK [iff]: "shrK A \<noteq> privateKey b C"
by (simp add: symKeys_neq_imp_neq)

lemmas shrK_neq_priK = priK_neq_shrK [THEN not_sym]
declare shrK_neq_priK [simp]

lemma pubK_neq_shrK [iff]: "shrK A \<noteq> publicKey b C"
by (simp add: symKeys_neq_imp_neq)

lemmas shrK_neq_pubK = pubK_neq_shrK [THEN not_sym]
declare shrK_neq_pubK [simp]

lemma priEK_noteq_shrK [simp]: "priEK A \<noteq> shrK B" 
by auto

lemma publicKey_notin_image_shrK [simp]: "publicKey b x \<notin> shrK ` AA"
by auto

lemma privateKey_notin_image_shrK [simp]: "privateKey b x \<notin> shrK ` AA"
by auto

lemma shrK_notin_image_publicKey [simp]: "shrK x \<notin> publicKey b ` AA"
by auto

lemma shrK_notin_image_privateKey [simp]: "shrK x \<notin> invKey ` publicKey b ` AA" 
by auto

lemma shrK_image_eq [simp]: "(shrK x \<in> shrK ` AA) = (x \<in> AA)"
by auto

text{*For some reason, moving this up can make some proofs loop!*}
declare invKey_K [simp]


subsection{*Initial States of Agents*}

text{*Note: for all practical purposes, all that matters is the initial
knowledge of the Spy.  All other agents are automata, merely following the
protocol.*}

overloading
  initState \<equiv> initState
begin

primrec initState where
        (*Agents know their private key and all public keys*)
  initState_Server:
    "initState Server     =    
       {Key (priEK Server), Key (priSK Server)} \<union> 
       (Key ` range pubEK) \<union> (Key ` range pubSK) \<union> (Key ` range shrK)"

| initState_Friend:
    "initState (Friend i) =    
       {Key (priEK(Friend i)), Key (priSK(Friend i)), Key (shrK(Friend i))} \<union> 
       (Key ` range pubEK) \<union> (Key ` range pubSK)"

| initState_Spy:
    "initState Spy        =    
       (Key ` invKey ` pubEK ` bad) \<union> (Key ` invKey ` pubSK ` bad) \<union> 
       (Key ` shrK ` bad) \<union> 
       (Key ` range pubEK) \<union> (Key ` range pubSK)"

end


text{*These lemmas allow reasoning about @{term "used evs"} rather than
   @{term "knows Spy evs"}, which is useful when there are private Notes. 
   Because they depend upon the definition of @{term initState}, they cannot
   be moved up.*}

lemma used_parts_subset_parts [rule_format]:
     "\<forall>X \<in> used evs. parts {X} \<subseteq> used evs"
apply (induct evs) 
 prefer 2
 apply (simp add: used_Cons split: event.split)
 apply (metis Un_iff empty_subsetI insert_subset le_supI1 le_supI2 parts_subset_iff)
txt{*Base case*}
apply (auto dest!: parts_cut simp add: used_Nil) 
done

lemma MPair_used_D: "{|X,Y|} \<in> used H ==> X \<in> used H & Y \<in> used H"
by (drule used_parts_subset_parts, simp, blast)

text{*There was a similar theorem in Event.thy, so perhaps this one can
  be moved up if proved directly by induction.*}
lemma MPair_used [elim!]:
     "[| {|X,Y|} \<in> used H;
         [| X \<in> used H; Y \<in> used H |] ==> P |] 
      ==> P"
by (blast dest: MPair_used_D) 


text{*Rewrites should not refer to  @{term "initState(Friend i)"} because
  that expression is not in normal form.*}

lemma keysFor_parts_initState [simp]: "keysFor (parts (initState C)) = {}"
apply (unfold keysFor_def)
apply (induct_tac "C")
apply (auto intro: range_eqI)
done

lemma Crypt_notin_initState: "Crypt K X \<notin> parts (initState B)"
by (induct B, auto)

lemma Crypt_notin_used_empty [simp]: "Crypt K X \<notin> used []"
by (simp add: Crypt_notin_initState used_Nil)

(*** Basic properties of shrK ***)

(*Agents see their own shared keys!*)
lemma shrK_in_initState [iff]: "Key (shrK A) \<in> initState A"
by (induct_tac "A", auto)

lemma shrK_in_knows [iff]: "Key (shrK A) \<in> knows A evs"
by (simp add: initState_subset_knows [THEN subsetD])

lemma shrK_in_used [iff]: "Key (shrK A) \<in> used evs"
by (rule initState_into_used, blast)


(** Fresh keys never clash with long-term shared keys **)

(*Used in parts_induct_tac and analz_Fake_tac to distinguish session keys
  from long-term shared keys*)
lemma Key_not_used [simp]: "Key K \<notin> used evs ==> K \<notin> range shrK"
by blast

lemma shrK_neq: "Key K \<notin> used evs ==> shrK B \<noteq> K"
by blast

lemmas neq_shrK = shrK_neq [THEN not_sym]
declare neq_shrK [simp]


subsection{*Function @{term "knows Spy"} *}

lemma not_SignatureE [elim!]: "b \<noteq> Signature \<Longrightarrow> b = Encryption"
  by (cases b, auto) 

text{*Agents see their own private keys!*}
lemma priK_in_initState [iff]: "Key (privateKey b A) \<in> initState A"
  by (cases A, auto)

text{*Agents see all public keys!*}
lemma publicKey_in_initState [iff]: "Key (publicKey b A) \<in> initState B"
  by (cases B, auto) 

text{*All public keys are visible*}
lemma spies_pubK [iff]: "Key (publicKey b A) \<in> spies evs"
apply (induct_tac "evs")
apply (auto simp add: imageI knows_Cons split add: event.split)
done

lemmas analz_spies_pubK = spies_pubK [THEN analz.Inj]
declare analz_spies_pubK [iff]

text{*Spy sees private keys of bad agents!*}
lemma Spy_spies_bad_privateKey [intro!]:
     "A \<in> bad ==> Key (privateKey b A) \<in> spies evs"
apply (induct_tac "evs")
apply (auto simp add: imageI knows_Cons split add: event.split)
done

text{*Spy sees long-term shared keys of bad agents!*}
lemma Spy_spies_bad_shrK [intro!]:
     "A \<in> bad ==> Key (shrK A) \<in> spies evs"
apply (induct_tac "evs")
apply (simp_all add: imageI knows_Cons split add: event.split)
done

lemma publicKey_into_used [iff] :"Key (publicKey b A) \<in> used evs"
apply (rule initState_into_used)
apply (rule publicKey_in_initState [THEN parts.Inj])
done

lemma privateKey_into_used [iff]: "Key (privateKey b A) \<in> used evs"
apply(rule initState_into_used)
apply(rule priK_in_initState [THEN parts.Inj])
done

(*For case analysis on whether or not an agent is compromised*)
lemma Crypt_Spy_analz_bad:
     "[| Crypt (shrK A) X \<in> analz (knows Spy evs);  A \<in> bad |]  
      ==> X \<in> analz (knows Spy evs)"
by force


subsection{*Fresh Nonces*}

lemma Nonce_notin_initState [iff]: "Nonce N \<notin> parts (initState B)"
by (induct_tac "B", auto)

lemma Nonce_notin_used_empty [simp]: "Nonce N \<notin> used []"
by (simp add: used_Nil)


subsection{*Supply fresh nonces for possibility theorems*}

text{*In any trace, there is an upper bound N on the greatest nonce in use*}
lemma Nonce_supply_lemma: "EX N. ALL n. N<=n --> Nonce n \<notin> used evs"
apply (induct_tac "evs")
apply (rule_tac x = 0 in exI)
apply (simp_all (no_asm_simp) add: used_Cons split add: event.split)
apply safe
apply (rule msg_Nonce_supply [THEN exE], blast elim!: add_leE)+
done

lemma Nonce_supply1: "EX N. Nonce N \<notin> used evs"
by (rule Nonce_supply_lemma [THEN exE], blast)

lemma Nonce_supply: "Nonce (@ N. Nonce N \<notin> used evs) \<notin> used evs"
apply (rule Nonce_supply_lemma [THEN exE])
apply (rule someI, fast)
done

subsection{*Specialized Rewriting for Theorems About @{term analz} and Image*}

lemma insert_Key_singleton: "insert (Key K) H = Key ` {K} Un H"
by blast

lemma insert_Key_image: "insert (Key K) (Key`KK \<union> C) = Key ` (insert K KK) \<union> C"
by blast


lemma Crypt_imp_keysFor :"[|Crypt K X \<in> H; K \<in> symKeys|] ==> K \<in> keysFor H"
by (drule Crypt_imp_invKey_keysFor, simp)

text{*Lemma for the trivial direction of the if-and-only-if of the 
Session Key Compromise Theorem*}
lemma analz_image_freshK_lemma:
     "(Key K \<in> analz (Key`nE \<union> H)) --> (K \<in> nE | Key K \<in> analz H)  ==>  
         (Key K \<in> analz (Key`nE \<union> H)) = (K \<in> nE | Key K \<in> analz H)"
by (blast intro: analz_mono [THEN [2] rev_subsetD])

lemmas analz_image_freshK_simps =
       simp_thms mem_simps --{*these two allow its use with @{text "only:"}*}
       disj_comms 
       image_insert [THEN sym] image_Un [THEN sym] empty_subsetI insert_subset
       analz_insert_eq Un_upper2 [THEN analz_mono, THEN subsetD]
       insert_Key_singleton 
       Key_not_used insert_Key_image Un_assoc [THEN sym]

ML {*
structure Public =
struct

val analz_image_freshK_ss = @{simpset} delsimps [image_insert, image_Un]
  delsimps [@{thm imp_disjL}]    (*reduces blow-up*)
  addsimps @{thms analz_image_freshK_simps}

(*Tactic for possibility theorems*)
fun possibility_tac ctxt =
    REPEAT (*omit used_Says so that Nonces start from different traces!*)
    (ALLGOALS (simp_tac (simpset_of ctxt delsimps [@{thm used_Says}]))
     THEN
     REPEAT_FIRST (eq_assume_tac ORELSE' 
                   resolve_tac [refl, conjI, @{thm Nonce_supply}]))

(*For harder protocols (such as Recur) where we have to set up some
  nonces and keys initially*)
fun basic_possibility_tac ctxt =
    REPEAT 
    (ALLGOALS (asm_simp_tac (simpset_of ctxt setSolver safe_solver))
     THEN
     REPEAT_FIRST (resolve_tac [refl, conjI]))

end
*}

method_setup analz_freshK = {*
    Scan.succeed (fn ctxt =>
     (SIMPLE_METHOD
      (EVERY [REPEAT_FIRST (resolve_tac [allI, ballI, impI]),
          REPEAT_FIRST (rtac @{thm analz_image_freshK_lemma}),
          ALLGOALS (asm_simp_tac (Simplifier.context ctxt Public.analz_image_freshK_ss))]))) *}
    "for proving the Session Key Compromise theorem"


subsection{*Specialized Methods for Possibility Theorems*}

method_setup possibility = {*
    Scan.succeed (SIMPLE_METHOD o Public.possibility_tac) *}
    "for proving possibility theorems"

method_setup basic_possibility = {*
    Scan.succeed (SIMPLE_METHOD o Public.basic_possibility_tac) *}
    "for proving possibility theorems"

end
