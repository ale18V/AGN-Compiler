%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

int paren_count = 0;
%}

%locations
%define api.value.type union
%define parse.error verbose
%define parse.lac full

%token DEFINE ARROW AS RETURN 
%token PRINT READ 
%token WHILE IF ELSE BREAK CONTINUE 
%token INT ASSIGN
%token LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY LEFTBRACKET RIGHTBRACKET
%token COMMA SEMICOLON 
%token NUM IDENT 

%left LT LTEQ GT GTEQ EQ NOTEQ LLAND LLOR LLXOR 
%left MODULUS
%left PLUS MINUS 
%left MULTIPLY DIVIDE 
%left NOT

%start program

%%

program: statements | %empty;

statements: statement statements | statement;

statement: function-declaration
		| variable-declaration
		| if-statement
		| while-statement
		| return-statement
		| CONTINUE SEMICOLON
		| BREAK SEMICOLON
		;

type: INT;

// --- FUNCTION GRAMMAR ---

function-declaration: DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements return-statement RIGHTCURLY;

function-parameters: type IDENT COMMA function-parameters | %empty;

return-type: type | %empty;

return-statement: RETURN expression SEMICOLON | RETURN SEMICOLON;

// --- VARIABLES GRAMMAR ---
variable-declaration: type IDENT SEMICOLON 
		| type IDENT ASSIGN expression SEMICOLON;


// --- IF ELSE GRAMMAR ---
if-statement: IF expression LEFTCURLY statements RIGHTCURLY
		| IF expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY

// --- LOOPS GRAMMAR ---
while-statement: WHILE expression LEFTCURLY statements RIGHTCURLY


// --- MATHS GRAMMAR ---
expression: unary-operator expression | expression binary-operator expression | ( expression ) | operand;

operand: IDENT | NUM | IDENT LEFTBRACKET expression RIGHTBRACKET;

unary-operator: NOT | MINUS; 

binary-operator: comparison-operator | arithmetic-operator | LLAND | LLOR | LLXOR;

comparison-operator: LT | LTEQ | GT | GTEQ | EQ | NOTEQ;

arithmetic-operator: PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS;
	
%%

