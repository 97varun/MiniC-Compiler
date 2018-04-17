%{

#include <stdio.h>
#include "st.h"
void yyerror(const char *error_msg);
int yylex();

int scope = 0;
int parent_scope = -1;

%}
%union {
    char *str;
};

%token INCLUDE SEMI_COLON COMMA EQUAL ID OPEN_SQUARE CLOSE_SQUARE NUMCONST CHARCONST  INT BOOL CHAR OPEN_FLOWER CLOSE_FLOWER PRINTF SCANF OPEN_SIMPLE CLOSE_SIMPLE IF WHILE BREAK RETURN PLUS_EQUAL MINUS_EQUAL MUL_EQUAL DIV_EQUAL PLUS_PLUS ELSE INT_MAIN MINUS_MINUS LOGIC_OR LOGIC_AND NOT LESS_EQUAL GREAT_EQUAL LESS GREAT NOT_EQUAL EQUAL_EQUAL PLUS MINUS STAR DIV MOD TRUE FALSE

%type<str>  typeSpecifier varDeclList INT BOOL CHAR varDeclInitialize varDeclId simpleExpression ID NUMCONST CLOSE_SQUARE OPEN_SQUARE  STAR unaryExpression breakStmt expression  andExpression unaryRelExpression unaryop factor mutable immutable constant BREAK SEMI_COLON NOT MINUS relExpression  OPEN_SIMPLE  CLOSE_SIMPLE  CHARCONST TRUE FALSE sumExpression term
%%

program : declarationList
        ;
declarationList : declarationList declarationList
                | declaration
                ;
declaration : varDeclaration
            | mainDeclaration
            | headerDeclaration
            ;
headerDeclaration : INCLUDE
                  ;
mainDeclaration : INT_MAIN statement
                ;
varDeclaration : typeSpecifier varDeclList SEMI_COLON
               ;
varDeclList : varDeclList COMMA varDeclInitialize {}
            | varDeclInitialize	{}
            ;
varDeclInitialize : varDeclId				{}
                  | varDeclId EQUAL simpleExpression	{}
                  ;
varDeclId : ID	{
				if(load_token($1, (strcmp($<str>0, ",") ? $<str>0 : $<str>-2), line_no, scope, parent_scope)) {
					char buf[50]; sprintf(buf, "redeclaration of %s", $1);
					yyerror(buf);
					YYABORT;
				}
			}
          | ID OPEN_SQUARE NUMCONST CLOSE_SQUARE {
				char type[20] = {0};
				sprintf(type, "%s[%s]", (strcmp($<str>0, ",") ? $<str>0 : $<str>-2), $3);
				if(load_token($1, type, line_no, scope, parent_scope)) {
					char buf[50]; sprintf(buf, "redeclaration of %s", $1);
					yyerror(buf);
					YYABORT;
				}
          	}
          | ID OPEN_SQUARE NUMCONST CLOSE_SQUARE OPEN_SQUARE NUMCONST CLOSE_SQUARE {
          		char type[20] = {0};
          		sprintf(type, "%s[%s][%s]", (strcmp($<str>0, ",") ? $<str>0 : $<str>-2), $3, $6);
          		if(load_token($1, type, line_no, scope, parent_scope)) {
					char buf[50]; sprintf(buf, "redeclaration of %s", $1);
					yyerror(buf);
					YYABORT;
				}
          	}	
          | STAR ID {
				char type[20] = {0};
				sprintf(type, "%s*", (strcmp($<str>0, ",") ? $<str>0 : $<str>-2));
				if(load_token($2, type, line_no, scope, parent_scope)) {
					char buf[50]; sprintf(buf, "redeclaration of %s", $2);
					yyerror(buf);
					YYABORT;
				}         	
          }
          ;
typeSpecifier : INT
              | BOOL
              | CHAR
              ;
statement : declStmt
          | expressionStmt
          | compoundStmt
          | selectionStmt
          | iterationStmt
          | returnStmt
          | breakStmt
          | printfStmt
          | scanfStmt
          ;
compoundStmt : OPEN_FLOWER {++parent_scope; ++scope;} statementList CLOSE_FLOWER {--parent_scope;}
             ;
statementList : statementList statement
              |
              ;
declStmt : varDeclaration
         ;
printfStmt : PRINTF OPEN_SIMPLE args CLOSE_SIMPLE SEMI_COLON
           ;
scanfStmt : SCANF OPEN_SIMPLE args CLOSE_SIMPLE SEMI_COLON
          ;
args : argList
     |
     ;
argList : argList COMMA expression
        | expression
        ;
expressionStmt : expression SEMI_COLON
               | SEMI_COLON
               ;
selectionStmt : IF OPEN_SIMPLE simpleExpression CLOSE_SIMPLE
              | IF OPEN_SIMPLE simpleExpression CLOSE_SIMPLE ELSE statement
              ;
iterationStmt : WHILE OPEN_SIMPLE simpleExpression CLOSE_SIMPLE statement
returnStmt : RETURN SEMI_COLON
           | RETURN expression SEMI_COLON
           ;
breakStmt : BREAK SEMI_COLON
          ;
expression : mutable EQUAL expression
           | mutable PLUS_EQUAL expression
           | mutable MINUS_EQUAL expression
           | mutable MUL_EQUAL expression
           | mutable DIV_EQUAL expression
           | mutable PLUS_PLUS
           | mutable MINUS_MINUS
           | simpleExpression
           ;
simpleExpression : simpleExpression LOGIC_OR andExpression
                 | andExpression
                 ;
andExpression : andExpression LOGIC_AND unaryRelExpression
              | unaryRelExpression
              ;
unaryRelExpression : NOT unaryRelExpression
                   | relExpression
                   ;
relExpression : sumExpression relop sumExpression
              | sumExpression
              ;
relop : LESS_EQUAL
      | LESS
      | GREAT
      | GREAT_EQUAL
      | EQUAL_EQUAL
      | NOT_EQUAL
      ;
sumExpression : sumExpression sumop term
              | term
              ;
sumop : PLUS
      | MINUS
      ;
term : term mulop unaryExpression
     | unaryExpression
     ;
mulop : STAR
      | DIV
      | MOD
      ;
unaryExpression : unaryop unaryExpression
                | factor
                ;
unaryop : MINUS
        | STAR
        ;
factor : immutable
       | mutable
       ;
mutable : ID
        | mutable OPEN_SQUARE expression CLOSE_SQUARE
        | mutable OPEN_SQUARE expression CLOSE_SQUARE OPEN_SQUARE expression CLOSE_SQUARE
        ;
immutable : OPEN_SIMPLE expression CLOSE_SIMPLE
          | constant
          ;
constant : NUMCONST
         | CHARCONST
         | TRUE
         | FALSE
         ;
%%
void yyerror(const char *error_msg) {
	printf("error_msg: %s\n", error_msg);
}

int main() {
	if (!yyparse()) {
		printf("\n\nClean code after removing comments :-> \n");
		printf("**********************************************\n");
		printf("\n%s\n",code);
		printf("**********************************************\n\n\n");
		printf("Symbol Table :->\n");
		printf("----------------------------------------------\n");
		show_me();
		printf("\n-----------------------------------------------\n");
		printf("successful\n");
	} else {
		printf("unsuccessful\n");
	}
	return 0;
}

