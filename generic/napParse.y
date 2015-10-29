%{

/*
 * napParse.y --
 *
 * Copyright (c) 1998, CSIRO Australia
 *
 * bison source code defining expression parser
 * bison is a gnu's yacc
 *
 * Author: Harvey Davies, CSIRO Mathematical and Information Sciences
 *
 */

#ifndef lint
static char *rcsid="@(#) $Id: napParse.y,v 1.60 2003/07/19 14:19:35 dav480 Exp $";
#endif /* not lint */

#ifdef WIN32
#include <malloc.h>
#endif /* WIN32 */

#include "nap.h"
#include "nap_check.h"

#define YYERROR_VERBOSE 1
#define YYSTYPE Nap_stype
#define YYPARSE_PARAM Nap_param
#define YYLEX_PARAM Nap_param

%}

%pure_parser

%token <str>	ID			/* ID of nao  e.g. "nao.42" */
%token <str>	NAME			/* of nao or function */
%token <str>	STRING			/* e.g. 'hello world', `abc` */
%token <str>	UNUMBER			/* unsigned double */
%token <str>	CAT			/* // */
%token <str>	LAMINATE		/* /// */
%token <str>	CLOSEST			/* @@ */
%token <str>	MATCH			/* @@@ */
%token <str>	TO			/* .. */
%token <str>	AP3			/* ... */
%token <str>	EQ			/* == */
%token <str>	NE			/* != */
%token <str>	LE			/* <= */
%token <str>	GE			/* >= */
%token <str>	SHIFT_LEFT		/* << */
%token <str>	LESSER_OF		/* <<< */
%token <str>	SHIFT_RIGHT		/* >> */
%token <str>	GREATER_OF		/* >>> */
%token <str>	AND			/* && */
%token <str>	OR			/* || */
%token <str>	POWER			/* ** */
%token <str>	INNER_PROD		/* +* */
%token <str>	FUNCTION		/* used only for prec */
%token <str> ' ' '!' '"' '#' '$' '%' '&' '(' ')' '*' '+' ',' '-' '.' '/'
%token <str> ':' ';' '<' '=' '>' '?' '@'
%token <str> '[' ']' '^' '_' '`'
%token <str> '{' '|' '}' '~'

%right '='
%left ','
%left CAT LAMINATE
%right '?' ':'
%left OR
%left AND
%left '|'
%left '^'
%left '&'
%left EQ NE
%left LE GE '<' '>'
%left LESSER_OF GREATER_OF
%left SHIFT_LEFT SHIFT_RIGHT
%left '-' '+'
%left '*' '/' '%'
%left INNER_PROD
%left '#'
%left TO
%left '@' CLOSEST MATCH AP3
%right '!' '~'
%right POWER
%right FUNCTION

%type <str>	result			/* final result (nao ID) */
%type <str>	expr			/* nao ID of expression */
%type <str>	FuncArg1		/* 1st arg of Nap_Func */
%type <str>	FuncArg2		/* 2nd arg of Nap_Func */
%type <str>	naoID			/* nao->ID */
%type <str>	arrayConst		/* nao ID of encList */
%type <str>	stringConst		/* nao ID of string */
%type <pnode>	encList			/* enclosed list i.e. {list} */
%type <pnode>	list			/* what is inside braces */
%type <pnode>	element			/* of list (number or encList) */
%type <number>	ssnv			/* signed scalar numeric value */
%type <number>	usnv			/* unsigned scalar numeric value */

%%

result	: expr				{$$ = Nap_SetParseResult(Nap_param, $1);}
	;

