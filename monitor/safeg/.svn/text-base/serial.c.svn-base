/*
 * Copyright 2010 NVIDIA Corporation.  All Rights Reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and
 * proprietary rights in and to this software and related documentation.  Any
 * use, reproduction, disclosure or distribution of this software and related
 * documentation without an express license agreement from NVIDIA Corporation
 * is strictly prohibited.
 */

#include <serial.h>
#include <aruart.h>
#include <qb_drf.h>

#define NVBL_PLLP_KHZ               (408000)
#define UART_CLOCK (NVBL_PLLP_KHZ * 1000)
typedef enum {
    Uart_Src_PLL_P = 0,
    Uart_Src_CLK_M = 3,
} UartClkSource;

typedef struct QbAddressMapRec {
    unsigned int Base;
    unsigned int Limit;
    unsigned int Size;
}QbAddressMap;

#define NV_ADDRESS_MAP_UART \
    {\
         0x70006000,\
         0x7000603F,\
         0x00000040,\
    },\
    {\
        0x70006040,\
        0x7000607F,\
        0x00000040,\
    },\
    {\
        0x70006200,\
        0x700062FF,\
        0x00000100,\
    },\
    {\
        0x70006300,\
        0x700063FF,\
        0x00000100,\
    },\
    {\
        0x70006400,\
        0x700064FF,\
        0x00000100,\
    }


static void QbSerialSetBaudRate(unsigned int RegBase/*, unsigned int BaudRate*/)
{
    unsigned int LineControlReg, DivisorLSB, DivisorMSB = 0;
    unsigned short BaudRateRegVal;
    // FIXME : Check for supported BaudRates
    BaudRateRegVal = (unsigned short)((UART_CLOCK / 16/* / BaudRate*//115200)/* + 0.5*/);
    // Allow programming of the DLH, DLM Divisors
    LineControlReg = UART_REG_READ32(RegBase, LCR);
    LineControlReg =
        NV_FLD_SET_DRF_DEF(UART, LCR, DLAB, ENABLE, LineControlReg);
    UART_REG_WRITE32(RegBase, LCR, LineControlReg);
    // Write LSB of the BaudRate
    DivisorLSB = UART_REG_READ32(RegBase, THR_DLAB_0);
    DivisorLSB =
        NV_FLD_SET_DRF_NUM(UART, THR_DLAB_0, DLL_A, (BaudRateRegVal & 0xff),
                   DivisorLSB);
    UART_REG_WRITE32(RegBase, THR_DLAB_0, DivisorLSB);
    // Write the MSB of the Baudrate
    // FIXME : Cannot use NV_FLD_SET macros
    DivisorMSB |= ((BaudRateRegVal & 0xff00) >> 8);
    UART_REG_WRITE32(RegBase, IER_DLAB_0, DivisorMSB);
    // Disable Divisor Programming
    LineControlReg = UART_REG_READ32(RegBase, LCR);
    LineControlReg =
        NV_FLD_SET_DRF_DEF(UART, LCR, DLAB, DISABLE, LineControlReg);
    UART_REG_WRITE32(RegBase, LCR, LineControlReg);
}

