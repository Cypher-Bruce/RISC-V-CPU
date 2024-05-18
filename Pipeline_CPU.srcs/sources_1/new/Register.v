`timescale 1ns / 1ps

module Register(
    input clk,
    input rst,
    input reg_write_flag,
    input [4:0] read_reg_idx_1,
    input [4:0] read_reg_idx_2,
    input [4:0] write_reg_idx,
    input [31:0] write_data,

    output [31:0] read_data_1,
    output [31:0] read_data_2
);

    reg [31:0] register [0:31];

    assign read_data_1 = register[read_reg_idx_1];
    assign read_data_2 = register[read_reg_idx_2];

    always @(negedge clk) begin
        if (rst) begin
            register[0]  <= 32'b0;
            register[1]  <= 32'b0;
            register[2]  <= 32'b0;
            register[3]  <= 32'b0;
            register[4]  <= 32'b0;
            register[5]  <= 32'b0;
            register[6]  <= 32'b0;
            register[7]  <= 32'b0;
            register[8]  <= 32'b0;
            register[9]  <= 32'b0;
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
        else if (reg_write_flag && write_reg_idx != 5'b0) begin
            register[write_reg_idx] <= write_data;
        end
    end

endmodule
