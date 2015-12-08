assert 'a' = 'a' : Char
ap =
  \(S T : Session)->
  proc(c : (S -o T) -o S -o T)
  c{f,xo}
  xo{x,o}
  f[fi,fo]
  ( fwd(S)(fi,x)
  | fwd(T)(o,fo))
assert `false = `false : Bool

assert (\(x:Bool) -> x) = (\(y:Bool) -> y) : ((b:Bool) -> Bool)

assert (not `true) = `false : Bool

assert
    (proc (r : ?Bool.!Bool)
      (recv r (x : Bool) . send r x))
  = (proc (r : ?Bool.!Bool)
      (recv r (y : Bool) . send r y))
  : < ?Bool . !Bool >

assert
    (proc (r : !Bool) (send r (not `true)))
  = (proc (r : !Bool) (send r `false))
  : < !Bool >
assert `false = `true : Bool
Id : (A : Type)(x y : A)-> Type

refl : (A : Type)(x : A)-> Id A x x

bad : (A : Type)(x y : A)-> Id A x y
    = \(A : Type)(x y : A)-> refl A x
bad : (Y : Type) -> Y = \(Y : Type) -> 42
badCutSendRecv = proc() new (c : !Int, d : ?Int) send c 1 recv d (x : Int)
Id : (A : Type)(x y : A)-> Type

sym : (A : Type)(x y : A)(p : Id A x y)-> Id A y x
    = \(A : Type)(x y : A)(p : Id A x y)-> p
badTensor2 = proc(c : [!Int,?Int]) c[d,e] recv e (x : Int) send d x
another_not : (x : Bool)-> Bool
    = \(x : Bool)-> case x of { `false -> `true, `true -> `false }

pnot = proc(c : ?Bool. !Bool)
  recv c (x : Bool)
  send c (case x of { `false -> `true, `true -> `false })

if : (b : Bool)(A : Type)(t e : A)-> A
   = \(b : Bool)(A : Type)(t e : A)->
      case b of { `true -> t, `false -> e }

If : (b : Bool)(A B : Type)(t : A)(e : B)->
      case b of { `true -> A, `false -> B }
   = \(b : Bool)(A B : Type)(t : A)(e : B)->
      case b of { `true -> t, `false -> e }

{-
Rejected:

if : (b : Bool)(A : Type)(t e : A)->
      case b of { `true -> A, `false -> A }
   = \(b : Bool)(A : Type)(t e : A)->
      case b of { `true -> t, `false -> e }

IF : (b : Bool)(A : (b : Bool)-> Type)(t : A `true)(e : A `false)-> A b
   = \(b : Bool)(A : (b : Bool)-> Type)(t : A `true)(e : A `false)->
      case b of { `true -> t, `false -> e }
-}
data T = `c | `d
data U = `e | `f

badTU : (t : T)-> U = \(t : T)-> case t of { `e -> `c, `f -> `d }
case_con : case `true of { `true -> Int, `false -> Bool }
         = 1
case_fun_server =
  proc(c : ?(x : Bool). (case x of { `true -> !String, `false -> {!String,!String} }))
  recv c (x : Bool).
  @(case x of
    `true -> proc (c) send c "Hello World!"
    `false ->
       proc (c)
       c{d,e}
       send d "Hello".
       send e "World"
  )(c)
T : Type = Int
t : T = 42
bad : Int = case t of {}
bad : Int = case 42 of { }
dbl = \(n : Int)-> n + n
case_proto2 =
  \(S : Session)
   (n : Int)
   (p : < S ^ (n + n) >)
   (q : < S ^ (dbl n) >)
   (b : Bool)->
   proc(c)
   @(case b of
       `true  -> p
       `false -> q
   )(c)
My_Int = Int
case_proto
  :  (x : Bool)-> < ?Int >
  = \(x : Bool)-> proc(c : ?Int)
  @(case x of
      `true  -> proc(d : ?Int)    recv d (y : Int)
      `false -> proc(e : ?My_Int) recv e (y : My_Int)
  )(c)
com_new =
 \(S : Session)
  (p : < S  >)
  (q : < ~S >)->
  proc()
  new(c : S, d : ~S)
  ( @p(c)
  | @q(d))
com_new_mk_ten2 =
  let
    mk_tensor2 =
      \ (S0 S1 : Session)
        (p0 : < S0 >)
        (p1 : < S1 >)->
      proc(c : [S0, S1])
        c[c0,c1]
        ( @p0(c0)
        | @p1(c1))
  in
 \(S : Session)
  (p : < S  >)
  (q : < ~S >)->
  proc()
  new(c : S, d : ~S)
  @(mk_tensor2 S (~S) p q)[c,d]
data T = `c | `d | `c
confuseSendRecv2 = proc() new (c : ?Int, d : !Int)(recv c (x : Int) | recv d (y : Int))
confuseSendRecv2_using_dual = proc() new (c : ~!Int, d)(recv c (x : Int) | recv d (y : Int))
conv_fun =
  \ (A A' B : Type)
    (S : Session)
    (dom : A' -> A)
    (cod : B -> < S >)
    (f   : A -> B)->
  proc(c : !A' -o S)
    c{i,o}
    recv i (p : A')
    @(cod (f (dom p)))(o)
curry =
  \(S T U : Session)->
  proc(c : ([S, T] -o U) -o S -o T -o U)
-- later on we could replace the 5 lines below by: c{[[fx,fy],fo],{x,{y,o}}}
  c{f,xyo}
  xyo{x,yo}
  yo{y,o}
  f[fxy,fo]
  fxy[fx,fy]
  ( fwd(S)(fx,x)
  | fwd(T)(fy,y)
  | fwd(U)(o,fo))


cutEmptyParTensor = proc() new (c : {}, d : []) (c{} | d[])
cut_par_cut = proc()
  ( new (c  : !Int, d  : ?Int) ( send c  1 | recv d  (x  : Int) )
  | new (c' : !Int, d' : ?Int) ( send c' 1 | recv d' (x' : Int) )
  )

cut_recv_send_send_recv = proc() new (d : ?Int.!Int, c : !Int.?Int)
  ( send c 1
    recv c (x : Int)
  | recv d (y : Int)
    send d 2
  )

cutSendRecv = proc() new (c : !Int, d : ?Int) ( send c 1 | recv d (x : Int) )
cut_send_recv_recv_send = proc() new (c : !Int.?Int, d : ?Int.!Int)
  ( send c 1
    recv c (x : Int)
  | recv d (y : Int)
    send d 2
  )

cut_send_recv_recv_send_v2 = proc() new (c : !Int.?Int, d : ?Int.!Int)
  ( recv d (y : Int)
    send d 2
  | send c 1
    recv c (x : Int)
  )

cut_send_recv_recv_send_with_log =
  proc(logc : !String.!String, logd : !String.!String)
  new (c : !Int.?Int, d : ?Int.!Int)
  ( send logd "recv d".
    recv d (y : Int).
    send logd "send d 2".
    send d 2
  | send logc "send c 1".
    send c 1.
    send logc "recv c".
    recv c (x : Int))
cut_send_recv_recv_send_with_log_prll =
  proc(logc : !String.!String, logd : !String.!String)
  new (c : !Int.?Int, d : ?Int.!Int)
  ( ( send logd "recv d"
    | recv d (y : Int)).
    ( send logd "send d 2"
    | send d 2)
  | ( send logc "send c 1"
    | send c 1).
    ( send logc "recv c"
    | recv c (x : Int)))
data Bad = `foo | `bar | `foo
dead_lock_new_new = proc()
  new (c : ?Int, d)
  new (e : ?Int, f)
  ( recv c (x : Int).
    send f x
  | recv e (y : Int).
    send d y)
dead_lock_par_ten_ten = proc(c : {[?Int, !Int], [!Int, ?Int]})
  c{d,e} d[h,g] e[k,l]
  ( recv h (x : Int) send k x
  | recv l (y : Int) send g y
  )
dead_lock_tensor2_tensor2 = proc(cd : [?Int, !Int], ef : [?Int, !Int])
  cd[c,d] ef[e,f]
  (
    recv c (x : Int)
    send f x
  |
    recv e (y : Int)
    send d y
  )
dep_fun_server =
  \(A : Type)
   (B : (x : A)-> Type)
   (f : (x : A)-> B x)->
   proc(c : ?(x : A). !B x)
   recv c (x : A).
   send c (f x)
div_mod_server_cont = proc(c : ?Int.?Int.!Int.!Int)
  recv c (m : Int).
  recv c (n : Int).
  send c (m / n).
  send c (m % n)
div_mod_server_explicit_prll = proc(rm : ?Int, rn : ?Int, sdiv : !Int, smod : !Int)
  ( recv rn (n : Int)
  | recv rm (m : Int)).
  ( send sdiv (m / n)
  | send smod (m % n))
div_mod_server_par2_ten2_ten2 = proc(r : [?Int, ?Int], s : [!Int, !Int])
  r[rm,rn]
  s[sdiv,smod]
  ( recv rm (m : Int)
  | recv rn (n : Int)).
  ( send sdiv (m / n)
  | send smod (m % n))
div_mod_server_par4 = proc(c : {?Int, ?Int, !Int, !Int})
  c{rm,rn,sdiv,smod}
  recv rm (m : Int).
  recv rn (n : Int).
  send sdiv (m / n).
  send smod (m % n)
div_mod_server_seq2_ten2_ten2 = proc(c : [: [?Int, ?Int], [!Int, !Int] :])
  c[:r,s:]
  r[rm,rn]
  s[sdiv,smod]
  ( recv rm (m : Int)
  | recv rn (n : Int)).
  ( send sdiv (m / n)
  | send smod (m % n))
div_mod_server_seq4 = proc(c : [: ?Int, ?Int, !Int, !Int :])
  c[:rm,rn,sdiv,smod:]
  recv rm (m : Int).
  recv rn (n : Int).
  send sdiv (m / n).
  send smod (m % n)
div_mod_server_simple = proc(rm : ?Int, rn : ?Int, sdiv : !Int, smod : !Int)
  recv rm (m : Int).
  recv rn (n : Int).
  send sdiv (m / n).
  send smod (m % n)
double = proc(i : ?Int, r : !Int)
  recv i(xi : Int)
  new (c : ?Int. ?Int. !Int, d)
  (
    recv c(x : Int) recv c(y : Int) send c (x + y)
  |
    send d xi send d xi recv d(z : Int) send r z
  )
another_dual = \(S : Session)-> ~S
dual_dual =
  \(S : Session)
   (p : < S >)->
   proc(c : ~another_dual S)
   @p(c)
dup_send = proc(c : !Int)
  ( send c 1
  | send c 1)
send_42 = proc(c : !Int)
  send c 42

embed_send_42 = proc(c : !Int)
  @send_42(c)
my_zero = 0
assert ((S T : Session)-> < S ^ 5, T ^(0 + my_zero) >)
     = ((S T : Session)-> < S ^ 2, T ^ 0, S, S ^ 1, S >)
     : Type
assert ((S : Session)(m n : Int)-> < S ^(m + n)   >)
     = ((S : Session)(m n : Int)-> < S ^ m, S ^ n >)
     : Type
fake_div_mod_server_ten2 = proc(r : [?Int, ?Int], s : [!Int, !Int])
  r[rm,rn]
  s[sdiv,smod]
  ( send sdiv 42
  | send smod 21).
  ( recv rm (m : Int)
  | recv rn (n : Int))
feed_fwd_send_then_recv =
  \(I O : Type)
   (i : I)
   (f : (x : I)-> O)
   (p : < Fwd 2 (!I.?O) >)->
  proc()
   new(a : Fwd 2 (!I.?O), b : [?I.!O, !I.?O])
   ( @p(a)
   | b[c,d]
     ( recv c (x : I).
       send c (f x)
     | send d i.
       recv d (o : O)))
feed_recv =
  \(p : < ?Int >)
   (i : Int)->
  proc()
    new(c : ?Int,d)
    ( @p(c) | send d i )
feed_send =
  \(p : < !Int >)->
  proc()
    new(c : !Int,d)
    ( @p(c) | recv d (x : Int) )
feed_send_par_recv =
  \(p : < {!Int, ?Int} >)
   (n : Int)->
  proc()
    new(c : {!Int, ?Int}, d : [?Int, !Int])
    ( @p(c)
    | d[i,o]
      ( recv i (x : Int)
      | send o n))
feed_send_ten_recv =
  \(p : < [!Int, ?Int] >)
   (f : (x : Int)-> Int)->
  proc()
    new(c : [!Int, ?Int], d : {?Int, !Int})
    ( @p(c)
    | d{i,o}
      recv i (x : Int).
      send o (f x))
feed_send_then_recv =
  \(p : < !Int. ?Int >)
   (f : (x : Int)-> Int)->
  proc()
    new(c : !Int. ?Int,d)
    ( @p(c)
    | recv d (x : Int). send d (f x) )
flexible_telescope
  :  (A B : Type)(x y : A)(z t : B)-> Int
  = \(A B : Type)(x y : A)(z t : B)-> 42
fun1_to_proc_ord =
  \(I O : Type)
   (f : (x : I) -> O)->
  proc(c : [: ?I, !O :])
  c[: i, o :]
  recv i (x : I).
  send o (f x)
fun1_to_proc_par2 =
  \(I O : Type)
   (f : (x : I) -> O)->
  proc(i : ?I, o : !O)
  recv i (x : I).
  send o (f x)
fun1_to_proc_seq =
  \(I O : Type)
   (f : (x : I) -> O)->
  proc(c : ?I. !O)
  recv c (x : I).
  send c (f x)
fwd0_snd0 = proc(c : Fwd 0 (!Empty)) fwd 0 (!Empty) c
fwd1_rcv = proc(c : Fwd 1 (?Int)) fwd 1 (?Int) c
fwd2_par2_ten2 = proc(c : Fwd 2 {?Int,!Int.?Int}) fwd 2 {?Int,!Int.?Int} c
fwd3_par2_ten2_ten2 = proc(c : Fwd 3 {?Int,!Int.?Int})
  fwd 3 {?Int,!Int.?Int} c
fwd3_seq2_seq2_seq2 = proc(c : Fwd 3 [: ?Int, !Int.?Int :])
  fwd 3 [: ?Int,!Int.?Int :] c
fwd_par0_ten0 = proc(i : {}, o : []) fwd{}(i,o)
fwd_par2_ten2_expanded =
  proc (i : {?Int, !Int.?Int},o : [!Int, ?Int.!Int])
  o [o0, o1]
  i {i0, i1}
  ( recv i0 (xi0 : Int).
    send o0 xi0
  | recv o1 (xo1 : Int).
    send i1 xo1.
    recv i1 (xi1 : Int).
    send o1 xi1 )
fwd_par2_ten2 = proc(i : {?Int,!Int.?Int}, o : [!Int,?Int.!Int]) fwd{?Int,!Int.?Int}(i,o)
fwd_par2_ten2_ten2 =
  proc( i : {?Int,!Int.?Int}
      , o : [!Int,?Int.!Int]
      , l : {!Int,!Int.!Int}
      )
  fwd {?Int,!Int.?Int}(i,o,l)
fwd_par2_ten2_ten2_ten2 =
  proc( i : {?Int,!Int.?Int}
      , o : [!Int,?Int.!Int]
      , l : {!Int,!Int.!Int}
      , m : {!Int,!Int.!Int}
      )
  fwd{?Int,!Int.?Int}(i,o,l,m)
fwd_send_recv = proc(i : ?Int, o : !Int) fwd(?Int)(i,o)
fwd_send_recv_recv_auto = proc(c : !Int.?Int.?Int, d : ?Int.!Int.!Int)
  fwd(!Int.?Int.?Int)(c,d)
fwd_send_recv_recv_manually = proc(c : !Int.?Int.?Int, d : ?Int.!Int.!Int)
  recv d (x : Int).
  send c x.
  recv c (y : Int).
  send d y.
  recv c (z : Int).
  send d z
fwd_send_recv_recv_send = proc(i : ?Int. !Int, o : !Int. ?Int) fwd(?Int.!Int)(i,o)
fwd_send_recv_recv_with_listener_auto =
  proc(c : !Int.?Int.?Int,
       d : ?Int.!Int.!Int,
       e : !Int.!Int.!Int)
  fwd(!Int.?Int.?Int)(c,d,e)
fwd_send_recv_recv_with_listener_manually =
  proc(c : !Int.?Int.?Int,
       d : ?Int.!Int.!Int,
       e : !Int.!Int.!Int)
  recv d (x : Int).
  ( send c x
  | send e x).
  recv c (y : Int).
  ( send d y
  | send e y).
  recv c (z : Int).
  ( send d z
  | send e z)
fwd_seq2_seq2_seq2 =
  proc( i : [: ?Int, !Int.?Int :]
      , o : [: !Int, ?Int.!Int :]
      , l : [: !Int, !Int.!Int :]
      )
  fwd [: ?Int,!Int.?Int :](i,o,l)
fwd_ten2_par2 = proc(i : [?Int,!Int.?Int], o : {!Int,?Int.!Int}) fwd[?Int,!Int.?Int](i,o)
split_nested_seq_core =
  \(A B C D : Session)->
   proc(i : [: ~A, ~B, ~C, ~D :], o : [: [: A, B :], [: C, D :] :])
    i[:na,nb,nc,nd:]
    o[:ab,cd:]
    ab[:a,b:]
    cd[:c,d:]
    fwd A (a,na).
    fwd B (b,nb).
    fwd C (c,nc).
    fwd D (d,nd)

group_nested_seq :
  (A B C D : Session)->
  < [: [: A, B :], [: C, D :] :] -o [: A, B, C, D :] > =
  \(A B C D : Session)->
   proc(c : {[: [: ~A, ~B :], [: ~C, ~D :] :], [: A, B, C, D :]})
     c{i,o}
     @(split_nested_seq_core (~A) (~B) (~C) (~D))(o,i)
id : (A : Type)(x : A) -> A

idproc = proc(c : ?Int, d : !Int)
  recv c (y : Int)
  send d (id Int y)
assert 42 = let x = 42 in x
infer_plus = \ x y -> x + y
infer_recv = proc(c)
  recv c (x)
  send c (x + x)
i42 : Int = 42
one : Int = 1

suc : (x : Int) -> Int = _+_ one

doubleInt : (x : Int)-> Int = \(x : Int)-> x + x
data ABC = `a | `b | `c
rot : (x : ABC) -> ABC =
     \(x : ABC) ->
     case x of
       `a -> `b
       `b -> `c
       `c -> `a

rot2 : (x : ABC) -> ABC =
      \(x : ABC) -> rot (rot x)
let42ann =
  let x : Int = 42 in
  x + x
let42 = let x = 42 in x + x
let_example =
   let T = Int in
   let f = _+_ in
   proc(c : ?T.!T)
   recv c (x : T).
   let y = (f x x).
   send c y
letrecv_ann = proc(c : ?Int.!Int)
  recv c (x : Int).
  let y : Int = (x + x).
  send c y
letrecv = proc(c : ?Int.!Int)
  recv c (x : Int).
  let y = (x + x).
  send c y
letsession =
  let f = \(S0 : Session)->
            let S1 = {S0,S0} in
            let S2 = {S1,S1} in
            let S3 = {S2,S2} in
            let S4 = {S3,S3} in
            let S5 = {S4,S4} in
            let S6 = {S5,S5} in
            let S7 = {S6,S6} in
            S7
  in
  proc(c)
  fwd 2 (f (?Int)) c
lettype
  : (P : (A B : Type)-> Type)
    (p : (A : Type)-> P A A)
    (A : Type)->
    P (P (P (P A A) (P A A)) (P (P A A) (P A A)))
      (P (P (P A A) (P A A)) (P (P A A) (P A A)))
  =
   \(P : (A B : Type)-> Type)
    (p : (A : Type)-> P A A)
    (A : Type)->
    let B = P A A in
    let C = P B B in
    let D = P C C in
    p D
assert 1 = let f = \(x : Int)-> x in f (f 1) : Int
showMult = \(m n : Int) ->
  (showInt m) ++S " * " ++S (showInt n) ++S " = " ++S showInt (m * n)

showDiv = \(m n : Double) ->
  (showDouble m) ++S " / " ++S (showDouble n) ++S " = " ++S showDouble (m /D n)

my42 : String = showMult 2 21

my3_14 : String = showDiv 6.28 2.0

myNewline : Char = '\n'
local_redef_fwd_par2_ten2_expanded =
  proc(i : {?Int, !Int. ?Int}, o : [!Int, ?Int.!Int])
    o[o0,o1]
    i{i0,i1}
    ( recv i0 (x : Int).
      send o0 x
    | recv o1 (x : Int).
      send i1 x
      recv i1 (x : Int).
      send o1 x)
Id : (A : Type)(x y : A)-> Type

refl : (A : Type)(x : A)-> Id A x x

J : (A : Type)(x : A)(P : (y : A)(p : Id A x y)-> Type)(Px : P x (refl A x))(y : A)(p : Id A x y)-> P y p

-- also called subst
tr : (A : Type)(x : A)(P : (y : A)-> Type)(Px : P x)(y : A)(p : Id A x y)-> P y
   = \(A : Type)(x : A)(P : (y : A)-> Type)(Px : P x)(y : A)(p : Id A x y)->
     J A x (\(y : A)(p : Id A x y)-> P y) Px y p

coe : (A : Type)(B : Type)(p : Id Type A B)(x : A)-> B
    = \(A : Type)(B : Type)(p : Id Type A B)(x : A)->
      tr Type A (\(X : Type)-> X) x B p

sym : (A : Type)(x : A)(y : A)(p : Id A x y)-> Id A y x
    = \(A : Type)(x : A)(y : A)(p : Id A x y)-> tr A x (\(y : A)-> Id A y x) (refl A x) y p

trans : (A : Type)(x' : A)(y' : A)(z' : A)(p : Id A x' y')(q : Id A y' z')-> Id A x' z'
      = \(A : Type)(x' : A)(y' : A)(z' : A)(p : Id A x' y')(q : Id A y' z')->
        tr A y' (Id A x') p z' q
-- Should be renamed merge_ParSort_seq_recv
merger =
 \(m n : Int)->
 proc( c0 : [! Vec Int m, ? Vec Int m]
     , c1 : [! Vec Int n, ? Vec Int n]
     , ci : ? Vec Int (m + n)
     , co : ! Vec Int (m + n)
     )
  c0[c0i,c0o]
  c1[c1i,c1o]
  recv ci (vi : Vec Int (m + n))
  ( send c0i (take Int m n vi)
  | send c1i (drop Int m n vi)
  | recv c0o (v0 : Vec Int m)
    recv c1o (v1 : Vec Int n)
    send co  (merge m n v0 v1)
  )
merger_loli_Sort =
 \(m n : Int)->
 proc( c : {DotSort Int m, DotSort Int n} -o DotSort Int (m + n) )
  c{c01,d}
  c01[c0,c1]
  recv d (vi : Vec Int (m + n)).
  ( send c0 (take Int m n vi)
  | send c1 (drop Int m n vi)).
  ( recv c0 (v0 : Vec Int m)
  | recv c1 (v1 : Vec Int n)).
  send d (merge m n v0 v1)
merger_nstSort_prll =
 \(m n : Int)->
 proc( c0 : ~DotSort Int m
     , c1 : ~DotSort Int n
     , c  : DotSort Int (m + n)
     )
  recv c (vi : Vec Int (m + n)).
  ( send c0 (take Int m n vi)
  | send c1 (drop Int m n vi)).
  ( recv c0 (v0 : Vec Int m)
  | recv c1 (v1 : Vec Int n)).
  send c (merge m n v0 v1)
merger_nstSort_prll_v2 =
 \(m n : Int)->
 proc( c : [~DotSort Int m, ~DotSort Int n]
     , d : DotSort Int (m + n)
     )
  c[c0,c1]
  recv d (vi : Vec Int (m + n)).
  ( send c0 (take Int m n vi)
  | send c1 (drop Int m n vi)).
  ( recv c0 (v0 : Vec Int m)
  | recv c1 (v1 : Vec Int n)).
  send d (merge m n v0 v1)
merger_ParSort_full_prll =
 \(m n : Int)->
 proc( c0 : ~ParSort Int m
     , c1 : ~ParSort Int n
     , c  : ParSort Int (m + n)
     )
  c0[c0i,c0o]
  c1[c1i,c1o]
  c{ci,co}
  recv ci (vi : Vec Int (m + n)).
  ( send c0i (take Int m n vi)
  | send c1i (drop Int m n vi)
  | ( recv c0o (v0 : Vec Int m)
    | recv c1o (v1 : Vec Int n)).
    send co (merge m n v0 v1))
merger_seq_inferred =
 \(m n : Int)->
 proc(c0,c1,ci,co)
  recv ci (vi : Vec Int (m + n)).
  send c0 (take Int m n vi).
  send c1 (drop Int m n vi).
  recv c0 (v0 : Vec Int m).
  recv c1 (v1 : Vec Int n).
  send co (merge m n v0 v1)
merger_seq =
 \(m n : Int)->
 proc( c0 : ! Vec Int m. ? Vec Int m
     , c1 : ! Vec Int n. ? Vec Int n
     , ci : ? Vec Int (m + n)
     , co : ! Vec Int (m + n)
     )
  recv ci (vi : Vec Int (m + n)).
  send c0 (take Int m n vi).
  send c1 (drop Int m n vi).
  recv c0 (v0 : Vec Int m).
  recv c1 (v1 : Vec Int n).
  send co (merge m n v0 v1)
merger_seq_Sort =
 \(m n : Int)->
 proc(c : [DotSort Int m, DotSort Int n] -o DotSort Int (m + n))
  c{d,io} d{d0,d1}
  recv io (vi : Vec Int (m + n)).
  send d0 (take Int m n vi).
  send d1 (drop Int m n vi).
  recv d0 (v0 : Vec Int m).
  recv d1 (v1 : Vec Int n).
  send io (merge m n v0 v1)
merger_seqential_ten2_loli_Sort =
 \(m n : Int)->
 proc( c : [DotSort Int m, DotSort Int n] -o DotSort Int (m + n) )
  c{c01,d}
  c01{c0,c1}
  recv d (vi : Vec Int (m + n)).
  send c0 (take Int m n vi).
  send c1 (drop Int m n vi).
  recv c0 (v0 : Vec Int m).
  recv c1 (v1 : Vec Int n).
  send d (merge m n v0 v1)
merger_ten2_loli_Sort =
 \(m n : Int)->
 proc( c : [DotSort Int m, DotSort Int n] -o DotSort Int (m + n) )
  c{c01,d}
  c01{c0,c1}
  recv d (vi : Vec Int (m + n)).
  ( send c0 (take Int m n vi)
  | send c1 (drop Int m n vi)).
  ( recv c0 (v0 : Vec Int m)
  | recv c1 (v1 : Vec Int n)).
  send d (merge m n v0 v1)
-- This violates the protocol as one might start receiving
-- on d0 or d1 before having sent on d0 or d1
merger_v2 =
 \(m n : Int)->
 proc(c : [DotSort Int m, DotSort Int n] -o DotSort Int (m + n))
  c{d,io} d{d0,d1}
  recv io (vi : Vec Int (m + n))
  ( send d0 (take Int m n vi)
  | send d1 (drop Int m n vi)
  | recv d0 (v0 : Vec Int m)
    recv d1 (v1 : Vec Int n)
    send io (merge m n v0 v1)
  )

missing_one_seq3 = proc(c : [: !Int, !Int, !Int :])
  c[: c0, c1, c2 :]
  send c1 1
  send c2 2

missingSendConfuseSendRecv = proc() new (c : !Int, d) recv c (x : Int)
missingSend = proc() new (c : ?Int, d) recv c (x : Int)
mk_new_ann =
  \(ann : Allocation)
   (S : Session)
   (p : < S  >)
   (q : < ~S >)->
  proc()
    new/ann [c : S, d : ~S]
    ( @p(c)
    | @q(d))
mk_par2_LR =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : {S0, S1})
    c{c0,c1}
    @p0(c0).
    @p1(c1)
mk_par2_prll =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : {S0, S1})
    c{c0,c1}
    ( @p0(c0)
    | @p1(c1))
mk_par2_RL =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : {S0, S1})
    c{c0,c1}
    @p1(c1).
    @p0(c0)
mk_seq2 =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : [: S0, S1 :])
    c[: c0, c1 :]
    @p0(c0).
    @p1(c1)
-- a needlessly complicated version of mk_tensor2
-- (should be convertible with it)
mk_ten2_2new_2fwd =
 \(S0 S1 : Session)
  (p0 : < S0 >)
  (p1 : < S1 >)->
  proc(c : [S0, S1])
  c[c0,c1]
  new(d0 : ~S0, e0 : S0)
  new(d1 : ~S1, e1 : S1)
  ( @p0(e0)
  | fwd S0 (c0, d0)
  | @p1(e1)
  | fwd S1 (c1, d1))
mk_tensor2 =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : [S0, S1])
    c[c0,c1]
    ( @p0(c0)
    | @p1(c1))
assert ?(A B : Type)(C : Type)
     = ?(A : Type). ?(B : Type). ?(C : Type)
     : Session
my_dual = \(S : Session)-> ~S

test_my_dual = proc(c : my_dual (!Int))
  recv c (x : Int)
my_loli = \(S T : Session) -> {~S,T}

test_my_loli =
 \(A : Type)->
  proc(c : my_loli (!A) (!A))
  c{i,o}
  recv i (x : A).
  send o x
new_alloc = proc(c : !Int)
  new/alloc [d : !Int, e]
  ( send d 1
  | fwd(!Int)(c,e))
new_fuse1_recv_send_send_recv = proc()
  new/fuse 1 [d : ?Int.!Int, c : !Int.?Int]
  ( send c 1
    recv c (x : Int)
  | recv d (y : Int)
    send d 2
  )
new_ann_ten_recv = \(ann : Allocation)->
  proc()
    new/ann [c : [!Int, ?Int], d : {?Int, !Int}]
    ( c[co,ci]
      ( send co 42
      | recv ci (y : Int))
    | d{di,do}
      recv di (x : Int).
      send do (x + x))

{- Soon...
new_fuse_ten_recv = \(depth : Int)-> new_ann_ten_recv (fuse depth)
new_fuse1_ten_recv = new_fuse_ten_recv 1
new_fuse2_ten_recv = new_fuse_ten_recv 2
new_fuse3_ten_recv = new_fuse_ten_recv 3
new_fused_ten_recv = new_ann_ten_recv fused
-}

new_fuse1_ten_recv =
  proc()
    new/fuse 1 [c : [!Int, ?Int], d : {?Int, !Int}]
    ( c[co,ci]
      ( send co 42
      | recv ci (y : Int))
    | d{di,do}
      recv di (x : Int).
      send do (x + x))

new_fuse2_ten_recv =
  proc()
    new/fuse 2 [c : [!Int, ?Int], d : {?Int, !Int}]
    ( c[co,ci]
      ( send co 42
      | recv ci (y : Int))
    | d{di,do}
      recv di (x : Int).
      send do (x + x))

new_fuse3_ten_recv =
  proc()
    new/fuse 3 [c : [!Int, ?Int], d : {?Int, !Int}]
    ( c[co,ci]
      ( send co 42
      | recv ci (y : Int))
    | d{di,do}
      recv di (x : Int).
      send do (x + x))

new_fused_ten_recv =
  proc()
    new/fused [c : [!Int, ?Int], d : {?Int, !Int}]
    ( c[co,ci]
      ( send co 42
      | recv ci (y : Int))
    | d{di,do}
      recv di (x : Int).
      send do (x + x))
-- Requires a mix
no_dead_lock_new_new = proc()
  new (c : ?Int, d)
  new (e : ?Int, f)
  ( recv c (x : Int).
    send f x
  | send d 5
  | recv e (y : Int))
-- Requires a mix
no_dead_lock_new_new_v2 = proc()
  new (c : ?Int, d)
  new (e : ?Int, f)
  ( send d 5
  | ( recv c (x : Int).
      send f x
    | recv e (y : Int)))
non_dependent_function_type : Int -> Int = \(x : Int) -> x + 1
assert (A : Type)(a0 : A)(B : (a : A)-> Type)-> (B a0 -> Type)
     = (A : Type)(a0 : A)(B : (a : A)-> Type)-> ((b : B a0) -> Type)
     : Type
assert (A : Type)(a0 : A)(B : (a : A)-> Type)-> < ?     B a0  >
     = (A : Type)(a0 : A)(B : (a : A)-> Type)-> < ?(b : B a0) >
     : Type
some_type : Type = Int , some_value : some_type = 42
assert ((S : Session)(m n : Int)-> < S ^(m + n) >)
     = ((S : Session)(m n : Int)-> < S ^(n + m) >)
     : Type
not_sink_fwd1_snd = proc(c : Fwd 1 (!Int)) c{d} fwd (!Int) (d)
over_application : Int = _+_ 1 2 3
par0 = proc(c : {}) c{}
par1 = proc(c : {!Int}) c{d} send d 42
par2 = proc(c : {!Int,?Int}) c{d,e} recv e (x : Int) send d x
par2mix = proc(c : {!Int,?Int}) c{d,e}(recv e (x : Int) | send d 42)
par4_seq_send3 = proc(a : {[:!Int,!Int:],!Int,!Int,!Int})
  a{b,e,f,g} b[:c,d:] send e 1 send c 2 send f 3 send d 4 send g 5
parallel_assoc_2tensor2_left = proc(cde : [[!Int, !Int], !Int])
  cde[cd,e]
  cd[c,d]
  ( send c 1
  | send d 2
  | send e 3
  )
parallel_assoc_2tensor2_right = proc(cde : [[!Int, !Int], !Int])
  cde[cd,e]
  ( cd[c,d] ( send c 1 | send d 2 )
  | send e 3
  )
parallel_assoc_flat = proc(c : !Int, d : !Int, e : !Int)
  ( send c 1
  | send d 2
  | send e 3
  )
parallel_assoc_left = proc(c : !Int, d : !Int, e : !Int)
  ( ( send c 1 | send d 2 )
  | send e 3
  )
parallel_assoc_right = proc(c : !Int, d : !Int, e : !Int)
  ( send c 1
  | ( send d 2 | send e 3 )
  )
parallel_assoc_tensor3_flat = proc(cde : [!Int, !Int, !Int])
  cde[c,d,e]
  ( send c 1
  | send d 2
  | send e 3
  )
parallel_assoc_tensor3_left = proc(cde : [!Int, !Int, !Int])
  cde[c,d,e]
  ( send c 1
  | ( send d 2 | send e 3 )
  )
parallel_assoc_tensor3_right = proc(cde : [!Int, !Int, !Int])
  cde[c,d,e]
  ( ( send c 1 | send d 2 )
  | send e 3
  )
parallel_tensor4_flat = proc(cd : [!Int,!Int], ef : [!Int,!Int])
  cd[c,d]
  ef[e,f]
  ( send c 1
  | send e 2
  | send d 3
  | send f 4
  )
-- Needs mix
-- [c,d],[e,f] <mix> [c,d,e,f] <split> [c,e],[d,f] <split/split> [c],[e] and [d],[f]
parallel_tensor4_v0 = proc(cd : [!Int,!Int], ef : [!Int,!Int])
  cd[c,d]
  ef[e,f]
  ( ( send c 1 | send e 2 )
  | ( send d 3 | send f 4 )
  )
par_comm =
 \(A B : Session)->
 proc(c : {A,B} -o {B,A})
  c{i,o}
  i[na,nb]
  o{b,a}
  (fwd(A)(a,na) | fwd(B)(b,nb))
par_loli_ten = proc(c : {A,B} -o [A,B])
  c{i,o}
  i[na,nb]
  o[a,b]
  (fwd(A)(a,na) | fwd(B)(b,nb))
par_loli_ten_send =
 \(S T : Type)->
 proc(c : {!S,!T} -o [!S,!T])
  c{i,o}
  i[rs,rt]
  o[ss,st]
  ( recv rs (vs : S)
  | recv rt (vt : T)).
  ( send ss vs
  | send st vt)
par_loli_ten_send_v2 =
 \(S T : Type)->
 proc(c : {!S,!T} -o [!S,!T])
  c{i,o}
  i[rs,rt]
  ( recv rs (vs : S)
  | recv rt (vt : T)).
  o[ss,st]
  ( send ss vs
  | send st vt)
par_pat = proc(d : !Int, e : ?Int)
  @(proc (f) fwd 2 (!Int) f){d,e}
par_seq_back = proc(a : {[:!Int,!Int:],!Int})
  a{b,e} b[:c,d:] send c 2 send d 3 send e 1
par_seq_front = proc(a : {[:!Int,!Int:],!Int})
  a{b,e} b[:c,d:] send e 1 send c 2 send d 3
par_seq_middle = proc(a : {[:!Int,!Int:],!Int})
  a{b,e} b[:c,d:] send c 2 send e 1 send d 3
par_seq_send3 = proc(a : {[:!Int,!Int:],!Int.!Int.!Int})
  a{b,e} b[:c,d:] send e 1 send c 2 send e 3 send d 4 send e 5
par_ten1_ten1 = proc(c : {[?Int], [!Int]})
  c{e,d} d[l] e[h]
  recv h (x : Int) send l x
-- Accepted by the checker, makes the compiler loop
par_ten_ten_v0 = proc(c : {[?Int, !Int], [!Int, ?Int]})
  c{e,d} d[k,l] e[h,g]
  ( ( recv h (x : Int)
    | ( send k 1 | recv l (y : Int) )
    )
  | send g 2
  )
par_ten_ten_v1 = proc(c : {[?Int, !Int], [!Int, ?Int]})
  c{e,d} d[k,l] e[h,g]
  ( recv h (x : Int)
  | send k 1
  | recv l (y : Int)
  | send g 2
  )
par_ten_ten_v2 = proc(c : {[?Int, !Int], [!Int, ?Int]})
  c{e,d} d[k,l] e[h,g]
  ( ( send k 1
    | ( recv h (x : Int) | recv l (y : Int) )
    )
  | send g 2
  )
pattern_example_expanded =
  proc(abcde : [!Int, [: !Int, !Int :], { [!Int, !Int], {?Int, ?Int} } ])
    abcde[a, bc, de]
    bc[: b, c :]
    de{d, e}
    (send a 1 | send b 2. send c 3 | fwd [!Int,!Int] (d,e))
plug_compose =
  \(A B C : Session)
   (p : < A, B >)
   (q : < ~B, C >)->
  proc(a : A, c : C)
    new(b : B, b' : ~B)
    ( @p(a, b)
    | @q(b', c))
-- plug_compose_par_par is a variation over plug_compose which is derived from
-- plug_compose. This shows how one can convert between <A,B> and <{A,B}>.

flat_par' =
  \(A B : Session)
   (p : < {A, B} >)->
  proc(a : A, b : B)
    new(ab : {A, B}, nanb)
    ( @p(ab)
    | nanb[na,nb]
      ( fwd(A)(a,na)
      | fwd(B)(b,nb)))

bump_par' =
  \(A B : Session)
   (p : < A, B >)->
  proc(ab : {A, B})
    ab{a,b}
    @p(a,b)

plug_compose' =
  \(A B C : Session)
   (p : < A, B >)
   (q : < ~B, C >)->
  proc(a : A, c : C)
    new(b : B, b' : ~B)
    ( @p(a, b)
    | @q(b', c))

plug_compose_par_par :
   (A B C : Session)
   (p : < { A, B} >)
   (q : < {~B, C} >)->
        < { A, C} >
  =
  \(A B C : Session)
   (p : < { A, B} >)
   (q : < {~B, C} >)->
   bump_par' A C (plug_compose' A B C (flat_par' A B p) (flat_par' (~B) C q))
plug_send_recv =
  \(p : < !Int, ?Int >)->
  proc(c : !Int, d : ?Int)
    @p(c,d)
_ = 1
_ = 2
_ = "Hello!"
data T1 = `c1 | `c2
data T2 = `c3 | `c1
data T1 = `c1
data T1 = `c2
Int : Type
p1 = proc() ()
p1 = proc(c : !Int) send c 1
assert 16 % 33 =  16
assert 30 + 2  =  32
assert 86 - 22 =  64
assert 4  * 32 = 128
assert 512 / 2 = 256
assert pow 2 9 = 512

assert 3.03 +D 0.11000000000000032 = 3.14
assert 3.28 -D 0.13999999999999968 = 3.14
assert 6.28 *D 0.5  = 3.14
assert 1.57 /D 0.5  = 3.14
assert powD 0.1 0.001 = 0.9977000638225533

assert Int2Double 42 = 42.0
assert showInt 42 = "42"
assert showDouble 3.14 = "3.14"
assert showChar 'a' = "'a'"
assert showString "Hello \"World\"!" = "\"Hello \\\"World\\\"!\""

assert "Hello " ++S "World!" = "Hello World!"
replicate =
  \(A : Type)(n : Int)(x : A)->
  proc(os : [!A ^ n])
  os[o]
  slice (o) n as _
  send o x
-- should be named enum_par
replicate_par = proc(c : {!Int ^ 10})
  c{d}
  slice (d) 10 as i
  send d i
-- The slice command will sequence the `fwd` actions making the `i`
-- channel be read many times.
-- Some sessions are thus considered safe to be repeated, including: ?A
replicate_proc =
  \(A : Type)(n : Int)->
  proc(c : !A -o [!A ^ n])
  c{i,os}
  os[o]
  slice (o) n as _
  fwd(!A)(o,i)

-- Here is a version without this trick which relies on the persistency of
-- the variables (not channels)
replicate_proc_alt =
  \(A : Type)(n : Int)->
  proc(c : !A -o [!A ^ n])
  c{i,os}
  recv i (x : A).
  os[o]
  slice (o) n as _
  new (j : ?A, k)
  ( fwd(!A)(o,j)
  | send k x)
-- should be name enum_ten
replicate_ten = proc(c : [!Int ^ 10])
  c[d]
  slice (d) 10 as i
  send d i
reusedParChannel = proc(c : {}) c{} c{}
reusedTensorChannel = proc(c : [?Int]) c[d] recv d (x : Int) send c 1
Int1 = Int
send_1 = proc(c : !Int1)
  send c 1
seq0_explicit =
  proc(c : [: :])
  c[: :]
seq0 =
  proc(c : [: :])
  ()
seq3 = proc(c : [: !Int, !Int, !Int :])
  c[: c0, c1, c2 :]
  send c0 0
  send c1 1
  send c2 2

seq3_seq2 = proc(c : [: !Int, !Int, !Int :], d : [: !Int, !Int :])
  c[: c0, c1, c2 :]
  d[: d0, d1 :]
  send c0 0
  send c1 1
  send d0 0
  send c2 2
  send d1 1

seq_assoc_core =
 \(A B C : Session)->
 proc(i : ~[:[:A,B:],C:], o : [:A,[:B,C:]:])
  i[:nab,nc:]
  nab[:na,nb:]
  o[:a,bc:]
  bc[:b,c:]
  fwd(A)(a,na). fwd(B)(b,nb). fwd(C)(c,nc)
seq_par_back = proc(a : [:{!Int,!Int},!Int:])
  a[:b,e:] b{c,d} send c 2 send d 3 send e 1
seq_par_back_v2 = proc(a : [:{!Int,!Int},!Int:])
  a[:b,e:] b{c,d} send d 3 send c 2 send e 1
seq_pat = proc(c : [:?Int,!Int:])
  c[:d,e:]
  @(proc (f) f[:g,h:] fwd (?Int)(g,h))[:d,e:]
seq_seq = proc(a : [:[:!Int,!Int:],!Int:])
  a[:b,e:] b[:c,d:] send c 1 send d 2 send e 3
seq_seq_send2 = proc(a : [:[:!Int.!Int,!Int.!Int:],!Int.!Int:])
  a[:b,e:] b[:c,d:] send c 1 send c 2 send d 3 send d 4 send e 5 send e 6
seq_ten = proc(a : [:[!Int,!Int],!Int:])
  a[:b,e:] b[c,d] (send c 2 send e 1 | send d 3)
singleRecv = proc(c : ?Int) recv c (x : Int)
singleSend = proc(c : !Int) send c 42
sorter =
 \(n : Int)->
 proc(c : {? Vec Int n, ! Vec Int n})
  c{ci,co}
  recv ci (v : Vec Int n)
  send co (sort n v)
split_fwd1_rcv = proc(c : Fwd 1 (?Int)) c{d} fwd (?Int) (d)
split_nested_seq :
  (A B C D : Session)->
  < [: A, B, C, D :] -o [: [: A, B :], [: C, D :] :] > =
  \(A B C D : Session)->
   proc(c : {[: ~A, ~B, ~C, ~D :], [: [: A, B :], [: C, D :] :]})
    c{i,o}
    i[:na,nb,nc,nd:]
    o[:ab,cd:]
    ab[:a,b:]
    cd[:c,d:]
    fwd A (a,na).
    fwd B (b,nb).
    fwd C (c,nc).
    fwd D (d,nd)
sum_int = proc(a : {?Int ^ 10}, r : !Int)
  new/alloc [itmp : !Int.?Int, tmp]
  (send itmp 0
   fwd(?Int)(itmp, r)
  |
   a{ai}
   slice (ai) 10 as i
   recv ai  (x : Int)
   recv tmp (y : Int)
   send tmp (x + y)
  )

switch
  : (A B C : Session)->
    < [A, {B, C}] -o {[A, B], C} >
  = \(A B C : Session)->
    -- The definition of `-o` is expanded to make it easier to follow the splits.
    proc(c : {{~A, [~B, ~C]}, {[A, B], C}})
      c{i,o}
      i{na,nbc}
      nbc[nb,nc]
      o{ab,c}
      ab[a,b]
      ( fwd A (a,na)
      | fwd B (b,nb)
      | fwd C (c,nc))
ten_loli_par =
 \(A B : Session)->
 proc(c : [A,B] -o {A,B})
  c{i,o}
  i{na,nb}
  o{a,b}
  ( fwd(A)(a,na)
  | fwd(B)(b,nb))

ten_loli_par_sInt_sDouble = ten_loli_par (!Int) (!Double)
ten_loli_par_sequential =
 \(A B : Session)->
 proc(c : [A,B] -o {A,B})
  c{i,o}
  i{na,nb}
  o{a,b}
  fwd(A)(a,na).
  fwd(B)(b,nb)
-- At first we were rejecting it under the basis
-- that d{} should be in parallel with e{} since
-- d and e are in tensor. Since this is harmless
-- and avoids a special case in the checker we
-- now accept it.
ten_par_par_seq = proc(c : [{},{}]) c[d,e] d{} e{}
ten_par_par_split = proc(c : [{},{}]) c[d,e] (d{} | e{})
tensor0 = proc(c : []) c[]
tensor1 = proc(c : [!Int]) c[d] send d 42
tensor2 = proc(c : [!Int,?Int]) c[d,e](recv e (x : Int) | send d 42)
tensor2_tensor0_tensor0_parallel = proc(cd : [[], []])
  cd[c,d] ( c[] | d[] )
{-
          d[] : [d : []]
       c[]d[] : [c : [], d : []]
cd[c,d]c[]d[] : [cd : [[], []]]
-}
tensor2_tensor0_tensor0_sequence = proc(cd : [[], []])
  cd[c,d] c[] d[]
tensor2_using_dual = proc(c : [!Int,~!Int]) c[d,e](recv e (x : Int) | send d 42)
test2 = proc()
  new (c : {?Int. !Int. ?Int, !Int. ?Int. !Int}, d)
  (
    c{c0,c1}
    recv c0 (x0 : Int)
    send c1 (x0 + 1)
    recv c1 (x1 : Int)
    send c0 (x1 + x0 + 2)
    recv c0 (x2 : Int)
    send c1 (x2 + x1 + x0 + 3)
  | d[d0,d1]
    (
      send d0 1
      recv d0 (y0 : Int)
      send d0 (y0 + 4)
    |
      recv d1 (z0 : Int)
      send d1 (z0 + 5)
      recv d1 (z1 : Int)
    )
  )
test3 = proc()
  new (c : ?Int. [!Int, !Int], d)
  (
    recv c (x0 : Int)
    c[c0,c1]
    ( send c0 x0 | send c1 x0 )
  |
    send d 1
    d{d0,d1}
    ( recv d0 (y0 : Int) | recv d1 (z0 : Int) )
  )
test4_inferred = proc(r)
  new (c, d)
  (
    recv c (x0 : Int)
    recv c (x1 : Int)
    recv c (x2 : Int)
    send r (x0 + x1 + x2)
  |
    send d 1
    send d 2
    send d 3
  )
test4 = proc(r : !Int)
  new (c : ?Int. ?Int. ?Int, d)
  (
    recv c (x0 : Int)
    recv c (x1 : Int)
    recv c (x2 : Int)
    send r (x0 + x1 + x2)
  |
    send d 1
    send d 2
    send d 3
  )
test_pat_term =
  proc(abcde : [!Int, [: !Int, !Int :], { [!Int, !Int], {?Int, ?Int} } ])
    abcde[a, bc, de]
    bc[: b, c :]
    de{d, e}
    (send a 1 | send b 2. send c 3 | fwd [!Int,!Int] (d,e))

-- notice how various parts gets commuted
test_pat =
  proc(bcaed : [[: !Int, !Int :], !Int, { {?Int, ?Int}, [!Int, !Int] } ])
    bcaed[bc, a, ed]
    bc[: b, c :]
    ed{e, d}
  @test_pat_term[a, [: b, c :], {d, e}]
type_annotation =
  ((21 + 21) : Int)
ZeroCh : Type
       = (A : Type)-> A

One : Type
    = (A : Type)(x : A)-> A

zeroOne : One
        = \(A : Type)(x : A)-> x

Two : Type
    = (A : Type)(x y : A)-> A

zeroTwo : Two
        = \(A : Type)(x y : A)-> x

oneTwo : Two
       = \(A : Type)(x y : A)-> y

notTwo : (b : Two)-> Two
       = \(b : Two)(A : Type)(x y : A)-> b A y x

andTwo : (b0 b1 : Two)-> Two
       = \(b0 b1 : Two)-> b0 Two zeroTwo b1

orTwo : (b0 b1 : Two)-> Two
      = \(b0 b1 : Two)-> b0 Two b1 oneTwo

Nat : Type
    = (A : Type)(z : A)(s : (n : A)-> A)-> A

zeroNat : Nat
        = \(A : Type)(z : A)(s : (n : A)-> A)-> z

sucNat : (n : Nat)-> Nat
       = \(n : Nat)(A : Type)(z : A)(s : (m : A)-> A)-> s (n A z s)

addNat : (m n : Nat)-> Nat
       = \(m n : Nat)-> m Nat n sucNat

Bin : Type
    = (A : Type)(leaf : A)(fork : (left : A)(right : A)-> A)-> A

Nats : Type
     = (A : Type)(nil : A)(cons : (head : Nat)(tail : A)-> A)-> A

List : (X : Type)-> Type
     = \(X : Type)-> (A : Type)(nil : A)(cons : (head : X)(tail : A)-> A)-> A

nilList : (X : Type)-> List X
        = \(X : Type)(A : Type)(nil : A)(cons : (head : X)(tail : A)-> A)-> nil

consList : (X : Type)(head : X)(tail : List X)-> List X
         = \(X : Type)(head : X)(tail : List X)(A : Type)(nil : A)(cons : (head' : X)(tail' : A)-> A)->
           cons head (tail A nil cons)

mapList : (X Y : Type)(f : (x : X)-> Y)(xs : List X)-> List Y
        = \(X Y : Type)(f : (x : X)-> Y)(xs : List X)(A : Type)(nil : A)(cons : (head' : Y)(tail' : A)-> A)->
          xs A nil (\(head : X)(tail : A)-> cons (f head) tail)

-- -}
Id : (A : Type)(x y : A)-> Type

refl : (A : Type)(x : A)-> Id A x x

J : (A : Type)(x : A)(P : (y : A)(p : Id A x y)-> Type)(Px : P x (refl A x))(y : A)(p : Id A x y)-> P y p

J-refl : (A : Type)(x : A)(P : (y : A)(p : Id A x y)-> Type)(Px : P x (refl A x))->
         Id (P x (refl A x)) (J A x P Px x (refl A x)) Px

-- also called subst
tr : (A : Type)(x : A)(P : (y : A)-> Type)(Px : P x)(y : A)(p : Id A x y)-> P y
   = \(A : Type)(x : A)(P : (y : A)-> Type)(Px : P x)(y : A)(p : Id A x y)->
     J A x (\(z : A)(q : Id A x z)-> P z) Px y p

tr-refl : (A : Type)(x : A)(P : (y : A)-> Type)(Px : P x)->
          Id (P x) (tr A x P Px x (refl A x)) Px
        = \(A : Type)(x : A)(P : (y : A)-> Type)(Px : P x)->
          J-refl A x (\(z : A)(q : Id A x z)-> P z) Px

coe : (A B : Type)(p : Id Type A B)(x : A)-> B
    = \(A B : Type)(p : Id Type A B)(x : A)->
      tr Type A (\(X : Type)-> X) x B p

coe-refl : (A : Type)(x : A)-> Id A (coe A A (refl Type A) x) x
         = \(A : Type)(x : A)->
           tr-refl Type A (\(X : Type)-> X) x

sym : (A : Type)(x y : A)(p : Id A x y)-> Id A y x
    = \(A : Type)(x y : A)(p : Id A x y)-> tr A x (\(z : A)-> Id A z x) (refl A x) y p

trans : (A : Type)(x y z : A)(p : Id A x y)(q : Id A y z)-> Id A x z
     = \(A : Type)(x y z : A)(p : Id A x y)(q : Id A y z)->
        tr A y (Id A x) p z q
-- -}
_ : Int = 42

bla = _
unboundChannel = proc() recv c (x : Int)
uncurry =
  \(S T U : Session)->
  proc(c : (S -o T -o U) -o [S, T] -o U)
-- later on we could replace the 5 lines below by: c{[fx,[fy,fo]],{{x,y},o}}
  c{f,xyo}
  xyo{xy,o}
  xy{x,y}
  f[fx,fyo]
  fyo[fy,fo]
  ( fwd(S)(fx,x)
  | fwd(T)(fy,y)
  | fwd(U)(o,fo))
bad : Type = `bad
unused_chan = proc(c) c{i : !Int}
-- while wrong_case_con reduces to 1 which is well-typed a part of it is not
wrong_case_con = case `true of { `true -> 1, `false -> 1 + `true }
wrong_char_literal : Double = '\n'
wrong_dep_fun_server =
  \(A : Type)
   (B : (x : A)-> Type)
   (y : A)
   (f : (x : A)-> B x)->
   proc(c : ?(x : A). !B x)
   recv c (x : A).
   send c (f y)
wrong_double_literal : Char = 2.0
wrong_feed_send_with_send =
  \(p : < !Int >)->
  proc()
    new(c : !Int,d)
    ( @p(c) | send d 4 )
wrong_fun1_to_proc_ord =
  \(I O : Type)
   (f : (x : I) -> O)->
  proc(c : [: !O, ?I :])
  c[: o, i :]
  recv i (x : I).
  send o (f x)
wrong_fun1_to_proc_par2 =
  \(I O : Type)
   (f : (x : I) -> O)->
  proc(i : ?I, o : !O)
  recv i (x : I).
  send o (f (f x))
wrong_fwd_seq2_seq2_seq2 =
  proc( i : [: ?Int, !Int.?Int :]
      , o : [: !Int, ?Int.!Int :]
      , l : {  !Int, !Int.!Int }
      )
  fwd [: ?Int,!Int.?Int :](i,o,l)
wrong_integer_literal : Double = 42
wrong_let42ann =
  let x : Bool = 42 in
  x
wrong_let42 =
  let x = 42 in
  x x
wrong_merger_ParSort_full_seq =
 \(m n : Int)->
 proc( c0 : [! Vec Int m, ? Vec Int m]
     , c1 : [! Vec Int n, ? Vec Int n]
     , c  : {? Vec Int (m + n), ! Vec Int (m + n)}
     )
  c0[c0i,c0o]
  c1[c1i,c1o]
  c{ci,co}
  recv ci (vi : Vec Int (m + n)).
  send c0i (take Int m n vi).
  send c1i (drop Int m n vi).
  recv c0o (v0 : Vec Int m).
  recv c1o (v1 : Vec Int n).
  send co (merge m n v0 v1)
-- ParSort = \(n : Int) -> {? Vec Int n, ! Vec Int n}

wrong_merger_ParSort_prll =
 \(m n : Int)->
 proc( c0 : [! Vec Int m, ? Vec Int m]
     , c1 : [! Vec Int n, ? Vec Int n]
     , c  : {? Vec Int (m + n), ! Vec Int (m + n)}
     )
  c0[c0i,c0o]
  c1[c1i,c1o]
  c{ci,co}
  recv ci (vi : Vec Int (m + n)).
  ( send c0i (take Int m n vi)
  | send c1i (drop Int m n vi)).
  ( recv c0o (v0 : Vec Int m)
  | recv c1o (v1 : Vec Int n)).
  send co (merge m n v0 v1)
wrong_merger_send_seqential_par2_loli_Sort =
 \(m n : Int)->
 proc( c : {DotSort Int m, DotSort Int n} -o DotSort Int (m + n) )
  c{c01,d}
  c01[c0,c1]
  recv d (vi : Vec Int (m + n)).
  ( send c0 (take Int m n vi)
  | send c1 (drop Int m n vi)).
  recv c0 (v0 : Vec Int m).
  recv c1 (v1 : Vec Int n).
  send d (merge m n v0 v1)
wrong_merger_send_seqential_par2_loli_Sort =
 \(m n : Int)->
 proc( c : {DotSort Int m, DotSort Int n} -o DotSort Int (m + n) )
  c{c01,d}
  c01[c0,c1]
  recv d (vi : Vec Int (m + n)).
  send c0 (take Int m n vi).
  send c1 (drop Int m n vi).
  ( recv c0 (v0 : Vec Int m)
  | recv c1 (v1 : Vec Int n)).
  send d (merge m n v0 v1)
wrong_merger_seqential_par2_loli_Sort =
 \(m n : Int)->
 proc( c : {DotSort Int m, DotSort Int n} -o DotSort Int (m + n) )
  c{c01,d}
  c01[c0,c1]
  recv d (vi : Vec Int (m + n)).
  send c0 (take Int m n vi).
  send c1 (drop Int m n vi).
  recv c0 (v0 : Vec Int m).
  recv c1 (v1 : Vec Int n).
  send d (merge m n v0 v1)
wrong_mk_seq2_prll =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : [: S0, S1 :])
    c[: c0, c1 :]
    ( @p0(c0)
    | @p1(c1))
wrong_mk_seq2_RL =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : [: S0, S1 :])
    c[: c0, c1 :]
    @p1(c1).
    @p0(c0)
mk_ten2_LR =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : [ S0, S1 ])
    c[c0, c1]
    @p0(c0).
    @p1(c1)
wrong_mk_tensor2_RL =
  \ (S0 S1 : Session)
    (p0 : < S0 >)
    (p1 : < S1 >)->
  proc(c : [S0, S1])
    c[c0,c1]
    @p1(c1).
    @p0(c0)
wrong_new_ann = proc(c : !Int)
  new/fuse "42" [d : !Int, e]
  ( send d 1
  | fwd(!Int)(c,e))
wrong_non_dependent_function_type : Int -> Int = \(x : Bool)-> 42
wrong_order_par2_par2 = proc(c : [: {!Int,!Int}, {!Int,!Int} :])
  c[:d,e:]
  d{f,g}
  e{h,i}
  send g 2
  send h 3
  send i 4
  send f 1

wrong_order_par_seq_back = proc(a : {[:!Int,!Int:],!Int})
  a{b,e} b[:c,d:] send d 3 send c 2 send e 1
wrong_order_par_seq_front = proc(a : {[:!Int,!Int:],!Int})
  a{b,e} b[:c,d:] send e 1 send d 3 send c 2
wrong_order_par_seq_middle = proc(a : {[:!Int,!Int:],!Int})
  a{b,e} b[:c,d:] send d 3 send e 1 send c 2
wrong_order_seq2_seq2 = proc(c : [: [: !Int,!Int :], [: !Int,!Int :] :])
  c[:d,e:]
  d[:f,g:]
  e[:h,i:]
  send h 3
  send i 4
  send f 1
  send g 2

wrong_order_seq3 = proc(c : [: !Int, !Int, !Int :])
  c[: c0, c1, c2 :]
  send c0 0
  send c2 2
  send c1 1

wrong_order_seq_par_front = proc(a : [:{!Int,!Int},!Int:])
  a[:b,e:] b{c,d} send e 1 send c 2 send d 3
wrong_order_seq_par_middle = proc(a : [:{!Int,!Int},!Int:])
  a[:b,e:] b{c,d} send c 2 send e 1 send d 3
wrong_order_seq_seq = proc(a : [:[:!Int,!Int:],!Int:])
  a[:b,e:] b[:c,d:] send c 1 send e 3 send d 2
wrong_order_seq_seq_send2 = proc(a : [:[:!Int.!Int,!Int.!Int:],!Int.!Int:])
  a[:b,e:] b[:c,d:] send c 1 send c 2 send d 3 send e 4 send d 5 send e 6
wrong_order_seq_ten = proc(a : [:[!Int,!Int],!Int:])
  a[:b,e:] b[c,d] (send e 1 send c 2 | send d 3)
wrong_order_split_nested_seq :
  (A B C D : Session)->
  < [: A, B, C, D :] -o [: [: A, B :], [: C, D :] :] > =
  \(A B C D : Session)->
   proc(c : {[: ~A, ~B, ~C, ~D :], [: [: A, B :], [: C, D :] :]})
    c{i,o}
    i[:na,nb,nc,nd:]
    o[:ab,cd:]
    ab[:a,b:]
    cd[:c,d:]
    fwd(A)(a,na).
    fwd(C)(c,nc).
    fwd(B)(b,nb).
    fwd(D)(d,nd)
wrong_par_comm_sequential =
 \(A B : Session)->
 proc(c : {A,B} -o {B,A})
  c{i,o}
  i[na,nb]
  o{b,a}
  fwd(A)(a,na).
  fwd(B)(b,nb)
wrong_par_pat = proc(c : [!Int,?Int])
  c[d,e]
  @(proc (f) fwd 2 (!Int) f){d,e}
wrong_par_pat_v2 = proc(c : {?Int,!Int})
  c{d,e}
  @(proc (f) f[:g,h:] fwd (?Int) (g,h)){d,e}
wrong_par_seq3 = proc(c : [: !Int, !Int, !Int :])
  c[: c0, c1, c2 :]
  send c0 0
  (send c1 1 | send c2 2)

wrong_pattern_example_expanded =
  proc(abcde : [!Int, [: !Int, !Int :], { [!Int, !Int], {?Int, ?Int} } ])
    abcde[a, bc, de]
    bc[: b, c :]
    de{d, e}
    (send a 1. send b 2. send c 3 | fwd [!Int,!Int] (d,e))
wrong_plug_send_recv =
  \(p : < !Int, ?Int >)->
  proc(c : !Int, d : ?Int)
    @p(d,c)
assert "Hello" ++S "World!" = "Hello World!"
assert 3.03 +D 0.11 = 3.14
wrong_repeat_par = proc(c : {!Int})
  slice () 10 as i
  c{d}
  send d 1

wrong_seq_pat = proc(c : [:?Int,!Int:])
  c[:d,e:]
  @(proc (f) fwd 2 (!Int) f){d,e}
wrong_par_pat_v2 = proc(c : {?Int,!Int})
  c{d,e}
  @(proc (f) f[:g,h:] fwd (?Int) (g,h)){d,e}
wrong_split_nested_seq :
  (A B C D : Session)->
  < [: A, B, C, D :] -o [: [: A, B :], [: C, D :] :] > =
  \(A B C D : Session)->
   proc(c : {[: ~A, ~B, ~C, ~D :], [: [: A, B :], [: C, D :] :]})
    c{i,o}
    i[:na,nb,nc,nd:]
    o[:ab,cd:]
    ab[:a,b:]
    cd[:c,d:]
    ( fwd(A)(a,na)
    | fwd(B)(b,nb)
    | fwd(C)(c,nc)
    | fwd(D)(d,nd)
    )
wrong_string_literal : Double = "Hello!"
wrong_telescope = (42 : Int)-> Int
wrong_ten2_par2 = proc(c : [{!Int,!Int},!Int])
  c[d,e]
  d{f,g}
  send f 1.
  send g 1.
  send e 1
wrong_ten2_send_par1_send = proc(c : [!Int, {!Int}])
  c[d,e]
  e{f}
  send d 1. send f 2
wrong_ten_pat = proc(c : [?Int,!Int])
  c[d,e]
  @(proc (f) fwd 2 (?Int) f)[d,e]
test_pat_term2 =
  proc(abcde : [!Int, [: !Int, !Int :], { [!Int, !Int], {?Int, ?Int} } ])
    abcde[a, bc, de]
    bc[: b, c :]
    de{d, e}
    (send a 1 | send b 2. send c 3 | fwd [!Int,!Int] (d,e))

-- notice how various parts gets commuted
-- but also c and b which must stay in-order
wrong_test_pat =
  proc(bcaed : [[: !Int, !Int :], !Int, { {?Int, ?Int}, [!Int, !Int] } ])
    bcaed[bc, a, ed]
    bc[: b, c :]
    ed{e, d}
  @test_pat_term2[a, [: c, b :], {d, e}]
wrong_type_annotation = (Int : Int)
wrong : Int = Type
zap =
  \(S T : Session)(n : Int)->
  proc(c : [S -o T ^ n] -o [S ^ n] -o [T ^ n])
  c{fs,xos}
  xos{xs,os}
  fs{f}
  xs{x}
  os[o]
  slice (f,x,o) n as _
  f[fi,fo]
  ( fwd(S)(fi,x)
  | fwd(T)(o,fo))
{- later on...
  c{{f},{{x},[o]}}
  slice (f,x,o) n as _
  fwd(S -o T){f, {x,o}}
-}
-- cf: would be more precise with {~(!Int -o !Int) ^ 10}
zap_ten_fwd = proc(cf : {?Int -o ?Int ^ 10}, cn : {?Int ^ 10}, co : [!Int ^ 10])
  cf{cfi}
  cn{cni}
  co[coi]
  slice (cfi,cni,coi) 10 as i
  cfi{cfii,cfio}
  ( fwd(?Int)(cni,cfii)
  | fwd(?Int)(cfio,coi)
  )

-- cf: would be more precise with {~(!Int -o !Int) ^ 10}
zap_ten_par = proc(cf : {(?Int -o ?Int) ^ 10}, cn : {?Int ^ 10}, co : [!Int ^ 10])
  cf{cfi}
  cn{cni}
  co[coi]
  slice (cfi,cni,coi) 10 as i
  cfi{cfii,cfio}
  ( recv cni (x : Int)
    send cfii x
  | recv cfio (y : Int)
    send coi y
  )

-- cf: would be more precise with {~(!Int -o !Int) ^ 10}
zap_ten_seq = proc(cf : {?Int -o ?Int ^ 10}, cn : {?Int ^ 10}, co : [!Int ^ 10])
  cf{cfi}
  cn{cni}
  co[coi]
  slice (cfi,cni,coi) 10 as i
  cfi{cfii,cfio}
  recv cni (x : Int)
  send cfii x
  recv cfio (y : Int)
  send coi y

zip_add = proc(xs : {?Int ^ 10}, ys : {?Int ^ 10}, zs : [!Int ^ 10])
  xs{x}
  ys{y}
  zs[z]
  slice (x,y,z) 10 as i
  recv x (a : Int)
  recv y (b : Int)
  send z (a + b)
