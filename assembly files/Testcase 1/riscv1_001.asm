#����1-001
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

lb a1, 2(t0)
sw a1, 0(t2) # ������Ҫ������תʮ�����ƣ���ʾ������ܻ�VGA��
addi sp, sp, -8
sw a1, 0(sp) # �ݴ���data memory��stack-8��
addi sp, sp, 8 # �ָ���ַ

