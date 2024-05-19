`timescale 1ns / 1ps

module Top_tb();

reg            raw_clk;
reg            rst;
reg  [23:0]    switch;
reg  [4:0]     button;
wire [23:0]    led;
wire [7:0]     tube_select_onehot;
wire [7:0]     tube_shape;

Top Top_Instance(
    .raw_clk(raw_clk),
    .rst(rst),
    .switch(switch),
    .button(button),
    .led(led),
    .tube_select_onehot(tube_select_onehot),
    .tube_shape(tube_shape)
);

initial begin
    raw_clk = 0;
    rst = 1;
    switch = 24'hFFFFFF;
    forever #5 raw_clk = ~raw_clk;
end

initial begin
    #2720 rst = 0;
end
endmodule
