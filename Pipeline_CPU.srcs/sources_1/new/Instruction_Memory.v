`timescale 1ns / 1ps

module Instruction_Memory(
    input clk,
    input [31:0] program_counter,
    output [31:0] inst,

    // UART Programmer Pinouts
    input         kick_off_flag,       
    input         uart_clk,           // UPG clk(10MHz)
    input         upg_wen,           // UPG write enable
    input  [13:0] upg_adr,           // UPG write address
    input  [31:0] upg_dat            // UPG write data
);

// Instruction_Memory_ip Instruction_Memory_ip_Instance(
//     .clka(clk), 
//     .addra(program_counter[15:2]), 
//     .douta(inst)
// );

////////////////////////// Instruction Memory //////////////////////////
/// The inst memory is so far a ROM ip core
/// Config: width=32bits, depth=16384(2^14), capacity=64KB
/// Paramter: 
///         - clka: cpu clock signal, 23MHz
///         - addra: Word addressable. 14-bit from PC, = PC >> 2
///         - douta: 32-bit instruction
/// TODO: update inst memory to RAM for UART
/// Note: 
///         - Data is read at the FALLING edge of the clock signal
///         - To implement UART, instruction memory is changed to RAM ip core


Instruction_Memory_ip Instruction_Memory_Instance(
    .clka  (kick_off_flag ? clk                   : uart_clk),
    .wea   (kick_off_flag ? 1'b0                  : upg_wen),
    .addra (kick_off_flag ? program_counter[15:2] : upg_adr),
    .dina  (kick_off_flag ? 32'h00000000          : upg_dat),
    .douta (inst)
);

endmodule