#场景1-010
.text
	#read int 用lw？
	#print int 用sw？
	#假设I/O的基地址存储在t0和t1，memory的基地址在t2?
	lbu a1, 4(t0) #用lbu的方式把b存入a1
	sw a1, 4(t1) #输出
	sw a1, 4(t2) #存到memory中
	
