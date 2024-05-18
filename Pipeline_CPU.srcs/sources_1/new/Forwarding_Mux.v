`timescale 1ns / 1ps

module Forwarding_Mux(
    input [31:0] read_data_1_raw,
    input [31:0] read_data_2_raw,
    input [31:0] read_data_1_forwarding,
    input [31:0] read_data_2_forwarding,
    input read_data_1_forwarding_flag,
    input read_data_2_forwarding_flag,

    output [31:0] read_data_1,
    output [31:0] read_data_2
);

assign read_data_1 = (read_data_1_forwarding_flag) ? read_data_1_forwarding : read_data_1_raw;
assign read_data_2 = (read_data_2_forwarding_flag) ? read_data_2_forwarding : read_data_2_raw;
endmodule
