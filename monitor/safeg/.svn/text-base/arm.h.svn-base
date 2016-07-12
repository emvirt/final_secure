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
#ifndef _ARM_H_
#define _ARM_H_

#ifdef __ASSEMBLY__
/*
 * --------------
 * CPSR Bit Masks
 * --------------
 */
#define CPSR_MASK_FLAGS     0b11111000000000000000000000000000
#define CPSR_MASK_GE        0b00000000000011110000000000000000
#define CPSR_BIT_24_J       0b00000001000000000000000000000000
#define CPSR_BIT_9_E        0b00000000000000000000001000000000
#define CPSR_BIT_8_A        0b00000000000000000000000100000000
#define CPSR_BIT_7_I        0b00000000000000000000000010000000
#define CPSR_BIT_6_F        0b00000000000000000000000001000000
#define CPSR_BIT_5_T        0b00000000000000000000000000100000
#define CPSR_MASK_MODE      0b00000000000000000000000000011111

/*
 *  Mode bit masks used by CPSR and the CPS instruction
 */
#define CPSR_MODE_USER      0b10000
#define CPSR_MODE_FIQ       0b10001
#define CPSR_MODE_IRQ       0b10010
#define CPSR_MODE_SVC       0b10011
#define CPSR_MODE_ABORT     0b10111
#define CPSR_MODE_UNDEF     0b11011
#define CPSR_MODE_SYSTEM    0b11111
#define CPSR_MODE_MONITOR   0b10110

#else
/*
 * --------------
 * CPSR Bit Masks
 * --------------
 */
#define CPSR_MASK_FLAGS     0xf8000000
#define CPSR_MASK_GE        0x000f0000
#define CPSR_BIT_24_J       0x01000000
#define CPSR_BIT_9_E        0x00000200
#define CPSR_BIT_8_A        0x00000100
#define CPSR_BIT_7_I        0x00000080
#define CPSR_BIT_6_F        0x00000040
#define CPSR_BIT_5_T        0x00000020
#define CPSR_MASK_MODE      0x0000001f

/*
 *  Mode bit masks used by CPSR and the CPS instruction
 */
#define CPSR_MODE_USER      0x10
#define CPSR_MODE_FIQ       0x11
#define CPSR_MODE_IRQ       0x12
#define CPSR_MODE_SVC       0x13
#define CPSR_MODE_ABORT     0x17
#define CPSR_MODE_UNDEF     0x1b
#define CPSR_MODE_SYSTEM    0x1f
#define CPSR_MODE_MONITOR   0x16

#endif

#define CP15_CONTROL_FA_BIT        0x20000000   /* see DDI0301D p3-60 */
#define CP15_CONTROL_TR_BIT        0x10000000
#define CP15_CONTROL_EE_BIT        0x02000000
#define CP15_CONTROL_VE_BIT        0x01000000
#define CP15_CONTROL_XP_BIT        0x00800000
#define CP15_CONTROL_U_BIT         0x00400000
#define CP15_CONTROL_FI_BIT        0x00200000
#define CP15_CONTROL_IT_BIT        0x00040000
#define CP15_CONTROL_DT_BIT        0x00010000
#define CP15_CONTROL_L4_BIT        0x00008000
#define CP15_CONTROL_RR_BIT        0x00004000
#define CP15_CONTROL_V_BIT         0x00002000
#define CP15_CONTROL_I_BIT         0x00001000
#define CP15_CONTROL_Z_BIT         0x00000800
#define CP15_CONTROL_F_BIT         0x00000400
#define CP15_CONTROL_R_BIT         0x00000200
#define CP15_CONTROL_S_BIT         0x00000100
#define CP15_CONTROL_B_BIT         0x00000080
#define CP15_CONTROL_W_BIT         0x00000008
#define CP15_CONTROL_C_BIT         0x00000004
#define CP15_CONTROL_A_BIT         0x00000002
#define CP15_CONTROL_M_BIT         0x00000001

