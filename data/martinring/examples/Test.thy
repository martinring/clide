theory Test
imports Main
begin

datatype 'a seq = Empty | Seq 'a "'a seq"

end