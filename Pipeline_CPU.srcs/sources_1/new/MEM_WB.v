`timescale 1ns / 1ps

module MEM_WB(
    input clk,
    input rst,
    input [31:0] read_data_MEM,
    input [31:0] ALU_result_MEM,
    input mem_to_reg_flag_MEM,
    input reg_write_flag_MEM,
    input [4:0] write_reg_idx_MEM,

    output reg [31:0] read_data_WB,
    output reg [31:0] ALU_result_WB,
    output reg mem_to_reg_flag_WB,
    output reg reg_write_flag_WB,
    output reg [4:0] write_reg_idx_WB
);

always @(posedge clk) begin
    if (rst) begin
        read_data_WB <= 32'b0;
        ALU_result_WB <= 32'b0;
        mem_to_reg_flag_WB <= 1'b0;
        reg_write_flag_WB <= 1'b0;
        write_reg_idx_WB <= 5'b0;
    end else begin
        read_data_WB <= read_data_MEM;
        ALU_result_WB <= ALU_result_MEM;
        mem_to_reg_flag_WB <= mem_to_reg_flag_MEM;
        reg_write_flag_WB <= reg_write_flag_MEM;
        write_reg_idx_WB <= write_reg_idx_MEM;
    end
end

endmodule