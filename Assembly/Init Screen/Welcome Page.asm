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
    advance_mode:   .word 0x11ff4
    adv_left:       .word 0x11ff8
    adv_right:      .word 0x11ffc

.text
lw t0, switch
lw t1, led
lw t2, seven_seg_tube
lw t3, minus_sign_flag
lw t4, dot_flag
lw t5, show_non_flag
lw t6, push_flag

lw a0, advance_mode
li a1, 1
sw a1, 0(a0)

lw a0, adv_left
li a1, 0x396D5B06
sw a1, 0(a0)

lw a0, adv_right
li a1, 0x6639733E
sw a1, 0(a0)

li a1, 0x00000001

loop:
sw a1, 0(t1)
slli a2, a1, 1
srli a3, a1, 7
or a1, a2, a3
jal ra, sleep
j loop

sleep:

li a6, 0x00000000
li a7, 0X0057BCF0

sleep_loop:
addi a6, a6, 1
bne a6, a7, sleep_loop

jr ra