ASM = vasm6502_oldstyle -Fbin -cbm-prg

all: test.prg

clean:
	rm -f test.prg

test.prg: test.asm
	$(ASM) $< -o $@
