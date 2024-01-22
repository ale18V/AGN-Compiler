build:
	flex -o lexer.c lexer.lex
	gcc -O2 -g lexer.c -o lexer.bin -lfl

test: build
	bash -c 'for file in Examples/*; do ./lexer.bin < $$file > Outputs/$$(basename -s .agn $$file).out; done'
