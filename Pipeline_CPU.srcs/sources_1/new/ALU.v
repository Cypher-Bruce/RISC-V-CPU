`timescale 1ns / 1ps

/// Module: ALU
/// Description: This module is the Arithmetic Logic Unit (ALU) of the RISC-V processor,
///              it supports the following operations: AND, SUB, OR, ADD so far. (5/13)
/// Inputs: ReadData1, ReadData2, imm32, ALUOp, ALUSrc, funct3, funct7(details seen below in the code)
/// Outputs: ALUResult, zero

module ALU (
    input      [31:0] read_data_1,  // data from register file
    input      [31:0] read_data_2,  // data from register file
    input      [31:0] imme,         // immediate value, addi or beq, from ID
    input      [1:0]  ALU_operation,// ALU operation code, from controller
    input             ALU_src_flag, // ALU source flag, from controller
    input      [31:0] inst,         // 32-bit instruction, from ID
    input      [31:0] program_counter,
    input             jal_flag,
    input             jalr_flag,
    input             lui_flag,
    input             auipc_flag,
    
    output reg [31:0] ALU_result,   // result, to register file or data memory
    output            zero_flag     // branch flag, to IF(PC), 1 if difference btw two operands is 0
);

reg [3:0] ALU_control;
wire [31:0] operand_1;
wire [31:0] operand_2;  // depends on ALU_src_flag: 0 => read_data_2, 1 => imme
wire [2:0] funct3;
wire [6:0] funct7;
wire [6:0] opcode;

assign zero_flag = (ALU_result == 0);
assign funct7 = inst[31:25];
assign funct3 = inst[14:12];
assign opcode = inst[6:0];

assign operand_1 = read_data_1;
assign operand_2 = (ALU_src_flag) ? imme : read_data_2;

// ALU_operation are defined as follows:
// 00: S-type and load subset of I-type
// 01: B-type
// 10: R-type and arithmetic subset of I-type

always @* begin
    case(ALU_operation)
        2'b00: 
        begin
            ALU_control = 4'b0000; // add
        end
        2'b01:
        begin
            if (funct3 == 3'b110 || funct3 == 3'b111) // bltu or bgeu
                ALU_control = 4'b1001; // sltu
            else if (funct3 == 3'b100 || funct3 == 3'b101) // blt or bge
                ALU_control = 4'b1000; // slt
            else // beq or bne
                ALU_control = 4'b0001; // sub
        end
        2'b10:
        begin
            case(funct3)
                3'b000:
                begin
                    if(funct7 == 7'b0000000 || opcode == 7'b0010011)
                        ALU_control = 4'b0000; // add
                    else
                        ALU_control = 4'b0001; // sub
                end
                3'b001:
                begin
                    ALU_control = 4'b0101; // sll
                end
                3'b010:
                begin
                    ALU_control = 4'b1000; // slt
                end
                3'b011:
                begin
                    ALU_control = 4'b1001; // sltu
                end
                3'b100:
                begin
                    ALU_control = 4'b0010; // xor
                end
                3'b101:
                begin
                    if(funct7 == 7'b0000000)
                        ALU_control = 4'b0110; // srl
                    else
                        ALU_control = 4'b0111; // sra
                end
                3'b110:
                begin
                    ALU_control = 4'b0011; // or
                end
                3'b111:
                begin
                    ALU_control = 4'b0100; // and
                end
                default:
                begin
                    ALU_control = 4'b1111; // undefine
                end
            endcase
        end
        default:
        begin
            ALU_control = 4'b1111; // undefine
        end
    endcase
end

// ALU_control are defined as follows:
// 0000: add
// 0001: sub
// 0010: xor
// 0011: or
// 0100: and
// 0101: sll
// 0110: srl
// 0111: sra
// 1000: slt
// 1001: sltu
// Note: for signed and unsigned comparison, refer to https://circuitcove.com/design-examples-comparators/

always @* begin
    if (jal_flag || jalr_flag) begin
        ALU_result = program_counter + 4;
    end 
    else if (lui_flag) begin
        ALU_result = imme;
    end 
    else if (auipc_flag) begin
        ALU_result = program_counter + imme;
    end 
    else
        case(ALU_control)
            4'b0000:
            begin
                ALU_result = operand_1 + operand_2;
            end
            4'b0001:
            begin
                ALU_result = operand_1 - operand_2;
            end
            4'b0010:
            begin
                ALU_result = operand_1 ^ operand_2;
            end
            4'b0011:
            begin
                ALU_result = operand_1 | operand_2;
            end
            4'b0100:
            begin
                ALU_result = operand_1 & operand_2;
            end
            4'b0101:
            begin
                ALU_result = operand_1 << operand_2[4:0];
            end
            4'b0110:
            begin
                ALU_result = operand_1 >> operand_2[4:0];
            end
            4'b0111:
            begin
                ALU_result = operand_1 >>> operand_2[4:0];
            end
            4'b1000:
            begin
                ALU_result = ($signed(operand_1) < $signed(operand_2)) ? 32'b1 : 32'b0;
            end
            4'b1001:
            begin
                ALU_result = (operand_1 < operand_2) ? 32'b1 : 32'b0;
            end
            default:
            begin
                ALU_result = 32'b0;
            end
        endcase
end

endmodule