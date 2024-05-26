# SITUATION 2: test 111, fibonacci
.text

li a7, 5
ecall
mv s0, a0

li a7, 5
ecall
mv s1, a0
andi s1, s1, 0x00000003
li s2, 0 

loop:

mv  a0, s2
jal ra, fibonacci 
bge a1, s0, break
addi s2, s2, 1
j loop

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

li a7, 34
ecall

jal linebreak

lw ra, 0(sp)
addi sp, sp, 4
jr ra

linebreak:
addi sp, sp, -4
sw a0, (sp)
li a0, 0x0A
li a7, 11
ecall
lw a0, (sp)
addi sp, sp, 4
jr ra

break:

mv a0, s2
li a7, 34
ecall

li a7, 10
ecall
