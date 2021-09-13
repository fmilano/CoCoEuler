AS=lwasm
ASFLAGS=--decb

DSKINI=decb dskini
COPY=decb copy -b  

%.bin: %.asm
	$(AS) $(CFLAGS) -o $@ $< 
 
EULER.DSK: Euler1.bin
	$(DSKINI) $@
	$(COPY) $< -r -2 $@,$(shell echo '$<' | tr '[:lower:]' '[:upper:]')

all: Euler1.bin
	
clean:
	rm -f *.bin
	rm -f *.DSK
