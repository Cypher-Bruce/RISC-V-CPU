`timescale 1ns / 1ps

/// Module: TEST_UART_IM
/// DESCRIPTION:
///     This module is used to test the instruction memory uart functionality.
///     Test by transmit data through uart and check whether the data is updated
///     This test is conducted on Minisys, and the constraint file is appeneded at the end

module TEST_UART_IM(
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
///    - !!! Remember to reset before testing !!!

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

////////////////////////// Instrustion Fetch //////////////////////////
wire [31:0] program_counter;
wire        branch_flag;
wire        jal_flag;
wire        jalr_flag;
wire        zero_flag;
wire [31:0] imme;
wire [31:0] reg_data_1;
wire [31:0] inst;


TEST_Instruction_Fetch Instruction_Fetch_Instance(
    .clk(clk),
    .rst(rst),
    .branch_flag(branch_flag),
    .jal_flag(jal_flag),
    .jalr_flag(jalr_flag),
    .zero_flag(zero_flag),
    .imme(imme),
    .read_data_1(reg_data_1),
    .inst(inst),
    .program_counter(program_counter),

    // UART Programmer Pinouts
    .upg_rst_i(upg_rst),
    .upg_clk_i(clk_fpga),
    .upg_wen_i(upg_wen_o),
    .upg_adr_i(upg_adr_o),
    .upg_dat_i(upg_dat_o),
    .upg_done_i(upg_done_o)
);

////////////////////////// TESTING //////////////////////////
// inst is the first instruction in the inst. memory
// two coe file should respectively contain 32'hf9c00093(first inst) and 32'h00000033(second inst)

assign led[0] = inst == 32'hf9c00093 ? 1'b1 : 1'b0; // Work
assign led[1] = inst == 32'h00000033 ? 1'b1 : 1'b0; // Work
assign led[2] = !upg_rst;                                      


endmodule


////////////////////////// Testbench //////////////////////////
// `timescale 1ns / 1ps

// /// Module: TEST_UART_IM_tb
// /// DESCRIPTION: Simulate the content of TEST_UART_IM.v
// /// Note: !!! Since the clock signal is devided, need to wait for the actual clk after 600ns


// module TEST_UART_IM_tb;

//     // ćśéĺĺ¤ä˝äżĄĺ?
//     reg raw_clk;
//     reg rst_fpga;
    
//     // ćéŽäżĄĺˇ
//     reg button_start_pg;
    
//     // UART ćĽćśĺĺéć°ćŽäżĄĺ?
//     reg rx;
//     wire tx;
    
//     // LED čžĺş
//     wire [23:0] led;

//     // ĺŽäžĺč˘ŤćľčŻć¨Ąĺ
//     TEST_UART_IM dut (
//         .raw_clk(raw_clk),
//         .rst_fpga(rst_fpga),
//         .button_start_pg(button_start_pg),
//         .rx(rx),
//         .tx(tx),
//         .led(led)
//     );

//     // ćśéçć
//     always #1 raw_clk = ~raw_clk;

//     // ĺĺ§ĺ?
//     initial begin
//         raw_clk = 0;
//         rst_fpga = 0;
//         button_start_pg = 0;
//         rx = 0;
        
//         // ç­ĺžä¸?ćŽľćśé´ĺéćžĺ¤ä˝
//         #10;
//         rst_fpga = 1;

//         #200;
//         rst_fpga = 0;

//         // ćä¸ćéŽ
//         #50;
//         button_start_pg = 0;
        
//         // // ć¨Ąć UART ćĽćść°ćŽ
//         // #10;
//         // rx = 1;
//         // #10;
//         // rx = 0;
        
//         // ç­ĺžä¸?ćŽľćśé´č§ĺŻçťć?
// //        #1000;
//         $finish;
//     end

// endmodule

//////////////// Constraint File is Same as data memory //////////////////////////


//////////////// TEST INSTRCUTION FETCH //////////////////////////
// `timescale 1ns / 1ps
// `include "Parameters.v"

/// Module: TEST_Instruction_Fetch
/// #Description 
///                To avoid changing the original Instruction_Fetch module, I 
///              duplicate this module, and always set the PC to a certain value,
///              to observe the instruction signal fetched from the instruction memory
/// #Input       clk, rst, branch_flag, jal_flag, jalr_flag, zero_flag, imme
/// #Outputs     inst, program_counter
/// #Signals     
///         - address: 14-bit address for instruction memory
///         - branch_taken_flag: 1 if branch is taken
///         - funct3: 3-bit funct3 field from instruction
/// #Note
///         - PC is updated at the FALLING edge of the clock signal
///         - To implement uart, instruction memory should be changed to RAM ip core

