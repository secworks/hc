#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ======================================================================
#
# hc.py
# ------
# Simple, pure Python model of the HC stream cipher with
# support for 128 and 256 bit keys.
#
#
# Author: Joachim Strömbergson
# Copyright (c) 2017, Assured AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ======================================================================

# ------------------------------------------------------------------
# Python module imports.
# ------------------------------------------------------------------
import sys


# -------------------------------------------------------------------
# Defines.
# -------------------------------------------------------------------
MAX_W32 = 0xffffffff
HC256_TSIZE = 1024
HC128_TSIZE = 512


# -------------------------------------------------------------------
# HC
# The HC stream cipher class.
# ------------------------------------------------------------------
class HC():
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.P = [0] * 1024
        self.Q = [0] * 1024
        self.table_length
        self.i = 0


    def init(self, key, iv):
        self.key = key
        self.iv = iv

        if len(key) == 8:
            self.iterations = 1024
            self.self_length = 1024
        else:
            self.iiterations = 512
            self.self_length = 512


    def next(self):
        return 0


    def f1(self, x):
        return rotw32(x, 7) ^ rotw32(x, 18) ^ rotw32(x, 3)

    def f2(self, x):
        return rotw32(x, 17) ^ rotw32(x, 19) ^ rotw32(x, 10)

    def g1(self, x, y)
        return (rotw32(x, 10) ^ rotw32(x, 23) + Q[((x ^ y) % 1024)]) & MAX_W32

    def g2(self, x, y)
        return (rotw32(x, 10) ^ rotw32(x, 23) + P[((x ^ y) % 1024)]) & MAX_W32

    def h1(self, x)
        (x0, x1, x2, x3) = self.w2b(x)
        return (Q[x0] + Q[(x1 + 256)] + Q[(x2 + 512)] + Q[(x3 + 768)]) & MAX_W32

    def h2(self, x)
        (x0, x1, x2, x3) = self.w2b(x)
        return (P[x0] + P[(x1 + 256)] + P[(x2 + 512)] + P[(x3 + 768)]) & MAX_W32


    def rotw32(self, w, b):
        return ((w << b) | (w >> (32 - b))) & 0xffffffff

    def w2b(x)
        x0 = x >> 24
        x1 = x >> 16 & 0xff
        x2 = x >> 8 & 0xff
        x2 = x & 0xff
        return (x0, x1, x2, x3)

# ------------------------------------------------------------------
# test_hc()
# Test the HC implementation with 128 and 256 bit keys.
# ------------------------------------------------------------------
def test_hc():
    my_hc = HC()


# ------------------------------------------------------------------
# main()
# If executed tests the ChaCha class using known test vectors.
# ------------------------------------------------------------------
def main():
    print("Testing the HC stream cipher model")
    print("==================================")
    print

    test_hc()


# ------------------------------------------------------------------
# __name__
# Python thingy which allows the file to be run standalone as
# well as parsed from within a Python interpreter.
# ------------------------------------------------------------------
if __name__ == "__main__":
    # Run the main function.
    sys.exit(main())

# ======================================================================
# EOF hc.py
# ======================================================================
