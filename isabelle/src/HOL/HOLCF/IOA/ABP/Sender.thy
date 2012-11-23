(*  Title:      HOL/HOLCF/IOA/ABP/Sender.thy
    Author:     Olaf Müller
*)

header {* The implementation: sender *}

theory Sender
imports IOA Action Lemmas
begin

type_synonym
  'm sender_state = "'m list  *  bool"  -- {* messages, Alternating Bit *}

definition
  sq :: "'m sender_state => 'm list" where
  "sq = fst"

definition
  sbit :: "'m sender_state => bool" where
  "sbit = snd"

definition
  sender_asig :: "'m action signature" where
  "sender_asig = ((UN m. {S_msg(m)}) Un (UN b. {R_ack(b)}),
                   UN pkt. {S_pkt(pkt)},
                   {})"

definition
  sender_trans :: "('m action, 'm sender_state)transition set" where
  "sender_trans =
   {tr. let s = fst(tr);
            t = snd(snd(tr))
        in case fst(snd(tr))
        of
        Next     => if sq(s)=[] then t=s else False |
        S_msg(m) => sq(t)=sq(s)@[m]   &
                    sbit(t)=sbit(s)  |
        R_msg(m) => False |
        S_pkt(pkt) => sq(s) ~= []  &
                       hdr(pkt) = sbit(s)      &
                      msg(pkt) = hd(sq(s))    &
                      sq(t) = sq(s)           &
                      sbit(t) = sbit(s) |
        R_pkt(pkt) => False |
        S_ack(b)   => False |
        R_ack(b)   => if b = sbit(s) then
                       sq(t)=tl(sq(s)) & sbit(t)=(~sbit(s)) else
                       sq(t)=sq(s) & sbit(t)=sbit(s)}"
  
definition
  sender_ioa :: "('m action, 'm sender_state)ioa" where
  "sender_ioa =
   (sender_asig, {([],True)}, sender_trans,{},{})"

end
