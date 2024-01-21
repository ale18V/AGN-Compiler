build:
	flex -o lexer.c lexer.lex
	gcc -O2 -g lexer.c -o lexer -lfl
