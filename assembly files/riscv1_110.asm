#����1-110
.data 
   led:    .half 0xFFC0  
   switch: .half 0xFFC4
   tube: .half 0xCFCC
   memory: .half 0xCCCC
   
.text
lh t0, switch #t0 :address of switch
lh t1, led # t1: address of led
lh t2, tube # t2: address of tube segment ����ܵ�ַ
lh t3, memory # t3: address of memory
   
.text
lh t0, switch #t0 :address of switch
lh t1, led # t1: address of led
lh t2, tube # t2: address of tube segment ����ܵ�ַ
lh t3, memory # t3: address of memory

	addi sp, sp, -8
	lw a1, 0(sp) # ������001�У��ݴ�����sp-8��ȡ��a�浽�Ĵ���a1
	lw a2, 4(sp) # ������010�У��ݴ�����sp-4��ȡ��b�浽�Ĵ���a2
	addi sp, sp, 8 # �ָ�stack pointer
	bltu a1, a2, lit
	li a0��0
	sw a0, 0(t1) # ��24λȫ0����ȥ��Ϩ������led��
	jal exit #��ϵ��������ʲô������
lit:
	#led�ƵĻ���ַΪt1
	li a0, 0xffffff
	sw a0, 0(t1) #��24λȫ1(0xffffff)����ȥ����������led��
exit: