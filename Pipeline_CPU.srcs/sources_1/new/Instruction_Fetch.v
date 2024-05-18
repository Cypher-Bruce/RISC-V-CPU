`timescale 1ns / 1ps
`include "Parameters.v"

/// Module: Instruction_Fetch
/// #Description 
///                This module is responsible for fetching the instruction from the instruction memory.
///              according to the address. The address is from PC.
///              Note: the PC increments by 1 each cycle, unless there is a branch instruction.
///              Note(cont.): Thus, addr from PC can directly be used in inst. mem instead of right shift.
/// #Input       clk, rst, branch_flag, jal_flag, jalr_flag, zero_flag, imme
/// #Outputs     inst, program_counter
/// #Signals     
///         - address: 14-bit address for instruction memory
///         - branch_taken_flag: 1 if branch is taken
///         - funct3: 3-bit funct3 field from instruction

module Instruction_Fetch(
    input             clk,           /// adjusted clk, from cpu
    input             rst,           /// reset signal, from cpu
    input             branch_taken_flag,
    input      [31:0] branch_pc,
    input             stall_flag,

    output reg [31:0] program_counter,
    output reg [31:0] prev_pc
);

////////////////////////// ADDRESS SHIFTING //////////////////////////
/// We use memory layout like this: https://photos.app.goo.gl/8xTAXyCikpdyna5V9
/// Because it's not possible to access various memory IP cores using absolute addresses in the address space,
/// it's necessary to perform address offsetting when accessing IP core addresses: absolute address - offset within the address section.
/// Therefore, when accessing instruction memory, no address adjustment is required,
/// whereas when accessing data memory, the absolute address needs to be subtracted by 0x2000.

////////////////////////// PC //////////////////////////
/// Three cases for PC
/// Case1. rst: set PC to initial address
/// Case2. branch_flag && branch_taken_flag: increment PC with imme
/// Case3. default: increment PC by 4
/// Note that actual address sent to memory ip core is address >> 2
/// !!! PC is updated at the FALLING edge of the clock signal, for more details, refer to https://imgur.com/a/zZdYXqu

always @(negedge clk) begin
    if (rst) begin
        program_counter <= `inst_memory_initial_address;
        prev_pc <= `inst_memory_initial_address;
    end
    else if (branch_taken_flag) begin
        program_counter <= branch_pc;
        prev_pc <= program_counter;
    end
    else if (stall_flag) begin
        program_counter <= program_counter;
        prev_pc <= prev_pc;
    end
    else begin
        program_counter <= program_counter + 4;
        prev_pc <= program_counter;
    end
end

endmodule
