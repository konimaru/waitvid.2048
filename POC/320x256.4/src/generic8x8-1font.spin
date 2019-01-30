''
'' Font data (one bit/pixel, 8x8) extracted (and extended) from
''
''   Gameduino PASM library for Propeller ASC
''   Written by Martin Hodge, with help from kuroneko & Alessandro De Luca
''   Oct, 2011 ; v1.1
''
''   Based on "Gameduino library for arduino"
''   Copyright (c) 2011 by James Bowman <jamesb@excamera.com>
''
''        Author: Marko Lukat
'' Last modified: 2012/03/18
''       Version: 0.2
''        Layout: one scan line per character
''
CON
  height = 8

PUB addr

  return @font

DAT

font    byte    $00, $00, $00, $00, $3C, $3C, $FF, $FF, $04, $00, $00, $00, $18, $18, $00, $18
        byte    $00, $18, $18, $18, $18, $00, $66, $66, $55, $0F, $0F, $0F, $0F, $00, $00, $00
        byte    $00, $18, $36, $6C, $30, $06, $1C, $30, $30, $0C, $00, $00, $00, $00, $00, $00
        byte    $3C, $18, $3C, $3C, $30, $7E, $38, $7E, $3C, $3C, $00, $00, $30, $00, $0C, $3C
        byte    $3C, $3C, $3E, $3C, $1E, $7E, $7E, $3C, $66, $7E, $7C, $66, $06, $C6, $66, $3C
        byte    $3E, $3C, $3E, $3C, $7E, $66, $66, $C6, $66, $66, $7E, $3E, $00, $7C, $18, $00
        byte    $38, $00, $06, $00, $60, $00, $38, $00, $06, $18, $18, $06, $1C, $00, $00, $00
        byte    $00, $00, $00, $00, $0C, $00, $00, $00, $00, $00, $00, $30, $18, $0C, $8C, $00
        byte    $FF, $FF, $FF, $FF, $C3, $C3, $00, $00, $FB, $FF, $FF, $FF, $E7, $E7, $FF, $E7
        byte    $FF, $E7, $E7, $E7, $E7, $FF, $99, $99, $AA, $F0, $F0, $F0, $F0, $FF, $FF, $FF
        byte    $FF, $E7, $C9, $93, $CF, $F9, $E3, $CF, $CF, $F3, $FF, $FF, $FF, $FF, $FF, $FF
        byte    $C3, $E7, $C3, $C3, $CF, $81, $C7, $81, $C3, $C3, $FF, $FF, $CF, $FF, $F3, $C3
        byte    $C3, $C3, $C1, $C3, $E1, $81, $81, $C3, $99, $81, $83, $99, $F9, $39, $99, $C3
        byte    $C1, $C3, $C1, $C3, $81, $99, $99, $39, $99, $99, $81, $C1, $FF, $83, $E7, $FF
        byte    $C7, $FF, $F9, $FF, $9F, $FF, $C7, $FF, $F9, $E7, $E7, $F9, $E3, $FF, $FF, $FF
        byte    $FF, $FF, $FF, $FF, $F3, $FF, $FF, $FF, $FF, $FF, $FF, $CF, $E7, $F3, $73, $FF

        byte    $08, $10, $18, $18, $42, $42, $81, $C3, $0C, $00, $00, $00, $18, $18, $00, $18
        byte    $00, $18, $18, $18, $18, $FF, $E7, $66, $AA, $0F, $0F, $0F, $0F, $00, $00, $00
        byte    $00, $18, $36, $6C, $FC, $66, $36, $18, $18, $18, $18, $18, $00, $00, $00, $60
        byte    $66, $1C, $66, $66, $38, $06, $0C, $60, $66, $66, $00, $00, $18, $00, $18, $66
        byte    $66, $66, $66, $66, $36, $06, $06, $66, $66, $18, $30, $36, $06, $EE, $66, $66
        byte    $66, $66, $66, $66, $18, $66, $66, $C6, $66, $66, $60, $06, $06, $60, $3C, $00
        byte    $6C, $00, $06, $00, $60, $00, $0C, $00, $06, $00, $00, $06, $18, $00, $00, $00
        byte    $00, $00, $00, $00, $0C, $00, $00, $00, $00, $00, $00, $18, $18, $18, $D6, $18
        byte    $F7, $EF, $E7, $E7, $BD, $BD, $7E, $3C, $F3, $FF, $FF, $FF, $E7, $E7, $FF, $E7
        byte    $FF, $E7, $E7, $E7, $E7, $00, $18, $99, $55, $F0, $F0, $F0, $F0, $FF, $FF, $FF
        byte    $FF, $E7, $C9, $93, $03, $99, $C9, $E7, $E7, $E7, $E7, $E7, $FF, $FF, $FF, $9F
        byte    $99, $E3, $99, $99, $C7, $F9, $F3, $9F, $99, $99, $FF, $FF, $E7, $FF, $E7, $99
        byte    $99, $99, $99, $99, $C9, $F9, $F9, $99, $99, $E7, $CF, $C9, $F9, $11, $99, $99
        byte    $99, $99, $99, $99, $E7, $99, $99, $39, $99, $99, $9F, $F9, $F9, $9F, $C3, $FF
        byte    $93, $FF, $F9, $FF, $9F, $FF, $F3, $FF, $F9, $FF, $FF, $F9, $E7, $FF, $FF, $FF
        byte    $FF, $FF, $FF, $FF, $F3, $FF, $FF, $FF, $FF, $FF, $FF, $E7, $E7, $E7, $29, $E7

        byte    $0C, $30, $3C, $18, $81, $99, $81, $A5, $1C, $18, $00, $00, $18, $18, $00, $18
        byte    $00, $18, $18, $18, $18, $FF, $E7, $66, $55, $0F, $0F, $0F, $0F, $00, $00, $00
        byte    $00, $18, $36, $FE, $16, $30, $36, $0C, $0C, $30, $7E, $18, $00, $00, $00, $30
        byte    $76, $18, $60, $60, $3C, $3E, $06, $30, $66, $66, $18, $18, $0C, $7E, $30, $30
        byte    $76, $66, $66, $06, $66, $06, $06, $06, $66, $18, $30, $1E, $06, $FE, $6E, $66
        byte    $66, $66, $66, $06, $18, $66, $66, $D6, $3C, $66, $30, $06, $0C, $60, $66, $00
        byte    $0C, $3C, $3E, $3C, $7C, $3C, $0C, $7C, $3E, $1C, $1C, $66, $18, $6C, $3E, $3C
        byte    $3E, $7C, $36, $7C, $3E, $66, $66, $C6, $66, $66, $7E, $18, $18, $18, $62, $7E
        byte    $F3, $CF, $C3, $E7, $7E, $66, $7E, $5A, $E3, $E7, $FF, $FF, $E7, $E7, $FF, $E7
        byte    $FF, $E7, $E7, $E7, $E7, $00, $18, $99, $AA, $F0, $F0, $F0, $F0, $FF, $FF, $FF
        byte    $FF, $E7, $C9, $01, $E9, $CF, $C9, $F3, $F3, $CF, $81, $E7, $FF, $FF, $FF, $CF
        byte    $89, $E7, $9F, $9F, $C3, $C1, $F9, $CF, $99, $99, $E7, $E7, $F3, $81, $CF, $CF
        byte    $89, $99, $99, $F9, $99, $F9, $F9, $F9, $99, $E7, $CF, $E1, $F9, $01, $91, $99
        byte    $99, $99, $99, $F9, $E7, $99, $99, $29, $C3, $99, $CF, $F9, $F3, $9F, $99, $FF
        byte    $F3, $C3, $C1, $C3, $83, $C3, $F3, $83, $C1, $E3, $E3, $99, $E7, $93, $C1, $C3
        byte    $C1, $83, $C9, $83, $C1, $99, $99, $39, $99, $99, $81, $E7, $E7, $E7, $9D, $81

        byte    $7E, $7E, $7E, $18, $81, $BD, $81, $99, $3C, $3C, $F8, $1F, $F8, $1F, $FF, $18
        byte    $FF, $FF, $F8, $1F, $FF, $00, $00, $66, $AA, $0F, $0F, $0F, $0F, $00, $00, $00
        byte    $00, $18, $00, $6C, $7C, $18, $1C, $00, $0C, $30, $3C, $7E, $00, $7E, $00, $18
        byte    $7E, $18, $30, $38, $36, $60, $3E, $18, $3C, $7C, $18, $18, $06, $00, $60, $18
        byte    $56, $7E, $3E, $06, $66, $3E, $3E, $76, $7E, $18, $30, $0E, $06, $D6, $7E, $66
        byte    $3E, $66, $3E, $3C, $18, $66, $66, $D6, $18, $3C, $18, $06, $18, $60, $42, $00
        byte    $3E, $60, $66, $66, $66, $66, $3E, $66, $66, $18, $18, $36, $18, $FE, $66, $66
        byte    $66, $66, $6E, $06, $0C, $66, $66, $D6, $3C, $66, $30, $0E, $00, $70, $00, $18
        byte    $81, $81, $81, $E7, $7E, $42, $7E, $66, $C3, $C3, $07, $E0, $07, $E0, $00, $E7
        byte    $00, $00, $07, $E0, $00, $FF, $FF, $99, $55, $F0, $F0, $F0, $F0, $FF, $FF, $FF
        byte    $FF, $E7, $FF, $93, $83, $E7, $E3, $FF, $F3, $CF, $C3, $81, $FF, $81, $FF, $E7
        byte    $81, $E7, $CF, $C7, $C9, $9F, $C1, $E7, $C3, $83, $E7, $E7, $F9, $FF, $9F, $E7
        byte    $A9, $81, $C1, $F9, $99, $C1, $C1, $89, $81, $E7, $CF, $F1, $F9, $29, $81, $99
        byte    $C1, $99, $C1, $C3, $E7, $99, $99, $29, $E7, $C3, $E7, $F9, $E7, $9F, $BD, $FF
        byte    $C1, $9F, $99, $99, $99, $99, $C1, $99, $99, $E7, $E7, $C9, $E7, $01, $99, $99
        byte    $99, $99, $91, $F9, $F3, $99, $99, $29, $C3, $99, $CF, $F1, $FF, $8F, $FF, $E7

        byte    $7E, $7E, $18, $7E, $81, $BD, $81, $99, $3C, $3C, $F8, $1F, $F8, $1F, $FF, $18
        byte    $FF, $FF, $F8, $1F, $FF, $00, $00, $66, $55, $FF, $F0, $0F, $00, $FF, $F0, $0F
        byte    $00, $18, $00, $FE, $D0, $0C, $B6, $00, $0C, $30, $7E, $18, $00, $00, $00, $0C
        byte    $6E, $18, $18, $60, $7E, $60, $66, $0C, $66, $60, $00, $00, $0C, $7E, $30, $18
        byte    $76, $66, $66, $06, $66, $06, $06, $66, $66, $18, $30, $1E, $06, $D6, $76, $66
        byte    $06, $56, $36, $60, $18, $66, $66, $FE, $3C, $18, $0C, $06, $30, $60, $00, $00
        byte    $0C, $7C, $66, $06, $66, $7E, $0C, $66, $66, $18, $18, $1E, $18, $D6, $66, $66
        byte    $66, $66, $06, $3C, $0C, $66, $66, $D6, $18, $66, $18, $18, $18, $18, $00, $00
        byte    $81, $81, $E7, $81, $7E, $42, $7E, $66, $C3, $C3, $07, $E0, $07, $E0, $00, $E7
        byte    $00, $00, $07, $E0, $00, $FF, $FF, $99, $AA, $00, $0F, $F0, $FF, $00, $0F, $F0
        byte    $FF, $E7, $FF, $01, $2F, $F3, $49, $FF, $F3, $CF, $81, $E7, $FF, $FF, $FF, $F3
        byte    $91, $E7, $E7, $9F, $81, $9F, $99, $F3, $99, $9F, $FF, $FF, $F3, $81, $CF, $E7
        byte    $89, $99, $99, $F9, $99, $F9, $F9, $99, $99, $E7, $CF, $E1, $F9, $29, $89, $99
        byte    $F9, $A9, $C9, $9F, $E7, $99, $99, $01, $C3, $E7, $F3, $F9, $CF, $9F, $FF, $FF
        byte    $F3, $83, $99, $F9, $99, $81, $F3, $99, $99, $E7, $E7, $E1, $E7, $29, $99, $99
        byte    $99, $99, $F9, $C3, $F3, $99, $99, $29, $E7, $99, $E7, $E7, $E7, $E7, $FF, $FF

        byte    $0C, $30, $18, $3C, $81, $99, $81, $A5, $1C, $18, $18, $18, $00, $00, $00, $18
        byte    $18, $00, $18, $18, $18, $FF, $E7, $66, $AA, $FF, $F0, $0F, $00, $FF, $F0, $0F
        byte    $00, $00, $00, $6C, $7E, $66, $66, $00, $18, $18, $18, $18, $18, $00, $18, $06
        byte    $66, $18, $0C, $66, $30, $66, $66, $0C, $66, $30, $18, $18, $18, $00, $18, $00
        byte    $06, $66, $66, $66, $36, $06, $06, $66, $66, $18, $36, $36, $06, $C6, $66, $66
        byte    $06, $36, $66, $66, $18, $66, $3C, $EE, $66, $18, $06, $06, $60, $60, $00, $00
        byte    $0C, $66, $66, $66, $66, $06, $0C, $7C, $66, $18, $18, $36, $18, $D6, $66, $66
        byte    $3E, $7C, $06, $60, $0C, $66, $3C, $FE, $3C, $7C, $0C, $18, $18, $18, $00, $7E
        byte    $F3, $CF, $E7, $C3, $7E, $66, $7E, $5A, $E3, $E7, $E7, $E7, $FF, $FF, $FF, $E7
        byte    $E7, $FF, $E7, $E7, $E7, $00, $18, $99, $55, $00, $0F, $F0, $FF, $00, $0F, $F0
        byte    $FF, $FF, $FF, $93, $81, $99, $99, $FF, $E7, $E7, $E7, $E7, $E7, $FF, $E7, $F9
        byte    $99, $E7, $F3, $99, $CF, $99, $99, $F3, $99, $CF, $E7, $E7, $E7, $FF, $E7, $FF
        byte    $F9, $99, $99, $99, $C9, $F9, $F9, $99, $99, $E7, $C9, $C9, $F9, $39, $99, $99
        byte    $F9, $C9, $99, $99, $E7, $99, $C3, $11, $99, $E7, $F9, $F9, $9F, $9F, $FF, $FF
        byte    $F3, $99, $99, $99, $99, $F9, $F3, $83, $99, $E7, $E7, $C9, $E7, $29, $99, $99
        byte    $C1, $83, $F9, $9F, $F3, $99, $C3, $01, $C3, $83, $F3, $E7, $E7, $E7, $FF, $81

        byte    $08, $10, $18, $18, $42, $42, $81, $C3, $0C, $00, $18, $18, $00, $00, $00, $18
        byte    $18, $00, $18, $18, $18, $FF, $E7, $66, $55, $FF, $F0, $0F, $00, $FF, $F0, $0F
        byte    $00, $18, $00, $6C, $18, $60, $DC, $00, $30, $0C, $00, $00, $18, $00, $18, $00
        byte    $3C, $7E, $7E, $3C, $30, $3C, $3C, $0C, $3C, $1C, $18, $18, $30, $00, $0C, $18
        byte    $3C, $66, $3E, $3C, $1E, $7E, $06, $3C, $66, $7E, $1C, $66, $7E, $C6, $66, $3C
        byte    $06, $6C, $66, $3C, $18, $3C, $18, $C6, $66, $18, $7E, $3E, $00, $7C, $00, $00
        byte    $7E, $7C, $3E, $3C, $7C, $3C, $0C, $60, $66, $3C, $18, $66, $3C, $C6, $66, $3C
        byte    $06, $60, $06, $3E, $38, $7C, $18, $6C, $66, $60, $7E, $30, $18, $0C, $00, $00
        byte    $F7, $EF, $E7, $E7, $BD, $BD, $7E, $3C, $F3, $FF, $E7, $E7, $FF, $FF, $FF, $E7
        byte    $E7, $FF, $E7, $E7, $E7, $00, $18, $99, $AA, $00, $0F, $F0, $FF, $00, $0F, $F0
        byte    $FF, $E7, $FF, $93, $E7, $9F, $23, $FF, $CF, $F3, $FF, $FF, $E7, $FF, $E7, $FF
        byte    $C3, $81, $81, $C3, $CF, $C3, $C3, $F3, $C3, $E3, $E7, $E7, $CF, $FF, $F3, $E7
        byte    $C3, $99, $C1, $C3, $E1, $81, $F9, $C3, $99, $81, $E3, $99, $81, $39, $99, $C3
        byte    $F9, $93, $99, $C3, $E7, $C3, $E7, $39, $99, $E7, $81, $C1, $FF, $83, $FF, $FF
        byte    $81, $83, $C1, $C3, $83, $C3, $F3, $9F, $99, $C3, $E7, $99, $C3, $39, $99, $C3
        byte    $F9, $9F, $F9, $C1, $C7, $83, $E7, $93, $99, $9F, $81, $CF, $E7, $F3, $FF, $FF

        byte    $00, $00, $00, $00, $3C, $3C, $FF, $FF, $04, $00, $18, $18, $00, $00, $00, $18
        byte    $18, $00, $18, $18, $18, $00, $66, $66, $AA, $FF, $F0, $0F, $00, $FF, $F0, $0F
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0C, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0C, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF
        byte    $00, $00, $00, $00, $00, $00, $00, $3C, $00, $00, $0E, $00, $00, $00, $00, $00
        byte    $06, $E0, $00, $00, $00, $00, $00, $00, $00, $3C, $00, $00, $00, $00, $00, $00
        byte    $FF, $FF, $FF, $FF, $C3, $C3, $00, $00, $FB, $FF, $E7, $E7, $FF, $FF, $FF, $E7
        byte    $E7, $FF, $E7, $E7, $E7, $FF, $99, $99, $55, $00, $0F, $F0, $FF, $00, $0F, $F0
        byte    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $F3, $FF, $FF, $FF
        byte    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $F3, $FF, $FF, $FF, $FF
        byte    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        byte    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
        byte    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C3, $FF, $FF, $F1, $FF, $FF, $FF, $FF, $FF
        byte    $F9, $1F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C3, $FF, $FF, $FF, $FF, $FF, $FF

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT