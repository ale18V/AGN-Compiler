all: parser clean test 

parser: lexer.yy.c parser.tab.c parser.tab.h
	gcc -O2 -g -o parser parser.tab.c lexer.yy.c -lfl -lm

%.yy.c: %.lex
	flex -o$@ $<

%.tab.c %.tab.h: %.y
	bison -t -v -d $<

clean:
	-rm -f *.tab.c *.tab.h *.yy.c *.output print_lexer parser print_parser

test:
	-bash -c 'for file in Examples/* ; do ./parser < $$file > Outputs/Parser/$$(basename -s .agn $$file).out; done'
