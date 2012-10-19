header {* Editing Isabelle/Isar sources with Isabelle/jEdit *}

theory Editor
imports Main
begin

section {* The jEdit editor framework *}

text {*
  \<bullet> Home: http://www.jedit.org

  \<bullet> jEdit requires JVM 1.6 from Sun/Oracle/Apple.

  \<bullet> jEdit is a worthy successor to vi/emacs.

  \<bullet> Mostly standard menus and keyboard commands,
    e.g. C-X/C/V for cut/copy/paste.

  \<bullet> Many good ideas taken from vi/emacs,
    e.g. C-1/2/3 to split editor panes.

  \<bullet> Firefox-style quick-search and jEdit-style hypersearch.

  \<bullet> Many plugins, some of them very good (Console, Highlighter, Sidekick).

  \<bullet> Folds and outlines (via Sidekick).

  \<bullet> Native scripting via BeanShell.

  \<bullet> Plugins can be implemented in any JVM-based language, e.g. Scala.
*}


section {* The Isabelle/jEdit Prover IDE *}

text {*
  \<bullet> Based on original jEdit-4.3.2
      \<circ> minor modification of default jEdit properties (Isabelle font etc.)
      \<circ> suitable defaults for some jEdit plugins
      \<circ> sophisticated Isabelle plugin (written in Scala)

  \<bullet> Command line invocation:
      isabelle jedit
      isabelle jedit -l HOL A.thy B.thy C.thy

  \<bullet> Asynchronous interaction model:
      \<circ> Prover starts automatically and stays online.
      \<circ> Editor sends fine-grained document updates to the prover.
      \<circ> Prover provides continous semantic feedback (messages, markup).
      \<circ> Editor visualizes this information using standard GUI metaphors.

  \<bullet> Using the mouse with C (CONTROL or COMMAND) reveals further information.

  \<bullet> The Output dockable window shows messages related to the cursor position.

  \<bullet> Sidekick gives a structural overview, including source folds.
*}


section {* Isabelle symbols and fonts *}

text {*
  \<bullet> Isabelle supports infinitely many symbols:
      \<alpha>, \<beta>, \<gamma>, \<dots>
      \<forall>, \<exists>, \<or>, \<and>, \<longrightarrow>, \<longleftrightarrow>, \<dots>
      \<le>, \<ge>, \<sqinter>, \<squnion>, \<dots>
      \<aleph>, \<triangle>, \<nabla>, \<dots>
      \<toto>, \<tata>, \<titi>, \<dots>

  \<bullet> A default mapping relates some Isabelle symbols to Unicode points
    (see $ISABELLE_HOME/etc/symbols and $ISABELLE_HOME_USER/etc/symbols).

  \<bullet> The IsabelleText font ensures that Unicode points are actually
    seen on the screen (or printer).

  \<bullet> Input methods:
      \<circ> copy/paste from decoded source files
      \<circ> copy/paste from prover output
      \<circ> completion provided by Isabelle plugin, e.g.

          name            abbreviation  symbol

          lambda                        \<lambda>
          Rightarrow      =>            \<Rightarrow>
          Longrightarrow  ==>           \<Longrightarrow>
          And             !!            \<And>
          equiv           ==            \<equiv>

          forall          !             \<forall>
          exists          ?             \<exists>
          longrightarrow  -->           \<longrightarrow>
          and             /\            \<and>
          or              \/            \<or>
          not             ~             \<not>
          noteq           ~=            \<noteq>
          in              :             \<in>
          notin           ~:            \<notin>

  \<bullet> NOTE: The above abbreviations refer to the input method, but
    the logical notation provides ASCII alternatives that often
    coincide but deviate occasionally.

  \<bullet> NOTE: Generic jEdit abbreviations or plugins perform similar
    source replacement operations; this works for Isabelle as long
    as the Unicode sequences coincide with the symbol mapping.
*}


section {* Limitations and workrounds (January 2011) *}

text {*
  \<bullet> No way to start/stop prover or switch to a different logic.
    Workaround: Change options and restart editor. 

  \<bullet> Multiple theory buffers cannot depend on each other,
    imports are resolved via the file-system.
    Workaround: Save/reload files manually.

  \<bullet> No reclaiming of old/unused document versions in prover or editor.
    Workaround: Avoid large files; restart after a few hours of use.

  \<bullet> Incremental reparsing sometimes produces unexpected command spans.
    Workaround: Cut/paste larger parts or reload buffer.

  \<bullet> Command execution sometimes gets stuck (purple background).
    Workaround: Force reparsing as above.

  \<bullet> Odd behavior of some diagnostic commands, notably those starting
    external processes asynchronously (e.g. thy_deps, sledgehammer).
    Workaround: Avoid such commands.

  \<bullet> No support for non-local markup, e.g. commands reporting on
    previous commands (proof end on proof head), or markup produced
    by loading external files.

  \<bullet> General lack of various conveniences known from Proof General.
*}

end

