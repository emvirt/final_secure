/*
 *  TOPPERS/SafeG Dual-OS monitor
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Safety Gate Dual-OS monitor
 *
 *  Copyright (C) 2009-2011 by Embedded and Real-Time Systems Laboratory
 *     Graduate School of Information Science, Nagoya University, JAPAN
 *
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 */
#include "arm.h"
#include "entry.h"
#include "safeg_syscalls.h"
#include "safeg_measures.h"

/*
 * -----------------
 * Workspace Offsets
 * -----------------
 * Offsets within the workspace
 */

/*
 * Offset to first banked registers from sp_mon.
 * Calculated using the N World Workspace but values are the same for S World.
 */
#define BankedOffset    (N_IRQ_SPSR_CORE0 - NtContextBase0)

/*
 * Support 4 Cores
 */
#ifdef SAFEG_KZMCA9
#define SUPPORT_4CORES 
#endif

/*4Byte Move Macro*/
.macro mov32, reg, val
        movw    \reg, #:lower16:\val
        movt    \reg, #:upper16:\val
.endm

/*4Byte Moveeq Macro*/
.macro mov32eq, reg, val
        movweq    \reg, #:lower16:\val
        movteq    \reg, #:upper16:\val
.endm

/*4Byte Moveeq Macro*/
.macro mov32ne, reg, val
        movwne    \reg, #:lower16:\val
        movtne    \reg, #:upper16:\val
.endm


.macro  cpu_id, rd
        mrc     p15, 0, \rd, c0, c0, 5
        and     \rd, \rd, #0xF
.endm

/*
 * --------------------
 * Workspace Constants
 * --------------------
 */

#define WORKSPACE_RESET_VALUE   0x0

/*
 * Interrupt Related Constants
 */
#define HIGHVEC_IRQADR        0xffff0018

/*
 * NORMAL_CPSR_INIT_VALUE
 */
#define NORMAL_CPSR_INIT_VALUE CPSR_BIT_8_A | CPSR_BIT_7_I | CPSR_BIT_6_F | CPSR_MODE_SVC

/*
 * NORMAL CP15 CTRL レジスタのリセット時の値
 */
#define NORMAL_CP15_CTRL_INIT_VALUE 0x50078

/*
 * ----------------
 * MACRO: SaveState
 * ----------------
 * Saves registers to the workspace sp points into.
 * Corrupts r6, r7, r12
 * Trust状態(SCRのNSビットが0)で呼びだすこと.
 *
 * ToDo : 引数でコア指定ができるようにする
 */
    .macro SaveState
        stmdb   sp, {r0-lr}^
        add     r6, sp, #BankedOffset
        cps     #CPSR_MODE_IRQ
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_SVC
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_ABORT
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_UNDEF
        mrs     r12, spsr
        stmia   r6!, {r12-lr}
        cps     #CPSR_MODE_FIQ
        mrs     r7, spsr
        stmia   r6, {r7-lr}
        cps     #CPSR_MODE_MONITOR
    .endm

/*
 * ----------------
 * MACRO: LoadState
 * ----------------
 * SPは呼び出したいコンテキストの場所を指していること.
 * Trust状態(SCRのNSビットが0)で呼びだすこと.
 * 終了後はモニタモードになっており, レジスタには各コンテキストの内容が復帰しているため,
 * LR_mon, SP_monのみ使用可能.
 *
 * ToDo : 引数でコア指定ができるようにする
 */

    .macro LoadState
        add     r6, sp, #BankedOffset
        cps     #CPSR_MODE_IRQ
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_SVC
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_ABORT
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_UNDEF
        ldmia   r6!, {r12-lr}
        msr     spsr_fsxc, r12
        cps     #CPSR_MODE_FIQ
        ldmia   r6, {r7-lr}
        msr     spsr_fsxc, r7
        cps     #CPSR_MODE_MONITOR
        ldmdb   sp, {r0-lr}^
    .endm

    // マクロ GetCtBase :
    //        自プロセッサのコンテキストエリアアドレスを取得する
    //        sp <= [Address of ContextAreaBase]
    //        SaveStateの前に、
    .macro GetCtBase table
	cpu_id sp		

        cmp sp, #0
        ldreq sp, =_smm_stack_0
        cmp sp, #1
        ldreq sp, =_smm_stack_1
        cmp sp, #2
        ldreq sp, =_smm_stack_2
        cmp sp, #3
        ldreq sp, =_smm_stack_3

        add sp, sp, #0x72000000		/*HJPARK: convert stack Physical Address to Virtual Address*/
        ldr sp, [sp]
        add sp, sp, #0x72000000
        sub sp, sp, #4 

        stmfd sp!, {r0, r1} /* r0, r1を保存 */

        // 自プロセッサのコンテキストベースアドレスを取得
        mrc p15, 0, r0, c0, c0, 5 /* プロセッサIDの取得 */
        and r0, r0, #0x0f /* 下位4bitのみ有効(r0 <= cpu_id) */
        ldr r1, =\table
  	add r1, r1, #0x72000000		//HJPARK
        ldr r0, [r1, r0, asl #2] /* r0 <= table[cpu_id] */
        str r0, [sp, #8] /* r0,r1の下にContextBaseのアドレスを入れる */
        ldmfd sp!, {r0, r1} /* r0, r1を復帰 */
        ldr sp, [sp]
	add sp, sp, #0x72000000		//HJPARK
    .endm

    
/*
 * ----------------------------------------------------------------------------
 * ===============
 * モニタベクタ
 * ===============
 *
 * tableを作成して, ベクタは0番地に配置する
 */
    .section .vector, "a"
    .align 5
    .globl MonitorVectorTableBase
MonitorVectorTableBase:
    ldr pc, reset_vector       /* リセット             */
    ldr pc, undef_vector       /* 未定義命令           */
    ldr pc, smc_vector         /* SMC                  */
    ldr pc, prefech_vector     /* プリフェッチアボート */
    ldr pc, data_abort_vector  /* データアボート       */
    ldr pc, reset_vector       /* 予約                 */
    ldr pc, irq_vector         /* IRQ                  */
    ldr pc, fiq_vector         /* FIQ                  */

/*
 *  例外ベクタの命令から参照される
 *  ジャンプ先アドレス
 */
    .global monitor_vector_ref_tbl
monitor_vector_ref_tbl:
reset_vector:
    .long   disaster + 0x72000000		/*HJPARK: convert interrupt handler's physical address to virtual address*/
undef_vector:
    .long   disaster + 0x72000000
smc_vector:
    .long   smc_handler + 0x72000000
prefech_vector:
    .long   disaster + 0x72000000
data_abort_vector:
    .long   data_abort_handler + 0x72000000
irq_vector:
    .long   irq_handler + 0x72000000
fiq_vector:
    .long   fiq_handler + 0x72000000
disaster: //error handling 
    b   disaster

/*
 *-----------------------------------------------------------------------------
 * ===========
 * IRQ Handler
 *
 * IRQはNon Trusted側からしか来ないと仮定している
 * モニタモード, IRQ/FIQ禁止で呼び出される.
 * IRQ の処理をしている間にFIQやSMCが入ることがあるので,
 * IRQ 用のスタックだけは別にする.
 *
 * H ┌──────────┐offset
 *   │ジャンプ先 │+0x14 _smm_stack
 *   │ip        │+0x10
 *   │r3        │+0x0c
 *   │r2        │+0x08
 *   │r1        │+0x04
 * sp│r0        │+0x00
 * L └──────────┘
 * ===========
 */
    .text
    .align 5
    .global irq_handler
irq_handler:
    /* 発生元のワールドを判断し, Trustから来たときの対応をここでする */
    CP15_SCR_READ sp
    tst sp, #SCR_BIT_0_NS
    beq trusted_irq                 // trustからの場合, trusted_irqへジャンプ

    /* スタックを切り替えて, コンテキストを保存する.
     * fdでそのまま積んでもプリデクリメントのため一番上は空く.
     */
    cpu_id sp

    cmp sp, #0
    ldreq sp, =_smm_stack_0
    cmp sp, #1
    ldreq sp, =_smm_stack_1
    cmp sp, #2
    ldreq sp, =_smm_stack_2
    cmp sp, #3
    ldreq sp, =_smm_stack_3

    add sp, sp, #0x72000000   	/*HJPARK: convert stack physical address to virtual address*/ 
    ldr sp, [sp]
    add sp, sp, #0x72000000

    stmfd sp!, {r0-r1}

#if (SAFEG_MEASURE_IRQ_OVH == 1) || (LINUX_MEASURE_TIMER_LAT == 1)
    perfmon_start r0
#endif /* SAFEG_MEASURE_IRQ_OVH */

    /*
     * NT側のベクタテーブルの読み出し.
     * SCRのNSビットが1の状態で読み出す必要がある.
     * (NT側のMMUを利用したいため).
     */
    CP15_CONTROL_READ r0
    tst r0, #CP15_CONTROL_V_BIT

    /* high vector の場合は r0 に HIGHVEC_IRQ を読み込む */ 
    ldrne r0, =HIGHVEC_IRQADR
    bne highvec

    /* high vector でない場合 */
    CP15_VBAR_READ r0                // check non-secure irq vector address
    add r0, r0, #0x18                // IRQベクタのアドレスは vectorbase + 0x18

highvec:
    /*
     * ここまではNSで実行する必要がある.
     * SCRのNSビットを0にしておく.
     * (モード切替を行うため). 
     */
    mov r1, #SCR_S
    CP15_SCR_WRITE r1

    /*
     * このハンドラが終わった後にジャンプする実際のベクタアドレスを保存.
     * 保存するレジスタ群が変わるとオフセットが変わるので注意すること.
     *
     * Note: the stack after "stmfd sp!, {r0-r1}" is like this:
     *
     *                                 +------------------+ high address
     * _smm_stack = old_sp = sp + 8 -> |      xxx         |
     *                       sp + 4 -> |      r1          |     ↓
     *                       sp + 0 -> |      r0          |
     *                                 +------------------+ low address
     *
     * The xxx space is there because we used "!" which increments the
     * stack pointer before. Now we will do: xxx = r0 = irq handler address
     */
    str r0, [sp, #8]

    /*
     * NT側の割込みハンドラを改変せずに済むように,
     * lr_mon, spsr_mon を lr_irq, spsr_irq に移す
     */
    mov r0, lr                       //[r0] = lr_mon
    mrs r1, spsr                     //[r1] = spsr_mon
    cps #CPSR_MODE_IRQ
    mov lr, r0                       // lr_irq = lr_mon
    msr spsr_cxsf, r1                // spsr_irq = spsr_mon
    cps #CPSR_MODE_MONITOR

    /* NT 側の IRQ ベクタを呼び出すための準備 */
    mov r1, #SCR_NS
    CP15_SCR_WRITE r1

    /* spsr が IRQ モードとなるような設定をする */
    mov r0, #(CPSR_MODE_IRQ | CPSR_BIT_7_I)
    msr spsr_fsxc, r0

#ifdef ENABLE_IRQ_MANAGEMENT
    stmfd sp!, {r2-r3, ip}
    bl irq_management
    ldmfd sp!, {r2-r3, ip}
#endif

#if SAFEG_MEASURE_IRQ_OVH == 1
    stmfd sp!, {r2}
    perfmon_end r0, r1, r2
    ldmfd sp!, {r2}
#endif /* SAFEG_MEASURE_IRQ_OVH */

    /* NT 側の IRQ ベクタにジャンプ */
    ldmfd sp!, {r0-r1, pc}^

   /*
    * trusted_irq の場合の処理を行う.
    * 独自に処理を行いたい場合には, trusted_irq_handler に定義する.
    */
trusted_irq:
    ldr r0, =trusted_irq_handler
    ldr r0, [r0]
    cmp r0, #0
    movne pc, r0
    b   disaster

/*
 *-----------------------------------------------------------------------------
 * ===========
 * FIQ handler
 * ===========
 */
    .text
    .align 5
    .global fiq_handler
fiq_handler:
    cpu_id sp
    cmp sp, #1
    beq t_smc_wfi		/*HJPARK: FIQ from core1*/

    CP15_SCR_READ sp
    tst sp, #SCR_BIT_0_NS
    bne non_trusted_fiq

    /* secureから来た場合 */
trusted_fiq:
    cpu_id sp
    cmp sp, #0
    ldreq sp, =_smm_stack_0
    cmp sp, #1
    ldreq sp, =_smm_stack_1
    add sp, sp, #0x72000000	/*HJPARK: convert stack physical address to virtual address*/
    ldr sp, [sp]
    add sp, sp, #0x72000000

    stmfd sp!, {r0,r1,r2}

    /*HJPARK: check nested FIQ*/
    mrs r0, spsr
    and r1, r0, #0x0f
    cmp r1, #0			/*HJPARK: exception from usr*/
    beq 1f
    cmp r1, #3          	/*HJPARK: exception from svc*/
    beq 2f  
    orr r0, r0, #CPSR_BIT_6_F
    orr r0, r0, #CPSR_BIT_7_I
    msr spsr, r0

    ldmia sp!, {r0,r1,r2}
    sub lr, lr, #4
    movs pc, lr

    /*HJPARK: check exception from SWI handler*/ 
2:
    mov r1, lr
    ldr r2, =0xffff000c		/*HJPARK: SWI vector address + 0x4*/
    cmp r2, r1
    bne 2f
    orr r0, r0, #CPSR_BIT_6_F
    orr r0, r0, #CPSR_BIT_7_I
    msr spsr, r0
    ldmia sp!, {r0,r1,r2}
    sub lr, lr, #4
    movs pc, lr

2:
    ldr r2, =0x8003ff84		/*HJPARK: Linux 'vector_swi' address + 0x4*/
    cmp r2, r1
    bne 1f
    orr r0, r0, #CPSR_BIT_6_F
    orr r0, r0, #CPSR_BIT_7_I
    msr spsr, r0
    ldmia sp!, {r0,r1,r2}
    sub lr, lr, #4
    movs pc, lr
   
1:
    ldmia sp!, {r0,r1,r2}

    stmfd sp!, {r0-r1}

#if SAFEG_MEASURE_FIQ_FIQ == 1
    perfmon_start r0
#endif /* SAFEG_MEASURE_FIQ_FIQ */
    /*
     * T側の割込みハンドラを改変せずに済むように,
     * lr_mon, spsr_mon を lr_irq, spsr_irq に移す
     */
    mov r0, lr
    mrs r1, spsr
    cps #CPSR_MODE_IRQ
    mov lr, r0
    msr spsr_fsxc, r1
    cps #CPSR_MODE_MONITOR

#ifdef ENABLE_FIQ_MANAGEMENT
    stmfd sp!, {r2-r3, ip}
    bl fiq_management
    ldmfd sp!, {r2-r3, ip}
#endif

    ldmfd sp!, {r0-r1}

    b fiq_exit

    /* non-secureから来た場合 */
non_trusted_fiq:
    /* SaveStateの前にSCRをsecureに変更 */
    mov sp, #SCR_S
    CP15_SCR_WRITE sp
    /* 割込みで入ってきたので, 戻り先アドレスはLRから4減らした値になる */
    sub lr, lr, #4
    /* save non-trust pc and spsr to monitor stack */
#ifdef SAFEG_KZMCA9
    /* sp <= nt_base_table[cpu id] */
    GetCtBase nt_base_table
#else
    ldr sp, =NtContextBase0
#endif /* SAFEG_KZMCA9 */

    srsia #CPSR_MODE_MONITOR
    /* save the rest of non-trust registers */
    SaveState
    /*
     * LoadState をする前にIRQモードの内容も入れ替わるので書き換え前に行う.
     * LoadState で復帰されるコンテキストは, 前回の SMC 実行時に保存されたもの
     * であるため, IRQハンドラで使用するために事前に 4 を足しておく.
     * Trust側でIRQハンドラが終わった後に返るための SPSR_irq, LR_irq を
     * IRQモードに設定しておく.
     */
#ifdef SAFEG_KZMCA9
    /* sp <= t_base_table[cpu_id] */    
    GetCtBase t_base_table
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */

    ldmfd sp, {r0, r1} // 前回SMCを呼び出した時点の pc, cpsr.
    add r0, r0, #4
    str r1, [sp, #0xc]
    str r0, [sp, #0x14]
    LoadState
    /* Prepare stack to store CPSR and PC before returning with rfeia*/
    ldr sp, =_smm_stack_0
    add sp, sp, #0x72000000
    ldr sp, [sp]
    add sp, sp, #0x72000000

#ifdef ENABLE_FIQ_MANAGEMENT
    stmfd sp!, {r0-r3, ip}
    bl fiq_management
    ldmfd sp!, {r0-r3, ip}
#endif

/*
 * secureに必ず抜けるので、ここにはSCRはsecureでくる.
 * rfeiaで戻るためにスタックにCPSRとPCを積む.
 */
fiq_exit:
    /* push CPSR = (IRQ and FIQ disabled) + IRQ mode */
    mov lr, #(CPSR_MODE_IRQ | CPSR_BIT_6_F | CPSR_BIT_7_I)
    str lr, [sp, #-4]!
    /* IRQベクタのアドレスはvectorbase + 0x18 */
    CP15_VBAR_READ lr
    add lr, lr, #0x18
    str lr, [sp, #-4]!
    /* IRQモードに切り替え (load CPSR + PC from stack) T側の IRQベクタにジャンプ */
    rfeia sp

/*
 * ===========
 * SMC handler
 * ===========
 */
    .text
    .align 5
    .global smc_handler
smc_handler:
    /* check if it is a Trust or Non-Trust SMC (NS bit) */
    CP15_SCR_READ sp
    tst sp, #SCR_BIT_0_NS

    /* if is Non-Trust SMC jump to nt_smc_handler */
    bne nt_smc_handler

t_smc_handler:
    /* cylee : send tzipc ipi from secure world */
    cmp r0, #NT_SMC_TZIPC
    beq nt_smc_tzipc

    /* otherwise its a Trust SMC so first we save the Trust context */
#ifdef SAFEG_KZMCA9
    /* sp <= t_base_table[cpu_id] */
    GetCtBase t_base_table
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    srsia   #CPSR_MODE_MONITOR  // [sp_mon] = lr_mon, [sp_mon, #4] = spsr_mon
    SaveState                   // S-Context = Context

    /* r0 has the syscall, branch to the appropriate SMC handler */
    cmp r0, #T_SMC_REBOOT
    beq t_smc_reboot

t_smc_switch:
/*HJPARK: world switch, secure to normal*/ 
#ifdef SAFEG_KZMCA9
    /* sp <= t_base_table[cpu_id] */
    GetCtBase t_base_table
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    srsia   #CPSR_MODE_MONITOR  // [sp_mon] = lr_mon, [sp_mon, #4] = spsr_mon
    SaveState                   // S-Context = Context

t_smc_set:
/*HJPARK: set core1 interrupt*/
    /*HJPARK: set CSU register*/
    ldr r1, =0xf41c0020		//USB
    ldr r0, =0x00bb00bb
    str r0, [r1]
    add r1, r1, #4		//uSDHC1
    str r0, [r1]
    add r1, r1, #4    		//uSDHC3
    ldr r0, =0x003f00bb
    str r0, [r1]
    ldr r1, =0xf41c006c		//HDMI
    ldr r0, =0x003300bb
    str r0, [r1]
    add r1, r1, #4		//GPU3D
    ldr r0, =0x00bb003f
    str r0, [r1]    

/*HJPARK: set GIC register*/
    /*ICDISR initialize SPI interrupt as IRQ*/
    ldr r1, =0xf2a01084
    ldr r2, =0xf2a01094
    ldr r0, =0xffffffff
1:  str r0, [r1]
    add r1, r1, #0x4
    cmp r1, r2
    bne 1b

    /*ICDISR set secure world dedicated interrupts as FIQ*/
    ldr r1, =0xf2a01084
    ldr r0, =0xdefffdff		//UART4 61 uSDHC3 56 GPU3D 41
    str r0, [r1]
    add r1, r1, #8
    ldr r0, =0xfff3ffff		//HDMI 146,147
    str r0, [r1]

    /*ICDDCR enable interrupt to core1 */
    ldr r1, =0xf2a01000
    ldr r0, =0x3
    str r0, [r1]

    /*ICDISER enable normal world dedicated interrupts triggered uart3 uSDHC1 sdma*/
    ldr r1, =0xf2a01104
    ldr r0, =0x10400004		//UART3 60, uSDHC1 54, sdma 34
    str r0, [r1]

    /*ICDICER disable secure world dedicated interrupts triggered uart4 uSDHC3 GPU3D HDMI*/
    ldr r1, =0xf2a01184
    ldr r0, =0x21000200		//UART4 61, uSDHC3 56, GPU3D 41
    str r0, [r1]
    add r1, r1, #8		
    ldr r0, =0xfff3ffff		//HDMI 146,147
    str r0, [r1]

    mov pc, lr

t_smc_wfi_2:
    sub lr, lr, #4
    movs pc, lr

t_smc_wfi:
/*HJPARK: IPI from core0*/
    ldr sp, =0xf2a01200		//check if IPI#8
    ldr sp, [sp]
    tst sp, #0x100
    bne 1f

    tst sp, #0x80		//check if IPI#7
    beq t_smc_wfi_2

/*HJPARK: IPI#7, check the interupt is valid*/
    ldr sp, =_smm_stack_1
    add sp, sp, #0x72000000	/*convert stack physical address to virtual address*/
    ldr sp, [sp]
    add sp, sp, #0x72000000
    push {r0, r1}
    ldr r0, =0xf2a01080		/*ICDISPR set IPI7 as IRQ*/
    ldr r1, =0xfffffffe
    str r1, [r0]
    mrs r0, spsr
    tst r0, #0x80		/*check if IPI7 triggered at IRQ handler*/
    ldm sp!, {r0, r1}

    bne t_smc_wfi_2		/*set core1 WFI if the IPI is invalid*/

    b irq_handler

1:  
/*HJPARK: if IPI is #8, start booting normal world*/
#ifdef SAFEG_KZMCA9
    /* sp <= t_base_table[cpu_id] */
    GetCtBase t_base_table
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    srsia   #CPSR_MODE_MONITOR  // [sp_mon] = lr_mon, [sp_mon, #4] = spsr_mon
    SaveState                   // S-Context = Context

#ifdef SAFEG_KZMCA9
    mrc p15, 0, sp, c0, c0, 5 
    and sp, sp, #0x0f    
    ldr r5, =nt_base_table
    add r5, r5, #0x72000000	/*HJPARK: convert stack physical address to virtual address*/ 
    ldr sp, [r5, sp, asl #2] 
    add sp, sp, #0x72000000   
#else
    ldr sp, =NtContextBase0
#endif   /*SAFEG_KZMCA9*/ 
    /*HJPARK: ICCIAR set IPI8 state active*/
    ldr r0, =0xf2a0010c
    ldr r0, [r0]

    /*HJPARK: ICCEOIR end IPI8 interrupt*/
    ldr r1, =0xf2a00110
    str r0, [r1]

    /*HJPARK: ICDISR set IPI7 as FIQ*/
    ldr r1, =0xf2a01080
    ldr r0, =0xffffff7e
    str r0, [r1]

    /*HJPARK: ICCICR enable core1 to get interrupt*/
    ldr r1, =0xf2a00100
    ldr r0, =0xF
    str r0, [r1]

    bl t_smc_set
    b NTSecondaryBoot

t_smc_switch_exit:
    /* switch to non-trust world */
    rfeia   sp                  // load cpsr and pc from NtContext

t_smc_reboot: /* TODO: Test this! */
    /*
     * r1 にはジャンプ先のアドレスが入っている
     * reset した後の CPSR と PC をNT側コンテキストに設定する
     * r0 を NORMAL_CP15_CTRL_INIT_VALUE のロードに使わないのは,
     * stmea がストアする順序が重要なため.
     */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, r4, c0, c0, 5 /* プロセッサIDの取得 */
    and r4, r4, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =nt_base_table
    ldr r4, [r5, r4, asl #2] /* r4 = nt_base_table[cpu_id] */
#else
    ldr r4, =NtContextBase0
#endif /* SAFEG_KZMCA9 */
    ldr r2, =NORMAL_CPSR_INIT_VALUE
    stmea r4, {r1, r2}

    /* 直接 linux を boot するためのレジスタ設定 */
    mov r1, #0
    mov r2, #0x5e0
    mov r3, #0x100
#ifdef SAFEG_KZMCA9
    mrc p15, 0, r4, c0, c0, 5 /* プロセッサIDの取得 */
    and r4, r4, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =nt_area_table
    ldr r4, [r5, r4, asl #2] /* sp = nt_area_table[cpu_id] */
#else
    ldr r4, =NtContextSavedArea0
#endif /* SAFEG_KZMCA9 */
    stmea r4, {r1-r3}

    /* CP15 CTRL レジスタを操作する前に Non-Secure にしておく必要がある. */
    mov     r2, #SCR_NS
    CP15_SCR_WRITE  r2

    /* MMU と キャッシュをDISABLEにする */
    ldr r1, =NORMAL_CP15_CTRL_INIT_VALUE
    mcr p15, 0, r1, c1, c0, 0

    /* 操作が終わったら Secureに戻す. */
    mov     r2, #SCR_S
    CP15_SCR_WRITE  r2
    b t_smc_switch

t_smc_boot:
/*HJPARK: initialize core1*/
    mrs r0, cpsr
    bic r0, r0, #0xC0
    msr cpsr, r0

    /*HJPARK: ICCICR enable core1 to get interrupts*/
    mov32 r0, 0x00a00100	/*GIC CPU interface register base address*/
    mov r1, #0xF
    str r1, [r0]

    /*HJPARK: ICCPMR set core1 to get only interrupts with higer priority than 0xF0*/
    add r0, r0, #4
    mov r1, #0xF0
    str r1, [r0]

    /*HJPARK: set page table entry to map monitor address space*/ 
    mov32 r0, 0x10004000
    mov32 r1, 0x1ffc
    add r0, r0, r1
    mov32 r2, 0x7ff11c0e
    str r2, [r0]

    mov r0, #0x15
    mcr p15, 0, r0, c3, c0, 0		//domain access control

    mov32 r0, 0x10004000
    mcr p15, 0, r0, c2, c0, 0		//translation table base 0

    mov32 r0, 0x10c53c7d		
    mcr p15, 0, r0, c1, c0, 0           //system control register
    
    mov r0, #0x41
    mcr p15, 0, r0, c1, c0, 1		//auxiliary control

    mov32 r0, 0xff0a81a8
    mcr p15, 0, r0, c10, c2, 0		//primary region remap

    mov32 r0, 0x00f00000
    mcr p15, 0, r0, c1, c0, 2		//coprocessor access control

    mov r0, #0x0
    mcr p15, 0, r0, c7, c5, 0 		//Invalidate I-Cache

    mov     r0, #0
    mcr     p15, 2, r0, c0, c0, 0
    mrc     p15, 1, r0, c0, c0, 0
    ldr     r1, =0x7fff
    and     r2, r1, r0, lsr #13
    ldr     r1, =0x3ff
    and     r3, r1, r0, lsr #3  @ NumWays - 1
    add     r2, r2, #1          @ NumSets
    and     r0, r0, #0x7
    add     r0, r0, #4          @ SetShift
    clz     r1, r3              @ WayShift
    add     r4, r3, #1          @ NumWays
1:  sub     r2, r2, #1          @ NumSets--
    mov     r3, r4              @ Temp = NumWays
2:  subs    r3, r3, #1          @ Temp--
    mov     r5, r3, lsl r1
    mov     r6, r2, lsl r0
    orr     r5, r5, r6          @ Reg = (Temp<<WayShift)|(NumSets<<SetShift)
    mcr     p15, 0, r5, c7, c6, 2
    bgt     2b
    cmp     r2, #0
    bgt     1b

t_smc_boot_2:
    wfi
    b t_smc_boot_2

nt_smc_handler:
    ldr sp, =_smm_stack_1
    add sp, sp, #0x72000000	/*HJPARK: convert stack physical address to virtual address*/
    ldr sp, [sp]
    add sp, sp, #0x72000000

    /* switch to NT (and pass arguments) */
    cmp r0, #NT_SMC_SWITCH
    beq nt_smc_switch
    /* emulate a software interrupt in Trust world */
    cmp r0, #NT_SMC_SOFTIRQ
    addeq lr, lr, #4
    beq non_trusted_fiq
    /* invalidate the cache */
    cmp r0, #NT_SMC_INV_CACHE
    beq nt_smc_cache

    /* cylee: send tzipc ipi from normal world */
    cmp r0, #NT_SMC_TZIPC
    beq nt_smc_tzipc
    /*HJPARK: restor IPI as FIQ*/
    cmp r0, #NT_SMC_SET_IPI
    beq nt_smc_set_ipi
   
    cmp r0, #NT_SMC_IPI
    beq nt_smc_ipi

    /* if SMC number is not supported go back to nt with error (TODO: test) */
    mov r1, #NT_SMC_SWITCH_ERR
    b nt_smc_return_to_nt

nt_smc_switch:
    /* go to secure world, to save NT state in secure memory */
    mov     sp, #SCR_S          // lr_mon = Secure World SCR config
    CP15_SCR_WRITE  sp          // cp15_SCR = lr_mon (S-World Config)

    /* save NT world state */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
    and sp, sp, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */

    ldr sp, =nt_base_table
    ldr sp, [sp]
#else
    ldr sp, =NtContextBase0
#endif /* SAFEG_KZMCA9 */
    srsia #CPSR_MODE_MONITOR

    SaveState                   // N-Context = Context

    /*
     * In S_USR_R1 we have  &ret_args, get it to r6 (SaveState already
     * corrupted r6,r7,r12) and write args (r1-r2) in there
     */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, r6, c0, c0, 5 /* プロセッサIDの取得 */
    and r6, r6, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =t_area_table
    add r5, r5, #0x72000000
    ldr r6, [r5, r6, asl #2] /* sp = t_area_table[cpu_id] */  
    add r6, r6, #0x72000000
#else
    ldr r6, =TContextSavedArea0  // r6 = TContextSavedArea
#endif /* SAFEG_KZMCA9 */
/*  ldr r6, [r6, #4]            // r6 = *(S_USR_R1) = ret_args
    str r1, [r6, #0]            // ret_args->arg0 = r1
    str r2, [r6, #4]            // ret_args->arg1 = r2
*/
    b	nt_smc_switch_exit

nt_smc_ipi:
/*HJPARK: set GIC register and enable secure dedicated interrupts*/
    mov     r0, #SCR_S          // lr_mon = Secure World SCR config
    CP15_SCR_WRITE  r0          // cp15_SCR = lr_mon (S-World Config)

    /*ICDISR set secure dedicated interrupts as FIQ*/
    ldr r0, =0xf2a01084
    ldr sp, =0xdefff01f		//UART4 61 uSDHC3 56 GPU3D 41 IPU 40-37
    str sp, [r0]

    /*ICDISER enable secure dedicated interrupts*/
    ldr r0, =0xf2a01104
    ldr sp, =0x21000fe0		//UART 61 uSDHC3 56 GPU3D 41 IPU 40-37
    str sp, [r0]
    add r0, r0, #8
    ldr sp, =0x000c0000		//HDMI 146, 147
    str sp, [r0]

    /*ICDIPTR set secure dedicated interrupts passed core0*/
    ldr r0, =0xf2a01824
    ldr sp, =0x0101010f
    str sp, [r0]
    add r0, r0, #4
    ldr sp, =0x01010101
    str sp, [r0]
    add r0, r0, #0x10
    ldr sp, =0x0f0f0f01
    str sp, [r0]
    add r0, r0, #4
    ldr sp, =0x0f0f010f
    str sp, [r0]
    add r0, r0, #0x34
    ldr sp, =0x01010f0f
    str sp, [r0]

    mov r0, #SCR_NS
    CP15_SCR_WRITE  r0   
    movs pc, lr

nt_smc_switch_exit:
    /* Load the trust world state */
    /* Note: BTAC flush is automatic in this direction */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
    and sp, sp, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =t_base_table
    add r5, r5, #0x72000000 
    ldr sp, [r5, sp, asl #2] /* sp = t_base_table[cpu_id] */  
    add sp, sp, #0x72000000
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    LoadState                   // Context = S-Context
    rfeia   sp                  // switch to the trust-world os

nt_smc_switch_raise_handler:
    /* turn to trust world and raise a safeg soft interrupt handler */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
    and sp, sp, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =t_base_table
    ldr sp, [r5, sp, asl #2] /* sp = t_base_table[cpu_id] */  
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    ldmfd sp, {r0, r1} // 前回SMCを呼び出した時点の pc, cpsr.
    add r0, r0, #4
    str r1, [sp, #0xc]
      str r0, [sp, #0x14]
    LoadState
    ldr sp, =_smm_stack_0
    ldr sp, [sp]
    mov lr, #(CPSR_MODE_IRQ | CPSR_BIT_6_F | CPSR_BIT_7_I)
    str lr, [sp, #-4]!
    /* SAFEGベクタのアドレスはvectorbase + 0x20 */
    CP15_VBAR_READ lr
    add lr, lr, #0x20
    str lr, [sp, #-4]!
    /* IRQ モードに切り替え, T 側の IRQ ベクタにジャンプ */
    rfeia sp

nt_smc_cache:
    /* check arg0 in r1 to know what to invalidate */
    cmp r1, #NT_SMC_INV_CACHE_D
    beq nt_smc_cache_invalidate_dcache
    cmp r1, #NT_SMC_INV_CACHE_I
    beq nt_smc_cache_invalidate_icache
    cmp r1, #NT_SMC_INV_CACHE_ALL
    beq nt_smc_cache_invalidate_allcache

    /* if argument number is not supported return with error (TODO: test)*/
    mov r1, #NT_SMC_INV_CACHE_ERR
    b nt_smc_return_to_nt

nt_smc_cache_invalidate_dcache:
    /* invalidate the entire data cache */
    mov r0, #0
    mcr p15, 0, r0, c7, c6, 0
    b nt_smc_return_to_nt

nt_smc_cache_invalidate_icache:
    /* invalidate the entire instruction cache */
    mov r0, #0
    mcr p15, 0, r0, c7, c5, 0
    b nt_smc_return_to_nt

nt_smc_cache_invalidate_allcache:
    // invalidate both the data and the instruction cache 
    mov r0, #0
    mcr p15, 0, r0, c7, c14, 0
    mcr p15, 0, r0, c7, c5, 0
    b nt_smc_return_to_nt

nt_smc_set_ipi:
/*HJPARK: restore IPI7 and IPI8 as FIQ*/
    push {r0, r1}
    ldr r0, =0xf2a01080
    ldr r1, =0xfffffd7e
    str r1, [r0]
    ldm sp!, {r0, r1}
    b nt_smc_return_to_nt

nt_smc_tzipc:
    // check arg0 in r1 to know what to invalidate
    mov32 r0, 0xf2a01f00
    str r1, [r0] 	
    b nt_smc_return_to_nt

nt_smc_return_to_nt:
    movs pc, lr

/*
 * SCRのEAビットを立てたことによって，NT側がTrust領域にアクセスした際に
 * このベクタが呼ばれる．
 * なので確実にNT側としてdata_abort_handlerは呼び出される．
 * NT側には戻らないので，SaveStateは呼び出さない．
 * 内容としてはdata abortだが，NT側のフォルトをハンドリングするという
 * 処理の性質上，SWIとしてT側に処理させることとした．
 */
    .text
    .align 5
    .global data_abort_handler
data_abort_handler:
    /* LoadStateを呼び出す前に, Secureにしておく必要がある. */
    mov     sp, #SCR_S                 // lr_mon = Secure World SCR config
    CP15_SCR_WRITE  sp                 // cp15_SCR = lr_mon (S-World Config)

    /*
     * TContextBase, TContextBase+4 は 前回 SMC が呼び出された
     * ときの pc, cpsr となっている．
     * これらの値は swi 終了後に戻る先となるので，swi が通常呼ばれた状態に合わせ
     * lr_svc, spsr_svc に設定する．
     * lr_svc, spsr_svcを破壊するが，asm_target_idleではこれらを破壊しても
     * よいことになっているので保存復帰はしない
     */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
    and sp, sp, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =t_base_table
    ldr sp, [r5, sp, asl #2] /* sp = t_base_table[cpu_id] */ 
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    ldmia sp, {r0, r1}
#ifdef SUPPORT_4CORES    
    mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
	and sp, sp, #0x0f    /* 下位4bitのみ有効   */
    cmp sp, #0
    ldreq sp, =S_SVC_LR_CORE0
    cmp sp, #1
    ldreq sp, =S_SVC_LR_CORE1
    cmp sp, #2
    ldreq sp, =S_SVC_LR_CORE2
    cmp sp, #3
    ldreq sp, =S_SVC_LR_CORE3
#else
    ldr sp, =S_SVC_LR_CORE0    
#endif
    str r0, [sp]
    str r1, [sp, #-8]

    /*
     * rfeiaで戻るために S_PC, S_CPSR を書き換える．
     * FIQ 許可，IRQ 禁止，SVCモードになる状態で抜ける. 
     */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, sp, c0, c0, 5 /* プロセッサIDの取得 */
    and sp, sp, #0x0f    /* 下位4bitのみ有効(r4 = cpu_id) */
    ldr r5, =t_base_table
    ldr sp, [r5, sp, asl #2] /* sp = t_base_table[cpu_id] */      
#else
    ldr sp, =TContextBase0
#endif /* SAFEG_KZMCA9 */
    /* SWI ベクタのアドレスはvectorbase + 0x8 */
    CP15_VBAR_READ r0
    add r0, r0, #0x8
    mov r1, #(CPSR_MODE_SVC | CPSR_BIT_7_I)
    stmia sp, {r0, r1}

    /*
     * Tコンテキストを復帰．
     */
    LoadState

    /* SVC モードに切り替え, T 側の SWI ベクタにジャンプ */
    rfeia sp

/*
 * SafeG の起動を行う.
 * trust側からのSMCによりnon-trustに移動できるように
 * non-trustの起動のための情報をNTコンテキストに保存する.
 * Trust側の起動処理を呼び出す.
 *
 * r0: Non-Trust側スタートアドレス
 * r1: Trust側スタートアドレス
 */
    .text
    .align 5
    .global SafeGStart
SafeGStart:
    /* Non-Trust側のコンテキストを設定する */
    /* stmea をやめて label を使った単発ストア2個にする */
#ifdef SAFEG_KZMCA9
    mrc p15, 0, r2, c0, c0, 5 /* プロセッサIDの取得 */
    and r2, r2, #0x0f    /* 下位4bitのみ有効(r2 = cpu_id) */
    ldr r5, =nt_base_table
    ldr r2, [r5, r2, asl #2] /* r2 = nt_base_table[cpu_id] */  
#else
    ldr r2, =NtContextBase0
#endif /* SAFEG_KZMCA9 */
    ldr r3, =NORMAL_CPSR_INIT_VALUE
    stmea r2, {r0, r3}

    /* Trust側リセット時のモードに変更する */
    cps #CPSR_MODE_SVC

    /* Trust側のスタートアドレスにジャンプする */
    mov pc, r1

    .text
    .align 5
    .global SafeGSecondaryBoot
SafeGSecondaryBoot:
/*HJPARK: start initializing core1*/
    cps #CPSR_MODE_MONITOR		
    mov r0, #SCR_S                 	
    CP15_SCR_WRITE r0		
	
    cpu_id sp
    cmp sp, #1
    ldreq sp, =_smm_stack_1
    cmp sp, #2
    ldreq sp, =_smm_stack_2
    cmp sp, #3
    ldreq sp, =_smm_stack_3
    ldr sp, [sp]

    ldr r1, =MonitorVectorTableBase 
    add r1, r1, #0x72000000	/*HJPARK: convert vector table base address PA to VA*/
    CP15_MVBAR_WRITE r1
    ldr r1, =NSACR_SETTING
    CP15_NSACR_WRITE r1
    ldr r0, =normal_secondary	/*HJPARK: normal boot loader entry point*/	
    ldr r0, [r0]
    ldr r1, =t_smc_boot
	
    b SafeGStart

    .text
    .align 5
    .global NTSecondaryBoot
NTSecondaryBoot:
    cps #CPSR_MODE_MONITOR

    LoadState

    /* flush the branch target address cache */
    CP15_Flush_BTAC lr          // flush BTAC (corrupts lr_mon)

    /* set the SCR to non-trust world settings */
    CP15_SCR_READ lr           // cp15_SCR = lr_mon (N-World Config)
    mov lr, #SCR_NS              // lr_mon = Normal SCR Config
    CP15_SCR_WRITE lr           // cp15_SCR = lr_mon (N-World Config)

    mov lr, #0x15
    mcr p15, 0, lr, c3, c0, 0           //domain access control
    
    /* switch to non-trust world */
    rfeia   sp                  // load cpsr and pc from NtContext

    .align 5
safeg_now_init_core:
    .long 0x1
safeg_irq_handler_sp_core_1:
    .long 0x0
safeg_irq_handler_sp_core_2:
    .long 0x0
safeg_irq_handler_sp_core_3:
    .long 0x0

    .data
normal_secondary:
    .word 0x678006e0
secure_secondary:
    .word 0x104eef9c

    .data
    .align 5
T_RR_ratio 	: .long 0x3
NT_RR_ratio	: .long 0x1

S_quantum:
S_quantum0	: .long 0x3
S_quantum1      : .long 0x3
S_quantum2      : .long 0x3
S_quantum3      : .long 0x3

NS_quantum:
NS_quantum0	: .long 0x1
NS_quantum1     : .long 0x1
NS_quantum2     : .long 0x1
NS_quantum3     : .long 0x1

LR_save_area: 
LR_save_area0	: .long 0x0
LR_save_area1   : .long 0x0
LR_save_area2   : .long 0x0
LR_save_area3   : .long 0x0

R0_save_area:
R0_save_area0	: .long 0x0
R0_save_area1   : .long 0x0
R0_save_area2   : .long 0x0
R0_save_area3   : .long 0x0

Sched_flag:	.long 0x0

/*
 *  현재 tick을 받아 스케줄 중인 world를 의미
 *  0: Secure World , 1: Normal World
 */
current_world:
current_world0	: .long 0x1
current_world1  : .long 0x1
current_world2  : .long 0x1
current_world3  : .long 0x1
current_world_all	: .long 0x1

nt_save_IPI:
nt_save_IPI0	: .long 0x0
nt_save_IPI1    : .long 0x0
nt_save_IPI2    : .long 0x0
nt_save_IPI3    : .long 0x0

t_save_IPI:
t_save_IPI0	: .long 0x0
t_save_IPI1     : .long 0x0
t_save_IPI2     : .long 0x0
t_save_IPI3     : .long 0x0

/*
 *-----------------------------------------------------------------------------
 * =================
 * Monitor workspace
 * =================
 */

/*
 * =================
 * Core 0
 * ================= 
 */
    .bss
    .align 5
    .global NtContextSavedArea0
    .global NtContextSavedAreaEnd0
    .global TContextSavedArea0
    .global TContextSavedAreaEnd0
    .global NtContextBase0
    .global TContextBase0
NtContextSavedArea0:
N_USR_R0_CORE0       : .long 0x00
N_USR_R1_CORE0       : .long 0x00
N_USR_R2_CORE0       : .long 0x00
N_USR_R3_CORE0       : .long 0x00
N_USR_R4_CORE0       : .long 0x00
N_USR_R5_CORE0       : .long 0x00
N_USR_R6_CORE0       : .long 0x00
N_USR_R7_CORE0       : .long 0x00
N_USR_R8_CORE0       : .long 0x00
N_USR_R9_CORE0       : .long 0x00
N_USR_R10_CORE0      : .long 0x00
N_USR_R11_CORE0      : .long 0x00
N_USR_R12_CORE0      : .long 0x00
N_USR_SP_CORE0       : .long 0x00
N_USR_LR_CORE0       : .long 0x00

NtContextBase0:
N_PC_CORE0           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE0         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE0      : .long 0x00
N_IRQ_SPSR_CORE0     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE0       : .long 0x00
N_IRQ_LR_CORE0       : .long 0x00
N_SVC_SPSR_CORE0     : .long 0x00    // etc.
N_SVC_SP_CORE0       : .long 0x00
N_SVC_LR_CORE0       : .long 0x00
N_ABT_SPSR_CORE0     : .long 0x00
N_ABT_SP_CORE0       : .long 0x00
N_ABT_LR_CORE0       : .long 0x00
N_UND_SPSR_CORE0     : .long 0x00
N_UND_SP_CORE0       : .long 0x00
N_UND_LR_CORE0       : .long 0x00
N_FIQ_SPSR_CORE0     : .long 0x00
N_FIQ_R8_CORE0       : .long 0x00
N_FIQ_R9_CORE0       : .long 0x00
N_FIQ_R10_CORE0      : .long 0x00
N_FIQ_R11_CORE0      : .long 0x00
N_FIQ_R12_CORE0      : .long 0x00
N_FIQ_SP_CORE0       : .long 0x00
N_FIQ_LR_CORE0       : .long 0x00
NtContextSavedAreaEnd0:

TContextSavedArea0:
S_USR_R0_CORE0       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE0       : .long 0x00
S_USR_R2_CORE0       : .long 0x00
S_USR_R3_CORE0       : .long 0x00
S_USR_R4_CORE0       : .long 0x00
S_USR_R5_CORE0       : .long 0x00
S_USR_R6_CORE0       : .long 0x00
S_USR_R7_CORE0       : .long 0x00
S_USR_R8_CORE0       : .long 0x00
S_USR_R9_CORE0       : .long 0x00
S_USR_R10_CORE0      : .long 0x00
S_USR_R11_CORE0      : .long 0x00
S_USR_R12_CORE0      : .long 0x00
S_USR_SP_CORE0       : .long 0x00
S_USR_LR_CORE0       : .long 0x00

TContextBase0:
S_PC_CORE0           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE0         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE0      : .long 0x00
S_IRQ_SPSR_CORE0     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE0       : .long 0x00
S_IRQ_LR_CORE0       : .long 0x00
S_SVC_SPSR_CORE0     : .long 0x00    // etc.
S_SVC_SP_CORE0       : .long 0x00
S_SVC_LR_CORE0       : .long 0x00
S_ABT_SPSR_CORE0     : .long 0x00
S_ABT_SP_CORE0       : .long 0x00
S_ABT_LR_CORE0       : .long 0x00
S_UND_SPSR_CORE0     : .long 0x00
S_UND_SP_CORE0       : .long 0x00
S_UND_LR_CORE0       : .long 0x00
S_FIQ_SPSR_CORE0     : .long 0x00
S_FIQ_R8_CORE0       : .long 0x00
S_FIQ_R9_CORE0       : .long 0x00
S_FIQ_R10_CORE0      : .long 0x00
S_FIQ_R11_CORE0      : .long 0x00
S_FIQ_R12_CORE0      : .long 0x00
S_FIQ_SP_CORE0       : .long 0x00
S_FIQ_LR_CORE0       : .long 0x00
TContextSavedAreaEnd0:

/*
 * =================
 * Core 1
 * ================= 
 */
    .bss
    .align 5
    .global NtContextSavedArea1
    .global NtContextSavedAreaEnd1
    .global TContextSavedArea1
    .global TContextSavedAreaEnd1
    .global NtContextBase1
    .global TContextBase1
NtContextSavedArea1:
N_USR_R0_CORE1       : .long 0x00
N_USR_R1_CORE1       : .long 0x00
N_USR_R2_CORE1       : .long 0x00
N_USR_R3_CORE1       : .long 0x00
N_USR_R4_CORE1       : .long 0x00
N_USR_R5_CORE1       : .long 0x00
N_USR_R6_CORE1       : .long 0x00
N_USR_R7_CORE1       : .long 0x00
N_USR_R8_CORE1       : .long 0x00
N_USR_R9_CORE1       : .long 0x00
N_USR_R10_CORE1      : .long 0x00
N_USR_R11_CORE1      : .long 0x00
N_USR_R12_CORE1      : .long 0x00
N_USR_SP_CORE1       : .long 0x00
N_USR_LR_CORE1       : .long 0x00

NtContextBase1:
N_PC_CORE1           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE1         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE1      : .long 0x00
N_IRQ_SPSR_CORE1     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE1       : .long 0x00
N_IRQ_LR_CORE1       : .long 0x00
N_SVC_SPSR_CORE1     : .long 0x00    // etc.
N_SVC_SP_CORE1       : .long 0x00
N_SVC_LR_CORE1       : .long 0x00
N_ABT_SPSR_CORE1     : .long 0x00
N_ABT_SP_CORE1       : .long 0x00
N_ABT_LR_CORE1       : .long 0x00
N_UND_SPSR_CORE1     : .long 0x00
N_UND_SP_CORE1       : .long 0x00
N_UND_LR_CORE1       : .long 0x00
N_FIQ_SPSR_CORE1     : .long 0x00
N_FIQ_R8_CORE1       : .long 0x00
N_FIQ_R9_CORE1       : .long 0x00
N_FIQ_R10_CORE1      : .long 0x00
N_FIQ_R11_CORE1      : .long 0x00
N_FIQ_R12_CORE1      : .long 0x00
N_FIQ_SP_CORE1       : .long 0x00
N_FIQ_LR_CORE1       : .long 0x00
NtContextSavedAreaEnd1:

TContextSavedArea1:
S_USR_R0_CORE1       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE1       : .long 0x00
S_USR_R2_CORE1       : .long 0x00
S_USR_R3_CORE1       : .long 0x00
S_USR_R4_CORE1       : .long 0x00
S_USR_R5_CORE1       : .long 0x00
S_USR_R6_CORE1       : .long 0x00
S_USR_R7_CORE1       : .long 0x00
S_USR_R8_CORE1       : .long 0x00
S_USR_R9_CORE1       : .long 0x00
S_USR_R10_CORE1      : .long 0x00
S_USR_R11_CORE1      : .long 0x00
S_USR_R12_CORE1      : .long 0x00
S_USR_SP_CORE1       : .long 0x00
S_USR_LR_CORE1       : .long 0x00

TContextBase1:
S_PC_CORE1           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE1         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE1      : .long 0x00
S_IRQ_SPSR_CORE1     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE1       : .long 0x00
S_IRQ_LR_CORE1       : .long 0x00
S_SVC_SPSR_CORE1     : .long 0x00    // etc.
S_SVC_SP_CORE1       : .long 0x00
S_SVC_LR_CORE1       : .long 0x00
S_ABT_SPSR_CORE1     : .long 0x00
S_ABT_SP_CORE1       : .long 0x00
S_ABT_LR_CORE1       : .long 0x00
S_UND_SPSR_CORE1     : .long 0x00
S_UND_SP_CORE1       : .long 0x00
S_UND_LR_CORE1       : .long 0x00
S_FIQ_SPSR_CORE1     : .long 0x00
S_FIQ_R8_CORE1       : .long 0x00
S_FIQ_R9_CORE1       : .long 0x00
S_FIQ_R10_CORE1      : .long 0x00
S_FIQ_R11_CORE1      : .long 0x00
S_FIQ_R12_CORE1      : .long 0x00
S_FIQ_SP_CORE1       : .long 0x00
S_FIQ_LR_CORE1       : .long 0x00
TContextSavedAreaEnd1:


/*
 * =================
 * Core 2
 * ================= 
 */
    .bss
    .align 5
    .global NtContextSavedArea2
    .global NtContextSavedAreaEnd2
    .global TContextSavedArea2
    .global TContextSavedAreaEnd2
    .global NtContextBase2
    .global TContextBase2
NtContextSavedArea2:
N_USR_R0_CORE2       : .long 0x00
N_USR_R1_CORE2       : .long 0x00
N_USR_R2_CORE2       : .long 0x00
N_USR_R3_CORE2       : .long 0x00
N_USR_R4_CORE2       : .long 0x00
N_USR_R5_CORE2       : .long 0x00
N_USR_R6_CORE2       : .long 0x00
N_USR_R7_CORE2       : .long 0x00
N_USR_R8_CORE2       : .long 0x00
N_USR_R9_CORE2       : .long 0x00
N_USR_R10_CORE2      : .long 0x00
N_USR_R11_CORE2      : .long 0x00
N_USR_R12_CORE2      : .long 0x00
N_USR_SP_CORE2       : .long 0x00
N_USR_LR_CORE2       : .long 0x00

NtContextBase2:
N_PC_CORE2           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE2         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE2      : .long 0x00
N_IRQ_SPSR_CORE2     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE2       : .long 0x00
N_IRQ_LR_CORE2       : .long 0x00
N_SVC_SPSR_CORE2     : .long 0x00    // etc.
N_SVC_SP_CORE2       : .long 0x00
N_SVC_LR_CORE2       : .long 0x00
N_ABT_SPSR_CORE2     : .long 0x00
N_ABT_SP_CORE2       : .long 0x00
N_ABT_LR_CORE2       : .long 0x00
N_UND_SPSR_CORE2     : .long 0x00
N_UND_SP_CORE2       : .long 0x00
N_UND_LR_CORE2       : .long 0x00
N_FIQ_SPSR_CORE2     : .long 0x00
N_FIQ_R8_CORE2       : .long 0x00
N_FIQ_R9_CORE2       : .long 0x00
N_FIQ_R10_CORE2      : .long 0x00
N_FIQ_R11_CORE2      : .long 0x00
N_FIQ_R12_CORE2      : .long 0x00
N_FIQ_SP_CORE2       : .long 0x00
N_FIQ_LR_CORE2       : .long 0x00
NtContextSavedAreaEnd2:

TContextSavedArea2:
S_USR_R0_CORE2       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE2       : .long 0x00
S_USR_R2_CORE2       : .long 0x00
S_USR_R3_CORE2       : .long 0x00
S_USR_R4_CORE2       : .long 0x00
S_USR_R5_CORE2       : .long 0x00
S_USR_R6_CORE2       : .long 0x00
S_USR_R7_CORE2       : .long 0x00
S_USR_R8_CORE2       : .long 0x00
S_USR_R9_CORE2       : .long 0x00
S_USR_R10_CORE2      : .long 0x00
S_USR_R11_CORE2      : .long 0x00
S_USR_R12_CORE2      : .long 0x00
S_USR_SP_CORE2       : .long 0x00
S_USR_LR_CORE2       : .long 0x00

TContextBase2:
S_PC_CORE2           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE2         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE2      : .long 0x00
S_IRQ_SPSR_CORE2     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE2       : .long 0x00
S_IRQ_LR_CORE2       : .long 0x00
S_SVC_SPSR_CORE2     : .long 0x00    // etc.
S_SVC_SP_CORE2       : .long 0x00
S_SVC_LR_CORE2       : .long 0x00
S_ABT_SPSR_CORE2     : .long 0x00
S_ABT_SP_CORE2       : .long 0x00
S_ABT_LR_CORE2       : .long 0x00
S_UND_SPSR_CORE2     : .long 0x00
S_UND_SP_CORE2       : .long 0x00
S_UND_LR_CORE2       : .long 0x00
S_FIQ_SPSR_CORE2     : .long 0x00
S_FIQ_R8_CORE2       : .long 0x00
S_FIQ_R9_CORE2       : .long 0x00
S_FIQ_R10_CORE2      : .long 0x00
S_FIQ_R11_CORE2      : .long 0x00
S_FIQ_R12_CORE2      : .long 0x00
S_FIQ_SP_CORE2       : .long 0x00
S_FIQ_LR_CORE2       : .long 0x00
TContextSavedAreaEnd2:


/*
 * =================
 * Core 3
 * ================= 
 */
    .bss
    .align 5
    .global NtContextSavedArea3
    .global NtContextSavedAreaEnd3
    .global TContextSavedArea3
    .global TContextSavedAreaEnd3
    .global NtContextBase3
    .global TContextBase3
NtContextSavedArea3:
N_USR_R0_CORE3       : .long 0x00
N_USR_R1_CORE3       : .long 0x00
N_USR_R2_CORE3       : .long 0x00
N_USR_R3_CORE3       : .long 0x00
N_USR_R4_CORE3       : .long 0x00
N_USR_R5_CORE3       : .long 0x00
N_USR_R6_CORE3       : .long 0x00
N_USR_R7_CORE3       : .long 0x00
N_USR_R8_CORE3       : .long 0x00
N_USR_R9_CORE3       : .long 0x00
N_USR_R10_CORE3      : .long 0x00
N_USR_R11_CORE3      : .long 0x00
N_USR_R12_CORE3      : .long 0x00
N_USR_SP_CORE3       : .long 0x00
N_USR_LR_CORE3       : .long 0x00

NtContextBase3:
N_PC_CORE3           : .long 0x00    // PC to load to return to Normal World
N_CPSR_CORE3         : .long 0x00    // CPSR to load when returning to Normal World
N_SCRATCH_CORE3      : .long 0x00
N_IRQ_SPSR_CORE3     : .long 0x00    // Normal World IRQ mode SPSR, SP and LR reg
N_IRQ_SP_CORE3       : .long 0x00
N_IRQ_LR_CORE3       : .long 0x00
N_SVC_SPSR_CORE3     : .long 0x00    // etc.
N_SVC_SP_CORE3       : .long 0x00
N_SVC_LR_CORE3       : .long 0x00
N_ABT_SPSR_CORE3     : .long 0x00
N_ABT_SP_CORE3       : .long 0x00
N_ABT_LR_CORE3       : .long 0x00
N_UND_SPSR_CORE3     : .long 0x00
N_UND_SP_CORE3       : .long 0x00
N_UND_LR_CORE3       : .long 0x00
N_FIQ_SPSR_CORE3     : .long 0x00
N_FIQ_R8_CORE3       : .long 0x00
N_FIQ_R9_CORE3       : .long 0x00
N_FIQ_R10_CORE3      : .long 0x00
N_FIQ_R11_CORE3      : .long 0x00
N_FIQ_R12_CORE3      : .long 0x00
N_FIQ_SP_CORE3       : .long 0x00
N_FIQ_LR_CORE3       : .long 0x00
NtContextSavedAreaEnd3:

TContextSavedArea3:
S_USR_R0_CORE3       : .long 0x00    // Secure World USR/SYS registers
S_USR_R1_CORE3       : .long 0x00
S_USR_R2_CORE3       : .long 0x00
S_USR_R3_CORE3       : .long 0x00
S_USR_R4_CORE3       : .long 0x00
S_USR_R5_CORE3       : .long 0x00
S_USR_R6_CORE3       : .long 0x00
S_USR_R7_CORE3       : .long 0x00
S_USR_R8_CORE3       : .long 0x00
S_USR_R9_CORE3       : .long 0x00
S_USR_R10_CORE3      : .long 0x00
S_USR_R11_CORE3      : .long 0x00
S_USR_R12_CORE3      : .long 0x00
S_USR_SP_CORE3       : .long 0x00
S_USR_LR_CORE3       : .long 0x00

TContextBase3:
S_PC_CORE3           : .long 0x00    // PC to load to return to Secure World
S_CPSR_CORE3         : .long 0x00    // CPSR to load to return to Secure World
S_SCRATCH_CORE3      : .long 0x00
S_IRQ_SPSR_CORE3     : .long 0x00    // Secure World IRQ mode SPSR, SP and LR reg
S_IRQ_SP_CORE3       : .long 0x00
S_IRQ_LR_CORE3       : .long 0x00
S_SVC_SPSR_CORE3     : .long 0x00    // etc.
S_SVC_SP_CORE3       : .long 0x00
S_SVC_LR_CORE3       : .long 0x00
S_ABT_SPSR_CORE3     : .long 0x00
S_ABT_SP_CORE3       : .long 0x00
S_ABT_LR_CORE3       : .long 0x00
S_UND_SPSR_CORE3     : .long 0x00
S_UND_SP_CORE3       : .long 0x00
S_UND_LR_CORE3       : .long 0x00
S_FIQ_SPSR_CORE3     : .long 0x00
S_FIQ_R8_CORE3       : .long 0x00
S_FIQ_R9_CORE3       : .long 0x00
S_FIQ_R10_CORE3      : .long 0x00
S_FIQ_R11_CORE3      : .long 0x00
S_FIQ_R12_CORE3      : .long 0x00
S_FIQ_SP_CORE3       : .long 0x00
S_FIQ_LR_CORE3       : .long 0x00
TContextSavedAreaEnd3:
