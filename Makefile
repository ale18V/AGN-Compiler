all: parser clean generate 

parser: lexer.yy.c parser.tab.c parser.tab.h
	g++ -std=c++17 -O2 -g -o parser.bin parser.tab.c lexer.yy.c -lm

%.yy.c: %.lex
	flex -o$@ $<

%.tab.c %.tab.h: %.y
	bison -t -v -d $<

clean:
	-rm -f *.tab.c *.tab.h *.yy.c *.output

generate:
	-bash -c 'for file in Examples/* ; do  echo $$file; ./parser.bin < $$file > Outputs/Intermediate/$$(basename -s .agn $$file).mil; done'

run:	
	-bash -c 'for file in Outputs/Intermediate/* ; do  echo $$file; ./mil_run  $$file ; done'
