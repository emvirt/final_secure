# 1 "crt0-safeg.S"
# 1 "/home/cylee/alps/final/kernel/secure/monitor/safeg//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "crt0-safeg.S"
# 39 "crt0-safeg.S"
# 1 "arm.h" 1
# 180 "arm.h"
.macro CP15_CONTROL_WRITE treg
  mcr p15, 0, \treg, c1, c0, 0
.endm
.macro CP15_CONTROL_READ treg
  mrc p15, 0, \treg, c1, c0, 0
.endm
.macro CP15_SCR_WRITE treg
  mcr p15, 0, \treg, c1, c1, 0
.endm
.macro CP15_SCR_READ treg
  mrc p15, 0, \treg, c1, c1, 0
.endm
.macro CP15_NSACR_WRITE treg
  mcr p15, 0, \treg, c1, c1, 2
.endm
.macro CP15_VBAR_READ treg
  mrc p15, 0, \treg, c12, c0, 0
.endm
.macro CP15_VBAR_WRITE treg
  mcr p15, 0, \treg, c12, c0, 0
.endm
.macro CP15_MVBAR_WRITE treg
  mcr p15, 0, \treg, c12, c0, 1
.endm
.macro CP15_Flush_BTAC treg
  mov \treg, #0
  mcr p15, 0, \treg, c7, c5, 6
.endm
# 40 "crt0-safeg.S" 2
    .text
    .balign 2
    .globl _start

_start:

    cps #0b10110
    mov r0, #0b0000010 | 0b0000100 | 0b0010000 | 0b0100000
    CP15_SCR_WRITE r0


_setup_mmu:
    ldr r4, =pgdir_start
    ldr r4, [r4]
    sub r3, r4, #16384 @ Page directory size
    bic r3, r3, #0xff @ Align the pointer
    bic r3, r3, #0x3f00






@ clear pagetable region
    mov r0, r3
    mov r9, r0, lsr #18
    mov r9, r9, lsl #18 @ start of RAM
    add r10, r9, #0x10000000 @ a reasonable RAM size
    ldr r2, =mmu_flags
    ldr r2, [r2]
    add r1, r3, #16384

1:
    str r2, [r0], #4 @ 1:1 mapping
    add r2, r2, #1048576
    teq r0, r1
    bne 1b







    ldr r2, =mmu_flags
    ldr r2, [r2]
    mov r1, pc
    mov r1, r1, lsr #20
    orr r2, r2, r1, lsl #20
    add r0, r3, r1, lsl #2
    str r2, [r0], #4
    add r2, r2, #1048576
    str r2, [r0]


    ldr r0, =vaddr_start
    ldr r0, [r0]
    mov r0, r0, lsr #20
    add r0, r3, r0, lsl #2
    ldr r2, =mmu_flags
    ldr r2, [r2]
    mov r1, pc, lsr #20
    orr r2, r2, r1, lsl #20
    str r2, [r0]


__turn_mmu_on:
    mov r0, #0
    mcr p15, 0, r0, c7, c10, 4 @ drain write buffer
    mcr p15, 0, r0, c8, c7, 0 @ i,d,tlb flush

    mrc p15, 0, r0, c1, c0, 0 @ read control reg
    orr r0, r0, #1 @ mmu enabled
    bic r0, r0, #2

    mov r2, #21
    mcr p15, 0, r2, c3, c0, 0 @ load domain access control
    mcr p15, 0, r3, c2, c0, 0 @ load page table pointer
    mcr p15, 0, r0, c1, c0, 0 @ write control reg
    mrc p15, 0, r4, c0, c0 @ read id reg

    ldr sp, =_smm_stack_0
    ldr sp, [sp]
# 163 "crt0-safeg.S"
start_5:
    ldr r0, =software_init_hook
    cmp r0, #0x00
    movne lr, pc
    movne pc, r0




start_6:
    bl arm_main
l_end:
    b l_end

pgdir_start:
.word 0x10008000
vaddr_start:
.word 0xf1f00000
mmu_flags:
.word 0x00011c0e
