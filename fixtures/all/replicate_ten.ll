-- should be name enum_ten
replicate_ten = proc(c : [!Int ^ 10])
  c[d^10]
  slice (d) 10 as i
    send d i
