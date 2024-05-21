`timescale 1ns / 1ps

module Top(
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
wire cpu_clk;       // 23MHz clock signal
wire uart_clk_in;   // 10MHz clock signal

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

///////////// UART  ///////////// 

wire          kick_off_flag;  // 1 -> working mode, 0 -> communication mode
wire          uart_clk_out;   // uart out cycle, to data and instruction memory
wire          upg_wen;        // uart write out enable
wire  [14:0]  upg_adr;        // address to which memory unit of program_rom/dmemory32
wire  [31:0]  upg_dat;        // data to program_rom or dmemory32

UART UART_Instance(
    .uart_clk_in   (uart_clk_in),
    .raw_clk       (raw_clk),
    .raw_rst       (raw_rst),
    .start_pg      (push_button_flag[4]),
    .kick_off_flag (kick_off_flag),
    .uart_clk_out  (uart_clk_out),
    .upg_wen       (upg_wen),
    .upg_adr       (upg_adr),
    .upg_dat       (upg_dat),
    .rst           (rst),
    .rx            (rx),
    .tx            (tx)
);

////////// CPU //////////

CPU_Top CPU_Top_Instance(
    .clk(cpu_clk),
    .rst(rst),
    .switch(switch),
    .debounced_button(debounced_button),
    .push_button_flag(push_button_flag),
    .release_button_flag(release_button_flag),
    .led(led),
    .seven_seg_tube(seven_seg_tube),
    .minus_sign_flag(minus_sign_flag),
    .dot_flag(dot_flag),
    .show_none_flag(show_none_flag),

    // UART pinouts
    .kick_off_flag(kick_off_flag),
    .uart_clk(uart_clk_out),
    .upg_wen(upg_wen),
    .upg_adr(upg_adr),
    .upg_dat(upg_dat)
);

////////// Seven Segment Tube Driver //////////

Seven_Seg_Tube_Driver Seven_Seg_Tube_Driver_Instance(
    .raw_clk(raw_clk),
    .rst(rst),
    .data(seven_seg_tube),
    .minus_sign_flag(minus_sign_flag),
    .dot_flag(dot_flag),
    .show_none_flag(show_none_flag),
    .tube_select_onehot(tube_select_onehot),
    .tube_shape(tube_shape)
);
endmodule
