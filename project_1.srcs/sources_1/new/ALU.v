`timescale 1ns / 1ps

module ALU(
input [31:0] read_data_1,
input [31:0] read_data_2,
input [31:0] imme,
input [1:0] ALU_Operation,
input ALU_src_flag,
input [31:0] inst,
output reg [31:0] ALU_result,
output zero_flag
);

reg [3:0] ALUControl;
wire [31:0] operand_2;
wire [2:0] funct3;
wire [6:0] funct7;

assign operand_2 = ALU_src_flag ? imme : read_data_2;
assign zero_flag = ALU_result == 0;
assign funct7 = inst[31:25];
assign funct3 = inst[14:12];

always @* begin
    case(ALU_Operation)
        2'b00: 
        begin
            ALUControl = 4'b0010;
        end
        2'b01:
        begin
            ALUControl = 4'b0110;
        end
        2'b10:
        begin
            case(funct7)
                7'b0000000:
                begin
                    case(funct3)
                        3'b000:
                        begin
                            ALUControl = 4'b0010;
                        end
                        3'b111:
                        begin
                            ALUControl = 4'b0000;
                        end
                        3'b110:
                        begin
                            ALUControl = 4'b0001;
                        end
                    endcase
                end
                7'b0100000:
                begin
                    ALUControl = 4'b0110;
                end
            endcase
        end
    endcase
end

always @* begin
    case(ALUControl)
        4'b0000:
        begin
            ALU_result = read_data_1 & operand_2;
        end
        4'b0001:
        begin
            ALU_result = read_data_1 | operand_2;
        end
        4'b0010:
        begin
            ALU_result = read_data_1 + operand_2;
        end
        4'b0110:
        begin
            ALU_result = read_data_1 - operand_2;
        end
    endcase
end

endmodule