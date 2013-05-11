# Brainfuck Processor
This is a single cycle processor which executes [brainfuck](http://en.wikipedia.org/wiki/Brainfuck) code. It was written in Verilog using the Xilinx ISE design software which you can get for free [here](http://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.htm), or you can run in in the CS hardware labs.

## ROM Generation
Before using the processor, you must generate a ROM file which contains the brainfuck program you want to execute. To save memory and skip the comments, the ROM contains an encoded version of the program rather than the actual text. The default name of the ROM file is "rom.mif".

You can use the generate_rom.py python script to convert a brainfuck program into a ROM file.

    python generate_rom.py -i <input file> -o rom.mif

### ROM File Details
Each line of the ROM file contains one 4-bit hex digit containing one of the brainfuck commands:

    0   =   Halt processor
    1-7 =   No op
    8   = > Increment pointer
    9   = < Decrement pointer
    A   = + Increment value at pointer
    B   = - Decrement value at pointer
    C   = [ Start while value != 0 loop
    D   = ] End while loop
    E   = . Output value at pointer
    F   = , Input value and store at pointer

## Implementation Notes
Most aspects about the size of things in the processor can be modified using Verilog parameters in cpu.v. This includes:

    IADDR_WIDTH = Width of instruction memory addresses (max ROM size = 2 ^ IADDR_WIDTH)
    DADDR_WIDTH = Width of data memory addresses (size of RAM = 2 ^ DADDR_WIDTH)
    SADDR_WIDTH = Width of loop stack addresses (max loop depth = 2 ^ SADDR_WIDTH)
     DATA_WIDTH = Width of data cells in RAM

Note that all values wraparound when incrementing past their maximum value. If the number of nested loops exceeds the maximum loop depth, behavior is (very) undefined.
