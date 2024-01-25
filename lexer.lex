%{
#include <stdio.h>
#include <string.h>
//THIS IS WHERE WE IMPLEMENT THE ROW AND COLUMN COUNTER
//ROW IS INCREMENTED WHEN A "\N" SYMBOL IS FOUND
//COLUMN IS INCREMENTED EACH TIME THE LOOP IS ITERATED
int nrow = 1, ncol = 1;

#define YY_USER_ACTION ncol += yyleng;

//ALSO THERE IS A WAY TO FEED A FILE INTO THE LEXER USING "a.out < code.file"
%}

Define              define
As                  as                          
Return              return                        
Int                 int                              
Print               write                          
Read                read                            
While               while                          
If                  if                              
Else                else                            
Break               break                          
Continue            continue
LogicalAnd          and
LogicalOr           or
LogicalXor          xor                    
LeftParen           \(                          
RightParen          \)                         
LeftCurly           \{                          
RightCurly          \}                         
LeftBracket         \[                        
RightBracket        \]
Arrow               ->                       
Comma               ,                                  
Semicolon           ;                          
Plus                \+                                   
Subtract            -                           
Multiply            \*                           
Divide              \/                             
Modulus             %                            
Assign              =                             
Less                <                               
LessEqual           <=                         
Greater             >                            
GreaterEqual        >=                      
Equality            == 
NotEqual            !=   
Not					!
Ident               [a-zA-Z]+[a-zA-Z_0-9]*
IncorrectIdent      [_0-9]+{Ident}?
Comment             \/\/.*\n
WhiteSpace          [ \r\t]

%%
{Define}            {puts("DEFINE keyword");}
{As}                {puts("AS keyword");}
{LogicalOr}         {puts("OR keyword");}
{LogicalAnd}        {puts("AND keyword");}
{Return}            {puts("RETURN keyword"); }
{Int}               {puts("INT keyword");}
{Print}             {puts("PRINT keyword"); }
{While}             {puts("WHILE keyword");}
{If}                {puts("IF keyword");}
{Else}              {puts("ELSE keyword");}
{Break}             {puts("BREAK keyword"); }
{Continue}          {puts("CONTINUE keyword"); }
{LeftParen}         {puts("LEFTPAREN keyword"); }
{RightParen}        {puts("RIGHTPAREN keyword");}
{LeftCurly}         {puts("LEFTCURLY keyword");}
{RightCurly}        {puts("RIGHTCURLY keyword");}
{LeftBracket}       {puts("LEFTBRACKET keyword");}
{RightBracket}      {puts("RIGHT keyword");}
{Comma}             {puts("COMMA keyword");}             
{Semicolon}         {puts("SEMICOLON keywork");}
{Plus}              {puts("PLUS symbol");}
{Subtract}			{puts("SUBTRACT symbol");}
{Multiply}			{puts("MULTIPLY symbol");}
{Divide}			{puts("DIVIDE symbol");}
{Modulus}			{puts("MODULUS symbol");}
{Less}				{puts("LT symbol");}
{LessEqual}			{puts("LTEQ symbol");}
{Greater}			{puts("GT symbol");}
{GreaterEqual}		{puts("GTEQ symbol");}
{Equality}			{puts("EQ symbol");}
{Assign}			{puts("ASSIGN symbol");}
{NotEqual}			{puts("NOTEQ symbol");}
{Not}				{puts("NOT symbol");}
{Num}				{printf("NUMBER: %s\n", yytext);}
{Ident}				{printf("IDENTIFIER: %s\n", yytext);}
{IncorrectIdent}    {printf("Invalid identifier %s: at line %d, column %d.\n", yytext, nrow, ncol-yyleng); exit(-1);}
{Comment}			{nrow++; ncol=1; }
{WhiteSpace}		{}
\n                  {nrow++; ncol=1;}
%%

int main() {
    yylex();
}