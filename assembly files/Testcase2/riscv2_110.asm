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

sw zero, (t1)       # clear led
sw zero, (t2)       # clear seven_seg_tube
sw zero, (t3)       # clear minus_sign_flag
li a3, 0x000000FF   
sw a3, (t5)         # set show_non_flag to 0xFF

testcase0:

# read 8-bit number
lb  a1, 0(t0)
li  a3, 0x000000FF
and a1, a1, a3
mv  a4, a1

# tube
li a3, 0x000000FC
sw a3, (t5)
sw a4, (t2)

# power of 2
li a3, 0x00000001
beq a1, a3, show_led_110
li a3, 0x00000002
beq a1, a3, show_led_110
li a3, 0x00000004
beq a1, a3, show_led_110
li a3, 0x00000008
beq a1, a3, show_led_110
li a3, 0x00000010
beq a1, a3, show_led_110
li a3, 0x00000020
beq a1, a3, show_led_110
li a3, 0x00000040
beq a1, a3, show_led_110
li a3, 0x00000080
beq a1, a3, show_led_110
j exit

show_led_110:
li a3, 0x00FFFFFF
sw a3, 0(t1)

exit:
