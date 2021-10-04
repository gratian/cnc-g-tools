/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include "code-gen/output/init_codes.h"
#include "g-decoder.h"

int yylex(void);
void yyerror(char const*);
%}

%union {
	char cval;
	int ival;
	char* sval;
	double dval;
}

%token <cval> MID_LINE_LETTER
%token <cval> NEW_LINE
%token <cval> LEFT_BRACKET RIGHT_BRACKET
%token <cval> EQUALS
%token <ival> LINE_NUMBER
%token <sval> MESSAGE
%token <sval> ORDINARY_COMMENT
%token <dval> REAL_NUMBER

/* ordinary unary operations */
%token OP_ABS OP_ACOS OP_ASIN OP_COS OP_EXP OP_FIX OP_FUP OP_LN OP_ROUND OP_SIN OP_SQRT OP_TAN
%token OP_ATAN

/* associativity and precedence (from low to high) */
%left OP_AND OP_XOR OP_SUB OP_OR OP_ADD
%left OP_DIV OP_MOD OP_MUL
%precedence NEG			/* @todo: check this */
%right OP_POWER
%precedence POUND

%type<dval> real_value
%type<dval> parameter_value
%type<dval> expression
%type<dval> ordinary_unary_combo
%type<dval> arc_tangent_combo
%type<dval> unary_combo
%type<dval> binary_combo

%printer { fprintf(yyo, "'%c'", $$); } <cval>
%printer { fprintf(yyo, "\"%s\"", $$); } <sval>
%printer { fprintf(yyo, "%d", $$); } <ival>
%printer { fprintf(yyo, "%g", $$); } <dval>

/* grammar rules for NIST-RS274NGC ver 3. g-code */
%%

input:
  %empty
| input line
;

line:
  segment NEW_LINE { commit_line(); }
| line_number segment NEW_LINE { commit_line(); }
| block_delete line_number segment NEW_LINE { commit_line(); }
;

block_delete:
  OP_DIV	{ printf("<del> "); }

line_number:
  LINE_NUMBER	{ printf("[%d]\n", $1); }

segment:
  %empty
| segment mid_line_word
| segment comment
| segment parameter_setting
;

mid_line_word:
  MID_LINE_LETTER real_value	{ push_code($1, $2); }
;

/* @todo: messages (comments starting with MSG) should be displayed on device */
comment:
  MESSAGE			{ printf("MSG: %s\n", $1); free($1); }
| ORDINARY_COMMENT		{ printf("// %s\n", $1); free($1); }
;

parameter_setting:
  POUND real_value EQUALS real_value {
	  if ((int)$2 >= 1 && (int)$2 <= 5400) {
		  push_param($2, $4);
		  printf("#%d = %g\n", (int)$2, $4);
	  } else {
		  yyerror (YY_("syntax error: parameter index outside range"));
		  YYERROR;
	  }
  }
;

parameter_value:
  POUND real_value { $$ = g_parameters[(int)$2];
	  printf("#%d = %g\n", (int)$2, g_parameters[(int)$2]); }
;

real_value:
  REAL_NUMBER
| OP_ADD REAL_NUMBER	{ $$ = $2; }
| OP_SUB REAL_NUMBER	{ $$ = -$2; }
| expression
| binary_combo	/* @todo: binary ops should only appear inside expressions */
| parameter_value
| unary_combo
;

expression:
  LEFT_BRACKET real_value RIGHT_BRACKET	{ $$ = $2; }

binary_combo:
  real_value OP_ADD real_value { $$ = $1 + $3; }
| real_value OP_SUB real_value { $$ = $1 - $3; }
| real_value OP_MUL real_value { $$ = $1 * $3; }
| real_value OP_DIV real_value { $$ = $1 / $3; }
| real_value OP_POWER real_value { $$ = pow($1, $3); }
| real_value OP_MOD real_value { $$ = fmod($1, $3); }
| real_value OP_AND real_value { $$ = $1 && $3; }
| real_value OP_OR real_value { $$ = $1 || $3; }
| real_value OP_XOR real_value { $$ = (!$1 != !$3);}
;

unary_combo:
  ordinary_unary_combo
| arc_tangent_combo
;

/* all angles are in degrees */
ordinary_unary_combo:
  OP_ADD expression { $$ = $2; }
| OP_SUB expression %prec NEG { $$ = -$2; }
| OP_ABS expression	{ $$ = fabs($2); }
| OP_SIN expression	{ $$ = sin($2 * M_PI / 180); }
| OP_COS expression	{ $$ = cos($2 * M_PI / 180); }
| OP_TAN expression	{ $$ = tan($2 * M_PI / 180); }
| OP_ASIN expression	{ $$ = asin($2) * 180 / M_PI; }
| OP_ACOS expression	{ $$ = acos($2) * 180 / M_PI; }
| OP_EXP expression	{ $$ = exp($2); }
| OP_FIX expression	{ $$ = floor($2); }
| OP_FUP expression	{ $$ = ceil($2); }
| OP_LN expression	{ $$ = log($2); }
| OP_ROUND expression	{ $$ = round($2); }
| OP_SQRT expression	{ $$ = sqrt($2); }
;

arc_tangent_combo:
  OP_ATAN expression OP_DIV expression { $$ = atan($2/$4) * 180 / M_PI; }
;

%%
void yyerror(char const *s)
{
	fprintf(stderr, "%s\n", s);
}

int main (int argc, char const* argv[])
{
#if YYDEBUG
	yydebug = 1;
#endif
	command_codes_init();

	return yyparse();
}
