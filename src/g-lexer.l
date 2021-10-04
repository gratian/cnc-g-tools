/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <math.h>
#include <ctype.h>

#define YY_DECL int yylex()

#include "g-parser.h"
%}

%%

[ \t]+	; /* eat up whitespace */
\%	; /* @todo do not ignore start/end of program if M2 or M30 is not present */
[ABCDFGHIJKLMPQRSTXYZabcdfghijklmpqrstxyz]	{ yylval.cval = toupper(yytext[0]);
						return MID_LINE_LETTER; }
[Nn][0-9]+		{ yylval.ival = atoi(&yytext[1]); return LINE_NUMBER; }
[0-9]+[\.]*[0-9]*	{ yylval.dval = atof(yytext); return REAL_NUMBER; }
[0-9]*[\.]+[0-9]+	{ yylval.dval = atof(yytext); return REAL_NUMBER; }
\([ \t]*[mM][ \t]*[sS][ \t]*[gG][ \t]*[^()]*\) { yylval.sval = strdup(yytext); return MESSAGE; }
\([^(^)]*\)		{ yylval.sval = strdup(yytext); return ORDINARY_COMMENT; }
"**"			{return OP_POWER;}
"/"			{return OP_DIV;}
[mM][oO][dD]		{return OP_MOD;}
"*"			{return OP_MUL;}
[aA][nN][dD]		{return OP_AND;}
[xX][oO][rR]		{return OP_XOR;}
"-"			{return OP_SUB;}
[oO][rR]		{return OP_OR;}
"+"			{return OP_ADD;}
[aA][bB][sS]		{return OP_ABS;}
[aA][cC][oO][sS]	{return OP_ACOS;}
[aA][sS][iI][nN]	{return OP_ASIN;}
[cC][oO][sS]		{return OP_COS;}
[eE][xX][pP]		{return OP_EXP;}
[fF][iI][xX]		{return OP_FIX;}
[fF][uU][pP]		{return OP_FUP;}
[lL][nN]		{return OP_LN;}
[rR][oO][uU][nN][dD]	{return OP_ROUND;}
[sS][iI][nN]		{return OP_SIN;}
[sS][qQ][rR][tT]	{return OP_SQRT;}
[tT][aA][nN]		{return OP_TAN;}
[aA][tT][aA][nN]	{return OP_ATAN;}
\n			{return NEW_LINE;}
\n\r			{return NEW_LINE;}
\r\n			{return NEW_LINE;}
\[			{return LEFT_BRACKET;}
\]			{return RIGHT_BRACKET;}
"#"			{return POUND;}
"="			{return EQUALS;}
%%
