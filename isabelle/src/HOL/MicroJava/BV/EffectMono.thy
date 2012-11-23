(*  Title:      HOL/MicroJava/BV/EffectMono.thy
    Author:     Gerwin Klein
    Copyright   2000 Technische Universitaet Muenchen
*)

header {* \isaheader{Monotonicity of eff and app} *}

theory EffectMono
imports Effect
begin

lemma PrimT_PrimT: "(G \<turnstile> xb \<preceq> PrimT p) = (xb = PrimT p)"
  by (auto elim: widen.cases)


lemma sup_loc_some [rule_format]:
"\<forall>y n. (G \<turnstile> b <=l y) \<longrightarrow> n < length y \<longrightarrow> y!n = OK t \<longrightarrow> 
  (\<exists>t. b!n = OK t \<and> (G \<turnstile> (b!n) <=o (y!n)))"
proof (induct b)
  case Nil
  show ?case by simp
next
  case (Cons a list)
  show ?case 
  proof (clarsimp simp add: list_all2_Cons1 sup_loc_def Listn.le_def lesub_def)
    fix z zs n
    assume *: 
      "G \<turnstile> a <=o z" "list_all2 (sup_ty_opt G) list zs" 
      "n < Suc (length list)" "(z # zs) ! n = OK t"

    show "(\<exists>t. (a # list) ! n = OK t) \<and> G \<turnstile>(a # list) ! n <=o OK t" 
    proof (cases n) 
      case 0
      with * show ?thesis by (simp add: sup_ty_opt_OK)
    next
      case Suc
      with Cons *
      show ?thesis by (simp add: sup_loc_def Listn.le_def lesub_def) 
    qed
  qed 
qed
   

lemma all_widen_is_sup_loc:
"\<forall>b. length a = length b \<longrightarrow> 
     (\<forall>(x, y)\<in>set (zip a b). G \<turnstile> x \<preceq> y) = (G \<turnstile> (map OK a) <=l (map OK b))" 
 (is "\<forall>b. length a = length b \<longrightarrow> ?Q a b" is "?P a")
proof (induct "a")
  show "?P []" by simp

  fix l ls assume Cons: "?P ls"

  show "?P (l#ls)" 
  proof (intro allI impI)
    fix b 
    assume "length (l # ls) = length (b::ty list)" 
    with Cons
    show "?Q (l # ls) b" by - (cases b, auto)
  qed
qed
 

lemma append_length_n [rule_format]: 
"\<forall>n. n \<le> length x \<longrightarrow> (\<exists>a b. x = a@b \<and> length a = n)"
proof (induct x)
  case Nil
  show ?case by simp
next
  case (Cons l ls)

  show ?case
  proof (intro allI impI)
    fix n
    assume l: "n \<le> length (l # ls)"

    show "\<exists>a b. l # ls = a @ b \<and> length a = n" 
    proof (cases n)
      assume "n=0" thus ?thesis by simp
    next
      fix n' assume s: "n = Suc n'"
      with l have  "n' \<le> length ls" by simp
      hence "\<exists>a b. ls = a @ b \<and> length a = n'" by (rule Cons [rule_format])
      then obtain a b where "ls = a @ b" "length a = n'" by iprover
      with s have "l # ls = (l#a) @ b \<and> length (l#a) = n" by simp
      thus ?thesis by blast
    qed
  qed
qed

lemma rev_append_cons:
"n < length x \<Longrightarrow> \<exists>a b c. x = (rev a) @ b # c \<and> length a = n"
proof -
  assume n: "n < length x"
  hence "n \<le> length x" by simp
  hence "\<exists>a b. x = a @ b \<and> length a = n" by (rule append_length_n)
  then obtain r d where x: "x = r@d" "length r = n" by iprover
  with n have "\<exists>b c. d = b#c" by (simp add: neq_Nil_conv)
  then obtain b c where "d = b#c" by iprover
  with x have "x = (rev (rev r)) @ b # c \<and> length (rev r) = n" by simp
  thus ?thesis by blast
qed

lemma sup_loc_length_map:
  "G \<turnstile> map f a <=l map g b \<Longrightarrow> length a = length b"
proof -
  assume "G \<turnstile> map f a <=l map g b"
  hence "length (map f a) = length (map g b)" by (rule sup_loc_length)
  thus ?thesis by simp
qed

lemmas [iff] = not_Err_eq

