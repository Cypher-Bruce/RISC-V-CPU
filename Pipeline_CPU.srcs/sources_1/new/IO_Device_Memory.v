`timescale 1ns / 1ps

/// Module: IO_Device_Memory
/// Description: The IO_Device_Memory module acts as a memory controller for I/O devices. 
///              It manages read and write operations to memory-mapped registers and peripherals, 
///              and it handles input from switches and buttons.

module IO_Device_Memory(
    input              clk,
    input              rst,
    input      [31:0]  address_absolute,
    input      [31:0]  write_data,
    input              read_flag,
    input              write_flag,
    input      [23:0]  switch,
    input      [4:0]   debounced_button,
    input      [4:0]   push_button_flag,
    input      [4:0]   release_button_flag,

    output reg [31:0]  read_data,
    output reg [23:0]  led,
    output reg [31:0]  seven_seg_tube,
    output reg [7:0]   minus_sign_flag,
    output reg [7:0]   dot_flag,
    output reg [7:0]   show_none_flag,
    output reg         advanced_mode_flag,
    output reg [31:0]  adv_seven_seg_tube_left,
    output reg [31:0]  adv_seven_seg_tube_right
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
        advanced_mode_flag <= 1'b0;
        adv_seven_seg_tube_left <= 32'h0;
        adv_seven_seg_tube_right <= 32'h0;
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
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `seven_seg_tube_initial_address:
            begin
                led <= led;
                seven_seg_tube <= write_data;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `minus_sign_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= write_data[7:0];
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `dot_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= write_data[7:0];
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `show_none_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= write_data[7:0];
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `advanced_mode_flag_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= write_data[0];
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `adv_seven_seg_tube_left_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= write_data;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
            `adv_seven_seg_tube_right_initial_address:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= write_data;
            end
            default:
            begin
                led <= led;
                seven_seg_tube <= seven_seg_tube;
                minus_sign_flag <= minus_sign_flag;
                dot_flag <= dot_flag;
                show_none_flag <= show_none_flag;
                advanced_mode_flag <= advanced_mode_flag;
                adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
                adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
            end
        endcase
    end
    else begin
        led <= led;
        seven_seg_tube <= seven_seg_tube;
        minus_sign_flag <= minus_sign_flag;
        dot_flag <= dot_flag;
        show_none_flag <= show_none_flag;
        advanced_mode_flag <= advanced_mode_flag;
        adv_seven_seg_tube_left <= adv_seven_seg_tube_left;
        adv_seven_seg_tube_right <= adv_seven_seg_tube_right;
    end
end

always @* begin
    case (truncate_address)
        `switch_initial_address: read_data = {8'h0, switch};
        `debounced_button_initial_address: read_data = {27'h0, debounced_button};
        `push_button_flag_initial_address: read_data = {27'h0, push_button_flag};
        `release_button_flag_initial_address: read_data = {27'h0, release_button_flag};
        default: read_data = 32'h00000000;
    endcase
end
endmodule
