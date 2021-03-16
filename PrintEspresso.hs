{-# LANGUAGE CPP                  #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif
{-# LANGUAGE FlexibleInstances    #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for PrintEspresso.
--   Generated by the BNF converter.
module PrintEspresso where

import qualified AbsEspresso
import           Data.Char

-- | The top-level printing method.
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) ""
  where
    rend i ss =
      case ss of
        "[":ts -> showChar '[' . rend i ts
        "(":ts -> showChar '(' . rend i ts
        "{":ts -> showChar '{' . new (i + 1) . rend (i + 1) ts
        "}":";":ts -> new (i - 1) . space "}" . showChar ';' . new (i - 1) . rend (i - 1) ts
        "}":ts -> new (i - 1) . showChar '}' . new (i - 1) . rend (i - 1) ts
        ";":ts -> showChar ';' . new i . rend i ts
        t:ts@(p:_)
          | closingOrPunctuation p -> showString t . rend i ts
        t:ts -> space t . rend i ts
        _ -> id
    new i = showChar '\n' . replicateS (2 * i) (showChar ' ') . dropWhile isSpace
    space t =
      showString t .
      (\s ->
         if null s
           then ""
           else ' ' : s)
    closingOrPunctuation :: String -> Bool
    closingOrPunctuation [c] = c `elem` closerOrPunct
    closingOrPunctuation _   = False
    closerOrPunct :: String
    closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.
class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s =
  case s of
    _
      | s == q -> showChar '\\' . showChar s
    '\\' -> showString "\\\\"
    '\n' -> showString "\\n"
    '\t' -> showString "\\t"
    _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j =
  if j < i
    then parenth
    else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print AbsEspresso.Ident where
  prt _ (AbsEspresso.Ident i) = doc (showString i)

instance Print AbsEspresso.Program where
  prt i e =
    case e of
      AbsEspresso.Program fundefs -> prPrec i 0 (concatD [prt 0 fundefs])

instance Print AbsEspresso.FunDef where
  prt i e =
    case e of
      AbsEspresso.FunDef type_ id args block ->
        prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "("), prt 0 args, doc (showString ")"), prt 0 block])
  prtList _ [x]    = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [AbsEspresso.FunDef] where
  prt = prtList

instance Print AbsEspresso.Arg where
  prt i e =
    case e of
      AbsEspresso.Arg type_ id -> prPrec i 0 (concatD [prt 0 type_, prt 0 id])
  prtList _ []     = concatD []
  prtList _ [x]    = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [AbsEspresso.Arg] where
  prt = prtList

instance Print AbsEspresso.Block where
  prt i e =
    case e of
      AbsEspresso.Block stmts -> prPrec i 0 (concatD [doc (showString "{"), prt 0 stmts, doc (showString "}")])

instance Print [AbsEspresso.Stmt] where
  prt = prtList

instance Print AbsEspresso.Stmt where
  prt i e =
    case e of
      AbsEspresso.Empty -> prPrec i 0 (concatD [doc (showString ";")])
      AbsEspresso.BStmt block -> prPrec i 0 (concatD [prt 0 block])
      AbsEspresso.FunStmt fundef -> prPrec i 0 (concatD [prt 0 fundef])
      AbsEspresso.Init type_ id expr -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "="), prt 0 expr])
      AbsEspresso.Ass id expr -> prPrec i 0 (concatD [prt 0 id, doc (showString "="), prt 0 expr])
      AbsEspresso.Incr id -> prPrec i 0 (concatD [prt 0 id, doc (showString "++")])
      AbsEspresso.Decr id -> prPrec i 0 (concatD [prt 0 id, doc (showString "--")])
      AbsEspresso.Ret expr -> prPrec i 0 (concatD [doc (showString "return"), prt 0 expr])
      AbsEspresso.VRet -> prPrec i 0 (concatD [doc (showString "return")])
      AbsEspresso.Cond expr stmt ->
        prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 expr, doc (showString ")"), prt 0 stmt])
      AbsEspresso.CondElse expr stmt1 stmt2 ->
        prPrec
          i
          0
          (concatD
             [ doc (showString "if")
             , doc (showString "(")
             , prt 0 expr
             , doc (showString ")")
             , prt 0 stmt1
             , doc (showString "else")
             , prt 0 stmt2
             ])
      AbsEspresso.While expr stmt ->
        prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 expr, doc (showString ")"), prt 0 stmt])
      AbsEspresso.For type_ id expr1 expr2 block ->
        prPrec
          i
          0
          (concatD
             [ doc (showString "for")
             , prt 0 type_
             , prt 0 id
             , doc (showString "=")
             , prt 0 expr1
             , doc (showString "to")
             , prt 0 expr2
             , prt 0 block
             ])
      AbsEspresso.Print expr -> prPrec i 0 (concatD [doc (showString "print"), doc (showString "("), prt 0 expr, doc (showString ")")])
      AbsEspresso.SExp expr -> prPrec i 0 (concatD [prt 0 expr])
  prtList _ []     = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsEspresso.Type where
  prt i e =
    case e of
      AbsEspresso.IntT -> prPrec i 0 (concatD [doc (showString "int")])
      AbsEspresso.StrT -> prPrec i 0 (concatD [doc (showString "string")])
      AbsEspresso.BoolT -> prPrec i 0 (concatD [doc (showString "boolean")])
      AbsEspresso.VoidT -> prPrec i 0 (concatD [doc (showString "void")])
      AbsEspresso.FunT type_ types -> prPrec i 0 (concatD [prt 0 type_, doc (showString "("), prt 0 types, doc (showString ")")])
  prtList _ []     = concatD []
  prtList _ [x]    = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [AbsEspresso.Type] where
  prt = prtList