lemma app_mono: 
"\<lbrakk>G \<turnstile> s <=' s'; app i G m rT pc et s'\<rbrakk> \<Longrightarrow> app i G m rT pc et s"
proof -

  { fix s1 s2
    assume G:   "G \<turnstile> s2 <=s s1"
    assume app: "app i G m rT pc et (Some s1)"

    note [simp] = sup_loc_length sup_loc_length_map

    have "app i G m rT pc et (Some s2)"
    proof (cases i)
      case Load
    
      from G Load app
      have "G \<turnstile> snd s2 <=l snd s1" by (auto simp add: sup_state_conv)
      
      with G Load app show ?thesis 
        by (cases s2) (auto simp add: sup_state_conv dest: sup_loc_some)
    next
      case Store
      with G app show ?thesis
        by (cases s2) (auto simp add: sup_loc_Cons2 sup_state_conv)
    next
      case LitPush
      with G app show ?thesis by (cases s2) (auto simp add: sup_state_conv)
    next
      case New
      with G app show ?thesis by (cases s2) (auto simp add: sup_state_conv)
    next
      case Getfield
      with app G show ?thesis
        by (cases s2) (clarsimp simp add: sup_state_Cons2, rule widen_trans) 
    next
      case (Putfield vname cname)
      
      with app 
      obtain vT oT ST LT b
        where s1: "s1 = (vT # oT # ST, LT)" and
                  "field (G, cname) vname = Some (cname, b)" 
                  "is_class G cname" and
              oT: "G\<turnstile> oT\<preceq> (Class cname)" and
              vT: "G\<turnstile> vT\<preceq> b" and
              xc: "Ball (set (match G NullPointer pc et)) (is_class G)"
        by force
      moreover
      from s1 G
      obtain vT' oT' ST' LT'
        where s2:  "s2 = (vT' # oT' # ST', LT')" and
              oT': "G\<turnstile> oT' \<preceq> oT" and
              vT': "G\<turnstile> vT' \<preceq> vT"
        by - (cases s2, simp add: sup_state_Cons2, elim exE conjE, simp, rule that)
      moreover
      from vT' vT
      have "G \<turnstile> vT' \<preceq> b" by (rule widen_trans)
      moreover
      from oT' oT
      have "G\<turnstile> oT' \<preceq> (Class cname)" by (rule widen_trans)
      ultimately
      show ?thesis by (auto simp add: Putfield xc)
    next
      case Checkcast
      with app G show ?thesis 
        by (cases s2) (auto intro!: widen_RefT2 simp add: sup_state_Cons2)
    next
      case Return
      with app G show ?thesis
        by (cases s2) (auto simp add: sup_state_Cons2, rule widen_trans)
    next
      case Pop
      with app G show ?thesis
        by (cases s2) (clarsimp simp add: sup_state_Cons2)
    next
      case Dup
      with app G show ?thesis
        by (cases s2) (clarsimp simp add: sup_state_Cons2,
            auto dest: sup_state_length)
    next
      case Dup_x1
      with app G show ?thesis
        by (cases s2) (clarsimp simp add: sup_state_Cons2, 
            auto dest: sup_state_length)
    next
      case Dup_x2
      with app G show ?thesis
        by (cases s2) (clarsimp simp add: sup_state_Cons2,
            auto dest: sup_state_length)
    next
      case Swap
      with app G show ?thesis
        by (cases s2) (auto simp add: sup_state_Cons2)
    next
      case IAdd
      with app G show ?thesis
        by (cases s2) (auto simp add: sup_state_Cons2 PrimT_PrimT)
    next
      case Goto 
      with app show ?thesis by simp
    next
      case Ifcmpeq
      with app G show ?thesis
        by (cases s2) (auto simp add: sup_state_Cons2 PrimT_PrimT widen_RefT2)
    next
      case (Invoke cname mname list)
      
      with app
      obtain apTs X ST LT mD' rT' b' where
        s1: "s1 = (rev apTs @ X # ST, LT)" and
        l:  "length apTs = length list" and
        c:  "is_class G cname" and
        C:  "G \<turnstile> X \<preceq> Class cname" and
        w:  "\<forall>(x, y) \<in> set (zip apTs list). G \<turnstile> x \<preceq> y" and
        m:  "method (G, cname) (mname, list) = Some (mD', rT', b')" and
        x:  "\<forall>C \<in> set (match_any G pc et). is_class G C"
        by (simp del: not_None_eq, elim exE conjE) (rule that)

      obtain apTs' X' ST' LT' where
        s2: "s2 = (rev apTs' @ X' # ST', LT')" and
        l': "length apTs' = length list"
      proof -
        from l s1 G 
        have "length list < length (fst s2)" 
          by simp
        hence "\<exists>a b c. (fst s2) = rev a @ b # c \<and> length a = length list"
          by (rule rev_append_cons [rule_format])
        thus ?thesis
          by (cases s2) (elim exE conjE, simp, rule that)
      qed

      from l l'
      have "length (rev apTs') = length (rev apTs)" by simp
    
      from this s1 s2 G 
      obtain
        G': "G \<turnstile> (apTs',LT') <=s (apTs,LT)" and
        X : "G \<turnstile>  X' \<preceq> X" and "G \<turnstile> (ST',LT') <=s (ST,LT)"
        by (simp add: sup_state_rev_fst sup_state_append_fst sup_state_Cons1)
        
      with C
      have C': "G \<turnstile> X' \<preceq> Class cname"
        by - (rule widen_trans, auto)
    
      from G'
      have "G \<turnstile> map OK apTs' <=l map OK apTs"
        by (simp add: sup_state_conv)
      also
      from l w
      have "G \<turnstile> map OK apTs <=l map OK list" 
        by (simp add: all_widen_is_sup_loc)
      finally
      have "G \<turnstile> map OK apTs' <=l map OK list" .

      with l'
      have w': "\<forall>(x, y) \<in> set (zip apTs' list). G \<turnstile> x \<preceq> y"
        by (simp add: all_widen_is_sup_loc)

      from Invoke s2 l' w' C' m c x
      show ?thesis
        by (simp del: split_paired_Ex) blast
    next
      case Throw
      with app G show ?thesis
        by (cases s2, clarsimp simp add: sup_state_Cons2 widen_RefT2)
    qed
  } note this [simp]

  assume "G \<turnstile> s <=' s'" "app i G m rT pc et s'"
  thus ?thesis by (cases s, cases s', auto)
qed
    
lemmas [simp del] = split_paired_Ex

lemma eff'_mono:
"\<lbrakk> app i G m rT pc et (Some s2); G \<turnstile> s1 <=s s2 \<rbrakk> \<Longrightarrow>
  G \<turnstile> eff' (i,G,s1) <=s eff' (i,G,s2)"
proof (cases s1, cases s2)
  fix a1 b1 a2 b2
  assume s: "s1 = (a1,b1)" "s2 = (a2,b2)"
  assume app2: "app i G m rT pc et (Some s2)"
  assume G: "G \<turnstile> s1 <=s s2"
  
  note [simp] = eff_def

  with G have "G \<turnstile> (Some s1) <=' (Some s2)" by simp
  from this app2
  have app1: "app i G m rT pc et (Some s1)" by (rule app_mono)

  show ?thesis
  proof (cases i)
    case (Load n)

    with s app1
    obtain y where
       y:  "n < length b1" "b1 ! n = OK y" by clarsimp

    from Load s app2
    obtain y' where
       y': "n < length b2" "b2 ! n = OK y'" by clarsimp

    from G s 
    have "G \<turnstile> b1 <=l b2" by (simp add: sup_state_conv)

    with y y'
    have "G \<turnstile> y \<preceq> y'" 
      by - (drule sup_loc_some, simp+)
    
    with Load G y y' s app1 app2 
    show ?thesis by (clarsimp simp add: sup_state_conv)
  next
    case Store
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_conv sup_loc_update)
  next
    case LitPush
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case New
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Getfield
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Putfield
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Checkcast
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case (Invoke cname mname list)

    with s app1
    obtain a X ST where
      s1: "s1 = (a @ X # ST, b1)" and
      l:  "length a = length list"
      by (simp, elim exE conjE, simp (no_asm_simp))

    from Invoke s app2
    obtain a' X' ST' where
      s2: "s2 = (a' @ X' # ST', b2)" and
      l': "length a' = length list"
      by (simp, elim exE conjE, simp (no_asm_simp))

    from l l'
    have lr: "length a = length a'" by simp
      
    from lr G s1 s2 
    have "G \<turnstile> (ST, b1) <=s (ST', b2)"
      by (simp add: sup_state_append_fst sup_state_Cons1)
    
    moreover

    obtain b1' b2' where eff':
      "b1' = snd (eff' (i,G,s1))" 
      "b2' = snd (eff' (i,G,s2))" by simp

    from Invoke G s eff' app1 app2
    obtain "b1 = b1'" "b2 = b2'" by simp

    ultimately 

    have "G \<turnstile> (ST, b1') <=s (ST', b2')" by simp

    with Invoke G s app1 app2 eff' s1 s2 l l'
    show ?thesis 
      by (clarsimp simp add: sup_state_conv)
  next
    case Return 
    with G
    show ?thesis
      by simp
  next
    case Pop
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Dup
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Dup_x1
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next 
    case Dup_x2
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Swap
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case IAdd
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next
    case Goto
    with G s app1 app2
    show ?thesis by simp
  next
    case Ifcmpeq
    with G s app1 app2
    show ?thesis
      by (clarsimp simp add: sup_state_Cons1)
  next 
    case Throw
    with G
    show ?thesis
      by simp
  qed
qed

lemmas [iff del] = not_Err_eq

end
