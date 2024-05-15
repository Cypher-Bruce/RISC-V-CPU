`timescale 1ns / 1ps

/// Module: CPU_Top
/// #Description: This module is the top module of the CPU. 
///              It connects all the other modules together.
/// #Inputs: raw_clk, fpga_rst, switch, button, start_pg, rx
/// #Outputs: led, tx
/// #Signals
///             clk: adjusted clock signal, 
///             inst: 32-bit instruction from inst. memory

///             branch_flag: flag indicates branch inst
///             ALU_Operation: 2-bit ALU operation code
///             ALU_src_flag: 0: read data from register, 1: read data from immediate
///             mem_read_flag: flag indicates memory read
///             mem_write_flag: flag indicates memory write
///             mem_to_reg_flag: flag indicates memory to register
///             reg_write_flag: flag indicates register write
///             zero_flag: flag indicates zero result

///             imme: 32-bit immediate value extracted from instruction
///             reg_data_1: 32-bit data from register file
///             reg_data_2: 32-bit data from register file
///             write_data: 32-bit data to be written to register file

///             ALU_result: 32-bit result from ALU
///             data_memory_data: 32-bit data from data memory

module CPU_Top(
    input         raw_clk,
    input         rst_fpga,        // (See the note below) Effect of rst: clear all the registers, set PC to 0, active high;
    input  [23:0] switch,
    input  [4:0 ] button,

    /*!!!Note-change since UART: the global input set is chaged from rst to rst_fpga, 
                                the rst connected to each port is redefined in UART part, 
                                see UART part down below at around LINE 180 for more details*/

    /* UART Programmer Pinouts
    /  start Uart communicate at high level */
    input         button_start_pg, // active high
    input         rx,              // receive data from UART
    output        tx,              // transmit data to UART

    output [23:0] led
);

////////////////////////// Clock divisions //////////////////////////
wire clk;
wire clk_fpga;
CPU_Main_Clock_ip CPU_Main_Clock_Instance( 
    .clk_in1(raw_clk), 
    .clk_out1(clk) ,
    .clk_out2(clk_fpga)
);

////////////////////////////// UART /////////////////////////////
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

// UART Programmer Pinouts
wire upg_clk_o;         //Uart clock output
wire upg_wen_o;         //Uart write out enable
wire upg_done_o;        //Uart rx data have done

wire [14:0] upg_adr_o;  //data to which memory unit of program_rom/dmemory32
wire [31:0] upg_dat_o;  //data to program_rom or dmemory32 

/// Detwitter
wire spg_bufg;    
button_debounce U1(clk, ~rst_fpga, button_start_pg, spg_bufg);  

/// Generate UART Programmer reset signal
reg upg_rst;
always @ (posedge clk_fpga) begin
    if (spg_bufg) upg_rst <= 0;
    if (rst_fpga) upg_rst <= 1;
end

/// Redefine rst for other modules
wire rst;
assign rst = rst_fpga | !upg_rst;

/// UART Programmer
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


////////////////////////// Controller //////////////////////////
wire [31:0]     inst;
wire            branch_flag;
wire [1:0]      ALU_Operation;
wire            ALU_src_flag;
wire            mem_read_flag;
wire            mem_write_flag;
wire            mem_to_reg_flag;
wire            reg_write_flag;
wire            jal_flag;
wire            jalr_flag;
wire            lui_flag;
wire            auipc_flag;

Controller Controller_Instance(
    .inst(inst),
    .branch_flag(branch_flag),
    .ALU_Operation(ALU_Operation),
    .ALU_src_flag(ALU_src_flag),
    .mem_read_flag(mem_read_flag),
    .mem_write_flag(mem_write_flag),
    .mem_to_reg_flag(mem_to_reg_flag),
    .reg_write_flag(reg_write_flag),
    .jal_flag(jal_flag),
    .jalr_flag(jalr_flag),
    .lui_flag(lui_flag),
    .auipc_flag(auipc_flag)
);

////////////////////////// Instruction Decode & WB //////////////////////////
wire [31:0] reg_data_1;
wire [31:0] reg_data_2;
reg  [31:0] write_data;
wire [31:0] imme;
Decoder Decoder_Instance(
    .write_data(write_data),            // WB
    .reg_write_flag(reg_write_flag),
    .inst(inst),
    .clk(clk),
    .rst(rst),
    .read_data_1(reg_data_1),
    .read_data_2(reg_data_2),
    .imme(imme)
);

////////////////////////// Instrustion Fetch //////////////////////////
wire        zero_flag;
wire [31:0] program_counter;
Instruction_Fetch Instruction_Fetch_Instance(
    .clk(clk),
    .rst(rst),
    .branch_flag(branch_flag),
    .jal_flag(jal_flag),
    .jalr_flag(jalr_flag),
    .zero_flag(zero_flag),
    .imme(imme),
    .read_data_1(reg_data_1),
    .inst(inst),
    .program_counter(program_counter)
);

////////////////////////// Execution //////////////////////////
wire [31:0] ALU_result;
ALU ALU_Instance(
    .read_data_1(reg_data_1),
    .read_data_2(reg_data_2),
    .imme(imme),
    .ALU_Operation(ALU_Operation),
    .ALU_src_flag(ALU_src_flag),
    .inst(inst),
    .ALU_result(ALU_result),
    .zero_flag(zero_flag)
);

////////////////////////// Memory //////////////////////////
wire [31:0] data_memory_data;
Data_Memory Data_Memory_Instance(
    .clk(clk),
    .inst(inst),
    .address(ALU_result),
    .write_data(reg_data_2),        
    .switch(switch),
    .mem_read_flag(mem_read_flag),
    .mem_write_flag(mem_write_flag),
    .read_data(data_memory_data),
    .led(led), 

    // UART Programmer Pinouts
    .upg_rst_i(upg_rst),
    .upg_clk_i(clk_fpga),
    .upg_wen_i(upg_wen_o),
    .upg_adr_i(upg_adr_o),
    .upg_dat_i(upg_dat_o),
    .upg_done_i(upg_done_o)
);

////////////////////////// WB //////////////////////////
always @*
begin
    if (jal_flag || jalr_flag)
    begin
        write_data = program_counter + 4;
    end 
    else if (lui_flag)
    begin
        write_data = imme;
    end
    else if (auipc_flag)
    begin
        write_data = program_counter + imme;
    end
    else if (mem_to_reg_flag)
    begin
        write_data = data_memory_data;
    end
    else
    begin
        write_data = ALU_result;
    end
end

endmodule
