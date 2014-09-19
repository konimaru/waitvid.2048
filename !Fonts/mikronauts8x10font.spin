'***************************************************************************************
'
' Mikronauts8x10font
'
' Copyright 2011 William Henning
'
' http://Mikronauts.com
' mikronauts@gmail.com
'
' DESCRIPTION:
'
' 8x10 pixel font adapted from my Morpheus fonts
'
' TERMS OF USE: MIT License
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
'
' Feb.19/2011 - v0.80 initial beta release
'
'***************************************************************************************

CON
  height = 10

PUB addr

  return @font_table

DAT

font_table ' one bit per pixel font

        byte  $FF, $FF, $C0, $03, $03, $C0, $FF, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $F0, $0F, $C0, $03, $C0, $03, $C3, $FF, $00, $00, $0F, $01, $1C
        byte  $00, $1C, $22, $14, $08, $02, $0C, $30, $20, $02, $00, $00, $00, $00, $00, $00
        byte  $1C, $08, $3E, $3E, $30, $7F, $3E, $7F, $3E, $3E, $00, $00, $60, $00, $06, $3E
        byte  $1C, $1C, $3F, $3E, $1F, $7F, $7F, $3E, $41, $3E, $7C, $21, $01, $41, $41, $1C
        byte  $1F, $1C, $3F, $7E, $7F, $41, $41, $41, $41, $41, $7F, $3E, $00, $3E, $08, $00
        byte  $04, $00, $01, $00, $40, $00, $38, $00, $01, $0C, $18, $01, $0C, $00, $00, $00
        byte  $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $70, $08, $07, $00, $55
        byte  $00, $00, $3F, $FC, $FC, $3F, $00, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $0F, $F0, $3F, $FC, $3F, $FC, $3C, $00, $FF, $FF, $F0, $FE, $E3
        byte  $FF, $E3, $DD, $EB, $F7, $FD, $F3, $CF, $DF, $FD, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $E3, $F7, $C1, $C1, $CF, $80, $C1, $80, $C1, $C1, $FF, $FF, $9F, $FF, $F9, $C1
        byte  $E3, $E3, $C0, $C1, $E0, $80, $80, $C1, $BE, $C1, $83, $DE, $FE, $BE, $BE, $E3
        byte  $E0, $E3, $C0, $81, $80, $BE, $BE, $BE, $BE, $BE, $80, $C1, $FF, $C1, $F7, $FF
        byte  $FB, $FF, $FE, $FF, $BF, $FF, $C7, $FF, $FE, $F3, $E7, $FE, $F3, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FD, $FF, $FF, $FF, $FF, $FF, $FF, $8F, $F7, $F8, $FF, $AA

        byte  $FF, $FF, $C0, $03, $03, $C0, $FF, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $FC, $3F, $C0, $03, $60, $06, $66, $FF, $00, $00, $0F, $03, $3E
        byte  $00, $1C, $22, $14, $3E, $45, $12, $30, $18, $0C, $08, $08, $00, $00, $00, $40
        byte  $22, $0C, $41, $41, $28, $01, $41, $40, $41, $41, $18, $18, $30, $00, $0C, $41
        byte  $22, $22, $41, $41, $21, $01, $01, $41, $41, $08, $10, $11, $01, $63, $41, $22
        byte  $21, $22, $41, $01, $08, $41, $41, $41, $22, $41, $20, $02, $01, $20, $14, $00
        byte  $0C, $00, $01, $00, $40, $00, $44, $00, $01, $00, $00, $01, $08, $00, $00, $00
        byte  $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $08, $08, $08, $46, $AA
        byte  $00, $00, $3F, $FC, $FC, $3F, $00, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $03, $C0, $3F, $FC, $9F, $F9, $99, $00, $FF, $FF, $F0, $FC, $C1
        byte  $FF, $E3, $DD, $EB, $C1, $BA, $ED, $CF, $E7, $F3, $F7, $F7, $FF, $FF, $FF, $BF
        byte  $DD, $F3, $BE, $BE, $D7, $FE, $BE, $BF, $BE, $BE, $E7, $E7, $CF, $FF, $F3, $BE
        byte  $DD, $DD, $BE, $BE, $DE, $FE, $FE, $BE, $BE, $F7, $EF, $EE, $FE, $9C, $BE, $DD
        byte  $DE, $DD, $BE, $FE, $F7, $BE, $BE, $BE, $DD, $BE, $DF, $FD, $FE, $DF, $EB, $FF
        byte  $F3, $FF, $FE, $FF, $BF, $FF, $BB, $FF, $FE, $FF, $FF, $FE, $F7, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FD, $FF, $FF, $FF, $FF, $FF, $FF, $F7, $F7, $F7, $B9, $55

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $0E, $70, $C0, $03, $60, $06, $66, $FF, $00, $00, $0F, $07, $3E
        byte  $00, $1C, $22, $7F, $49, $62, $0C, $20, $0C, $18, $2A, $08, $00, $00, $00, $60
        byte  $51, $0E, $40, $40, $24, $01, $01, $20, $41, $41, $18, $18, $18, $00, $18, $20
        byte  $59, $41, $41, $01, $41, $01, $01, $01, $41, $08, $10, $09, $01, $55, $43, $41
        byte  $41, $41, $21, $01, $08, $41, $41, $41, $14, $22, $10, $02, $03, $20, $22, $00
        byte  $18, $1E, $01, $00, $40, $3E, $04, $3E, $01, $0C, $3C, $21, $08, $00, $00, $1C
        byte  $1D, $5C, $00, $3E, $0F, $00, $00, $00, $00, $00, $00, $08, $08, $08, $49, $55
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $F1, $8F, $3F, $FC, $9F, $F9, $99, $00, $FF, $FF, $F0, $F8, $C1
        byte  $FF, $E3, $DD, $80, $B6, $9D, $F3, $DF, $F3, $E7, $D5, $F7, $FF, $FF, $FF, $9F
        byte  $AE, $F1, $BF, $BF, $DB, $FE, $FE, $DF, $BE, $BE, $E7, $E7, $E7, $FF, $E7, $DF
        byte  $A6, $BE, $BE, $FE, $BE, $FE, $FE, $FE, $BE, $F7, $EF, $F6, $FE, $AA, $BC, $BE
        byte  $BE, $BE, $DE, $FE, $F7, $BE, $BE, $BE, $EB, $DD, $EF, $FD, $FC, $DF, $DD, $FF
        byte  $E7, $E1, $FE, $FF, $BF, $C1, $FB, $C1, $FE, $F3, $C3, $DE, $F7, $FF, $FF, $E3
        byte  $E2, $A3, $FF, $C1, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $F7, $F7, $F7, $B6, $AA

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $07, $E0, $C0, $03, $30, $0C, $3C, $00, $FF, $00, $0F, $07, $7F
        byte  $00, $08, $00, $14, $09, $30, $0E, $10, $06, $30, $1C, $08, $00, $00, $00, $30
        byte  $49, $08, $40, $3C, $22, $3E, $3F, $10, $3E, $7E, $00, $00, $0C, $7F, $30, $10
        byte  $65, $41, $3F, $01, $41, $3F, $3F, $71, $7F, $08, $10, $07, $01, $49, $45, $41
        byte  $21, $41, $1F, $3E, $08, $41, $22, $49, $08, $14, $08, $02, $06, $20, $41, $00
        byte  $10, $20, $1F, $3E, $7C, $41, $1F, $41, $3F, $08, $10, $11, $08, $37, $1D, $22
        byte  $23, $62, $3D, $01, $02, $41, $41, $41, $41, $41, $7F, $06, $00, $30, $31, $AA
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $F8, $1F, $3F, $FC, $CF, $F3, $C3, $FF, $00, $FF, $F0, $F8, $80
        byte  $FF, $F7, $FF, $EB, $F6, $CF, $F1, $EF, $F9, $CF, $E3, $F7, $FF, $FF, $FF, $CF
        byte  $B6, $F7, $BF, $C3, $DD, $C1, $C0, $EF, $C1, $81, $FF, $FF, $F3, $80, $CF, $EF
        byte  $9A, $BE, $C0, $FE, $BE, $C0, $C0, $8E, $80, $F7, $EF, $F8, $FE, $B6, $BA, $BE
        byte  $DE, $BE, $E0, $C1, $F7, $BE, $DD, $B6, $F7, $EB, $F7, $FD, $F9, $DF, $BE, $FF
        byte  $EF, $DF, $E0, $C1, $83, $BE, $E0, $BE, $C0, $F7, $EF, $EE, $F7, $C8, $E2, $DD
        byte  $DC, $9D, $C2, $FE, $FD, $BE, $BE, $BE, $BE, $BE, $80, $F9, $FF, $CF, $CE, $55

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $FF, $FF, $FF, $1F, $FF, $F8, $F8
        byte  $1F, $1F, $F8, $03, $C0, $C0, $03, $18, $18, $18, $00, $FF, $00, $0F, $0F, $7F
        byte  $00, $08, $00, $14, $3E, $18, $51, $00, $06, $30, $7F, $7F, $0C, $7F, $00, $18
        byte  $45, $08, $3C, $40, $7F, $40, $41, $08, $41, $40, $00, $18, $06, $00, $60, $08
        byte  $25, $7F, $41, $01, $41, $01, $01, $41, $41, $08, $10, $09, $01, $41, $49, $41
        byte  $1F, $49, $21, $40, $08, $41, $22, $49, $14, $08, $04, $02, $0C, $20, $00, $00
        byte  $00, $3E, $21, $41, $42, $41, $04, $41, $41, $08, $10, $0F, $08, $49, $23, $41
        byte  $41, $41, $43, $3E, $02, $41, $41, $41, $22, $41, $30, $08, $08, $08, $00, $55
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $00, $00, $00, $E0, $00, $07, $07
        byte  $E0, $E0, $07, $FC, $3F, $3F, $FC, $E7, $E7, $E7, $FF, $00, $FF, $F0, $F0, $80
        byte  $FF, $F7, $FF, $EB, $C1, $E7, $AE, $FF, $F9, $CF, $80, $80, $F3, $80, $FF, $E7
        byte  $BA, $F7, $C3, $BF, $80, $BF, $BE, $F7, $BE, $BF, $FF, $E7, $F9, $FF, $9F, $F7
        byte  $DA, $80, $BE, $FE, $BE, $FE, $FE, $BE, $BE, $F7, $EF, $F6, $FE, $BE, $B6, $BE
        byte  $E0, $B6, $DE, $BF, $F7, $BE, $DD, $B6, $EB, $F7, $FB, $FD, $F3, $DF, $FF, $FF
        byte  $FF, $C1, $DE, $BE, $BD, $BE, $FB, $BE, $BE, $F7, $EF, $F0, $F7, $B6, $DC, $BE
        byte  $BE, $BE, $BC, $C1, $FD, $BE, $BE, $BE, $DD, $BE, $CF, $F7, $F7, $F7, $FF, $AA

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $FF, $FF, $FF, $1F, $FF, $F8, $F8
        byte  $1F, $1F, $F8, $03, $C0, $C0, $03, $18, $18, $18, $00, $FF, $00, $0F, $0F, $7F
        byte  $00, $08, $00, $7F, $48, $0C, $11, $00, $0C, $18, $1C, $08, $0C, $00, $00, $0C
        byte  $45, $08, $02, $40, $20, $40, $41, $04, $41, $20, $18, $18, $0C, $7F, $30, $08
        byte  $19, $41, $41, $01, $41, $01, $01, $41, $41, $08, $11, $11, $01, $41, $51, $41
        byte  $01, $51, $41, $40, $08, $41, $14, $55, $22, $08, $02, $02, $18, $20, $00, $00
        byte  $00, $21, $41, $01, $41, $3F, $04, $41, $41, $08, $10, $11, $08, $49, $41, $41
        byte  $23, $62, $01, $40, $02, $41, $22, $49, $1C, $41, $18, $08, $08, $08, $00, $AA
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $00, $00, $00, $E0, $00, $07, $07
        byte  $E0, $E0, $07, $FC, $3F, $3F, $FC, $E7, $E7, $E7, $FF, $00, $FF, $F0, $F0, $80
        byte  $FF, $F7, $FF, $80, $B7, $F3, $EE, $FF, $F3, $E7, $E3, $F7, $F3, $FF, $FF, $F3
        byte  $BA, $F7, $FD, $BF, $DF, $BF, $BE, $FB, $BE, $DF, $E7, $E7, $F3, $80, $CF, $F7
        byte  $E6, $BE, $BE, $FE, $BE, $FE, $FE, $BE, $BE, $F7, $EE, $EE, $FE, $BE, $AE, $BE
        byte  $FE, $AE, $BE, $BF, $F7, $BE, $EB, $AA, $DD, $F7, $FD, $FD, $E7, $DF, $FF, $FF
        byte  $FF, $DE, $BE, $FE, $BE, $C0, $FB, $BE, $BE, $F7, $EF, $EE, $F7, $B6, $BE, $BE
        byte  $DC, $9D, $FE, $BF, $FD, $BE, $DD, $B6, $E3, $BE, $E7, $F7, $F7, $F7, $FF, $55

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $E0, $07, $0C, $30, $3C, $00, $FF, $00, $0F, $1F, $3E
        byte  $00, $00, $00, $14, $49, $26, $6E, $00, $18, $0C, $2A, $08, $08, $00, $0C, $06
        byte  $22, $08, $01, $41, $20, $41, $41, $02, $41, $10, $18, $10, $18, $00, $18, $00
        byte  $42, $41, $41, $41, $21, $01, $01, $41, $41, $08, $11, $21, $01, $41, $61, $22
        byte  $01, $22, $41, $40, $08, $41, $14, $63, $41, $08, $01, $02, $30, $20, $00, $00
        byte  $00, $21, $21, $41, $42, $01, $04, $7E, $41, $08, $10, $21, $08, $49, $41, $22
        byte  $1D, $5C, $01, $41, $22, $63, $14, $55, $22, $5E, $06, $08, $08, $08, $00, $55
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $1F, $F8, $F3, $CF, $C3, $FF, $00, $FF, $F0, $E0, $C1
        byte  $FF, $FF, $FF, $EB, $B6, $D9, $91, $FF, $E7, $F3, $D5, $F7, $F7, $FF, $F3, $F9
        byte  $DD, $F7, $FE, $BE, $DF, $BE, $BE, $FD, $BE, $EF, $E7, $EF, $E7, $FF, $E7, $FF
        byte  $BD, $BE, $BE, $BE, $DE, $FE, $FE, $BE, $BE, $F7, $EE, $DE, $FE, $BE, $9E, $DD
        byte  $FE, $DD, $BE, $BF, $F7, $BE, $EB, $9C, $BE, $F7, $FE, $FD, $CF, $DF, $FF, $FF
        byte  $FF, $DE, $DE, $BE, $BD, $FE, $FB, $81, $BE, $F7, $EF, $DE, $F7, $B6, $BE, $DD
        byte  $E2, $A3, $FE, $BE, $DD, $9C, $EB, $AA, $DD, $A1, $F9, $F7, $F7, $F7, $FF, $AA

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $70, $0E, $06, $60, $66, $00, $00, $FF, $0F, $3F, $3E
        byte  $00, $08, $00, $14, $3E, $53, $00, $00, $20, $02, $08, $08, $08, $00, $0C, $03
        byte  $1C, $3E, $7F, $3E, $70, $3E, $3E, $01, $3E, $0E, $00, $08, $30, $00, $0C, $08
        byte  $3C, $41, $3F, $3E, $1F, $7F, $01, $3E, $41, $3E, $0E, $41, $7F, $41, $41, $1C
        byte  $01, $5C, $41, $3F, $08, $3E, $08, $41, $41, $08, $7F, $3E, $60, $3E, $00, $7F
        byte  $00, $5E, $1F, $3E, $7C, $7E, $04, $40, $41, $3E, $11, $41, $3E, $49, $41, $1C
        byte  $01, $40, $01, $3E, $1C, $5C, $08, $63, $41, $20, $7F, $70, $08, $07, $00, $AA
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $8F, $F1, $F9, $9F, $99, $FF, $FF, $00, $F0, $C0, $C1
        byte  $FF, $F7, $FF, $EB, $C1, $AC, $FF, $FF, $DF, $FD, $F7, $F7, $F7, $FF, $F3, $FC
        byte  $E3, $C1, $80, $C1, $8F, $C1, $C1, $FE, $C1, $F1, $FF, $F7, $CF, $FF, $F3, $F7
        byte  $C3, $BE, $C0, $C1, $E0, $80, $FE, $C1, $BE, $C1, $F1, $BE, $80, $BE, $BE, $E3
        byte  $FE, $A3, $BE, $C0, $F7, $C1, $F7, $BE, $BE, $F7, $80, $C1, $9F, $C1, $FF, $80
        byte  $FF, $A1, $E0, $C1, $83, $81, $FB, $BF, $BE, $C1, $EE, $BE, $C1, $B6, $BE, $E3
        byte  $FE, $BF, $FE, $C1, $E3, $A3, $F7, $9C, $BE, $DF, $80, $8F, $F7, $F8, $FF, $55

        byte  $03, $C0, $FF, $FF, $03, $C0, $00, $FF, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $3F, $FC, $06, $60, $66, $00, $00, $FF, $0F, $3F, $1C
        byte  $00, $00, $00, $00, $08, $20, $00, $00, $00, $00, $00, $00, $04, $00, $00, $01
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60, $00, $06, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $3F, $00, $00, $0E, $00, $00, $00, $00, $00
        byte  $01, $40, $00, $00, $00, $00, $00, $00, $00, $1F, $00, $00, $00, $00, $00, $55
        byte  $FC, $3F, $00, $00, $FC, $3F, $FF, $00, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $C0, $03, $F9, $9F, $99, $FF, $FF, $00, $F0, $C0, $E3
        byte  $FF, $FF, $FF, $FF, $F7, $DF, $FF, $FF, $FF, $FF, $FF, $FF, $FB, $FF, $FF, $FE
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $9F, $FF, $F9, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C0, $FF, $FF, $F1, $FF, $FF, $FF, $FF, $FF
        byte  $FE, $BF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $E0, $FF, $FF, $FF, $FF, $FF, $AA

        byte  $03, $C0, $FF, $FF, $03, $C0, $00, $FF, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $0F, $F0, $03, $C0, $C3, $00, $00, $FF, $0F, $7F, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $AA
        byte  $FC, $3F, $00, $00, $FC, $3F, $FF, $00, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $F0, $0F, $FC, $3F, $3C, $FF, $FF, $00, $F0, $80, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $55

DAT