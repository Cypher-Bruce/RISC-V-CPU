`timescale 1ns / 1ps

module Instruction_Fetch_tb();

reg clk;
reg rst;
reg branch_flag;
reg jal_flag;
reg jalr_flag;
reg zero_flag;
reg [31:0] imme;
reg [31:0] read_data_1;
wire [31:0] inst;
wire [31:0] program_counter;
Instruction_Fetch Instruction_Fetch_Instance(
    .clk(clk),
    .rst(rst),
    .branch_flag(branch_flag),
    .jal_flag(jal_flag),
    .jalr_flag(jalr_flag),
    .zero_flag(zero_flag),
    .imme(imme),
    .read_data_1(read_data_1),
    .inst(inst),
    .program_counter(program_counter)
);

initial begin
    clk = 0;
    rst = 1;
    branch_flag = 0;
    jal_flag = 0;
    jalr_flag = 0;
    zero_flag = 0;
    imme = 0;
    read_data_1 = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    #20 rst = 0;
    #100 $finish;
end
endmodule
