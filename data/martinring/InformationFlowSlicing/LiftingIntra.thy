header {* \isaheader{Framework Graph Lifting for Noninterference} *}

theory LiftingIntra 
  imports NonInterferenceIntra "../Slicing/StaticIntra/CDepInstantiations" 
begin

text {* In this section, we show how a valid CFG from the slicing framework in
\cite{Wasserrab:08} can be lifted to fulfil all properties of the 
@{text "NonInterferenceIntraGraph"} locale. Basically, we redefine the
hitherto existing @{text Entry} and @{text Exit} nodes as new
@{text High} and @{text Low} nodes, and introduce two new nodes
@{text NewEntry} and @{text NewExit}. Then, we have to lift all functions
to operate on this new graph. *}

subsection {* Liftings *}

subsubsection {* The datatypes *}

datatype 'node LDCFG_node = Node 'node
  | NewEntry
  | NewExit


type_synonym ('edge,'node,'state) LDCFG_edge = 
  "'node LDCFG_node \<times> ('state edge_kind) \<times> 'node LDCFG_node"


subsubsection {* Lifting @{term valid_edge} *}

inductive lift_valid_edge :: "('edge \<Rightarrow> bool) \<Rightarrow> ('edge \<Rightarrow> 'node) \<Rightarrow> ('edge \<Rightarrow> 'node) \<Rightarrow>
  ('edge \<Rightarrow> 'state edge_kind) \<Rightarrow> 'node \<Rightarrow> 'node \<Rightarrow> ('edge,'node,'state) LDCFG_edge \<Rightarrow> 
  bool"
for valid_edge::"'edge \<Rightarrow> bool" and src::"'edge \<Rightarrow> 'node" and trg::"'edge \<Rightarrow> 'node" 
  and knd::"'edge \<Rightarrow> 'state edge_kind" and E::'node and X::'node

where lve_edge:
  "\<lbrakk>valid_edge a; src a \<noteq> E \<or> trg a \<noteq> X; 
    e = (Node (src a),knd a,Node (trg a))\<rbrakk>
  \<Longrightarrow> lift_valid_edge valid_edge src trg knd E X e"

  | lve_Entry_edge:
  "e = (NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node E) 
  \<Longrightarrow> lift_valid_edge valid_edge src trg knd E X e"

  | lve_Exit_edge:
  "e = (Node X,(\<lambda>s. True)\<^isub>\<surd>,NewExit) 
  \<Longrightarrow> lift_valid_edge valid_edge src trg knd E X e"

  | lve_Entry_Exit_edge:
  "e = (NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit) 
  \<Longrightarrow> lift_valid_edge valid_edge src trg knd E X e"


lemma [simp]:"\<not> lift_valid_edge valid_edge src trg knd E X (Node E,et,Node X)"
by(auto elim:lift_valid_edge.cases)


subsubsection {* Lifting @{term Def} and @{term Use} sets *}

inductive_set lift_Def_set :: "('node \<Rightarrow> 'var set) \<Rightarrow> 'node \<Rightarrow> 'node \<Rightarrow> 
                       'var set \<Rightarrow> 'var set \<Rightarrow> ('node LDCFG_node \<times> 'var) set"
for Def::"('node \<Rightarrow> 'var set)" and E::'node and X::'node 
  and H::"'var set" and L::"'var set"

where lift_Def_node: 
  "V \<in> Def n \<Longrightarrow> (Node n,V) \<in> lift_Def_set Def E X H L"

  | lift_Def_High:
  "V \<in> H \<Longrightarrow> (Node E,V) \<in> lift_Def_set Def E X H L"

abbreviation lift_Def :: "('node \<Rightarrow> 'var set) \<Rightarrow> 'node \<Rightarrow> 'node \<Rightarrow> 
                       'var set \<Rightarrow> 'var set \<Rightarrow> 'node LDCFG_node \<Rightarrow> 'var set"
  where "lift_Def Def E X H L n \<equiv> {V. (n,V) \<in> lift_Def_set Def E X H L}"


inductive_set lift_Use_set :: "('node \<Rightarrow> 'var set) \<Rightarrow> 'node \<Rightarrow> 'node \<Rightarrow> 
                       'var set \<Rightarrow> 'var set \<Rightarrow> ('node LDCFG_node \<times> 'var) set"
for Use::"'node \<Rightarrow> 'var set" and E::'node and X::'node 
  and H::"'var set" and L::"'var set"

where 
  lift_Use_node: 
  "V \<in> Use n \<Longrightarrow> (Node n,V) \<in> lift_Use_set Use E X H L"

  | lift_Use_High:
  "V \<in> H \<Longrightarrow> (Node E,V) \<in> lift_Use_set Use E X H L"

  | lift_Use_Low:
  "V \<in> L \<Longrightarrow> (Node X,V) \<in> lift_Use_set Use E X H L"


abbreviation lift_Use :: "('node \<Rightarrow> 'var set) \<Rightarrow> 'node \<Rightarrow> 'node \<Rightarrow> 
                       'var set \<Rightarrow> 'var set \<Rightarrow> 'node LDCFG_node \<Rightarrow> 'var set"
  where "lift_Use Use E X H L n \<equiv> {V. (n,V) \<in> lift_Use_set Use E X H L}"



subsection {* The lifting lemmas *}

subsubsection {* Lifting the basic locales *}


abbreviation src :: "('edge,'node,'state) LDCFG_edge \<Rightarrow> 'node LDCFG_node"
  where "src a \<equiv> fst a"

abbreviation trg :: "('edge,'node,'state) LDCFG_edge \<Rightarrow> 'node LDCFG_node"
  where "trg a \<equiv> snd(snd a)"

definition knd :: "('edge,'node,'state) LDCFG_edge \<Rightarrow> 'state edge_kind"
  where "knd a \<equiv> fst(snd a)"


lemma lift_CFG:
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  shows "CFG src trg
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry"
proof -
  interpret CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                       state_val Exit
    by(rule wf)
  show ?thesis 
  proof
    fix a assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "trg a = NewEntry"
    thus False by(fastforce elim:lift_valid_edge.cases)
  next
    fix a a' 
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'"
      and "src a = src a'" and "trg a = trg a'"
    thus "a = a'"
    proof(induct rule:lift_valid_edge.induct)
      case lve_edge thus ?case by -(erule lift_valid_edge.cases,auto dest:edge_det)
    qed(auto elim:lift_valid_edge.cases)
  qed
qed


lemma lift_CFG_wf:
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  shows "CFG_wf src trg knd 
         (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
         (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val"
proof -
  interpret CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                       state_val Exit
    by(rule wf)
  interpret CFG:CFG src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit" NewEntry
    by(fastforce intro:lift_CFG wf)
  show ?thesis
  proof
    show "lift_Def Def Entry Exit H L NewEntry = {} \<and>
          lift_Use Use Entry Exit H L NewEntry = {}"
      by(fastforce elim:lift_Use_set.cases lift_Def_set.cases)
  next
    fix a V s 
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "V \<notin> lift_Def Def Entry Exit H L (src a)" and "pred (knd a) s"
    thus "state_val (transfer (knd a) s) V = state_val s V"
    proof(induct rule:lift_valid_edge.induct)
      case lve_edge
      thus ?case by(fastforce intro:CFG_edge_no_Def_equal dest:lift_Def_node[of _ Def]
        simp:knd_def)
    qed(auto simp:knd_def)
  next
    fix a s s'
    assume assms:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      "\<forall>V\<in>lift_Use Use Entry Exit H L (src a). state_val s V = state_val s' V"
      "pred (knd a) s" "pred (knd a) s'"
    show "\<forall>V\<in>lift_Def Def Entry Exit H L (src a).
             state_val (transfer (knd a) s) V = state_val (transfer (knd a) s') V"
    proof
      fix V assume "V \<in> lift_Def Def Entry Exit H L (src a)"
      with assms
      show "state_val (transfer (knd a) s) V = state_val (transfer (knd a) s') V"
      proof(induct rule:lift_valid_edge.induct)
        case (lve_edge a e)
        show ?case
        proof (cases "Node (sourcenode a) = Node Entry")
          case True
          hence "sourcenode a = Entry" by simp
          from Entry_Exit_edge obtain a' where "valid_edge a'"
            and "sourcenode a' = Entry" and "targetnode a' = Exit"
            and "kind a' = (\<lambda>s. False)\<^isub>\<surd>" by blast
          have "\<exists>Q. kind a = (Q)\<^isub>\<surd>"
          proof(cases "targetnode a = Exit")
            case True
            with `valid_edge a` `valid_edge a'` `sourcenode a = Entry`
              `sourcenode a' = Entry` `targetnode a' = Exit`
            have "a = a'" by(fastforce dest:edge_det)
            with `kind a' = (\<lambda>s. False)\<^isub>\<surd>` show ?thesis by simp
          next
            case False
            with `valid_edge a` `valid_edge a'` `sourcenode a = Entry`
              `sourcenode a' = Entry` `targetnode a' = Exit`
            show ?thesis by(auto dest:deterministic)
          qed
          from True `V \<in> lift_Def Def Entry Exit H L (src e)` Entry_empty
            `e = (Node (sourcenode a), kind a, Node (targetnode a))`
          have "V \<in> H" by(fastforce elim:lift_Def_set.cases)
          from True `e = (Node (sourcenode a), kind a, Node (targetnode a))`
            `sourcenode a \<noteq> Entry \<or> targetnode a \<noteq> Exit`
          have "\<forall>V\<in>H. V \<in> lift_Use Use Entry Exit H L (src e)"
            by(fastforce intro:lift_Use_High)
          with `\<forall>V\<in>lift_Use Use Entry Exit H L (src e). 
                            state_val s V = state_val s' V` `V \<in> H`
          have "state_val s V = state_val s' V" by simp
          with `e = (Node (sourcenode a), kind a, Node (targetnode a))` 
            `\<exists>Q. kind a = (Q)\<^isub>\<surd>`
          show ?thesis by(fastforce simp:knd_def)
        next
          case False
          { fix V' assume "V' \<in> Use (sourcenode a)"
            with `e = (Node (sourcenode a), kind a, Node (targetnode a))`
            have "V' \<in> lift_Use Use Entry Exit H L (src e)"
              by(fastforce intro:lift_Use_node)
          }
          with `\<forall>V\<in>lift_Use Use Entry Exit H L (src e). 
                            state_val s V = state_val s' V`
          have "\<forall>V\<in>Use (sourcenode a). state_val s V = state_val s' V"
            by fastforce
          from `valid_edge a` this `pred (knd e) s` `pred (knd e) s'`
            `e = (Node (sourcenode a), kind a, Node (targetnode a))`
          have "\<forall>V \<in> Def (sourcenode a). state_val (transfer (kind a) s) V =
            state_val (transfer (kind a) s') V"
            by -(erule CFG_edge_transfer_uses_only_Use,auto simp:knd_def)
          from `V \<in> lift_Def Def Entry Exit H L (src e)` False
            `e = (Node (sourcenode a), kind a, Node (targetnode a))`
          have "V \<in> Def (sourcenode a)" by(fastforce elim:lift_Def_set.cases)
          with `\<forall>V \<in> Def (sourcenode a). state_val (transfer (kind a) s) V =
            state_val (transfer (kind a) s') V`
            `e = (Node (sourcenode a), kind a, Node (targetnode a))`
          show ?thesis by(simp add:knd_def)
        qed
      next
        case (lve_Entry_edge e)
        from `V \<in> lift_Def Def Entry Exit H L (src e)` 
          `e = (NewEntry, (\<lambda>s. True)\<^isub>\<surd>, Node Entry)`
        have False by(fastforce elim:lift_Def_set.cases)
        thus ?case by simp
      next
        case (lve_Exit_edge e)
        from `V \<in> lift_Def Def Entry Exit H L (src e)` 
          `e = (Node Exit, (\<lambda>s. True)\<^isub>\<surd>, NewExit)`
        have False
          by(fastforce elim:lift_Def_set.cases intro!:Entry_noteq_Exit simp:Exit_empty)
        thus ?case  by simp
      qed(simp add:knd_def)
    qed
  next
    fix a s s'
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "pred (knd a) s" 
      and "\<forall>V\<in>lift_Use Use Entry Exit H L (src a). state_val s V = state_val s' V"
    thus "pred (knd a) s'"
      by(induct rule:lift_valid_edge.induct,
         auto elim!:CFG_edge_Uses_pred_equal dest:lift_Use_node simp:knd_def)
  next
    fix a a'
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'"
      and "src a = src a'" and "trg a \<noteq> trg a'"
    thus "\<exists>Q Q'. knd a = (Q)\<^isub>\<surd> \<and> knd a' = (Q')\<^isub>\<surd> \<and> 
                 (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))"
    proof(induct rule:lift_valid_edge.induct)
      case (lve_edge a e)
      from `lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'`
        `valid_edge a` `e = (Node (sourcenode a), kind a, Node (targetnode a))`
        `src e = src a'` `trg e \<noteq> trg a'`
      show ?case
      proof(induct rule:lift_valid_edge.induct)
        case lve_edge thus ?case by(auto dest:deterministic simp:knd_def)
      next
        case (lve_Exit_edge e')
        from `e = (Node (sourcenode a), kind a, Node (targetnode a))`
          `e' = (Node Exit, (\<lambda>s. True)\<^isub>\<surd>, NewExit)` `src e = src e'`
        have "sourcenode a = Exit" by simp
        with `valid_edge a` have False by(rule Exit_source)
        thus ?case by simp
      qed auto
    qed (fastforce elim:lift_valid_edge.cases simp:knd_def)+
  qed
qed


lemma lift_CFGExit:
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  shows "CFGExit src trg knd 
         (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
         NewEntry NewExit"
proof -
  interpret CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                       state_val Exit
    by(rule wf)
  interpret CFG:CFG src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit" NewEntry
    by(fastforce intro:lift_CFG wf)
  show ?thesis
  proof
    fix a assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "src a = NewExit"
    thus False by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Entry_Exit_edge
    show "\<exists>a. lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a \<and>
              src a = NewEntry \<and> trg a = NewExit \<and> knd a = (\<lambda>s. False)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  qed
qed


lemma lift_CFGExit_wf:
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  shows "CFGExit_wf src trg knd 
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
        (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val NewExit"
proof -
  interpret CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                       state_val Exit
    by(rule wf)
  interpret CFGExit:CFGExit src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit" 
    NewEntry NewExit
    by(fastforce intro:lift_CFGExit wf)
  interpret CFG_wf:CFG_wf src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit" 
    NewEntry "lift_Def Def Entry Exit H L" "lift_Use Use Entry Exit H L" state_val
    by(fastforce intro:lift_CFG_wf wf)
  show ?thesis
  proof
    show "lift_Def Def Entry Exit H L NewExit = {} \<and>
          lift_Use Use Entry Exit H L NewExit = {}"
      by(fastforce elim:lift_Use_set.cases lift_Def_set.cases)
  qed
qed



subsubsection {* Lifting @{term wod_backward_slice} *}

lemma lift_wod_backward_slice:
  fixes valid_edge and sourcenode and targetnode and kind and Entry and Exit
  and Def and Use and H and L
  defines lve:"lve \<equiv> lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit"
  and lDef:"lDef \<equiv> lift_Def Def Entry Exit H L" 
  and lUse:"lUse \<equiv> lift_Use Use Entry Exit H L"
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  and "H \<inter> L = {}" and "H \<union> L = UNIV"
  shows "NonInterferenceIntraGraph src trg knd lve NewEntry lDef lUse state_val 
         (CFG_wf.wod_backward_slice src trg lve lDef lUse)
         NewExit H L (Node Entry) (Node Exit)"
proof -
  interpret CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                       state_val Exit
    by(rule wf)
  interpret CFGExit_wf:
    CFGExit_wf src trg knd lve NewEntry lDef lUse state_val NewExit
    by(fastforce intro:lift_CFGExit_wf wf simp:lve lDef lUse)
  from wf lve have CFG:"CFG src trg lve NewEntry"
    by(fastforce intro:lift_CFG)
  from wf lve lDef lUse have CFG_wf:"CFG_wf src trg knd lve NewEntry
    lDef lUse state_val"
    by(fastforce intro:lift_CFG_wf)
  show ?thesis
  proof
    fix n S
    assume "n \<in> CFG_wf.wod_backward_slice src trg lve lDef lUse S"
    with CFG_wf show "CFG.valid_node src trg lve n"
      by -(rule CFG_wf.wod_backward_slice_valid_node)
  next
    fix n S assume "CFG.valid_node src trg lve n" and "n \<in> S"
    with CFG_wf show "n \<in> CFG_wf.wod_backward_slice src trg lve lDef lUse S"
      by -(rule CFG_wf.refl)
  next
    fix n' S n V
    assume "n' \<in> CFG_wf.wod_backward_slice src trg lve lDef lUse S"
      and "CFG_wf.data_dependence src trg lve lDef lUse n V n'"
    with CFG_wf show "n \<in> CFG_wf.wod_backward_slice src trg lve lDef lUse S"
      by -(rule CFG_wf.dd_closed)
  next
    fix n S
    from CFG_wf 
    have "(\<exists>m. (CFG.obs src trg lve n
        (CFG_wf.wod_backward_slice src trg lve lDef lUse S)) = {m}) \<or>
      CFG.obs src trg lve n (CFG_wf.wod_backward_slice src trg lve lDef lUse S) = {}"
      by(rule CFG_wf.obs_singleton)
    thus "finite 
      (CFG.obs src trg lve n (CFG_wf.wod_backward_slice src trg lve lDef lUse S))"
      by fastforce
  next
    fix n S
    from CFG_wf 
    have "(\<exists>m. (CFG.obs src trg lve n
        (CFG_wf.wod_backward_slice src trg lve lDef lUse S)) = {m}) \<or>
      CFG.obs src trg lve n (CFG_wf.wod_backward_slice src trg lve lDef lUse S) = {}"
      by(rule CFG_wf.obs_singleton)
    thus "card (CFG.obs src trg lve n
                        (CFG_wf.wod_backward_slice src trg lve lDef lUse S)) \<le> 1"
      by fastforce
  next
    fix a assume "lve a" and "src a = NewEntry"
    with lve show "trg a = NewExit \<or> trg a = Node Entry"
      by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Entry_edge lve
    show "\<exists>a. lve a \<and> src a = NewEntry \<and> trg a = Node Entry \<and> knd a = (\<lambda>s. True)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  next
    fix a assume "lve a" and "trg a = Node Entry"
    with lve show "src a = NewEntry" by(fastforce elim:lift_valid_edge.cases)
  next
    fix a assume "lve a" and "trg a = NewExit"
    with lve show "src a = NewEntry \<or> src a = Node Exit"
      by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Exit_edge lve
    show "\<exists>a. lve a \<and> src a = Node Exit \<and> trg a = NewExit \<and> knd a = (\<lambda>s. True)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  next
    fix a assume "lve a" and "src a = Node Exit"
    with lve show "trg a = NewExit" by(fastforce elim:lift_valid_edge.cases)
  next
    from lDef show "lDef (Node Entry) = H"
      by(fastforce elim:lift_Def_set.cases intro:lift_Def_High)
  next
    from Entry_noteq_Exit lUse show "lUse (Node Entry) = H"
      by(fastforce elim:lift_Use_set.cases intro:lift_Use_High)
  next
    from Entry_noteq_Exit lUse show "lUse (Node Exit) = L"
      by(fastforce elim:lift_Use_set.cases intro:lift_Use_Low)
  next
    from `H \<inter> L = {}` show "H \<inter> L = {}" .
  next
    from `H \<union> L = UNIV` show "H \<union> L = UNIV" .
  qed
qed


subsubsection {* Lifting @{text PDG_BS} with @{text standard_control_dependence} *}

lemma lift_Postdomination:
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  and pd:"Postdomination sourcenode targetnode kind valid_edge Entry Exit"
  and inner:"CFGExit.inner_node sourcenode targetnode valid_edge Entry Exit nx"
  shows "Postdomination src trg knd
  (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry NewExit"
proof -
  interpret Postdomination sourcenode targetnode kind valid_edge Entry Exit
    by(rule pd)
  interpret CFGExit_wf:CFGExit_wf src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit" NewEntry
    "lift_Def Def Entry Exit H L" "lift_Use Use Entry Exit H L" state_val NewExit
    by(fastforce intro:lift_CFGExit_wf wf)
  from wf have CFG:"CFG src trg
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry"
    by(rule lift_CFG)
  show ?thesis
  proof
    fix n assume "CFG.valid_node src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) n"
    show "\<exists>as. CFG.path src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
      NewEntry as n"
    proof(cases n)
      case NewEntry
      have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
        (NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Entry_Exit_edge)
      with NewEntry have "CFG.path src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
        NewEntry [] n"
        by(fastforce intro:CFG.empty_path[OF CFG] simp:CFG.valid_node_def[OF CFG])
      thus ?thesis by blast
    next
      case NewExit
      have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
        (NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Entry_Exit_edge)
      with NewExit have "CFG.path src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
        NewEntry [(NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit)] n"
        by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                     simp:CFG.valid_node_def[OF CFG])
      thus ?thesis by blast
    next
      case (Node m)
      with Entry_Exit_edge `CFG.valid_node src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) n`
      have "valid_node m" 
        by(auto elim:lift_valid_edge.cases 
                simp:CFG.valid_node_def[OF CFG] valid_node_def)
      thus ?thesis
      proof(cases m rule:valid_node_cases)
        case Entry
        have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node Entry)" by(fastforce intro:lve_Entry_edge)
        with Entry Node have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          NewEntry [(NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node Entry)] n"
          by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                       simp:CFG.valid_node_def[OF CFG])
        thus ?thesis by blast
      next
        case Exit
        from inner obtain ax where "valid_edge ax" and "inner_node (sourcenode ax)"
          and "targetnode ax = Exit" by(erule inner_node_Exit_edge)
        hence "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (Node (sourcenode ax),kind ax,Node Exit)"
          by(auto intro:lift_valid_edge.lve_edge simp:inner_node_def)
        hence path:"CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node (sourcenode ax)) [(Node (sourcenode ax),kind ax,Node Exit)] 
          (Node Exit)"
          by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                       simp:CFG.valid_node_def[OF CFG])
        have edge:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node Entry)" by(fastforce intro:lve_Entry_edge)
        from `inner_node (sourcenode ax)` have "valid_node (sourcenode ax)"
          by(rule inner_is_valid)
        then obtain asx where "Entry -asx\<rightarrow>* sourcenode ax"
          by(fastforce dest:Entry_path)
        from this `valid_edge ax` have "\<exists>es. CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) es (Node (sourcenode ax))"
        proof(induct asx arbitrary:ax rule:rev_induct)
          case Nil
          from `Entry -[]\<rightarrow>* sourcenode ax` have "sourcenode ax = Entry" by fastforce
          hence "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node Entry) [] (Node (sourcenode ax))"
            apply simp apply(rule CFG.empty_path[OF CFG])
            by(auto intro:lve_Entry_edge simp:CFG.valid_node_def[OF CFG])
          thus ?case by blast
        next
          case (snoc x xs)
          note IH = `\<And>ax. \<lbrakk>Entry -xs\<rightarrow>* sourcenode ax; valid_edge ax\<rbrakk> \<Longrightarrow>
            \<exists>es. CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node Entry) es (Node (sourcenode ax))`
          from `Entry -xs@[x]\<rightarrow>* sourcenode ax`
          have "Entry -xs\<rightarrow>* sourcenode x" and "valid_edge x"
            and "targetnode x = sourcenode ax" by(auto elim:path_split_snoc)
          { assume "targetnode x = Exit"
            with `valid_edge ax` `targetnode x = sourcenode ax`
            have False by -(rule Exit_source,simp+) }
          hence "targetnode x \<noteq> Exit" by clarsimp
          with `valid_edge x` `targetnode x = sourcenode ax`[THEN sym]
          have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
            (Node (sourcenode x),kind x,Node (sourcenode ax))"
            by(fastforce intro:lift_valid_edge.lve_edge)
          hence path:"CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node (sourcenode x)) [(Node (sourcenode x),kind x,Node (sourcenode ax))] 
            (Node (sourcenode ax))"
            by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                         simp:CFG.valid_node_def[OF CFG])
          from IH[OF `Entry -xs\<rightarrow>* sourcenode x` `valid_edge x`] obtain es
            where "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node Entry) es (Node (sourcenode x))" by blast
          with path have "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node Entry) (es@[(Node (sourcenode x),kind x,Node (sourcenode ax))])
            (Node (sourcenode ax))"
            by -(rule CFG.path_Append[OF CFG])
          thus ?case by blast
        qed
        then obtain es where "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) es (Node (sourcenode ax))" by blast
        with path have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) (es@ [(Node (sourcenode ax),kind ax,Node Exit)]) (Node Exit)"
          by -(rule CFG.path_Append[OF CFG])
        with edge have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          NewEntry ((NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node Entry)#
                      (es@ [(Node (sourcenode ax),kind ax,Node Exit)])) (Node Exit)"
          by(fastforce intro:CFG.Cons_path[OF CFG])
        with Node Exit show ?thesis by fastforce
      next
        case inner
        from `valid_node m` obtain as where "Entry -as\<rightarrow>* m"
          by(fastforce dest:Entry_path)
        with inner have "\<exists>es. CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) es (Node m)"
        proof(induct arbitrary:m rule:rev_induct)
          case Nil
          from `Entry -[]\<rightarrow>* m`
          have "m = Entry" by fastforce
          with lve_Entry_edge have "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node Entry) [] (Node m)"
            by(fastforce intro:CFG.empty_path[OF CFG] simp:CFG.valid_node_def[OF CFG])
          thus ?case by blast
        next
          case (snoc x xs)
          note IH = `\<And>m. \<lbrakk>inner_node m; Entry -xs\<rightarrow>* m\<rbrakk>
            \<Longrightarrow> \<exists>es. CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node Entry) es (Node m)`
          from `Entry -xs@[x]\<rightarrow>* m` have "Entry -xs\<rightarrow>* sourcenode x"
            and "valid_edge x" and "m = targetnode x" by(auto elim:path_split_snoc)
          with `inner_node m`
          have edge:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
            (Node (sourcenode x),kind x,Node m)"
            by(fastforce intro:lve_edge simp:inner_node_def)
          hence path:"CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node (sourcenode x)) [(Node (sourcenode x),kind x,Node m)] (Node m)"
            by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                         simp:CFG.valid_node_def[OF CFG])
          from `valid_edge x` have "valid_node (sourcenode x)" by simp
          thus ?case
          proof(cases "sourcenode x" rule:valid_node_cases)
            case Entry
            with edge have "CFG.path src trg
              (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
              (Node Entry) [(Node Entry,kind x,Node m)] (Node m)"
              apply - apply(rule CFG.Cons_path[OF CFG])
              apply(rule CFG.empty_path[OF CFG]) 
              by(auto simp:CFG.valid_node_def[OF CFG])
            thus ?thesis by blast
          next
            case Exit
            with `valid_edge x` have False by(rule Exit_source)
            thus ?thesis by simp
          next
            case inner
            from IH[OF this `Entry -xs\<rightarrow>* sourcenode x`] obtain es 
              where "CFG.path src trg
              (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
              (Node Entry) es (Node (sourcenode x))" by blast
            with path have "CFG.path src trg
              (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
              (Node Entry) (es@[(Node (sourcenode x),kind x,Node m)]) (Node m)"
              by -(rule CFG.path_Append[OF CFG])
            thus ?thesis by blast
          qed
        qed
        then obtain es where path:"CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) es (Node m)" by blast
        have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node Entry)" by(fastforce intro:lve_Entry_edge)
        from this path Node have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          NewEntry ((NewEntry,(\<lambda>s. True)\<^isub>\<surd>,Node Entry)#es) n"
          by(fastforce intro:CFG.Cons_path[OF CFG])
        thus ?thesis by blast
      qed
    qed
  next
    fix n assume "CFG.valid_node src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) n"
    show "\<exists>as. CFG.path src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
      n as NewExit"
    proof(cases n)
      case NewEntry
      have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
        (NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Entry_Exit_edge)
      with NewEntry have "CFG.path src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
        n [(NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit)] NewExit"
        by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                     simp:CFG.valid_node_def[OF CFG])
      thus ?thesis by blast
    next
      case NewExit
      have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
        (NewEntry,(\<lambda>s. False)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Entry_Exit_edge)
      with NewExit have "CFG.path src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
        n [] NewExit"
        by(fastforce intro:CFG.empty_path[OF CFG] simp:CFG.valid_node_def[OF CFG])
      thus ?thesis by blast
    next
      case (Node m)
      with Entry_Exit_edge `CFG.valid_node src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) n`
      have "valid_node m" 
        by(auto elim:lift_valid_edge.cases 
                simp:CFG.valid_node_def[OF CFG] valid_node_def)
      thus ?thesis
      proof(cases m rule:valid_node_cases)
        case Entry
        from inner obtain ax where "valid_edge ax" and "inner_node (targetnode ax)"
          and "sourcenode ax = Entry" by(erule inner_node_Entry_edge)
        hence edge:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (Node Entry,kind ax,Node (targetnode ax))"
          by(auto intro:lift_valid_edge.lve_edge simp:inner_node_def)
        have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (Node Exit,(\<lambda>s. True)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Exit_edge)
        hence path:"CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Exit) [(Node Exit,(\<lambda>s. True)\<^isub>\<surd>,NewExit)] (NewExit)"
          by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                       simp:CFG.valid_node_def[OF CFG])
        from `inner_node (targetnode ax)` have "valid_node (targetnode ax)"
          by(rule inner_is_valid)
        then obtain asx where "targetnode ax -asx\<rightarrow>* Exit" by(fastforce dest:Exit_path)
        from this `valid_edge ax` have "\<exists>es. CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node (targetnode ax)) es (Node Exit)"
        proof(induct asx arbitrary:ax)
          case Nil
          from `targetnode ax -[]\<rightarrow>* Exit` have "targetnode ax = Exit" by fastforce
          hence "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node (targetnode ax)) [] (Node Exit)"
            apply simp apply(rule CFG.empty_path[OF CFG])
            by(auto intro:lve_Exit_edge simp:CFG.valid_node_def[OF CFG])
          thus ?case by blast
        next
          case (Cons x xs)
          note IH = `\<And>ax. \<lbrakk>targetnode ax -xs\<rightarrow>* Exit; valid_edge ax\<rbrakk> \<Longrightarrow>
            \<exists>es. CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node (targetnode ax)) es (Node Exit)`
          from `targetnode ax -x#xs\<rightarrow>* Exit`
          have "targetnode x -xs\<rightarrow>* Exit" and "valid_edge x"
            and "sourcenode x = targetnode ax" by(auto elim:path_split_Cons)
          { assume "sourcenode x = Entry"
            with `valid_edge ax` `sourcenode x = targetnode ax`
            have False by -(rule Entry_target,simp+) }
          hence "sourcenode x \<noteq> Entry" by clarsimp
          with `valid_edge x` `sourcenode x = targetnode ax`[THEN sym]
          have edge:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
            (Node (targetnode ax),kind x,Node (targetnode x))"
            by(fastforce intro:lift_valid_edge.lve_edge)
          from IH[OF `targetnode x -xs\<rightarrow>* Exit` `valid_edge x`] obtain es
            where "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node (targetnode x)) es (Node Exit)" by blast
          with edge have "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node (targetnode ax)) 
            ((Node (targetnode ax),kind x,Node (targetnode x))#es) (Node Exit)"
            by(fastforce intro:CFG.Cons_path[OF CFG])
          thus ?case by blast
        qed
        then obtain es where "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node (targetnode ax)) es (Node Exit)" by blast
        with edge have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) ((Node Entry, kind ax, Node (targetnode ax))#es) (Node Exit)"
          by(fastforce intro:CFG.Cons_path[OF CFG])
        with path have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Entry) (((Node Entry,kind ax,Node (targetnode ax))#es)@
                        [(Node Exit, (\<lambda>s. True)\<^isub>\<surd>, NewExit)]) NewExit"
          by -(rule CFG.path_Append[OF CFG])
        with Node Entry show ?thesis by fastforce
      next
        case Exit
        have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (Node Exit,(\<lambda>s. True)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Exit_edge)
        with Exit Node have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          n [(Node Exit,(\<lambda>s. True)\<^isub>\<surd>,NewExit)] NewExit"
          by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                       simp:CFG.valid_node_def[OF CFG])
        thus ?thesis by blast
      next
        case inner
        from `valid_node m` obtain as where "m -as\<rightarrow>* Exit"
          by(fastforce dest:Exit_path)
        with inner have "\<exists>es. CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node m) es (Node Exit)"
        proof(induct as arbitrary:m)
          case Nil
          from `m -[]\<rightarrow>* Exit`
          have "m = Exit" by fastforce
          with lve_Exit_edge have "CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node m) [] (Node Exit)"
            by(fastforce intro:CFG.empty_path[OF CFG] simp:CFG.valid_node_def[OF CFG])
          thus ?case by blast
        next
          case (Cons x xs)
          note IH = `\<And>m. \<lbrakk>inner_node m; m -xs\<rightarrow>* Exit\<rbrakk>
            \<Longrightarrow> \<exists>es. CFG.path src trg
            (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
            (Node m) es (Node Exit)`
          from `m -x#xs\<rightarrow>* Exit` have "targetnode x -xs\<rightarrow>* Exit"
            and "valid_edge x" and "m = sourcenode x" by(auto elim:path_split_Cons)
          with `inner_node m`
          have edge:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
            (Node m,kind x,Node (targetnode x))"
            by(fastforce intro:lve_edge simp:inner_node_def)
          from `valid_edge x` have "valid_node (targetnode x)" by simp
          thus ?case
          proof(cases "targetnode x" rule:valid_node_cases)
            case Entry
            with `valid_edge x` have False by(rule Entry_target)
            thus ?thesis by simp
          next
            case Exit
            with edge have "CFG.path src trg
              (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
              (Node m) [(Node m,kind x,Node Exit)] (Node Exit)"
              apply - apply(rule CFG.Cons_path[OF CFG])
              apply(rule CFG.empty_path[OF CFG]) 
              by(auto simp:CFG.valid_node_def[OF CFG])
            thus ?thesis by blast
          next
            case inner
            from IH[OF this `targetnode x -xs\<rightarrow>* Exit`] obtain es 
              where "CFG.path src trg
              (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
              (Node (targetnode x)) es (Node Exit)" by blast
            with edge have "CFG.path src trg
              (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
              (Node m) ((Node m,kind x,Node (targetnode x))#es) (Node Exit)"
              by(fastforce intro:CFG.Cons_path[OF CFG])
            thus ?thesis by blast
          qed
        qed
        then obtain es where path:"CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node m) es (Node Exit)" by blast
        have "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit
          (Node Exit,(\<lambda>s. True)\<^isub>\<surd>,NewExit)" by(fastforce intro:lve_Exit_edge)
        hence "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          (Node Exit) [(Node Exit,(\<lambda>s. True)\<^isub>\<surd>,NewExit)] NewExit"
          by(fastforce intro:CFG.Cons_path[OF CFG] CFG.empty_path[OF CFG]
                       simp:CFG.valid_node_def[OF CFG])
        with path Node have "CFG.path src trg
          (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
          n (es@[(Node Exit, (\<lambda>s. True)\<^isub>\<surd>, NewExit)]) NewExit"
          by(fastforce intro:CFG.path_Append[OF CFG])
        thus ?thesis by blast
      qed
    qed
  qed
qed


lemma lift_PDG_scd:
  assumes PDG:"PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit 
  (Postdomination.standard_control_dependence sourcenode targetnode valid_edge Exit)"
  and pd:"Postdomination sourcenode targetnode kind valid_edge Entry Exit"
  and inner:"CFGExit.inner_node sourcenode targetnode valid_edge Entry Exit nx"
  shows "PDG src trg knd 
  (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
  (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val NewExit
  (Postdomination.standard_control_dependence src trg 
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewExit)"
proof -
  interpret PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit
    "Postdomination.standard_control_dependence sourcenode targetnode 
                                                           valid_edge Exit"
    by(rule PDG)
  have wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                            state_val Exit" by(unfold_locales)
  from wf pd inner have pd':"Postdomination src trg knd
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
    NewEntry NewExit"
    by(rule lift_Postdomination)
  from wf have CFG:"CFG src trg
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry"
    by(rule lift_CFG)
  from wf have CFG_wf:"CFG_wf src trg knd
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
    (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val"
    by(rule lift_CFG_wf)
  from wf have CFGExit:"CFGExit src trg knd 
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
    NewEntry NewExit"
    by(rule lift_CFGExit)
  from wf have CFGExit_wf:"CFGExit_wf src trg knd 
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
    (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val NewExit"
    by(rule lift_CFGExit_wf)
  show ?thesis
  proof
    fix a assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "trg a = NewEntry"
    with CFG show False by(rule CFG.Entry_target)
  next
    fix a a' 
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'"
      and "src a = src a'" and "trg a = trg a'"
    with CFG show "a = a'" by(rule CFG.edge_det)
  next
    from CFG_wf
    show "lift_Def Def Entry Exit H L NewEntry = {} \<and>
          lift_Use Use Entry Exit H L NewEntry = {}"
      by(rule CFG_wf.Entry_empty)
  next
    fix a V s 
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "V \<notin> lift_Def Def Entry Exit H L (src a)" and "pred (knd a) s"
    with CFG_wf show "state_val (transfer (knd a) s) V = state_val s V"
      by(rule CFG_wf.CFG_edge_no_Def_equal)
  next
    fix a s s'
    assume assms:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      "\<forall>V\<in>lift_Use Use Entry Exit H L (src a). state_val s V = state_val s' V"
      "pred (knd a) s" "pred (knd a) s'"
    with CFG_wf show "\<forall>V\<in>lift_Def Def Entry Exit H L (src a).
             state_val (transfer (knd a) s) V = state_val (transfer (knd a) s') V"
      by(rule CFG_wf.CFG_edge_transfer_uses_only_Use)
  next
    fix a s s'
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "pred (knd a) s" 
      and "\<forall>V\<in>lift_Use Use Entry Exit H L (src a). state_val s V = state_val s' V"
    with CFG_wf show "pred (knd a) s'" by(rule CFG_wf.CFG_edge_Uses_pred_equal)
  next
    fix a a'
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'"
      and "src a = src a'" and "trg a \<noteq> trg a'"
    with CFG_wf show "\<exists>Q Q'. knd a = (Q)\<^isub>\<surd> \<and> knd a' = (Q')\<^isub>\<surd> \<and> 
                             (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))"
      by(rule CFG_wf.deterministic)
  next
    fix a assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "src a = NewExit"
    with CFGExit show False by(rule CFGExit.Exit_source)
  next
    from CFGExit
    show "\<exists>a. lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a \<and>
              src a = NewEntry \<and> trg a = NewExit \<and> knd a = (\<lambda>s. False)\<^isub>\<surd>"
      by(rule CFGExit.Entry_Exit_edge)
  next
    from CFGExit_wf
    show "lift_Def Def Entry Exit H L NewExit = {} \<and>
          lift_Use Use Entry Exit H L NewExit = {}"
      by(rule CFGExit_wf.Exit_empty)
  next
    fix n n'
    assume scd:"Postdomination.standard_control_dependence src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewExit n n'"
    show "n' \<noteq> NewExit"
    proof(rule ccontr)
      assume "\<not> n' \<noteq> NewExit"
      hence "n' = NewExit" by simp
      with scd pd' show False 
        by(fastforce intro:Postdomination.Exit_not_standard_control_dependent)
    qed
  next
    fix n n'
    assume "Postdomination.standard_control_dependence src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewExit n n'"
    thus "\<exists>as. CFG.path src trg
               (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
               n as n' \<and> as \<noteq> []"
      by(fastforce simp:Postdomination.standard_control_dependence_def[OF pd'])
  qed
qed




lemma lift_PDG_standard_backward_slice:
  fixes valid_edge and sourcenode and targetnode and kind and Entry and Exit
  and Def and Use and H and L
  defines lve:"lve \<equiv> lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit"
  and lDef:"lDef \<equiv> lift_Def Def Entry Exit H L" 
  and lUse:"lUse \<equiv> lift_Use Use Entry Exit H L"
  assumes PDG:"PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit 
  (Postdomination.standard_control_dependence sourcenode targetnode valid_edge Exit)"
  and pd:"Postdomination sourcenode targetnode kind valid_edge Entry Exit"
  and inner:"CFGExit.inner_node sourcenode targetnode valid_edge Entry Exit nx"
  and "H \<inter> L = {}" and "H \<union> L = UNIV"
  shows "NonInterferenceIntraGraph src trg knd lve NewEntry lDef lUse state_val 
         (PDG.PDG_BS src trg lve lDef lUse
           (Postdomination.standard_control_dependence src trg lve NewExit))
         NewExit H L (Node Entry) (Node Exit)"
proof -
  interpret PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit
    "Postdomination.standard_control_dependence sourcenode targetnode 
                                                           valid_edge Exit"
    by(rule PDG)
  have wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                            state_val Exit" by(unfold_locales)
  interpret wf':CFGExit_wf src trg knd lve NewEntry lDef lUse state_val NewExit
    by(fastforce intro:lift_CFGExit_wf wf simp:lve lDef lUse)
  from PDG pd inner lve lDef lUse have PDG':"PDG src trg knd 
    lve NewEntry lDef lUse state_val NewExit
    (Postdomination.standard_control_dependence src trg lve NewExit)"
    by(fastforce intro:lift_PDG_scd)
  from wf pd inner have pd':"Postdomination src trg knd
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
    NewEntry NewExit"
    by(rule lift_Postdomination)
  from wf lve have CFG:"CFG src trg lve NewEntry"
    by(fastforce intro:lift_CFG)
  from wf lve lDef lUse 
  have CFG_wf:"CFG_wf src trg knd lve NewEntry lDef lUse state_val"
    by(fastforce intro:lift_CFG_wf)
  from wf lve have CFGExit:"CFGExit src trg knd lve NewEntry NewExit"
    by(fastforce intro:lift_CFGExit)
  from wf lve lDef lUse 
  have CFGExit_wf:"CFGExit_wf src trg knd lve NewEntry lDef lUse state_val NewExit"
    by(fastforce intro:lift_CFGExit_wf)
  show ?thesis
  proof
    fix n S
    assume "n \<in> PDG.PDG_BS src trg lve lDef lUse
      (Postdomination.standard_control_dependence src trg lve NewExit) S"
    with PDG' show "CFG.valid_node src trg lve n"
      by(rule PDG.PDG_BS_valid_node)
  next
    fix n S assume "CFG.valid_node src trg lve n" and "n \<in> S"
    thus "n \<in> PDG.PDG_BS src trg lve lDef lUse
      (Postdomination.standard_control_dependence src trg lve NewExit) S"
      by(fastforce intro:PDG.PDG_path_Nil[OF PDG'] simp:PDG.PDG_BS_def[OF PDG'])
  next
    fix n' S n V
    assume "n' \<in> PDG.PDG_BS src trg lve lDef lUse
      (Postdomination.standard_control_dependence src trg lve NewExit) S"
      and "CFG_wf.data_dependence src trg lve lDef lUse n V n'"
    thus "n \<in> PDG.PDG_BS src trg lve lDef lUse
      (Postdomination.standard_control_dependence src trg lve NewExit) S"
      by(fastforce intro:PDG.PDG_path_Append[OF PDG'] PDG.PDG_path_ddep[OF PDG']
                        PDG.PDG_ddep_edge[OF PDG'] simp:PDG.PDG_BS_def[OF PDG']
                  split:split_if_asm)
  next
    fix n S
    interpret PDGx:PDG src trg knd lve NewEntry lDef lUse state_val NewExit
      "Postdomination.standard_control_dependence src trg lve NewExit"
      by(rule PDG')
    interpret pdx:Postdomination src trg knd lve NewEntry NewExit
      by(fastforce intro:pd' simp:lve)
    have scd:"StandardControlDependencePDG src trg knd lve NewEntry
      lDef lUse state_val NewExit" by(unfold_locales)
    from StandardControlDependencePDG.obs_singleton[OF scd]
    have "(\<exists>m. CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (Postdomination.standard_control_dependence src trg lve NewExit) S) = {m}) \<or>
      CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (Postdomination.standard_control_dependence src trg lve NewExit) S) = {}"
      by(fastforce simp:StandardControlDependencePDG.PDG_BS_s_def[OF scd])
    thus "finite (CFG.obs src trg lve n
        (PDG.PDG_BS src trg lve lDef lUse
          (Postdomination.standard_control_dependence src trg lve NewExit) S))"
      by fastforce
  next
    fix n S
    interpret PDGx:PDG src trg knd lve NewEntry lDef lUse state_val NewExit
      "Postdomination.standard_control_dependence src trg lve NewExit"
      by(rule PDG')
    interpret pdx:Postdomination src trg knd lve NewEntry NewExit
      by(fastforce intro:pd' simp:lve)
    have scd:"StandardControlDependencePDG src trg knd lve NewEntry
      lDef lUse state_val NewExit" by(unfold_locales)
    from StandardControlDependencePDG.obs_singleton[OF scd]
    have "(\<exists>m. CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (Postdomination.standard_control_dependence src trg lve NewExit) S) = {m}) \<or>
      CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (Postdomination.standard_control_dependence src trg lve NewExit) S) = {}"
      by(fastforce simp:StandardControlDependencePDG.PDG_BS_s_def[OF scd])
    thus "card (CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (Postdomination.standard_control_dependence src trg lve NewExit) S)) \<le> 1"
      by fastforce
  next
    fix a assume "lve a" and "src a = NewEntry"
    with lve show "trg a = NewExit \<or> trg a = Node Entry"
      by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Entry_edge lve
    show "\<exists>a. lve a \<and> src a = NewEntry \<and> trg a = Node Entry \<and> knd a = (\<lambda>s. True)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  next
    fix a assume "lve a" and "trg a = Node Entry"
    with lve show "src a = NewEntry" by(fastforce elim:lift_valid_edge.cases)
  next
    fix a assume "lve a" and "trg a = NewExit"
    with lve show "src a = NewEntry \<or> src a = Node Exit"
      by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Exit_edge lve
    show "\<exists>a. lve a \<and> src a = Node Exit \<and> trg a = NewExit \<and> knd a = (\<lambda>s. True)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  next
    fix a assume "lve a" and "src a = Node Exit"
    with lve show "trg a = NewExit" by(fastforce elim:lift_valid_edge.cases)
  next
    from lDef show "lDef (Node Entry) = H"
      by(fastforce elim:lift_Def_set.cases intro:lift_Def_High)
  next
    from Entry_noteq_Exit lUse show "lUse (Node Entry) = H"
      by(fastforce elim:lift_Use_set.cases intro:lift_Use_High)
  next
    from Entry_noteq_Exit lUse show "lUse (Node Exit) = L"
      by(fastforce elim:lift_Use_set.cases intro:lift_Use_Low)
  next
    from `H \<inter> L = {}` show "H \<inter> L = {}" .
  next
    from `H \<union> L = UNIV` show "H \<union> L = UNIV" .
  qed
qed



subsubsection {* Lifting @{text PDG_BS} with @{text weak_control_dependence} *}

lemma lift_StrongPostdomination:
  assumes wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                         state_val Exit"
  and spd:"StrongPostdomination sourcenode targetnode kind valid_edge Entry Exit"
  and inner:"CFGExit.inner_node sourcenode targetnode valid_edge Entry Exit nx"
  shows "StrongPostdomination src trg knd
  (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry NewExit"
proof -
  interpret StrongPostdomination sourcenode targetnode kind valid_edge Entry Exit
    by(rule spd)
  have pd:"Postdomination sourcenode targetnode kind valid_edge Entry Exit"
    by(unfold_locales)
  interpret pd':Postdomination src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit"
    NewEntry NewExit
    by(fastforce intro:wf inner lift_Postdomination pd)
  interpret CFGExit_wf:CFGExit_wf src trg knd
    "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit" NewEntry
    "lift_Def Def Entry Exit H L" "lift_Use Use Entry Exit H L" state_val NewExit
    by(fastforce intro:lift_CFGExit_wf wf)
  from wf have CFG:"CFG src trg
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry"
    by(rule lift_CFG)
  show ?thesis
  proof
    fix n assume "CFG.valid_node src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) n"
    show "finite
      {n'. \<exists>a'. lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a' \<and>
                src a' = n \<and> trg a' = n'}"
    proof(cases n)
      case NewEntry
      hence "{n'. \<exists>a'. lift_valid_edge valid_edge sourcenode targetnode kind 
                     Entry Exit a' \<and> src a' = n \<and> trg a' = n'} = {NewExit,Node Entry}"
        by(auto elim:lift_valid_edge.cases intro:lift_valid_edge.intros)
      thus ?thesis by simp
    next
      case NewExit
      hence "{n'. \<exists>a'. lift_valid_edge valid_edge sourcenode targetnode kind 
                     Entry Exit a' \<and> src a' = n \<and> trg a' = n'} = {}"
        by fastforce
      thus ?thesis by simp
    next
      case (Node m)
      with Entry_Exit_edge `CFG.valid_node src trg
        (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) n`
      have "valid_node m" 
        by(auto elim:lift_valid_edge.cases 
                simp:CFG.valid_node_def[OF CFG] valid_node_def)
      hence "finite {m'. \<exists>a'. valid_edge a' \<and> sourcenode a' = m \<and> targetnode a' = m'}"
        by(rule successor_set_finite)
      have "{m'. \<exists>a'. lift_valid_edge valid_edge sourcenode targetnode kind 
                      Entry Exit a' \<and> src a' = Node m \<and> trg a' = Node m'} \<subseteq> 
            {m'. \<exists>a'. valid_edge a' \<and> sourcenode a' = m \<and> targetnode a' = m'}"
        by(fastforce elim:lift_valid_edge.cases)
      with `finite {m'. \<exists>a'. valid_edge a' \<and> sourcenode a' = m \<and> targetnode a' = m'}`
      have "finite {m'. \<exists>a'. lift_valid_edge valid_edge sourcenode targetnode kind 
                             Entry Exit a' \<and> src a' = Node m \<and> trg a' = Node m'}"
        by -(rule finite_subset)
      hence "finite (Node ` {m'. \<exists>a'. lift_valid_edge valid_edge sourcenode 
        targetnode kind Entry Exit a' \<and> src a' = Node m \<and> trg a' = Node m'})"
        by fastforce
      hence fin:"finite ((Node ` {m'. \<exists>a'. lift_valid_edge valid_edge sourcenode 
        targetnode kind Entry Exit a' \<and> src a' = Node m \<and> trg a' = Node m'}) \<union>
        {NewEntry,NewExit})" by fastforce
      with Node have "{n'. \<exists>a'. lift_valid_edge valid_edge sourcenode targetnode kind 
        Entry Exit a' \<and> src a' = n \<and> trg a' = n'} \<subseteq>
        (Node ` {m'. \<exists>a'. lift_valid_edge valid_edge sourcenode 
        targetnode kind Entry Exit a' \<and> src a' = Node m \<and> trg a' = Node m'}) \<union>
        {NewEntry,NewExit}" by auto (case_tac x,auto)
      with fin show ?thesis by -(rule finite_subset)
    qed
  qed
qed





lemma lift_PDG_wcd:
  assumes PDG:"PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit 
  (StrongPostdomination.weak_control_dependence sourcenode targetnode 
  valid_edge Exit)"
  and spd:"StrongPostdomination sourcenode targetnode kind valid_edge Entry Exit"
  and inner:"CFGExit.inner_node sourcenode targetnode valid_edge Entry Exit nx"
  shows "PDG src trg knd 
  (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
  (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val NewExit
  (StrongPostdomination.weak_control_dependence src trg 
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewExit)"
proof -
  interpret PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit
    "StrongPostdomination.weak_control_dependence sourcenode targetnode 
                                                           valid_edge Exit"
    by(rule PDG)
  have wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                            state_val Exit" by(unfold_locales)
  from wf spd inner have spd':"StrongPostdomination src trg knd
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
    NewEntry NewExit"
    by(rule lift_StrongPostdomination)
  from wf have CFG:"CFG src trg
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry"
    by(rule lift_CFG)
  from wf have CFG_wf:"CFG_wf src trg knd
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
    (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val"
    by(rule lift_CFG_wf)
  from wf have CFGExit:"CFGExit src trg knd 
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
    NewEntry NewExit"
    by(rule lift_CFGExit)
  from wf have CFGExit_wf:"CFGExit_wf src trg knd 
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewEntry
    (lift_Def Def Entry Exit H L) (lift_Use Use Entry Exit H L) state_val NewExit"
    by(rule lift_CFGExit_wf)
  show ?thesis
  proof
    fix a assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "trg a = NewEntry"
    with CFG show False by(rule CFG.Entry_target)
  next
    fix a a' 
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'"
      and "src a = src a'" and "trg a = trg a'"
    with CFG show "a = a'" by(rule CFG.edge_det)
  next
    from CFG_wf
    show "lift_Def Def Entry Exit H L NewEntry = {} \<and>
          lift_Use Use Entry Exit H L NewEntry = {}"
      by(rule CFG_wf.Entry_empty)
  next
    fix a V s 
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "V \<notin> lift_Def Def Entry Exit H L (src a)" and "pred (knd a) s"
    with CFG_wf show "state_val (transfer (knd a) s) V = state_val s V"
      by(rule CFG_wf.CFG_edge_no_Def_equal)
  next
    fix a s s'
    assume assms:"lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      "\<forall>V\<in>lift_Use Use Entry Exit H L (src a). state_val s V = state_val s' V"
      "pred (knd a) s" "pred (knd a) s'"
    with CFG_wf show "\<forall>V\<in>lift_Def Def Entry Exit H L (src a).
             state_val (transfer (knd a) s) V = state_val (transfer (knd a) s') V"
      by(rule CFG_wf.CFG_edge_transfer_uses_only_Use)
  next
    fix a s s'
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "pred (knd a) s" 
      and "\<forall>V\<in>lift_Use Use Entry Exit H L (src a). state_val s V = state_val s' V"
    with CFG_wf show "pred (knd a) s'" by(rule CFG_wf.CFG_edge_Uses_pred_equal)
  next
    fix a a'
    assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a'"
      and "src a = src a'" and "trg a \<noteq> trg a'"
    with CFG_wf show "\<exists>Q Q'. knd a = (Q)\<^isub>\<surd> \<and> knd a' = (Q')\<^isub>\<surd> \<and> 
                             (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))"
      by(rule CFG_wf.deterministic)
  next
    fix a assume "lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a"
      and "src a = NewExit"
    with CFGExit show False by(rule CFGExit.Exit_source)
  next
    from CFGExit
    show "\<exists>a. lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit a \<and>
              src a = NewEntry \<and> trg a = NewExit \<and> knd a = (\<lambda>s. False)\<^isub>\<surd>"
      by(rule CFGExit.Entry_Exit_edge)
  next
    from CFGExit_wf
    show "lift_Def Def Entry Exit H L NewExit = {} \<and>
          lift_Use Use Entry Exit H L NewExit = {}"
      by(rule CFGExit_wf.Exit_empty)
  next
    fix n n'
    assume wcd:"StrongPostdomination.weak_control_dependence src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewExit n n'"
    show "n' \<noteq> NewExit"
    proof(rule ccontr)
      assume "\<not> n' \<noteq> NewExit"
      hence "n' = NewExit" by simp
      with wcd spd' show False 
        by(fastforce intro:StrongPostdomination.Exit_not_weak_control_dependent)
    qed
  next
    fix n n'
    assume "StrongPostdomination.weak_control_dependence src trg
      (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) NewExit n n'"
    thus "\<exists>as. CFG.path src trg
               (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit)
               n as n' \<and> as \<noteq> []"
      by(fastforce simp:StrongPostdomination.weak_control_dependence_def[OF spd'])
  qed
qed




lemma lift_PDG_weak_backward_slice:
  fixes valid_edge and sourcenode and targetnode and kind and Entry and Exit
  and Def and Use and H and L
  defines lve:"lve \<equiv> lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit"
  and lDef:"lDef \<equiv> lift_Def Def Entry Exit H L" 
  and lUse:"lUse \<equiv> lift_Use Use Entry Exit H L"
  assumes PDG:"PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit 
  (StrongPostdomination.weak_control_dependence sourcenode targetnode 
  valid_edge Exit)"
  and spd:"StrongPostdomination sourcenode targetnode kind valid_edge Entry Exit"
  and inner:"CFGExit.inner_node sourcenode targetnode valid_edge Entry Exit nx"
  and "H \<inter> L = {}" and "H \<union> L = UNIV"
  shows "NonInterferenceIntraGraph src trg knd lve NewEntry lDef lUse state_val 
         (PDG.PDG_BS src trg lve lDef lUse
           (StrongPostdomination.weak_control_dependence src trg lve NewExit))
         NewExit H L (Node Entry) (Node Exit)"
proof -
  interpret PDG sourcenode targetnode kind valid_edge Entry Def Use state_val Exit
    "StrongPostdomination.weak_control_dependence sourcenode targetnode 
                                                           valid_edge Exit"
    by(rule PDG)
  have wf:"CFGExit_wf sourcenode targetnode kind valid_edge Entry Def Use
                            state_val Exit" by(unfold_locales)
  interpret wf':CFGExit_wf src trg knd lve NewEntry lDef lUse state_val NewExit
    by(fastforce intro:lift_CFGExit_wf wf simp:lve lDef lUse)
  from PDG spd inner lve lDef lUse have PDG':"PDG src trg knd 
    lve NewEntry lDef lUse state_val NewExit
    (StrongPostdomination.weak_control_dependence src trg lve NewExit)"
    by(fastforce intro:lift_PDG_wcd)
  from wf spd inner have spd':"StrongPostdomination src trg knd
    (lift_valid_edge valid_edge sourcenode targetnode kind Entry Exit) 
    NewEntry NewExit"
    by(rule lift_StrongPostdomination)
  from wf lve have CFG:"CFG src trg lve NewEntry"
    by(fastforce intro:lift_CFG)
  from wf lve lDef lUse 
  have CFG_wf:"CFG_wf src trg knd lve NewEntry lDef lUse state_val"
    by(fastforce intro:lift_CFG_wf)
  from wf lve have CFGExit:"CFGExit src trg knd lve NewEntry NewExit"
    by(fastforce intro:lift_CFGExit)
  from wf lve lDef lUse 
  have CFGExit_wf:"CFGExit_wf src trg knd lve NewEntry lDef lUse state_val NewExit"
    by(fastforce intro:lift_CFGExit_wf)
  show ?thesis
  proof
    fix n S
    assume "n \<in> PDG.PDG_BS src trg lve lDef lUse
      (StrongPostdomination.weak_control_dependence src trg lve NewExit) S"
    with PDG' show "CFG.valid_node src trg lve n"
      by(rule PDG.PDG_BS_valid_node)
  next
    fix n S assume "CFG.valid_node src trg lve n" and "n \<in> S"
    thus "n \<in> PDG.PDG_BS src trg lve lDef lUse
      (StrongPostdomination.weak_control_dependence src trg lve NewExit) S"
      by(fastforce intro:PDG.PDG_path_Nil[OF PDG'] simp:PDG.PDG_BS_def[OF PDG'])
  next
    fix n' S n V
    assume "n' \<in> PDG.PDG_BS src trg lve lDef lUse
      (StrongPostdomination.weak_control_dependence src trg lve NewExit) S"
      and "CFG_wf.data_dependence src trg lve lDef lUse n V n'"
    thus "n \<in> PDG.PDG_BS src trg lve lDef lUse
      (StrongPostdomination.weak_control_dependence src trg lve NewExit) S"
      by(fastforce intro:PDG.PDG_path_Append[OF PDG'] PDG.PDG_path_ddep[OF PDG']
                        PDG.PDG_ddep_edge[OF PDG'] simp:PDG.PDG_BS_def[OF PDG']
                  split:split_if_asm)
  next
    fix n S
    interpret PDGx:PDG src trg knd lve NewEntry lDef lUse state_val NewExit
      "StrongPostdomination.weak_control_dependence src trg lve NewExit"
      by(rule PDG')
    interpret spdx:StrongPostdomination src trg knd lve NewEntry NewExit
      by(fastforce intro:spd' simp:lve)
    have wcd:"WeakControlDependencePDG src trg knd lve NewEntry
      lDef lUse state_val NewExit" by(unfold_locales)
    from WeakControlDependencePDG.obs_singleton[OF wcd]
    have "(\<exists>m. CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
       (StrongPostdomination.weak_control_dependence src trg lve NewExit) S) = {m}) \<or>
      CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (StrongPostdomination.weak_control_dependence src trg lve NewExit) S) = {}"
      by(fastforce simp:WeakControlDependencePDG.PDG_BS_w_def[OF wcd])
    thus "finite (CFG.obs src trg lve n
        (PDG.PDG_BS src trg lve lDef lUse
          (StrongPostdomination.weak_control_dependence src trg lve NewExit) S))"
      by fastforce
  next
    fix n S
    interpret PDGx:PDG src trg knd lve NewEntry lDef lUse state_val NewExit
      "StrongPostdomination.weak_control_dependence src trg lve NewExit"
      by(rule PDG')
    interpret spdx:StrongPostdomination src trg knd lve NewEntry NewExit
      by(fastforce intro:spd' simp:lve)
    have wcd:"WeakControlDependencePDG src trg knd lve NewEntry
      lDef lUse state_val NewExit" by(unfold_locales)
    from WeakControlDependencePDG.obs_singleton[OF wcd]
    have "(\<exists>m. CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
       (StrongPostdomination.weak_control_dependence src trg lve NewExit) S) = {m}) \<or>
      CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (StrongPostdomination.weak_control_dependence src trg lve NewExit) S) = {}"
      by(fastforce simp:WeakControlDependencePDG.PDG_BS_w_def[OF wcd])
    thus "card (CFG.obs src trg lve n
      (PDG.PDG_BS src trg lve lDef lUse
        (StrongPostdomination.weak_control_dependence src trg lve NewExit) S)) \<le> 1"
      by fastforce
  next
    fix a assume "lve a" and "src a = NewEntry"
    with lve show "trg a = NewExit \<or> trg a = Node Entry"
      by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Entry_edge lve
    show "\<exists>a. lve a \<and> src a = NewEntry \<and> trg a = Node Entry \<and> knd a = (\<lambda>s. True)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  next
    fix a assume "lve a" and "trg a = Node Entry"
    with lve show "src a = NewEntry" by(fastforce elim:lift_valid_edge.cases)
  next
    fix a assume "lve a" and "trg a = NewExit"
    with lve show "src a = NewEntry \<or> src a = Node Exit"
      by(fastforce elim:lift_valid_edge.cases)
  next
    from lve_Exit_edge lve
    show "\<exists>a. lve a \<and> src a = Node Exit \<and> trg a = NewExit \<and> knd a = (\<lambda>s. True)\<^isub>\<surd>"
      by(fastforce simp:knd_def)
  next
    fix a assume "lve a" and "src a = Node Exit"
    with lve show "trg a = NewExit" by(fastforce elim:lift_valid_edge.cases)
  next
    from lDef show "lDef (Node Entry) = H"
      by(fastforce elim:lift_Def_set.cases intro:lift_Def_High)
  next
    from Entry_noteq_Exit lUse show "lUse (Node Entry) = H"
      by(fastforce elim:lift_Use_set.cases intro:lift_Use_High)
  next
    from Entry_noteq_Exit lUse show "lUse (Node Exit) = L"
      by(fastforce elim:lift_Use_set.cases intro:lift_Use_Low)
  next
    from `H \<inter> L = {}` show "H \<inter> L = {}" .
  next
    from `H \<union> L = UNIV` show "H \<union> L = UNIV" .
  qed
qed


end




