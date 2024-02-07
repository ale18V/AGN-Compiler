# CS152_Project
A custom compiler developed in CS 152 using the All Guy Names programming language.

Authors: Nicolas Karalis, Garrett Greenup, Alessandro Bombarda.

### Language Features

| Language Feature      | Code Example |
|-----------------------|--------------|
| Variable Declaration  | int x;       |
| Add                   | x + y        |
| Sub                   | x - y        |
| Multiply              | x * y        |
| Divide                | x / y        |
| Modulus               | x % y        |
| Less Than             | x < y        |
| Less Than Equal       | x <= y       |
| Equality              | x == y       |
| Not Equality          | x != y       |
| Greater Than          | x > y        |
| Greater Than Equal    | x >= y       |
| Logical or            | x or y       |
| Logical and           | x and y      |
| Logical xor           | x xor y      |
| Write                 | write(x)     |
| Read                  | read(x)      |
| Arrays                | int [8] array|
| Comments              | // This is a comment|

### Table of Symbols

|Symbol                | Token Name   |
|----------------------|--------------|
|define                | Define       |
|as					   | As           |
|return                | Return       |
|int                   | Int          |
|write                 | Write        |
|read                  | Read         |
|while                 | While        |
|if                    | If           |
|else                  | Else         |
|break                 | Break        |
|continue              | Continue     |
|and                   | Logical and  |
|or                    | Logical or   |
|xor                   | Logical xor  |
|(                     | LeftParen    |
|)                     | RightParen   |
|{                     | LeftCurly    |
|}                     | RightCurly   |
|[                     | LeftBracket  |
|]                     | RightBracket |
|->                    | Arrow        |			
|,                     | Comma        |
|;                     | Semicolon    |
|+                     | Plus         |
|-                     | Minus		  |
|*                     | Multiply     |
|/                     | Divide       |
|%                     | Modulus      |
|=                     | Assign       |
|<                     | Less         |
|<=                    | LessEqual    |
|>                     | Greater      |
|>=                    | GreaterEqual |
|==                    | Equality     |
|!=                    | NotEqual     |
|!                     | Not          |
|variable_name         | Ident        |
|10311517              | Num          |

### Comments

Comments can be single line comments starting with `//`. For example:

```
int x; //This is a variable declaration.
```
