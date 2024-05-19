#场景1-110
.data 
   led:    .half 0xFFC0  
   switch: .half 0xFFC4
   tube: .half 0xCFCC
   memory: .half 0xCCCC
   
.text
lh t0, switch #t0 :address of switch
lh t1, led # t1: address of led
lh t2, tube # t2: address of tube segment 数码管地址
lh t3, memory # t3: address of memory
   
.text
lh t0, switch #t0 :address of switch
lh t1, led # t1: address of led
lh t2, tube # t2: address of tube segment 数码管地址
lh t3, memory # t3: address of memory

	addi sp, sp, -8
	lw a1, 0(sp) # 从用例001中（暂存在了sp-8）取出a存到寄存器a1
	lw a2, 4(sp) # 从用例010中（暂存在了sp-4）取出b存到寄存器a2
	addi sp, sp, 8 # 恢复stack pointer
	bltu a1, a2, lit
	li a0，0
	sw a0, 0(t1) # 把24位全0传进去，熄灭所有led灯
	jal exit #关系不成立，什么都不做
lit:
	#led灯的基地址为t1
	li a0, 0xffffff
	sw a0, 0(t1) #把24位全1(0xffffff)传进去，点亮所有led灯
exit: