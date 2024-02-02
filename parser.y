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

%token DEFINE AS RETURN INT PRINT READ WHILE IF ELSE BREAK CONTINUE LOGICALAND LOGICALOR LOGICALXOR LEFTPAREN RIGHTPAREN LEFTCURLY RIGHTCURLY LEFTBRACKET RIGHTBRACKET
%token ARROW COMMA SEMICOLON PLUS SUBTRACT MULTIPLY DIVIDE MODULUS ASSIGN LESS LESSEQUAL GREATER GREATEREQUAL EQUALITY NOTEQUAL NOT NUM IDENT COMMENT WHITESPACE

%start program

%%
program: program function | %empty ;



variable: IDENT | IDENT LEFTBRACKET expression RIGHTBRACKET ;

term: variable | NUM | LEFTPAREN expression RIGHTPAREN ;

multipliexp : term | term MULT term | term DIV term | term MOD term ;

expression: multiexp | multiexp ADD multiexp | multiexp SUB multiexp ;

comparison: LT | LTEQ | GT | GTEQ | EQ ;

boolexp: NOT expression comparison expression | expression comparision expression ;

statement: variable ASSIGN expression
		| CONTINUE
		| BREAK
		| RETURN expression
%%