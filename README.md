## Build

```
./build.sh
./test.sh interpreter good
./test.sh interpreter bad
```

## Language functionalities table (in Polish)
 
##### Na 15 punktów
- *01 (trzy typy)* +
- *02 (literały, arytmetyka, porównania)* +
- *03 (zmienne, przypisanie)* +
- *04 (print)* +
- *05 (while, if)* +
- *06 (funkcje lub procedury, rekurencja)* +
- 07 (przez zmienną / przez wartość / in/out)
- *08 (zmienne read-only i pętla for)* +

##### Na 20 punktów
- *09 (przesłanianie i statyczne wiązanie)* +
- *10 (obsługa błędów wykonania)* +
- *11 (funkcje zwracające wartość)* +

##### Na 30 punktów
- 12 (4) (statyczne typowanie)
- *13 (2) (funkcje zagnieżdżone ze statycznym wiązaniem)* +
- 14 (1) (rekordy/tablice/listy)
- 15 (2) (krotki z przypisaniem)
- 16 (1) (break, continue)
- *17 (4) (funkcje wyższego rzędu, anonimowe, domknięcia)* +
- 18 (3) (generatory)

#### Total: 26 points

## Language description

Espresso is an imperative language based on Latte with closures and anonymous functions. For now it is dynamically typed but types are required by the parser – it is possible that I will implement a typechecker in the future. 

01 Types: `int`, `boolean`, `string`, `void`, function type, e.g. `int(int)`

02 Literals, arithmetic, comparisons

03 Variables and assignment `int x = 42`

04 Printing: `print("Hello, World!")`

05 Standard while loop and if else syntax

06 Standard syntax

08 Read-only for loop:
```
for int i = 1 to 100 {
    print(i)
}
```

09 Nested function definitions with static binding
```
int main() {
    void g(void(int) f) {
        int x = 1
        f()
        print(x) // stdout: 1
    }
    int f() {
        int x = 0
        void(int) y = () => { x++ }
        g(y)
        print(x) // stdout: 0
    }
}
```
10 Standard handling of runtime errors

11 Functions as parameters

13 Nested functions with static binding as in point 09

17 Functions as parameters, as a return value, anonymous functions
```
int(int) f(int(int) g) {
    int x = g(1)
    return (int x) => { return x + 1 }
}

int main() {
    int(int) g = (int x) => { return x + 1 }
    int(int) fg = f(g)
    int x = fg(x)
    print(x) // stdout: 3
}
```

## Grammar

```
-- programs ------------------------------------------------

entrypoints Program ;

Program.   Program ::= [FunDef] ;

FunDef.    FunDef ::= Type Ident "(" [Arg] ")" Block ;

separator nonempty FunDef "" ;

Arg.       Arg ::= Type Ident ;

separator  Arg "," ;

-- statements ----------------------------------------------

Block.     Block ::= "{" [Stmt] "}" ;

separator  Stmt "" ;

Empty.     Stmt ::= ";" ;

BStmt.     Stmt ::= Block ;

FunStmt.   Stmt ::= FunDef ;

Init.      Stmt ::= Type Ident "=" Expr ;

Ass.       Stmt ::= Ident "=" Expr ;

Incr.      Stmt ::= Ident "++" ;

Decr.      Stmt ::= Ident "--" ;

Ret.       Stmt ::= "return" Expr ;

VRet.      Stmt ::= "return" ;

Cond.      Stmt ::= "if" "(" Expr ")" Stmt  ;

CondElse.  Stmt ::= "if" "(" Expr ")" Stmt "else" Stmt  ;

While.     Stmt ::= "while" "(" Expr ")" Stmt ;

For.       Stmt ::= "for" Type Ident "=" Expr "to" Expr Block ;

Print.     Stmt ::= "print" "(" Expr ")" ;

SExp.      Stmt ::= Expr ;

-- Types ---------------------------------------------------

IntT.       Type ::= "int" ;

StrT.       Type ::= "string" ;

BoolT.      Type ::= "boolean" ;

VoidT.      Type ::= "void" ;

FunT.       Type ::= Type "(" [Type] ")" ;

separator  Type "," ;

-- Expressions ---------------------------------------------

EVar.      Expr7 ::= Ident ;

ELitInt.   Expr7 ::= Integer ;

ELitTrue.  Expr7 ::= "true" ;

ELitFalse. Expr7 ::= "false" ;

EApp.      Expr7 ::= Ident "(" [Expr] ")" ;

EString.   Expr7 ::= String ;

Neg.       Expr6 ::= "-" Expr6 ;

Not.       Expr6 ::= "!" Expr6 ;

EMul.      Expr4 ::= Expr4 MulOp Expr5 ;

EAdd.      Expr3 ::= Expr3 AddOp Expr4 ;

ERel.      Expr2 ::= Expr2 RelOp Expr3 ;

ELogic.    Expr1  ::= Expr2 LogicOp Expr1 ;

ELambda.   Expr  ::= "(" [Arg] ")" "=>" Block ;

coercions  Expr 7 ;

separator  Expr "," ;

-- operators -----------------------------------------------

Plus.      AddOp ::= "+" ;

Minus.     AddOp ::= "-" ;

Times.     MulOp ::= "*" ;

Div.       MulOp ::= "/" ;

Mod.       MulOp ::= "%" ;

LTH.       RelOp ::= "<" ;

LE.        RelOp ::= "<=" ;

GTH.       RelOp ::= ">" ;

GE.        RelOp ::= ">=" ;

EQU.       RelOp ::= "==" ;

NE.        RelOp ::= "!=" ;

And.       LogicOp ::= "&&" ;

Or.        LogicOp ::= "||" ;

-- comments ------------------------------------------------

comment    "#" ;

comment    "//" ;

comment    "/*" "*/" ;

```
