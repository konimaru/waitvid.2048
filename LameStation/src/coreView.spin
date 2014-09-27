''
''        Author: Marko Lukat
'' Last modified: 2014/06/19
''       Version: 0.6
''
'' 20140610: announce frame ID change immediately after work is done
'' 20140611: relaxed interface timing
'' 20140618: added SCREEN_* constants
'' 20140619: introduced auto-attach for internal screen buffer
''
CON
  #0, LCD_S[0], DI, EN, DB[8], CSA, CSB, LCD_E{xclusive}

  SYNC_PERIOD = 80_000_000/73
  BUSY_PERIOD = 400

  SCREEN_W = 128
  SCREEN_H = 64

VAR
  long  insn
  long  sync

PUB null
'' This is not a top level object.

PUB init(primary)
'' Initializes the viewer object and any underlying graphics driver.
''
'' parameters
''  primary: optional screen buffer (to be attached at index 0) or
''           NULL (internal screen buffer if available)
''
'' result
''   Aborts when any part of the initialization fails, otherwise an address
''   of an internal buffer which can be used as a screen buffer (DAT reuse)
''   or NULL of no such buffer is available.

  ifnot cognew(@screen, @insn) +1
    abort

  setn(primary, 0)                                      ' make sure cog is running
  longfill(@screen{0}, 0, 128)                          ' before making DAT public
  ifnot primary
    setn(@screen{0}, 0)                                 ' auto-attach DAT

  return @screen{0}

PUB setn(address, sidx)
'' Add or remove a screen buffer from display.
''
'' parameters
''  address: ... of 128x64 px buffer or NULL (remove)
''     sidx: screen index (must be 0)

  ifnot sidx
    sidx.word[1] := address
    insn := sidx|%100

    repeat
    while insn

PUB waitVBL
'' Block execution until vertical sync pulse starts.

  repeat
  until sync
  repeat
  while sync                                            ' 1/0 transition

DAT                     org     0                       ' single screen LCD driver

screen                  jmpret  $, #setup               ' once

main                    movs    read, #line             ' reset
                        call    #translateLCD           ' flip data for this page

                        mov     eins, rcnt
                        or      eins, CMD_SetPage       ' chip select embedded
                        call    #sendLCDcommand         ' set page

fill                    mov     ccnt, #64

                        mov     eins, scrn wz           ' |
read            if_nz   mov     eins, line              ' read data or black (detached)
                        add     $-1, #1                 ' |

                        mov     zwei, eins
                        shr     zwei, #8

                        test    idnt, #1 wc             ' even or odd frame?
                if_nc   andn    eins, zwei              ' apply gray value
                        and     eins, dmsk              ' limit to valid pins

                        or      eins, CMD_WriteByte     ' chip select embedded
                        call    #sendLCDcommand         ' send data

                        djnz    ccnt, #read-1           ' for all columns

                        test    CMD_WriteByte, LCD_CE_L wz
                        xor     CMD_WriteByte, LCD_CE_B ' swap displays (L/R)
                if_nz   jmp     #fill                   ' |

                        cmp     rcnt, rmsk wz           ' check recently drawn page
                if_ne   jmp     #main                   ' for all pages

                        xor     idnt, #1                ' toggle frame identifier
                        wrlong  idnt, blnk              ' and announce it

                        waitcnt LCD_time, LCD_frameperiod

                        rdlong  eins, par wz            ' |
                if_nz   shr     eins, #16               ' |
                if_nz   mov     scrn, eins              ' update display buffer
                if_nz   wrlong  zero, par               ' acknowledge command

                        jmp     #main                   ' next frame

' min enable pulse width: 450ns
' min address setup time: 140ns (before enable high)
'     min data hold time:  10ns
'
' cycle timing assumes 80MHz system clock

sendLCDcommand          mov     outa, eins              ' DI(RS), data, CSA/B

                        mov     cnt, cnt
                        add     cnt, #9{14} + BUSY_PERIOD
'                                     |            |
'                                     |            +----  covers busy period
'                                     +-----------------  (14+4)*12.5ns = 225ns

                        waitcnt cnt, #40                ' 500ns
                        or      outa, LCD_Enable

                        waitcnt cnt, #0
                        andn    outa, LCD_Enable

sendLCDcommand_ret      ret

' Given screen dimensions of 128x64 pixel and 2 bits/pixel we're looking at
' a linear buffer of 64*128*2 bits == 64*32 bytes == 2K. The LCD buffers needs
' the bytes effectively rotated by 90 deg.
'
'    +---------------+---------------+    An 8x8 pixel block holds 16bytes or
' R0 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    8 words. The LCD expects data to be
'    +---------------+---------------+    formatted in a way that all 0 bits
' R1 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    are delivered first starting with R0.0
'    +---------------+---------------+    in bit position 0 and R7.0 in position
' R2 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    7. This new byte is followed by column
'    +---------------+---------------+    1 and so on until column F.
' R3 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+    To achieve this we scan all 16x8 blocks
' R4 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    of the structure shown to the left. This
'    +---------------+---------------+    gives us outer and inner loop. Address
' R5 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    offsets increment by 2 (word) for each
'    +---------------+---------------+    column and 8*32 == 256 for each row.
' R6 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+
' R7 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+

translateLCD            add     rcnt, radv              ' 8 blocks of 8 rows
                        and     rcnt, rmsk wz

                if_z    mov     addr, scrn              ' |
                        movd    :set, #line             ' rewind

                        mov     ccnt, #16               ' 16 blocks of 8 columns

