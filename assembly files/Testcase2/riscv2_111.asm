# SITUATION 2: test 111, fibonacci
.data
    switch:         .word 0x11fc0
    button:         .word 0x11fc4
    push_flag:      .word 0x11fc8
    release_flag:   .word 0x11fcc
    led:            .word 0x11fe0
    seven_seg_tube: .word 0x11fe4
    minus_sign_flag:.word 0x11fe8
    dot_flag:       .word 0x11fec
    show_non_flag:  .word 0x11ff0

.text
lw t0, switch
lw t1, led
lw t2, seven_seg_tube
lw t3, minus_sign_flag
lw t4, dot_flag
lw t5, show_non_flag
lw t6, push_flag

#init
sw zero, (t1)       # clear led
sw zero, (t2)       # clear seven_seg_tube
sw zero, (t3)       # clear minus_sign_flag
li a3, 0x000000FF   
sw a3, (t5)         # set show_non_flag to 0xFF

li a3, 0x000000E4    # clear show_non_flag
sw a3, (t5)          # set show_non_flag to 0x00, so all tubes will be shown

# read 8-bit number: s0; s2: stack flag, 0x00000000 -> data into stack, 0x00000001 -> data out of stack
lw  s0, 0(t0)       # read switch
sw  s0, (t1)         # write switch to led
lb  s2, 1(t0)       # read stack flag
li  s3, 0x000000FF  # mask, keep the last 8 bits
and s0, s0, s3      # keep the last 8 bits
and s2, s2, s3      # keep the last 8 bits

li s1, 0 
loop: 

#fib
mv  a0, s1 
jal ra, fibonacci   # result in a1
bge a1, s0, break # if a1 >s0 break
addi s1, s1, 1
j loop

fibonacci:
    addi sp, sp, -12    
    sw   ra, 0(sp)     
    sw   a0, 4(sp)  
    sw   a2, 8(sp)
    
    # n <= 1, base case
    li  a3, 1
    ble a0, a3, base_case
    
    # fib(n - 1) and fib(n - 2)
    addi a0, a0, -1     
    jal  ra, fibonacci   
    mv   a2, a1       
    addi a0, a0, -1   
    jal  ra, fibonacci  
    
    add  a1, a1, a2
   
return_n:
    lw  a2, 8(sp)
    lw  a0, 4(sp)      
    lw  ra, 0(sp)    
    addi sp, sp, 12 
    jr ra
   
base_case:
    mv a1, a0 
    j return_n

break:

slli s1, s1, 16
mv   s11, s1      # s11: 0x????0000 (???? is the result)

#write led
li s1, 0            # counter, start from 0
loop_stack: 

#fib
mv  a0, s1 
jal ra, fibonacci_stack   # result in a1
bge a1, s0, break_stack   # if a1 >s0 break
addi s1, s1, 1            # try the next fib number
j loop_stack

fibonacci_stack:
    addi sp, sp, -12    
    sw   ra, 0(sp)     
    sw   a0, 4(sp)  
    sw   a2, 8(sp)

    # print into-stack data
    li s3, 0x00000000        # s3 be the flag of print into-stack data
    bne s2, s3, no_stack_in  # if s2 != 0, don't bother, go to no_stack_in
    # li  s3, 0x00000000
    li  s4, 0x00ffffff   # counter destiniation, start from 0
    li  s6, 0x000000FF   # mask, keep the last 8 bits
    mv  s5, a0           # s5 be the in-stack data
    and s5, s5, s6       # mask, keep the last 8 bits
    or  s5, s5, s11      # concat with result: s5: 0x (result) (in-stack data)
    sw  s5, 0(t2)
small_loop:
    addi s3, s3, 1
    bne s3, s4, small_loop

no_stack_in:
    
    # n <= 1, base case
    li  a3, 1
    ble a0, a3, base_case_stack
    
    # fib(n - 1) and fib(n - 2)
    addi a0, a0, -1     
    jal  ra, fibonacci_stack   
    mv   a2, a1       
    addi a0, a0, -1   
    jal  ra, fibonacci_stack  
    
    add  a1, a1, a2
   
return_n_stack:
    lw  a2, 8(sp)
    lw  a0, 4(sp)      
    lw  ra, 0(sp)    
    addi sp, sp, 12 

    # print out-stack data
    li s3, 0x00000001           # s3 be the flag of print out-stack data
    bne s2, s3, no_stack_out    # if s2 != 1, don't bother, go to no_stack_out
    # li  s3, 0x00000000
    li  s4, 0x00ffffff  # counter destiniation, start from 0
    li  s6, 0x000000FF  # mask, keep the last 8 bits
    mv  s5, a0          # s5 be the out-stack data
    and s5, s5, s6      # mask, keep the last 8 bits
    or  s5, s5, s11     # concat with result: s5: 0x (result) (out-stack data)
    sw  s5, 0(t2)
small_loop_out:
    addi s3, s3, 1
    bne s3, s4, small_loop_out

no_stack_out:
    jr ra
   
base_case_stack:
    mv a1, a0 
    j return_n_stack

break_stack:    
