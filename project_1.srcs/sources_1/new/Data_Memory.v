`timescale 1ns / 1ps
/// Module: Data_Memory
/// #Description: 
///     This module is the data memory module. It is used to store the data in the memory.
///     It has a 14-bit address bus and a 32-bit data bus. 
///     Data Memory is implemented with ipcore, it is a RAM
/// #Input: clk, address, write_data, mem_read_flag, mem_write_flag
/// #Output: read_data
/// #TODO: update the module for UART

module Data_Memory (
    input               clk,             // adjusted clk signal, from cpu_top
    input       [31:0]  address,         // 14-bit address bus, from ALU
    input       [31:0]  write_data,      // data to be written in memory, from ALU
    input       [31:0]  inst,
    input               mem_read_flag,   // read flag, from controller
    input               mem_write_flag,  // write flag, from controller
    input       [23:0]  switch,

    output      [31:0]  read_data,       // data read from memory, to register file(load inst.)
    output reg  [23:0]  led
); 

///////////////////////// DATA MEMORY //////////////////////////
Data_Memory_ip Data_Memory_Instance(
    .clka(clk),
    .wea(mem_write_flag), 
    .addra(address[15:2]), 
    .dina(write_data), 
    .douta(read_data)
);

endmodule
