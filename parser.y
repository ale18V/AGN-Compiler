%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <vector>

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

struct CodeNode {
	std::string code;
	std::string name;
};

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
%token NUM IDENT 

%left LLAND LLOR LLXOR 
%left LT LTEQ GT GTEQ EQ NOTEQ 
%left NOT
%left MODULUS
%left PLUS MINUS 
%left MULTIPLY DIVIDE 
%left NEG

%nterm expression

%start program

%%



program: statements | %empty;

statements: statement statements {puts("statements -> statement statements");}
		|	statement {puts("statements -> statement");};

statement: function-declaration		{$$ = $1;}
		| variable-declaration		{$$ = $1;}
		| variable-assignment		{$$ = $1;}
		| if-statement				{$$ = $1;}
		| while-statement			{$$ = $1;}
		| return-statement			{$$ = $1;}
		| write-statement			{$$ = $1;}
		| read-statement			{$$ = $1;}
		| CONTINUE SEMICOLON		{$$ = $1;}
		| BREAK SEMICOLON			{$$ = $1;}
		;

type: INT {puts("type -> INT");};

// --- INPUT / OUTPUT ---
write-statement: WRITE LEFTPAREN expression RIGHTPAREN SEMICOLON

read-statement: READ LEFTPAREN expression RIGHTPAREN SEMICOLON

// --- FUNCTION GRAMMAR ---
function-declaration: DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements RIGHTCURLY {
	puts("function-declaration -> DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements RIGHTCURLY");
};

function-parameters:  function-parameters-sequence	{puts("function-parameters -> function-parameters-sequence");}
					| %empty						{puts("function-parameters -> ");};





function-parameters-sequence: type IDENT COMMA function-parameters	{

	struct CodeNode* node = new CodeNode;
	node->code = std::string("param ") + std::string($2) +  std::string("\n") +  std::string($4) +  std::string("\n"); //do we need the newline? if so, then every command should have a newline

	$$=node;
}
| type IDENT {
	struct CodeNode* node = new CodeNode;
	node->code = std::string("param ") + std::string($2) +  std::string("\n");

	$$=node;
}



// "  param $2 $4  "

return-type: 

type{
	puts("return-type -> type");
} 
			
| %empty{
	puts("return-type -> ");
};





return-statement: 

RETURN expression SEMICOLON	{
	struct CodeNode* node = new CodeNode;
	node->code = std::string("ret ") + std::string($2) +  std::string("\n");

	$$=node;
}
| RETURN SEMICOLON {
	struct CodeNode* node = new CodeNode;
	node->code = std::string("ret") +  std::string("\n");

	$$=node;
};





// --- VARIABLES GRAMMAR ---
variable-declaration: 

type variable-sequence SEMICOLON {$$ = $2}
					
| type IDENT ASSIGN expression SEMICOLON {
	struct CodeNode* node = new CodeNode;
	node->code = std::string(". ") + std::string($2) + std::string("\n");
	node->code += std::string("= ") + std::string($2) + std::string($4) +  std::string("\n");

	$$=node;
};

| type LEFTBRACKET NUM RIGHTBRACKET IDENT SEMICOLON	{
	struct CodeNode* node = new CodeNode;
	node->code = std::string(".[] ") + std::string($5) + std::string(", ") + std::string($3) +  std::string("\n");

	$$=node;
};





variable-sequence:

IDENT COMMA variable-sequence {
	
	//assign new node
	struct CodeNode* node = new CodeNode;
	node->code = std::string($1) + std::string("\n") + std::string($3) +  std::string("\n");
	$$ = node;
}
|IDENT {$$ = $1;}
	




variable-assignment: 

IDENT ASSIGN expression SEMICOLON {
	//assign new node
	struct CodeNode* node = new CodeNode;
	node->code = std::string("= ") + std::string($1) + std::string($3) +  std::string("\n");

	$$ = node;
}
|IDENT LEFTBRACKET expression RIGHTBRACKET ASSIGN expression SEMICOLON	{
	//assign new node
	struct CodeNode* node = new CodeNode;
	node->code += std::string("[]= ") + std::string($1) + std::string($6) +  std::string("\n");

	$$ = node;
}





// --- IF ELSE GRAMMAR ---
if-statement: IF expression LEFTCURLY statements RIGHTCURLY											{puts("if-statement -> IF expression LEFTCURLY statements RIGHTCURLY");}
			| IF expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY	{puts("if-statement -> IF expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY");}





// --- LOOPS GRAMMAR ---
while-statement: WHILE expression LEFTCURLY statements RIGHTCURLY {puts("while-statement -> WHILE expression LEFTCURLY statements RIGHTCURLY");}



// --- MATHS GRAMMAR ---
expression: NOT expression %prec NOT				 		{puts("expression -> NOT expression");}
		| MINUS expression %prec NEG						{puts("expression -> MINUS expression");}
		| expression LLAND expression                  		{puts("expression -> expression LLAND expression"); }
    	| expression LLOR expression                   		{puts("expression -> expression LLOR expression"); }
    	| expression LLXOR expression                  		{puts("expression -> expression LLXOR expression"); }
    	| expression LT expression                     		{puts("expression -> expression LT expression"); }
    	| expression LTEQ expression                   		{puts("expression -> expression LTEQ expression"); }
    	| expression GT expression                     		{puts("expression -> expression GT expression"); }
    	| expression GTEQ expression                   		{puts("expression -> expression GTEQ expression"); }
    	| expression EQ expression                     		{puts("expression -> expression EQ expression"); }
    	| expression NOTEQ expression                  		{puts("expression -> expression NOTEQ expression"); }
    	| expression MODULUS expression                		{puts("expression -> expression MODULUS expression"); }
    	| expression PLUS expression                    	{
		
		$$ = "+ $3 $1 $2"
		
		
		
		}
    	| expression MINUS expression                   	{puts("expression -> expression MINUS expression"); }
    	| expression MULTIPLY expression                	{puts("expression -> expression MULTIPLY expression"); }
    	| expression DIVIDE expression
		| LEFTPAREN expression RIGHTPAREN					{puts("expression -> LEFTPAREN expression RIGHTPAREN");}
		| IDENT LEFTPAREN expression-sequence RIGHTPAREN	{puts("expression -> IDENT LEFTPAREN expression-sequence  RIGHTPAREN");}
		| IDENT LEFTBRACKET expression RIGHTBRACKET			{puts("expression -> IDENT LEFTBRACKET expression RIGHTBRACKET");}
		| IDENT												{puts("expression -> IDENT");}
		| NUM												{puts("expression -> NUM");};


expression-sequence: expression COMMA expression-sequence {puts("expression-sequence -> expression COMMA expression-sequence");}
		| expression {puts("expression-sequence -> expression");};

%%


int main(int argc, char** argv) {
	yyin = stdin;
	return yyparse();
}

void yyerror(const char* s) {
  fprintf(stderr, "Error encountered while parsing token at [%i,%i %i,%i]: %s\n", yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column, s);
  exit(1);
}

