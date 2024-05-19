//parameters.v

// Data memory
`define IO_device_initial_address 16'hFFC0 
`define switch_initial_address 16'hFFC0
`define button_initial_address 16'hFFC4
`define led_initial_address 16'hFFC8
`define seven_seg_tube_initial_address 16'hFFCC

// Address offset
`define data_memory_initial_address 32'h00002000
`define inst_memory_initial_address 32'h00000000

// Instruction
`define nop 32'h00000013