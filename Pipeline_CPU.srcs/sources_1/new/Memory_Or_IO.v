`timescale 1ns / 1ps
`include "Parameters.v"

module Memory_Or_IO(
    input       [31:0]  address_absolute,         // 14-bit address bus, from ALU
    input       [31:0]  inst,                     // instruction from inst memory (to determine output byte/half/word)
    input               mem_read_flag,            // read flag, from controller
    input               mem_write_flag,           // write flag, from controller
    input       [31:0]  data_memory_read_data,
    input       [31:0]  io_device_read_data,
    
    output reg  [31:0]  read_data,                // data read from memory, to register file(load inst.)
    output              data_memory_read_flag,
    output              data_memory_write_flag,
    output              io_device_read_flag,
    output              io_device_write_flag
); 

wire [31:0] address;
assign address = address_absolute - `data_memory_initial_address;

// decide whether to read from (write to) memory or IO device
// 0: memory, 1: IO device
wire data_source_select_flag; 
assign data_source_select_flag = ($unsigned(address[15:0]) >= $unsigned(`IO_device_initial_address)) ? 1 : 0;

// specific flags for memory and IO device
assign data_memory_read_flag = mem_read_flag & ~data_source_select_flag;
assign data_memory_write_flag = mem_write_flag & ~data_source_select_flag;
assign io_device_read_flag = mem_read_flag & data_source_select_flag;
assign io_device_write_flag = mem_write_flag & data_source_select_flag;


// extract and sign-extend the data read from memory
wire [31:0] raw_read_data;
wire [2:0] funct3;
assign funct3 = inst[14:12];
assign raw_read_data = data_source_select_flag ? io_device_read_data : data_memory_read_data;
always @* begin
    if (~mem_read_flag)
        read_data = 32'h00000000;
    else
        case (funct3)
            3'b000: // load byte
            begin
                case ({address[1], address[0]})   // looks strange right? change this to address[1:0] and the cpu fail to work, don't know why yet
                    2'b00: read_data = {{24{raw_read_data[7]}}, raw_read_data[7:0]};
                    2'b01: read_data = {{24{raw_read_data[15]}}, raw_read_data[15:8]};
                    2'b10: read_data = {{24{raw_read_data[23]}}, raw_read_data[23:16]};
                    2'b11: read_data = {{24{raw_read_data[31]}}, raw_read_data[31:24]};
                endcase
            end
            3'b001: // load half
            begin
                case (address[1])
                    1'b0: read_data = {{16{raw_read_data[15]}}, raw_read_data[15:0]};
                    1'b1: read_data = {{16{raw_read_data[31]}}, raw_read_data[31:16]};
                endcase
            end
            3'b010: // load word
            begin
                read_data = raw_read_data;
            end
            3'b100: // load byte unsigned
            begin
                case ({address[1], address[0]})
                    2'b00: read_data = {24'h000000, raw_read_data[7:0]};
                    2'b01: read_data = {24'h000000, raw_read_data[15:8]};
                    2'b10: read_data = {24'h000000, raw_read_data[23:16]};
                    2'b11: read_data = {24'h000000, raw_read_data[31:24]};
                endcase
            end
            3'b101: // load half unsigned
            begin
                case (address[1])
                    1'b0: read_data = {16'h0000, raw_read_data[15:0]};
                    1'b1: read_data = {16'h0000, raw_read_data[31:16]};
                endcase
            end
            default: read_data = 32'h00000000;
        endcase
end
endmodule
