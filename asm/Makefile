ASM = vasm6502_oldstyle -Fbin

all: test.prg lisp.prg

clean:
	rm -f *.prg

test.prg: test.asm
	$(ASM) -cbm-prg $< -o $@


lisp.prg: lisp.asm
	$(ASM) -cbm-prg $< -o $@

