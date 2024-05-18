`timescale 1ns / 1ps

/// Module: Decoder
/// #Description
///    This module is used to decode the instruction and generate some extra values.
///    More than one stage are involved in this module, they are related to register files
///     - ID: Get the register values and immediate value based on instruction
///     - WB: Write the data back to the register file, eg: load, R-type
/// #Inputs: clk, rst, write_data, reg_write_flag, inst
/// #Outputs: read_data_1, read_data_2, imme
/// #Signals:
///    - register: 32 registers, each has 32 bits
///    - read_reg_idx_1: index of the first register to be read
///    - read_reg_idx_2: index of the second register to be read
///    - write_reg_idx: index of the register to be written, used in WB stage

module Decoder (
    input  [31:0] inst,                 // instruction, from Instruction_Memory(IF)

    output [4:0] read_reg_idx_1,      // register index 1 to be read from, to register
    output [4:0] read_reg_idx_2,      // register index 2 to be read from, to register
    output [4:0] write_reg_idx        // register index to be written to, to register
);

assign read_reg_idx_1 = inst[19:15];
assign read_reg_idx_2 = inst[24:20];
assign write_reg_idx  = inst[11:7];

endmodule
