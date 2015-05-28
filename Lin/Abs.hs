

module Lin.Abs where

-- Haskell module generated by the BNF converter




newtype Name = Name String deriving (Eq,Ord,Show,Read)
data Program =
   Program [Dec]
  deriving (Eq,Ord,Show,Read)

data Dec =
   Dec Name OptChanDecs Proc
 | Sig Name Term
  deriving (Eq,Ord,Show,Read)

data VarDec =
   VarDec Name Term
  deriving (Eq,Ord,Show,Read)

data OptChanDecs =
   NoChanDecs
 | SoChanDecs [ChanDec]
  deriving (Eq,Ord,Show,Read)

data ChanDec =
   ChanDec Name OptSession
  deriving (Eq,Ord,Show,Read)

data Op =
   Plus
  deriving (Eq,Ord,Show,Read)

data Term =
   Var Name
 | Lit Integer
 | TTyp
 | TProto [RSession]
 | Def Name [Term]
 | Infix Term Op Term
 | TFun VarDec [VarDec] Term
 | TSig VarDec [VarDec] Term
 | Proc [ChanDec] Proc
  deriving (Eq,Ord,Show,Read)

data Proc =
   Act [Pref] Procs
  deriving (Eq,Ord,Show,Read)

data Procs =
   ZeroP
 | Ax Session Name Name [Snk]
 | At Term [Name]
 | Procs [Proc]
  deriving (Eq,Ord,Show,Read)

data Snk =
   Snk Name
  deriving (Eq,Ord,Show,Read)

data Pref =
   Nu ChanDec ChanDec
 | ParSplit Name [ChanDec]
 | TenSplit Name [ChanDec]
 | SeqSplit Name [ChanDec]
 | NewSlice Term Name
 | Send Name Term
 | Recv Name VarDec
  deriving (Eq,Ord,Show,Read)

data OptSession =
   NoSession
 | SoSession Session
  deriving (Eq,Ord,Show,Read)

data Session =
   Atm Name
 | End
 | Par [RSession]
 | Ten [RSession]
 | Seq [RSession]
 | Sort Term Term
 | Log Session
 | Fwd Integer Session
 | Snd Term CSession
 | Rcv Term CSession
 | Dual Session
 | Loli Session Session
  deriving (Eq,Ord,Show,Read)

data RSession =
   Repl Session OptRepl
  deriving (Eq,Ord,Show,Read)

data OptRepl =
   One
 | Some Term
  deriving (Eq,Ord,Show,Read)

data CSession =
   Cont Session
 | Done
  deriving (Eq,Ord,Show,Read)

