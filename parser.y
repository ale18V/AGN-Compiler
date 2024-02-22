%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);
using namespace std;

struct CodeNode {
	string code;
	string name;
}

%}

%locations
%define api.value.type union
%define parse.error verbose
%define parse.lac full

%union {
	char* op_val;
	struct CodeNode* code_node;	
}

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

%nterm <code_node> program statements statement type write-statement read-statement function-declaration function-parameters function-parameters-sequence return-type return-statement 
%nterm <code_node> variable-declaration variable-sequence variable-assignment if-statement while-statement expression expression-sequence

%start program

%%

program: statements | %empty;

statements: statement statements {puts("statements -> statement statements");}
		|	statement {puts("statements -> statement");};

statement: function-declaration		{puts("statement -> function-declaration");}
		| variable-declaration		{puts("statement -> variable-declaration");}
		| variable-assignment		{puts("statement -> variable-assignment");}
		| if-statement				{puts("statement -> if-statement");}
		| while-statement			{puts("statement -> while-statement");}
		| return-statement			{puts("statement -> return-statement");}
		| write-statement			{puts("statement -> print-statement");}
		| read-statement			{puts("statement -> write-statement");}
		| CONTINUE SEMICOLON		{puts("statement -> CONTINUE SEMICOLON");}
		| BREAK SEMICOLON			{puts("statement -> BREAK SEMICOLON");}
		;

type: INT {puts("type -> INT");};

// --- INPUT / OUTPUT ---
write-statement: WRITE LEFTPAREN expression RIGHTPAREN SEMICOLON {

	struct CodeNode* node = new CodeNode;
	struct CodeNode* expression = $3;
	node->code std::string(". > ")
	node->code += expression->code;
	$$ = node;

}

read-statement: READ LEFTPAREN expression RIGHTPAREN SEMICOLON{

	struct CodeNode* node = new CodeNode;
	struct CodeNode* expression = $3;
	node->code std::string(". < ")
	node->code += expression->code;
	$$ = node;

}

// --- FUNCTION GRAMMAR ---
function-declaration: DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements RIGHTCURLY {
	
	struct CodeNode* node = new CodeNode;
	struct CodeNode* statements = $10
	node->code = std::string("func ") + std::string($2) + std::string("\n");
	node->code += statements->code;
	node->code+= std::string("endfunc\n\n");
	$$ = node;

};

function-parameters:  function-parameters-sequence	{
	$$ = $1;
}
					| %empty						{};





function-parameters-sequence: type IDENT COMMA function-parameters	{

	struct CodeNode* node = new CodeNode;
	node->code = std::string("param ") + std::string($2) + std::string("\n") + std::string($4);
	$$ = node;
}
							| type IDENT							{struct CodeNode* node = new CodeNode;
																	node->code = std::string("param ") + std::string($2) + std::string("\n");
																	$$ = node;}





return-type: type		{puts("return-type -> type");} 
			| %empty	{puts("return-type -> ");};





return-statement: RETURN expression SEMICOLON	{puts("return-statement -> RETURN expression SEMICOLON");}
				| RETURN SEMICOLON				{puts("return-statement -> RETURN SEMICOLON");};





// --- VARIABLES GRAMMAR ---
variable-declaration: type variable-sequence SEMICOLON 
					| type IDENT ASSIGN expression SEMICOLON							{puts("variable-declaration -> type IDENT ASSIGN expression SEMICOLON");};
					| type LEFTBRACKET NUM RIGHTBRACKET IDENT SEMICOLON	{puts("variable-declaration -> type LEFTBRACKET NUM RIGHTPAREN ASSIGN expression SEMICOLON");};





variable-sequence:IDENT COMMA variable-sequence {puts("variable-sequence -> IDENT COMMA variable-sequence");}
				| IDENT							{puts("variable-sequence -> IDENT");};
	




variable-assignment: IDENT ASSIGN expression SEMICOLON									{puts("variable-assignment -> IDENT ASSIGN expression SEMICOLON");}
					|IDENT LEFTBRACKET expression RIGHTBRACKET ASSIGN expression SEMICOLON	{puts("variable-assignment -> IDENT LEFTPAREN expression RIGHTPAREN ASSIGN expression SEMICOLON");}





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
    	| expression PLUS expression                    	{puts("expression -> expression PLUS expression"); }
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

