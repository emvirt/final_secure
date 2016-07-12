#include <linux/kernel.h>
#include <linux/io.h>
#include <asm/hardware/gic.h>

/*HJPARK: send IPI8 to normal core*/
asmlinkage int sys_newcall(){
	int cpu = 1;
	int irq=8;

	writel_relaxed( 1 << ( 16 + cpu ) | irq, 0xf2a01000 + GIC_DIST_SOFTINT);
	
	return 0;
}
