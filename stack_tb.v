/*
 * stack_tv.v
 * Testbench for stack.v
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

module stack_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [15:0] pushd;
    reg push_en;
    reg pop_en;

    // Outputs
    wire [15:0] top;

    // Instantiate the Unit Under Test (UUT)
    stack uut (
        .top(top),
        .clk(clk),
        .rst(rst),
        .pushd(pushd),
        .push_en(push_en),
        .pop_en(pop_en)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        pushd = 0;
        push_en = 0;
        pop_en = 0;

        // Reset the UUT
        rst = 1;
        clk = 1;
        #10 clk = 0;
        rst = 0;

        // Push some stuff onto the stack
        pushd = 16'hBEEF;
        push_en = 1;
        #10 clk = 1;
        #10 clk = 0;

        pushd = 16'hDEAD;
        push_en = 1;
        #10 clk = 1;
        #10 clk = 0;

        // Pop it off
        push_en = 0;
        pop_en = 1;
        #10 clk = 1;
        #10 clk = 0;
        #10 clk = 1;
        #10 clk = 0;
    end
endmodule
