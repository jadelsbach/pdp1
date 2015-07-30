# PDP-1(D) in Verilog
## Basic usage
 * Adjust the readmemh `pdp1_memory.v` to load a hex dump of some program (default is "test.hex")
 * The simulation will stop if the more than 1000000000 cycles have passed or if CPU is halted over the OPR instruction or gets an unknown instruction.
 * Default output is pdp1.vcd

## Current Status

 * Can execute most of the instruction tests: <http://bitsavers.trailing-edge.com/bits/DEC/pdp1/papertapeImages/20040106/instrTest/>
 * Doesn't have IO yet
