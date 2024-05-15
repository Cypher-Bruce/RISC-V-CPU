// THE TESTBENCH IS AT THE END OF FILE

`timescale 1ns / 1ps

/// Module: TEST_UART_DM
/// DESCRIPTION:
///     This module is used to test the data memory uart functionality.
///     Test by convert data through uart and check whether the data is updated
///     This test is conducted on Minisys, and the constraint file is appeneded at the end

module TEST_UART_DM(
    input         raw_clk,
    input         rst_fpga,        // (See the note below) Effect of rst: clear all the registers, set PC to 0, active high;
    input         button_start_pg, // active high
    input         rx,              // receive data from UART
    output        tx,              // transmit data to UART
    output [23:0] led              // in this test only three leds are used
    );

////////////////////////// Clock divisions //////////////////////////
    wire clk;
    wire clk_fpga;
    CPU_Main_Clock_ip CPU_Main_Clock_Instance( 
        .clk_in1(raw_clk), 
        .clk_out1(clk),
        .clk_out2(clk_fpga)
    );


////////////////////////////// UART /////////////////////////////
/// #Description
///     UART is the interface between the CPU and the programmer, 
///     it detects whether the programmer wants to communiate, 
///     receives the inst and data bit-info from the programmer,
///     and tells both sides when the transition is ready. 
///     Received data are stored in the ports with suffix o,
///     which is used to write to data and inst memory.
/// #Signal
///    -upg_clk: SHOULD BE clk_fpga
///    -upg_clk_o: clock signal for UART programmer
///    -upg_wen_o: write enable signal for UART programmer
///    -upg_done_o: UART programmer done signal
///    -upg_adr_o: address signal for data memory
///    -upg_dat_o: data to write to data memory
///    -spg_bufg: buffer signal for UART programmer
/// #Note
///    - rst that connected to each module is redefined here
///    - !! rememver to reset the FPGA rst signal !!

// UART Programmer Pinouts
wire upg_clk_o;         //Uart clock output
wire upg_wen_o;         //Uart write out enable
wire upg_done_o;        //Uart rx data have done

wire [14:0] upg_adr_o;  //data to which memory unit of program_rom/dmemory32
wire [31:0] upg_dat_o;  //data to program_rom or dmemory32 

/// Detwitter
/// button_debounce module uses active low reset signal
wire spg_bufg;    
button_debounce U1(raw_clk, ~rst_fpga, button_start_pg, spg_bufg);  

/// Generate UART Programmer reset signal
/// communication mode on if uart button valid and not in reset
/// upg_rst: 1 -> not in communication mode, 0 -> in communication mode
reg upg_rst;
always @ (posedge clk_fpga) begin
    if (spg_bufg) upg_rst <= 0;
    if (rst_fpga) upg_rst <= 1;
end

/// Redefine rst for other modules
/// rst is valid if we are rst_fpga or we are doing uart(clear all the registers)
wire rst;
assign rst = rst_fpga | !upg_rst;

/// UART Programmer: communication interface
uart_bmpg_0 uart(
    .upg_clk_i(clk_fpga),
    .upg_rst_i(upg_rst),
    .upg_rx_i(rx),
    .upg_clk_o(upg_clk_o),
    .upg_wen_o(upg_wen_o),
    .upg_adr_o(upg_adr_o),
    .upg_dat_o(upg_dat_o),
    .upg_done_o(upg_done_o),
    .upg_tx_o(tx)
);


////////////////////////// Memory //////////////////////////
wire [31:0] data_memory_data;

wire [31:0] inst;
wire [31:0] address; // set to 0, first data
wire [31:0] reg_data_2;
wire [23:0] switch;
wire        mem_read_flag;  // set to 1, allow reading
wire        mem_write_flag;
wire [23:0] ledd;


assign address = 32'h00000000;
assign mem_read_flag = 1'b1;
assign inst = 32'h0001a083; // lw, so we can read data out

Data_Memory Data_Memory_Instance(
    .clk(clk),
    .inst(inst),
    .address(address),
    .write_data(reg_data_2),        
    .switch(switch),
    .mem_read_flag(mem_read_flag),
    .mem_write_flag(mem_write_flag),
    .read_data(data_memory_data),
    .led(ledd), 

    // UART Programmer Pinouts
    .upg_rst_i(upg_rst),
    .upg_clk_i(clk_fpga),
    .upg_wen_i(upg_wen_o),
    .upg_adr_i(upg_adr_o),
    .upg_dat_i(upg_dat_o),
    .upg_done_i(upg_done_o)
);

////////////////////////// TESTING //////////////////////////
// data_memory_data is the first data in the data memory
// two coe file should respectively contain 32'h000004d2 and 32'h000010e1

assign led[0] = data_memory_data == 32'h000004d2 ? 1'b1 : 1'b0; // Work
assign led[1] = data_memory_data == 32'h000010e1 ? 1'b1 : 1'b0; // Work
assign led[2] = !upg_rst;                                       // Work, need to reset


endmodule

////////////////////////// Constraint file //////////////////////////
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y19} [get_ports rx]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V18} [get_ports tx]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P2} [get_ports {button_start_pg}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN P20} [get_ports rst_fpga]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y18} [get_ports raw_clk]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K17} [get_ports {led[23]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L13} [get_ports {led[22]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M13} [get_ports {led[21]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K14} [get_ports {led[20]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K13} [get_ports {led[19]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M20} [get_ports {led[18]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN N20} [get_ports {led[17]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN N19} [get_ports {led[16]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M17} [get_ports {led[15]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M16} [get_ports {led[14]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN M15} [get_ports {led[13]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K16} [get_ports {led[12]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L16} [get_ports {led[11]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L15} [get_ports {led[10]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L14} [get_ports {led[9]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J17} [get_ports {led[8]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F21} [get_ports {led[7]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G22} [get_ports {led[6]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN G21} [get_ports {led[5]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN D21} [get_ports {led[4]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN E21} [get_ports {led[3]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN D22} [get_ports {led[2]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN E22} [get_ports {led[1]}]
// set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN A21} [get_ports {led[0]}]



////////////////////////// Testbench File //////////////////////////
// `timescale 1ns / 1ps

// module TEST_dm_uart_tb;

//     // Parameters
//     parameter CLK_PERIOD = 10; // Clock period in ns

//     // Signals
//     reg raw_clk = 0;
//     reg rst_fpga = 0;
//     reg button_start_pg = 0;
//     reg rx = 0;
//     wire tx;
//     wire [23:0] led;

//     // Instantiate the module under test
//     TEST_UART_DM dut (
//         .raw_clk(raw_clk),
//         .rst_fpga(rst_fpga),
//         .button_start_pg(button_start_pg),
//         .rx(rx),
//         .tx(tx),
//         .led(led)
//     );

//     // Clock generation
//     always #5 raw_clk = ~raw_clk;

//     // Reset generation
//     initial begin
//         #20 rst_fpga = 1; // Assert FPGA reset
//         #100 rst_fpga = 0; // Deassert FPGA reset

//         #300 button_start_pg = 1; // Assert start button
//         // #100 rst_fpga = 1; // Deassert FPGA reset
//         // #200 button_start_pg = 1; // Assert start button
//         // #500 button_start_pg = 0; // Deassert start button
//         // Add any additional stimulus here
//         // Add delays as needed
//         // Monitor and check LED outputs for expected behavior
//         // Monitor and check UART transmissions for expected behavior
//         // Monitor and check any other relevant signals for expected behavior
//         // Repeat for desired number of clock cycles
//         // End simulation when testing is complete
//         // $finish; 
//     end

// endmodule
