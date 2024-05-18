`timescale 1ns / 1ps

module Branch_Target(
    input             jal_flag,
    input             jalr_flag,
    input             branch_flag,
    input             zero_flag,
    input      [31:0] read_data_1,
    input      [31:0] imme,
    input      [31:0] program_counter,
    input      [31:0] inst,

    output            pc_src_flag,
    output reg [31:0] branch_pc
);

//////////////// branch_flag //////////////////
// branch_flag: whether the branch instruction is taken
// unconditional branch: jal, jalr
// conditional branch: beq, bne, blt, bge, bltu, bgeu
reg branch_taken_flag; 
wire [2:0] funct3;
assign funct3 = inst[14:12];

always @* begin
    if (jal_flag || jalr_flag) begin // J-type
        branch_taken_flag = 1;  // unconditional branch
    end
    else begin // B-type
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

//////////////// pc_src_flag //////////////////
// pc_src_flag: whether the branch_pc is the target address
// 0: pc = pc + 4, 1: pc = branch_pc

assign pc_src_flag = branch_flag && branch_taken_flag;

//////////////// branch_pc //////////////////
// branch_pc: the next program counter
// will be ignored if pc_src_flag is 0

always @* begin
    if (jalr_flag) begin
        branch_pc = read_data_1 + imme;
    end
    else if (jal_flag || pc_src_flag) begin
        branch_pc = program_counter + imme;
    end
    else begin
        branch_pc = 32'h0; // will be ignored, also more obvious for debugging
    end
end

endmodule
