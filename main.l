	/* Ichim Dan Gabriel 331CC */

%option stack
%{
	#include <stdio.h>
	#include <string.h>
	int lines = 1, nr_var = 0;
	struct Variables {
		char name[100];
		char type[100];
	} variables[100];

	struct Function_name {
		char name[100];
	} func_name[100];
	
	char type[100];
	char return_type[100];
	int check = 0, check2 = 0;
	int nr_func = 0;
	int nr_var_start;
	int aux = 0;
%}

DIGIT	[0-9]
LETTER	[a-zA-Z]
SPACE	[\t ]*
TYPE	int|float32|string|bool
BOOL 	true|false
STRING  "\""{LETTER}*"\""
INT 	{DIGIT}+
FLOAT 	{DIGIT}+"."{DIGIT}+

%s COMMENT COMMENT2 VARIABLES FUNCTION FUNC_VAR FUNC_BODY VAR_TYPE TYPE_ERROR TYPE_ERROR_MULTIPLE
%s VAR_TYPE_MULTIPLE VAR_TYPE_ERROR TYPE_ERROR_I
%%

{SPACE}
\n						lines++;
"/*"         			BEGIN(COMMENT);
"//"					BEGIN(COMMENT2);

<COMMENT>[^*\n]*        
<COMMENT>"*"+[^*/\n]*   
<COMMENT>"*/"        	BEGIN(INITIAL);
                   	
<COMMENT2>.*\n {
	lines++;
	BEGIN(INITIAL);
}

<INITIAL>"func"			BEGIN(FUNCTION);

<FUNCTION>{
	{TYPE} 		strcpy(return_type, yytext);
	{LETTER}*	strcpy(func_name[nr_func].name, yytext);
	"(" {
		nr_func++;
		for(int i = 0; i < nr_func - 1; i++) {
			if(strcmp(func_name[i].name, func_name[nr_func-1].name) == 0) {
				printf("line %d: '%s' redeclared in this file\n", lines,func_name[nr_func-1].name);
			}
		}
		yy_push_state(FUNC_VAR);
	}
	"{"	yy_push_state(FUNC_BODY);
}

<FUNC_VAR>{
	{LETTER}" "{TYPE}	{
		strncpy(variables[nr_var].name, yytext, 1);
		memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
		strcpy(variables[nr_var].type, yytext);
		strcpy(type, yytext);
		nr_var++;
	}
	
	{LETTER} {
		strcpy(variables[nr_var].name, yytext);
		nr_var++;
	}

	"," {
		if(*type == NULL)
			check = 1;
	}

	")"	{
		if(check == 1) {
			for(int i = 0; i < nr_var - 1; i++)
				strcpy(variables[i].type, type);
		}
		memset(&type[0], 0, sizeof(type));
		check = 0;
		yy_pop_state();
	}
}

<FUNC_BODY>{
	"}"		BEGIN(INITIAL);
	"var "	yy_push_state(VARIABLES);

	"return "{LETTER} {
		memmove(yytext, yytext + 7, strlen(yytext + 7) + 1);
		if(*return_type == NULL)
			printf("line %d: Too many arguments to return\n", lines);
		else {
			for(int i = 0; i < nr_var; i++) {
				if(strncmp(variables[i].name, yytext, 1) == 0)
					if(strcmp(variables[i].type, return_type) != 0)
						printf("line %d: Invalid return type for function '%s'\n", lines, func_name[nr_func-1].name);
			}
		}
		nr_var = 0;
		memset(&return_type[0], 0, sizeof(return_type));
	}

	{LETTER}" = " {
		for(int i = 0; i < nr_var; i++) {
			if(strncmp(variables[i].name, yytext, 1) == 0) {
				aux = i;
				yy_push_state(TYPE_ERROR);
			}
		}
		aux = 0;
	}

	{LETTER}" := " {
		for(int i = 0; i < nr_var; i++) {
			if(strncmp(variables[i].name, yytext, 1) == 0) {
				printf("line %d: No new variables on the left side of :=\n", lines);
				check2 = 1;
				yy_push_state(VAR_TYPE_ERROR);
			}
		}
		if(check2 == 0) {
			strncpy(variables[nr_var].name, yytext, 1);
			yy_push_state(VAR_TYPE);
			nr_var++;
		}
		check2 = 0;
	}

	({LETTER}", ")+{LETTER}" := " {

	}
}

