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

%left MODULUS
%left LT LTEQ GT GTEQ EQ NOTEQ LLAND LLOR LLXOR 
%left PLUS SUBTRACT 
%left MULTIPLY DIVIDE 
%left NOT

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
		| %empty
		| statement statement
		| CONTINUE
		| BREAK
		| RETURN expression
		| IF boolexp LEFTCURLY statement SEMICOLON RIGHTCURLY
		| IF boolexp LEFTCURLY statement SEMICOLON RIGHTCURLY ELSE LEFTCURLY statement SEMICOLON RIGHTCURLY
		;
		
%%

