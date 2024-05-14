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
wire [31:0] inst_mem_data;
reg branch_taken_flag;
wire [2:0] funct3;
Instruction_Memory_ip Instruction_Memory_Instance(
    .clka(clk), 
    .addra(address), 
    .douta(inst_mem_data)
); 

assign inst = inst_mem_data;
assign funct3 = inst[14:12];

always @*
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

always @(posedge clk)
begin
    if (rst)
    begin
        address <= `instruction_initial_address;
    end
    else if (branch_flag && branch_taken_flag)
    begin
        address <= address + imme >> 2;
    end
    else
    begin
        address <= address + 1;
    end
end

endmodule
