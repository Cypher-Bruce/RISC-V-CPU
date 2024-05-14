# SUSTech-CS214-Computer-Organization-Project
## Code Conventions
For the sake of code quality, we have some regulations for the code:
1. **Naming**: 
    - **Variable**: Use `snake_case` with lowercase for variable names. Example: `read_data`
      - **value**: no special requirements
      - **flag**: use **_flag** as the suffix. Example: `mem_read_flag`
      - **data**: for data from/to memory/register, use **_data** as the suffix. Example: `write_data`
    - **Module**: Use `snake_case` with uppercase for module names. Example: `Decoder`
    - **Instance**: Use `<module_name> + _ + Instance` for instance names. Example: `Decoder_Instance`
    - **Ip Core**: Use `snake_case` with suffix `_ip` for IP core names. Example: `CPU_Main_Clock_ip`
2. **Constants**: For all constants, please put them in the `Parameters.v` and reference them in the code. An example is shown in ``Instruction_Fetch.v``.
3. **Instantiation**: When instantiating a module, please use the following format:
    ```verilog
        <module_name> <module_name> + _ + Instance(
            .<port_name>(<port_name>)
        );
    ```
    For example:
    ```verilog
        Controller Controller_Instance(
            .inst(inst),
            .branch_flag(branch_flag),
            .ALU_Operation(ALU_Operation),
            .ALU_src_flag(ALU_src_flag),
            .mem_read_flag(mem_read_flag),
            .mem_write_flag(mem_write_flag),
            .mem_to_reg_flag(mem_to_reg_flag),
            .reg_write_flag(reg_write_flag)
        );
    ```
        