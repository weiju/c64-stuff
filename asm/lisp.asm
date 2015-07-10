        ;; Lisp runtime system, assume for now, we can freely allocate
        
        ;; 1. every value is 16 bit
        ;; 2. values have a 3 bit tag
        ;;   a. 0 = cons cell index
        ;;   b. 1 = integer
        ;;   c. 2 = char
        ;; 2. never deallocate cons-cells
        

        ;; memory range for cons cells ($c000-$cfff)
        ;; first 2 bytes hold number of cons cells
CC_BASE=$c000
CC_OFFSET=4
CC_NIL=0

        ;; memory range for parameters ($8000-$8fff)
RETVAL=$8000
ARG1=$8002
ARG2=$8004
SCRATCH1=$8ffc
SCRATCH2=$8ffe
        
        org $1000
        JSR init

        ;; just as a test
        JSR alloc_cc
        LDA RETVAL              ; get byte offset of cons cell
        STA SCRATCH1            ; save for later
        STA ARG1                ; set car -> $CAFE
        LDA #$CA
        STA ARG2
        LDA #$FE
        STA ARG2+1
        JSR set_car

        ;; just as a test
        JSR alloc_cc
        LDA RETVAL
        STA SCRATCH2
        STA ARG1                ; set car -> $FACE
        LDA #$FA
        STA ARG2
        LDA #$CE
        STA ARG2+1
        JSR set_car

        ;; test (cons cc1 cc2)
        LDA SCRATCH1
        STA ARG1
        LDA #0
        STA ARG1+1
        LDA SCRATCH2
        STA ARG2
        LDA #0
        STA ARG2+1
        JSR set_cdr
        
        BRK

        ;; initialize the Lisp runtime
init    LDA #0                  ; initialize memory
        STA CC_BASE             ; initially no cells
        STA CC_BASE+1
        JSR alloc_cc            ; except slot 0 -> NIL
        RTS
        
        ;; allocate a cons-cell, the number of cells is in the 2 bytes at $C000
        ;; returns the index in RETVAL
alloc_cc
        LDA CC_BASE             ; index of cons-cell in accu
        STA RETVAL              ; current number is return value
        INC CC_BASE             ; increment number of cons cells
        STA ARG1                ; set cdr -> 0
        LDA #$00
        STA ARG2
        STA ARG2+1
        JSR set_cdr
        RTS

        ;; cc[ARG1].cdr -> ARG2
        ;; can be used as cons as well: ARG2 is index within cc table
cons
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


        ;; cc[ARG1].car -> ARG2
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

        ;; return cc[ARG1].car
car     LDA ARG1                ; cons cell index
        ASL
        ASL
        ADC #CC_OFFSET
        TAY                     ; accu -> Y
        LDA CC_BASE,Y
        STA RETVAL
        LDA CC_BASE+1,Y
        STA RETVAL+1
        RTS

        ;; return cc[ARG1].cdr
cdr     LDA ARG1                ; cons cell index
        ASL
        ASL
        ADC #(CC_OFFSET+2)
        TAY                     ; accu -> Y
        LDA CC_BASE,Y
        STA RETVAL
        LDA CC_BASE+1,Y
        STA RETVAL+1
        RTS
