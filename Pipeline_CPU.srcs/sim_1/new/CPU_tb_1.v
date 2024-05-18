`timescale 1ns / 1ps

module CPU_tb_1();

reg raw_clk;
reg rst;
reg [23:0] switch;
reg [4:0] button;
wire [23:0] led;
CPU_Top CPU_Top_Instance(
    .raw_clk(raw_clk),
    .rst(rst),
    .switch(switch),
    .button(button),
    .led(led)
);

initial begin
    raw_clk = 0;
    rst = 1;
    switch = 24'h123456;
    forever #5 raw_clk = ~raw_clk;
end

initial begin
    #2720 rst = 0;
end
endmodule
