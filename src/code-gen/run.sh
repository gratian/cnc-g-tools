#!/bin/sh -v
# SPDX-License-Identifier: MIT
# Copyright © 2021 Gratian Crisan. All Rights Reserved.

mkdir -p output
./code-gen output < g-codes.def
