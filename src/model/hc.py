#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ======================================================================
#
# hc.py
# ------
# Simple, pure Python model of the HC stream cipher with
# support for 128 and 256 bit keys.
#
# Note: Currently the model is only implementing HC-256.
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
        # Allocate the internal state variables.
        self.verbose = verbose
        self.P = [0] * 1024
        self.Q = [0] * 1024
        self.i = 0


    # Initialize the internal state given the key and iv.
    def init(self, key, iv):
        W = [0] * 2560;
        for i in range(8):
            W[i] = key[i]
            W[(i + 8)] = iv[i]

        for i in range(16, 2560):
            W[i] = (self.f2(W[(i - 2)]) + W[(i - 7)] +
                        self.f1(W[(i - 15)]) + W[(i - 15)] + i) & MAX_W32

        for i in range(1024):
            self.P[i] = W[(i + 512)]
            self.Q[i] = W[(i + 1536)]


    # Update internal state and return the next word.
    def next(self):
        j = self.i % 1024
        if (self.i % 2048) < 1024:
            self.P[j] = (self.P[j] + self.P[self.subm(j, 10)]
                             + self.g1(self.P[self.subm(j, 3)], self.P[self.subm(j, 1023)])) & MAX_W32
            s = self.h1(self.P[self.subm(j, 12)]) ^ self.P[j]

        else:
            self.Q[j] = (self.Q[j] + self.Q[self.subm(j, 10)]
                             + self.g2(Q[self.subm(j, 3)], Q[self.subm(j, 1023)])) & MAX_W32
            s = self.h2(self.Q[self.subm(j, 12)]) ^ self.Q[j]

        self.i += 1
        return s


    # HC internal functions.
    def f1(self, x):
        return self.rotr(x, 7) ^ self.rotr(x, 18) ^ self.rotr(x, 3)

    def f2(self, x):
        return self.rotr(x, 17) ^ self.rotr(x, 19) ^ self.rotr(x, 10)

    def g1(self, x, y):
        return (self.rotr(x, 10) ^ self.rotr(x, 23) + self.Q[((x ^ y) % 1024)]) & MAX_W32

    def g2(self, x, y):
        return (self.rotr(x, 10) ^ self.rotr(x, 23) + self.P[((x ^ y) % 1024)]) & MAX_W32

    def h1(self, x):
        (x0, x1, x2, x3) = self.w2b(x)
        return (self.Q[x0] + self.Q[(x1 + 256)] +
                    self.Q[(x2 + 512)] + self.Q[(x3 + 768)]) & MAX_W32

    def h2(self, x):
        (x0, x1, x2, x3) = self.w2b(x)
        return (self.P[x0] + self.P[(x1 + 256)] +
                    self.P[(x2 + 512)] + self.P[(x3 + 768)]) & MAX_W32


    # Helper functions neeed to implement the HC functions.
    def rotr(self, w, b):
        return ((w >> b) | (w << (32 - b))) & 0xffffffff

    def w2b(self, x):
        x0 = x >> 24
        x1 = x >> 16 & 0xff
        x2 = x >> 8 & 0xff
        x3 = x & 0xff
        return (x0, x1, x2, x3)

    def subm(self, x, y):
        return (x - y) % 1024


# ------------------------------------------------------------------
# test_rotr()
# Test the hc help function rotr()
# ------------------------------------------------------------------
def test_rotr():
    my_hc = HC()
    print("Testing rotr help function.")
    for i in range(33):
        print("rotr %02d steps: 0x%08x" % (i, my_hc.rotr(0x00000001, i)))
    print("")


# ------------------------------------------------------------------
# test_hc()
# Test the HC implementation with 128 and 256 bit keys.
# ------------------------------------------------------------------
def test_hc():
    my_key = [0] * 8
    my_iv = [0] * 8
    my_hc = HC()
    my_hc.init(my_key, my_iv)

    for i in range(16):
        print("keystream %02d = 0x%08x" % (i, my_hc.next()))


# ------------------------------------------------------------------
# main()
# If executed tests the ChaCha class using known test vectors.
# ------------------------------------------------------------------
def main():
    print("Testing the HC stream cipher model")
    print("==================================")
    print

#    test_rotr()
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