#define CP15_TTB_CTRL_PD1            (1 << 5)   /* see DDI0301D p3-83 */
#define CP15_TTB_CTRL_PD0            (1 << 4)
#define CP15_TTB_CTRL_NBITS          (7 << 0)
#define CP15_TTB_CTRL_NBITS_16KB          0x0
#define CP15_TTB_CTRL_NBITS_8KB           0x1
#define CP15_TTB_CTRL_NBITS_4KB           0x2
#define CP15_TTB_CTRL_NBITS_2KB           0x3
#define CP15_TTB_CTRL_NBITS_1KB           0x4
#define CP15_TTB_CTRL_NBITS_512B          0x5
#define CP15_TTB_CTRL_NBITS_256B          0x6
#define CP15_TTB_CTRL_NBITS_128B          0x7

#define CP15_VA_TO_PA_CURRENT_PRIV_READ     0
#define CP15_VA_TO_PA_CURRENT_PRIV_WRITE    1
#define CP15_VA_TO_PA_CURRENT_USER_READ     2
#define CP15_VA_TO_PA_CURRENT_USER_WRITE    3
#define CP15_VA_TO_PA_OTHER_PRIV_READ       4
#define CP15_VA_TO_PA_OTHER_PRIV_WRITE      5
#define CP15_VA_TO_PA_OTHER_USER_READ       6
#define CP15_VA_TO_PA_OTHER_USER_WRITE      7

#define CP15_PM_CONTROL_EVTCNT0    0x0FF00000
#define CP15_PM_CONTROL_EVTCNT1    0x000FF000
#define CP15_PM_CONTROL_X_BIT      0x00000800
#define CP15_PM_CONTROL_CCR_BIT    0x00000400
#define CP15_PM_CONTROL_CR1_BIT    0x00000200
#define CP15_PM_CONTROL_CR0_BIT    0x00000100
#define CP15_PM_CONTROL_ECC_BIT    0x00000040
#define CP15_PM_CONTROL_EC1_BIT    0x00000020
#define CP15_PM_CONTROL_EC0_BIT    0x00000010
#define CP15_PM_CONTROL_D_BIT      0x00000008
#define CP15_PM_CONTROL_C_BIT      0x00000004
#define CP15_PM_CONTROL_P_BIT      0x00000002
#define CP15_PM_CONTROL_E_BIT      0x00000001

#define PM_EVENT_ALL                     0xFF
#define PM_EVENT_DCACHE_MISS             0x0B
#define PM_EVENT_DCACHE_ACCESS           0x0A
#define PM_EVENT_DCACHE_ACCESS_CACHABLE  0x09
#define PM_EVENT_ICACHE_MISS             0x00

#ifdef SAFEG_KZMCA9
#define CP15_NSACR_NS_SMP           (1 << 18)
#define CP15_NSACR_TL               (1 << 17)
#define CP15_NSACR_PLE              (1 << 16)
#define CP15_NSACR_CP11             (1 << 11)
#define CP15_NSACR_CP10             (1 << 10)
#define NSACR_SETTING (CP15_NSACR_NS_SMP|CP15_NSACR_TL|CP15_NSACR_PLE|CP15_NSACR_CP11|CP15_NSACR_CP10)
#else
#define CP15_NSACR_DMA              (1 << 18)   /* see DDI333F p3-72 */
#define CP15_NSACR_TL               (1 << 17)
#define CP15_NSACR_CL               (1 << 16)
#define CP15_NSACR_CPFULL           (0x3FFF)    /* experimental */
#define NSACR_SETTING (CP15_NSACR_DMA|CP15_NSACR_TL|CP15_NSACR_CL|CP15_NSACR_CPFULL)
#endif

#ifdef __ASSEMBLY__
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
#else

#define CP15_CONTROL_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c1, c0, 0":"=r"(x))
#define CP15_CONTROL_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c1, c0, 0"::"r"(x))
#define CP15_SCR_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c1, c1, 0":"=r"(x))
#define CP15_SCR_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c1, c1, 0"::"r"(x))
#define CP15_NSACR_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c1, c1, 2":"=r"(x))
#define CP15_NSACR_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c1, c1, 2"::"r"(x))
#define CP15_TTB0_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c2, c0, 0": "=r"(x))
#define CP15_TTB0_WRITE(x) \
        __asm__ volatile ("mcr p15, 0, %0, c2, c0, 0":: "r"(x))
