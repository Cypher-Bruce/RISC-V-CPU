`timescale 1ns / 1ps

module Instruction_Memory(
    input clk,
    input [31:0] program_counter,
    output [31:0] inst
);

Instruction_Memory_ip Instruction_Memory_ip_Instance(
    .clka(clk), 
    .addra(program_counter[15:2]), 
    .douta(inst)
);

endmodule
