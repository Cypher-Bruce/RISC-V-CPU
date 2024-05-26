`timescale 1ns / 1ps
`include "Parameters.v"

/// Module: Instruction_Fetch
/// Description: This module handles the updating of the program counter (PC).
///              Techniques like branch prediction and stall are implemented here.

module Instruction_Fetch(
    input             clk,                      /// adjusted clk, from cpu
    input             rst,                      /// reset signal, from cpu
    input             wrong_prediction_flag,    /// see Program_Counter_Prediction.v for details
    input      [31:0] branch_pc,
    input             stall_flag,
    input      [31:0] program_counter_prediction,

    output reg [31:0] program_counter,
    output reg [31:0] prev_pc
);

////////////////////////// ADDRESS SHIFTING //////////////////////////
/// !Note: in pipeline version CPU, the memory ip core is detached from instrctoin fectch, this module only deals with PC.
/// We use memory layout like this: https://photos.app.goo.gl/8xTAXyCikpdyna5V9
/// Because it's not possible to access various memory IP cores using absolute addresses in the address space,
/// it's necessary to perform address offsetting when accessing IP core addresses: absolute address - offset within the address section.
/// Therefore, when accessing instruction memory, no address adjustment is required,
/// whereas when accessing data memory, the absolute address needs to be subtracted by 0x2000.

////////////////////////// PROGRAM COUNTER //////////////////////////
/// This module handles the updating of the program counter (PC).
/// The PC is updated based on different conditions:
/// 1. If it's a reset condition, the PC is initialized to the initial address of the instruction memory.
/// 2. If a wrong prediction is detected, the PC is updated to the branch target address.
/// 3. If a stall condition is detected, the PC remains unchanged.
/// 4. Otherwise, the PC is updated to the predicted program counter value.

always @(negedge clk) begin
    if (rst) begin
        program_counter <= `inst_memory_initial_address;
        prev_pc <= `inst_memory_initial_address;
    end
    else if (wrong_prediction_flag) begin
        program_counter <= branch_pc;
        prev_pc <= program_counter;
    end
    else if (stall_flag) begin
        program_counter <= program_counter;
        prev_pc <= prev_pc;
    end
    else begin
        program_counter <= program_counter_prediction;
        prev_pc <= program_counter;
    end
end

endmodule
