/*
 * cpu_tv.v
 * Testbench for cpu.v
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

module cpu_tb;

    // Inputs
    reg         clk;
    reg [7:0]   data_in;
    reg         data_available;

    // Outputs
    wire [7:0]  data_out;
    wire        data_out_en;
    wire        data_read;

    // This testbench just lets the CPU run, producing whatever output it wants
    cpu #(.INIT_RAM(1)) uut (
        .clk(clk),
        .data_in(data_in),
        .data_available(data_available),
        .data_out(data_out),
        .data_out_en(data_out_en),
        .data_read(data_read)
    );

    initial
    begin
        clk = 0;
        data_in = 0;
        data_available = 0;
        #101 data_available = 1;
    end

    // Generate some data
    always @(posedge clk)
    begin
        if (data_read)
        begin
            data_in <= data_in + 1'b1;
        end
    end
    
    // Print output
    always @(posedge clk)
    begin
        if (data_out_en)
        begin
            $write("%c", data_out);
        end
    end

    // Clock signal
    always
    begin
        #10 clk = 0;
        #10 clk = 1;
    end
endmodule
