{-# LANGUAGE LambdaCase   #-}
{-# LANGUAGE ViewPatterns #-}

module Ling.Session where

import           Ling.Norm
import           Ling.Prelude
import qualified Ling.Raw     as Raw
import           Prelude      hiding (log)

array :: TraverseKind -> Sessions -> Session
array = Array

oneS :: Session -> RSession
oneS s = Repl s ø

loli :: Op2 Session
loli s t = Array ParK $ oneS <$> [dual s, t]

fwds :: Dual session => Int -> session -> [session]
fwds n s
  | n <  0    = error "fwd: Negative number of channels to forward"
  | n == 0    = []
  | n == 1    = [s]
  | otherwise = s : dual s : replicate (n - 2) (log s)

fwd :: Int -> Endom Session
fwd n s = Array ParK $ oneS <$> fwds n s

-- Here one can tune what we consider ended.
-- Being ended implies:
-- * No need to actually use the channel
-- * Forwarders thus never use them
-- For instance these could be ended.
-- * `Array _ []` (thus `{}` and `[]`)
-- * `Array _ [ended ,..., ended]`
endS :: Prism' Session ()
endS = only (Array SeqK [])

endRS :: Prism' RSession ()
endRS = nearly (oneS (endS # ())) $ \(s `Repl` r) -> endS `is` s && litR1 `is` r

endedS :: Iso' (Maybe Session) Session
endedS = non' endS

endedRS :: Iso' (Maybe RSession) RSession
endedRS = non' endRS

unRepl :: RSession -> Session
unRepl (s `Repl` r)
  | litR1 `is` r = s
  | otherwise    = error "unRepl: unexpected replicated session"

wrapSessions :: [RSession] -> Session
wrapSessions [s `Repl` (is litR1 -> True)] = s
wrapSessions ss                            = Array ParK ss

-- LENS ME
mapR :: Endom Session -> Endom RSession
mapR f (Repl s a) = Repl (f s) a

-- LENS ME
mapSessions :: Endom Session -> Endom Sessions
mapSessions = map . mapR

seqOp :: SessionOp
seqOp = SessionOp (constEndom Write) (constEndom SeqK)

parOp :: SessionOp
parOp = SessionOp (constEndom Write) (constEndom ParK)

tenOp :: SessionOp
tenOp = SessionOp (constEndom Write) (constEndom TenK)

logOp :: SessionOp
logOp = SessionOp (constEndom Write) (ifEndom TenK ParK (ifEndom ParK ParK (constEndom SeqK)))

dualOp :: SessionOp
dualOp = SessionOp (ifEndom Read Write (constEndom Read))
                   (ifEndom TenK ParK  (ifEndom ParK TenK (constEndom SeqK)))

-- Laws (not the minimal set):
-- * dual . dual = id
-- * log . log = log
-- * the sessionOp default definition should hold
-- * isSource . log = const True
class Dual a where
  dual :: Endom a
  dual = sessionOp dualOp

  log :: Endom a
  log = sessionOp logOp

  sessionOp :: Dual a => SessionOp -> Endom a

  -- A source is only made of sends but can be combined with any form of
  -- array: Seq, Par, Ten.
  isSource :: a -> Bool

  -- Being master only concerns the top part of the session. The rule being
  -- that only one when composing several sessions only one can be master.
  isMaster :: a -> Bool

isSink :: Dual a => a -> Bool
isSink = isSource . dual

dualized :: (Dual a, Dual b) => Iso a b a b
dualized = iso dual dual

termS :: SessionOp -> Term -> Session
termS o (TSession s) = sessionOp o s
termS o           t  = TermS  o t

instance Dual RW where
  dual Read  = Write
  dual Write = Read

  log        = const Write

  sessionOp (SessionOp rwf _) = evalFinEndom rwf

  isSource   = (== Write)
  isMaster   = (== Write)

instance (Ord a, Dual a) => Dual (FinEndom a) where
  sessionOp f
    | f == idOp   = id
    | f == dualOp = dual
    | f == logOp  = log
    | otherwise   = error $ "FinEndom.sessionOp: not implemented " ++ show f
  isSource (FinEndom m d) = allOf each isSource m && isSource d
  isMaster (FinEndom m d) = anyOf each isMaster m || isMaster d

instance Dual SessionOp where
  sessionOp (SessionOp rwf kf) (SessionOp rwg kg) =
    SessionOp (composeFinEndom rwf rwg) (composeFinEndom kf kg)
  isSource  (SessionOp rwf kf) = isSource (rwf, kf)
  isMaster  (SessionOp rwf kf) = isMaster (rwf, kf)

instance Dual TraverseKind where
  dual ParK = TenK
  dual TenK = ParK
  dual SeqK = SeqK

  log  SeqK = SeqK
  log  _    = ParK

  sessionOp (SessionOp _ kfun) = evalFinEndom kfun

  isSource  = const True
  isMaster  = (== ParK)

instance Dual Session where
  sessionOp f = \case
    Array k s -> Array (sessionOp f k) (sessionOp f s)
    IO p a s  -> IO (sessionOp f p) a (sessionOp f s)
    TermS o t -> TermS (sessionOp f o) t

  isSource = \case
    Array k s -> isSource (k, s)
    IO p _ s  -> isSource (p, s)
    TermS o _ -> isSource o

  isMaster = \case
    Array k _ -> isMaster k
    IO p _ _  -> isMaster p
    TermS o _ -> isMaster o

instance Dual Raw.Term where
  dual (Raw.Dual s) =          s
  dual           s  = Raw.Dual s

  log s
    | Raw.RawApp (Raw.Var (Raw.Name "Log")) [_] <- s =
        s
    | otherwise =
        Raw.RawApp (Raw.Var (Raw.Name "Log")) [Raw.paren s]

  sessionOp f
    | f == idOp   = id
    | f == dualOp = dual
    | f == logOp  = log
    | otherwise   = error $ "Raw.Term.sessionOp: not implemented " ++ show f

  isSource  = error "Raw.Term.isSource: not implemented"
  isMaster  = error "Raw.Term.isMaster: not implemented"

instance Dual RSession where
  dual   = mapR dual
  log    = mapR log
  sessionOp = mapR . sessionOp
  isSource = isSource . view rsession
  isMaster = isMaster . view rsession

instance (Dual a, Dual b) => Dual (a, b) where
  dual     = bimap dual dual
  log      = bimap log  log
  sessionOp f = bimap (sessionOp f) (sessionOp f)
  isSource (a,b) = isSource a && isSource b
  isMaster (a,b) = isMaster a || isMaster b

instance Dual a => Dual [a] where
  dual   = map dual
  log    = map log
  sessionOp = map . sessionOp
  isSource = all isSource
  isMaster = any isMaster

instance Dual Term where
  sessionOp o = view tSession . termS o
  isSource = isSource . view (from tSession)
  isMaster = isMaster . view (from tSession)

validAx :: (Eq session, Dual session) => session -> [channel] -> Bool
-- Forwarding anything between no channels is always possible
validAx _ []          = True
-- At least two for the general case
validAx _ (_ : _ : _) = True
-- One is enough if the session is a Sink. A sink can be derived
-- alone. Another way to think of it is that in the case of a sink,
-- the other side is a Log and there can be any number of Logs.
validAx s (_ : _)     = isSink s

sessionStep :: Endom Session
sessionStep (IO _ _ s) = s
sessionStep s          = error $ "sessionStep: no steps " ++ show s

-- Should be length preserving
extractDuals :: Dual a => [Maybe a] -> [a]
extractDuals = \case
  [Just s0, Nothing] -> [s0, dual s0]
  [Nothing, Just s1] -> [dual s1, s1]

  -- Appart from the two cases above the general rule
  -- so far is that all sessions should be annotated
  mas -> mas ^? below _Just ?| error "Missing type signature in `new` (extractDuals)"

extractSession :: [Maybe a] -> a
extractSession l = l ^? each . _Just ?| error "Missing type signature in `new` (extractSession)"

-- See flatRSession in Ling.Reduce
unsafeFlatRSession :: RSession -> [Session]
unsafeFlatRSession (s `Repl` r) =
  replicate (r ^? litR . integral ?| error ("unsafeFlatRSession " ++ show r)) s

-- See flatSessions in Ling.Reduce
unsafeFlatSessions :: Sessions -> [Session]
unsafeFlatSessions = concatMap unsafeFlatRSession

projSessions :: Integer -> Sessions -> Session
projSessions _ [] = error "projSessions: out of bound"
projSessions n (Repl s r:ss)
  | Just i <- r ^? litR = if n < i
                           then s
                           else projSessions (n - i) ss
  | otherwise           = error "projSessions/Repl: only integer literals are supported"

replRSession :: RFactor -> Endom RSession
replRSession r (Repl s t) = Repl s (r <> t)

-- -}
