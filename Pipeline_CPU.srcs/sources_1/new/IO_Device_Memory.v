`timescale 1ns / 1ps

module IO_Device_Memory(
    input              clk,
    input      [31:0]  address_absolute,
    input      [31:0]  write_data,
    input              read_flag,
    input              write_flag,
    input      [23:0]  switch,

    output reg [31:0]  read_data,
    output reg [23:0]  led
); 

wire [31:0] address;
assign address = address_absolute - `data_memory_initial_address;

always @(negedge clk) begin
    if (write_flag) begin
        case (address[15:0])
            `led_initial_address: led <= write_data[23:0];
            default: led <= led;
        endcase
    end
    else begin
        led <= led;
    end
end

always @* begin
    case (address[15:0])
        `switch_initial_address: read_data = {8'h00, switch};
        default: read_data = 32'h00000000;
    endcase
end
endmodule
