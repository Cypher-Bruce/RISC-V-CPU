.macro print_string(%str)
	.data 
		pstr:   .asciz   %str
	.text
		la a0,pstr
		li a7,4
		ecall
.end_macro

.macro end
	li a7,10
	ecall
.end_macro

#Add the content to 
#“macro_print_str.asm”
.macro print_float(%fr)
	addi sp, sp, -8 
	fsw fa0, 4(sp) 
	sw a7, 0(sp)
	
	fmv.s fa0, %fr
	li a7, 2
	ecall
	
	lw a7, 0(sp)
	flw fa0, 4(sp)
	addi sp, sp, 8
.end_macro
