`timescale 1ns / 1ps
`include "Parameters.v"

module Data_Memory (
    input               clk,
    input       [31:0]  address_absolute,
    input       [31:0]  write_data,
    input               read_flag,
    input               write_flag,

    output      [31:0]  read_data
); 

wire [31:0] address;
assign address = address_absolute - `data_memory_initial_address;

Data_Memory_ip Data_Memory_ip_Instance(
    .clka(~clk),
    .wea(write_flag),
    .addra(address[15:2]), 
    .dina(write_data), 
    .douta(read_data)
);

endmodule
