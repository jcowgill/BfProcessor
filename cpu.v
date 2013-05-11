/*
 * cpu.v
 * The Brainfuck Processor
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

module cpu(clk, data_in, data_available, data_out, data_out_en, data_read);

    // Width of instruction addresses (affects size of ROM)
    parameter IADDR_WIDTH = 8;

    // Width of data addresses (affects size of RAM area)
    parameter DADDR_WIDTH = 15;

    // Width of stack addresses (affects size of loop stack)
    parameter SADDR_WIDTH = 5;

    // Width of data entries
    parameter DATA_WIDTH = 8;

    // True to initialize RAM for simulations
    parameter INIT_RAM = 0;

    // Inputs and outputs
    output reg [DATA_WIDTH - 1:0] data_out;     // Output data bus
    output reg                  data_out_en;    // If high, output was written on last cycle
    output reg                  data_read;      // If high, input was read on last cycle

    input                       clk;            // Clock

    input [DATA_WIDTH - 1:0]    data_in;        // Input data bus
    input                       data_available; // Data available on the input bus

    // Internal Registers
    reg  [IADDR_WIDTH - 1:0]    pc;             // Program counter
    reg  [DADDR_WIDTH - 1:0]    dp;             // Data pointer
    reg  [SADDR_WIDTH - 1:0]    lsc;            // Loop skip counter
        /*
         * The loop skip counter is used for skipping entire loops
         * when *DP == 0 when entering them. During normal operation
         * the counter equals 0. When entering a loop which should be
         * skipped, the counter is set to 1 and is used to detect nested
         * loops and when the program should resume.
         * When loop_skip_count != 0, normal instructions are not executed.
         */

    // Internal Signals (wires driven by block memories)
    wire [3:0]                  ci;             // Current instruction

    wire [DATA_WIDTH - 1:0]     data_from_ram;  // Data at dp from RAM
    reg  [DATA_WIDTH - 1:0]     data_to_ram;    // Data to write into RAM at dp
    reg                         ram_write;      // Write enable on RAM

    wire [IADDR_WIDTH - 1:0]    stack_top;      // Address on top of the loop stack
    reg  [IADDR_WIDTH - 1:0]    stack_data;     // Data to push onto the stack
    reg                         stack_push;     // High to push onto the stack
    reg                         stack_pop;      // High to pop off the stack

    reg  [IADDR_WIDTH - 1:0]    next_pc;        // Next value of the program counter
    reg  [DADDR_WIDTH - 1:0]    next_dp;        // Next value of the data pointer
    reg  [SADDR_WIDTH - 1:0]    next_lsc;       // Next value of the loop skip counter

    // Block memory instances
    instruction_rom #(.ADDR_WIDTH(IADDR_WIDTH)) rom (
        .address(pc),
        .data_out(ci)
    );

    data_ram #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(DADDR_WIDTH), .INIT_RAM(INIT_RAM)) ram (
        .data_out(data_from_ram),
        .clk(clk),
        .address(next_dp),
        .data_in(data_to_ram),
        .write(ram_write)
    );

    stack #(.DATA_WIDTH(IADDR_WIDTH), .ADDR_WIDTH(SADDR_WIDTH)) loop_stack (
        .top(stack_top),
        .clk(clk),
        .pushd(stack_data),
        .push_en(stack_push),
        .pop_en(stack_pop)
    );

    // Register initialization
    initial
    begin
        pc = 0;
        dp = 0;
        lsc = 0;
    end

    // Combinational part
    always @(*)
    begin
        // Default signal states
        data_out = 32'bX;
        data_out_en = 0;
        data_read = 0;
        data_to_ram = 32'bX;
        ram_write = 0;
        stack_data = 32'bX;
        stack_push = 0;
        stack_pop = 0;
        next_dp = dp;
        next_pc = pc + 1'b1;
        next_lsc = lsc;

        // Different handling depending on lsc
        if (lsc == 0)
        begin
            // Handle each opcode
            case (ci)
                4'h0:
                    begin
                        // Halt - set pc to itself so we just loop on this instruction
                        next_pc = pc;
                    end

                4'h8:
                    begin
                        // Increment DP
                        next_dp = dp + 1'b1;
                    end

                4'h9:
                    begin
                        // Decrement DP
                        next_dp = dp - 1'b1;
                    end

                4'hA:
                    begin
                        // Increment *DP
                        data_to_ram = data_from_ram + 1'b1;
                        ram_write = 1;
                    end

                4'hB:
                    begin
                        // Decrement *DP
                        data_to_ram = data_from_ram - 1'b1;
                        ram_write = 1;
                    end

                4'hC:
                    begin
                        // Start loop - either skip entire loop of push into it
                        if (data_from_ram == 0)
                        begin
                            // Skip entire loop
                            next_lsc = 1;
                        end
                        else
                        begin
                            // Start loop - push PC + 1 onto the stack
                            stack_data = next_pc;
                            stack_push = 1;
                        end
                    end

                4'hD:
                    begin
                        // End of loop - either exit the loop or loop around
                        if (data_from_ram == 0)
                            stack_pop = 1;
                        else
                            next_pc = stack_top;
                    end

                4'hE:
                    begin
                        // Output 1 byte
                        data_out = data_from_ram;
                        data_out_en = 1;
                    end

                4'hF:
                    begin
                        // Input 1 byte
                        if (data_available)
                        begin
                            // Read this byte into memory and signal that it was read
                            data_to_ram = data_in;
                            ram_write = 1;
                            data_read = 1;
                        end
                        else
                        begin
                            // Busy wait here until we can read (this is like the halt instruction)
                            next_pc = pc;
                        end
                    end

                // Deault - noop
            endcase
        end
        else
        begin
            // Special loop skip counter handling
            case (ci)
                4'hC:
                    begin
                        // Increment lsc
                        next_lsc = lsc + 1'b1;
                    end

                4'hD:
                    begin
                        // Decrement lsc
                        next_lsc = lsc - 1'b1;
                    end
            endcase
        end
    end

    // Synchronous (register update) part
    always @(posedge clk)
    begin
        // Update registers
        pc <= next_pc;
        dp <= next_dp;
        lsc <= next_lsc;
    end
endmodule
