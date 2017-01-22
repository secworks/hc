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
# HC
#
# The HC stream cipher class.
# ------------------------------------------------------------------
class HC():
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.P = [0] * 1024
        self.S = [0] * 1024
        self.i = 0


    def init(self, key, iv):
        self.key = key
        self.iv = iv

        if len(key) == 8:
            self.iterations = 1024

        else:
            self.iiterations = 512


    def next(self):
        return 0

    def rotw32(self, w, r):
        return (((w << r) % (2**32 -1)) | ( w >> (32 - r)))


# ------------------------------------------------------------------
# test_hc()
#
# Test the HC implementation with 128 and 256 bit keys.
# ------------------------------------------------------------------
def test_hc():
    my_hc = HC()

    for i in range(33):
        print("shift %02d steps: 0x%08x" % (i, my_hc.rotw32(i, 0x00000001)))


# ------------------------------------------------------------------
# main()
#
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
