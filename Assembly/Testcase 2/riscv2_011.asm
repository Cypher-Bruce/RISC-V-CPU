# SITUATION 2: test 011
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

# input a half precision floating point number
# display the number on the seven segment tube

lhu a0, 0(t0)
li a1, 0x8000
and s0, a0, a1
srli s0, s0, 15
li a1, 0x7C00
and s1, a0, a1
srli s1, s1, 10
li a1, 0x03FF
and s2, a0, a1
li s3, -10

# s0: sign bit
# s1: exponent
# s2: the number itself (first digit will be added later due to the special case of subnormal_011 numbers)
# s3: exponent offset
# the fraction number = s2 * 2^s3

li a1, 0
beq s1, a1, subnormal_011
li a1, 0x0000001F
beq s1, a1, infinity_or_nan_011

normal_011:

li a1, 0x00000400
add s2, s2, a1
addi s1, s1, -15
add s3, s3, s1
j display_011

subnormal_011:

addi s3, s3, -14
j display_011

infinity_or_nan_011:

beq s2, zero, display_inf_011

display_nan_011:
lw t6, advance_mode
li a1, 1
sw a1, 0(t6)

lw t6, adv_left
li a1, 0
sw a1, 0(t6)

lw t6, adv_right
li a1, 0x00547754
sw a1, 0(t6)

j exit

display_inf_011:
lw t6, advance_mode
li a1, 1
sw a1, 0(t6)

lw t6, adv_left
li a1, 0
sw a1, 0(t6)

lw t6, adv_right
li a1, 0x00065471
slli a2, s0, 30
add a1, a1, a2
sw a1, 0(t6)

j exit

display_011:

addi s3, s3, 1
blt s3, zero, shift_right_011

shift_left_011:
sll s4, s2, s3
addi s4, s4, 1
srli s4, s4, 1

sw s4, 0(t1)
sw s4, 0(t2)
mv a1, s0
slli a1, a1, 7
sw a1, 0(t3)
mv a1, s0
xori a1, a1, 1
slli a1, a1, 7
sw a1, 0(t5)

j exit

shift_right_011:
xori s3, s3, -1
addi s3, s3, 1
srl s4, s2, s3
addi s4, s4, 1
srli s4, s4, 1

sw s4, 0(t1)
sw s4, 0(t2)
mv a1, s0
slli a1, a1, 7
sw a1, 0(t3)
mv a1, s0
xori a1, a1, 1
slli a1, a1, 7
sw a1, 0(t5)

exit: