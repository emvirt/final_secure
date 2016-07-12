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
#ifndef _SAFEG_H_
#define _SAFEG_H_

/* IRQ カウント*/
#define IRQ_COUNT    0x000FFFF8
/* FIQ カウント*/
#define FIQ_COUNT    0x000FFFFC

/*
 * irq, fiq を管理するための関数
 * tz_basic.S の irq, fiq ハンドラの中で呼ばれる.
 * これらの関数内に行いたい処理を記述する.
 */

// #define ENABLE_FIQ_MANAGEMENT
// #define ENABLE_IRQ_MANAGEMENT

#ifdef ENABLE_IRQ_MANAGEMENT
void irq_management(void);
#endif

#ifdef ENABLE_FIQ_MANAGEMENT
void fiq_management(void);
#endif

struct NtContextSavedAreaStruct
{
    unsigned long n_usr_r0;
    unsigned long n_usr_r1;
    unsigned long n_usr_r2;
    unsigned long n_usr_r3;
    unsigned long n_usr_r4;
    unsigned long n_usr_r5;
    unsigned long n_usr_r6;
    unsigned long n_usr_r7;
    unsigned long n_usr_r8;
    unsigned long n_usr_r9;
    unsigned long n_usr_r10;
    unsigned long n_usr_r11;
    unsigned long n_usr_r12;
    unsigned long n_usr_sp;
    unsigned long n_usr_lr;
    unsigned long n_pc;
    unsigned long n_cpsr;
    unsigned long n_scratch;
    unsigned long n_irq_spsr;
    unsigned long n_irq_sp;
    unsigned long n_irq_lr;
    unsigned long n_svc_spsr;
    unsigned long n_svc_sp;
    unsigned long n_svc_lr;
    unsigned long n_abt_spsr;
    unsigned long n_abt_sp;
    unsigned long n_abt_lr;
    unsigned long n_und_spsr;
    unsigned long n_und_sp;
    unsigned long n_und_lr;
    unsigned long n_fiq_spsr;
    unsigned long n_fiq_r8;
    unsigned long n_fiq_r9;
    unsigned long n_fiq_r10;
    unsigned long n_fiq_r11;
    unsigned long n_fiq_r12;
    unsigned long n_fiq_sp;
    unsigned long n_fiq_lr;
};
struct TContextSavedAreaStruct
{
    unsigned long s_usr_r0;
    unsigned long s_usr_r1;
    unsigned long s_usr_r2;
    unsigned long s_usr_r3;
    unsigned long s_usr_r4;
    unsigned long s_usr_r5;
    unsigned long s_usr_r6;
    unsigned long s_usr_r7;
    unsigned long s_usr_r8;
    unsigned long s_usr_r9;
    unsigned long s_usr_r10;
    unsigned long s_usr_r11;
    unsigned long s_usr_r12;
    unsigned long s_usr_sp;
    unsigned long s_usr_lr;
    unsigned long s_pc;
    unsigned long s_cpsr;
    unsigned long s_scratch;
    unsigned long s_irq_spsr;
    unsigned long s_irq_sp;
    unsigned long s_irq_lr;
    unsigned long s_svc_spsr;
    unsigned long s_svc_sp;
    unsigned long s_svc_lr;
    unsigned long s_abt_spsr;
    unsigned long s_abt_sp;
    unsigned long s_abt_lr;
    unsigned long s_und_spsr;
    unsigned long s_und_sp;
    unsigned long s_und_lr;
    unsigned long s_fiq_spsr;
    unsigned long s_fiq_r8;
    unsigned long s_fiq_r9;
    unsigned long s_fiq_r10;
    unsigned long s_fiq_r11;
    unsigned long s_fiq_r12;
    unsigned long s_fiq_sp;
    unsigned long s_fiq_lr;
};
#endif
