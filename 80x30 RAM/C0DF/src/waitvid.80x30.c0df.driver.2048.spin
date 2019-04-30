''
'' VGA display 80x30 (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2019/05/01
''       Version: 0.15.c0df.2
''
'' long[par][0]: vgrp:[!Z]:vpin:[!Z]:addr = 2:1:8:5:16 -> zero (accepted) screen buffer    (4n)
'' long[par][1]:                addr:addr =      16:16 -> zero (accepted) palette/font     (2n/4n)
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
'' 20190428: initial version (720x480@60Hz timing, %11 sync locked)
'' 20190501: restored original underscore cursor
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

' horizontal timing 720(720) 16(16) 62(62) 60(60)
'   vertical timing 480(480)  9(9)   6(6)  30(30)

'                              +----------------- front porch
'                              | +--------------- sync
'                              | |     +--------- back porch
'                              | |     |
vsync           mov     ecnt, #9+6+(30-4)

                cmp     ecnt, #32 wz
        if_ne   cmp     ecnt, #26 wz
        if_e    xor     sync, #$0101            ' in/active

                call    #blank
                djnz    ecnt, #vsync+1

' While still in sync, figure out the blink state (used to be based on cnt) and cursor.
' hsync offers 31 hub windows.

                add     fcnt, #1                ' next frame
                cmpsub  fcnt, #30 wz            ' N frames per phase (on/off)
        if_z    xor     rxor, rmsk              ' $FFFFFFFF vs $00000000; 60/(2*30), ~1Hz

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

                mov     ecnt, #4
        if_nc   call    #blank                  ' |
        if_nc   djnz    ecnt, #$-1              ' back porch remainder (primary only)

' Vertical sync chain done, do visible area.

                mov     zwei, scrn              ' screen base address
                mov     rows, #res_y/16         ' row count

:scan           mov     scnt, #16/4/2           ' 16 quad scanlines (split between primary and secondary)
                mov     eins, font              ' font base
        if_nc   add     eins, adv4              ' interleaved

:line           mov     vscl, many              ' four lines we don't use
                waitvid zero, #0                ' 636 hub windows

                call    #load                   ' load pixels and colours for the next four lines

                add     cnt, $+1                ' adjust sync point by 4 scanlines
                long    (858*4*80000)/26953

                call    #char0                  ' |
                call    #char1                  ' |
                call    #char0                  ' display scanlines
                call    #char1                  ' |

                add     eins, adv8              ' skip 8 scanlines
                djnz    scnt, #:line            ' for all character scanlines
                sub     zwei, #80*2             ' next row
                djnz    rows, #:scan            ' for all rows

                mov     ecnt, #4
        if_c    call    #blank                  ' secondary finishes early so
        if_c    djnz    ecnt, #$-1              ' let him do some blank lines

        if_nc   wrlong  cnt, fcnt_              ' announce vertical blank (primary)

                jmp     #vsync                  ' next frame


blank           mov     vscl, line              ' 180/720
                waitvid sync, #%0000            ' latch blank line

hsync           mov     vscl, #16               ' 256/16
                waitvid sync, #%0000            ' front

                mov     vcfg, vcfg_sync         ' drive sync lines                      (&&)
                mov     outa, #0                ' stop interfering

                mov     cnt, cnt                ' record sync point                     (**)
                add     cnt, #9{14}+300         ' relaxed timing

                mov     vscl, wrap              '  62/122
                waitvid sync, #%0001            ' sync+back
hsync_ret
blank_ret       ret


char0           waitcnt cnt, #0                 ' re-sync after back porch              (**)

                mov     outa, idle              ' take over sync lines
                mov     vcfg, vcfg_norm         ' disconnect from video h/w             (&&)

                movd    :one, #pix+0            ' |
                movs    :two, #pix+0            ' |
                movd    :two, #col+0            ' restore initial settings

                mov     vscl, hvis              ' 1/9, speed up (one pixel per frame clock)
                mov     ecnt, #80               ' character count

:loop           add     :one, dst1              ' advance (pipeline)
:one            ror     1-1, #16
                add     :two, d1s1              ' advance (pipeline)
:two            waitvid 0-0, 1-1                ' emit pixels
                djnz    ecnt, #:loop

                call    #hsync
char0_ret       ret


char1           waitcnt cnt, #0                 ' re-sync after back porch              (**)

                mov     outa, idle              ' take over sync lines
                mov     vcfg, vcfg_norm         ' disconnect from video h/w             (&&)

                movd    :one, #pix-80           ' |
                movs    :two, #pix-80           ' |
                movd    :two, #col+0            ' restore initial settings

                mov     vscl, hvis              ' 1/9, speed up (one pixel per frame clock)
                mov     ecnt, #80               ' character count

:loop           add     :one, dst1              ' advance (pipeline)
:one            ror     1-1, #16
                add     :two, d1s1              ' advance (pipeline)
:two            waitvid 0-0, 1-1                ' emit pixels
                djnz    ecnt, #:loop

                call    #hsync
char1_ret       ret


load            muxnc   flag, $                 ' preserve carry flag

                movd    :pix0_0, #pix+0         ' |
                movd    :pix1_0, #pix-80        ' re/store initial settings
                movd    :colN_0, #col+0         ' |

                movd    :pix0_1, #pix+1         ' |
                movd    :pix1_1, #pix-79        ' |
                movd    :colN_1, #col+1         ' |

                mov     addr, zwei              ' current screen base
                movi    addr, #80{units} -2     ' add magic marker

' Fetch pixel data and colour for two characters. Only character 2n is documented.

:loop           rdword  frqb, addr      {hub}   '  +0 = read ASCII + colour

                ror     frqb, #7                '  +8   ASCII *2 +{0..1}
                mov     phsb, eins              '  -4   current font address
                rdlong  pix0, phsb      {hub}   '  +0 = four scanlines

                rol     frqb, #7                '  +8   restore

                mov     drei, frqb              '  -4   working copy
                shr     drei, #13               '  +0 = extract signature ($C0..$DF)
                sub     addr, i2s3 wc           '  +4   advance source

                and     frqb, #$FF              '  +8   palette index
                mov     phsb, plte              '  -4   current palette location
                rdword  colN, phsb      {hub}   '  +0 = read palette entry

                test    colN, #1 wz             '  +8   check mode
        if_nz   and     pix0, rxor              '  -4   modify foreground (-1/0)
                cmp     drei, #%110 wz          '  +0 = zero: char in [$C0..$DF]

        if_e    xor     pix0, h80808080         '  +4   pixel duplication 1/2

                mov     pix1, pix0              '  +8   |
                and     pix1, h00FF00FF         '  -4   scanlines 1/3
                shr     pix0, #8                '  +0 = |
                and     pix0, h00FF00FF         '  +4   scanlines 0/2

        if_e    add     pix0, h01800180         '  +8   pixel duplication 2/2
        if_e    add     pix1, h01800180         '  -4   |

:pix0_0         mov     0-0, pix0               '  +0 = store scanlines 0/2
                add     $-1, dst2               '  +4   |
:pix1_0         mov     1-1, pix1               '  +8   store scanlines 1/3
                add     $-1, dst2               '  -4   |

                rdword  frqb, addr      {hub}   '  +0 =

                ror     frqb, #7                '  +8
                mov     phsb, eins              '  -4
                rdlong  pix0, phsb      {hub}   '  +0 =

                rol     frqb, #7                '  +8

                mov     drei, frqb              '  -4
:colN_0         mov     2-2, colN               '  +0 = store palette
                add     $-1, dst2               '  +4   |

                and     frqb, #$FF              '  +8
                mov     phsb, plte              '  -4
                rdword  colN, phsb      {hub}   '  +0 =

                test    colN, #1 wz             '  +8
        if_nz   and     pix0, rxor              '  -4
                shr     drei, #13               '  +0 =
                cmp     drei, #%110 wz          '  +4

        if_e    xor     pix0, h80808080         '  +8

                mov     pix1, pix0              '  -4
                and     pix1, h00FF00FF         '  +0 =
                shr     pix0, #8                '  +4
                and     pix0, h00FF00FF         '  +8

        if_e    add     pix0, h01800180         '  -4
        if_e    add     pix1, h01800180         '  +0 =

:pix0_1         mov     0-0, pix0               '  +4
                add     $-1, dst2               '  +8
:pix1_1         mov     1-1, pix1               '  -4
                add     $-1, dst2               '  +0 =
:colN_1         mov     2-2, colN               '  +4
                add     $-1, dst2               '  +8

        if_nc   djnz    addr, #:loop            '  -4   for all characters

                mov     vier, crs0
                call    #cursor

                cmp     crs0, crs1 wz
        if_ne   mov     vier, crs1
        if_ne   call    #cursor

load_ret        jmpret  flag, #0-0 nr,wc        ' restore carry flag


cursor          test    vier, #%100 wz          ' cursor enabled?

                mov     temp, vier              ' local copy
                sar     temp, #1+16             ' extract y - 30
        if_z    add     temp, rows wz           ' rows = {30..1}
        if_nz   jmp     cursor_ret              ' wrong row/disabled

                test    vier, #%010 wz,wc       ' underscore(1)/block(0)
        if_nz   cmp     scnt, #1 wz
        if_nz   jmp     cursor_ret              ' wrong scanline pair

        if_nc   jmp     #:block

:underscore     ror     vier, #8 wc             ' carry: blink on/off
                movd    :set_0, vier
                sub     vier, #80
                movd    :set_1, vier
                
        if_c    cmp     fcnt, #15 wc            ' 60/(2*15), ~2Hz
:set_0  if_nc   xor     0-0, pmsk_0
:set_1  if_nc   xor     1-1, pmsk_1
                jmp     cursor_ret              ' done

:block          ror     vier, #8 wc             ' carry: blink on/off
                movd    :set_c, vier
        if_c    cmp     fcnt, #15 wc            ' 60/(2*15), ~2Hz
:set_c  if_nc   xor     0-0, cmsk

cursor_ret      ret


prep            mov     temp, vier              ' working copy
                shr     temp, #16               ' |
                and     temp, #255              ' extract y
                sub     temp, #res_y/16         '   y - 30
                shl     temp, #1+16             ' 2(y - 30)

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
adv4            long    256*(4+0)*1             ' 4 scanlines in font
adv8            long    256*(4+0)*2             ' 8 scanlines in font

flag            long    0                       ' loader flag storage
idle            long    hv_idle
sync            long    hv_idle ^ $0200

wrap            long     62 << 12 | 122         '  62/122
hvis            long      1 << 12 | 9           '   1/9
line            long    180 << 12 | 720         ' 180/720
many            long      0 << 12 | 3432        ' 256/3432

scrn_           long    $00000000 -12           ' |
font_           long    $00000004 -12           ' |
locn_           long    $00000008 -12           ' |
fcnt_           long    $0000000C -12           ' mailbox addresses (local copy)        (##)

vcfg_norm       long    %0_01_0_00_000 << 23
vcfg_sync       long    %0_01_0_00_000 << 23 | %00000011

dst1            long    1 << 9                  ' dst     +/-= 1
dst2            long    2 << 9                  ' dst     +/-= 2
d1s1            long    1 << 9  | 1             ' dst/src +/-= 1
i2s3            long    2 << 23 | 3

cmsk            long    %%3330_3330             ' xor mask for block cursor
pmsk_0          long    %%0000_0000_0000_3333   ' |
pmsk_1          long    %%0000_3333_0000_0000   ' xor mask for underscore cursor (secondary inactive)

rmsk            long    $FFFFFFFF               ' master for blink mode
rxor            long    0                       ' pixel mask

h80808080       long    $80808080               ' |
h01800180       long    $01800180               ' |
h00FF00FF       long    $00FF00FF               ' misc patterns

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

                add     scrn, $+1               ' scrn now points to last word
                long    res_x * res_y /72 -1

' Upset video h/w and relatives.

                rdlong  temp, #0                ' clkfreq
                shr     temp, #10               ' ~1ms
        if_nc   waitpne $, #0                   ' adjust primary

'   primary: cnt + 0 + 6
' secondary: cnt + 2 + 4

                add     temp, cnt

                movi    ctrb, #%0_11111_000     ' LOGIC always (loader support)
                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 26.953125MHz

                mov     vscl, #1                ' reload as fast as possible
                mov     zwei, scrn              ' vgrp:[!Z]:vpin:[!Z]:scrn = 2:1:8:5:16 (%%)
                shr     zwei, #5+16             ' |
                andn    zwei, #%%000_3          ' |
                or      vcfg_norm, zwei         ' | group + %%RGB_0
                shr     zwei, #9                ' |
                movd    vcfg_sync, zwei         ' | group + %%000_3
                mov     vcfg, vcfg_sync         ' VGA, 2 colour mode

                waitcnt temp, #0                ' PLL settled, frame counter flushed

                ror     vcfg, #1                ' freeze video h/w
                mov     vscl, line              ' transfer user value
                rol     vcfg, #1                ' unfreeze
                waitpne $, #0                   ' get some distance
                waitvid zero, #0                ' latch user value

                mov     temp, vcfg_norm         ' |
                or      temp, vcfg_sync         ' |
                and     mask, temp              ' transfer vpin

                mov     temp, vcfg              ' |
                shr     temp, #9                ' extract vgrp
                shl     temp, #3                ' 0..3 >> 0..24
                shl     mask, temp              ' finalise mask

                max     dira, mask              ' drive outputs
        if_c    mov     pmsk_0, #0              ' |
        if_c    mov     pmsk_1, #0              ' no cursor mask for secondary

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return

' Local data, used only once.

frqx            long    $15900000               ' 26.953125MHz
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
zwei            res     1                       '                       < setup +28     (%%)
drei            res     1
vier            res     1

pix0            res     1
pix1            res     1
colN            res     1

                res     80                      ' |
pix             res     80                      ' emitter pixel array
col             res     80                      ' emitter colour data

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
  hv_idle = $01010101 * %11 {%hv}               ' h/v sync inactive

  res_x   = 720                                 ' |
  res_y   = 480                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0

DAT