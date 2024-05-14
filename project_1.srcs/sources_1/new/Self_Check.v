`timescale 1ns / 1ps

module Self_Check(
input rst,
input [23:0] Levers,
input [4:0] Buttons,
output reg [23:0] Leds
    );

always @*
begin
    if (rst || Buttons > 0) begin
        Leds = 24'b0;
    end
    else begin
        Leds = Levers;
    end
end
endmodule
