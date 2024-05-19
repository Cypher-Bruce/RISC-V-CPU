`timescale 1ns / 1ps

module IF_ID(
    input clk,
    input rst,
    input stall_flag,
    input wrong_prediction_flag,
    
    input [31:0] inst_IF,
    input [31:0] program_counter_IF,
    input [31:0] program_counter_prediction_IF,

    output reg [31:0] inst_ID,
    output reg [31:0] program_counter_ID,
    output reg [31:0] program_counter_prediction_ID
);

always @(posedge clk) begin
    if (rst || wrong_prediction_flag) begin
        inst_ID <= 32'b0;
        program_counter_ID <= 32'b0;
        program_counter_prediction_ID <= 32'b0;
    end 
    else if (stall_flag) begin
        inst_ID <= inst_ID;
        program_counter_ID <= program_counter_ID;
        program_counter_prediction_ID <= program_counter_prediction_ID;
    end
    else begin
        inst_ID <= inst_IF;
        program_counter_ID <= program_counter_IF;
        program_counter_prediction_ID <= program_counter_prediction_IF;
    end
end
endmodule