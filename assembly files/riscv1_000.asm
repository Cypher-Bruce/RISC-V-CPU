#场景1-000
.text
	#read int 用lw？
	#print int 用sw？
	#假设I/O的基地址存储在t0和t1，memory的基地址在t2?
	lw a1, 0(t0)
	lw a2, 4(t0)
	sw a1, 0(t1)
	sw a2, 4(t1)
