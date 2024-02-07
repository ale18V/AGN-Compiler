%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

%}

%locations
%define api.value.type union
%define parse.error verbose
%define parse.lac full

%token DEFINE ARROW AS RETURN 
%token WRITE READ 
%token WHILE IF ELSE BREAK CONTINUE 
%token INT ASSIGN
%token LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY LEFTBRACKET RIGHTBRACKET
%token COMMA SEMICOLON 
%token <int> NUM IDENT 

%left LT LTEQ GT GTEQ EQ NOTEQ LLAND LLOR LLXOR 
%left MODULUS
%left PLUS MINUS 
%left MULTIPLY DIVIDE 
%left NOT

%nterm <int> expression

%start program

%%

program: statements | %empty;

statements: statement statements {puts("statements -> statement statements");}
		|	statement {puts("statements -> statement");};

statement: function-declaration {puts("statement -> function-declaration");}
		| variable-declaration {puts("statement -> variable-declaration");}
		| variable-assignment {puts("statement -> variable-assignment");}
		| if-statement {puts("statement -> if-statement");}
		| while-statement {puts("statement -> while-statement");}
		| return-statement {puts("statement -> return-statement");}
		| write-statement {puts("statement -> print-statement");}
		| read-statement {puts("statement -> write-statement");}
		| CONTINUE SEMICOLON {puts("statement -> CONTINUE SEMICOLON");}
		| BREAK SEMICOLON {puts("statement -> BREAK SEMICOLON");}
		;

type: INT {puts("type -> INT");};

// --- INPUT / OUTPUT ---
write-statement: WRITE LEFTPAREN expression RIGHTPAREN SEMICOLON

read-statement: READ LEFTPAREN expression RIGHTPAREN SEMICOLON

// --- FUNCTION GRAMMAR ---
function-declaration: DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements RIGHTCURLY {
	puts("function-declaration -> DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements RIGHTCURLY");
};

function-parameters: function-parameters-sequence {puts("function-parameters -> function-parameters-sequence");}
		| %empty {puts("function-parameters -> ");};

function-parameters-sequence: type IDENT COMMA function-parameters {puts("function-parameters -> type IDENT COMMA function-parameters");}
		| type IDENT {puts("function-parameters -> type IDENT");}

return-type: type {puts("return-type -> type");} 
		| %empty {puts("return-type -> ");};

return-statement: RETURN expression SEMICOLON {puts("return-statement -> RETURN expression SEMICOLON");}
		| RETURN SEMICOLON {puts("return-statement -> RETURN SEMICOLON");};

// --- VARIABLES GRAMMAR ---
variable-declaration: type variable-sequence SEMICOLON 
		| type IDENT ASSIGN expression SEMICOLON {puts("variable-declaration -> type IDENT ASSIGN expression SEMICOLON");};

variable-sequence: IDENT COMMA variable-sequence {puts("variable-sequence -> IDENT COMMA variable-sequence");}
		| IDENT {puts("variable-sequence -> IDENT");};
	
variable-assignment: IDENT ASSIGN expression SEMICOLON {puts("variable-assignment -> IDENT ASSIGN expression SEMICOLON");}

// --- IF ELSE GRAMMAR ---
if-statement: IF expression LEFTCURLY statements RIGHTCURLY {puts("if-statement -> IF expression LEFTCURLY statements RIGHTCURLY");}
		| IF expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY {puts("if-statement -> IF expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY");}

// --- LOOPS GRAMMAR ---
while-statement: WHILE expression LEFTCURLY statements RIGHTCURLY {puts("while-statement -> WHILE expression LEFTCURLY statements RIGHTCURLY");}

// --- MATHS GRAMMAR ---
expression: expression binary-operator expression {puts("expression -> expression binary-operator expression");}
		| NOT expression {puts("expression -> NOT expression");}
		| LEFTPAREN expression RIGHTPAREN {puts("expression -> LEFTPAREN expression RIGHTPAREN");}
		| IDENT LEFTPAREN expression RIGHTPAREN  {puts("expression -> IDENT LEFTPAREN expression RIGHTPAREN");}
		| IDENT LEFTBRACKET expression RIGHTBRACKET {puts("expression -> IDENT LEFTBRACKET expression RIGHTBRACKET");}
		| IDENT {puts("expression -> IDENT");}
		| NUM {puts("expression -> NUM");};

unary-operator: NOT {puts("unary-operator -> NOT");}; 

binary-operator: comparison-operator {puts("binary-operator -> comparison-operator");}
		| arithmetic-operator {puts("binary-operator -> arithmetic-operator");}
		| LLAND {puts("binary-operator -> LLAND");}
		| LLOR {puts("binary-operator -> LLOR");}
		| LLXOR {puts("binary-operator -> LLXOR");};

comparison-operator: LT {puts("comparison-operator -> LT");}
		| LTEQ {puts("comparison-operator -> LTEQ");}
		| GT {puts("comparison-operator -> GT");}
		| GTEQ {puts("comparison-operator -> GTEQ");}
		| EQ {puts("comparison-operator -> EQ");}
		| NOTEQ {puts("comparison-operator -> NOTEQ");};

arithmetic-operator: PLUS {puts("arithmetic-operator -> PLUS");}
		| MINUS {puts("arithmetic-operator -> MINUS");}
		| MULTIPLY {puts("arithmetic-operator -> MULTIPLY");}
		| DIVIDE {puts("arithmetic-operator -> DIVIDE");}
		| MODULUS {puts("arithmetic-operator -> MODULUS");};
	
%%


int main(int argc, char** argv) {
	yyin = stdin;
	return yyparse();
}

void yyerror(const char* s) {
  fprintf(stderr, "Error encountered while parsing token at [%i,%i-%i,%i]: %s\n", yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column, s);
  exit(1);
}

