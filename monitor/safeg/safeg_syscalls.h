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
#ifndef _SAFEG_SYSCALLS_H_
#define _SAFEG_SYSCALLS_H_

/*
 * SAFEG System Monitor Calls 
 *
 * T_: Trust calls 
 * NT_: Non-Trust calls
 *
 * template: safeg_syscall(int num, int *arg0, int *arg1)
 *
 * indentation:
 *      num
 *          arg0
 *              arg1
 */
#define T_SMC_SWITCH  0 /* switch to NT */
#define     T_SMC_SWITCH_OK      0 /* no error */
#define     T_SMC_SWITCH_ERR     1 /* error, return to T */
#define     T_SMC_SWITCH_HANDLER 2 /* NT returns, raise safeg handler*/
#define     T_SMC_SWITCH_RET     3 /* NT returns */
#define     T_SMC_SWITCH_SHVAR   4 /* NT returns, arg1 = shared variable */

#define T_SMC_REBOOT  1 /* reboot NT */
#define     T_SMC_REBOOT_OK      0 /* no error */
#define     T_SMC_REBOOT_ERR     1 /* error, return to T */

#define T_SMC_SWITCH_BOOT 2 /*HJPARK switch to NT and boot NT*/

#define T_SMC_WFI 3 /*HJPARK set NT cores wfi*/

#define NT_SMC_SWITCH 0 /* switch to T */
#define     NT_SMC_SWITCH_OK     0 /* no error */
#define     NT_SMC_SWITCH_ERR    1 /* error, return to NT */

#define NT_SMC_INV_CACHE 1 /* invalidate cache and return to NT */
#define     NT_SMC_INV_CACHE_OK   0 /* no error */
#define     NT_SMC_INV_CACHE_ERR  1 /* error, return to T */
#define     NT_SMC_INV_CACHE_D    2 /* invalidate data cache */
#define     NT_SMC_INV_CACHE_I    3 /* invalidate instruction cache */
#define     NT_SMC_INV_CACHE_ALL  4 /* invalidate both caches */

#define NT_SMC_SOFTIRQ 2 /* generate a software interrupt in Trust world */

#define NT_SMC_START_DOM_SCHED 3
#define NT_SMC_STOP_DOM_SCHED 4

#define NT_SMC_INIT_CORE 5

#define NT_SMC_TZIPC 6

#define NT_SMC_SET_IPI 7

#define NT_SMC_IPI 8


#endif /* _SAFEG_SYSCALLS_H_ */
