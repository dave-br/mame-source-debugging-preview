        SECTION blockx

StartX:
        LDX     #$10
        STB     Var
        LDB     #$11
        STB     Var
        LDB     #$12
        STB     Var
        LDB     #$02            ; Move on to block X
        STB     $FFA1
        BRA     StartB
Var:
        RMB     1

        ENDSECTION