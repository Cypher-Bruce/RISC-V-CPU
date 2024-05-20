`timescale 1ns / 1ps

module EX_MEM(
    input clk,
    input rst,
    input wrong_prediction_flag,

    input [31:0] ALU_result_EX,
    input zero_flag_EX,
    input branch_flag_EX,
    input mem_read_flag_EX,
    input mem_write_flag_EX,
    input mem_to_reg_flag_EX,
    input reg_write_flag_EX,
    input jal_flag_EX,
    input jalr_flag_EX,
    input [31:0] imme_EX,
    input [31:0] read_data_1_EX,
    input [31:0] read_data_2_EX,
    input [4:0] write_reg_idx_EX,
    input [31:0] inst_EX,
    input [31:0] program_counter_EX,
    input [31:0] program_counter_prediction_EX,

    output reg [31:0] ALU_result_MEM,
    output reg zero_flag_MEM,
    output reg branch_flag_MEM,
    output reg mem_read_flag_MEM,
    output reg mem_write_flag_MEM,
    output reg mem_to_reg_flag_MEM,
    output reg reg_write_flag_MEM,
    output reg jal_flag_MEM,
    output reg jalr_flag_MEM,
    output reg [31:0] imme_MEM,
    output reg [31:0] read_data_1_MEM,
    output reg [31:0] read_data_2_MEM,
    output reg [4:0] write_reg_idx_MEM,
    output reg [31:0] inst_MEM,
    output reg [31:0] program_counter_MEM,
    output reg [31:0] program_counter_prediction_MEM
);

always @(posedge clk) begin
    if (rst || wrong_prediction_flag) begin
        ALU_result_MEM <= 32'b0;
        zero_flag_MEM <= 1'b0;
        branch_flag_MEM <= 1'b0;
        mem_read_flag_MEM <= 1'b0;
        mem_write_flag_MEM <= 1'b0;
        mem_to_reg_flag_MEM <= 1'b0;
        reg_write_flag_MEM <= 1'b0;
        jal_flag_MEM <= 1'b0;
        jalr_flag_MEM <= 1'b0;
        imme_MEM <= 32'b0;
        read_data_1_MEM <= 32'b0;
        read_data_2_MEM <= 32'b0;
        write_reg_idx_MEM <= 5'b0;
        inst_MEM <= 32'b0;
        program_counter_MEM <= 32'b0;
        program_counter_prediction_MEM <= 32'b0;
    end 
    else begin
        ALU_result_MEM <= ALU_result_EX;
        zero_flag_MEM <= zero_flag_EX;
        branch_flag_MEM <= branch_flag_EX;
        mem_read_flag_MEM <= mem_read_flag_EX;
        mem_write_flag_MEM <= mem_write_flag_EX;
        mem_to_reg_flag_MEM <= mem_to_reg_flag_EX;
        reg_write_flag_MEM <= reg_write_flag_EX;
        jal_flag_MEM <= jal_flag_EX;
        jalr_flag_MEM <= jalr_flag_EX;
        imme_MEM <= imme_EX;
        read_data_1_MEM <= read_data_1_EX;
        read_data_2_MEM <= read_data_2_EX;
        write_reg_idx_MEM <= write_reg_idx_EX;
        inst_MEM <= inst_EX;
        program_counter_MEM <= program_counter_EX;
        program_counter_prediction_MEM <= program_counter_prediction_EX;
    end
end

endmodule