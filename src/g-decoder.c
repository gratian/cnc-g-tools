/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include "axes.h"
#include "code-gen/output/init_codes.h"
#include "g-decoder.h"

extern int yylineno;

struct axes ax;

double g_parameters[5400];	/* @todo this needs to be preserved between
				   programs/reboots; default 0 except #5220=1 */

static struct g_word* word_queue = NULL;

static struct g_code* get_g_code(double val)
{
	int i = CODE_TO_IDX(val);
	assert(i >= 0 && i < MAX_G_CODE_IDX);
	return g_codes[i];
}

static struct g_code* get_m_code(double val)
{
	int i = CODE_TO_IDX(val);
	assert(i >= 0 && i < MAX_M_CODE_IDX);
	return m_codes[i];
}

void push_param(int i, double val)
{
	struct g_word* p = (struct g_word *)malloc(sizeof(struct g_word));
	assert(p);

	p->type = k_param;
	p->op.i = i;
	p->val = val;
	p->code = NULL;

	/* Code words and parameter settings within a line can be
	   re-ordered w/o changing the meaning of the line. If a
	   parameter is set more than once the last value assigned
	   takes effect. Add parameter assignments at te begining of
	   the word queue (which also takes care of the double setting
	   of a parameter corner case above). */
	p->next = word_queue;
	word_queue = p;
}

void push_code(char c, double val)
{
	struct g_word* p;
	struct g_word* q = (struct g_word *)malloc(sizeof(struct g_word));
	assert(q);

	q->type = k_code;
	q->op.c = c;
	q->val = val;
	switch (c) {
	case 'G':
		q->code = get_g_code(val);
		break;
	case 'M':
		q->code = get_m_code(val);
		break;
	default:
		q->code = NULL;
	}

/** @todo add double linked list implementation w/ sorting by rank */

	q->next = word_queue;
	word_queue = q;
}

struct g_word* pop_word(void)
{
	struct g_word* w = word_queue;

	if (w)
		word_queue = w->next;

	return w;
}

void err_out(struct g_word* w, char* err_str)
{
	fprintf(stderr,
		"error at line %d: "
		"parsing code word '%c%g', %s\n",
		yylineno - 1, w->op.c, w->val, err_str);
	exit(EXIT_FAILURE);
}

void commit_line(void)
{
	struct g_word* w;
	struct g_code *code;
	uint32_t g_mode = 0;
	uint32_t m_mode = 0;

	while ((w = pop_word()) != NULL) {
		switch (w->type) {
		case k_code:
			switch (w->op.c) {
			case 'G':
				code = get_g_code(w->val);

				/* check for modal group violations */
				if ((g_mode & (1 << code->modal)) > 1)
					err_out(w, "modal group violation "
						"(multiple words from same "
						"modal group)");
				g_mode |= (1 << code->modal);

				/* It is an error to put a G-code from
				   group 1 and a G-code from group 0
				   on the same line if both of them
				   use axis words. The axis word-using
				   G-codes from group 0 are G10, G28,
				   G30, and G92. */
				if ((g_mode & 0x3 == 0x3) && (
						w->val == 10 ||
						w->val == 28 ||
						w->val == 30 ||
						w->val == 92))
					err_out(w, "modal group violation "
						"(multiple axis using words on"
						" the same line)");

				printf("<G%g> func: %p\n",
					w->val,
					code->fn);
				assert(code->fn);
				code->fn();
				break;
			case 'M':
				/** @todo implement M-code handling */
			default:
				printf("%c = %g\n", w->op.c, w->val);
			};
			break;
		case k_param:
			g_parameters[w->op.i] = w->val;
			printf("param[%d] = %g\n", w->op.i, w->val);
			break;
		};
		free(w);
	}
	printf("\n");
}
