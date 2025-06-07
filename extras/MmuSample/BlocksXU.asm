        SECTION blockx

StartX:
        LDX     #$1111
        STX     VarX
        LDX     #$2222
        STX     VarX
        NOP
        NOP
        NOP
        LDB     #$03            ; Move on to block U
        STB     $FFA1
        BRA     StartX
VarX:
        RMB     2

        ENDSECTION



        SECTION blocku

StartU:
        LDU     #$3333
        STU     VarU
        LDU     #$4444
        STU     VarU
        LDU     #$5555
        STU     VarU
        RTS                                        ; Tour complete
        NOP
        BRA     StartU
VarU:
        RMB     2

        ENDSECTION