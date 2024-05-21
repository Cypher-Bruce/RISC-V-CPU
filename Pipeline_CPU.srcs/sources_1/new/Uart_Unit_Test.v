`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/21 17:22:44
// Design Name: 
// Module Name: Uart_Unit_Test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Uart_Unit_Test(
    input             raw_clk,
    input             raw_rst,
    input  [23:0]     switch,
    input  [4:0]      button,
    output [23:0]     led,
    output [7:0]      tube_select_onehot,
    output [7:0]      tube_shape,
    
    input             rx,
    output            tx
);

wire [31:0] seven_seg_tube;
wire [7:0]  minus_sign_flag;
wire [7:0]  dot_flag;
wire [7:0]  show_none_flag;
wire cpu_clk;  // 23MHz clock signal
wire uart_clk_in; // 10MHz clock signal

CPU_Main_Clock_ip CPU_Main_Clock_ip_Instance(
    .clk_in1(raw_clk),
    .clk_out1(cpu_clk),
    .clk_out2(uart_clk_in)
);

////////// Button Debouncer //////////

wire rst;
wire [4:0] debounced_button;
wire [4:0] push_button_flag;
wire [4:0] release_button_flag;

Debouncer Debouncer_Instance(
    .raw_clk(raw_clk),
    .rst(rst),
    .button(button),
    .debounced_button(debounced_button),
    .push_button_flag(push_button_flag),
    .release_button_flag(release_button_flag)
);

///////////// UART Programmer ///////////// 
wire start_pg = push_button_flag[4];
wire uart_clk_out;
wire upg_wen; //Uart write out enable
wire upg_done; //Uart iFpgaUartFromPc data have done
wire [14:0] upg_adr; //data to which memory unit of program_rom/dmemory32
wire [31:0] upg_dat; //data to program_rom or dmemory32
wire spg_bufg;
BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter
// Generate UART Programmer reset signal
reg upg_rst;
always @ (posedge raw_clk) begin
    if (spg_bufg) 
        upg_rst <= 0;
    if (raw_rst) 
        upg_rst <= 1;
end

assign rst = raw_rst | !upg_rst; //used for other modules which don't relate to UART

/* if kickOff is 1 means CPU work on normal mode, otherwise CPU work on Uart communication mode */
wire kick_off_flag = upg_rst | (~upg_rst & upg_done);

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


Instruction_Memory Instruction_Memory_Instance(
    .clk(cpu_clk),
    .program_counter(24'h000000),
    .inst(seven_seg_tube),
    .kick_off_flag(kick_off_flag),
    .upg_clk(uart_clk_out),
    .upg_wen(upg_wen & (!upg_adr[14])),
    .upg_adr(upg_adr[13:0]),
    .upg_dat(upg_dat)
);

assign led = seven_seg_tube[23:0];

endmodule
