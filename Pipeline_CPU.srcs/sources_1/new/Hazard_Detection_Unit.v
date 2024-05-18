`timescale 1ns / 1ps

module Hazard_Detection_Unit(
    input [4:0] write_reg_idx_EX,
    input write_reg_flag_EX,
    input mem_to_reg_flag_EX,
    input [4:0] read_reg_idx_1_ID,
    input [4:0] read_reg_idx_2_ID,

    output stall_flag
);

assign stall_flag = (write_reg_flag_EX && mem_to_reg_flag_EX && write_reg_idx_EX != 0 && (write_reg_idx_EX == read_reg_idx_1_ID || write_reg_idx_EX == read_reg_idx_2_ID));
endmodule
