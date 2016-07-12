/*
 * Copyright 2010 NVIDIA Corporation.  All Rights Reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and
 * proprietary rights in and to this software and related documentation.  Any
 * use, reproduction, disclosure or distribution of this software and related
 * documentation without an express license agreement from NVIDIA Corporation
 * is strictly prohibited.
 */



#ifndef _QB_SERIAL_H_
#define _QB_SERIAL_H_

#define NV_WRITE08(a,d)     *((volatile unsigned char *)(a)) = (d)
#define NV_WRITE16(a,d)     *((volatile unsigned short *)(a)) = (d)
#define NV_WRITE32(a,d)     *((volatile unsigned int *)(a)) = (d)
#define NV_READ8(a)         *((const volatile unsigned char *)(a))
#define NV_READ16(a)        *((const volatile unsigned short *)(a))
#define NV_READ32(a)        *((const volatile unsigned int *)(a))

#define QB_MAX_SERIAL_PORTS  (5)

// FIXME : Should this be made (READ,WRITE)8 ?
#define UART_REG_READ32(UartRegsVirtBaseAdd, reg) \
    NV_READ32((unsigned long *)(UartRegsVirtBaseAdd) + ((UART_##reg##_0)/4))
#define UART_REG_WRITE32(UartRegsVirtBaseAdd, reg, val) \
    do { \
        NV_WRITE32((((unsigned long *)(UartRegsVirtBaseAdd) + ((UART_##reg##_0)/4))), (val)); \
    } while(0)

int QbSerialProbe(void);
int QbSerialRead(void *Buffer, unsigned int Size);
#endif // _QB_SERIAL_H_
