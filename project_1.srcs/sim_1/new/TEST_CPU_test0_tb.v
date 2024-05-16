`timescale 1ns/1ps

/// Module: TEST_CPU_test0_tb
/// Description: Testbench for the CPU_Top module.
///              After testing the instruction and data on board, we fail to have the result we want
///              So we decide to test the CPU_Top module in the simulation environment
/// Notes: some things to consider
///     - The clock period, is it suitable?
/// Expected test results: led should have the same value as switch

module TEST_CPU_test0_tb();

    // Parameters
    parameter CLK_PERIOD = 1; // Clock period in ns

    // Inputs
    reg raw_clk = 0;
    reg rst = 0;
    reg [23:0] switch;
    reg [4:0] button;

    // Outputs
    wire [23:0] led;

    // Instantiate the module to be tested
    CPU_Top dut (
        .raw_clk(raw_clk),
        .rst(rst),
        .switch(switch),
        .button(button),
        .led(led)
    );

    // Clock generation
    always #CLK_PERIOD raw_clk = ~raw_clk;

    // Reset generation
    initial begin
        #10;
        rst = 1;

        # 500;
        rst = 0;
    end

    // Test sequence
    initial begin
        #2000;
        switch = 24'hffffff;
    end

endmodule
