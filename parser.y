%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <string>
#include <stack>
#include <vector> 
using namespace std;

void yyerror(const char* s);
int yylex();
extern FILE* yyin;

enum Type { Integer, Array };

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

// Code variables
int idx = 0;
int startLabelIdx = 0, endLabelIdx = 0;
string sep = string(", ");
stack<pair<string, string>> labelStack;
vector <Function> symbol_table;


// Symbol table functions
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

bool find(std::string &value) {
	bool find = false;
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      if(find) yyerror("Multiple declarations of same variable.\n");
	  find = true;
    }
  }
  return find;
}

void add_function_to_symbol_table(std::string const &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string const &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%code requires {
	#include "code_node.h"
}
%locations
%define api.value.type { struct CodeNode* }
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

%start program

%%

program: statements {
			cout << $1->code;
		}
		| %empty {};

statements: statement statements {
			newcn(node);
			node->code = $1->code + $2->code;
			$$ = node;
		}
		|	statement {
			$$ = $1;
		};

statement: function-declaration		{$$ = $1;}
		| variable-declaration		{$$ = $1;}
		| variable-assignment		{$$ = $1;}
		| if-statement				{$$ = $1;}
		| while-statement			{$$ = $1;}
		| return-statement			{$$ = $1;}
		| write-statement			{$$ = $1;}
		| read-statement			{$$ = $1;}
		| CONTINUE SEMICOLON		{
			struct CodeNode* node = new CodeNode;
			node->code = std::string(":= ") + std::string(labelStack.top().first);
			$$ = node;
		}
		| BREAK SEMICOLON			{
			struct CodeNode* node = new CodeNode;
			node->code = std::string(":= ") + std::string(labelStack.top().second);
			$$ = node;
		}
		;

type: INT {puts("type -> INT");};

// --- INPUT / OUTPUT ---
write-statement: WRITE LEFTPAREN expression RIGHTPAREN SEMICOLON {

	struct CodeNode* node = new CodeNode;
	struct CodeNode* expression = $3;
	node->code = std::string(". > ");
	node->code += expression->code;
	$$ = node;

}

read-statement: READ LEFTPAREN expression RIGHTPAREN SEMICOLON{

	struct CodeNode* node = new CodeNode;
	struct CodeNode* expression = $3;
	node->code = std::string(". < ");
	node->code += expression->code;
	$$ = node;

}

// --- FUNCTION GRAMMAR ---
function-declaration: DEFINE IDENT AS LEFTPAREN function-parameters RIGHTPAREN ARROW return-type LEFTCURLY statements RIGHTCURLY {
	
	struct CodeNode* node = new CodeNode;
	struct CodeNode* statements = $10;
	node->code = std::string("func ") + std::string($2->val) + std::string("\n");
	node->code += statements->code;
	node->code+= std::string("endfunc\n\n");
	add_function_to_symbol_table($2->val);
	$$ = node;

};

function-parameters:  function-parameters-sequence	{
			$$ = $1;
		}
		| %empty						{};





function-parameters-sequence: type IDENT COMMA function-parameters	{
			struct CodeNode* node = new CodeNode;
			$$ = node;
		}
 		| type IDENT	{
			struct CodeNode* node = new CodeNode;
  			$$ = node;
  		};


return-type:  type{
	$$ = new CodeNode;
} 
| %empty{
	$$ = new CodeNode;
};





return-statement: RETURN expression SEMICOLON	{
	struct CodeNode* node = new CodeNode;
	node->code = std::string("ret ") + std::string($2->code) +  std::string("\n");

	$$=node;
}
| RETURN SEMICOLON {
	struct CodeNode* node = new CodeNode;
	node->code = std::string("ret") +  std::string("\n");

	$$=node;
};





// --- VARIABLES GRAMMAR ---
variable-declaration: type variable-sequence SEMICOLON {$$ = $2;}
					
| type IDENT ASSIGN expression SEMICOLON {
	
	////ADD VARIABLE TO SYMBOL TABLE
	if(symbol_table.size() == 0){
		struct CodeNode* globalScope = new CodeNode;
		globalScope->val = "GLOBAL";
		add_function_to_symbol_table(globalScope->val);
	}
	add_variable_to_symbol_table($2->val, Integer); 

	struct CodeNode* node = new CodeNode;
	node->code = std::string(". ") + std::string($2->val) + std::string("\n");
	node->code += std::string("= ") + std::string($2->val) + std::string($4->code) +  std::string("\n");
	
	$$=node;
};

| type LEFTBRACKET NUM RIGHTBRACKET IDENT SEMICOLON	{

	////ADD VARIABLE TO SYMBOL TABLE
	if(symbol_table.size() == 0){
                struct CodeNode* globalScope = new CodeNode;
                globalScope->val = "GLOBAL";
                add_function_to_symbol_table(globalScope->val);
        }
	add_variable_to_symbol_table( $5->val , Integer); 


	struct CodeNode* node = new CodeNode;
	node->code = std::string(".[] ") + std::string($5->val) + std::string(", ") + std::string($3->val) +  std::string("\n");

	$$=node;
};





variable-sequence:

IDENT COMMA variable-sequence {
	
	////ADD VARIABLE TO SYMBOL TABLE
	if(symbol_table.size() == 0){
                struct CodeNode* globalScope = new CodeNode;
                globalScope->val = "GLOBAL";
                add_function_to_symbol_table(globalScope->val);
        }
	add_variable_to_symbol_table($1->val, Integer); 

	//assign new node
	struct CodeNode* node = new CodeNode;
	node->code = std::string($1->val) + std::string("\n") + std::string($3->code) +  std::string("\n");
	$$ = node;
}
|IDENT {

	////ADD VARIABLE TO SYMBOL TABLE
	if(symbol_table.size() == 0){
                struct CodeNode* globalScope = new CodeNode;
                globalScope->val = "GLOBAL";
                add_function_to_symbol_table(globalScope->val);
        }
	add_variable_to_symbol_table( $1->val , Integer); 


	$$ = $1;
	
}
	


variable-assignment: 

IDENT ASSIGN expression SEMICOLON {
	struct CodeNode* node = new CodeNode;
	node->code = $3->code;
	node->code += string("= ") + $1->val + sep + $3->val + string("\n");

	$$ = node;
}
|IDENT LEFTBRACKET expression RIGHTBRACKET ASSIGN expression SEMICOLON	{
	//assign new node
	struct CodeNode* node = new CodeNode;
	string dst = $1->val;
	string index = $3->val;
	string src = $6->val;
	node->code = $3->code + $6->code;
	node->code += std::string("[]= ") + dst + sep + index + sep + src + string("\n");

	$$ = node;
}





// --- IF ELSE GRAMMAR ---
if-statement: IF expression LEFTCURLY statements RIGHTCURLY {
		newcn(node);

		string startLabelName = string("start_if_") + std::to_string(++startLabelIdx); 
		string endLabelName = string("end_if_") + std::to_string(++endLabelIdx);
		node->code = $2->code;
		node->code += string("?:= ") + startLabelName + sep + $2->val + string("\n"); 
		node->code += string(":= ") + endLabelName + string("\n");
		node->code += string(": ") + startLabelName + string("\n");
		node->code += $4->code;
		node->code += string(": ") + endLabelName + string("\n");
		$$ = node;
	}
|  	IF  expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY	
	{
		newcn(node);
		string ifLabelName = string("start_if_") + to_string(++startLabelIdx); 
		string elseLabelName = string("start_else_") + to_string(++endLabelIdx);
		string endElseLabelName = string("end_else_") + to_string(++endLabelIdx);
		node->code = $2->code;
		node->code += string("?:= ") + ifLabelName + sep + $2->val + string("\n"); 
		node->code += string(":= ") + elseLabelName + string("\n");
		node->code += string(": ") + ifLabelName + string("\n");
		node->code += $4->code;
		node->code += string(":= ") + endElseLabelName + string("\n");
		node->code += string(": ") + elseLabelName + string("\n");
		node->code += $8->code;
		node->code += string(": ") + endElseLabelName + string("\n");
		$$ = node;
	}





// --- LOOPS GRAMMAR ---
while-statement: WHILE 

{
	string startLabelName = string("start_while_") + to_string(++startLabelIdx); 
	string endLabelName = string("end_while_") + to_string(++endLabelIdx);
	
	labelStack.push({startLabelName, endLabelName});
}

expression LEFTCURLY statements RIGHTCURLY {
	
		newcn(node);
		string startLabelName = labelStack.top().first;
		string endLabelName = labelStack.top().second;


		node->code = string(": ") + startLabelName + string("\n");
		node->code += $3->code;
		node->code += string("! ") + $3->val + sep + $3->val + string("\n"); // Negate the condition
		node->code += string("?:= ") + endLabelName + sep + $3->val + string("\n"); // So you can jump to the end if it's !false = true
		node->code += $5->code;
		node->code += string(":= ") + startLabelName  + string("\n");
		node->code += string(": ") + endLabelName + string("\n");
		$$ = node;
		labelStack.pop();
	
}


// --- MATHS GRAMMAR ---
expression: NOT expression %prec NOT				 		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $2->code;
			node->code += string("! ") + val + sep + $2->val + string("\n");
			node->val = val;
			$$ = node;
		}
		| MINUS expression %prec NEG						{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $2->code;
			node->code += string("* ") + val + sep + $2->val + sep + "-1" + string("\n"); // Multiply by -1 to get negative. Ugly
			node->val = val;
			$$ = node;
		}
		| expression LLAND expression                  		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("&& ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LLOR expression                   		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("|| ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LLXOR expression                  		{
			newcn(node);
			// TODO
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("&& ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LT expression                     		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("< ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LTEQ expression                   		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("<= ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression GT expression                     		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("> ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression GTEQ expression                   		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string(">= ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression EQ expression                     		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("== ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression NOTEQ expression                  		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("!= ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression MODULUS expression                		{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("% ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression PLUS expression                    	{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("+ ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression MINUS expression                   	{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("- ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression MULTIPLY expression                	{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("* ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression DIVIDE expression						{
			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $1->code + $3->code;
			node->code += string("/ ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
		| LEFTPAREN expression RIGHTPAREN					{
			newcn(node);
			node->code = $2->code;
			node->val = $2->val;
			$$ = node;
		}
		| IDENT LEFTPAREN func-call-params RIGHTPAREN	{

			//FIND THE FUNCTION IN SYMBOL TABLE
			std::string func_name = $1->val;
			if(!find(func_name)) yyerror((string("Undeclared function ") + string(func_name)).c_str());
		
		}
		| IDENT LEFTPAREN RIGHTPAREN {

			//FIND THE FUNCTION IN SYMBOL TABLE
			std::string func_name = $1->val;
			if(!find(func_name)) yyerror("Undeclared function.\n");

			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = string("call ") + $1->val + sep + val + string("\n");
			node->val = val;
			$$ = node;
		}
		| IDENT LEFTBRACKET expression RIGHTBRACKET			{

			//FIND THE VARIABLE IN SYMBOL TABLE
			std::string var_name = $1->val;
			if(!find(var_name)) yyerror("Undeclared variable.\n");

			newcn(node);
			string val = string("_tmp_") + to_string(++idx);
			node->code = $3->code;
			node->code += string("=[] ") + val +  sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
		| IDENT { $$ = $1; }
		| NUM { $$ = $1;};


func-call-params: expression COMMA func-call-params {
			newcn(node);
			node->code = $1->code;
			node->code += string("param ") + $1->val + string("\n");
			node->code += $3->code;
			$$ = node;
		}
		| expression {
			newcn(node);
			node->code = $1->code;
			node->code += string("param ") + $1->val + string("\n");
			$$ = node;
		};

%%


int main(int argc, char** argv) {
	yyin = stdin;
	return yyparse();
}

void yyerror(const char* s) {
  fprintf(stderr, "Error encountered while parsing token at [%i,%i %i,%i]: %s\n", yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column, s);
  print_symbol_table();
  fflush(stdout);
  exit(1);
}

