(*  Title:      HOL/HOLCF/IOA/ABP/Packet.thy
    Author:     Olaf Müller
*)

header {* Packets *}

theory Packet
imports Main
begin

type_synonym
  'msg packet = "bool * 'msg"

definition
  hdr :: "'msg packet => bool" where
  "hdr = fst"

definition
  msg :: "'msg packet => 'msg" where
  "msg = snd"

end
