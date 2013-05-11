/*
 * instruction_rom.v
 * Asynchronous ROM module used for instruction storage
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

module instruction_rom(data_out, address);

    // Width of instructions stored in the ROM
    parameter DATA_WIDTH = 4;

    // Width of addresses
    parameter ADDR_WIDTH = 8;

    // Inputs and outputs
    output [DATA_WIDTH - 1:0]   data_out;   // Data currently at the given address

    input [ADDR_WIDTH - 1:0]    address;    // Address of the byte in use

    // ROM Storage
    reg [DATA_WIDTH - 1:0] data[0:(1 << ADDR_WIDTH) - 1];

    // Output assignment
    assign data_out = data[address];

    // ROM data loading
    initial
    begin
        $readmemh("../rom.mif", data);
    end
endmodule