expr	: naoID
	| arrayConst
	| stringConst
	| usnv				{$$ = Nap_ScalarConstant(Nap_param, $1);}
	| NAME				{$$ = Nap_GetNaoIdFromId(Nap_param, $1);}
	| NAME '=' expr			{$$ = Nap_Assign(Nap_param, $1, $3);}
	| expr ',' expr			{$$ = Nap_Link(Nap_param, $1, $3);}
	| expr CAT expr			{$$ = Nap_Cat(Nap_param, $1, $3);}
	| expr LAMINATE expr		{$$ = Nap_Laminate(Nap_param, $1, $3);}
	| expr '@' expr			{$$ = Nap_IndexOf2(Nap_param, $1, $3);}
	| expr '#' expr			{$$ = Nap_Copy(Nap_param, $1, $3);}
	| expr CLOSEST expr		{$$ = Nap_Closest(Nap_param, $1, $3);}
	| expr MATCH expr		{$$ = Nap_Match(Nap_param, $1, $3);}
	| expr '?' expr ':' expr	{$$ = Nap_Choice(Nap_param, $1, $3, $5);}
	| expr TO expr			{$$ = Nap_AP(Nap_param, $1, $3);}
	| expr AP3 expr			{$$ = Nap_Link(Nap_param, $1, $3);}
	| expr OR expr			{$$ = Nap_Or(Nap_param, $1, $3);}
	| expr AND expr			{$$ = Nap_And(Nap_param, $1, $3);}
	| expr EQ expr			{$$ = Nap_Eq(Nap_param, $1, $3);}
	| expr NE expr			{$$ = Nap_Ne(Nap_param, $1, $3);}
	| expr LE expr			{$$ = Nap_Le(Nap_param, $1, $3);}
	| expr LESSER_OF expr		{$$ = Nap_LesserOf(Nap_param, $1, $3);}
	| expr GREATER_OF expr		{$$ = Nap_GreaterOf(Nap_param, $1, $3);}
	| expr '<' expr			{$$ = Nap_Lt(Nap_param, $1, $3);}
	| expr GE expr			{$$ = Nap_Ge(Nap_param, $1, $3);}
	| expr '>' expr			{$$ = Nap_Gt(Nap_param, $1, $3);}
	| expr '+' expr			{$$ = Nap_Add(Nap_param, $1, $3);}
	| expr '-' expr			{$$ = Nap_Sub(Nap_param, $1, $3);}
	| expr '*' expr			{$$ = Nap_Mul(Nap_param, $1, $3);}
	| expr '/' expr			{$$ = Nap_Div(Nap_param, $1, $3);}
	| expr '%' expr			{$$ = Nap_Rem(Nap_param, $1, $3);}
	| expr INNER_PROD expr		{$$ = Nap_InnerProd(Nap_param, $1, $3);}
	| expr POWER expr		{$$ = Nap_Power(Nap_param, $1, $3);}
	| expr '&' expr			{$$ = Nap_BitAnd(Nap_param, $1, $3);}
	| expr '|' expr			{$$ = Nap_BitOr(Nap_param, $1, $3);}
	| expr '^' expr			{$$ = Nap_BitXor(Nap_param, $1, $3);}
	| expr SHIFT_LEFT expr		{$$ = Nap_ShiftLeft(Nap_param, $1, $3);}
	| expr SHIFT_RIGHT expr		{$$ = Nap_ShiftRight(Nap_param, $1, $3);}
	| '!' expr			{$$ = Nap_Not(Nap_param, $2);}
	| '#' expr %prec '!'		{$$ = Nap_Tally(Nap_param, $2);}
	| '-' expr %prec '!'		{$$ = Nap_Negate(Nap_param, $2);}
	| '~' expr %prec '!'		{$$ = Nap_Complement(Nap_param, $2);}
	| '+' expr %prec '!'		{$$ = Nap_Identity(Nap_param, $2);}
	| '@' expr %prec '!'		{$$ = Nap_Indirect(Nap_param, 1,$2);}
	| CLOSEST expr %prec '!'	{$$ = Nap_Indirect(Nap_param, 2,$2);}
	| MATCH expr %prec '!'		{$$ = Nap_Indirect(Nap_param, 3,$2);}
	| ',' expr %prec ','		{$$ = Nap_Link(Nap_param, NULL, $2);}
	| expr ',' %prec ','		{$$ = Nap_Link(Nap_param, $1, NULL);}
	| ','				{$$ = Nap_Niladic(Nap_param, ",");}
	| '-'	   %prec '!'		{$$ = Nap_Niladic(Nap_param, "-");}
	| '(' expr ')'			{$$ = $2;}
	| NAME NAME %prec FUNCTION	{$$ = Nap_Func(Nap_param, $1, $2);}
	| NAME FuncArg2 %prec FUNCTION	{$$ = Nap_Func(Nap_param, $1, $2);}
	| FuncArg1 NAME %prec FUNCTION	{$$ = Nap_Func(Nap_param, $1, $2);}
	| FuncArg1 FuncArg2 %prec FUNCTION	{$$ = Nap_Func(Nap_param, $1, $2);}
	;

FuncArg1: arrayConst
	| stringConst
	| naoID
	| '(' expr ')'			{$$ = $2;}
	;

FuncArg2: arrayConst
	| stringConst
	| naoID
	| '(' expr ')'			{$$ = $2;}
	| '(' ')'			{$$ = NULL;}
	| usnv				{$$ = Nap_ScalarConstant(Nap_param, $1);}
	;

naoID:	ID				{$$ = Nap_GetNaoIdFromId(Nap_param, $1);}
	;

stringConst: STRING			{$$ = Nap_StringConstant(Nap_param, $1);}
	;

arrayConst: encList			{$$ = Nap_ArrayConstant(Nap_param, $1);}
	;

encList : '{' list '}'			{$$ = $2 ? $2 :
						Nap_NewListPNode(Nap_param, "0", NULL);}
	;

list	: /* empty */			{$$ = NULL;}
	| list element			{$$ = Nap_AppendToPNodeList(Nap_param, $1, $2);}
	;

element : ssnv				{$$ = Nap_NewValuePNode(Nap_param, "1", $1);}
	| UNUMBER '#' ssnv		{$$ = Nap_NewValuePNode(Nap_param, $1, $3);}
	| encList			{$$ = Nap_NewListPNode(Nap_param, "1", $1);}
	| UNUMBER '#' encList		{$$ = Nap_NewListPNode(Nap_param, $1, $3);}
	;

ssnv	: usnv
	| '-' usnv			{$$ = Nap_NegateNumber(Nap_param, $2);}
	| '+' usnv			{$$ = $2;}
	;

usnv	: UNUMBER			{(void) Nap_StringToNumber(Nap_param, $1, &($$));}
	;

%%
