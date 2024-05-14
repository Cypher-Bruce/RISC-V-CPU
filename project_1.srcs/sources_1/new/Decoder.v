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
    input         clk,              // adjusted clk signal, from cpu_top
    input         rst,              // reset signal, from cpu_top

    input  [31:0] write_data,       // data to be written in register, from ALU or Data_Memory
    input         reg_write_flag,   // write flag, from controller
    input  [31:0] inst,             // instruction, from Instruction_Memory(IF)
    input  [31:0] program_counter,  // program counter, from IF

    output [31:0] read_data_1,      // data read from register, to ALU
    output [31:0] read_data_2,      // data read from register, to ALU
    output [31:0] imme              // immediate value, to ALU
);

///////////////////////// IMMEDIATE GENERATOR //////////////////////////
Immediate_Generator Immediate_Generator_Instance(
    .inst(inst), 
    .imme(imme)
);

///////////////////////// ID //////////////////////////
/// read register data from register file
reg  [31:0] register [0:31];
wire [4:0]  read_reg_idx_1;
wire [4:0]  read_reg_idx_2;
wire [4:0]  write_reg_idx;

assign read_reg_idx_1 = inst[19:15];
assign read_reg_idx_2 = inst[24:20];
assign write_reg_idx  = inst[11:7];
assign read_data_1    = register[read_reg_idx_1];
assign read_data_2    = register[read_reg_idx_2];

///////////////////////// INIT & WB //////////////////////////
/// WB is activated when reg_write_flag is high and write_reg_idx is not 0
/// !!! The register 0 is always 0, so it can't be written
always @(posedge clk)
begin
    if (rst)
    begin
        register[0] <= 32'b0;
        register[1] <= 32'b0;
        register[2] <= 32'b0;
        register[3] <= 32'b0;
        register[4] <= 32'b0;
        register[5] <= 32'b0;
        register[6] <= 32'b0;
        register[7] <= 32'b0;
        register[8] <= 32'b0;
        register[9] <= 32'b0;
        register[10] <= 32'b0;
        register[11] <= 32'b0;
        register[12] <= 32'b0;
        register[13] <= 32'b0;
        register[14] <= 32'b0;
        register[15] <= 32'b0;
        register[16] <= 32'b0;
        register[17] <= 32'b0;
        register[18] <= 32'b0;
        register[19] <= 32'b0;
        register[20] <= 32'b0;
        register[21] <= 32'b0;
        register[22] <= 32'b0;
        register[23] <= 32'b0;
        register[24] <= 32'b0;
        register[25] <= 32'b0;
        register[26] <= 32'b0;
        register[27] <= 32'b0;
        register[28] <= 32'b0;
        register[29] <= 32'b0;
        register[30] <= 32'b0;
        register[31] <= 32'b0;
    end 
    else 
    begin
        if (reg_write_flag && write_reg_idx != 0)
        begin
            register[write_reg_idx] <= write_data;
        end
    end
end


endmodule
