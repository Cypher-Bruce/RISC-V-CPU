`timescale 1ns / 1ps
`include "Parameters.v"
/// Module: Data_Memory
/// #Description: 
///     This module is the data memory module. It is used to store the data in the memory.
///     It has a 14-bit address bus and a 32-bit data bus. 
///     Data Memory is implemented with ipcore, it is a RAM
/// #Input: clk, address, write_data, inst, mem_read_flag, mem_write_flag, switch
/// #Output: read_data, led
/// #TODO: update the module for UART

module Data_Memory (
    input               clk,             // adjusted clk signal, from cpu_top
    input       [31:0]  address,         // 14-bit address bus, from ALU
    input       [31:0]  write_data,      // data to be written in memory, from ALU
    input       [31:0]  inst,            // instruction from inst memory (to determine output byte/half/word)
    input               mem_read_flag,   // read flag, from controller
    input               mem_write_flag,  // write flag, from controller
    input       [23:0]  switch,          // switch input, from board

    output reg  [31:0]  read_data,       // data read from memory, to register file(load inst.)
    output reg  [23:0]  led,              // led output, to board


    // UART Programmer Pinouts
    input           upg_rst_i,           // UPG reset
    input           upg_clk_i,           // UPG ram_clk_i(10MHz)
    input           upg_wen_i,           // UPG write enable
    input [13:0]    upg_adr_i,           // UPG write address
    input [31:0]    upg_dat_i,           // UPG write data
    input           upg_done_i          // 1 if UPG is done

); 

///////////////////////// MMIO //////////////////////////
/// Update: mmio is implemented

wire [31:0] block_memory_read_data; // data read from block memory
reg  [31:0] io_device_read_data;    // data read from io device
wire data_flag;                     // which divice to read/write, 0: block memory, 1: io device
wire [31:0] raw_read_data;          // raw data read chosen from block memory or io device

/// configure the data flag to choose the data to read: data memory or io device
assign data_flag = ($unsigned(address[15:0]) >= $unsigned(`IO_device_initial_address)) ? 1 : 0; // 0: block memory, 1: io device
assign raw_read_data = data_flag ? io_device_read_data : block_memory_read_data;                // choose the data to read

/// handle the io device write
always @(negedge clk) begin
    if (data_flag ? mem_write_flag : 1'b0) begin
        case (address[15:0])
            `led_initial_address: led <= write_data[23:0];
            default: led <= led;
        endcase
    end
end

/// handle the io device read
always @* begin
    case (address[15:0])
        `switch_initial_address: io_device_read_data = {8'h00, switch};
        default: io_device_read_data = 32'h00000000;
    endcase
end

/// manipulate the raw data read from block memory or io device, and sign extend it
/// lb, lh, lw, lbu, lhu
wire [2:0] funct3;
assign funct3 = inst[14:12];

always @* begin
    if (!mem_read_flag)
        read_data = 32'h00000000;
    else
        case (funct3)
            3'b000: // load byte
            begin
                case (address[1:0])
                    2'b00: read_data = {{24{raw_read_data[7]}}, raw_read_data[7:0]};
                    2'b01: read_data = {{24{raw_read_data[15]}}, raw_read_data[15:8]};
                    2'b10: read_data = {{24{raw_read_data[23]}}, raw_read_data[23:16]};
                    2'b11: read_data = {{24{raw_read_data[31]}}, raw_read_data[31:24]};
                endcase
            end
            3'b001: // load half
            begin
                case (address[1])
                    1'b0: read_data = {{16{raw_read_data[15]}}, raw_read_data[15:0]};
                    1'b1: read_data = {{16{raw_read_data[31]}}, raw_read_data[31:16]};
                endcase
            end
            3'b010: // load word
            begin
                read_data = raw_read_data;
            end
            3'b100: // load byte unsigned
            begin
                case (address[1:0])
                    2'b00: read_data = {24'h000000, raw_read_data[7:0]};
                    2'b01: read_data = {24'h000000, raw_read_data[15:8]};
                    2'b10: read_data = {24'h000000, raw_read_data[23:16]};
                    2'b11: read_data = {24'h000000, raw_read_data[31:24]};
                endcase
            end
            3'b101: // load half unsigned
            begin
                case (address[1])
                    1'b0: read_data = {16'h0000, raw_read_data[15:0]};
                    1'b1: read_data = {16'h0000, raw_read_data[31:16]};
                endcase
            end
            default: read_data = 32'h00000000;
        endcase
end

///////////////////////// UART  //////////////////////////
/// kickOff: mode flag, 1: normal working mode, 0: communication mode

wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);


////////////////////////// DATA MEMORY //////////////////////////
/// Question: when the data is read or write? rising or falling edge?
/// !!! Data is read or write at the FALLING edge of the clock signal
/// No instruction requires read and write at the same time

// temp write enable for readability
wire ram_wen_i;
assign ram_wen_i = data_flag ? 1'b0 : mem_write_flag;

Data_Memory_ip Data_Memory_Instance(
    .clka  (kickOff ? ~clk          : upg_clk_i),
    .wea   (kickOff ? ram_wen_i     : upg_wen_i),
    .addra (kickOff ? address[15:2] : upg_adr_i),
    .dina  (kickOff ? write_data    : upg_dat_i),
    .douta (block_memory_read_data             )
);


endmodule