`timescale 1ns / 1ps

/// Credit: https://github.com/2catycm/SUSTech-CS202_214-Computer_Organization-Project/blob/develop/main/verilog/mips_cpu/drivers/TubeDriver.v
/// Module: TubeDriver
/// Description: This module is used to drive the digital tube. It will display the number from the input.
/// Input
/// Output
module TubeDriver(
    input            clock,                 // clk signal; cpu clock
    input            reset,                 // reset signal, active high 
    input            TubeCtrl,              // control signal, 1->something new come in; 0-> still the old
    input     [31:0] in_num,                // Input to be processed
    output    [7:0]  oDigitalTubeNotEnable, // Choose tube enables, active low
    output    [7:0]  oDigitalTubeShape      // Choose which segments enabled, active low 
);
    reg [7:0]  Dig_r;       // The inverse of Digital selection, select which tube to work
    reg [6:0]  Y_r;         // The reverse of Digital, select which segements to work

    /// Segment content change logic 
    reg [31:0] in_num_temp;
    always @(posedge clock) begin
        if (TubeCtrl) begin
            in_num_temp <= in_num;
        end
        else begin
            in_num_temp <= in_num_temp;
        end
    end
    
    /// Counter: new clk generator
    /// clk is a new clock signal that will be used in tube driver
    parameter half_period = 10000; // Clock half period parameter
    reg         clk;
    reg [31:0]  clk_cnt;
    reg [3 :0]  scanner_cnt;

    always @(posedge clock or posedge reset) begin
        if (reset) begin 
            clk     <= 1'b0;
            clk_cnt <= 32'h0000000;
        end
        else begin  
            clk_cnt <= clk_cnt + 1;
            if (clk_cnt  == (half_period >> 1) - 1)               
                clk <= 1'b1;
            else if (clk_cnt == half_period - 1) begin 
                clk <= 1'b0;
                clk_cnt <= 32'h00000000;      
            end
        end
    end

    /// Switch the tube in a fast frequency
    /// tube changed at every rising edge of new clk signal, s.t. all tubes are working same time
    always @(posedge clk or posedge reset) begin 
        if (reset) begin
            scanner_cnt <= 4'b0000;
        end
        else begin
            scanner_cnt <= scanner_cnt + 1'b1;    
            if(scanner_cnt == 4'd8)  begin
                scanner_cnt <= 4'b0001;
            end
        end 
    end
    
    always @(scanner_cnt) begin
        case(scanner_cnt)
            4'b0001 : Dig_r <= 8'b0000_0001;    
            4'b0010 : Dig_r <= 8'b0000_0010;    
            4'b0011 : Dig_r <= 8'b0000_0100;    
            4'b0100 : Dig_r <= 8'b0000_1000;    
            4'b0101 : Dig_r <= 8'b0001_0000;    
            4'b0110 : Dig_r <= 8'b0010_0000;    
            4'b0111 : Dig_r <= 8'b0100_0000;     
            4'b1000 : Dig_r <= 8'b1000_0000;    
            default : Dig_r <= Dig_r;
        endcase
    end
     
    /// Determine the content for each tube
    /// eg: for the rightmost tube(scanner_cnt == 4'b0001), show the lower four bits, and transfer it to hex
    reg [3:0] which_trans;
    always @(scanner_cnt) begin
        case(scanner_cnt)
            4'b0001 : which_trans <= in_num_temp[3:0];    
            4'b0010 : which_trans <= in_num_temp[7:4];      
            4'b0011 : which_trans <= in_num_temp[11:8];     
            4'b0100 : which_trans <= in_num_temp[15:12];      
            4'b0101 : which_trans <= in_num_temp[19:16];  
            4'b0110 : which_trans <= in_num_temp[23:20];  
            4'b0111 : which_trans <= in_num_temp[27:24];  
            4'b1000 : which_trans <= in_num_temp[31:28];  
            default : which_trans <= which_trans;
        endcase
    end
    
    always @(which_trans) begin
        case(which_trans) // Higher bit is gfdcba, dp
            4'd0  : Y_r <= 7'b0111111;
            4'd1  : Y_r <= 7'b0000110; // 1
            4'd2  : Y_r <= 7'b1011011; // 2
            4'd3  : Y_r <= 7'b1001111; // 3
            4'd4  : Y_r <= 7'b1100110; // 4
            4'd5  : Y_r <= 7'b1101101; // 5
            4'd6  : Y_r <= 7'b1111101; // 6
            4'd7  : Y_r <= 7'b0100111; // 7
            4'd8  : Y_r <= 7'b1111111; // 8
            4'd9  : Y_r <= 7'b1100111; // 9
            4'd10 : Y_r <= 7'b1110111; // A
            4'd11 : Y_r <= 7'b1111100; // B
            4'd12 : Y_r <= 7'b0111001; // C
            4'd13 : Y_r <= 7'b1011110; // D
            4'd14 : Y_r <= 7'b1111001; // E
            4'd15 : Y_r <= 7'b1110001; // F
            default : Y_r <= Y_r;
        endcase
    end

    /// Output assignment
    assign oDigitalTubeNotEnable = ~Dig_r;            // active low
    assign oDigitalTubeShape     = {{1'b1},{~Y_r}};   // {1'b1} is dot 
endmodule
