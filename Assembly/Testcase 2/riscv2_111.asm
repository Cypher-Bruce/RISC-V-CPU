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

lb   s0, 0(t0)       # read switch
lbu  s1, 1(t0)       # read stack flag
andi s1, s1, 0x00000003
li s2, 0 

loop_111:

mv  a0, s2
jal ra, fibonacci 
bge a1, s0, break_111
addi s2, s2, 1
j loop_111

fibonacci: # calculate f(n) where n = a0, put f(n) into a1, will use a2 as temp

addi sp, sp, -12
sw   ra, 0(sp)
sw   a0, 4(sp)
sw   a2, 8(sp)

jal ra, display_111_stack_in

li a2, 0
beq a0, a2, base_case_0
li a2, 1
beq a0, a2, base_case_1

addi a0, a0, -1
jal  ra, fibonacci
mv  a2, a1
addi a0, a0, -1
jal  ra, fibonacci
add  a1, a1, a2
j end_fibonacci

base_case_0:
li a1, 0
j end_fibonacci

base_case_1:
li a1, 1
j end_fibonacci

end_fibonacci:

lw a0, 4(sp)

jal ra, display_111_stack_out

lw ra, 0(sp)
lw a2, 8(sp)
addi sp, sp, 12
jr ra

display_111_stack_in:

li s3, 0
beq s1, s3, display_111
jr ra

display_111_stack_out:

li s3, 1
beq s1, s3, display_111
jr ra

display_111:

addi sp, sp, -4
sw   ra, 0(sp)

sw a0, 0(t1)
sw a0, 0(t2)

jal ra, sleep

lw ra, 0(sp)
addi sp, sp, 4
jr ra

sleep:

li a6, 0
li a7, 0x00AF79E0

sleep_loop:
addi a6, a6, 1
bne a6, a7, sleep_loop

jr ra


break_111:

sw s2, 0(t1)
sw s2, 0(t2)
