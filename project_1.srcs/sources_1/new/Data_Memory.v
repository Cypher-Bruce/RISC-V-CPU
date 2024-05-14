`timescale 1ns / 1ps

module Data_Memory(
input clk,
input [31:0] address,
input [31:0] write_data,
input mem_read_flag,
input mem_write_flag,
output [31:0] read_data
);

Data_Memory_ip Data_Memory_Instance(
    .clka(clk),
    .wea(mem_write_flag), 
    .addra(address[13:0]), 
    .dina(write_data), 
    .douta(read_data)
);

endmodule
