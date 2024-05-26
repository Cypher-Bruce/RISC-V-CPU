# SITUATION 2: test 100, add and negate
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

lb a1, 0(t0)       # read rightmost 8-bit from switch
lb a2, 1(t0)       # read left 8-bit from switch
andi a1, a1, 0x000000ff     # keep the lower 8-bit
andi a2, a2, 0x000000ff     # keep the lower 8-bit

add  a3, a1, a2          # a3 = a1 + a2
srli a4, a3, 8          # get the 9_th bit of sum of a1 and a2
addi a4, a4, -1
andi  a3, a3, 0x000000ff         # by the way, keep the lower 8-bit of a3
bne  a4, zero, display_100
addi a3, a3, 1      # add 1 to a3

display_100:
xori a3, a3, -1
andi  a3, a3, 0x000000ff  
sw a3, (t1)
sw a3, (t2)