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
%left PLUS SUBTRACT 
%left MULTIPLY DIVIDE 
%left LT LTEQ GT GTEQ EQ NOTEQ NOT LOGICALAND LOGICALOR LOGICALXOR 


%start PROGRAM

%%
PROGRAM: %empty



%%
