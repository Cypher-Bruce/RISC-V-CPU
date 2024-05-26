# SITUATION 2: test 000
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

lbu a0, 0(t0)
li a1, 0x00000080
li a2, 0

loop_000:

and a3, a0, a1
bne a3, zero, break_000
addi a2, a2, 1
srli a1, a1, 1
beq a1, zero, break_000
j loop_000

break_000:
sw a2, 0(t1)
sw a2, 0(t2)