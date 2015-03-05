''
'' VGA driver 320x256 (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2015/03/05
''       Version: 0.24
''
'' long[par][0]:           [!Z]:addr =     16:16 -> zero (accepted) screen buffer           (4n)
'' long[par][1]: addr:[!Z]:addr:[!Z] = 14:2:14:2 -> zero (accepted) cursor/colour buffer    (4n/4n)
'' long[par][2]:           [!Z]:addr =     16:16 -> zero (accepted) palette, runtime update (4n)
'' long[par][3]: frame indicator
''
'' cursor format: %00000000_yyyyyyyy_xxxxxxxx_00000_mmm
'' - mode flags are ignored, only solid block mode is supported
'' - out of range values disable cursor
''
'' acknowledgements
'' - loader code based on work done by Phil Pilgrim (PhiPi)
''
'' 20130420: initial version (1280x1024@60Hz timing, %00 sync locked)
'' 20130422: added palette update code
'' 20130502: revoked palette update code, now embedded for speed (doubled colour resolution)
'' 20130503: minor change to palette format
'' 20130504: reinstated palette update code
'' 20150301: minor cleanup (investigation into adding a cursor)
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

PUB init(ID, mailbox)
                                      
  return system.launch(ID, @driver, mailbox)

DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

' A palette entry holds two pairs of FG/BG colours (high word: blink colours, low word: normal colours).

                long               $0C00000C, $30000030, $3C00003C, $C00000C0, $CC0000CC, $F00000F0, $FC0000FC
                long    $00000800, $0C00080C, $30000830, $3C00083C, $C00008C0, $CC0008CC, $F00008F0, $FC0008FC
                long    $00001000, $0C00100C, $30001030, $3C00103C, $C00010C0, $CC0010CC, $F00010F0, $FC0010FC
                long    $00001800, $0C00180C, $30001830, $3C00183C, $C00018C0, $CC0018CC, $F00018F0, $FC0018FC
                long    $00002000, $0C00200C, $30002030, $3C00203C, $C00020C0, $CC0020CC, $F00020F0, $FC0020FC
                long    $00002800, $0C00280C, $30002830, $3C00283C, $C00028C0, $CC0028CC, $F00028F0, $FC0028FC
                long    $00003000, $0C00300C, $30003030, $3C00303C, $C00030C0, $CC0030CC, $F00030F0, $FC0030FC
                long    $00003800, $0C00380C, $30003830, $3C00383C, $C00038C0, $CC0038CC, $F00038F0, $FC0038FC
                long    $00008000, $0C00800C, $30008030, $3C00803C, $C00080C0, $CC0080CC, $F00080F0, $FC0080FC
                long    $00008800, $0C00880C, $30008830, $3C00883C, $C00088C0, $CC0088CC, $F00088F0, $FC0088FC
                long    $00009000, $0C00900C, $30009030, $3C00903C, $C00090C0, $CC0090CC, $F00090F0, $FC0090FC
                long    $00009800, $0C00980C, $30009830, $3C00983C, $C00098C0, $CC0098CC, $F00098F0, $FC0098FC
                long    $0000A000, $0C00A00C, $3000A030, $3C00A03C, $C000A0C0, $CC00A0CC, $F000A0F0, $FC00A0FC
                long    $0000A800, $0C00A80C, $3000A830, $3C00A83C, $C000A8C0, $CC00A8CC, $F000A8F0, $FC00A8FC
                long    $0000B000, $0C00B00C, $3000B030, $3C00B03C, $C000B0C0, $CC00B0CC, $F000B0F0, $FC00B0FC
                long    $0000B800, $0C00B80C, $3000B830, $3C00B83C, $C000B8C0, $CC00B8CC, $F000B8F0, $FC00B8FC

'               mov     ecnt, #1
vsync           call    #blank                  ' front porch
'               djnz    ecnt, #$-1

                xor     sync, #$0101            ' active

                mov     ecnt, #3
                call    #blank                  ' vertical sync
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

' Put some distance between vertical blank indication and cursor/palette request fetch.

                rdlong  updt, updt_ wz          ' fetch palette update request
        if_nz   wrlong  zero, updt_             ' acknowledge
        if_nz   ror     updt, #1{/2}            ' half but keep non-zero marker
        if_nz   add     sub7, dst128            ' |
        if_nz   add     sub1, dst128            ' reset loader

' The first four back porch lines are used to (optionally) update the palette.

                mov     ecnt, #4
                call    #blank                  ' back porch (1/3)
                djnz    ecnt, #$-1

                mov     updt, #0                ' done
                
                mov     ecnt, #38 -4 -16
                call    #blank                  ' back porch (2/3)
                djnz    ecnt, #$-1

' Handle cursor update/preparation (ctrb inactive now)

                rdbyte  phsb, crsx              ' horizontal position
                max     phsb, #res_x/8          ' out of range is invisible
                ror     phsb, #2                ' long index, keep byte lane
                add     phsb, #pix              ' base address
                movd    crs3, phsb              ' insert xor target

                shr     phsb, #30-3             ' byte lane *8
                mov     pmsk, #$FF              ' xor mask
                shl     pmsk, phsb              ' final location

                rdbyte  phsb, crsy              ' vertical position
                shl     phsb, #5                ' in scanlines
                sub     phsb, resy              ' adjustment (upside down)

' The last 16 invisible lines are used for fetching colour. This will cause
' pixel updates but they are not emitted so that's OK.

                mov     zwei, plte              ' reset colour buffer

                mov     scnt, #16               ' scnt is key value ...
                call    #blank                  ' back porch (3/3)
                call    #fetch                  ' ... for colour fetch
                djnz    scnt, #$-2

' Vertical sync chain done, do visible area.

                mov     eins, scrn              ' reset screen buffer
                mov     scnt, resy              ' actual scanline count (x4)

:loop           call    #fetch                  ' 4n: pixels, else colour
                call    #emit                     
                call    #hsync

                djnz    scnt, #:loop            ' for all scanlines

                wrlong  cnt, fcnt_              ' announce vertical blank

                jmp     #vsync                  ' next frame


blank           mov     vscl, phsa              ' 256/960
                waitvid sync, #%0000

                cmp     updt, #0 wz             ' enabled?
        if_e    jmp     #hsync                  ' nothing to do

                mov     phsb, #32 * 4 -1        ' byte count (8n + 7)
                
sub7    if_be   rdlong  511, phsb               ' |
                sub     $-1, dst2               ' |
                sub     phsb, #7 wz             ' |
sub1    if_be   rdlong  510, phsb               ' |
                sub     $-1, dst2               ' sub #7/djnz (Thanks Phil!)
        if_nz   djnz    phsb, #sub7             ' load 32(*4) palette entries

hsync           mov     vscl, slow              '   6/306
                waitvid sync, slow_value

                mov     cnt, cnt                ' record sync point                     (##)
                add     cnt, #9{14} + 260       '                                       (##)

                mov     vcfg, vcfg_sync         ' switch back to sync mode
hsync_ret
blank_ret       ret


fetch           mov     drei, scnt              ' working copy
                and     drei, #%00001111        ' extract line index
                test    drei, #%11 wz           ' 4n?
        if_z    jmp     #:cpy

                cmp     drei, #3 wc             ' |
        if_c    jmp     fetch_ret               ' stop after 10 invocations


                rdlong  drei, zwei              '  +0 = fetch colour
                test    blnk, cnt wz            '       test flash interval
                add     zwei, #4                '       advance address

'               shr     drei, #0                '       4n+0

                movs    :rd0, drei              '  +0 = prime call
                andn    :rd0, #%110000000       '       limit index
                test    drei, #%010000000 wc    '       test blink mode
:rd0            mov     vier, 0-0               '       palette entry
    if_c_and_z  shr     vier, #16               '  +0 = use secondary colour pair
:wr0            mov     two+0, vier             '       transfer to hidden palette

                shr     drei, #8                '       4n+1
                
                movs    :rd1, drei              '       prime call
                andn    :rd1, #%110000000       '  +0 = limit index
                test    drei, #%010000000 wc    '       test blink mode
:rd1            mov     vier, 0-0               '       palette entry
    if_c_and_z  shr     vier, #16               '       use secondary colour pair
:wr1            mov     two+1, vier             '  +0 = transfer to hidden palette

                shr     drei, #8                '       4n+2

                movs    :rd2, drei              '       prime call
                andn    :rd2, #%110000000       '       limit index
                test    drei, #%010000000 wc    '  +0 = test blink mode
:rd2            mov     vier, 0-0               '       palette entry
    if_c_and_z  shr     vier, #16               '       use secondary colour pair
:wr2            mov     two+2, vier             '       transfer to hidden palette

                shr     drei, #8                '  +0 = 4n+3

                movs    :rd3, drei              '       prime call
                andn    :rd3, #%110000000       '       limit index
                test    drei, #%010000000 wc    '       test blink mode
:rd3            mov     vier, 0-0               '  +0 = palette entry
    if_c_and_z  shr     vier, #16               '       use secondary colour pair
:wr3            mov     two+3, vier             '       transfer to hidden palette

                add     :wr0, dst4              '       |
                add     :wr1, dst4              '  +0 = |
                add     :wr2, dst4              '       |
                add     :wr3, dst4              '       advance index

                jmp     fetch_ret


:cpy            rdlong  pix+0, eins             '   0..31
                add     eins, #4
{slot}          test    scnt, #%00001111 wz     '               check start of block
                rdlong  pix+1, eins             '  32..63
                add     eins, #4
{slot}  if_z    movd    :wr0, #two+0            '               prime insn (reset)
                rdlong  pix+2, eins             '  64..95
                add     eins, #4
{slot}  if_z    movd    :wr1, #two+1            '               prime insn (reset)
                rdlong  pix+3, eins             '  96..127
                add     eins, #4
{slot}  if_z    movd    :wr2, #two+2            '               prime insn (reset)
                rdlong  pix+4, eins             ' 128..159
                add     eins, #4
{slot}  if_z    movd    :wr3, #two+3            '               prime insn (reset)
                rdlong  pix+5, eins             ' 160..191
                add     eins, #4
{slot}'         nop                             '               empty
                rdlong  pix+6, eins             ' 192..223
                add     eins, #4
crs0            neg     vier, phsb              '               res_y*4-y*32
                rdlong  pix+7, eins             ' 224..255
                add     eins, #4
crs1            sub     vier, scnt              '               res_y*4-y*32-scnt
                rdlong  pix+8, eins             ' 256..287
                add     eins, #4
crs2            shr     vier, #5 wz             '               check character line
                rdlong  pix+9, eins             ' 288..319
                add     eins, #4
crs3    if_z    xor     0-0, pmsk               '               apply block cursor

fetch_ret       ret


emit            waitcnt cnt, #0                 ' re-sync after back porch              (##)

                mov     vcfg, vcfg_norm         ' disconnect sync from video h/w
                mov     vscl, hvis              ' pixel timing

                test    scnt, #%00001111 wz     ' 16n

        if_z    mov     one+$0, two+$0
                waitvid one+$0, pix+0
                ror     pix+0, #8
        if_z    mov     one+$1, two+$1
                waitvid one+$1, pix+0
                ror     pix+0, #8
        if_z    mov     one+$2, two+$2
                waitvid one+$2, pix+0
                ror     pix+0, #8
        if_z    mov     one+$3, two+$3
                waitvid one+$3, pix+0
                ror     pix+0, #8    

        if_z    mov     one+$4, two+$4
                waitvid one+$4, pix+1
                ror     pix+1, #8
        if_z    mov     one+$5, two+$5
                waitvid one+$5, pix+1
                ror     pix+1, #8
        if_z    mov     one+$6, two+$6
                waitvid one+$6, pix+1
                ror     pix+1, #8
        if_z    mov     one+$7, two+$7
                waitvid one+$7, pix+1
                ror     pix+1, #8    

        if_z    mov     one+$8, two+$8
                waitvid one+$8, pix+2
                ror     pix+2, #8
        if_z    mov     one+$9, two+$9
                waitvid one+$9, pix+2
                ror     pix+2, #8
        if_z    mov     one+10, two+10
                waitvid one+10, pix+2
                ror     pix+2, #8
        if_z    mov     one+11, two+11
                waitvid one+11, pix+2
                ror     pix+2, #8    

        if_z    mov     one+12, two+12
                waitvid one+12, pix+3 
                ror     pix+3, #8
        if_z    mov     one+13, two+13
                waitvid one+13, pix+3 
                ror     pix+3, #8
        if_z    mov     one+14, two+14
                waitvid one+14, pix+3 
                ror     pix+3, #8
        if_z    mov     one+15, two+15
                waitvid one+15, pix+3 
                ror     pix+3, #8     

        if_z    mov     one+16, two+16
                waitvid one+16, pix+4 
                ror     pix+4, #8
        if_z    mov     one+17, two+17
                waitvid one+17, pix+4 
                ror     pix+4, #8
        if_z    mov     one+18, two+18
                waitvid one+18, pix+4 
                ror     pix+4, #8
        if_z    mov     one+19, two+19
                waitvid one+19, pix+4 
                ror     pix+4, #8     

        if_z    mov     one+20, two+20
                waitvid one+20, pix+5 
                ror     pix+5, #8
        if_z    mov     one+21, two+21
                waitvid one+21, pix+5 
                ror     pix+5, #8
        if_z    mov     one+22, two+22
                waitvid one+22, pix+5 
                ror     pix+5, #8
        if_z    mov     one+23, two+23
                waitvid one+23, pix+5 
                ror     pix+5, #8     

        if_z    mov     one+24, two+24
                waitvid one+24, pix+6 
                ror     pix+6, #8
        if_z    mov     one+25, two+25
                waitvid one+25, pix+6 
                ror     pix+6, #8
        if_z    mov     one+26, two+26
                waitvid one+26, pix+6 
                ror     pix+6, #8
        if_z    mov     one+27, two+27
                waitvid one+27, pix+6 
                ror     pix+6, #8     

        if_z    mov     one+28, two+28
                waitvid one+28, pix+7 
                ror     pix+7, #8
        if_z    mov     one+29, two+29
                waitvid one+29, pix+7 
                ror     pix+7, #8
        if_z    mov     one+30, two+30
                waitvid one+30, pix+7 
                ror     pix+7, #8
        if_z    mov     one+31, two+31
                waitvid one+31, pix+7 
                ror     pix+7, #8     

        if_z    mov     one+32, two+32
                waitvid one+32, pix+8 
                ror     pix+8, #8
        if_z    mov     one+33, two+33
                waitvid one+33, pix+8 
                ror     pix+8, #8
        if_z    mov     one+34, two+34
                waitvid one+34, pix+8 
                ror     pix+8, #8
        if_z    mov     one+35, two+35
                waitvid one+35, pix+8 
                ror     pix+8, #8     

        if_z    mov     one+36, two+36
                waitvid one+36, pix+9 
                ror     pix+9, #8
        if_z    mov     one+37, two+37
                waitvid one+37, pix+9 
                ror     pix+9, #8
        if_z    mov     one+38, two+38
                waitvid one+38, pix+9 
                ror     pix+9, #8
        if_z    mov     one+39, two+39
                waitvid one+39, pix+9 
                ror     pix+9, #8     

emit_ret        ret

' initialised data and/or presets

sync            long    $0200                   ' locked to %00 {%hv}
                        
slow_value      long    $000FFFC0               ' 31/14/6
slow            long    6 << 12 | 306           '   6/306
hvis            long    3 << 12 | 24            '   3/24

vcfg_norm       long    %0_01_0_00_000 << 23 | vgrp << 9 | vpin
vcfg_sync       long    %0_01_0_00_000 << 23 | sgrp << 9 | %11

dst2            long      2 << 9                ' dst +/-= 2
dst4            long      4 << 9                ' dst +/-= 4
dst128          long    128 << 9                ' dst +/-= 128

updt_           long    8                       ' |
fcnt_           long    12                      ' mailbox addresses (local copy)

resy            long    res_y * 4               ' actual scanlines
blnk            long    |< 25                   ' flashing mask

crsx            long    1                       ' |
crsy            long    2                       ' cursor location

' Stuff below is re-purposed for temporary storage.

setup           add     scrn_, par              ' @long[par][0]
                add     plte_, par              ' @long[par][1]
                add     updt_, par              ' @long[par][2]
                add     fcnt_, par              ' @long[par][3]

                rdlong  scrn, scrn_             ' screen buffer                         (%%)
                rdlong  plte, plte_             ' colour buffer                         (%%)

                wrlong  zero, scrn_             ' |
                wrlong  zero, plte_             ' acknowledge

                ror     plte, #16               ' cursor address visible
                andn    plte, #%11              ' force 4n
                add     crsx, plte              ' |
                add     crsy, plte              ' resolve source addresses
                rol     plte, #16               ' restore colour buffer

                movi    ctrb, #%0_11111_000     ' LOGIC always (loader support)

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_111     ' PLL, VCO/1
                movi    frqa, #%0001_00000      ' 5MHz * 16/1 = 80MHz
                movs    frqa, #res_x*3/4        ' |
                movs    frqa, #0                ' insert res_x*3 into phsa

                mov     vcfg, vcfg_sync         ' VGA, 2 colour mode

                max     dira, mask              ' drive outputs
                mov     $000, pal0              ' restore colour entry 0
                jmp     #vsync                  ' return

' Local data, used only once.

scrn_           long    0                       ' |
plte_           long    4                       ' mailbox addresses (local copy)

pal0            long    $00000000               ' first palette entry
mask            long    vpin << (vgrp * 8) | %11 << (sgrp * 8)

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup
                
scrn            res     1                       ' screen buffer reference  < setup +4   (%%)    
plte            res     1                       ' colour buffer reference  < setup +5   (%%)

one             res     40                      ' |
two             res     40                      ' palette buffers
pix             res     10                      ' scanline buffer

pmsk            res     alias                   ' cursor mask
ecnt            res     1                       ' element count (pix overflow, pix+10)
scnt            res     1                       ' scanlines

eins            res     1
zwei            res     1
drei            res     1
vier            res     1

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
  updt    = $1FB                                ' frqb

  vpin    = $0FC                                ' pin group mask
  vgrp    = 2                                   ' pin group
  sgrp    = 2                                   ' pin group sync

  res_x   = 320                                 ' |
  res_y   = 256                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0
  
DAT