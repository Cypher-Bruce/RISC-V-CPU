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
li s3, 0x000000ff  # musk
and a1, a1, s3     # keep the lower 8-bit
and a2, a2, s3     # keep the lower 8-bit

add  a3, a1, a2          # a3 = a1 + a2
srli s4, a3, 8          # get the 9_th bit of sum of a1 and a2
li   s3, 0x000000ff
and  a3, a3, s3         # by the way, keep the lower 8-bit of a3
li   s3, 0x00000001
beq  s4, s3, negation   # if the 9_th bit is 1, then go to negation
j    exit_100           # else, just print the sum of a1 and a2

negation:
    addi a3, a3, 1      # add 1 to a3
    li  s3, 0x000000ff
    xor a3, a3, s3      # negate a3 by xor with 0xff
    and a3, a3, s3      # keep the lower 8-bit of a3

exit_100:
    li s3, 0x000000FC   # show the rightmost two regs
    sw s3, 0(t5)        # show the rightmost two regs
    sw a3, 0(t1)        # write a3 to led
    sw a3, 0(t2)        # write a3 to seven_seg_tube
