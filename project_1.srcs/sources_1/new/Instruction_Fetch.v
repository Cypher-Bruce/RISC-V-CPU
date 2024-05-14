`timescale 1ns / 1ps
`include "Parameters.v"

/// Module: Instruction_Fetch
/// #Description 
///                This module is responsible for fetching the instruction from the instruction memory.
///              according to the address. The address is from PC.
///              Note: the PC increments by 1 each cycle, unless there is a branch instruction.
///              Note(cont.): Thus, addr from PC can directly be used in inst. mem instead of right shift.
/// #Input       clk, rst, branch_flag, jump_flag, zero_flag, imme
/// #Outputs     inst, program_counter
/// #Signals     
///         - address: 14-bit address for instruction memory
///         - branch_taken_flag: 1 if branch is taken
///         - funct3: 3-bit funct3 field from instruction

module Instruction_Fetch(
    input         clk,           /// adjusted clk, from cpu
    input         rst,           /// reset signal, from cpu
    input         branch_flag,   /// branch flag, from controller
    input         jump_flag,     /// jump flag, from controller
    input         zero_flag,     /// 1 if sub result is 0, from ALU, 
    input  [31:0] imme,          /// imm in branch inst, from inst memory

    output [31:0] inst,
    output reg [31:0] program_counter
);

reg         branch_taken_flag;
wire [2:0]  funct3;  

////////////////////////// Instruction Memory //////////////////////////
/// The inst memory is so far a ROM ip core
/// Config: width=32bits, depth=16384(2^14), capacity=64KB
/// Paramter: 
///         - clka: cpu clock signal, 23MHz
///         - addra: Word addressable. 14-bit from PC, = PC >> 2
///         - douta: 32-bit instruction
/// TODO: update inst memory to RAM for UART
  
Instruction_Memory_ip Instruction_Memory_Instance(
    .clka(clk), 
    .addra(program_counter[15:2]), 
    .douta(inst)
); 

////////////////////////// BRANCH CONTROL //////////////////////////
/// According to the result and the branch instruction,
/// PC is determined to go to goal address or not
/// It corresponds to the MUX in the CPU blueprint, but with some modifications added
  
assign funct3 = inst[14:12];

always @*
begin
    if (jump_flag)
    begin
        branch_taken_flag = 1;
    end
    else
    begin
        case(funct3)
            3'b000: // beq (ALU do sub)
            begin
                branch_taken_flag = zero_flag;
            end
            3'b001: // bne
            begin
                branch_taken_flag = !zero_flag;
            end
            3'b100: // blt (ALU do slt instead of sub)
            begin
                branch_taken_flag = !zero_flag;
            end
            3'b101: // bge
            begin
                branch_taken_flag = zero_flag;
            end
            3'b110: // bltu (ALU do sltu instead of sub)
            begin
                branch_taken_flag = !zero_flag;
            end
            3'b111: // bgeu
            begin
                branch_taken_flag = zero_flag;
            end
        endcase
    end
end

////////////////////////// PC //////////////////////////
/// Three cases for PC
/// Case1. rst: set PC to initial address
/// Case2. branch_flag && branch_taken_flag: increment PC with imme
/// Case3. default: increment PC by 4
/// Note that actual address sent to memory ip core is address >> 2

always @(posedge clk)
begin
    if (rst)
    begin
        program_counter <= `instruction_initial_address;
    end
    else if (branch_flag && branch_taken_flag)
    begin
        program_counter <= program_counter + imme;
    end
    else
    begin
        program_counter <= program_counter + 4;
    end
end

endmodule
