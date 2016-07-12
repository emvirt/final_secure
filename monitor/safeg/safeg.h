/*
 *  TOPPERS/SafeG Dual-OS monitor
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Safety Gate Dual-OS monitor
 *
 *  Copyright (C) 2009-2011 by Embedded and Real-Time Systems Laboratory
 *     Graduate School of Information Science, Nagoya University, JAPAN
 *
 *  �嵭����Ԥϡ��ʲ���(1)��(4)�ξ������������˸¤ꡤ�ܥ��եȥ���
 *  �����ܥ��եȥ���������Ѥ�����Τ�ޤࡥ�ʲ�Ʊ���ˤ���ѡ�ʣ������
 *  �ѡ������ۡʰʲ������ѤȸƤ֡ˤ��뤳�Ȥ�̵���ǵ������롥
 *  (1) �ܥ��եȥ������򥽡��������ɤη������Ѥ�����ˤϡ��嵭������
 *      ��ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ��꤬�����Τޤޤη��ǥ���
 *      ����������˴ޤޤ�Ƥ��뤳�ȡ�
 *  (2) �ܥ��եȥ������򡤥饤�֥������ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ�����Ǻ����ۤ�����ˤϡ������ۤ�ȼ���ɥ�����ȡ�����
 *      �ԥޥ˥奢��ʤɡˤˡ��嵭�����ɽ�����������Ѿ�浪��Ӳ���
 *      ��̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *  (3) �ܥ��եȥ������򡤵�����Ȥ߹���ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ��ʤ����Ǻ����ۤ�����ˤϡ����Τ����줫�ξ�����������
 *      �ȡ�
 *    (a) �����ۤ�ȼ���ɥ�����ȡ����Ѽԥޥ˥奢��ʤɡˤˡ��嵭����
 *        �ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *    (b) �����ۤη��֤��̤�������ˡ�ˤ�äơ�TOPPERS�ץ������Ȥ�
 *        ��𤹤뤳�ȡ�
 *  (4) �ܥ��եȥ����������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������뤤���ʤ�»
 *      ������⡤�嵭����Ԥ����TOPPERS�ץ������Ȥ����դ��뤳�ȡ�
 *      �ޤ����ܥ��եȥ������Υ桼���ޤ��ϥ���ɥ桼������Τ����ʤ���
 *      ͳ�˴�Ť����ᤫ��⡤�嵭����Ԥ����TOPPERS�ץ������Ȥ�
 *      ���դ��뤳�ȡ�
 *
 *  �ܥ��եȥ������ϡ�̵�ݾڤ��󶡤���Ƥ����ΤǤ��롥�嵭����Ԥ�
 *  ���TOPPERS�ץ������Ȥϡ��ܥ��եȥ������˴ؤ��ơ�����λ�����Ū
 *  ���Ф���Ŭ������ޤ�ơ������ʤ��ݾڤ�Ԥ�ʤ����ޤ����ܥ��եȥ���
 *  �������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������������ʤ�»���˴ؤ��Ƥ⡤��
 *  ����Ǥ�����ʤ���
 *
 */
#ifndef _SAFEG_H_
#define _SAFEG_H_

/* IRQ �������*/
#define IRQ_COUNT    0x000FFFF8
/* FIQ �������*/
#define FIQ_COUNT    0x000FFFFC

/*
 * irq, fiq ��������뤿��δؿ�
 * tz_basic.S �� irq, fiq �ϥ�ɥ����ǸƤФ��.
 * �����δؿ���˹Ԥ����������򵭽Ҥ���.
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
