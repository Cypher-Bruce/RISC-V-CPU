`timescale 1ns / 1ps
`include "Parameters.v"

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

module TEST_Instruction_Fetch(
    input         clk,           /// adjusted clk, from cpu
    input         rst,           /// reset signal, from cpu
    input         branch_flag,   /// branch flag, from controller
    input         jal_flag,      /// jump and link flag, from controller
    input         jalr_flag,     /// jump and link register flag, from controller
    input         zero_flag,     /// 1 if sub result is 0, from ALU, 
    input  [31:0] imme,          /// imm in branch inst, from inst memory
    input  [31:0] read_data_1,   /// data from register

    output [31:0] inst,
    output reg [31:0] program_counter,

    // UART Programmer Pinouts
    input         upg_rst_i,           // UPG reset
    input         upg_clk_i,           // UPG clk(10MHz)
    input         upg_wen_i,           // UPG write enable
    input  [13:0] upg_adr_i,           // UPG write address
    input  [31:0] upg_dat_i,           // UPG write data
    input         upg_done_i           // 1 if UPG is done
);

reg         branch_taken_flag;
wire [2:0]  funct3;  

////////////////////////// BRANCH CONTROL //////////////////////////
/// According to the result and the branch instruction,
/// PC is determined to go to goal address or not
/// It corresponds to the MUX in the CPU blueprint, but with some modifications added
  
assign funct3 = inst[14:12];

always @*
begin
    if (jal_flag || jalr_flag) // J-type
    begin
        branch_taken_flag = 1;
    end
    else // B-type
    begin
        case(funct3)
            3'b000: // beq (ALU do sub)
            begin
                branch_taken_flag = zero_flag;
            end
            3'b001: // bne
            begin
                branch_taken_flag = !zero_flag;
            end
            3'b100: // blt (ALU do slt instead of sub)
            begin
                branch_taken_flag = !zero_flag;
            end
            3'b101: // bge
            begin
                branch_taken_flag = zero_flag;
            end
            3'b110: // bltu (ALU do sltu instead of sub)
            begin
                branch_taken_flag = !zero_flag;
            end
            3'b111: // bgeu
            begin
                branch_taken_flag = zero_flag;
            end
            default: // no branch
            begin
                branch_taken_flag = 0;
            end
        endcase
    end
end

/// PC is set as constant value for testing
////////////////////////// PC //////////////////////////
/// Three cases for PC
/// Case1. rst: set PC to initial address
/// Case2. branch_flag && branch_taken_flag: increment PC with imme
/// Case3. default: increment PC by 4
/// Note that actual address sent to memory ip core is address >> 2
/// !!! PC is updated at the FALLING edge of the clock signal, for more details, refer to https://imgur.com/a/zZdYXqu

always @(negedge clk)
begin
    // if (rst)
    // begin
    //     // can changed this value to test different instructions
    //     program_counter <= `instruction_initial_address;  
    // end

    program_counter <= `instruction_initial_address;
    
    // else if (jalr_flag)
    // begin
    //     program_counter <= read_data_1 + imme;
    // end
    // else if (branch_flag && branch_taken_flag)
    // begin
    //     program_counter <= program_counter + imme;
    // end
    // else
    // begin
    //     program_counter <= program_counter + 4;
    // end
end

/////////////////////////////// Uart ///////////////////////////////
/// kickOff: mode flag, 1: normal working mode, 0: communication mode
wire kickOff;
assign kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);


////////////////////////// Instruction Memory //////////////////////////
/// The inst memory is so far a ROM ip core
/// Config: width=32bits, depth=16384(2^14), capacity=64KB
/// Paramter: 
///         - clka: cpu clock signal, 23MHz
///         - addra: Word addressable. 14-bit from PC, = PC >> 2
///         - douta: 32-bit instruction
/// TODO: update inst memory to RAM for UART
/// Note: 
///         - Data is read at the FALLING edge of the clock signal
///         - To implement UART, instruction memory is changed to RAM ip core

/// temp wire for readability
wire addra_ram; 
assign addra_ram = program_counter[15:2];

Instruction_Memory_ip Instruction_Memory_Instance(
    .clka  (kickOff ? clk             : upg_clk_i),
    .wea   (kickOff ? 1'b0            : upg_wen_i),
    .addra (kickOff ? addra_ram       : upg_adr_i),
    .dina  (kickOff ? 32'h00000000    : upg_dat_i),
    .douta (inst)
);


endmodule
