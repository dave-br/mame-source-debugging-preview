        SECTION blocka
StartA  EXPORT

StartA:
; Some comments that only
; appear in
; Block A
        LDA     #0
        STA     Var
        LDA     #1
        STA     Var
; We're still in Block A
        LDA     #2
        STA     Var
; And we're lovin' it
        LDA     #$01            ; Move on to blockb
        STA     $FFA1
; Here's some NOP padding so Var appears at same
; logical address as in blockb
        NOP
        NOP
Var:
        RMB     1

        ENDSECTION