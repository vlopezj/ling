{-# LANGUAGE TemplateHaskell, GeneralizedNewtypeDeriving,
             FlexibleInstances, MultiParamTypeClasses #-}
module Lin.Term.Checker where

import Lin.Abs (Name)
import Lin.Utils
import Lin.Proto
import Lin.Norm
import Lin.Subst
import Lin.ErrM

import qualified Data.Map as Map
import Data.Map (Map)
import Control.Monad.Reader
import Control.Monad.Error.Class
import Control.Applicative
import Control.Lens
import Debug.Trace

type Msg = String

data ProcDef = ProcDef Name [ChanDec] Proc Proto

data TCEnv = TCEnv
  { _verbosity :: Bool
  , _evars     :: Map Name Typ
  , _pdefs     :: Map Name ProcDef
  }

$(makeLenses ''TCEnv)

emptyTCEnv :: TCEnv
emptyTCEnv = TCEnv False {-emptyConstraints-} Map.empty Map.empty -- Map.empty

newtype TC a = MkTC { unTC :: ReaderT TCEnv Err a }
  deriving (Functor, Applicative, Monad, MonadReader TCEnv)

instance MonadError String TC where
  throwError = MkTC . lift . Bad
  catchError = error "catchError: not implemented for TC"

checkTypEquality :: Typ -> Typ -> TC ()
checkTypEquality t0 t1 = assertEqual t0 t1
  ["Types are not equivalent."
  ,"Expected:"
  ,"  " ++ pretty t0
  ,"Inferred:"
  ,"  " ++ pretty t1
  ]

checkTyp :: Typ -> TC ()
checkTyp = checkTerm TTyp

checkVarDec :: VarDec -> TC () -> TC ()
checkVarDec (Arg x typ) kont = do
  checkTyp typ
  local (evars %~ Map.insert x typ) kont

-- TODO: Here I assume that sessions are well formed
checkSessions :: [RSession] -> TC ()
checkSessions _ = return ()

inferTerm :: Term -> TC Typ
inferTerm e0 = case e0 of
  Lit _           -> return int
  TTyp            -> return TTyp -- type-in-type
  Def x es        -> inferDef x es
  Proc{}          -> throwError "inferTerm: NProc"
  TFun arg s      -> checkVarDec arg (checkTyp s) >> return TTyp
  TSig arg s      -> checkVarDec arg (checkTyp s) >> return TTyp
  TProto sessions -> checkSessions sessions       >> return TTyp

checkTerm :: Typ -> Term -> TC ()
checkTerm typ e = inferTerm e >>= checkTypEquality typ

inferDef :: Name -> [Term] -> TC Typ
inferDef f es = do
  mtyp <- view $ evars . at f
  case mtyp of
    Just typ -> checkApp typ es
    Nothing  -> throwError $ "unknown definition " ++ unName f

checkApp :: Typ -> [Term] -> TC Typ
checkApp typ []     = return typ
checkApp typ (e:es) =
  case typ of
    TFun (Arg x t) s -> do
      checkTerm t e
      checkApp (subst1 (x,e) s) es
    _ -> throwError "checkApp: TODO"

debug :: [Msg] -> TC ()
debug xs = do
  v <- view verbosity
  when v $ trace (unlines (map ("[DEBUG]  "++) xs)) (return ())

assert :: Bool -> [Msg] -> TC ()
assert True  _    = return ()
assert False msgs = throwError (unlines msgs)

assertEqual :: Eq a => a -> a -> [Msg] -> TC ()
assertEqual x y = assert (x == y)

data CheckOpts = CheckOpts { _debugChecker :: Bool }

$(makeLenses ''CheckOpts)

defaultCheckOpts :: CheckOpts
defaultCheckOpts = CheckOpts False

runTC :: CheckOpts -> TC a -> Err a
runTC opts tc = runReaderT (unTC tc) (emptyTCEnv & verbosity .~ (opts ^. debugChecker))
