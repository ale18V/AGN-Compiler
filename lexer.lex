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
Num                 [0-9]+
Ident               [a-zA-Z]+[a-zA-Z_0-9]*
IncorrectIdent      [_0-9]+{Ident}?
Comment             \/\/.*\n
WhiteSpace          [ \r\t]

%%
{Define}            {return DEFINE;}
{As}                {return AS;}
{LogicalOr}         {return OR;}
{LogicalAnd}        {return AND;}
{Return}            {return RETURN; }
{Int}               {return INT;}
{Print}             {return PRINT; }
{While}             {return WHILE;}
{If}                {return IF;}
{Else}              {return ELSE;}
{Break}             {return BREAK; }
{Continue}          {return CONTINUE; }
{Arrow}             {return ARROW;}
{LeftParen}         {return LEFTPAREN; }
{RightParen}        {return RIGHTPAREN;}
{LeftCurly}         {return LEFTCURLY;}
{RightCurly}        {return RIGHTCURLY;}
{LeftBracket}       {return LEFTBRACKET;}
{RightBracket}      {return RIGHT;}
{Comma}             {return COMMA;}             
{Semicolon}         {return SEMICOLON;}
{Plus}              {return PLUS;}
{Subtract}			{return SUBTRACT;}
{Multiply}			{return MULTIPLY;}
{Divide}			{return DIVIDE;}
{Modulus}			{return MODULUS;}
{Less}				{return LT;}
{LessEqual}			{return LTEQ;}
{Greater}			{return GT;}
{GreaterEqual}		{return GTEQ;}
{Equality}			{return EQ;}
{Assign}			{return ASSIGN;}
{NotEqual}			{return NOTEQ;}
{Not}				{return NOT;}
{Num}				{printf("NUMBER: %s\n", yytext);}
{Ident}				{printf("IDENTIFIER: %s\n", yytext);}
{IncorrectIdent}    {printf("Invalid identifier %s: at line %d, column %d.\n", yytext, nrow, ncol-yyleng); exit(-1);}
{Comment}			{nrow++; ncol=1; }
{WhiteSpace}		{}
\n                  {nrow++; ncol=1;}
.                   {printf("Unrecognized character %s at line %d, column %d.\n", yytext, nrow, ncol-yyleng); exit(-1); }
%%

int main() {
    yylex();
}
