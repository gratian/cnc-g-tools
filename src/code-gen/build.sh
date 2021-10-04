#!/bin/sh -v
# SPDX-License-Identifier: MIT
# Copyright © 2021 Gratian Crisan. All Rights Reserved.

# enable debug trace output
# bison -Dparse.trace -d code-gen.y
bison -d code-gen.y
flex code-gen.l
gcc -O2 -o code-gen code-gen.tab.c lex.yy.c
