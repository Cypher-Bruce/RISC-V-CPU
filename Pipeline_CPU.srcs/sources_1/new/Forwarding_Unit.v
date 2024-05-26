`timescale 1ns / 1ps

/// Module: Forwarding_Unit
/// Description: This module is used to forward the data from the MEM and WB stages to the EX stage.
///             The forwarding unit is responsible for detecting data hazards and forwarding the data
///             to the EX stage to avoid stalls.

module Forwarding_Unit(
    input       [31:0] ALU_result_MEM,
    input       [4 :0] write_reg_idx_MEM,
    input              write_reg_flag_MEM,
    input              mem_to_reg_flag_MEM,
    input       [31:0] ALU_result_WB,
    input       [31:0] read_data_WB,
    input       [4 :0] write_reg_idx_WB,
    input              write_reg_flag_WB,
    input              mem_to_reg_flag_WB,
    input       [4 :0] read_reg_idx_1_EX,
    input       [4 :0] read_reg_idx_2_EX,

    output reg  [31:0] read_data_1_forwarding,
    output reg  [31:0] read_data_2_forwarding,
    output             read_data_1_forwarding_flag,
    output             read_data_2_forwarding_flag
);

wire MEM_hazard_1_flag;
wire MEM_hazard_2_flag;
wire WB_hazard_1_flag;
wire WB_hazard_2_flag;

assign MEM_hazard_1_flag = (write_reg_flag_MEM && (write_reg_idx_MEM == read_reg_idx_1_EX) && (read_reg_idx_1_EX != 0) && !mem_to_reg_flag_MEM);
assign MEM_hazard_2_flag = (write_reg_flag_MEM && (write_reg_idx_MEM == read_reg_idx_2_EX) && (read_reg_idx_2_EX != 0) && !mem_to_reg_flag_MEM);
assign WB_hazard_1_flag = (write_reg_flag_WB && (write_reg_idx_WB == read_reg_idx_1_EX) && (read_reg_idx_1_EX != 0));
assign WB_hazard_2_flag = (write_reg_flag_WB && (write_reg_idx_WB == read_reg_idx_2_EX) && (read_reg_idx_2_EX != 0));

assign read_data_1_forwarding_flag = MEM_hazard_1_flag || WB_hazard_1_flag;
assign read_data_2_forwarding_flag = MEM_hazard_2_flag || WB_hazard_2_flag;

always @* begin
    if (read_data_1_forwarding_flag)
        if (MEM_hazard_1_flag)
            read_data_1_forwarding = ALU_result_MEM;
        else
            if (mem_to_reg_flag_WB)
                read_data_1_forwarding = read_data_WB;
            else
                read_data_1_forwarding = ALU_result_WB;
    else
        read_data_1_forwarding = 32'b0;

    if (read_data_2_forwarding_flag)
        if (MEM_hazard_2_flag)
            read_data_2_forwarding = ALU_result_MEM;
        else
            if (mem_to_reg_flag_WB)
                read_data_2_forwarding = read_data_WB;
            else
                read_data_2_forwarding = ALU_result_WB;
    else
        read_data_2_forwarding = 32'b0;
end

endmodule
