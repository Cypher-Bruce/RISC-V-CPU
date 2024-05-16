///parameters.v

// Instruction memory
`define instruction_initial_address 32'h00000000

// Data memory
`define IO_device_initial_address 16'hFFC0 
`define led_initial_address 16'hFFC0
`define switch_initial_address 16'hFFC4

// Address offset
`define data_memory_initial_address 32'h00002000
`define inst_memory_initial_address 32'h00000000