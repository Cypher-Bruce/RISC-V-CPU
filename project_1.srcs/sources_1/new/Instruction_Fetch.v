`timescale 1ns / 1ps
`include "Parameters.v"

module Instruction_Fetch(
input clk,
input rst,
input branch_flag,
input zero_flag,
input [31:0] imme,
output [31:0] inst
);

reg [13:0] address;
Instruction_Memory_ip Instruction_Memory_Instance(
    .clka(clk), 
    .addra(address), 
    .douta(inst)
); 

always @(posedge clk)
begin
    if (rst)
    begin
        address <= `instruction_initial_address;
    end
    else if (branch_flag && zero_flag)
    begin
        address <= address + imme;
    end
    else
    begin
        address <= address + 1;
    end
end

endmodule
