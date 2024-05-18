`timescale 1ns / 1ps

module ID_EX(
    input clk,
    input rst,
    input stall_flag,

    input branch_flag_ID,
    input [1:0] ALU_operation_ID,
    input ALU_src_flag_ID,
    input mem_read_flag_ID,
    input mem_write_flag_ID,
    input mem_to_reg_flag_ID,
    input reg_write_flag_ID,
    input jal_flag_ID,
    input jalr_flag_ID,
    input lui_flag_ID,
    input auipc_flag_ID,
    input [31:0] imme_ID,
    input [31:0] read_data_1_ID,
    input [31:0] read_data_2_ID,
    input [4:0] read_reg_idx_1_ID,
    input [4:0] read_reg_idx_2_ID,
    input [4:0] write_reg_idx_ID,
    input [31:0] inst_ID,
    input [31:0] program_counter_ID,

    output reg branch_flag_EX,
    output reg [1:0] ALU_operation_EX,
    output reg ALU_src_flag_EX,
    output reg mem_read_flag_EX,
    output reg mem_write_flag_EX,
    output reg mem_to_reg_flag_EX,
    output reg reg_write_flag_EX,
    output reg jal_flag_EX,
    output reg jalr_flag_EX,
    output reg lui_flag_EX,
    output reg auipc_flag_EX,
    output reg [31:0] imme_EX,
    output reg [31:0] read_data_1_EX,
    output reg [31:0] read_data_2_EX,
    output reg [4:0] read_reg_idx_1_EX,
    output reg [4:0] read_reg_idx_2_EX,
    output reg [4:0] write_reg_idx_EX,
    output reg [31:0] inst_EX,
    output reg [31:0] program_counter_EX
);

always @(posedge clk) begin
    if (rst || stall_flag) begin
        branch_flag_EX <= 1'b0;
        ALU_operation_EX <= 2'b00;
        ALU_src_flag_EX <= 1'b0;
        mem_read_flag_EX <= 1'b0;
        mem_write_flag_EX <= 1'b0;
        mem_to_reg_flag_EX <= 1'b0;
        reg_write_flag_EX <= 1'b0;
        jal_flag_EX <= 1'b0;
        jalr_flag_EX <= 1'b0;
        lui_flag_EX <= 1'b0;
        auipc_flag_EX <= 1'b0;
        imme_EX <= 32'b0;
        read_data_1_EX <= 32'b0;
        read_data_2_EX <= 32'b0;
        read_reg_idx_1_EX <= 5'b0;
        read_reg_idx_2_EX <= 5'b0;
        write_reg_idx_EX <= 5'b0;
        inst_EX <= 32'b0;
        program_counter_EX <= 32'b0;
    end
    else begin
        branch_flag_EX <= branch_flag_ID;
        ALU_operation_EX <= ALU_operation_ID;
        ALU_src_flag_EX <= ALU_src_flag_ID;
        mem_read_flag_EX <= mem_read_flag_ID;
        mem_write_flag_EX <= mem_write_flag_ID;
        mem_to_reg_flag_EX <= mem_to_reg_flag_ID;
        reg_write_flag_EX <= reg_write_flag_ID;
        jal_flag_EX <= jal_flag_ID;
        jalr_flag_EX <= jalr_flag_ID;
        lui_flag_EX <= lui_flag_ID;
        auipc_flag_EX <= auipc_flag_ID;
        imme_EX <= imme_ID;
        read_data_1_EX <= read_data_1_ID;
        read_data_2_EX <= read_data_2_ID;
        read_reg_idx_1_EX <= read_reg_idx_1_ID;
        read_reg_idx_2_EX <= read_reg_idx_2_ID;
        write_reg_idx_EX <= write_reg_idx_ID;
        inst_EX <= inst_ID;
        program_counter_EX <= program_counter_ID;
    end
end


endmodule
