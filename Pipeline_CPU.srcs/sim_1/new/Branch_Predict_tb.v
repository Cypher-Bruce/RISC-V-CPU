`timescale 1ns / 1ps

module Branch_Predict_tb();

    reg             raw_clk;
    reg             raw_rst;
    reg  [23:0]     switch;
    reg  [4:0]      button;
    wire [23:0]     led;
    wire [7:0]      tube_select_onehot;
    wire [7:0]      tube_shape;
    reg             rx;
    wire            tx;

    Top Top_Instance(
        .raw_clk(raw_clk),
        .raw_rst(raw_rst),
        .switch(switch),
        .button(button),
        .led(led),
        .tube_select_onehot(tube_select_onehot),
        .tube_shape(tube_shape),
        .rx(rx),
        .tx(tx)
    );

    initial begin
        raw_clk = 0;
        raw_rst = 1;
        switch = 0;
        button = 0;
        rx = 0;
        forever #5 raw_clk = ~raw_clk;
    end
    
    initial begin
        #3000 raw_rst = 0;
    end

endmodule
