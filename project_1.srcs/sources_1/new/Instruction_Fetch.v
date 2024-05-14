`timescale 1ns / 1ps
`include "Parameters.v"

/// Module: Instruction_Fetch
/// #Description 
///                This module is responsible for fetching the instruction from the instruction memory.
///              according to the address. The address is from PC.
///              Note: the PC increments by 1 each cycle, unless there is a branch instruction.
///              Note(cont.): Thus, addr from PC can directly be used in inst. mem instead of right shift.
/// #Input       clk, rst, branch_flag, zero_flag, imme
/// #Outputs     inst
/// #Signals     address: 14-bit address for instruction memory
module Instruction_Fetch(
    input         clk,           /// adjusted clk, from cpu
    input         rst,           /// reset signal, from cpu
    input         branch_flag,   /// branch flag, from controller
    input         zero_flag,     /// zero flag, from ALU
    input  [31:0] imme,          /// imm in branch inst, from inst memory

    output [31:0] inst
);

reg [13:0] address; // Program Counter

////////////////////////// Instruction Memory //////////////////////////
/// The inst memory is so far a ROM ip core
/// Config: width=32bits, depth=16384(2^14)
/// Paramter: 
///         - clka: cpu clock signal, 100MHz
///         - addra: Word addressable. 14-bit from PC, = (actual address) >> 2
///         - douta: 32-bit instruction
/// TODO: update inst memory to RAM for UART
Instruction_Memory_ip Instruction_Memory_Instance(
    .clka(clk), 
    .addra(address), 
    .douta(inst)
); 

////////////////////////// PC //////////////////////////
/// Three cases for PC
/// Case1. rst: set PC to initial address
/// Case2. branch_flag && zero_flag: increment PC with imme
/// Case3. default: increment PC by 1
/// Note that PC = (actual address) >> 2

// always @(posedge clk) // CHANGE TO NEGATIVE CLKEDGE
always @(posedge clk)
begin
    if (rst)
    begin
        address <= `instruction_initial_address;
    end
    else if (branch_flag && zero_flag)
    begin
        address <= address + imme >> 2;
    end
    else
    begin
        address <= address + 1;
    end
end

endmodule
