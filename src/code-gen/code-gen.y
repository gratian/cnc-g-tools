/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <err.h>
#include <sys/stat.h>

/* emit an error if G function is missing */
#define ERROR_ON_MISSING_FN	0

#define MAX_G_CODE_IDX	1000
#define MAX_M_CODE_IDX	2000

int yylex(void);
void yyerror(char const*);

/* stack for storing generated g-code function names */
struct fn_el {
	char* name;
	struct fn_el *next;
	int idx;
	char code;
};
static struct fn_el *fn_stack = NULL;

static inline void fn_stack_push(struct fn_el *el)
{
	el->next = fn_stack;
	fn_stack = el;
}

static inline struct fn_el* fn_stack_pop()
{
	struct fn_el *el = NULL;

	if (fn_stack) {
		el = fn_stack;
		fn_stack = el->next;
	}
	return el;
}

static FILE *i_file;
static unsigned int rank = 0;
%}

%union {
	int ival;
	struct {
		unsigned int idx;
		char code;
	} cval;
	char* sval;
}

%token <cval> CMD
%token <ival> NUMBER
%token <sval> ID
%token <sval> COMMENT
%token L_CBRACKET R_CBRACKET
%token L_RBRACKET R_RBRACKET
%token EQ
%token COMMA
%token LF

%printer { fprintf(yyo, "'%c%g'", $$.code, $$.idx); } <cval>
%printer { fprintf(yyo, "\"%s\"", $$); } <sval>
%printer { fprintf(yyo, "%d", $$); } <ival>

%%

input:
  %empty
| input line
;

line:
  LF
| L_CBRACKET
| expression LF
| R_CBRACKET { rank++; }
;

expression:
  command
| expression command
;

command:
  COMMENT { fprintf(i_file, "%s\n", $1); }
| L_RBRACKET blocks R_RBRACKET { fprintf(i_file, "\n\t.rank = %u\n};\n\n", rank); }
;

blocks:
  block
| blocks COMMA block

block:
  %empty
| CMD {
	struct fn_el *el = (struct fn_el*)malloc(sizeof(struct fn_el));
	assert(el);

	el->code = $1.code;
	el->idx = $1.idx;
	if ($1.idx % 10) {
		asprintf(&el->name, "%c_%d_%d",
			 $1.code, $1.idx / 10, $1.idx % 10);
	} else {
		asprintf(&el->name, "%c_%d",
			 $1.code, $1.idx / 10);
	}
	fprintf(i_file, "struct g_code %s_code = {\n", el->name);
	fprintf(i_file,"\t.fn = %s_fn,\n", el->name);
	fn_stack_push(el);
      }
| attribute
;

attribute:
  ID EQ NUMBER { fprintf(i_file, "\t.%s = %d,", $1, $3); }
;

%%

static void free_fn_stack()
{
	struct fn_el *el;

	while ((el = fn_stack_pop())) {
		free(el->name);
		free(el);
	}
}

static void print_c_parse_fn(FILE *out, struct fn_el *el)
{
	fprintf(out, "int %s_fn(void)\n{\n", el->name);
	fprintf(out, "\tdefault_%c_parse_fn();\n", el->code);
	fprintf(out, "\treturn -1;\n");
	fprintf(out, "}\n\n");
}

static void print_h_parse_fn(FILE *out, struct fn_el *el)
{
	fprintf(out, "int %s_fn(void) __attribute__((weak));\n", el->name);
}

static void gen_parse_fn(const char code, const char *name, const char* dir)
{
	FILE *c_file;
	FILE *h_file;
	char *c_path;
	char *h_path;
	struct fn_el *el;

	if (asprintf(&c_path, "%s/%s.c", dir, name) < 0)
		err(1, "%s/%s.c", dir, name);

	if (asprintf(&h_path, "%s/%s.h", dir, name) < 0)
		err(1, "%s/%s.h", dir, name);

	c_file = fopen(c_path, "w+");
	if (!c_file)
		err(1, "%s", c_path);

	fprintf(c_file, "#include <stdio.h>\n");
	fprintf(c_file, "#include <error.h>\n");
	fprintf(c_file, "#include \"%s.h\"\n\n", name);

#if ERROR_ON_MISSING_FN
	fprintf(c_file, "#define default_%c_parse_fn() "
		"error_at_line(1, 1, __FILE__, __LINE__, "
		"\"%c function not implemented\")\n\n", code, code);
#else
	fprintf(c_file, "#define default_%c_parse_fn() "
		"fprintf(stderr, \"warning:%%s:%%d:%%s\", __FUNCTION__, __LINE__, "
		"\"%c function not implemented\")\n\n", code, code);
#endif

	h_file = fopen(h_path, "w+");
	if (!h_file)
		err(1, "%s", h_path);
	fprintf(h_file, "#ifndef _%s_h_\n#define _%s_h_\n\n", name, name);

	for (el = fn_stack; el; el = el->next) {
		if (el->code == code) {
			print_c_parse_fn(c_file, el);
			print_h_parse_fn(h_file, el);
		}
	}

	fprintf(h_file, "\n#endif /* _%s_h_ */\n", name);

	fclose(c_file);
	fclose(h_file);
	free(c_path);
	free(h_path);
}

