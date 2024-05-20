// Parameters.v

// Data memory
`define IO_device_initial_address 16'hFFC0 

// Input device address
`define switch_initial_address 16'hFFC0
`define debounced_button_initial_address 16'hFFC4
`define push_button_flag_initial_address 16'hFFC8
`define release_button_flag_initial_address 16'hFFCC

// Output device address
`define led_initial_address 16'hFFE0
`define seven_seg_tube_initial_address 16'hFFE4
`define minus_sign_flag_initial_address 16'hFFE8
`define dot_flag_initial_address 16'hFFEC
`define show_none_flag_initial_address 16'hFFF0

// Address offset
`define data_memory_initial_address 32'h00002000
`define inst_memory_initial_address 32'h00000000

// Instruction
`define nop 32'h00000013

// Registers
`define stack_pointer_initial_value 32'h00005ffc
`define global_pointer_initial_value 32'h00003800