/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

#include "code-gen.tab.h"

#define YY_DECL int yylex()
%}

%%

[ \t]+ ; /* eat up whitespace */

#.* ; /* ignore comments */

[ABCDFGHIJKLMPQRSTXYZ][0-9]+[\.]*[0-9]* {
	char *endp;
	double dval = strtod(&yytext[1], &endp);

	if (dval == 0 && endp == &yytext[1]) {
		fprintf(stderr, "[lex error] cannot parse double\n");
		exit(EXIT_FAILURE);
	}

	yylval.cval.code = toupper(yytext[0]);
	yylval.cval.idx = (unsigned int)(dval * 10);
	return CMD;
}

\/\*([^*]|\*+[^/])*\*+\/ { yylval.sval = strdup(yytext); return COMMENT; }

[a-z]+ { yylval.sval = strdup(yytext); return ID; }

[0-9]+ { yylval.ival = atoi(yytext); return NUMBER; }

\{ { return L_CBRACKET; }
\} { return R_CBRACKET; }
\( { return L_RBRACKET; }
\) { return R_RBRACKET; }
= { return EQ; }
, { return COMMA; }
\n { return LF; }

%%
