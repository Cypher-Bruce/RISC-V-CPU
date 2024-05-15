`timescale 1ns / 1ps
`include "Parameters.v"

module Data_Memory_tb();

reg clk;
reg  [31:0] address;
reg  [31:0] write_data;
reg  [31:0] inst;
reg         mem_read_flag;
reg         mem_write_flag;
reg  [23:0] switch;
wire [31:0] read_data;
wire [23:0] led;
Data_Memory Data_Memory_Instance(
    .clk(clk),
    .address(address),
    .write_data(write_data),
    .inst(inst),
    .mem_read_flag(mem_read_flag),
    .mem_write_flag(mem_write_flag),
    .switch(switch),
    .read_data(read_data),
    .led(led)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    mem_read_flag = 1;
    mem_write_flag = 0;
    switch = 24'b10010110_10101010_01010101;
    address = {16'h0000, `switch_initial_address};
    write_data = 32'h00000000;
    inst = 32'h00002003;

    #5;
    mem_read_flag = 0;
    mem_write_flag = 1;
    write_data = 32'h00001234;
    address = 32'h00000000;

    #10;
    mem_read_flag = 1;
    mem_write_flag = 0;
    address = 32'h00000000;

    #10;
    address = 32'h00000004;

    #10;
    mem_read_flag = 0;
    mem_write_flag = 1;
    write_data = 32'h00000678;
    address = {16'h0000, `led_initial_address};

    #10;
    $finish;
end
endmodule
