#场景1-100
.text
	#read int 用lw？
	#print int 用sw？
	#假设I/O的基地址存储在t0和t1，memory的基地址在t2?
	lw a1, 0(t2) #从用例001中取出a存到寄存器a1
	lw a2, 4(t2) #从用例010中取出b存到寄存器a2
	blt a1, a2, led
	jal exit #关系不成立，什么都不做
led:
	#假设led灯亮的控制信号所在的基地址是s0
	li a0, 1
	sw a0, 0(s0) #把1传进去，点亮第一个led灯（在基地址的led）
exit:
	