(*  Title:      HOL/HOLCF/IOA/NTP/Action.thy
    Author:     Tobias Nipkow & Konrad Slind
*)

header {* The set of all actions of the system *}

theory Action
imports Packet
begin

datatype 'm action = S_msg 'm | R_msg 'm
                   | S_pkt "'m packet" | R_pkt "'m packet"
                   | S_ack bool | R_ack bool
                   | C_m_s | C_m_r | C_r_s | C_r_r 'm

end