<TYPE_ERROR_I>{
	{BOOL}	{
		if(variables[aux].type != "bool")
			printf("line %d: (bool) cannot be represented by (%s)\n", lines, variables[aux].type);
		yy_pop_state();
	}
	{FLOAT}	{
		if(variables[aux].type != "float32")
			printf("line %d: (float32) cannot be represented by (%s)\n", lines, variables[aux].type);
		yy_pop_state();
	}
	{INT}	{
		if(variables[aux].type != "int")
			printf("line %d: (int) cannot be represented by (%s)\n", lines, variables[aux].type);
		yy_pop_state();
	}
	{STRING} {
		if(strcmp(variables[aux].type, "string"))
			printf("line %d: (string) cannot be represented by (%s)\n", lines, variables[aux].type);
		yy_pop_state();
	}
	. yy_pop_state();
}

<VARIABLES>{
	{LETTER}" = " {
		for(int i = 0; i < nr_var; i++) {
			if(strncmp(variables[i].name, yytext, 1) == 0) {
				printf("line %d: '%s' redeclared in this block\n", lines, variables[i].name);
				yy_pop_state();
			}
		}
		strncpy(variables[nr_var].name, yytext, 1);
		yy_push_state(VAR_TYPE);
		nr_var++;
		yy_pop_state();
	}
	{LETTER}" "{TYPE}" = " {
		strncpy(variables[nr_var].name, yytext, 1);
		memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
		strncpy(variables[nr_var].type, yytext, yyleng - 4);
		yy_push_state(TYPE_ERROR);
		nr_var++;
		yy_pop_state();
	}
	{LETTER}" "{TYPE} {
		for(int i = 0; i < nr_var; i++) {
			if(strncmp(variables[i].name, yytext, 1) == 0) {
				printf("line %d: '%s' redeclared in this block\n", lines, variables[i].name);
				yy_pop_state();
			}
		}
		strncpy(variables[nr_var].name, yytext, 1);
		memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
		strcpy(variables[nr_var].type, yytext);
		nr_var++;
		yy_pop_state();
	}
	({LETTER}", ")+{LETTER}" "{TYPE}" = " {
		nr_var_start = nr_var;
		strncpy(variables[nr_var].name, yytext, 1);
		memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
		nr_var++;
		while(strncmp(" ", yytext, 1) == 0) {
			memmove(yytext, yytext + 1, strlen(yytext + 1) + 1);
			strncpy(variables[nr_var].name, yytext, 1);
			memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
			nr_var++;
		}
		for(int i = 0; i < nr_var - nr_var_start; i++)
			strncpy(variables[nr_var_start + i].type, yytext, yyleng - 11);
		yy_push_state(TYPE_ERROR_MULTIPLE);
		yy_pop_state();
	}
	({LETTER}", ")+{LETTER}" "{TYPE} {

	}
	({LETTER}", ")+{LETTER} {

	}
	{LETTER}" := " {

	}
	({LETTER}", ")+{LETTER}" := " {
		nr_var_start = nr_var;
		strncpy(variables[nr_var].name, yytext, 1);
		memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
		nr_var++;
		while(strncmp(" ", yytext, 1) == 0) {
			memmove(yytext, yytext + 1, strlen(yytext + 1) + 1);
			strncpy(variables[nr_var].name, yytext, 1);
			memmove(yytext, yytext + 2, strlen(yytext + 2) + 1);
			nr_var++;
		}
		yy_push_state(VAR_TYPE_MULTIPLE);
		yy_pop_state();
	}
}

<VAR_TYPE>{
	{BOOL}	{
		strcpy(variables[nr_var].type, "bool");
		yy_pop_state();
	}
	{FLOAT}	{
		strcpy(variables[nr_var].type, "float32");
		yy_pop_state();
	}
	{INT}	{
		strcpy(variables[nr_var].type, "int");
		yy_pop_state();
	}
	{STRING} {
		strcpy(variables[nr_var].type, "string");
		yy_pop_state();
	}
	. yy_pop_state();
}

