`timescale 1ns / 1ps
`include "Parameters.v"

/// Module: Data_Memory
/// Description: This module is the data memory of the RISC-V processor.
///              Also, UART commnication is supported here.

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

////////////////////////// ADDRESS SHIFTING //////////////////////////
/// !Note: in pipeline version CPU, the memory ip core is detached from instrctoin fectch, this module only deals with PC.
/// We use memory layout like this: https://photos.app.goo.gl/8xTAXyCikpdyna5V9
/// Because it's not possible to access various memory IP cores using absolute addresses in the address space,
/// it's necessary to perform address offsetting when accessing IP core addresses: absolute address - offset within the address section.
/// Therefore, when accessing instruction memory, no address adjustment is required,
/// whereas when accessing data memory, the absolute address needs to be subtracted by 0x2000.
wire [31:0] address;
assign address = address_absolute - `data_memory_initial_address;

////////////////////////// DATA MEMORY //////////////////////////
/// Data is read or write at the FALLING edge of the clock signal
/// No instruction requires read and write at the same time

Data_Memory_ip Data_Memory_Instance(
    .clka  (kick_off_flag ? ~clk          : uart_clk),
    .wea   (kick_off_flag ? write_flag    : upg_wen),
    .addra (kick_off_flag ? address[15:2] : upg_adr),
    .dina  (kick_off_flag ? write_data    : upg_dat),
    .douta (read_data)
);

endmodule