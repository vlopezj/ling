{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module Lin.Print where

-- pretty-printer generated by the BNF converter

import Lin.Abs
import Data.Char


-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "\n"     :ts -> new i . rend i ts
    [c]      :ts | c `elem` "{[(.?!" -> showChar c . rend i ts
    "="      :ts -> showString " =" . new (i+1) . rend (i+1) ts
    ".\n"    :ts -> new (i-1) . showChar '.' . new (i-1) . rend (i-1) ts
{-
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
-}
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : [c] :ts | c `elem` "}])" -> showString t . showChar c . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else ' ':s)

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

nl :: Doc
nl = doc $ showChar '\n'

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print Name where
  prt _ (Name i) = doc (showString ( i))
  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])



instance Print Program where
  prt i e = case e of
   Program decs -> prPrec i 0 (concatD [prt 0 decs])


instance Print Dec where
  prt i e = case e of
   Dec name optchandecs proc -> prPrec i 0 (concatD [prt 0 name , prt 0 optchandecs , doc (showString "=") , nl , prt 0 proc , doc (showString ".\n")])
   Sig name term -> prPrec i 0 (concatD [prt 0 name , doc (showString ":") , prt 0 term , doc (showString ".")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , nl , prt 0 xs])

instance Print VarDec where
  prt i e = case e of
   VarDec name term -> prPrec i 0 (concatD [doc (showString "(") , prt 0 name , doc (showString ":") , prt 0 term , doc (showString ")")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print OptChanDecs where
  prt i e = case e of
   NoChanDecs  -> prPrec i 0 (concatD [])
   SoChanDecs chandecs -> prPrec i 0 (concatD [doc (showString "(") , prt 0 chandecs , doc (showString ")")])


instance Print ChanDec where
  prt i e = case e of
   ChanDec name optsession -> prPrec i 0 (concatD [prt 0 name , prt 0 optsession])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print ATerm where
  prt i e = case e of
   Var name -> prPrec i 0 (concatD [prt 0 name])
   Lit n -> prPrec i 0 (concatD [prt 0 n])
   TTyp  -> prPrec i 0 (concatD [doc (showString "Type")])
   TProto rsessions -> prPrec i 0 (concatD [doc (showString "<") , prt 0 rsessions , doc (showString ">")])
   Paren term -> prPrec i 0 (concatD [doc (showString "(") , prt 0 term , doc (showString ")")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print DTerm where
  prt i e = case e of
   DTerm name aterms -> prPrec i 0 (concatD [prt 0 name , prt 0 aterms])


instance Print Term where
  prt i e = case e of
   RawApp aterm aterms -> prPrec i 0 (concatD [prt 0 aterm , prt 0 aterms])
   TFun vardec vardecs term -> prPrec i 0 (concatD [prt 0 vardec , prt 0 vardecs , doc (showString "->") , prt 0 term])
   TSig vardec vardecs term -> prPrec i 0 (concatD [prt 0 vardec , prt 0 vardecs , doc (showString "**") , prt 0 term])
   Proc chandecs proc -> prPrec i 0 (concatD [doc (showString "proc") , doc (showString "(") , prt 0 chandecs , doc (showString ")") , prt 0 proc])


instance Print Proc where
  prt i e = case e of
   Act prefs procs -> prPrec i 0 (concatD [prt 0 prefs , prt 0 procs])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString "|") , prt 0 xs])

instance Print Procs where
  prt i e = case e of
   ZeroP  -> prPrec i 0 (concatD [])
   Ax session names -> prPrec i 0 (concatD [doc (showString "fwd") , prt 0 session , doc (showString "(") , prt 0 names , doc (showString ")")])
   At aterm names -> prPrec i 0 (concatD [doc (showString "@") , prt 0 aterm , doc (showString "(") , prt 0 names , doc (showString ")")])
   NewSlice names aterm name proc -> prPrec i 0 (concatD [doc (showString "slice") , doc (showString "(") , prt 0 names , doc (showString ")") , prt 0 aterm , doc (showString "as") , prt 0 name , nl , prt 0 proc])
   Procs procs -> prPrec i 0 (concatD [doc (showString "(") , prt 0 procs , doc (showString ")")])


instance Print Pref where
  prt i e = case e of
   Nu chandec0 chandec -> prPrec i 0 (concatD [doc (showString "new") , doc (showString "(") , prt 0 chandec0 , doc (showString ",") , prt 0 chandec , doc (showString ")")])
   ParSplit name chandecs -> prPrec i 0 (concatD [prt 0 name , doc (showString "{") , prt 0 chandecs , doc (showString "}")])
   TenSplit name chandecs -> prPrec i 0 (concatD [prt 0 name , doc (showString "[") , prt 0 chandecs , doc (showString "]")])
   SeqSplit name chandecs -> prPrec i 0 (concatD [prt 0 name , doc (showString "[:") , prt 0 chandecs , doc (showString ":]")])
   Send name aterm -> prPrec i 0 (concatD [doc (showString "send") , prt 0 name , prt 0 aterm])
   Recv name vardec -> prPrec i 0 (concatD [doc (showString "recv") , prt 0 name , prt 0 vardec])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , nl , prt 0 xs])

instance Print OptSession where
  prt i e = case e of
   NoSession  -> prPrec i 0 (concatD [])
   SoSession rsession -> prPrec i 0 (concatD [doc (showString ":") , prt 0 rsession])


instance Print Session where
  prt i e = case e of
   Atm name -> prPrec i 4 (concatD [prt 0 name])
   End  -> prPrec i 4 (concatD [doc (showString "end")])
   Par rsessions -> prPrec i 4 (concatD [doc (showString "{") , prt 0 rsessions , doc (showString "}")])
   Ten rsessions -> prPrec i 4 (concatD [doc (showString "[") , prt 0 rsessions , doc (showString "]")])
   Seq rsessions -> prPrec i 4 (concatD [doc (showString "[:") , prt 0 rsessions , doc (showString ":]")])
   Sort aterm0 aterm -> prPrec i 3 (concatD [doc (showString "Sort") , prt 0 aterm0 , prt 0 aterm])
   Log session -> prPrec i 3 (concatD [doc (showString "Log") , prt 4 session])
   Fwd n session -> prPrec i 3 (concatD [doc (showString "Fwd") , prt 0 n , prt 4 session])
   Snd dterm csession -> prPrec i 2 (concatD [doc (showString "!") , prt 0 dterm , prt 0 csession])
   Rcv dterm csession -> prPrec i 2 (concatD [doc (showString "?") , prt 0 dterm , prt 0 csession])
   Dual session -> prPrec i 2 (concatD [doc (showString "~") , prt 2 session])
   Loli session0 session -> prPrec i 0 (concatD [prt 2 session0 , doc (showString "-o") , prt 0 session])


instance Print RSession where
  prt i e = case e of
   Repl session optrepl -> prPrec i 0 (concatD [prt 0 session , prt 0 optrepl])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print OptRepl where
  prt i e = case e of
   One  -> prPrec i 0 (concatD [])
   Some aterm -> prPrec i 0 (concatD [doc (showString "^") , prt 0 aterm])


instance Print CSession where
  prt i e = case e of
   Cont session -> prPrec i 0 (concatD [doc (showString ".") , prt 2 session])
   Done  -> prPrec i 0 (concatD [])
