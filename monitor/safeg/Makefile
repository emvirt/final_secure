OBJS-C    = safeg_start.o serial.o
OBJS-A    = safeg.o crt0-safeg.o
LSCRIPT   = safeg.lds
LOADIMAGE = safeg
SRCS     =$(OBJS-C:.o=.c) $(OBJS-A:.o=.S)

all: depend.mk $(LOADIMAGE).bin

$(LOADIMAGE).elf: $(OBJS-C) $(OBJS-A) $(LSCRIPT)
	$(CC) $(LDFLAGS) -T $(LSCRIPT) $^  -o $(LOADIMAGE).elf

$(LOADIMAGE).bin: $(LOADIMAGE).elf
	$(OBJCOPY) -O binary -S $(LOADIMAGE).elf $(LOADIMAGE).bin

safeg.o: safeg.i
safeg.i: safeg.S
crt0-safeg.o: crt0-safeg.i
crt0-safeg.i: crt0-safeg.S

%.i: %.S
	$(CC) -E $(CFLAGS) -D__ASSEMBLY__ $< > $@

%.o: %.i
	$(AS) $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $<

$(LSCRIPT): $(LSCRIPT).S
	$(CC) -E -P -C $(CFLAGS) $< > $@

entry.h:
	@exec touch entry.h

depend.mk: $(SRCS) entry.h
	-@ $(RM) depend.mk
	-@ for i in $^; do\
		$(CXX) -MM $(CFLAGS) $$i >> depend.mk;\
	done
-include depend.mk

clean:
#	$(RM) -f entry.h depend.mk
	$(RM) -f depend.mk
	$(RM) -f $(LSCRIPT)
	$(RM) -f safeg.bin trust.bin non-trust.bin
	@find \( -name '*~*' -or -name '*.o' -or -name '*.i' \) -print -delete
