(*  Title:      HOL/HOLCF/IOA/NTP/Packet.thy
    Author:     Tobias Nipkow & Konrad Slind
*)

theory Packet
imports Multiset
begin

type_synonym
  'msg packet = "bool * 'msg"

definition
  hdr :: "'msg packet => bool" where
  "hdr == fst"

definition
  msg :: "'msg packet => 'msg" where
  "msg == snd"


text {* Instantiation of a tautology? *}
lemma eq_packet_imp_eq_hdr: "!x. x = packet --> hdr(x) = hdr(packet)"
  by simp

declare hdr_def [simp] msg_def [simp]

end
