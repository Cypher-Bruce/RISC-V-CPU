`timescale 1ns / 1ps
`include "Parameters.v"

module Data_Memory (
    input               clk,
    input       [31:0]  address_absolute,
    input       [31:0]  write_data,
    input               read_flag,
    input               write_flag,

    output      [31:0]  read_data,

    // UART Programmer Pinouts
    input           kick_off_flag,
    input           uart_clk,           // UPG ram_clk_i(10MHz)
    input           upg_wen,           // UPG write enable
    input [13:0]    upg_adr,           // UPG write address
    input [31:0]    upg_dat            // UPG write data
); 

wire [31:0] address;
assign address = address_absolute - `data_memory_initial_address;

// Data_Memory_ip Data_Memory_ip_Instance(
//     .clka(~clk),
//     .wea(write_flag),
//     .addra(address[15:2]), 
//     .dina(write_data), 
//     .douta(read_data)
// );

////////////////////////// DATA MEMORY //////////////////////////
/// Question: when the data is read or write? rising or falling edge?
/// !!! Data is read or write at the FALLING edge of the clock signal
/// No instruction requires read and write at the same time

Data_Memory_ip Data_Memory_Instance(
    .clka  (kick_off_flag ? ~clk          : uart_clk),
    .wea   (kick_off_flag ? write_flag    : upg_wen),
    .addra (kick_off_flag ? address[15:2] : upg_adr),
    .dina  (kick_off_flag ? write_data    : upg_dat),
    .douta (read_data)
);

endmodule