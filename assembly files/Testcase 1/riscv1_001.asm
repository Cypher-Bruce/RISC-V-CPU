# test case 1-0
# input an 8-bit integer a and store it in a6
.data 
	switch: .word 0x11fc0
	button: .word 0x11fc4
	led: .word 0x11fc8
	seven_seg_tube: .word 0x11fcc
	minus_sign_flag: .word 0x11fd0
	dot_flag: .word 0x11fd4
	show_non_flag: .word 0x11fd8
   
.text
lw t0, switch
lw t1, led
lw t2, seven_seg_tube
lw t3, minus_sign_flag
lw t4, dot_flag
lw t5, show_non_flag
lw t6, button

lw a0, (t0)
lb a1, 1(t0)
lb a2, 2(t0)

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

load_loop:
lw a3, (t0)
lw a4, (t6)
andi a4, a4, 1
sw a3, (t1)
beq a4, zero, load_loop

lb a4, 1(t0)
mv a6, a4