<VAR_TYPE_ERROR>{
	{BOOL}	{
		yy_pop_state();
	}
	{FLOAT}	{
		yy_pop_state();
	}
	{INT}	{
		yy_pop_state();
	}
	{STRING} {
		yy_pop_state();
	}
	. yy_pop_state();
}

<VAR_TYPE_MULTIPLE>{
	{BOOL}", "	{
		strcpy(variables[nr_var_start + aux].type, "bool");
		aux++;
	}
	{FLOAT}", " {
		strcpy(variables[nr_var_start + aux].type, "float32");
		aux++;
	}
	{INT}", " {
		strcpy(variables[nr_var_start + aux].type, "int");
		aux++;
	}
	{STRING}", " {
		strcpy(variables[nr_var_start + aux].type, "string");
		aux++;
	}

	{BOOL}	{
		strcpy(variables[nr_var_start + aux].type, "bool");
		aux = 0;
		yy_pop_state();
	}
	{FLOAT} {
		strcpy(variables[nr_var_start + aux].type, "float32");
		aux = 0;
		yy_pop_state();
	}
	{INT} {
		strcpy(variables[nr_var_start + aux].type, "int");
		aux = 0;
		yy_pop_state();
	}
	{STRING} {
		strcpy(variables[nr_var_start + aux].type, "string");
		aux = 0;
		yy_pop_state();
	}

	. {
		yy_pop_state();
		aux = 0;
	}
}

<TYPE_ERROR>{
	{BOOL}	{
		if(variables[nr_var].type != "bool")
			printf("line %d: (bool) cannot be represented by (%s)\n", lines, variables[nr_var].type);
		yy_pop_state();
	}
	{FLOAT}	{
		if(variables[nr_var].type != "float32")
			printf("line %d: (float32) cannot be represented by (%s)\n", lines, variables[nr_var].type);
		yy_pop_state();
	}
	{INT}	{
		if(variables[nr_var].type != "int")
			printf("line %d: (int) cannot be represented by (%s)\n", lines, variables[nr_var].type);
		yy_pop_state();
	}
	{STRING} {
		if(variables[nr_var].type != "string")
			printf("line %d: (string) cannot be represented by (%s)\n", lines, variables[nr_var].type);
		yy_pop_state();
	}
	. yy_pop_state();
}

<TYPE_ERROR_MULTIPLE>{
	({BOOL}", ")+{BOOL}	{
		yy_pop_state();
	}
	({FLOAT}", ")+{FLOAT}	{
		yy_pop_state();
	}
	({INT}", ")+{INT}	{
		yy_pop_state();
	}
	({STRING}", ")+{STRING} {
		yy_pop_state();
	}

	(({LETTER}", ")|({BOOL}", "))+({LETTER}|{BOOL}) {
		if(variables[nr_var - 1].type != "bool")
			printf("line %d: (type) cannot be represented by (%s)\n", lines, variables[nr_var-1].type);
		yy_pop_state();
	}

	(({LETTER}", ")|({FLOAT}", "))+({LETTER}|{FLOAT}) {
		if(variables[nr_var - 1].type != "float32")
			printf("line %d: (type) cannot be represented by (%s)\n", lines, variables[nr_var-1].type);
		yy_pop_state();
	}

	(({LETTER}", ")|({INT}", "))+({LETTER}|{INT}) {
		if(variables[nr_var - 1].type != "int")
			printf("line %d: (type) cannot be represented by (%s)\n", lines, variables[nr_var-1].type);
		yy_pop_state();
	}

	(({LETTER}", ")|({STRING}", "))+({LETTER}|{STRING}) {
		if(variables[nr_var - 1].type != "string")
			printf("line %d: (type) cannot be represented by (%s)\n", lines, variables[nr_var-1].type);
		yy_pop_state();
	}

	. {
		printf("line %d: (type) cannot be represented by (%s)\n", lines, variables[nr_var-1].type);
		yy_pop_state();
	}
}
%%

int main(int argc, char **argv) {
	yyin = fopen(argv[1], "r");
	if (!yyin) {
		printf("Eroare la deschiderea fisierului de analizat.\nUtilizare: \"./a.out nume_fisier.go\"\n");
		exit(1);
	}
	yylex();
}