# test case 1-0
# input two 8-bit number a and b through switch and display their value in seven seg tube
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

lw a0, (t0)
lb a1, 0(t0)
lb a2, 1(t0)

li a3, 0x0000FFFF
and a1, a1, a3
and a2, a2, a3
slli a2, a2, 16
or a4, a1, a2

sw a4, (t2)
sw a0, (t1)
