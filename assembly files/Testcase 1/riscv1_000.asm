#test case 1-0
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

lbu a1, 2(t0) # ��ȡled[23:16]��a1, ����8bit��a
lbu a2, 0(t0) # ��ȡled[7:0]��a2, ����8bit��b
slli a1, a1, 16
add a1, a1, a2
sw a1, 0(t1) # д��led�У�a����b���ң��м����8��
