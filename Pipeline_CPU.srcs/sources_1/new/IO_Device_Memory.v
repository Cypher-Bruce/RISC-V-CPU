`timescale 1ns / 1ps

module IO_Device_Memory(
    input              clk,
    input              rst,
    input      [31:0]  address_absolute,
    input      [31:0]  write_data,
    input              read_flag,
    input              write_flag,
    input      [23:0]  switch,
    input      [4:0]   button,

    output reg [31:0]  read_data,
    output reg [23:0]  led,
    output reg [31:0]  seven_seg_tube,
    output reg [7:0]   minus_sign_flag,
    output reg [7:0]   dot_flag,
    output reg [7:0]   show_none_flag
); 

wire [31:0] address;
wire [31:0] truncate_address;
assign address = address_absolute - `data_memory_initial_address;
assign truncate_address = {address[31:2], 2'b00};

always @(negedge clk) begin
    if (rst) begin
        led <= 24'h0;
        seven_seg_tube <= 32'h0;
        minus_sign_flag <= 8'h0;
        dot_flag <= 8'h0;
        show_none_flag <= 8'h0;
    end
    else if (write_flag) begin
        case (truncate_address)
            `led_initial_address:
            begin
                led <= write_data[23:0];
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
            end
            `seven_seg_tube_initial_address:
            begin
                led <= led;
                seven_seg_tube <= write_data;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
            end
            `minus_sign_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= write_data[7:0];
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
            end
            `dot_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= write_data[7:0];
                show_none_flag <= show_none_flag;
            end
            `show_none_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= write_data[7:0];
            end
            default:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
            end
        endcase
    end
    else begin
        led <= led;
        seven_seg_tube <= seven_seg_tube;
        minus_sign_flag <= minus_sign_flag;
        dot_flag <= dot_flag;
        show_none_flag <= show_none_flag;
    end
end

always @* begin
    case (truncate_address)
        `switch_initial_address: read_data = {8'h0, switch};
        `button_initial_address: read_data = {27'h0, button};
        default: read_data = 32'h00000000;
    endcase
end
endmodule
