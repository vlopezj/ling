fun1_to_proc_par2 =
  \(I : Type)
   (O : Type)
   (f : (x : I) -> O)->
  proc(i : ?I, o : !O)
  recv i (x : I).
  send o (f x)
