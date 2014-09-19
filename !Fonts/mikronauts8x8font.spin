'***************************************************************************************
'
' Mikronauts8x8font
'
' Copyright 2011 William Henning
'
' http://Mikronauts.com
' mikronauts@gmail.com
'
' DESCRIPTION:
'
' 8x8 pixel font adapted from my Morpheus fonts
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
  height = 8

PUB addr

  return @font_table

DAT

font_table ' one bit per pixel font

        byte  $FF, $FF, $C0, $03, $03, $C0, $FF, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $F0, $0F, $C0, $03, $C0, $03, $C3, $FF, $00, $00, $0F, $01, $1C
        byte  $00, $1C, $22, $14, $08, $47, $0C, $30, $20, $02, $00, $00, $00, $00, $00, $C0
        byte  $1C, $08, $3E, $3E, $18, $7F, $3E, $7F, $3E, $3E, $00, $00, $30, $00, $0C, $3E
        byte  $1C, $1C, $3F, $3E, $1F, $7F, $7F, $3E, $41, $3E, $7C, $41, $01, $41, $41, $1C
        byte  $3F, $1C, $3F, $7E, $7F, $41, $41, $41, $41, $41, $7F, $3E, $01, $3E, $08, $00
        byte  $04, $00, $01, $00, $40, $00, $38, $00, $01, $0C, $18, $01, $0C, $00, $00, $00
        byte  $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $70, $08, $07, $46, $55
        byte  $00, $00, $3F, $FC, $FC, $3F, $00, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $0F, $F0, $3F, $FC, $3F, $FC, $3C, $00, $FF, $FF, $F0, $FE, $E3
        byte  $FF, $E3, $DD, $EB, $F7, $B8, $F3, $CF, $DF, $FD, $FF, $FF, $FF, $FF, $FF, $3F
        byte  $E3, $F7, $C1, $C1, $E7, $80, $C1, $80, $C1, $C1, $FF, $FF, $CF, $FF, $F3, $C1
        byte  $E3, $E3, $C0, $C1, $E0, $80, $80, $C1, $BE, $C1, $83, $BE, $FE, $BE, $BE, $E3
        byte  $C0, $E3, $C0, $81, $80, $BE, $BE, $BE, $BE, $BE, $80, $C1, $FE, $C1, $F7, $FF
        byte  $FB, $FF, $FE, $FF, $BF, $FF, $C7, $FF, $FE, $F3, $E7, $FE, $F3, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FD, $FF, $FF, $FF, $FF, $FF, $FF, $8F, $F7, $F8, $B9, $AA

        byte  $FF, $FF, $C0, $03, $03, $C0, $FF, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $FC, $3F, $C0, $03, $60, $06, $66, $FF, $00, $00, $0F, $03, $3E
        byte  $00, $1C, $22, $14, $3E, $62, $12, $20, $18, $0C, $22, $08, $00, $00, $00, $60
        byte  $22, $0C, $41, $41, $14, $01, $41, $40, $41, $41, $00, $00, $18, $00, $18, $41
        byte  $22, $22, $41, $41, $21, $01, $01, $41, $41, $08, $10, $21, $01, $63, $43, $22
        byte  $41, $22, $41, $01, $08, $41, $41, $41, $22, $41, $20, $02, $03, $20, $14, $00
        byte  $0C, $00, $01, $00, $40, $00, $44, $00, $01, $00, $00, $01, $08, $00, $00, $00
        byte  $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $08, $08, $08, $49, $AA
        byte  $00, $00, $3F, $FC, $FC, $3F, $00, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $03, $C0, $3F, $FC, $9F, $F9, $99, $00, $FF, $FF, $F0, $FC, $C1
        byte  $FF, $E3, $DD, $EB, $C1, $9D, $ED, $DF, $E7, $F3, $DD, $F7, $FF, $FF, $FF, $9F
        byte  $DD, $F3, $BE, $BE, $EB, $FE, $BE, $BF, $BE, $BE, $FF, $FF, $E7, $FF, $E7, $BE
        byte  $DD, $DD, $BE, $BE, $DE, $FE, $FE, $BE, $BE, $F7, $EF, $DE, $FE, $9C, $BC, $DD
        byte  $BE, $DD, $BE, $FE, $F7, $BE, $BE, $BE, $DD, $BE, $DF, $FD, $FC, $DF, $EB, $FF
        byte  $F3, $FF, $FE, $FF, $BF, $FF, $BB, $FF, $FE, $FF, $FF, $FE, $F7, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FD, $FF, $FF, $FF, $FF, $FF, $FF, $F7, $F7, $F7, $B6, $55

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $00, $18, $00, $18, $18, $18, $00
        byte  $00, $18, $18, $0E, $70, $C0, $03, $30, $0C, $3C, $FF, $FF, $00, $0F, $07, $7F
        byte  $00, $1C, $22, $7F, $09, $30, $0C, $20, $0C, $18, $14, $08, $00, $00, $00, $30
        byte  $51, $08, $40, $40, $12, $01, $01, $20, $41, $41, $18, $18, $0C, $7F, $30, $20
        byte  $79, $41, $41, $01, $41, $01, $01, $01, $41, $08, $10, $11, $01, $55, $45, $41
        byte  $41, $41, $21, $01, $08, $41, $22, $41, $14, $22, $10, $02, $06, $20, $22, $00
        byte  $18, $1E, $1F, $3E, $7C, $3E, $04, $3E, $01, $0C, $3C, $21, $08, $37, $1D, $1C
        byte  $3D, $5E, $3D, $3E, $0F, $41, $41, $41, $41, $41, $7F, $08, $08, $08, $31, $55
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $FF, $E7, $FF, $E7, $E7, $E7, $FF
        byte  $FF, $E7, $E7, $F1, $8F, $3F, $FC, $CF, $F3, $C3, $00, $00, $FF, $F0, $F8, $80
        byte  $FF, $E3, $DD, $80, $F6, $CF, $F3, $DF, $F3, $E7, $EB, $F7, $FF, $FF, $FF, $CF
        byte  $AE, $F7, $BF, $BF, $ED, $FE, $FE, $DF, $BE, $BE, $E7, $E7, $F3, $80, $CF, $DF
        byte  $86, $BE, $BE, $FE, $BE, $FE, $FE, $FE, $BE, $F7, $EF, $EE, $FE, $AA, $BA, $BE
        byte  $BE, $BE, $DE, $FE, $F7, $BE, $DD, $BE, $EB, $DD, $EF, $FD, $F9, $DF, $DD, $FF
        byte  $E7, $E1, $E0, $C1, $83, $C1, $FB, $C1, $FE, $F3, $C3, $DE, $F7, $C8, $E2, $E3
        byte  $C2, $A1, $C2, $C1, $F0, $BE, $BE, $BE, $BE, $BE, $80, $F7, $F7, $F7, $CE, $AA

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $FF, $FF, $FF, $1F, $FF, $F8, $F8
        byte  $1F, $1F, $F8, $07, $E0, $C0, $03, $18, $18, $18, $FF, $FF, $00, $0F, $0F, $7F
        byte  $00, $08, $00, $14, $3E, $18, $0E, $10, $0C, $18, $7F, $7F, $0C, $7F, $00, $18
        byte  $49, $08, $3C, $3C, $11, $3E, $3F, $10, $3E, $7E, $00, $00, $06, $00, $60, $10
        byte  $25, $41, $3F, $01, $41, $3F, $3F, $71, $7F, $08, $10, $8F, $01, $55, $49, $41
        byte  $3F, $41, $1F, $3E, $08, $41, $22, $49, $08, $14, $08, $02, $0C, $20, $00, $00
        byte  $10, $20, $21, $41, $42, $41, $1F, $41, $3F, $08, $10, $11, $08, $49, $23, $22
        byte  $43, $61, $43, $01, $02, $41, $22, $49, $22, $41, $30, $06, $00, $30, $00, $AA
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $00, $00, $00, $E0, $00, $07, $07
        byte  $E0, $E0, $07, $F8, $1F, $3F, $FC, $E7, $E7, $E7, $00, $00, $FF, $F0, $F0, $80
        byte  $FF, $F7, $FF, $EB, $C1, $E7, $F1, $EF, $F3, $E7, $80, $80, $F3, $80, $FF, $E7
        byte  $B6, $F7, $C3, $C3, $EE, $C1, $C0, $EF, $C1, $81, $FF, $FF, $F9, $FF, $9F, $EF
        byte  $DA, $BE, $C0, $FE, $BE, $C0, $C0, $8E, $80, $F7, $EF, $70, $FE, $AA, $B6, $BE
        byte  $C0, $BE, $E0, $C1, $F7, $BE, $DD, $B6, $F7, $EB, $F7, $FD, $F3, $DF, $FF, $FF
        byte  $EF, $DF, $DE, $BE, $BD, $BE, $E0, $BE, $C0, $F7, $EF, $EE, $F7, $B6, $DC, $DD
        byte  $BC, $9E, $BC, $FE, $FD, $BE, $DD, $B6, $DD, $BE, $CF, $F9, $FF, $CF, $FF, $55

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $FF, $FF, $FF, $1F, $FF, $F8, $F8
        byte  $1F, $1F, $F8, $03, $C0, $E0, $07, $18, $18, $18, $00, $FF, $FF, $0F, $0F, $7F
        byte  $00, $08, $00, $7F, $48, $0C, $51, $00, $0C, $18, $14, $08, $08, $00, $00, $0C
        byte  $45, $08, $02, $40, $7F, $40, $41, $08, $41, $40, $00, $18, $0C, $7F, $30, $08
        byte  $19, $7F, $41, $01, $41, $01, $01, $41, $41, $08, $10, $11, $01, $49, $51, $41
        byte  $01, $51, $21, $40, $08, $41, $14, $55, $14, $08, $04, $02, $18, $20, $00, $00
        byte  $00, $3E, $41, $01, $41, $3F, $04, $41, $41, $08, $10, $0F, $08, $49, $41, $41
        byte  $43, $61, $01, $3E, $02, $41, $22, $55, $1C, $41, $08, $08, $08, $08, $00, $55
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $00, $00, $00, $E0, $00, $07, $07
        byte  $E0, $E0, $07, $FC, $3F, $1F, $F8, $E7, $E7, $E7, $FF, $00, $00, $F0, $F0, $80
        byte  $FF, $F7, $FF, $80, $B7, $F3, $AE, $FF, $F3, $E7, $EB, $F7, $F7, $FF, $FF, $F3
        byte  $BA, $F7, $FD, $BF, $80, $BF, $BE, $F7, $BE, $BF, $FF, $E7, $F3, $80, $CF, $F7
        byte  $E6, $80, $BE, $FE, $BE, $FE, $FE, $BE, $BE, $F7, $EF, $EE, $FE, $B6, $AE, $BE
        byte  $FE, $AE, $DE, $BF, $F7, $BE, $EB, $AA, $EB, $F7, $FB, $FD, $E7, $DF, $FF, $FF
        byte  $FF, $C1, $BE, $FE, $BE, $C0, $FB, $BE, $BE, $F7, $EF, $F0, $F7, $B6, $BE, $BE
        byte  $BC, $9E, $FE, $C1, $FD, $BE, $DD, $AA, $E3, $BE, $F7, $F7, $F7, $F7, $FF, $AA

        byte  $03, $C0, $C0, $03, $03, $C0, $00, $00, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $70, $0E, $0C, $30, $3C, $00, $FF, $FF, $0F, $1F, $3E
        byte  $00, $00, $00, $14, $3E, $26, $21, $00, $18, $0C, $22, $08, $08, $00, $0C, $06
        byte  $22, $08, $01, $41, $10, $41, $41, $04, $41, $20, $18, $10, $18, $00, $18, $00
        byte  $42, $41, $41, $41, $21, $01, $01, $41, $41, $08, $11, $21, $01, $41, $61, $22
        byte  $01, $22, $41, $40, $08, $41, $14, $63, $22, $08, $02, $02, $30, $20, $00, $00
        byte  $00, $21, $21, $41, $42, $01, $04, $7E, $41, $08, $11, $11, $08, $49, $41, $22
        byte  $3D, $5E, $01, $40, $22, $63, $14, $63, $22, $7E, $06, $08, $08, $08, $00, $AA
        byte  $FC, $3F, $3F, $FC, $FC, $3F, $FF, $FF, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $8F, $F1, $F3, $CF, $C3, $FF, $00, $00, $F0, $E0, $C1
        byte  $FF, $FF, $FF, $EB, $C1, $D9, $DE, $FF, $E7, $F3, $DD, $F7, $F7, $FF, $F3, $F9
        byte  $DD, $F7, $FE, $BE, $EF, $BE, $BE, $FB, $BE, $DF, $E7, $EF, $E7, $FF, $E7, $FF
        byte  $BD, $BE, $BE, $BE, $DE, $FE, $FE, $BE, $BE, $F7, $EE, $DE, $FE, $BE, $9E, $DD
        byte  $FE, $DD, $BE, $BF, $F7, $BE, $EB, $9C, $DD, $F7, $FD, $FD, $CF, $DF, $FF, $FF
        byte  $FF, $DE, $DE, $BE, $BD, $FE, $FB, $81, $BE, $F7, $EE, $EE, $F7, $B6, $BE, $DD
        byte  $C2, $A1, $FE, $BF, $DD, $9C, $EB, $9C, $DD, $81, $F9, $F7, $F7, $F7, $FF, $55

        byte  $03, $C0, $FF, $FF, $03, $C0, $00, $FF, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $3F, $FC, $06, $60, $66, $00, $00, $FF, $0F, $3F, $1C
        byte  $00, $08, $00, $14, $08, $73, $6E, $00, $20, $02, $00, $00, $04, $00, $0C, $03
        byte  $1C, $3E, $7F, $3E, $38, $3E, $3E, $02, $3E, $1E, $00, $08, $30, $00, $0C, $08
        byte  $3C, $41, $3F, $3E, $1F, $7F, $01, $3E, $41, $3E, $0E, $41, $7F, $41, $41, $1C
        byte  $01, $5C, $41, $3F, $08, $3E, $08, $41, $41, $08, $7F, $3E, $60, $3E, $00, $7F
        byte  $00, $5E, $1F, $3E, $7C, $7E, $04, $40, $41, $3E, $0E, $61, $3E, $49, $41, $1C
        byte  $01, $40, $01, $3E, $1C, $5C, $08, $41, $41, $40, $7F, $70, $08, $07, $00, $55
        byte  $FC, $3F, $00, $00, $FC, $3F, $FF, $00, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $C0, $03, $F9, $9F, $99, $FF, $FF, $00, $F0, $C0, $E3
        byte  $FF, $F7, $FF, $EB, $F7, $8C, $91, $FF, $DF, $FD, $FF, $FF, $FB, $FF, $F3, $FC
        byte  $E3, $C1, $80, $C1, $C7, $C1, $C1, $FD, $C1, $E1, $FF, $F7, $CF, $FF, $F3, $F7
        byte  $C3, $BE, $C0, $C1, $E0, $80, $FE, $C1, $BE, $C1, $F1, $BE, $80, $BE, $BE, $E3
        byte  $FE, $A3, $BE, $C0, $F7, $C1, $F7, $BE, $BE, $F7, $80, $C1, $9F, $C1, $FF, $80
        byte  $FF, $A1, $E0, $C1, $83, $81, $FB, $BF, $BE, $C1, $F1, $9E, $C1, $B6, $BE, $E3
        byte  $FE, $BF, $FE, $C1, $E3, $A3, $F7, $BE, $BE, $BF, $80, $8F, $F7, $F8, $FF, $AA

        byte  $03, $C0, $FF, $FF, $03, $C0, $00, $FF, $18, $00, $18, $18, $18, $00, $18, $18
        byte  $18, $00, $00, $03, $C0, $0F, $F0, $03, $C0, $C3, $00, $00, $FF, $0F, $7F, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $00, $00, $00, $00, $00, $00, $00, $3F, $00, $00, $00, $00, $00, $00, $00, $00
        byte  $01, $40, $00, $00, $00, $00, $00, $00, $00, $3F, $00, $00, $00, $00, $00, $AA
        byte  $FC, $3F, $00, $00, $FC, $3F, $FF, $00, $E7, $FF, $E7, $E7, $E7, $FF, $E7, $E7
        byte  $E7, $FF, $FF, $FC, $3F, $F0, $0F, $FC, $3F, $3C, $FF, $FF, $00, $F0, $80, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte  $FE, $BF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C0, $FF, $FF, $FF, $FF, $FF, $55

DAT