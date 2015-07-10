        ; A simple assembler program that is loaded to address 4096 ($1000)
        ; run with SYS 4096
        org	$1000
l1	    INC	$D020
        JMP	l1