// module TEST_Instruction_Fetch(
//     input         clk,           /// adjusted clk, from cpu
//     input         rst,           /// reset signal, from cpu
//     input         branch_flag,   /// branch flag, from controller
//     input         jal_flag,      /// jump and link flag, from controller
//     input         jalr_flag,     /// jump and link register flag, from controller
//     input         zero_flag,     /// 1 if sub result is 0, from ALU, 
//     input  [31:0] imme,          /// imm in branch inst, from inst memory
//     input  [31:0] read_data_1,   /// data from register

//     output [31:0] inst,
//     output reg [31:0] program_counter,

//     // UART Programmer Pinouts
//     input         upg_rst_i,           // UPG reset
//     input         upg_clk_i,           // UPG clk(10MHz)
//     input         upg_wen_i,           // UPG write enable
//     input  [13:0] upg_adr_i,           // UPG write address
//     input  [31:0] upg_dat_i,           // UPG write data
//     input         upg_done_i           // 1 if UPG is done
// );

// reg         branch_taken_flag;
// wire [2:0]  funct3;  

// ////////////////////////// BRANCH CONTROL //////////////////////////
// /// According to the result and the branch instruction,
// /// PC is determined to go to goal address or not
// /// It corresponds to the MUX in the CPU blueprint, but with some modifications added
  
// assign funct3 = inst[14:12];

// always @*
// begin
//     if (jal_flag || jalr_flag) // J-type
//     begin
//         branch_taken_flag = 1;
//     end
//     else // B-type
//     begin
//         case(funct3)
//             3'b000: // beq (ALU do sub)
//             begin
//                 branch_taken_flag = zero_flag;
//             end
//             3'b001: // bne
//             begin
//                 branch_taken_flag = !zero_flag;
//             end
//             3'b100: // blt (ALU do slt instead of sub)
//             begin
//                 branch_taken_flag = !zero_flag;
//             end
//             3'b101: // bge
//             begin
//                 branch_taken_flag = zero_flag;
//             end
//             3'b110: // bltu (ALU do sltu instead of sub)
//             begin
//                 branch_taken_flag = !zero_flag;
//             end
//             3'b111: // bgeu
//             begin
//                 branch_taken_flag = zero_flag;
//             end
//             default: // no branch
//             begin
//                 branch_taken_flag = 0;
//             end
//         endcase
//     end
// end

// /// PC is set as constant value for testing
// ////////////////////////// PC //////////////////////////
// /// Three cases for PC
// /// Case1. rst: set PC to initial address
// /// Case2. branch_flag && branch_taken_flag: increment PC with imme
// /// Case3. default: increment PC by 4
// /// Note that actual address sent to memory ip core is address >> 2
// /// !!! PC is updated at the FALLING edge of the clock signal, for more details, refer to https://imgur.com/a/zZdYXqu

// always @(negedge clk)
// begin
//     // if (rst)
//     // begin
//     //     // can changed this value to test different instructions
//     //     program_counter <= `instruction_initial_address;  
//     // end

//     program_counter <= `instruction_initial_address;
    
//     // else if (jalr_flag)
//     // begin
//     //     program_counter <= read_data_1 + imme;
//     // end
//     // else if (branch_flag && branch_taken_flag)
//     // begin
//     //     program_counter <= program_counter + imme;
//     // end
//     // else
//     // begin
//     //     program_counter <= program_counter + 4;
//     // end
// end

// /////////////////////////////// Uart ///////////////////////////////
// /// kickOff: mode flag, 1: normal working mode, 0: communication mode
// wire kickOff;
// assign kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);


// ////////////////////////// Instruction Memory //////////////////////////
// /// The inst memory is so far a ROM ip core
// /// Config: width=32bits, depth=16384(2^14), capacity=64KB
// /// Paramter: 
// ///         - clka: cpu clock signal, 23MHz
// ///         - addra: Word addressable. 14-bit from PC, = PC >> 2
// ///         - douta: 32-bit instruction
// /// TODO: update inst memory to RAM for UART
// /// Note: 
// ///         - Data is read at the FALLING edge of the clock signal
// ///         - To implement UART, instruction memory is changed to RAM ip core

// /// temp wire for readability
// wire addra_ram; 
// assign addra_ram = program_counter[15:2];

// Instruction_Memory_ip Instruction_Memory_Instance(
//     .clka  (kickOff ? clk             : upg_clk_i),
//     .wea   (kickOff ? 1'b0            : upg_wen_i),
//     .addra (kickOff ? addra_ram       : upg_adr_i),
//     .dina  (kickOff ? 32'h00000000    : upg_dat_i),
//     .douta (inst)
// );


// endmodule
