`timescale 1ns / 1ps

/// Module: Program_Counter_Prediction
/// Description: The mechanism of program counter prediction is as follows:
///   - If the current program counter value is already in the LRU cache, it means
///     that a similar branch instruction has been executed before and the
///     corresponding branch target address has been recorded in the cache.
///     Therefore, program prediction assumes that the current branch instruction
///     will be executed repeatedly, and the next program counter value is predicted
///     to be the corresponding branch target address in the cache.
///   - If the current program counter value is not in the LRU cache, this means
///     that there was no previous similar branching instruction or the cache has
///     been invalidated to provide a reliable prediction. In this case, the program
///     prediction will simply set the next program counter value to the current
///     program counter value plus the instruction width. This is a conservative
///     assumption that assumes the program will execute the next instruction
///     sequentially.
///   In short, use LRU cache to store the branch instruction and its target address.

module Program_Counter_Prediction(
    input             clk,
    input             rst,
    input      [31:0] branch_from_pc,               // where the branch instruction is
    input      [31:0] branch_to_pc,                 // where the branch instruction will go
    input      [31:0] program_counter,
    input             branch_flag,
    
    output reg [31:0] program_counter_prediction,
    output reg [31:0] prev_pcp
);

// Each LRU_cache is divided into 2 parts
// The first half stores the branch_from_pc (where the branch instruction is)
// The second half stores the branch_to_pc (where the branch instruction will go)

// If the branch_from_pc is in the LRU_cache, the most recent branch_to_pc is the prediction
// If the branch_from_pc is not in the LRU_cache, we predict branch will not be taken

reg [63:0] LRU_cache [0:3];
reg current_pc_in_cache_flag;
reg [1:0] current_pc_in_cache_idx;
reg branch_from_pc_in_cache_flag;
reg [1:0] branch_from_pc_in_cache_idx;
reg [2:0] LRU_capacity;

always @* begin
    if (LRU_cache[0][31:0] == program_counter) begin
        current_pc_in_cache_flag = 1'b1;
        current_pc_in_cache_idx = 2'b00;
    end
    else if (LRU_cache[1][31:0] == program_counter) begin
        current_pc_in_cache_flag = 1'b1;
        current_pc_in_cache_idx = 2'b01;
    end
    else if (LRU_cache[2][31:0] == program_counter) begin
        current_pc_in_cache_flag = 1'b1;
        current_pc_in_cache_idx = 2'b10;
    end
    else if (LRU_cache[3][31:0] == program_counter) begin
        current_pc_in_cache_flag = 1'b1;
        current_pc_in_cache_idx = 2'b11;
    end
    else begin
        current_pc_in_cache_flag = 1'b0;
        current_pc_in_cache_idx = 2'b00;
    end

    if (LRU_cache[0][31:0] == branch_from_pc) begin
        branch_from_pc_in_cache_flag = 1'b1;
        branch_from_pc_in_cache_idx = 2'b00;
    end
    else if (LRU_cache[1][31:0] == branch_from_pc) begin
        branch_from_pc_in_cache_flag = 1'b1;
        branch_from_pc_in_cache_idx = 2'b01;
    end
    else if (LRU_cache[2][31:0] == branch_from_pc) begin
        branch_from_pc_in_cache_flag = 1'b1;
        branch_from_pc_in_cache_idx = 2'b10;
    end
    else if (LRU_cache[3][31:0] == branch_from_pc) begin
        branch_from_pc_in_cache_flag = 1'b1;
        branch_from_pc_in_cache_idx = 2'b11;
    end
    else begin
        branch_from_pc_in_cache_flag = 1'b0;
        branch_from_pc_in_cache_idx = 2'b00;
    end

    if (current_pc_in_cache_flag && current_pc_in_cache_idx < LRU_capacity) begin
        program_counter_prediction = LRU_cache[current_pc_in_cache_idx][63:32];
    end
    else begin
        program_counter_prediction = program_counter + 4;
    end
end

always @(negedge clk) begin
    if (rst) begin
        prev_pcp <= 32'h00000000;
    end
    else begin
        prev_pcp <= program_counter_prediction;
    end

    if (rst) begin
        LRU_cache[0] <= 64'h0000000000000000;
        LRU_cache[1] <= 64'h0000000000000000;
        LRU_cache[2] <= 64'h0000000000000000;
        LRU_cache[3] <= 64'h0000000000000000;
        LRU_capacity <= 3'b000;
    end
    else if (branch_flag) begin
        if (branch_from_pc_in_cache_flag) begin
            case (branch_from_pc_in_cache_idx)
                2'b00: begin
                    LRU_cache[0] <= {branch_to_pc, branch_from_pc};
                    LRU_cache[1] <= LRU_cache[1];
                    LRU_cache[2] <= LRU_cache[2];
                    LRU_cache[3] <= LRU_cache[3];
                end
                2'b01: begin
                    LRU_cache[0] <= {branch_to_pc, branch_from_pc};
                    LRU_cache[1] <= LRU_cache[0];
                    LRU_cache[2] <= LRU_cache[2];
                    LRU_cache[3] <= LRU_cache[3];
                end
                2'b10: begin
                    LRU_cache[0] <= {branch_to_pc, branch_from_pc};
                    LRU_cache[1] <= LRU_cache[0];
                    LRU_cache[2] <= LRU_cache[1];
                    LRU_cache[3] <= LRU_cache[3];
                end
                2'b11: begin
                    LRU_cache[0] <= {branch_to_pc, branch_from_pc};
                    LRU_cache[1] <= LRU_cache[0];
                    LRU_cache[2] <= LRU_cache[1];
                    LRU_cache[3] <= LRU_cache[2];
                end
            endcase
            LRU_capacity <= LRU_capacity;
        end
        else begin
            LRU_cache[0] <= {branch_to_pc, branch_from_pc};
            LRU_cache[1] <= LRU_cache[0];
            LRU_cache[2] <= LRU_cache[1];
            LRU_cache[3] <= LRU_cache[2];
            if (LRU_capacity == 3'b100) begin
                LRU_capacity <= 3'b100;
            end
            else begin
                LRU_capacity <= LRU_capacity + 1;
            end
        end
    end
end

endmodule
