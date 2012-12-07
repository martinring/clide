(* Authors: Gerwin Klein and Rafal Kolanski, 2012
   Maintainers: Gerwin Klein <kleing at cse.unsw.edu.au>
                Rafal Kolanski <rafal.kolanski at nicta.com.au>
*)

header "Separation Logic Tactics"

theory Sep_Tactics
imports Separation_Algebra
uses "sep_tactics.ML"
begin

text {* A number of proof methods to assist with reasoning about separation logic. *}


section {* Selection (move-to-front) tactics *}

ML {*
  fun sep_select_method n ctxt =
        Method.SIMPLE_METHOD' (sep_select_tac ctxt n);
  fun sep_select_asm_method n ctxt =
        Method.SIMPLE_METHOD' (sep_select_asm_tac ctxt n);
*}

method_setup sep_select = {*
  Scan.lift Parse.int >> sep_select_method
*} "Select nth separation conjunct in conclusion"

method_setup sep_select_asm = {*
  Scan.lift Parse.int >> sep_select_asm_method
*} "Select nth separation conjunct in assumptions"


section {* Substitution *}

ML {*
  fun sep_subst_method ctxt occs thms =
        SIMPLE_METHOD' (sep_subst_tac ctxt occs thms);
  fun sep_subst_asm_method ctxt occs thms =
        SIMPLE_METHOD' (sep_subst_asm_tac ctxt occs thms);

  val sep_subst_parser =
        Args.mode "asm"
        -- Scan.lift (Scan.optional (Args.parens (Scan.repeat Parse.nat)) [0])
        -- Attrib.thms;
*}

method_setup "sep_subst" = {*
  sep_subst_parser >>
    (fn ((asm, occs), thms) => fn ctxt =>
      (if asm then sep_subst_asm_method else sep_subst_method) ctxt occs thms)
*}
"single-step substitution after solving one separation logic assumption"


section {* Forward Reasoning *}

ML {*
  fun sep_drule_method thms ctxt = SIMPLE_METHOD' (sep_dtac ctxt thms);
  fun sep_frule_method thms ctxt = SIMPLE_METHOD' (sep_ftac ctxt thms);
*}

method_setup "sep_drule" = {*
  Attrib.thms >> sep_drule_method
*} "drule after separating conjunction reordering"

method_setup "sep_frule" = {*
  Attrib.thms >> sep_frule_method
*} "frule after separating conjunction reordering"


section {* Backward Reasoning *}

ML {*
  fun sep_rule_method thms ctxt = SIMPLE_METHOD' (sep_rtac ctxt thms)
*}

method_setup "sep_rule" = {*
  Attrib.thms >> sep_rule_method
*} "applies rule after separating conjunction reordering"


section {* Cancellation of Common Conjuncts via Elimination Rules *}

ML {*
  structure SepCancel_Rules = Named_Thms (
    val name = @{binding "sep_cancel"};
    val description = "sep_cancel rules";
  );
*}
setup SepCancel_Rules.setup

text {*
  The basic @{text sep_cancel_tac} is minimal. It only eliminates
  erule-derivable conjuncts between an assumption and the conclusion.

  To have a more useful tactic, we augment it with more logic, to proceed as
  follows:
  \begin{itemize}
  \item try discharge the goal first using @{text tac}
  \item if that fails, invoke @{text sep_cancel_tac}
  \item if @{text sep_cancel_tac} succeeds
    \begin{itemize}
    \item try to finish off with tac (but ok if that fails)
    \item try to finish off with @{term sep_true} (but ok if that fails)
    \end{itemize}
  \end{itemize}
  *}

ML {*
  fun sep_cancel_smart_tac ctxt tac =
    let fun TRY' tac = tac ORELSE' (K all_tac)
    in
      tac
      ORELSE' (sep_cancel_tac ctxt tac
               THEN' TRY' tac
               THEN' TRY' (rtac @{thm TrueI}))
      ORELSE' (etac @{thm sep_conj_sep_emptyE}
               THEN' sep_cancel_tac ctxt tac
               THEN' TRY' tac
               THEN' TRY' (rtac @{thm TrueI}))
    end;

  fun sep_cancel_smart_tac_rules ctxt etacs =
      sep_cancel_smart_tac ctxt (FIRST' ([atac] @ etacs));

  fun sep_cancel_method ctxt =
    let
      val etacs = map etac (SepCancel_Rules.get ctxt);
    in
      SIMPLE_METHOD' (sep_cancel_smart_tac_rules ctxt etacs)
    end;

  val sep_cancel_syntax = Method.sections [
    Args.add -- Args.colon >> K (I, SepCancel_Rules.add)];
*}

method_setup sep_cancel = {*
  sep_cancel_syntax >> K sep_cancel_method
*} "Separating conjunction conjunct cancellation"

text {*
  As above, but use blast with a depth limit to figure out where cancellation
  can be done. *}

ML {*
  fun sep_cancel_blast_method ctxt =
    let
      val rules = SepCancel_Rules.get ctxt;
      val tac = Blast.depth_tac (ctxt addIs rules) 10;
    in
      SIMPLE_METHOD' (sep_cancel_smart_tac ctxt tac)
    end;
*}

method_setup sep_cancel_blast = {*
  sep_cancel_syntax >> K sep_cancel_blast_method
*} "Separating conjunction conjunct cancellation using blast"

end
