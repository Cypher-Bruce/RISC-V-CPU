module Controller(
input [31:0] inst,
output reg branch_flag,
output reg [1:0] ALU_Operation,
output reg ALU_src_flag,
output reg mem_read_flag,
output reg mem_write_flag,
output reg mem_to_reg_flag,
output reg reg_write_flag
);

wire [6:0] opcode;

assign opcode = inst[6:0];

always @*
begin
    case(opcode)
        7'b0110011: // R-type
        begin
            branch_flag = 1'b0;
            ALU_Operation = 2'b10;
            ALU_src_flag = 1'b0;
            mem_read_flag = 1'b0;
            mem_write_flag = 1'b0;
            mem_to_reg_flag = 1'b0;
            reg_write_flag = 1'b1;
        end
        7'b0010011: // I-type
        begin
            branch_flag = 1'b0;
            ALU_Operation = 2'b00;
            ALU_src_flag = 1'b1;
            mem_read_flag = 1'b0;
            mem_write_flag = 1'b0;
            mem_to_reg_flag = 1'b0;
            reg_write_flag = 1'b1;
        end
        7'b0000011: // I-type
        begin
            branch_flag = 1'b0;
            ALU_Operation = 2'b00;
            ALU_src_flag = 1'b1;
            mem_read_flag = 1'b1;
            mem_write_flag = 1'b0;
            mem_to_reg_flag = 1'b1;
            reg_write_flag = 1'b1;
        end
        7'b0100011: // S-type
        begin
            branch_flag = 1'b0;
            ALU_Operation = 2'b00;
            ALU_src_flag = 1'b1;
            mem_read_flag = 1'b0;
            mem_write_flag = 1'b1;
            mem_to_reg_flag = 1'b0;
            reg_write_flag = 1'b0;
        end
        7'b1100011: // B-type
        begin
            branch_flag = 1'b1;
            ALU_Operation = 2'b01;
            ALU_src_flag = 1'b0;
            mem_read_flag = 1'b0;
            mem_write_flag = 1'b0;
            mem_to_reg_flag = 1'b0;
            reg_write_flag = 1'b0;
        end
        default:
        begin
            branch_flag = 1'b0;
            ALU_Operation = 2'b00;
            ALU_src_flag = 1'b0;
            mem_read_flag = 1'b0;
            mem_write_flag = 1'b0;
            mem_to_reg_flag = 1'b0;
            reg_write_flag = 1'b0;
        end
    endcase
end

endmodule