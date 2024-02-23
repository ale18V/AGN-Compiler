%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <bits/stdc++.h>
#define newcn(name) struct CodeNode* name = new CodeNode 

extern int yylex();
extern FILE* yyin;
int idx = 0;
int startLabelIdx = 0, endLabelIdx = 0;

void yyerror(const char *s);
enum Type { Integer, Array };

stack<pair<string, string>> labelStack;

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
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

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes.

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

void yyerror(const char* s);
using namespace std;

string sep = string(", ");
struct CodeNode {
	string code;
	string val;
};

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

%type <code_node> program statements statement type write-statement read-statement function-declaration function-parameters function-parameters-sequence return-type return-statement 
%type <code_node> variable-declaration variable-sequence variable-assignment if-statement while-statement expression func-call-params

%type <op_val> NUM, IDENT
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
			node->code = std::string(":= ") + std::string(symbol_table.back());
			$$ = node;
		}
		| BREAK SEMICOLON			{
		
			////////////////
		}
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
	node->code = std::string("ret ") + std::string($2) +  std::string("\n");

	$$=node;
}
| RETURN SEMICOLON {
	struct CodeNode* node = new CodeNode;
	node->code = std::string("ret") +  std::string("\n");

	$$=node;
};





// --- VARIABLES GRAMMAR ---
variable-declaration: type variable-sequence SEMICOLON {$$ = $2}
					
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
if-statement: IF {
	string startLabelName = string("label_") + to_string(startLabelIdx); 
	string endLabelName = string("label_") + to_string(endLabelIdx);
	labelStack.push({startLabelName, endLabelName});
	} expression LEFTCURLY statements RIGHTCURLY {
		newcn(node);
		auto stacktop = labelStack.top();
		node->code = $3->code;
		node->code += string("?:= ") + stacktop.first + sep + $3->val + string("\n"); 
		node->code += string(":= ") + stacktop.second + string("\n");
		node->code += string(": ") + stacktop.first + string("\n");
		node->code += $5->code;
		node->code += string(": ") + stacktop.second + string("\n");
		$$ = node;
		labelStack.pop();
	}
| IF {
	string startLabelName = string("label_") + to_string(startLabelIdx); 
	string endLabelName = string("label_") + to_string(endLabelIdx);
	labelStack.push({startLabelName, endLabelName});
	} expression LEFTCURLY statements RIGHTCURLY ELSE LEFTCURLY statements RIGHTCURLY	
	{
		newcn(node);
		auto stacktop = labelStack.top();
		node->code = $3->code;
		node->code += string("?:= ") + stacktop.first + sep + $3->val + string("\n"); 
		node->code += string(":= ") + stacktop.second + string("\n");
		node->code += string(": ") + stacktop.first + string("\n");
		node->code += $5->code;
		node->code += string(": ") + stacktop.second + string("\n");
		$$ = node;
	}





// --- LOOPS GRAMMAR ---
while-statement: WHILE expression LEFTCURLY statements RIGHTCURLY {
	nstruct CodeNode* node = new CodeNode;
	node->code = std::string("[]= ") + std::string($1) + std::string($6) +  std::string("\n");

	$$ = node;
	
}



// --- MATHS GRAMMAR ---
expression: NOT expression %prec NOT				 		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $2->code;
			node->code += string("! ") + val + sep + $2->val + string("\n");
			node->val = val;
			$$ = node;
		}
		| MINUS expression %prec NEG						{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $2->code;
			node->code += string("* ") + val + sep + $2->val + sep + "-1" + string("\n"); // Multiply by -1 to get negative. Ugly
			node->val = val;
			$$ = node;
		}
		| expression LLAND expression                  		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("&& ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LLOR expression                   		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("|| ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LLXOR expression                  		{
			newcn(node);
			// TODO
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("&& ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LT expression                     		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("< ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression LTEQ expression                   		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("<= ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression GT expression                     		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("> ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression GTEQ expression                   		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string(">= ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression EQ expression                     		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("== ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression NOTEQ expression                  		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("!= ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression MODULUS expression                		{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("% ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression PLUS expression                    	{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("+ ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression MINUS expression                   	{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("- ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression MULTIPLY expression                	{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $1->code + $3->code;
			node->code += string("* ") + val + sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
    	| expression DIVIDE expression						{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
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
		| IDENT LEFTPAREN func-call-params RIGHTPAREN	{puts("expression -> IDENT LEFTPAREN expression-sequence  RIGHTPAREN");}
		| IDENT LEFTPAREN RIGHTPAREN {
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = string("call ") + $1->val + sep + val + string("\n");
			node->val = val;
			$$ = node;
		}
		| IDENT LEFTBRACKET expression RIGHTBRACKET			{
			newcn(node);
			string val = string("_tmp_") + to_string(++index);
			node->code = $3->code;
			node->code += string("=[] ") + val +  sep + $1->val + sep + $3->val + string("\n");
			node->val = val;
			$$ = node;
		}
		| IDENT												{
			struct CodeNode* node = new CodeNode; 
			node->val = $1;
			$$ = node;
		}
		| NUM												{
			struct CodeNode* node = new CodeNode; 
			node->val = $1;
			$$ = node;
		};


func-call-params: expression COMMA func-call-params {
			newcn(node);
			node->code = $1->code;
			node->code += string("param ") + $1->val + string("\n");
			node->code += $3->code;
			$$ = node;
		}
		| expression {
			newcn(node);
			nocde->code = $1->code;
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
  exit(1);
}

