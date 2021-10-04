/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
#ifndef _G_DECODER_H_
#define _G_DECODER_H_

extern double g_parameters[];

enum g_word_type {
	k_code,
	k_param
};

struct g_word {
	double val;
	struct g_code *code;
	struct g_word *next;
	enum g_word_type type;
	union {
		char c;
		int i;
	} op;
};

void push_param(int i, double val);
void push_code(char c, double val);
struct g_word* pop_word(void);
void commit_line(void);

#endif /* _G_DECODER_H_ */
