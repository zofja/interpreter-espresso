-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.
module AbsEspresso where

newtype Ident =
  Ident String
  deriving (Eq, Ord, Read)

instance Show (Ident) where
  show (Ident s) = s

data Program =
  Program [FunDef]
  deriving (Eq, Ord, Show, Read)

data FunDef =
  FunDef Type Ident [Arg] Block
  deriving (Eq, Ord, Show, Read)

data Arg =
  Arg Type Ident
  deriving (Eq, Ord, Show, Read)

data Block =
  Block [Stmt]
  deriving (Eq, Ord, Show, Read)

data Stmt
  = Empty
  | BStmt Block
  | FunStmt FunDef
  | Init Type Ident Expr
  | Ass Ident Expr
  | Incr Ident
  | Decr Ident
  | Ret Expr
  | VRet
  | Cond Expr Stmt
  | CondElse Expr Stmt Stmt
  | While Expr Stmt
  | For Type Ident Expr Expr Block
  | Print Expr
  | SExp Expr
  deriving (Eq, Ord, Show, Read)

data Type
  = IntT
  | StrT
  | BoolT
  | VoidT
  | FunT Type [Type]
  deriving (Eq, Ord, Show, Read)

data Expr
  = EVar Ident
  | ELitInt Integer
  | ELitTrue
  | ELitFalse
  | EApp Ident [Expr]
  | EString String
  | Neg Expr
  | Not Expr
  | EMul Expr MulOp Expr
  | EAdd Expr AddOp Expr
  | ERel Expr RelOp Expr
  | ELogic Expr LogicOp Expr
  | ELambda [Arg] Block
  deriving (Eq, Ord, Show, Read)

data AddOp
  = Plus
  | Minus
  deriving (Eq, Ord, Show, Read)

data MulOp
  = Times
  | Div
  | Mod
  deriving (Eq, Ord, Show, Read)

data RelOp
  = LTH
  | LE
  | GTH
  | GE
  | EQU
  | NE
  deriving (Eq, Ord, Show, Read)

data LogicOp
  = And
  | Or
  deriving (Eq, Ord, Show, Read)
