# SITUATION 2: test 110, identify power of 2
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

# read 8-bit number
lbu  a1, 0(t0)

# power of 2
li a3, 0x00000001
beq a1, a3, display_110
li a3, 0x00000002
beq a1, a3, display_110
li a3, 0x00000004
beq a1, a3, display_110
li a3, 0x00000008
beq a1, a3, display_110
li a3, 0x00000010
beq a1, a3, display_110
li a3, 0x00000020
beq a1, a3, display_110
li a3, 0x00000040
beq a1, a3, display_110
li a3, 0x00000080
beq a1, a3, display_110
j exit

display_110:
li a3, 0x000000FF
sw a3, 0(t1)
sw a3, 0(t2)

exit:
