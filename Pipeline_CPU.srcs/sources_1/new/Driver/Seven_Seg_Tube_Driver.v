`timescale 1ns / 1ps
`include "Seven_Seg_Tube_Parameters.v"

module Seven_Seg_Tube_Driver(
    input             raw_clk,
    input             rst,
    input      [31:0] data,
    output     [7:0]  tube_select_onehot,
    output     [7:0]  tube_shape
);

// raw_clk: 100MHz
// half_period: 5E4
// clk = raw_clk / half_period / 2 = 1KHz
// fps = clk / 8 = 125Hz (for each tube)

    reg [31:0] clock_divider_counter;
    reg clk;
    wire [3:0] digits [0:7];
    wire [6:0] pre_defined_shape [0:15];
    reg [2:0] tube_select;

    always @(posedge raw_clk or posedge rst) begin
        if (rst) begin
            clock_divider_counter <= 32'b0;
            clk <= 1'b0;
        end
        else begin
            if (clock_divider_counter == `half_period - 1) begin
                clock_divider_counter <= 32'b0;
                clk <= ~clk;
            end
            else begin
                clock_divider_counter <= clock_divider_counter + 1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tube_select <= 3'b000;
        end
        else begin
            tube_select <= tube_select + 1;
        end
    end

    assign tube_select_onehot = ~(8'b00000001 << tube_select);  // inverted for active low

    assign pre_defined_shape[0]  = `DIGIT_SHAPE_0;
    assign pre_defined_shape[1]  = `DIGIT_SHAPE_1;
    assign pre_defined_shape[2]  = `DIGIT_SHAPE_2;
    assign pre_defined_shape[3]  = `DIGIT_SHAPE_3;
    assign pre_defined_shape[4]  = `DIGIT_SHAPE_4;
    assign pre_defined_shape[5]  = `DIGIT_SHAPE_5;
    assign pre_defined_shape[6]  = `DIGIT_SHAPE_6;
    assign pre_defined_shape[7]  = `DIGIT_SHAPE_7;
    assign pre_defined_shape[8]  = `DIGIT_SHAPE_8;
    assign pre_defined_shape[9]  = `DIGIT_SHAPE_9;
    assign pre_defined_shape[10] = `DIGIT_SHAPE_A;
    assign pre_defined_shape[11] = `DIGIT_SHAPE_B;
    assign pre_defined_shape[12] = `DIGIT_SHAPE_C;
    assign pre_defined_shape[13] = `DIGIT_SHAPE_D;
    assign pre_defined_shape[14] = `DIGIT_SHAPE_E;
    assign pre_defined_shape[15] = `DIGIT_SHAPE_F;

    assign digits[0] = data[3:0];
    assign digits[1] = data[7:4];
    assign digits[2] = data[11:8];
    assign digits[3] = data[15:12];
    assign digits[4] = data[19:16];
    assign digits[5] = data[23:20];
    assign digits[6] = data[27:24];
    assign digits[7] = data[31:28];

    assign tube_shape = ~{1'b0, pre_defined_shape[digits[tube_select]]};  // inverted for active low

endmodule