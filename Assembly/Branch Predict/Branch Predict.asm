.data
.text

li t1 0x00000080
li a0, 0

loop:
addi a0, a0, 1
add a1, a0, a0
add a1, a1, a1
add a1, a1, a1
bne a1, t1, loop

li a1, 1
li a2, 1
