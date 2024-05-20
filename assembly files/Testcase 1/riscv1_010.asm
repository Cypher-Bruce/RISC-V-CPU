# test case 1-2
# input an 8-bit integer b and store it in a7
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

load_loop:
lw a3, (t0)
lw a4, (t6)
andi a4, a4, 1
sw a3, (t1)
beq a4, zero, load_loop

lb a4, 0(t0)
mv a7, a4
