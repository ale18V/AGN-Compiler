build:
	flex lexer.lex -o lexer.c
	gcc -O2 -g lexer.c -o lexer -lfl
