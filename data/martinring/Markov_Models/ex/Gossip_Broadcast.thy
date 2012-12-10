(* Author: Johannes Hölzl <hoelzl@in.tum.de> *)

header {* Formalization of the Gossip-Broadcast *}

theory Gossip_Broadcast
  imports "../Rewarded_DTMC"
begin

lemma setsum_folded_product:
  fixes I :: "'i set" and f :: "'s \<Rightarrow> 'i \<Rightarrow> 'a::{semiring_0, comm_monoid_mult}"
  assumes "finite I" "\<And>i. i \<in> I \<Longrightarrow> finite (S i)"
  shows "(\<Sum>x\<in>Pi\<^isub>E I S. \<Prod>i\<in>I. f (x i) i) = (\<Prod>i\<in>I. \<Sum>s\<in>S i. f s i)"
using assms proof (induct I)
  case empty then show ?case by simp
next
  case (insert i I)
  have *: "Pi\<^isub>E (insert i I) S = (\<lambda>(x, f). f(i := x)) ` (S i \<times> Pi\<^isub>E I S)"
    by (auto intro!: image_eqI ext[where 'a='i] dest: extensional_arb)
  have "(\<Sum>x\<in>Pi\<^isub>E (insert i I) S. \<Prod>i\<in>insert i I. f (x i) i) = 
    setsum ((\<lambda>x. \<Prod>i\<in>insert i I. f (x i) i) \<circ> ((\<lambda>(x, f). f(i := x)))) (S i \<times> Pi\<^isub>E I S)"
    unfolding * using insert by (intro setsum_reindex) (auto intro!: inj_on_upd_PiE)
  also have "\<dots> = (\<Sum>(a, x)\<in>(S i \<times> Pi\<^isub>E I S). f a i * (\<Prod>i\<in>I. f (x i) i))"
    using insert by (force intro!: setsum_cong setprod_cong arg_cong2[where f="op *"])
  also have "\<dots> = (\<Sum>a\<in>S i. f a i * (\<Sum>x\<in>Pi\<^isub>E I S. \<Prod>i\<in>I. f (x i) i))"
    by (simp add: setsum_cartesian_product setsum_right_distrib)
  finally show ?case
    using insert by (simp add: setsum_left_distrib)
qed

subsection {* Definition of the Gossip-Broadcast *}

datatype state = listening | sending | sleeping

lemma state_UNIV: "UNIV = {listening, sending, sleeping}"
  by (auto intro: state.exhaust)

locale gossip_broadcast =
  fixes size :: nat and p :: real
  assumes size: "0 < size"
  assumes p: "0 < p" "p < 1"
begin

definition
  "states = ({..< size} \<times> {..< size}) \<rightarrow>\<^isub>E {listening, sending, sleeping}"

definition "start = (\<lambda>x\<in>{..< size}\<times>{..< size}. listening)((0, 0) := sending)"

definition
  "neighbour_sending s = (\<lambda>(x,y).
    (x > 0 \<and> s (x - 1, y) = sending) \<or>
    (x < size \<and> s (x + 1, y) = sending) \<or>
    (y > 0 \<and> s (x, y - 1) = sending) \<or>
    (y < size \<and> s (x, y + 1) = sending))"

definition node_trans :: "((nat \<times> nat) \<Rightarrow> state) \<Rightarrow> (nat \<times> nat) \<Rightarrow> state \<Rightarrow> state \<Rightarrow> real" where
"node_trans g x s = (case s of
  listening \<Rightarrow> (if neighbour_sending g x
    then (\<lambda>_.0) (sending := p, sleeping := 1 - p)
    else (\<lambda>_.0) (listening := 1))
| sending   \<Rightarrow> (\<lambda>_.0) (sleeping := 1)
| sleeping  \<Rightarrow> (\<lambda>_.0) (sleeping := 1))"

definition "proto_trans s s' =
  (\<Prod>x\<in>{..< size}\<times>{..< size}. node_trans s x (s x) (s' x))"

lemma node_trans_sum_eq_1:
  "node_trans g x s' listening + (node_trans g x s' sending + node_trans g x s' sleeping) = 1"
  by (simp add: node_trans_def split: state.split)

end

subsection {* The Gossip-Broadcast forms a DTMC *}

sublocale gossip_broadcast \<subseteq> Discrete_Time_Markov_Chain states proto_trans start
proof
  show "finite states"
    by (simp add: states_def)
  show "start \<in> states"
    using size by (auto simp: extensional_def start_def states_def)
next
  fix s s' assume "s \<in> states" "s' \<in> states"
  with p show "0 \<le> proto_trans s s'"
    unfolding proto_trans_def node_trans_def
    by (auto intro!: setprod_nonneg split: state.split)
next
  fix s assume "s \<in> states"
  show "(\<Sum>s'\<in>states. proto_trans s s') = 1"
    unfolding proto_trans_def states_def
    by (subst setsum_folded_product) (simp_all add: node_trans_sum_eq_1 setprod_1)
qed

end
