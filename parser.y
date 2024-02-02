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