instance Print AbsEspresso.Expr where
  prt i e =
    case e of
      AbsEspresso.EVar id -> prPrec i 7 (concatD [prt 0 id])
      AbsEspresso.ELitInt n -> prPrec i 7 (concatD [prt 0 n])
      AbsEspresso.ELitTrue -> prPrec i 7 (concatD [doc (showString "true")])
      AbsEspresso.ELitFalse -> prPrec i 7 (concatD [doc (showString "false")])
      AbsEspresso.EApp id exprs -> prPrec i 7 (concatD [prt 0 id, doc (showString "("), prt 0 exprs, doc (showString ")")])
      AbsEspresso.EString str -> prPrec i 7 (concatD [prt 0 str])
      AbsEspresso.Neg expr -> prPrec i 6 (concatD [doc (showString "-"), prt 6 expr])
      AbsEspresso.Not expr -> prPrec i 6 (concatD [doc (showString "!"), prt 6 expr])
      AbsEspresso.EMul expr1 mulop expr2 -> prPrec i 4 (concatD [prt 4 expr1, prt 0 mulop, prt 5 expr2])
      AbsEspresso.EAdd expr1 addop expr2 -> prPrec i 3 (concatD [prt 3 expr1, prt 0 addop, prt 4 expr2])
      AbsEspresso.ERel expr1 relop expr2 -> prPrec i 2 (concatD [prt 2 expr1, prt 0 relop, prt 3 expr2])
      AbsEspresso.ELogic expr1 logicop expr2 -> prPrec i 1 (concatD [prt 2 expr1, prt 0 logicop, prt 1 expr2])
      AbsEspresso.ELambda args block ->
        prPrec i 0 (concatD [doc (showString "("), prt 0 args, doc (showString ")"), doc (showString "=>"), prt 0 block])
  prtList _ []     = concatD []
  prtList _ [x]    = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [AbsEspresso.Expr] where
  prt = prtList

instance Print AbsEspresso.AddOp where
  prt i e =
    case e of
      AbsEspresso.Plus  -> prPrec i 0 (concatD [doc (showString "+")])
      AbsEspresso.Minus -> prPrec i 0 (concatD [doc (showString "-")])

instance Print AbsEspresso.MulOp where
  prt i e =
    case e of
      AbsEspresso.Times -> prPrec i 0 (concatD [doc (showString "*")])
      AbsEspresso.Div   -> prPrec i 0 (concatD [doc (showString "/")])
      AbsEspresso.Mod   -> prPrec i 0 (concatD [doc (showString "%")])

instance Print AbsEspresso.RelOp where
  prt i e =
    case e of
      AbsEspresso.LTH -> prPrec i 0 (concatD [doc (showString "<")])
      AbsEspresso.LE  -> prPrec i 0 (concatD [doc (showString "<=")])
      AbsEspresso.GTH -> prPrec i 0 (concatD [doc (showString ">")])
      AbsEspresso.GE  -> prPrec i 0 (concatD [doc (showString ">=")])
      AbsEspresso.EQU -> prPrec i 0 (concatD [doc (showString "==")])
      AbsEspresso.NE  -> prPrec i 0 (concatD [doc (showString "!=")])

instance Print AbsEspresso.LogicOp where
  prt i e =
    case e of
      AbsEspresso.And -> prPrec i 0 (concatD [doc (showString "&&")])
      AbsEspresso.Or  -> prPrec i 0 (concatD [doc (showString "||")])