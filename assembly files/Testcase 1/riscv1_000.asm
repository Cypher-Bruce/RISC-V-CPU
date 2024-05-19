#test case 1-0
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

lbu a1, 2(t0) # 读取led[23:16]到a1, 即是8bit的a
lbu a2, 0(t0) # 读取led[7:0]到a2, 即是8bit的b
slli a1, a1, 16
add a1, a1, a2
sw a1, 0(t1) # 写到led中，a在左，b在右，中间空了8格
