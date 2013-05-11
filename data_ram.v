/*
 * data_ram.v
 * Synchronous RAM module used for data storage
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

module data_ram(data_out, clk, address, data_in, write);

    // Width of data values stored
    parameter DATA_WIDTH = 8;

    // Width of addresses (max stack size = 2^ADDR_WIDTH)
    parameter ADDR_WIDTH = 15;

    // True to initialize RAM in an initial block
    //  This can be disabled for synthesis when it is very slow and unnessesary
    parameter INIT_RAM = 1;

    // Inputs and outputs
    output [DATA_WIDTH - 1:0]   data_out;   // Data currently at the given address

    input                       clk;        // Clock

    input [ADDR_WIDTH - 1:0]    address;    // Address of the byte in use
    input [DATA_WIDTH - 1:0]    data_in;    // Incoming data
    input                       write;      // If high, writes on a clock edge

    // The RAM storage and output buffer
    reg [DATA_WIDTH - 1:0] data[0:(1 << ADDR_WIDTH) - 1];
    reg [DATA_WIDTH - 1:0] output_buffer;

    // View of the output buffer
    assign data_out = output_buffer;

    // RAM initialization
    integer i;

    initial
    begin
        output_buffer = 0;

        if (INIT_RAM)
        begin
            for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1)
                data[i] = 0;
        end
    end

    // RAM update code
    always @(posedge clk)
    begin
        if (write)
        begin
            data[address] <= data_in;
            output_buffer <= data_in;
        end
        else
        begin
            output_buffer <= data[address];
        end
    end
endmodule
