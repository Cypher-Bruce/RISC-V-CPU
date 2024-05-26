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

sw zero, (t1)
sw zero, (t2)
sw zero, (t3)
sw zero, (t4)
sw zero, (t5)
lw a3, advance_mode
sw zero, (a3)

lw s0, (t0)
srli s0, s0, 21
li s1, 0
beq s0, s1, testcase0
addi s1, s1, 1
beq s0, s1, testcase1
addi s1, s1, 1
beq s0, s1, testcase2
addi s1, s1, 1
beq s0, s1, testcase3
addi s1, s1, 1
beq s0, s1, testcase4
addi s1, s1, 1
beq s0, s1, testcase5
addi s1, s1, 1
beq s0, s1, testcase6
addi s1, s1, 1
beq s0, s1, testcase7

testcase0:

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

j exit

testcase1:

lhu a0, 0(t0)
li a1, 0x8000
and s0, a0, a1
srli s0, s0, 15

bne s0, zero, floor
j ceil

testcase2:

lhu a0, 0(t0)
li a1, 0x8000
and s0, a0, a1
srli s0, s0, 15

bne s0, zero, ceil
j floor

ceil:

li a1, 0x7C00
and s1, a0, a1
srli s1, s1, 10
li a1, 0x03FF
and s2, a0, a1
li s3, -10

# s0: sign bit
# s1: exponent
# s2: the number itself (first digit will be added later due to the special case of subnormal_001 numbers)
# s3: exponent offset
# the fraction number = s2 * 2^s3

li a1, 0
beq s1, a1, subnormal_001
li a1, 0x0000001F
beq s1, a1, infinity_or_nan_001

normal_001:

li a1, 0x00000400
add s2, s2, a1
addi s1, s1, -15
add s3, s3, s1
j display_001

subnormal_001:

addi s3, s3, -14
j display_001

infinity_or_nan_001:

beq s2, zero, display_inf_001

display_nan_001:
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

display_inf_001:
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

display_001:

blt s3, zero, shift_right_001

shift_left_001:
sll s4, s2, s3

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

shift_right_001:
xori s3, s3, -1
addi s3, s3, 1
li a1, 1
sll a1, a1, s3
addi a1, a1, -1
and s5, s2, a1
srl s4, s2, s3
sltu a1, zero, s5
add s4, s4, a1

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

floor:

li a1, 0x7C00
and s1, a0, a1
srli s1, s1, 10
li a1, 0x03FF
and s2, a0, a1
li s3, -10

# s0: sign bit
# s1: exponent
# s2: the number itself (first digit will be added later due to the special case of subnormal_010 numbers)
# s3: exponent offset
# the fraction number = s2 * 2^s3

li a1, 0
beq s1, a1, subnormal_010
li a1, 0x0000001F
beq s1, a1, infinity_or_nan_010

normal_010:

li a1, 0x00000400
add s2, s2, a1
addi s1, s1, -15
add s3, s3, s1
j display_010

subnormal_010:

addi s3, s3, -14
j display_010

infinity_or_nan_010:

beq s2, zero, display_inf_010

display_nan_010:
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

display_inf_010:
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

display_010:

blt s3, zero, shift_right_010

shift_left_010:
sll s4, s2, s3

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

shift_right_010:
xori s3, s3, -1
addi s3, s3, 1
srl s4, s2, s3

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

testcase3:


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

j exit

testcase4:


lb a1, 0(t0)       # read rightmost 8-bit from switch
lb a2, 1(t0)       # read left 8-bit from switch
andi a1, a1, 0x000000ff     # keep the lower 8-bit
andi a2, a2, 0x000000ff     # keep the lower 8-bit

add  a3, a1, a2          # a3 = a1 + a2
srli a4, a3, 8          # get the 9_th bit of sum of a1 and a2
andi  a3, a3, 0x000000ff         # by the way, keep the lower 8-bit of a3
beq  a4, zero, display_100      # if the 9_th bit of sum is 0 then output, otherwise proceed
addi a3, a3, 1      # add 1 to a3
xori a3, a3, -1      # take the reverse of a3

display_100:
andi  a3, a3, 0x000000ff
sw a3, (t1)
sw a3, (t2)

j exit

testcase5:

# a1: rightmost 8-bit data
# a2: 8-bit data in the left

lbu  a1, 0(t0)      # read rightmost 8-bit data from switch
lb   a2, 1(t0)      # read 8-bit data from switch
andi a2, a2, 0x000000FF     # a2: keep lower 8-bit data

# extract the highest bit of the 16-bit data
srli a4, a2, 7              # a4: the highest bit, right shift 7 bits
addi a4, a4, -1
bne  a4, zero, big_endian

little_endian:      # a5 is the output to led and seven_seg_tube
slli a5, a2, 8      # a5: 8-bit data in the left
or   a5, a5, a1     # a5: 16-bit data, little-endian
j    display_101

big_endian:         # a5 is the output to led and seven_seg_tube
slli a5, a1, 8      # a5: 8-bit data in the left
or   a5, a5, a2     # a5: 16-bit data, big-endian
j   display_101

display_101:
li a3, 0x0000FFFF
and a5, a5, a3
sw   a5, 0(t1)      # output to led
sw   a5, 0(t2)      # output to seven_seg_tube

j exit

testcase6:

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

j exit

testcase7:

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
jal ra, sleep

j exit

exit:
