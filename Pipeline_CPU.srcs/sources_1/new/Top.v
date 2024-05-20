`timescale 1ns / 1ps

module Top(
    input             raw_clk,
    input             rst,
    input  [23:0]     switch,
    input  [4:0]      button,
    output [23:0]     led,
    output [7:0]      tube_select_onehot,
    output [7:0]      tube_shape
);

wire [31:0] seven_seg_tube;
wire [7:0]  minus_sign_flag;
wire [7:0]  dot_flag;
wire [7:0]  show_none_flag;
wire clk;  // 23MHz clock signal

CPU_Main_Clock_ip CPU_Main_Clock_ip_Instance(
    .clk_in1(raw_clk),
    .clk_out1(clk)
);

wire [4:0] debounced_button;
wire [4:0] push_button_flag;
wire [4:0] release_button_flag;

Debouncer Debouncer_Instance(
    .cpu_clk(clk),
    .rst(rst),
    .button(button),
    .debounced_button(debounced_button),
    .push_button_flag(push_button_flag),
    .release_button_flag(release_button_flag)
);

CPU_Top CPU_Top_Instance(
    .clk(clk),
    .rst(rst),
    .switch(switch),
    .debounced_button(debounced_button),
    .push_button_flag(push_button_flag),
    .release_button_flag(release_button_flag),
    .led(led),
    .seven_seg_tube(seven_seg_tube),
    .minus_sign_flag(minus_sign_flag),
    .dot_flag(dot_flag),
    .show_none_flag(show_none_flag)
);

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
