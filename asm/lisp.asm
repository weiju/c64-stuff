        ;; Lisp runtime system, assume for now, we can freely allocate
        ;; 1. never deallocate cons-cells
        ;; cons-cells in the area from $C000-$CFFF
        ;; $C000: 2 Bytes that hold the number of cons-cells
        ;; $C002: 2 Bytes used to store return values for sub routines

        ;; memory range for cons cells ($c000-$cfff)
CC_BASE=$c000
CC_OFFSET=4

        ;; memory range for parameters ($8000-$8fff)
RETVAL=$8000
ARG1=$8002
ARG2=$8004
        
        org $1000
        JSR init
        JSR alloc_cc

        ;; just as a test
        LDA RETVAL              ; get byte offset of cons cell
        STA ARG1                ; set car -> $CAFE
        LDA #$CA
        STA ARG2
        LDA #$FE
        STA ARG2+1
        JSR set_car
        
        JSR alloc_cc

        ;; just as a test
        LDA RETVAL
        STA ARG1                ; set car -> $FACE
        LDA #$FA
        STA ARG2
        LDA #$CE
        STA ARG2+1
        JSR set_car

        BRK

init    LDA #0                   ; initialize memory
        STA CC_BASE              ; initially no cells
        STA CC_BASE+1
        RTS
        
        ;; allocate a cons-cell, the number of cells is in the 2 bytes at $C000
        ;; returns the index in RETVAL
alloc_cc
        LDA CC_BASE             ; index of cons-cell in accu
        STA RETVAL
        INC CC_BASE             ; added another cons-cell

        STA ARG1
        LDA #$33
        STA ARG2
        LDA #$44
        STA ARG2+1
        JSR set_cdr
        
        RTS

set_cdr LDA ARG1                ; cons cell index
        ASL
        ASL
        ADC #(CC_OFFSET+2)      ; cdr is 2 bytes after car
        TAY                     ; accu -> Y
        LDA ARG2                ; init value lo-byte
        STA CC_BASE,Y           ; y = byte offset within cons cell table
        LDA ARG2+1              ; init value hi-byte
        STA CC_BASE+1,Y
        RTS


set_car LDA ARG1                ; cons cell index
        ASL
        ASL
        ADC #CC_OFFSET
        TAY                     ; accu -> Y
        LDA ARG2                ; init value lo-byte
        STA CC_BASE,Y           ; y = byte offset within cons cell table
        LDA ARG2+1              ; init value hi-byte
        STA CC_BASE+1,Y
        RTS
