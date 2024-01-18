%{
#include <stdio.h>
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
Ident               [a-zA-Z_]+                  
Num                 [0-9]+                
Comment             //.*\n
WhiteSpace          [ \n\r\t]

%%
{Func}              {puts("Method declaration");}
{Return}            {puts("Return keyword");}
{Int}               {puts("Int keyword");}
{Print}             {puts("Print keyword");}
{While}             {puts("While keyword");}
{If}                {puts("If keyword");}
{Else}              {puts("Else keyword");}
{Break}             {puts("Break keyword");}
{Continue}          {puts("Continue keyword");}
{LeftParen}         {puts("Left parenthesis keyword");}
{RightParen}        {puts("Right parenthesis keyword");}
{LeftCurly}         {puts("Left curly brakcet keyword");}
{RightCurly}        {puts("Right curly bracket keyword");}
{LeftBracket}       {puts("Left bracket keyword");}
{RightBracket}      {puts("Right bracket keyword");}
{Comma}             {puts("Comma keyword");}             
{Semicolon}         {puts("Semicolon");}
{Plus}              {puts("Right curly bracket keyword");}
{Subtract}
{Multiply}
{Divide}
{Modulus}
{Assign}
{Less}
{LessEqual}
{Greater}
{GreaterEqu}al
{Equality}
{NotEqual}
{Not}
{Ident}
{Num}
{Comment}
{WhiteSpace}

%%