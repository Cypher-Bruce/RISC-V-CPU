/// Module: Controller
/// Description: This module is the controller of the RISC-V processor,
///              it supports the following operations: R, I, S, B so far. (5/13)
/// Inputs: inst
/// Outputs: control signals
/// Note: For the table of control signals, please refer to https://media.cheggcdn.com/media/f99/f99de6a3-e2a2-4471-956d-da6ded821aa3/phpLUoecl.png

module Controller(
    input      [31:0] inst,         // instruction  from IF
    output reg branch_flag,         // Branch signal, if inst. is beq, bne, etc.
    output reg [1:0] ALU_Operation, // ALU operation signal, among AND, SUB, OR, ADD
    output reg ALU_src_flag,        // 0: read data from register, 1: read data from immediate
    output reg mem_read_flag,       // read from memory enable(lw)
    output reg mem_write_flag,      // write to memory enable(sw)
    output reg mem_to_reg_flag,     // memory to register enable(lw)
    output reg reg_write_flag       // write to register enable(sw, add, sub, and, or...)
);

wire [6:0] opcode;
assign opcode = inst[6:0];

always @* begin
    case(opcode)
        7'b0110011: // R-type
            begin
                branch_flag     = 1'b0;
                ALU_Operation   = 2'b10;
                ALU_src_flag    = 1'b0;
                mem_read_flag   = 1'b0;
                mem_write_flag  = 1'b0;
                mem_to_reg_flag = 1'b0;
                reg_write_flag  = 1'b1;
            end
        7'b0010011: // I-type (arithmetic with immediate)
            begin
                branch_flag     = 1'b0;
                ALU_Operation   = 2'b10;
                ALU_src_flag    = 1'b1;
                mem_read_flag   = 1'b0;
                mem_write_flag  = 1'b0;
                mem_to_reg_flag = 1'b0;
                reg_write_flag  = 1'b1;
            end
        7'b0000011: // I-type (load)
            begin
                branch_flag     = 1'b0;
                ALU_Operation   = 2'b00;
                ALU_src_flag    = 1'b1;
                mem_read_flag   = 1'b1;
                mem_write_flag  = 1'b0;
                mem_to_reg_flag = 1'b1;
                reg_write_flag  = 1'b1;
            end
        7'b0100011: // S-type
            begin
                branch_flag     = 1'b0;
                ALU_Operation   = 2'b00;
                ALU_src_flag    = 1'b1;
                mem_read_flag   = 1'b0;
                mem_write_flag  = 1'b1;
                mem_to_reg_flag = 1'b0;
                reg_write_flag  = 1'b0;
            end
        7'b1100011: // B-type
            begin
                branch_flag     = 1'b1;
                ALU_Operation   = 2'b01;
                ALU_src_flag    = 1'b0;
                mem_read_flag   = 1'b0;
                mem_write_flag  = 1'b0;
                mem_to_reg_flag = 1'b0;
                reg_write_flag  = 1'b0;
            end
        default:
            begin
                branch_flag     = 1'b0;
                ALU_Operation   = 2'b00;
                ALU_src_flag    = 1'b0;
                mem_read_flag   = 1'b0;
                mem_write_flag  = 1'b0;
                mem_to_reg_flag = 1'b0;
                reg_write_flag  = 1'b0;
            end
    endcase
end

endmodule