# PIPELINE SITUATION: hazard
.data
    switch:         .word 0x11fc0
    button:         .word 0x11fc4
    push_flag:      .word 0x11fc8
    release_flag:   .word 0x11fcc
    led:            .word 0x11fe0
    seven_seg_tube: .word 0x11fe4
    minus_sign_flag:.word 0x11fe8
    dot_flag:       .word 0x11fec
    show_non_flag:  .word 0x11ff0
    advance_mode:   .word 0x11ff4
    adv_left:       .word 0x11ff8
    adv_right:      .word 0x11ffc

.text
lw t0, switch
lw t1, led
lw t2, seven_seg_tube
lw t3, minus_sign_flag
lw t4, dot_flag
lw t5, show_non_flag
lw t6, push_flag

lbu a1, 0(t0)
# SITUATION 2:
add a1, a1, a1 # load-use hazard --> MEM-ALU Forwarding
# SITUATION 1:
add a1, a1, a1 # ALU-ALU Forwarding
# SITUATION 3:
add a1, a1, a1 # Two Reg-Reg hazards --> ALU-ALU Forwarding
sw a1, 0(t1)
sw a1, 0(t2)

