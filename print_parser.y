%{
#include <stdio.h>
#include <amth.h>
#include <stdlib.h>
#include <stdbool.h>

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

%}

%locations
%define api.value.type union
%define parse.error verbose
%define parse.lac full

%left SUB ADD
%left MULT DIV MOD

%interm <double> expression comparison function variable

%start program

%%
program: program function | %empty ;



variable: IDENT | IDENT LEFTBRACKET expression RIGHTBRACKET ;

term: variable | NUM | LEFTPAREN expression RIGHTPAREN ;

multipliexp : term | term MULT term | term DIV term | term MOD term ;

expression: multiexp | multiexp ADD multiexp | multiexp SUB multiexp ;

comparison: LT | LTEQ | GT | GTEQ | EQ ;

boolexp: 

%%

int main(int argc, char** argv){

}