static void gen_init_header(const char *name, const char* dir)
{
	char *path;
	FILE *f;

	asprintf(&path, "%s/%s.h", dir, name);
	f = fopen(path, "w+");
	if (!f)
		err(1, "%s", path);
	free(path);

	fprintf(f, "#ifndef _%s_h_\n#define _%s_h_\n\n", name, name);
	fprintf(f,
		"struct g_code "
		"{\n"
		"\tint (*fn)(void);\n"
		"\tint modal;\n"
		"\tint rank;\n"
		"};\n\n"
		);
	fprintf(f, "/* G and M code values are multiplied by 10 when indexing in data\n"
		" * structures to allow for faster indexing of fractional codes\n"
		" * e.g. G19.1 can be found in the g_codes array at index 191)*/\n");
	fprintf(f, "#define CODE_TO_IDX(v)\t(int)(v * 10)\n");
	fprintf(f, "#define MAX_G_CODE_IDX\t%d\n", MAX_G_CODE_IDX);
	fprintf(f, "#define MAX_M_CODE_IDX\t%d\n\n", MAX_M_CODE_IDX);
	fprintf(f, "extern struct g_code* g_codes[MAX_G_CODE_IDX];\n");
	fprintf(f, "extern struct g_code* m_codes[MAX_M_CODE_IDX];\n\n");
	fprintf(f, "void command_codes_init(void);\n");
	fprintf(f, "\n#endif /* _%s_h_ */\n", name);

	fclose(f);
}

static void gen_init_code()
{
	struct fn_el *el;

	fprintf(i_file, "struct g_code* g_codes[%d];\n", MAX_G_CODE_IDX);
	fprintf(i_file, "struct g_code* m_codes[%d];\n", MAX_M_CODE_IDX);
	fprintf(i_file, "\n");
	fprintf(i_file, "void command_codes_init(void)\n{\n");

	for (el = fn_stack; el; el = el->next) {
		if (el->code == 'G') {
			fprintf(i_file, "\tg_codes[%u] = &%s_code;\n",
			       el->idx, el->name);
		} else if (el->code == 'M') {
			fprintf(i_file, "\tm_codes[%u] = &%s_code;\n",
			       el->idx/10, el->name);
		}
	}

	fprintf(i_file, "}\n");
}

void yyerror(char const *s)
{
	fprintf(stderr, "%s\n", s);
}

int main (int argc, char const* argv[])
{
	int ret;
	struct stat sb;
	char* i_path;

	if (argc < 2) {
		printf("Usage: %s <output_dir>\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	if (stat(argv[1], &sb) != 0 || !S_ISDIR(sb.st_mode)) {
		fprintf(stderr, "%s: error: %s is not a directory\n",
			argv[0], argv[1]);
		exit(EXIT_FAILURE);
	}

	gen_init_header("init_codes", argv[1]);

	asprintf(&i_path, "%s/init_codes.c", argv[1]);
	i_file = fopen(i_path, "w+");
	if (!i_file)
		err(1, "%s", i_path);

	fprintf(i_file, "#include \"g_codes.h\"\n");
	fprintf(i_file, "#include \"m_codes.h\"\n");
	fprintf(i_file, "#include \"f_codes.h\"\n");
	fprintf(i_file, "#include \"s_codes.h\"\n");
	fprintf(i_file, "#include \"t_codes.h\"\n");
	fprintf(i_file, "#include \"init_codes.h\"\n\n");

#if YYDEBUG
	yydebug = 1;
#endif
	ret = yyparse();

	if (!ret) {
		gen_parse_fn('G', "g_codes", argv[1]);
		gen_parse_fn('M', "m_codes", argv[1]);
		gen_parse_fn('F', "f_codes", argv[1]);
		gen_parse_fn('S', "s_codes", argv[1]);
		gen_parse_fn('T', "t_codes", argv[1]);
		gen_init_code();
	}
	fclose(i_file);
	free(i_path);
	free_fn_stack();

	return ret;
}
