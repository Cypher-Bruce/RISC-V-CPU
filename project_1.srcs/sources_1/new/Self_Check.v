`timescale 1ns / 1ps

module Self_Check(
input rst,
input [23:0] switch,
input [4:0] button,
output reg [23:0] led
    );

always @*
begin
    if (rst || button > 0) begin
        led = 24'b0;
    end
    else begin
        led = switch;
    end
end
endmodule
