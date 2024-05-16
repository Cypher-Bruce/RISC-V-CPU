#场景1-001
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

lb a1, 2(t0)
sw a1, 0(t2) # 后续需要二进制转十六进制，显示在数码管或VGA上
addi sp, sp, -8
sw a1, 0(sp) # 暂存在data memory的stack-8上
addi sp, sp, 8 # 恢复地址

