`timescale 1ns / 1ps

/// Module: UART
/// Description: This module is responsible for UART communication between the FPGA and the PC.
/// Note: rst is redefined in this module


module UART(
    input         uart_clk_in,
    input         raw_clk,
    input         raw_rst,
    input         start_pg,

    output        kick_off_flag,
    output        uart_clk_out,
    output        upg_wen,
    output [14:0] upg_adr,
    output [31:0] upg_dat,

    output        rst,

    input         rx,
    output        tx
);

wire upg_done; //Uart iFpgaUartFromPc data have done
reg upg_rst = 1;

assign rst = raw_rst | !upg_rst;  //used for other modules which don't relate to UART
assign kick_off_flag = upg_rst | (~upg_rst & upg_done);  /* if kickOff is 1 means CPU work on normal mode, otherwise CPU work on Uart communication mode */

// de-twitter
wire spg_bufg;
BUFG U1(.I(start_pg), .O(spg_bufg)); 

// Generate UART Programmer reset signal
always @ (posedge raw_clk) begin
    if (spg_bufg) 
        upg_rst <= 0;
    if (raw_rst) 
        upg_rst <= 1;
end

uart_bmpg_0 uart_Instance(
    .upg_clk_i(uart_clk_in),
    .upg_rst_i(upg_rst),
    .upg_rx_i(rx),
    
    .upg_clk_o(uart_clk_out),
    .upg_wen_o(upg_wen),
    .upg_adr_o(upg_adr),
    .upg_dat_o(upg_dat),
    .upg_done_o(upg_done),
    .upg_tx_o(tx)
);
endmodule