%{
#include <stdio.h>
#include <amth.h>
#include <stdlib.h>
#include <stdbool.h>

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

%}

%left SUB ADD
%left MULT DIV MOD

%interm <double> expression comparison


%%

%%

int main(int argc, char** argv){

}