#define CP15_TTB_CTRL_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c2, c0, 2":"=r"(x))
#define CP15_TTB_CTRL_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c2, c0, 2":: "r"(x))
#define CP15_DOMAINS_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c3, c0, 0":: "r"(x))
#define CP15_VA_TO_PA_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c7, c4, 0":"=r"(x))
#define CP15_ICACHE_INVALIDATE() \
    __asm__ volatile ("mcr p15, 0, %0, c7, c5, 0":: "r"(0))
#define CP15_DCACHE_INVALIDATE() \
    __asm__ volatile ("mcr p15, 0, %0, c7, c6, 0":: "r"(0))
#define CP15_CACHE_INVALIDATE_BOTH() \
    __asm__ volatile ("mcr p15, 0, %0, c7, c7, 0":: "r"(0))
#define CP15_DCACHE_CLEAN() \
    __asm__ volatile ("mcr p15, 0, %0, c7, c10, 0":: "r"(0))
#define CP15_DCACHE_INVALIDATE_CLEAN() \
    __asm__ volatile ("mcr p15, 0, %0, c7, c14, 0":: "r"(0))
#define CP15_VA_TO_PA_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c7, c4, 0":"=r"(x))
#define CP15_VA_TO_PA_WRITE(x, perm)  \
    __asm__ volatile ("mcr p15, 0, %0, c7, c8, %1"::"r"(x),"I"(perm))
#define CP15_VBAR_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c12, c0, 0"::"r"(x))
#define CP15_MVBAR_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c12, c0, 1"::"r"(x))
#define CP15_PM_CONTROL_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c15, c12, 0":"=r"(x))
#define CP15_PM_CONTROL_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c15, c12, 0"::"r"(x))
#define CP15_PM_CYCLE_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c15, c12, 1":"=r"(x))
#define CP15_PM_CYCLE_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c15, c12, 1"::"r"(x))
#define CP15_PM_CR0_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c15, c12, 2":"=r"(x))
#define CP15_PM_CR0_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c15, c12, 2"::"r"(x))
#define CP15_PM_CR1_READ(x) \
    __asm__ volatile ("mrc p15, 0, %0, c15, c12, 3":"=r"(x))
#define CP15_PM_CR1_WRITE(x) \
    __asm__ volatile ("mcr p15, 0, %0, c15, c12, 3"::"r"(x))
#define CP15_MPIDR_READ(x)					\
    __asm__ volatile ("mrc p15, 0, %0, c0, c0, 5":"=r"(x));
#define IRQ_ENABLE() __asm__ volatile ("cpsie i")
#define IRQ_DISABLE() __asm__ volatile ("cpsid i")

#endif                          /* __ASSEMBLY__ */

/*
* SCR の設定
*/

#define SCR_NS  SCR_BIT_0_NS | SCR_BIT_1_IRQ_INTO_MON | SCR_BIT_2_FIQ_INTO_MON | SCR_BIT_3_EA_INTO_MON | SCR_BIT_5_AW_MODIFY_ENABLE
#define SCR_S   SCR_BIT_1_IRQ_INTO_MON | SCR_BIT_2_FIQ_INTO_MON | SCR_BIT_4_FW_MODIFY_ENABLE | SCR_BIT_5_AW_MODIFY_ENABLE

/*
* -------------
* SCR Bit Masks
* -------------
* Bit masks for SCR bit settings (CP15-C1 SCR register)
* For details see ARM ARM Security Extensions Supplement (DDI 0309B)
*/
#define SCR_BIT_0_NS                  0b0000001
#define SCR_BIT_1_IRQ_INTO_MON        0b0000010
#define SCR_BIT_2_FIQ_INTO_MON        0b0000100
#define SCR_BIT_3_EA_INTO_MON         0b0001000
#define SCR_BIT_4_FW_MODIFY_ENABLE    0b0010000
#define SCR_BIT_5_AW_MODIFY_ENABLE    0b0100000

#endif /* _ARM_H_ */
