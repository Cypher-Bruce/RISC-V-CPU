// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Tue May 21 14:42:33 2024
// Host        : Cypher_Bruce running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {C:/Users/Cyphe/Documents/SUSTech Assignment/Term 4/Computer
//               Organization/Project/Pipeline/Pipeline_CPU.srcs/sources_1/ip/CPU_Main_Clock_ip/CPU_Main_Clock_ip_stub.v}
// Design      : CPU_Main_Clock_ip
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module CPU_Main_Clock_ip(clk_out1, clk_out2, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_out2,clk_in1" */;
  output clk_out1;
  output clk_out2;
  input clk_in1;
endmodule
