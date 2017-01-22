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

This implementation will probably support both key lengths, but starts
out with 128 bit key only.

The core will have a top level wrapper with a 32-bit compliant
interface. And testbenches for core and top level.

Note that the big tables P and Q are implemented with arrays and
accessed asynchronously, not clocked memories. This means that for FPGAs
these tables as separate registers, not block RAMs. This intentional
since we want to implement HC on a single cycle/word. So 64k will be
allocated.


## Status ##

Initial version. Much stuff to do before it works. Here will be dragons.