static int QbSerialConfigParam(unsigned int RegBase, unsigned char StopBits,
               unsigned char WordLength, unsigned char Parity)
{
    unsigned int LineControlReg, ModemControlReg, FifoControlReg;
    LineControlReg = UART_REG_READ32(RegBase, LCR);
    switch (WordLength) {
    case 5:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, WD_SIZE, WORD_LENGTH_5,
                       LineControlReg);
        break;
    case 6:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, WD_SIZE, WORD_LENGTH_6,
                       LineControlReg);
        break;
    case 7:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, WD_SIZE, WORD_LENGTH_7,
                       LineControlReg);
        break;
    case 8:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, WD_SIZE, WORD_LENGTH_8,
                       LineControlReg);
        break;
    default:
        return -1;
    }
    switch (StopBits) {
    case 0:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, STOP, DISABLE,
                       LineControlReg);
        break;
    case 1:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, STOP, ENABLE, LineControlReg);
        break;
    default:
        return -1;
    }
    switch (Parity) {
        // FIXME : Supports only No parity case. Since for parity we need to take care of even/odd parity
    case 0:
        LineControlReg =
            NV_FLD_SET_DRF_DEF(UART, LCR, PAR, NO_PARITY, LineControlReg);
        break;
    default:
        return -1;
    }
    UART_REG_WRITE32(RegBase, LCR, LineControlReg);
    // FIXME : Support for Handshaking
    // Disable all handshaking
    ModemControlReg = UART_REG_READ32(RegBase, MCR);
    ModemControlReg =
        NV_FLD_SET_DRF_DEF(UART, MCR, RTS_EN, DISABLE, LineControlReg);
    ModemControlReg =
        NV_FLD_SET_DRF_DEF(UART, MCR, CTS_EN, DISABLE, LineControlReg);
    UART_REG_WRITE32(RegBase, MCR, ModemControlReg);
    // FCR Programming
    // Enable FIFO's, Reset RX,TX FIFO's
    FifoControlReg = UART_REG_READ32(RegBase, IIR_FCR);
    FifoControlReg =
        NV_FLD_SET_DRF_DEF(UART, IIR_FCR, FCR_EN_FIFO, ENABLE, LineControlReg);
    FifoControlReg =
        NV_FLD_SET_DRF_DEF(UART, IIR_FCR, RX_CLR, CLEAR, LineControlReg);
    FifoControlReg =
        NV_FLD_SET_DRF_DEF(UART, IIR_FCR, TX_CLR, CLEAR, LineControlReg);
    UART_REG_WRITE32(RegBase, IIR_FCR, FifoControlReg);
    return 0;
}

unsigned int RegPhyBase, RegLen;

int QbSerialProbe()
{
    int err = 0;
    QbAddressMap nv_address_map_uart[] = { NV_ADDRESS_MAP_UART };

    RegPhyBase = nv_address_map_uart[0].Base;
    RegLen = nv_address_map_uart[0].Size;

    QbSerialSetBaudRate((unsigned int)RegPhyBase/*, 115200*/);

    err =
        QbSerialConfigParam((unsigned int)RegPhyBase, 1, 8, 0);

    if (err) {
        return err;
    }

    // Empty the receive FIFO
    // TODO: have some timeout here
    while( UART_REG_READ32(RegPhyBase, LSR) & 1) {
        UART_REG_READ32(RegPhyBase, THR_DLAB_0);
    }

    return err;
}

static void QbSerialPutc(unsigned int RegBase, unsigned char c)
{
    while (1)
    {
        volatile unsigned int LineStatus;
        LineStatus = UART_REG_READ32(RegBase, LSR);
        if (NV_DRF_VAL(UART, LSR, THRE, LineStatus))
        {
            break;
        }
    }
    // Transmit Register is Write Only
    UART_REG_WRITE32(RegBase, THR_DLAB_0, c);
}

static int QbSerialGetc(unsigned int RegBase,char *c)
{
    if(UART_REG_READ32(RegBase,LSR) & 1) {
        *c = UART_REG_READ32(RegBase,THR_DLAB_0);
        return 0;
    } else {
        return -1;
    }
}

void QbSerialSend(void *Buffer, unsigned int size)
{
    unsigned int i, RegBase = (unsigned int)RegPhyBase;
    char *Msg = (char*)(Buffer);

    for (i=0; i < size; i++)
    {
        //FIXME: Add an ioctl to control this operation.
        if(Msg[i] == '\n')
            QbSerialPutc(RegBase, '\r');
        QbSerialPutc(RegBase, Msg[i]);
    }

}

int QbSerialRead(void *Buffer, unsigned int Size)
{
    unsigned int RegBase = (unsigned int)RegPhyBase;
    unsigned int BytesToRead=Size;

    if(Size == 0)
        return 0;

    while((QbSerialGetc(RegBase,(char *)&((char *)Buffer)[Size - BytesToRead]) != -1)) {
        BytesToRead--;
        if(!BytesToRead)
            break;
    }

    return Size - BytesToRead;
}

