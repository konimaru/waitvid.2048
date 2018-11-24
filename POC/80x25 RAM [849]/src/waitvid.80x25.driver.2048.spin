''
'' VGA display 80x25 (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2018/11/23
''       Version: 0.15.LJ.1
''
'' long[par][0]: vgrp:[!Z]:vpin:[!Z]:addr = 2:1:8:5:16 -> zero (accepted) screen buffer    (4n)
'' long[par][1]:                addr:addr =      16:16 -> zero (accepted) palette/font     (2n/2n)
'' long[par][2]:                addr:addr =      16:16 -> zero (accepted) cursor locations (4n)
'' long[par][3]: frame indicator/sync lock
''
'' - character entries are words, i.e. ASCII << 8 | attribute
'' - top left corner is at highest screen memory address
''
'' - cursor location:   $00000000: both cursors off
''                      $BBBBAAAA: AAAA == BBBB, one cursor
''                      $DDDDCCCC: CCCC <> DDDD, two cursors
''
'' - cursor format:     %00000000_yyyyyyyy_xxxxxxxx_00000_mmm (see below for mode flags)
''
'' acknowledgements
'' - loader code based on work done by Phil Pilgrim (PhiPi)
''
'' 20140912: initial version (720x400@70Hz timing, %10 sync locked)
'' 20140914: dual cog timing sorted (colours are under our control)
'' 20140915: pixel loader, use internal 128 entry palette (fixed)
'' 20140916: enabled blink mode (0/1)
'' 20140918: blink mode is now an init time parameter
'' 20140919: cursor, WIP
'' 20140920: cursor implementation complete
'' 20140926: added cursor mask constant
'' 20150615: full character range (9th column is always background)
''
'' 20181124: dropped blink mode, now uses 256 entry (hub) palette
''           8th character column is copied to 9th
''
CON
  CURSOR_ON    = %100
  CURSOR_OFF   = %000
  CURSOR_ULINE = %010
  CURSOR_BLOCK = %000
  CURSOR_FLASH = %001
  CURSOR_SOLID = %000

  CURSOR_MASK  = %111
  
OBJ
  system: "core.con.system"

PUB null
'' This is not a top level object.
  
PUB init(ID, mailbox) : cog

  long[mailbox][3] := 0

  cog := system.launch( ID, @driver, mailbox) & 7
  cog := system.launch(cog, @driver, mailbox|$8000)

  repeat
  until long[mailbox][3] == $0000FFFF           ' OK (secondary/primary)

  long[mailbox][3] := 0                         ' release sync lock
  
DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

' Palette entries holds two pairs of FG/BG colours (high word: blink colours, low word: normal colours).

                long   {$062A2A06,}$82020282, $22020222, $92020292, $0A02020A, $8A02028A, $2A02022A, $AA0202AA
                long    $02828202, $82828282, $22828222, $92828292, $0A82820A, $8A82828A, $2A82822A, $AA8282AA
                long    $02222202, $82222282, $22222222, $92222292, $0A22220A, $8A22228A, $2A22222A, $AA2222AA
                long    $02929202, $82929282, $22929222, $92929292, $0A92920A, $8A92928A, $2A92922A, $AA9292AA
                long    $020A0A02, $820A0A82, $220A0A22, $920A0A92, $0A0A0A0A, $8A0A0A8A, $2A0A0A2A, $AA0A0AAA
                long    $028A8A02, $828A8A82, $228A8A22, $928A8A92, $0A8A8A0A, $8A8A8A8A, $2A8A8A2A, $AA8A8AAA
                long    $022A2A02, $822A2A82, $222A2A22, $922A2A92, $0A2A2A0A, $8A2A2A8A, $2A2A2A2A, $AA2A2AAA
                long    $02AAAA02, $82AAAA82, $22AAAA22, $92AAAA92, $0AAAAA0A, $8AAAAA8A, $2AAAAA2A, $AAAAAAAA
                long    $02565602, $82565682, $22565622, $92565692, $0A56560A, $8A56568A, $2A56562A, $AA5656AA
                long    $02D6D602, $82D6D682, $22D6D622, $92D6D692, $0AD6D60A, $8AD6D68A, $2AD6D62A, $AAD6D6AA
                long    $02767602, $82767682, $22767622, $92767692, $0A76760A, $8A76768A, $2A76762A, $AA7676AA
                long    $02F6F602, $82F6F682, $22F6F622, $92F6F692, $0AF6F60A, $8AF6F68A, $2AF6F62A, $AAF6F6AA
                long    $025E5E02, $825E5E82, $225E5E22, $925E5E92, $0A5E5E0A, $8A5E5E8A, $2A5E5E2A, $AA5E5EAA
                long    $02DEDE02, $82DEDE82, $22DEDE22, $92DEDE92, $0ADEDE0A, $8ADEDE8A, $2ADEDE2A, $AADEDEAA
                long    $027E7E02, $827E7E82, $227E7E22, $927E7E92, $0A7E7E0A, $8A7E7E8A, $2A7E7E2A, $AA7E7EAA
                long    $02FEFE02, $82FEFE82, $22FEFE22, $92FEFE92, $0AFEFE0A, $8AFEFE8A, $2AFEFE2A, $AAFEFEAA

' The following two masks are placed here to make sure cmsk is at 2n.

cmsk            long    %%3330_3330             ' xor mask for block cursor
pmsk            long    %%0000_1332             ' xor mask for underscore cursor (updated for primary)

' horizontal timing 720(720)  1(18) 6(108) 3(54)
'   vertical timing 400(400) 13(13) 2(2)  34(34)

'                               +---------------- front porch
'                               | +-------------- sync
'                               | |    +--------- back porch
'                               | |    |
vsync           mov     ecnt, #13+2+(34-2)

                cmp     ecnt, #34 wz
        if_ne   cmp     ecnt, #32 wz
        if_e    xor     sync, #$0101            ' in/active
                                                                                          
                call    #blank                                                            
                djnz    ecnt, #vsync+1

' While still in sync, figure out the blink state (used to be based on cnt) and cursor.
' hsync offers 31 hub windows.

                add     fcnt, #1                ' next frame
                cmpsub  fcnt, #36               ' N frames per phase (on/off)

                cmp     locn, #0 wz             ' check cursor availability
                mov     crs0, #0                ' default is disabled
        if_ne   rdlong  crs0, locn              ' override
        if_ne   rol     locn, #16
                mov     crs1, #0                ' default is disabled
        if_ne   rdlong  crs1, locn              ' override

                mov     vier, crs0              ' |
                call    #prep                   ' process cursor 0
                mov     crs0, vier              ' |

                mov     vier, crs1              ' |
                call    #prep                   ' process cursor 1
                mov     crs1, vier              ' |

        if_nc   call    #blank                  ' |                                       
        if_nc   call    #blank                  ' back porch remainder (primary only)     

' Vertical sync chain done, do visible area.

                mov     zwei, scrn              ' screen base address
                mov     rows, #res_y/16         ' row count

:scan           mov     scnt, #16/2/2           ' 16 double scanlines (split between primary and secondary)
                mov     eins, font              ' font base
        if_nc   add     eins, dst1              ' interleaved

:line           mov     vscl, many              ' two lines we don't use
                waitvid zero, #0                ' 317 hub windows

                call    #load                   ' load pixels and colours for the next two lines

                call    #chars                  ' |
                call    #chars                  ' display scanlines

                add     eins, dst2{512+512}     ' skip 4 scanlines
                djnz    scnt, #:line            ' for all character scanlines
                sub     zwei, #80*2             ' next row
                djnz    rows, #:scan            ' for all rows


        if_c    call    #blank                  ' secondary finishes early so
        if_c    call    #blank                  ' let him do some blank lines

        if_nc   wrlong  cnt, fcnt_              ' announce vertical blank (primary)
                
                jmp     #vsync                  ' next frame


blank           mov     vscl, line              ' 180/720
                waitvid sync, #%0000            ' latch blank line
                call    #hsync
blank_ret       ret


chars           movd    :one, #pix+0            ' |
                movd    :two, #col+0            ' restore initial settings
                movs    :two, #pix+0            ' |

                mov     vscl, hvis              ' 1/9, speed up (one pixel per frame clock)
                mov     ecnt, #80               ' character count

:one            ror     1-1, #8                 ' $000?AABB -> $BB000?AA -> $??????BB
                add     $-1, dst1               ' advance
                add     $+1, d1s1               ' advance (pipeline)
:two            waitvid 0-0, 1-1                ' emit pixels (9th column is background)
                djnz    ecnt, #$-4

                xor     :one, swap              ' ror #8 vs sar #24

' Horizontal sync embedded here due to timing constraints, only 18 clocks are allowed between waitvids.

hsync           mov     vscl, wrap              ' |
                waitvid sync, #%0001111110      ' horizontal sync pulse (1/6/3 reverse)
                mov     cnt, cnt                ' record sync point
hsync_ret
chars_ret       ret


load            muxnc   flag, $                 ' preserve carry flag

                movd    :pix0, #pix+0           ' |
                movd    :pix1, #pix+1           ' |
                movd    :pix2, #pix+2           ' re/store initial settings
                movd    :pix3, #pix+3           ' |

                movd    :col0, #col+0           ' |
                movd    :col1, #col+1           ' |
                movd    :col2, #col+2           ' same for colours
                movd    :col3, #col+3           ' |

                mov     addr, zwei              ' current screen base
                movi    addr, #80{units} -4     ' add magic marker

' Fetch pixel data and colour for four characters. Only character 4n is documented.

:loop           rdword  frqb, addr              ' {p.0.0} read ASCII + colour
                ror     frqb, #8                ' {p.0.1} select ASCII for indexed read
                mov     phsb, eins              ' {p.0.2} current font address
                rdword  pix0, phsb              ' {p.0.3} two scanlines worth of character data
                shr     frqb, #24               '               {c.0.0} select palette index for read
                mov     phsb, plte              '               {c.0.1} current palette location
:col0           rdword  0-0, phsb               '               {c.0.2} read palette entry
                add     $-1, dst4               '               {c.0.3} advance dst
                sub     addr, #3                ' {p.0.4} advance src

                rdword  frqb, addr              ' {p.1.0}
                ror     frqb, #8                ' {p.1.1}
                mov     phsb, eins              ' {p.1.2}
                rdword  pix1, phsb              ' {p.1.3}
                shr     frqb, #24               '               {c.1.0}
                mov     phsb, plte              '               {c.1.1}
:col1           rdword  1-1, phsb               '               {c.1.2}
                add     $-1, dst4               '               {c.1.3}
                sub     addr, #1                ' {p.1.4}

                rdword  frqb, addr              ' {p.2.0}
                ror     frqb, #8                ' {p.2.1}
                mov     phsb, eins              ' {p.2.2}
                rdword  pix2, phsb              ' {p.2.3}
                shr     frqb, #24               '               {c.2.0}
                mov     phsb, plte              '               {c.2.1}
:col2           rdword  2-2, phsb               '               {c.2.2}
                add     $-1, dst4               '               {c.2.3}
                sub     addr, i4s3 wc           ' {p.2.4}

                rdword  frqb, addr              ' {p.3.0}
                ror     frqb, #8                ' {p.3.1}
                mov     phsb, eins              ' {p.3.2}
                rdword  pix3, phsb              ' {p.3.3}
                shr     frqb, #24               '               {c.3.0}
                mov     phsb, plte              '               {c.3.1}
:col3           rdword  3-3, phsb               '               {c.3.2}
                add     $-1, dst4               '               {c.3.3}
'{deferred}     sub     addr, #1                ' {p.3.4}

                add     pix0, pdup              ' {p.0.5} duplicate !b15
:pix0           mov     0-0, pix0               ' {p.0.6} store final pixel data
                add     $-1, dst4               ' {p.0.7} advance dst

                add     pix1, pdup              ' {p.1.5}
:pix1           mov     1-1, pix1               ' {p.1.6}
                add     $-1, dst4               ' {p.1.7}

                add     pix2, pdup              ' {p.2.5}
:pix2           mov     2-2, pix2               ' {p.2.6}
                add     $-1, dst4               ' {p.2.7}

                add     pix3, pdup              ' {p.3.5}
:pix3           mov     3-3, pix3               ' {p.3.6}
                add     $-1, dst4               ' {p.3.7}

        if_nc   djnz    addr, #:loop            ' {p.3.4} for all characters

                mov     vier, crs0
                call    #cursor

                cmp     crs0, crs1 wz
        if_ne   mov     vier, crs1
        if_ne   call    #cursor
                
load_ret        jmpret  flag, #0-0 nr,wc        ' restore carry flag


cursor          test    vier, #%100 wz          ' cursor enabled?

                mov     temp, vier              ' local copy
                sar     temp, #1+16             ' extract y - 25
        if_z    add     temp, rows wz           ' rows = {25..1}
        if_nz   jmp     cursor_ret              ' wrong row/disabled

                test    vier, #%010 wz,wc       ' underscore(1)/block(0)
        if_nz   cmp     scnt, #1 wz
        if_nz   jmp     cursor_ret              ' wrong scanline pair

                muxc    :set, #1                ' adjust source
        
                ror     vier, #8 wc             ' carry: blink on/off
                movd    :set, vier
        if_c    cmp     fcnt, #18 wc
:set    if_nc   xor     0-0, cmsk{2n}           ' cmsk: block      
                                                ' pmsk: underscore
cursor_ret      ret


prep            mov     temp, vier              ' working copy
                shr     temp, #16               ' |
                and     temp, #255              ' extract y
                sub     temp, #25               '   y - 25
                shl     temp, #1+16             ' 2(y - 25)
                
                and     vier, xmsk              ' get rid of y
                max     vier, xlim              ' limit x to park position (auto off)
                xor     vier, #%100             ' invert on/off
                or      vier, temp              ' reinsert y

                test    vier, #%010 wz          ' underscore(1)/block(0)
                ror     vier, #8                ' align x for add
        if_nz   add     vier, #pix
        if_z    add     vier, #col
                rol     vier, #8                ' restore cursor descriptor
        
prep_ret        ret

' initialised data and/or presets

xmsk            long    $0000FF07               ' covers mode/x
xlim            long    80 << 8                 ' park position
    
fcnt            long    0                       ' blink frame count
pdup            long    $00018000               ' pixel duplicator

flag            long    0                       ' loader flag storage
swap            long    %000110 << 26 | 16      ' ror #8 vs sar #24
sync            long    hv_idle ^ $0200

wrap            long     18 << 12 | 180         '  18/180
hvis            long      1 << 12 | 9           '   1/9
line            long    180 << 12 | 720         ' 180/720
many            long      0 << 12 | 1800        ' 256/1800

scrn_           long    $00000000 -12           ' |
font_           long    $00000004 -12           ' |
locn_           long    $00000008 -12           ' |
fcnt_           long    $0000000C -12           ' mailbox addresses (local copy)        (##)

dst1            long    1 << 9                  ' dst     +/-= 1
dst2            long    2 << 9                  ' dst     +/-= 2
dst4            long    4 << 9                  ' dst     +/-= 4
d1s1            long    1 << 9  | 1             ' dst/src +/-= 1
i4s3            long    4 << 23 | 3

' Stuff below is re-purposed for temporary storage.

setup           add     trap, par wc            ' carry set -> secondary
                and     trap, hram              ' confine to hub RAM

                add     scrn_, trap             ' @long[par][0]
                add     font_, trap             ' @long[par][1]
                add     locn_, trap             ' @long[par][2]
                add     fcnt_, trap             ' @long[par][3]

                addx    trap, #%00              ' add secondary offset
                wrbyte  hram, trap              ' up and running

                rdlong  temp, trap wz           ' |                                     (%%)
        if_nz   jmp     #$-1                    ' synchronized start

'   primary: cnt + 0              
' secondary: cnt + 2

                rdlong  scrn, scrn_             ' get screen address  (4n)              (%%)
                wrlong  zero, scrn_             ' acknowledge screen buffer setup

                rdlong  font, font_             ' get font definition (2n)              (%%)
                wrlong  zero, font_             ' acknowledge font definition setup

                mov     plte, font              ' get palette location (2n)             (%%)
                shr     plte, #16               ' |

                rdlong  locn, locn_ wz          ' get cursor location                   (%%)
        if_nz   wrlong  zero, locn_             ' acknowledge cursor location

' Perform pending setup.

                add     scrn, $+1               ' scrn now points to last byte
                long    160*25 -1

' Upset video h/w and relatives.

                rdlong  temp, #0                ' clkfreq
                shr     temp, #10               ' ~1ms
        if_nc   waitpne $, #0                   ' adjust primary

'   primary: cnt + 0 + 6          
' secondary: cnt + 2 + 4

                add     temp, cnt

                movi    ctrb, #%0_11111_000     ' LOGIC always (loader support)
                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 28.322MHz
                
                mov     vscl, #1                ' reload as fast as possible
                mov     zwei, scrn              ' vgrp:mode:vpin:[!Z]:scrn = 2:1:8:5:16 (%%)
                shr     zwei, #5+16             ' |
                or      zwei, #%%000_3          ' |
                mov     vcfg, zwei              ' set vgrp and vpin
                movi    vcfg, #%0_01_0_00_000   ' VGA, 2 colour mode

                waitcnt temp, #0                ' PLL settled, frame counter flushed
                                                  
                ror     vcfg, #1                ' freeze video h/w
                mov     vscl, line              ' transfer user value
                rol     vcfg, #1                ' unfreeze
                waitpne $, #0                   ' get some distance
                waitvid zero, #0                ' latch user value

                and     mask, vcfg              ' transfer vpin
                mov     temp, vcfg              ' |
                shr     temp, #9                ' extract vgrp
                shl     temp, #3                ' 0..3 >> 0..24
                shl     mask, temp              ' finalise mask

                max     dira, mask              ' drive outputs
                mov     $000, pal0              ' restore colour entry 0
        if_nc   shl     pmsk, #8                ' adjust underscore cursor (bytes swapped)
                jmp     #vsync                  ' return

' Local data, used only once.

pal0            long    dcolour|hv_idle         ' first palette entry
frqx            long    $16A85879               ' 28.322MHz
mask            long    %11111111

hram            long    $00007FFF               ' hub RAM mask  
trap            long    $FFFF8000 +12           ' primary/secondary trap                (##)

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup

scrn            res     1                       ' screen buffer         < setup +10     (%%)
font            res     1                       ' font definition       < setup +12     (%%)
plte            res     1                       ' palette location      < setup +14     (%%)
locn            res     1                       ' cursor location       < setup +16     (%%)
ecnt            res     1                       ' element count
scnt            res     1                       ' scanlines (per char)

temp            res     alias                   '                       < setup + 8     (%%)
addr            res     1                       ' current screen base
rows            res     1                       ' display row count
crs0            res     1                       ' cursor 0 location and mode
crs1            res     1                       ' cursor 1 location and mode

eins            res     1
zwei            res     1                       '                       < setup < 28    (%%)
vier            res     1

pix0            res     1
pix1            res     1
pix2            res     1
pix3            res     1

pix             res     80 +1                   ' emitter pixel array |
col             res     80 +1                   ' emitter colour data | + park position

tail            fit
                
DAT                                             ' translation table

__table         word    (@__names - @__table)/2

                word    res_x
                word    res_y
                word    res_m
                
__names         byte    "res_x", 0
                byte    "res_y", 0
                byte    "res_m", 0

CON
  zero    = $1F0                                ' par (dst only)
  hv_idle = $01010101 * %10 {%hv}               ' h/v sync inactive
  dcolour = %%0010_0220_0220_0010               ' default colour
  
  res_x   = 720                                 ' |
  res_y   = 400                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0
  
DAT