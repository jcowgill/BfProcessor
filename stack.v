/*
 * stack.v
 * LIFO Stack
 *
 * Copyright (C) 2013 James Cowgill
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

`timescale 1ns / 1ps

module stack(top, clk, pushd, push_en, pop_en);

    // Width of data values stored on the stack
    parameter DATA_WIDTH = 8;

    // Width of stack addresses (max stack size = 2^ADDR_WIDTH)
    parameter ADDR_WIDTH = 5;

    // Inputs and outputs
    output [DATA_WIDTH - 1:0]   top;    // Value on the top of the stack

    input                       clk;    // Clock

    input [DATA_WIDTH - 1:0]    pushd;  // Incoming data for push operations
    input                       push_en;// Pushing on next clock
    input                       pop_en; // Pop on next clock

    // Stack storage and pointer
    //  stack_ptr = next location to store data
    reg [DATA_WIDTH - 1:0] stack_data[0:(1 << ADDR_WIDTH) - 1];
    reg [ADDR_WIDTH - 1:0] stack_ptr;

    // Top of the stack
    reg [DATA_WIDTH - 1:0] stack_top;

    // View of the top of the stack
    assign top = stack_top;

    // Stack initialization
    integer i;

    initial
    begin
        // Registers
        stack_ptr = 0;
        stack_top = 0;

        // Stack data
        for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1)
            stack_data[i] = 0;
    end

    // Main pushing and popping code
    always @(posedge clk)
    begin
        if (push_en)
        begin
            // Copy onto stack and increment pointer
            stack_data[stack_ptr] <= stack_top;
            stack_ptr <= stack_ptr + 1'b1;

            // Update stack top
            stack_top <= pushd;
        end
        else if (pop_en)
        begin
            // Pop by decrementing pointer
            stack_ptr <= stack_ptr - 1'b1;

            // Update stack top
            stack_top <= stack_data[stack_ptr - 1'b1];
        end
    end
endmodule
