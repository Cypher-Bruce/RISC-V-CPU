# SITUATION 2: test 101, little-endian and big-endian, 12-bit version
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

# a1: rightmost 8-bit data
# a2: 4-bit data in the left

lbu  a1, 0(t0)      # read rightmost 8-bit data from switch
lb   a2, 1(t0)      # read 4-bit data from switch
andi a2, a2, 0x0000000F     # a2: keep lower 4-bit data

# extract the highest bit of the 12-bit data
srli a4, a2, 3              # a4: the highest bit, right shift 3 bits
addi a4, a4, -1
bne  a4, zero, big_endian

little_endian:      # a5 is the output to led and seven_seg_tube
slli a5, a2, 8      # a5: 4-bit data in the left
or   a5, a5, a1     # a5: 12-bit data, little-endian
j    display_101

big_endian:         # a5 is the output to led and seven_seg_tube
slli a5, a1, 8      # a5: 8-bit data in the left
or   a5, a5, a2     # a5: 16-bit data, big-endian
j   display_101

display_101:
li a3, 0x00000FFF   
and a5, a5, a3	    # truncate to 12-bit to display
sw   a5, 0(t1)      # output to led
sw   a5, 0(t2)      # output to seven_seg_tube
