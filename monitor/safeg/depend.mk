safeg_start.o: safeg_start.c arm.h safeg.h entry.h safeg_measures.h
serial.o: serial.c serial.h aruart.h qb_drf.h
safeg.o: safeg.S arm.h entry.h safeg_syscalls.h safeg_measures.h
crt0-safeg.o: crt0-safeg.S arm.h
entry.o: entry.h
