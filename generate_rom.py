'''Python script to convert brainfuck programs to ROM files (rom.mif)'''

import sys
import argparse

# Width of instruction addresses
IADDR_WIDTH = 8

# Maximum opcodes allowed
MAX_OPCODES = 1 << IADDR_WIDTH

class OutOfSpaceError(Exception):
    '''Error raised if there is not enough ROM space'''

    def __init__(self, needed):
        Exception.__init__(self, \
            "Not enough ROM space (" + str(needed) + " addresses required)\n" + \
            " You can get more by increasing IADDR_WIDTH in this file and cpu.v\n")

def file_iterator(file):
    '''Returns an iterator iterating over the characters in a file'''
    while True:
        c = file.read(1)
        if not c:
            break

        yield c

def convert_bf(in_file, out_file):
    '''
    Reads a brainfuck program from input and writes the ROM file to output

    Both input and output are file streams
    '''

    # Opcodes written
    opcodes = 0

    # Command dictionary
    commands = { '>': '8',
                 '<': '9',
                 '+': 'A',
                 '-': 'B',
                 '[': 'C',
                 ']': 'D',
                 '.': 'E',
                 ',': 'F' }

    # Process input file
    for c in file_iterator(in_file):
        if c in commands:
            out_file.write(commands[c] + '\n')
            opcodes += 1

    # Pad the rest of the file with halt instructions
    if opcodes >= MAX_OPCODES:
        raise OutOfSpaceError(opcodes + 1)

    for _ in range(MAX_OPCODES - opcodes):
        out_file.write('0\n')

    # Flush output stream
    out_file.flush()

if __name__=='__main__':
    # Parse command line args
    parser = argparse.ArgumentParser( \
        description='Python script to convert brainfuck programs to ROM files (rom.mif)')
    parser.add_argument('-i', '--input', help='File to read input from (if not given, reads from stdin)')
    parser.add_argument('-o', '--output', help='File to write output to (if not given, writes to stdout)')
    args = parser.parse_args()

    # Open files
    if args.input is None:
        in_file = sys.stdin
    else:
        in_file = file(args.input, 'r')

    if args.output is None:
        out_file = sys.stdout
    else:
        out_file = file(args.output, 'w')

    # Process program
    convert_bf(in_file, out_file)