' read 8 words of an 8x8 pixel block (words are separated by a whole line, 32 bytes)

:columns                rdword  xsrc+0, addr            ' load 8x8 pixel block
                        add     addr, #32
                        rdword  xsrc+1, addr
                        add     addr, #32
                        rdword  xsrc+2, addr
                        add     addr, #32
                        rdword  xsrc+3, addr
                        add     addr, #32
                        rdword  xsrc+4, addr
                        add     addr, #32
                        rdword  xsrc+5, addr
                        add     addr, #32
                        rdword  xsrc+6, addr
                        add     addr, #32
                        rdword  xsrc+7, addr

                        mov     bcnt, #8                ' scan 8 columns

:loop                   shr     xsrc+0, #1 wc           ' extract even column(s)
                        rcr     trgt, #1
                        shr     xsrc+1, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+2, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+3, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+4, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+5, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+6, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+7, #1 wc
                        rcr     trgt, #1

                        shr     xsrc+0, #1 wc           ' extract odd column(s)
                        rcr     trgt, #1
                        shr     xsrc+1, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+2, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+3, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+4, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+5, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+6, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+7, #1 wc
                        rcr     trgt, #17 -DB

:set                    mov     line, trgt              ' store one pixel column
                        add     :set, dst1              ' advance destination

                        djnz    bcnt, #:loop

                        sub     addr, #32*7 -2          ' rewind loader, next 8 columns
                        djnz    ccnt, #:columns

                        add     addr, #256 -32          ' next 8 rows
translateLCD_ret        ret                             ' return

' initialised data and/or presets

LCD_time                long    SYNC_PERIOD
LCD_frameperiod         long    SYNC_PERIOD

CMD_DisplayOff          long    %11 << CSA | $3E << DB
CMD_DisplayOn           long    %11 << CSA | $3F << DB
CMD_SetAddress          long    %11 << CSA | $40 << DB  ' +0..63
CMD_SetPage             long    %11 << CSA | $B8 << DB  ' +0..7

CMD_WriteByte           long    %01 << CSA | $00 << DB | 1 << DI

LCD_CE_L                long    %01 << CSA
LCD_CE_B                long    %11 << CSA

LCD_Enable              long    1 << EN

mask                    long    |< LCD_E - |< LCD_S

scrn                    long    0                       ' active screen buffer
idnt                    long    0                       ' frame ID (even/odd)
dst1                    long    |< 9                    ' dst +/-= 1

dmsk                    long    $FF << DB

rmsk                    long    $07 << DB
radv                    long    $01 << DB
rcnt                    long    $07 << DB               ' row counter 0..7

blnk                    long    4                       ' frame identifier

' Stuff below is re-purposed for temporary storage.

setup                   mov     dira, mask              ' drive outputs
                        add     blnk, par               ' @long[par][1]
                        add     LCD_time, cnt           ' finalize 1st frame target

                        mov     eins, CMD_DisplayOn     ' chip select embedded
                        call    #sendLCDcommand         ' turn on LCD

                        mov     eins, CMD_SetAddress    ' chip select embedded
                        call    #sendLCDcommand         ' reset address

                        jmp     %%0                     ' return

EOD{ata}                fit     128

' uninitialised data and/or temporaries

                        org     setup

addr                    res     1
trgt                    res     1

reuse                   res     alias

xsrc                    res     8
bcnt                    res     1
ccnt                    res     1

line                    res     128

tail                    fit

' aliases (different functions share VAR space)

                        org     reuse

eins                    res     1
zwei                    res     1

                        fit     tail

{screen padding}        long    0[0 #> (128 - (@EOD - @screen) / 4)]

                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $55555405, $55555555, $55555555, $55555555, $00000000, $00000000, $00000150, $00000000
                        long    $40555405, $40555405, $55400405, $55400555, $00155150, $00155000, $15000150, $00155000
                        long    $40155405, $40555405, $54000005, $54000055, $01555550, $01555500, $15400150, $01555500
                        long    $50055405, $40555405, $50000005, $50000015, $05555550, $05555540, $05500150, $05555540
                        long    $54015405, $40555405, $40155005, $50155015, $05400550, $05400540, $01540150, $05400540
                        long    $55005405, $40555405, $40555405, $40555405, $15000150, $15000150, $00550150, $15000150
                        long    $55400005, $40555405, $55555405, $40555405, $15000150, $15555550, $00155550, $15000150
                        long    $55500005, $40555405, $55555405, $40555405, $15000150, $15555550, $00055550, $15000150
                        long    $55500005, $40555405, $55555405, $40555405, $15000150, $15555550, $00055550, $15000150
                        long    $55400005, $40555405, $55555405, $40555405, $15000150, $00000150, $00155550, $15000150
                        long    $55005405, $40555405, $55555405, $40555405, $15000150, $00000150, $00550150, $15000150
                        long    $54015405, $40155015, $55555405, $50155015, $15000150, $15000540, $01540150, $05400540
                        long    $50055405, $40000015, $55555405, $50000015, $15000150, $15555540, $05500150, $05555540
                        long    $40155405, $40000055, $55555405, $54000055, $15000150, $05555500, $15400150, $01555500
                        long    $40555405, $40400555, $55555405, $55400555, $15000150, $00555000, $15000150, $00155000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000
                        long    $55555555, $55555555, $55555555, $55555555, $00000000, $00000000, $00000000, $00000000

EndOfLogo               long    0[0 #> (512 - (@EndOfLogo - @screen) / 4)]

CON
  zero  = $1F0                                          ' par (dst only)

  alias = 0

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