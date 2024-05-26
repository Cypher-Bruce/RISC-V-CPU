`timescale 1ns / 1ps

/// Module: CPU_Top
/// #Description: This module is the top module of the CPU. 
///              It connects all the other modules together.
/// #Inputs: raw_clk, rst, switch
/// #Outputs: led
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


/// TODO: add uart to pipeline CPU

module CPU_Top(
    input         clk,
    input         rst,        // effect of rst: clear all the registers, set PC to 0, active high
    input  [23:0] switch,
    input  [4:0]  debounced_button,
    input  [4:0]  push_button_flag,
    input  [4:0]  release_button_flag,
    output [23:0] led,
    output [31:0] seven_seg_tube,   // segment
    output [7:0]  minus_sign_flag,  // segment 
    output [7:0]  dot_flag,         // segment
    output [7:0]  show_none_flag,   // segment
    output        advanced_mode_flag, // segment
    output [31:0] adv_seven_seg_tube_left,  // segment
    output [31:0] adv_seven_seg_tube_right, // segment

    input kick_off_flag,
    input uart_clk,           // UPG ram_clk_i(10MHz)
    input upg_wen,           // UPG write enable
    input [14:0] upg_adr,    // UPG write address
    input [31:0] upg_dat     // UPG write data
);

////////// Instruction Fetch //////////

///// Instruction Fetch Module /////
/// Program counter and its logic

wire               wrong_prediction_flag;           // if branch wrong, then
wire  [31:0]       branch_pc;                       // for branch inst, if condition correct, the pc supposed to be
wire               stall_flag;                      // indicate a stall is needed: load-use, dependency
wire  [31:0]       program_counter_prediction_IF;   // the predicted program counter, special if there is a branch
wire  [31:0]       program_counter_raw;             // instruction address of the current cycle
wire  [31:0]       prev_pc;                         // keep record of the inst address of this cycle

Instruction_Fetch Instruction_Fetch_Instance(
    .clk(clk),
    .rst(rst),
    .wrong_prediction_flag(wrong_prediction_flag),
    .branch_pc(branch_pc),
    .stall_flag(stall_flag),
    .program_counter_prediction(program_counter_prediction_IF),
    .program_counter(program_counter_raw),
    .prev_pc(prev_pc)
);

// The reason why we send prev_pc to the next stage (instead of program_counter_raw) is that: 
// only in the first half of the clock cycle,
// the program_counter_raw does correspond to the instruction fetched in the same cycle.
// In the second half of the clock cycle, the program_counter_raw is updated to determine
// the address of the next instruction to be fetched.
// You can see this design in the IF/ID pipeline register declaration right below.

///// Instruction Memory /////

wire [31:0] inst_IF;

Instruction_Memory Instruction_Memory_Instance(
    .clk(clk),
    .program_counter(program_counter_raw),
    .inst(inst_IF),
    .kick_off_flag(kick_off_flag),
    .uart_clk(uart_clk),
    .upg_wen(upg_wen & (!upg_adr[14])),
    .upg_adr(upg_adr[13:0]),
    .upg_dat(upg_dat)
);

///// Program Counter Prediction /////

wire              branch_flag_MEM;   
wire  [31:0]      program_counter_MEM;
wire  [31:0]      prev_pcp;

Program_Counter_Prediction Program_Counter_Prediction_Instance(
    .clk(clk),
    .rst(rst),
    .branch_from_pc(program_counter_MEM),
    .branch_to_pc(branch_pc),
    .program_counter(program_counter_raw),
    .branch_flag(branch_flag_MEM),
    .program_counter_prediction(program_counter_prediction_IF),
    .prev_pcp(prev_pcp)
);

////////// IF/ID //////////
/// pipline register
/// For pipeline reg, the suffix(eg: _IF) means the stage of the data it belongs to.

wire [31:0] inst_ID;
wire [31:0] program_counter_ID;
wire [31:0] program_counter_prediction_ID;

IF_ID IF_ID_Instance(
    .clk(clk),
    .rst(rst),
    .stall_flag(stall_flag),
    .wrong_prediction_flag(wrong_prediction_flag),
    .inst_IF(inst_IF),
    .program_counter_IF(prev_pc),
    .program_counter_prediction_IF(prev_pcp),
    .inst_ID(inst_ID),
    .program_counter_ID(program_counter_ID),
    .program_counter_prediction_ID(program_counter_prediction_ID)
);

////////// Instruction Decode //////////

///// Controller /////

wire               branch_flag_ID;
wire  [1:0]        ALU_operation_ID;
wire               ALU_src_flag_ID;
wire               mem_read_flag_ID;
wire               mem_write_flag_ID;
wire               mem_to_reg_flag_ID;
wire               reg_write_flag_ID;
wire               jal_flag_ID;
wire               jalr_flag_ID;
wire               lui_flag_ID;
wire               auipc_flag_ID;

Controller Controller_Instance(
    .inst(inst_ID),
    .branch_flag(branch_flag_ID),
    .ALU_operation(ALU_operation_ID),
    .ALU_src_flag(ALU_src_flag_ID),
    .mem_read_flag(mem_read_flag_ID),
    .mem_write_flag(mem_write_flag_ID),
    .mem_to_reg_flag(mem_to_reg_flag_ID),
    .reg_write_flag(reg_write_flag_ID),
    .jal_flag(jal_flag_ID),
    .jalr_flag(jalr_flag_ID),
    .lui_flag(lui_flag_ID),
    .auipc_flag(auipc_flag_ID)
);

///// Immediate Generator /////

wire [31:0] imme_ID;

Immediate_Generator Immediate_Generator_Instance(
    .inst(inst_ID),
    .imme(imme_ID)
);

///// Decoder /////

wire [4:0] read_reg_idx_1_ID;
wire [4:0] read_reg_idx_2_ID;
wire [4:0] write_reg_idx_ID;

Decoder Decoder_Instance(
    .inst(inst_ID),
    .read_reg_idx_1(read_reg_idx_1_ID),
    .read_reg_idx_2(read_reg_idx_2_ID),
    .write_reg_idx(write_reg_idx_ID)
);

///// Register /////

wire        reg_write_flag_WB;
wire [4:0]  write_reg_idx_WB;
wire [31:0] write_back_data;
wire [31:0] read_data_1_ID;
wire [31:0] read_data_2_ID;

Register Register_Instance(
    .clk(clk),
    .rst(rst),
    .reg_write_flag(reg_write_flag_WB),
    .read_reg_idx_1(read_reg_idx_1_ID),
    .read_reg_idx_2(read_reg_idx_2_ID),
    .write_reg_idx(write_reg_idx_WB),
    .write_data(write_back_data),
    .read_data_1(read_data_1_ID),
    .read_data_2(read_data_2_ID)
);

////////// ID/EX //////////

wire                  branch_flag_EX;
wire  [1:0]           ALU_operation_EX;
wire                  ALU_src_flag_EX;
wire                  mem_read_flag_EX;
wire                  mem_write_flag_EX;
wire                  mem_to_reg_flag_EX;
wire                  reg_write_flag_EX;
wire                  jal_flag_EX;
wire                  jalr_flag_EX;
wire                  lui_flag_EX;
wire                  auipc_flag_EX;
wire  [31:0]          imme_EX;
wire  [31:0]          read_data_1_before_forward_EX;
wire  [31:0]          read_data_2_before_forward_EX;
wire  [4:0]           read_reg_idx_1_EX;
wire  [4:0]           read_reg_idx_2_EX;
wire  [4:0]           write_reg_idx_EX;
wire  [31:0]          inst_EX;
wire  [31:0]          program_counter_EX;
wire  [31:0]          program_counter_prediction_EX;

ID_EX ID_EX_Instance(
    .clk(clk),
    .rst(rst),
    .stall_flag(stall_flag),
    .wrong_prediction_flag(wrong_prediction_flag),
    .branch_flag_ID(branch_flag_ID),
    .ALU_operation_ID(ALU_operation_ID),
    .ALU_src_flag_ID(ALU_src_flag_ID),
    .mem_read_flag_ID(mem_read_flag_ID),
    .mem_write_flag_ID(mem_write_flag_ID),
    .mem_to_reg_flag_ID(mem_to_reg_flag_ID),
    .reg_write_flag_ID(reg_write_flag_ID),
    .jal_flag_ID(jal_flag_ID),
    .jalr_flag_ID(jalr_flag_ID),
    .lui_flag_ID(lui_flag_ID),
    .auipc_flag_ID(auipc_flag_ID),
    .imme_ID(imme_ID),
    .read_data_1_ID(read_data_1_ID),
    .read_data_2_ID(read_data_2_ID),
    .read_reg_idx_1_ID(read_reg_idx_1_ID),
    .read_reg_idx_2_ID(read_reg_idx_2_ID),
    .write_reg_idx_ID(write_reg_idx_ID),
    .inst_ID(inst_ID),
    .program_counter_ID(program_counter_ID),
    .program_counter_prediction_ID(program_counter_prediction_ID),

    .branch_flag_EX(branch_flag_EX),
    .ALU_operation_EX(ALU_operation_EX),
    .ALU_src_flag_EX(ALU_src_flag_EX),
    .mem_read_flag_EX(mem_read_flag_EX),
    .mem_write_flag_EX(mem_write_flag_EX),
    .mem_to_reg_flag_EX(mem_to_reg_flag_EX),
    .reg_write_flag_EX(reg_write_flag_EX),
    .jal_flag_EX(jal_flag_EX),
    .jalr_flag_EX(jalr_flag_EX),
    .lui_flag_EX(lui_flag_EX),
    .auipc_flag_EX(auipc_flag_EX),
    .imme_EX(imme_EX),
    .read_data_1_EX(read_data_1_before_forward_EX),
    .read_data_2_EX(read_data_2_before_forward_EX),
    .read_reg_idx_1_EX(read_reg_idx_1_EX),
    .read_reg_idx_2_EX(read_reg_idx_2_EX),
    .write_reg_idx_EX(write_reg_idx_EX),
    .inst_EX(inst_EX),
    .program_counter_EX(program_counter_EX),
    .program_counter_prediction_EX(program_counter_prediction_EX)
);

////////// Execute //////////

///// Forwarding Mux /////

wire  [31:0]          read_data_1_forwarding;
wire  [31:0]          read_data_2_forwarding;
wire                  read_data_1_forwarding_flag;
wire                  read_data_2_forwarding_flag;
wire  [31:0]          read_data_1_after_forward_EX;
wire  [31:0]          read_data_2_after_forward_EX;

Forwarding_Mux Forwarding_Mux_Instance(
    .read_data_1_raw(read_data_1_before_forward_EX),
    .read_data_2_raw(read_data_2_before_forward_EX),
    .read_data_1_forwarding(read_data_1_forwarding),
    .read_data_2_forwarding(read_data_2_forwarding),
    .read_data_1_forwarding_flag(read_data_1_forwarding_flag),
    .read_data_2_forwarding_flag(read_data_2_forwarding_flag),

    .read_data_1(read_data_1_after_forward_EX),
    .read_data_2(read_data_2_after_forward_EX)
);

///// ALU /////

wire [31:0] ALU_result_EX;
wire        zero_flag_EX;

ALU ALU_Instance(
    .read_data_1(read_data_1_after_forward_EX),
    .read_data_2(read_data_2_after_forward_EX),
    .imme(imme_EX),
    .ALU_operation(ALU_operation_EX),
    .ALU_src_flag(ALU_src_flag_EX),
    .inst(inst_EX),
    .program_counter(program_counter_EX),
    .jal_flag(jal_flag_EX),
    .jalr_flag(jalr_flag_EX),
    .lui_flag(lui_flag_EX),
    .auipc_flag(auipc_flag_EX),

    .ALU_result(ALU_result_EX),
    .zero_flag(zero_flag_EX)
);

////////// EX/MEM //////////

wire  [31:0]          ALU_result_MEM;
wire                  zero_flag_MEM;
// wire                  branch_flag_MEM;
wire                  mem_read_flag_MEM;
wire                  mem_write_flag_MEM;
wire                  mem_to_reg_flag_MEM;
wire                  reg_write_flag_MEM;
wire                  jal_flag_MEM;
wire                  jalr_flag_MEM;
wire  [31:0]          imme_MEM;
wire  [31:0]          read_data_1_MEM;
wire  [31:0]          read_data_2_MEM;
wire  [4:0]           write_reg_idx_MEM;
wire  [31:0]          inst_MEM;
// wire  [31:0]         program_counter_MEM;
wire  [31:0]          program_counter_prediction_MEM;   

EX_MEM EX_MEM_Instance(
    .clk(clk),
    .rst(rst),
    .wrong_prediction_flag(wrong_prediction_flag),
    .ALU_result_EX(ALU_result_EX),
    .zero_flag_EX(zero_flag_EX),
    .branch_flag_EX(branch_flag_EX),
    .mem_read_flag_EX(mem_read_flag_EX),
    .mem_write_flag_EX(mem_write_flag_EX),
    .mem_to_reg_flag_EX(mem_to_reg_flag_EX),
    .reg_write_flag_EX(reg_write_flag_EX),
    .jal_flag_EX(jal_flag_EX),
    .jalr_flag_EX(jalr_flag_EX),
    .imme_EX(imme_EX),
    .read_data_1_EX(read_data_1_after_forward_EX),
    .read_data_2_EX(read_data_2_after_forward_EX),
    .write_reg_idx_EX(write_reg_idx_EX),
    .inst_EX(inst_EX),
    .program_counter_EX(program_counter_EX),
    .program_counter_prediction_EX(program_counter_prediction_EX),
    
    .ALU_result_MEM(ALU_result_MEM),
    .zero_flag_MEM(zero_flag_MEM),
    .branch_flag_MEM(branch_flag_MEM),
    .mem_read_flag_MEM(mem_read_flag_MEM),
    .mem_write_flag_MEM(mem_write_flag_MEM),
    .mem_to_reg_flag_MEM(mem_to_reg_flag_MEM),
    .reg_write_flag_MEM(reg_write_flag_MEM),
    .jal_flag_MEM(jal_flag_MEM),
    .jalr_flag_MEM(jalr_flag_MEM),
    .imme_MEM(imme_MEM),
    .read_data_1_MEM(read_data_1_MEM),
    .read_data_2_MEM(read_data_2_MEM),
    .write_reg_idx_MEM(write_reg_idx_MEM),
    .inst_MEM(inst_MEM),
    .program_counter_MEM(program_counter_MEM),
    .program_counter_prediction_MEM(program_counter_prediction_MEM)
);

////////// Memory //////////

///// Branch Target /////

Branch_Target Branch_Target_Instance(
    .jal_flag(jal_flag_MEM),
    .jalr_flag(jalr_flag_MEM),
    .branch_flag(branch_flag_MEM),
    .zero_flag(zero_flag_MEM),
    .read_data_1(read_data_1_MEM),
    .imme(imme_MEM),
    .program_counter(program_counter_MEM),
    .inst(inst_MEM),
    .program_counter_prediction(program_counter_prediction_MEM),
    .wrong_prediction_flag(wrong_prediction_flag),
    .branch_pc(branch_pc)
);

///// Memory Or IO /////

wire [31:0] data_memory_read_data;
wire [31:0] io_device_read_data;
wire [31:0] read_data_MEM;
wire        data_memory_read_flag;
wire        data_memory_write_flag;
wire        io_device_read_flag;
wire        io_device_write_flag;

Memory_Or_IO Memory_Or_IO_Instance(
    .address_absolute(ALU_result_MEM),
    .inst(inst_MEM),
    .mem_read_flag(mem_read_flag_MEM),
    .mem_write_flag(mem_write_flag_MEM),
    .data_memory_read_data(data_memory_read_data),
    .io_device_read_data(io_device_read_data),
    .read_data(read_data_MEM),
    .data_memory_read_flag(data_memory_read_flag),
    .data_memory_write_flag(data_memory_write_flag),
    .io_device_read_flag(io_device_read_flag),
    .io_device_write_flag(io_device_write_flag)
);

///// Data Memory /////

Data_Memory Data_Memory_Instance(
    .clk(clk),
    .address_absolute(ALU_result_MEM),
    .write_data(read_data_2_MEM),
    .read_flag(data_memory_read_flag),
    .write_flag(data_memory_write_flag),
    .read_data(data_memory_read_data),
    .kick_off_flag(kick_off_flag),
    .uart_clk(uart_clk),
    .upg_wen(upg_wen & upg_adr[14]),    
    .upg_adr(upg_adr[13:0]),
    .upg_dat(upg_dat)
);

///// IO Device Memory /////

IO_Device_Memory IO_Device_Memory_Instance(
    .clk(clk),
    .rst(rst),
    .address_absolute(ALU_result_MEM),
    .write_data(read_data_2_MEM),
    .read_flag(io_device_read_flag),
    .write_flag(io_device_write_flag),
    .switch(switch),
    .debounced_button(debounced_button),
    .push_button_flag(push_button_flag),
    .release_button_flag(release_button_flag),
    .read_data(io_device_read_data),
    .led(led),
    .seven_seg_tube(seven_seg_tube),
    .minus_sign_flag(minus_sign_flag),
    .dot_flag(dot_flag),
    .show_none_flag(show_none_flag),
    .advanced_mode_flag(advanced_mode_flag),
    .adv_seven_seg_tube_left(adv_seven_seg_tube_left),
    .adv_seven_seg_tube_right(adv_seven_seg_tube_right)
);

////////// MEM/WB //////////

wire [31:0] read_data_WB;
wire [31:0] ALU_result_WB;
wire        mem_to_reg_flag_WB;
// wire   reg_write_flag_WB;   // defined at register stage
wire        jal_flag_WB;
wire        jalr_flag_WB;
wire        lui_flag_WB;
wire        auipc_flag_WB;
wire [31:0] imme_WB;
// wire   [4:0] write_reg_idx_WB;   // defined at register stage
wire [31:0] program_counter_WB;

MEM_WB MEM_WB_Instance(
    .clk(clk),
    .rst(rst),
    .read_data_MEM(read_data_MEM),
    .ALU_result_MEM(ALU_result_MEM),
    .mem_to_reg_flag_MEM(mem_to_reg_flag_MEM),
    .reg_write_flag_MEM(reg_write_flag_MEM),
    .write_reg_idx_MEM(write_reg_idx_MEM),
    .read_data_WB(read_data_WB),
    .ALU_result_WB(ALU_result_WB),
    .mem_to_reg_flag_WB(mem_to_reg_flag_WB),
    .reg_write_flag_WB(reg_write_flag_WB),
    .write_reg_idx_WB(write_reg_idx_WB)
);

////////// Write Back //////////

assign write_back_data = mem_to_reg_flag_WB ? read_data_WB : ALU_result_WB;

////////// Forwarding Unit //////////

Forwarding_Unit Forwarding_Unit_Instance(
    .ALU_result_MEM(ALU_result_MEM),
    .write_reg_idx_MEM(write_reg_idx_MEM),
    .write_reg_flag_MEM(reg_write_flag_MEM),
    .mem_to_reg_flag_MEM(mem_to_reg_flag_MEM),
    .ALU_result_WB(ALU_result_WB),
    .read_data_WB(read_data_WB),
    .write_reg_idx_WB(write_reg_idx_WB),
    .write_reg_flag_WB(reg_write_flag_WB),
    .mem_to_reg_flag_WB(mem_to_reg_flag_WB),
    .read_reg_idx_1_EX(read_reg_idx_1_EX),
    .read_reg_idx_2_EX(read_reg_idx_2_EX),
    .read_data_1_forwarding(read_data_1_forwarding),
    .read_data_2_forwarding(read_data_2_forwarding),
    .read_data_1_forwarding_flag(read_data_1_forwarding_flag),
    .read_data_2_forwarding_flag(read_data_2_forwarding_flag)
);

////////// Hazard Detection Unit //////////

Hazard_Detection_Unit Hazard_Detection_Unit_Instance(
    .write_reg_idx_EX(write_reg_idx_EX),
    .write_reg_flag_EX(reg_write_flag_EX),
    .mem_to_reg_flag_EX(mem_to_reg_flag_EX),
    .read_reg_idx_1_ID(read_reg_idx_1_ID),
    .read_reg_idx_2_ID(read_reg_idx_2_ID),
    .stall_flag(stall_flag)
);

endmodule
