# hc #
Hardware implementation of the HC stream cipher.

## Introduction ##

The HC stream cipher by Hongjun Wu is a very fast, state table based
cipher. The HC-128 version of the cipher was selected as one of the
ciphers in the eSTREAM portfolio.

http://www.ecrypt.eu.org/stream/e2-hc128.html

There is also a version of the cipher with 256 bit key.


## Hardware implementation ##

This hardware implementation is written in Verilog 2001 RTL code. It is
an experimental implementation to see how fast the cipher can be
implemented in modern FPGA devices. The P and Q tables are currently
implemented as Verilog arrays and no specific work is done to ensure
that block RAMs are actually used.


## Status ##

Initial version. Much stuff to do before it works. Here will be dragons.
