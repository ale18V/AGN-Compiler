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

Func                method                          
Return              return                        
Int                 int                              
Print               write                          
Read                read                            
While               while                          
If                  if                                
Else                else                            
Break               break                          
Continue            continue                    
LeftParen           (                          
RightParen          )                         
LeftCurly           {                          
RightCurly          }                         
LeftBracket         [                        
RightBracket        ]                       
Comma               ,                                  
Semicolon           ;                          
Plus                +                                   
Subtract            -                           
Multiply            *                           
Divide              /                             
Modulus             %                            
Assign              =                             
Less                <                               
LessEqual           <=                         
Greater             >                            
GreaterEqual        >=                      
Equality            == 
LogicalAnd          and
LogicalOr           or
LogicalXor          xor
NotEqual            !=   
Not					!
Ident               [a-zA-Z]+[a-zA-Z_0-9]*
Num                 [0-9]+                
Comment             //.*\n
WhiteSpace          [ \n\r\t]

%%
{Func}              {puts("Method declaration");}
{LogicalOr}         {puts("Logical OR");}
{LogicalAnd}        {puts("Logical AND");}
{Return}            {puts("Return keyword"); }
{Int}               {puts("Int keyword");}
{Print}             {puts("Print keyword"); ncol += strlen(yytext);}
{While}             {puts("While keyword"); ncol += strlen(yytext);}
{If}                {puts("If keyword"); ncol += strlen(yytext);}
{Else}              {puts("Else keyword"); ncol += strlen(yytext);}
{Break}             {puts("Break keyword"); ncol += strlen(yytext);}
{Continue}          {puts("Continue keyword"); ncol += strlen(yytext);}
{LeftParen}         {puts("Left parenthesis keyword"); ncol += strlen(yytext);}
{RightParen}        {puts("Right parenthesis keyword");}
{LeftCurly}         {puts("Left curly brakcet keyword");}
{RightCurly}        {puts("Right curly bracket keyword");}
{LeftBracket}       {puts("Left bracket keyword");}
{RightBracket}      {puts("Right bracket keyword");}
{Comma}             {puts("Comma keyword");}             
{Semicolon}         {puts("Semicolon");}
{Plus}              {puts("Plus symbol");}
{Subtract}			{puts("Subtract symbol");}
{Multiply}			{puts("Multiply symbol");}
{Divide}			{puts("Divide symbol");}
{Modulus}			{puts("Modulus symbol");}
{Less}				{puts("Less than symbol");}
{LessEqual}			{puts("Less than or Equal symbol");}
{Greater}			{puts("Greater than symbol");}
{GreaterEqual}		{puts("Greater than or Equal symbol");}
{Equality}			{puts("Equality symbol");}
{Assign}			{puts("Equals sign symbol");}
{NotEqual}			{puts("Not equal symbol");}
{Not}				{puts("Logical NOT symbol");}
{Ident}				{printf("IDENTIFIER: %s\n", yytext);}
{Num}				{printf("NUMBER: %s\n", yytext);}
{Comment}			{nrow++; ncol=1; }
{WhiteSpace}		{}
\n                  {nrow++; ncol=1;}
%%

int main() {
    yylex():

}