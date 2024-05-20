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
    input      [31:0] program_counter_prediction,

    output            wrong_prediction_flag,
    output reg [31:0] branch_pc
);

//////////////// branch_taken_flag //////////////////
// branch_taken_flag: whether the branch_pc is the target address
// 0: pc = pc + 4, 1: pc = branch_pc
// unconditional branch: jal, jalr
// conditional branch: beq, bne, blt, bge, bltu, bgeu

wire [2:0] funct3;
reg branch_taken_flag;
assign funct3 = inst[14:12];

always @* begin
    if (jal_flag || jalr_flag) begin // J-type
        branch_taken_flag = 1;  // unconditional branch
    end
    else if (branch_flag) begin // B-type
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
    else begin
        branch_taken_flag = 0;
    end
end

//////////////// branch_pc //////////////////
// branch_pc: the next program counter
// will be ignored if branch_taken_flag = 0

always @* begin
    if (jalr_flag) begin
        branch_pc = read_data_1 + imme;
    end
    else if (jal_flag) begin
        branch_pc = program_counter + imme;
    end
    else if (branch_taken_flag) begin
        branch_pc = program_counter + imme;
    end
    else begin
        branch_pc = program_counter + 4;
    end
end

assign wrong_prediction_flag = (branch_pc != program_counter_prediction && branch_flag);

endmodule
