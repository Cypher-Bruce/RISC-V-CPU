`timescale 1ns / 1ps

/// THIS TEST IS DONE ON BOARD  

/// Module: TEST_TubeDriver
/// Description: 
///      this module is to test the functionality of tube driver,
///      the test is done on Minisys.
///      The effect is the tube should show the hexadecimal representation of the 
///      binary representation obtained from switches.
///      In practice, give a 32-bit signal to tube driver
/// input: 
/// output 

module TEST_TubeDriver(
    input            raw_clk,                // clk signal; cpu clock
    input            reset_fpga,                 // reset signal, active high 
    input     [23:0] switch,                // 24 switches in total
    output    [23:0] led,                // for good effect, swithc on, led on as well
    output    [7:0]  oDigitalTubeNotEnable, // Choose tube enables, active low
    output    [7:0]  oDigitalTubeShape      // Choose which segments enabled, active low 
    );

//////////////////////////  LED  //////////////////////////
assign led = switch;

////////////////////////// Clock divisions //////////////////////////
wire clk;
CPU_Main_Clock_ip CPU_Main_Clock_Instance( 
    .clk_in1(raw_clk), 
    .clk_out1(clk) 
);

///////////////////////////// Tube Driver //////////////////////////
wire TubeCtrl;
wire [31:0] in_num_real;

assign TubeCtrl     = 1'b1;
assign in_num_real  = {{ 8{1'b0}} ,switch[23:0]};

TubeDriver tube_driver_instance(
    // input            clock,                 // clk signal; cpu clock
    // input            reset,                 // reset signal, active high 
    // input            TubeCtrl,              // control signal, 1->something new come in; 0-> still the old
    // input     [31:0] in_num,                // Input to be processed
    // output    [7:0]  oDigitalTubeNotEnable, // Choose tube enables, active low
    // output    [7:0]  oDigitalTubeShape      // Choose which segments enabled, active low 
    .clock(clk),
    .reset(reset_fpga),
    .TubeCtrl(TubeCtrl),
    .in_num(in_num_real),
    .oDigitalTubeNotEnable(oDigitalTubeNotEnable),
    .oDigitalTubeShape(oDigitalTubeShape)
);

endmodule

////////////////// Constraint file //////////////////
/// Same as main