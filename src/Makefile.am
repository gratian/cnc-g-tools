# SPDX-License-Identifier: MIT
# Copyright © 2021 Gratian Crisan. All Rights Reserved.

AM_YFLAGS = -d -Wno-yacc
LDADD = -lm
BUILT_SOURCES = g-parser.h
bin_PROGRAMS = g_interp
g_interp_SOURCES = g-lexer.l \
		g-decoder.c \
		g-parser.y \
		code-gen/output/init_codes.c \
		code-gen/output/f_codes.c \
		code-gen/output/g_codes.c \
		code-gen/output/m_codes.c \
		code-gen/output/s_codes.c \
		code-gen/output/t_codes.c

