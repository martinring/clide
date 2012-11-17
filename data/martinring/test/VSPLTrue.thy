theory VSPLTrue
imports VSPL
begin

text{*
  Definition der Konstante "True", mit zwei Einführungsregeln: 
  True ist wahr, und aus True folgt alles, was wahr ist. 

  True ist (wenig überraschend) definiert als die Negation von False.
  *}

definition
  True    :: o
where
  "True   == ~ False"

lemma trueI: "True"
  apply (unfold True_def)
  apply (rule notI)
  apply (assumption) 
  done

lemma trueE: "[| True --> P |] ==> P"
  apply (rule impE [where P= "True"])
  apply (assumption)
  apply (rule trueI)
  done

end
