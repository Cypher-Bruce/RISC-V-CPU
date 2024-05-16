#场景1-001
.text
	#read int 用lw？
	#print int 用sw？
	#假设I/O的基地址存储在t0和t1，memory的基地址在t2?
	lb a1, 0(t0) #用lb的方式把a存入a1
	sw a1, 0(t1) #输出
	sw a1, 0(t2) #存到memory中
