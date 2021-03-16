.PHONY : all clean distclean

all : interpreter

interpreter : Interpreter.hs Evaluator.hs ErrM.hs LexEspresso.hs ParEspresso.hs PrintEspresso.hs
	ghc --make $< -o $@

clean :
	-rm -f *.hi *.o *.log *.aux *.dvi

distclean : clean
	-rm -f AbsEspresso.hs AbsEspresso.hs.bak ComposOp.hs ComposOp.hs.bak DocEspresso.txt DocEspresso.txt.bak ErrM.hs ErrM.hs.bak LayoutEspresso.hs LayoutEspresso.hs.bak LexEspresso.x LexEspresso.x.bak ParEspresso.y ParEspresso.y.bak PrintEspresso.hs PrintEspresso.hs.bak SharedString.hs SharedString.hs.bak Evaluator.hs Evaluator.hs.bak Interpreter.hs Interpreter.hs.bak XMLEspresso.hs XMLEspresso.hs.bak ASTEspresso.agda ASTEspresso.agda.bak ParserEspresso.agda ParserEspresso.agda.bak IOLib.agda IOLib.agda.bak Main.agda Main.agda.bak Espresso.dtd Espresso.dtd.bak Interpreter LexEspresso.hs ParEspresso.hs ParEspresso.info ParDataEspresso.hs Makefile

# EOF
