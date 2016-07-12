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
#ifndef _SAFEG_MEASURES_H_
#define _SAFEG_MEASURES_H_

/*
 * Enable/Disable measures globally
 */
// #define SAFEG_MEASUREMENTS_ENABLE

#ifdef SAFEG_MEASUREMENTS_ENABLE

/* Maximum number of samples per measure */
#define MAX_COUNT 10000

/*
 * Flags to enable/disable specific measures
 */
#define SAFEG_MEASURE_IRQ_OVH      0  /* IRQ overhead inside SafeG */
#define SAFEG_MEASURE_FIQ_OVH      0  /* TODO: FIQ overhead inside SafeG */
#define SAFEG_MEASURE_FIQ_FIQ      0  /* T-FIQ -> T-FIQ */
#define SAFEG_MEASURE_FIQ_IRQ      0  /* T-FIQ -> NT-IRQ */
#define ASP_MEASURE_IRQ_LAT        0  /* ASP interrupt latency */
#define ASP_MEASURE_TIMER_LAT      0  /* ASP TIMER interrupt latency */
#define ASP_MEASURE_ITASK_LAT      0  /* ITASK interrupt lat */
#define LINUX_MEASURE_TIMER_LAT    0  /* Linux timer handler latency */

#ifdef __ASSEMBLY__

/*
 * ---------------------------------------------------
 * MACROS for measurements using the ARM performance
 * monitor that is in the system coprocessor 15.
 *
 * All the measures are stored in an array:
 *
 *     unsigned long int safeg_latency[MAX_COUNT];
 *
 * and can be read using a Debugger.
 * (NOTE: C variables are in safeg_start.c)
 * ---------------------------------------------------
 */

/*
 * perfmon_start: macro to start a measure
 *    - tmp: register that will be manipulated
 */

#ifdef SAFEG_KZMCA9
    .macro perfmon_start, tmp
    	mov \tmp, #0
		mcr p15, 0, \tmp, c9, c12, 5	// event counter = 0
		mov \tmp, #0x11
		mcr p15, 0, \tmp, c9, c13, 1	// event type = cycle count
		mov \tmp, #0x80000000
		mcr p15, 0, \tmp, c9, c12, 2	// disable cycle counter
		mov \tmp, #0
		mcr p15, 0, \tmp, c9, c12, 0	// disable all counters + count in cycles
		mcr p15, 0, \tmp, c9, c13, 0	// load 0 to counter
		mov \tmp, #0x80000000
		mcr p15, 0, \tmp, c9, c12, 1	// enable cycle counter
		mov \tmp, #1
		mcr p15, 0, \tmp, c9, c12, 0	// enable all counters
    .endm
#else
    .macro perfmon_start, tmp
        mov \tmp, #0
        mcr p15, 0, \tmp, c15, c12, 0  /* disable counter (writting 0) */
        mcr p15, 0, \tmp, c15, c12, 1  /* write 0 to cycle counter    */
        mov \tmp, #1
        mcr p15, 0, \tmp, c15, c12, 0  /* enable counter (writting 1) */
    .endm
#endif /* SAFEG_KZMCA9 */

/*
 * perfmon_end: macros to finish a measure
 *     - result: register to store the cycles
 *     - tmp0: register that will be manipulated
 *     - tmp1: register that will be manipulated
 */

    .macro perfmon_end, result, tmp0, tmp1
#ifdef SAFEG_KZMCA9
		 mrc p15, 0, \result, c9, c13, 0   /* result = read cycle counter */
#else
         mrc p15, 0, \result, c15 ,c12 , 1 /* result = read cycle counter */
#endif /* SAFEG_KZMCA9 */
         ldr \tmp0, =latency_counter
         ldr \tmp0, [\tmp0]                /* tmp0 = &latency_counter */
         ldr \tmp1, =MAX_COUNT             /* tmp1 = max_count (ie 10000) */
         cmp \tmp0, \tmp1                  /* if tmp0 >= tmp1 */
         subcs \tmp0, \tmp1                /*    tmp0 = tmp0 - tmp1 */
         ldr \tmp1, =safeg_latency         /* tmp1 = &safeg_latency[0] */
         str \result, [\tmp1, \tmp0, lsl #2]  /* safeg_latency[tmp0]=result */
         add \tmp0, \tmp0, #1              /* tmp0++ */
         ldr \tmp1, =latency_counter       /* tmp1 = &latency_counter */
         str \tmp0, [\tmp1]                /* *tmp1 = tmp0 */
         /* clear the instruction cache */
         mov \tmp1, #0
#ifdef SAFEG_KZMCA9
         mcr p15, 0, \tmp1, c7, c5, 0
#else /* 1176 cache flush hardware bug */
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
         mcr p15, 0, \tmp1, c7, c5, 0
#endif /* SAFEG_KZMCA9 */
    .endm

#endif /* __ASSEMBLY__ */

#endif /* SAFEG_MEASUREMENTS_ENABLE */
#endif /* _SAFEG_MEASURES_H_ */
