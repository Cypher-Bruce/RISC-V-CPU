# full test case 1
.data 
	switch: .word 0x11fc0
	button: .word 0x11fc4
	push_flag: .word 0x11fc8
	release_flag: .word 0x11fcc
	led: .word 0x11fe0
	seven_seg_tube: .word 0x11fe4
	minus_sign_flag: .word 0x11fe8
	dot_flag: .word 0x11fec
	show_non_flag: .word 0x11ff0
   
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
li a3, 0x000000FF
sw a3, (t5)

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

lw a0, (t0)
sw a0, (t1)

lb a1, 0(t0)
lb a2, 1(t0)

li a3, 0x000000FF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

li a3, 0xA000B000
add a4, a4, a3

li a3, 0x00000044
sw a3, (t5)

sw a4, (t2)

j exit

testcase1:

li a3, 0x000000A0
sw a3, (t3)

li a3, 0x00000010
sw a3, (t5)

li a3, 0x0000FFFF
mv a4, a6
and a4, a4, a3
li a3, 0x0A000000
add a4, a4, a3
sw a4, (t2)

lw a3, (t0)
lw a4, (t6)
andi a4, a4, 1
sw a3, (t1)
beq a4, zero, exit

lb a4, 1(t0)
mv a6, a4

j exit

testcase2: 

li a3, 0x000000A0
sw a3, (t3)

li a3, 0x00000010
sw a3, (t5)

li a3, 0x0000FFFF
mv a4, a7
and a4, a4, a3
li a3, 0x0B000000
add a4, a4, a3
sw a4, (t2)

lw a3, (t0)
lw a4, (t6)
andi a4, a4, 1
sw a3, (t1)
beq a4, zero, exit

lbu a4, 0(t0)
mv a7, a4

j exit

testcase3:

mv a1, a7
mv a2, a6

li a3, 0x000000FF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

li a3, 0xA000B000
add a4, a4, a3

li a3, 0x00000044
sw a3, (t5)

sw a4, (t2)

beq a6, a7, led_light_up
sw zero, (t1)
j led_light_off

testcase4:

mv a1, a7
mv a2, a6

li a3, 0x000000FF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

li a3, 0xA000B000
add a4, a4, a3

li a3, 0x00000044
sw a3, (t5)

sw a4, (t2)

blt a6, a7, led_light_up
sw zero, (t1)
j led_light_off

testcase5:

mv a1, a7
mv a2, a6

li a3, 0x000000FF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

li a3, 0xA000B000
add a4, a4, a3

li a3, 0x00000044
sw a3, (t5)

sw a4, (t2)

bge a6, a7, led_light_up
sw zero, (t1)
j led_light_off

testcase6:

mv a1, a7
mv a2, a6

li a3, 0x000000FF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

li a3, 0xA000B000
add a4, a4, a3

li a3, 0x00000044
sw a3, (t5)

sw a4, (t2)

bltu a6, a7, led_light_up
sw zero, (t1)
j led_light_off

testcase7:

mv a1, a7
mv a2, a6

li a3, 0x000000FF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

li a3, 0xA000B000
add a4, a4, a3

li a3, 0x00000044
sw a3, (t5)

sw a4, (t2)

bgeu a6, a7, led_light_up
sw zero, (t1)
j led_light_off

led_light_up:
lw a4, (t0)
li a3, 0xFFFF0000
and a4, a4, a3
li a3, 0x0000FFFF
add a4, a4, a3
sw a4, (t1)

j exit

led_light_off:
lw a4, (t0)
li a3, 0xFFFF0000
and a4, a4, a3
sw a4, (t1)

j exit

exit:






