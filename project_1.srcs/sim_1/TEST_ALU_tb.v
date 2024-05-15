`timescale 1ns / 1ps
/// !!!DESIGN MODULE AT THE END OF FILE

/// Module: TEST_ALU_tb
/// #Description: This module is used to test the ALU module.
/// #Testcases: see the end of the module
/// #Note: this test DOES NOT require COE file for memory initialization

module TEST_ALU_tb;

    // Inputs
    reg [31:0] instruction;
    reg [31:0] reg_data_1;
    reg [31:0] reg_data_2;
    reg [31:0] imme;

    // Outputs
    wire [31:0] ALU_output;
    wire zero_flag;

    // Instantiate the Unit Under Test (UUT)
    TEST_ALU uut (
        .instruction(instruction),
        .reg_data_1(reg_data_1),
        .reg_data_2(reg_data_2),
        .imme(imme),
        .ALU_output(ALU_output),
        .zero_flag(zero_flag)
    );

    // Task to initialize and apply test vectors
    task apply_instruction;
        input [31:0] instr;
        input [31:0] data1;
        input [31:0] data2;
        input [31:0] immediate;
        begin
            instruction = instr;
            imme = immediate;
            #10; // Wait for 10 time units
        end
    endtask

    initial begin
        // Initialize inputs
        instruction = 32'd0;
        reg_data_1 = 32'hffffffff;
        reg_data_2 = 32'h0fffffff;
        imme = 32'd0;

        // Wait 100 ns for global reset to finish
        #100;

        // Apply instructions and operands
        // ADD (example encoding for R-type instruction)
        apply_instruction(32'h003100b3, 32'd10, 32'd20, 32'd0); // ADD x3 = x1 + x2
        // SUB (example encoding for R-type instruction)
        apply_instruction(32'h403100b3, 32'd30, 32'd10, 32'd0); // SUB x3 = x1 - x2
        // AND (example encoding for R-type instruction)
        apply_instruction(32'h003170b3, 32'hA5A5A5A5, 32'h5A5A5A5A, 32'd0); // AND x3 = x1 & x2
        // OR (example encoding for R-type instruction)
        apply_instruction(32'h003160b3, 32'hA5A5A5A5, 32'h5A5A5A5A, 32'd0); // OR x3 = x1 | x2
        // SLL (Shift Left Logical)
        apply_instruction(32'h003110b3, 32'h00000001, 32'd2, 32'd0); // SLL x3 = x1 << x2
        // SRL (Shift Right Logical)
        apply_instruction(32'h003150b3, 32'h00000010, 32'd1, 32'd0); // SRL x3 = x1 >> x2
        // SRA (Shift Right Arithmetic)
        apply_instruction(32'h403150b3, 32'h80000000, 32'd1, 32'd0); // SRA x3 = x1 >>> x2
        // SLT (Set Less Than)
        apply_instruction(32'h003120b3, 32'd10, 32'd20, 32'd0); // SLT x3 = (x1 < x2)
        // SLTU (Set Less Than Unsigned)
        apply_instruction(32'h003130b3, 32'd10, 32'd20, 32'd0); // SLTU x3 = (x1 < x2)

        // Finish the simulation
        #100;
        $finish;
    end

endmodule

/////////////////////////////////////////////Testcases/////////////////////////////////////////////

// The following lines are genrated from RARS and rars2coe
// The following lines correspond to each of the test case above
// add, sub, and, or, sll, srl, sra, slt, sltu
// memory_initialization_radix = 16;
// memory_initialization_vector =
// 003100b3,
// 403100b3,
// 005271b3,
// 003160b3,
// 00208663,
// 00012083,
// 00112023,
// 00000000,
// ......

//////////////////////////////////////Design module//////////////////////////////////////////////

// `timescale 1ns / 1ps

// /// Module: TEST_ALU
// /// #Description
// ///      This module is used to test the ALU module.
// ///      It reveives instruction, by controller gets the flags, then sends the flags and data to ALU.
// ///      In testbench, we assign the instuctions by refering to RARS
// ///      These instructions will be tested: add, sub, and, or, sll, srl, sra, slt, sltu
// ///      In testbench, the two operands, the ALU src will be given, and only the instruction needs to be changed
// /// #Inputs: instruction[31:0], reg_data_1[31:0], reg_data_2[31:0], imme[31:0]
// /// #Outputs: ALU_result[31:0]
// /// #Result: Find a bug in the ALU module - or should be 0011 but written as 0001

// module TEST_ALU(
//     input  [31:0] instruction,
//     input  [31:0] reg_data_1,
//     input  [31:0] reg_data_2,
//     input  [31:0] imme,

//     output [31:0] ALU_output,
//     output        zero_flag
//     );

// ////////////////////////// Controller //////////////////////////
// // wire [31:0]     inst;
// wire            branch_flag;
// wire [1:0]      ALU_Operation;
// wire            ALU_src_flag;
// wire            mem_read_flag;
// wire            mem_write_flag;
// wire            mem_to_reg_flag;
// wire            reg_write_flag;
// Controller Controller_Instance(
//     .inst(instruction),
//     .branch_flag(branch_flag),
//     .ALU_Operation(ALU_Operation),
//     .ALU_src_flag(ALU_src_flag),
//     .mem_read_flag(mem_read_flag),
//     .mem_write_flag(mem_write_flag),
//     .mem_to_reg_flag(mem_to_reg_flag),
//     .reg_write_flag(reg_write_flag)
// );


// ////////////////////////// Execution //////////////////////////
// wire [31:0] ALU_result;
// ALU ALU_Instance(
//     .read_data_1(reg_data_1),
//     .read_data_2(reg_data_2),
//     .imme(imme),
//     .ALU_Operation(ALU_Operation),
//     .ALU_src_flag(ALU_src_flag),
//     .inst(instruction),
//     .ALU_result(ALU_result),
//     .zero_flag(zero_flag)
// );

// assign ALU_output = ALU_result;

// endmodule
