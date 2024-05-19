`timescale 1ns / 1ps

module Seven_Seg_Tube_Driver_tb();

    reg             raw_clk;
    reg             rst;
    reg      [31:0] data;
    wire     [7:0]  tube_select_onehot;
    wire     [7:0]  tube_shape;

    initial begin
        raw_clk = 1'b0;
        rst = 1'b1;
        data = 32'h12345678;
        #100 rst = 1'b0;
    end

    always begin
        #1 raw_clk = ~raw_clk;
    end

    Seven_Seg_Tube_Driver Seven_Seg_Tube_Driver_Instance(
        .raw_clk(raw_clk),
        .rst(rst),
        .data(data),
        .tube_select_onehot(tube_select_onehot),
        .tube_shape(tube_shape)
    );
endmodule
