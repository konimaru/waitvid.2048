''
'' VGA driver 320x256 (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2019/01/26
''       Version: 0.1
''
'' long[par][0]: vgrp:[!Z]:vpin:[!Z]:addr = 2:1:8:5:16 -> zero (accepted) screen buffer
'' long[par][1]:                [!Z]:addr =      16:16 -> zero (accepted) colour buffer
'' long[par][2]: unused
'' long[par][3]: frame indicator/sync lock
''
'' acknowledgements
'' - loader code based on work done by Phil Pilgrim (PhiPi)
''
'' 201901xx:
''
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

' horizontal timing 320(1280) 6(48) 14(112) 31(248)
'   vertical timing 256(1024) 1(1)   3(3)   38(38)

'               mov     ecnt, #1
vsync           call    #blank                  ' front porch
'               djnz    ecnt, #$-1

                xor     sync, #$0101            ' active

                call    #blank                  ' |
                call    #blank                  ' vertical sync
                call    #blank                  ' |

                xor     sync, #$0101            ' inactive

                mov     ecnt, #38 -4
                call    #blank                  ' back porch
                djnz    ecnt, #$-1

                mov     ecnt, #4
        if_nc   call    #blank                  ' |                                       
        if_nc   djnz    ecnt, #$-1              ' back porch remainder (primary only)     

' Vertical sync chain done, do visible area.

                mov     scnt, #res_y /2         ' 256 quad scanlines (split between primary and secondary)

:scan           mov     vscl, many              ' four lines we don't use
                waitvid zero, #0                ' 312 hub windows

' load first 20 bytes/colours

                mov     vscl, many              ' |
                waitvid zero, #0                ' |

' load remaining 20 bytes/colours

                call    #blank                  ' |
                call    #blank                  ' |
                call    #blank                  ' display scanlines
                call    #blank                  ' |

                djnz    scnt, #:scan            ' for all rows

                mov     ecnt, #4
        if_c    call    #blank                  ' secondary finishes early so
        if_c    djnz    ecnt, #$-1              ' let him do some blank lines

        if_nc   wrlong  cnt, fcnt_              ' announce vertical blank (primary)
                
                jmp     #vsync                  ' next frame


blank           mov     vscl, phsa              ' 256/960
                waitvid sync, #%0000            ' latch blank line

hsync           mov     vscl, wrap              '   6/306
                waitvid sync, wrap_value
hsync_ret
blank_ret       ret

' initialised data and/or presets

'xmsk           long    $0000FF07               ' covers mode/x
'xlim           long    80 << 8                 ' park position
    
'fcnt           long    0                       ' blink frame count
'adv4           long    256*(4+0)*1             ' 4 scanlines in font
'adv8           long    256*(4+0)*2             ' 8 scanlines in font

'flag           long    0                       ' loader flag storage
'idle           long    hv_idle
sync            long    hv_idle ^ $0200

wrap_value      long    $000FFFC0               ' 31/14/6
wrap            long     6 << 12 | 306          '   2/102
'hvis           long     1 << 12 | 9            '   1/9
many            long     0 << 12 | 2532         ' 256/2532 (2 scanlines worth)

scrn_           long    $00000000 -12           ' |
attr_           long    $00000004 -12           ' |
fcnt_           long    $0000000C -12           ' mailbox addresses (local copy)        (##)

vcfg_norm       long    %0_01_0_00_000 << 23
vcfg_sync       long    %0_01_0_00_000 << 23 | %00000011

'dst1           long    1 << 9                  ' dst     +/-= 1
'dst2           long    2 << 9                  ' dst     +/-= 2
'd1s1           long    1 << 9  | 1             ' dst/src +/-= 1
'i2s3           long    2 << 23 | 3

'               long    0[$&1]
'cmsk   {2n}    long    %%3330_3330             ' xor mask for block cursor
'pmsk   {2n+1}  long    %%0000_0000_0000_3333   ' xor mask for underscore cursor (updated for secondary)

'rmsk           long    $FFFFFFFF               ' master for blink mode
'rxor           long    0                       ' pixel mask

'h80808080      long    $80808080               ' |
'h01800180      long    $01800180               ' |
'h00FF00FF      long    $00FF00FF               ' misc patterns

' Stuff below is re-purposed for temporary storage.

setup           add     trap, par wc            ' carry set -> secondary
                and     trap, hram              ' confine to hub RAM

                add     scrn_, trap             ' @long[par][0]
                add     attr_, trap             ' @long[par][1]
                add     fcnt_, trap             ' @long[par][3]

                addx    trap, #%00              ' add secondary offset
                wrbyte  hram, trap              ' up and running

                rdlong  temp, trap wz           ' |                                     (%%)
        if_nz   jmp     #$-1                    ' synchronized start

'   primary: cnt + 0              
' secondary: cnt + 2

                rdlong  scrn, scrn_             ' get screen address                    (%%)
                wrlong  zero, scrn_             ' acknowledge screen buffer setup

                rdlong  attr, attr_             ' get attribute address                 (%%)
                wrlong  zero, attr_             ' acknowledge attribute setup

' Upset video h/w and relatives.

                rdlong  temp, #0                ' clkfreq
                shr     temp, #10               ' ~1ms
        if_nc   waitpne $, #0                   ' adjust primary

'   primary: cnt + 0 + 6          
' secondary: cnt + 2 + 4

                add     temp, cnt

                movi    ctrb, #%0_11111_000     ' LOGIC always (loader support)
                movi    ctra, #%0_00001_111     ' PLL, VCO/1
                movi    frqa, #%0001_00000      ' 5MHz * 16/1 = 80MHz
                movs    frqa, #res_x*3/4        ' |
                movs    frqa, #0                ' insert res_x*3 into phsa
                
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
                mov     vscl, phsa              ' transfer user value
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
                mov     $000, pal0              ' restore colour entry 0
        
' Setup complete, do the heavy lifting upstairs ...

                jmp     #vsync                  ' return

' Local data, used only once.

mask            long    %11111111
pal0            long    hv_idle                 ' first palette entry

hram            long    $00007FFF               ' hub RAM mask  
trap            long    $FFFF8000 +12           ' primary/secondary trap                (##)

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup

scrn            res     1                       ' screen buffer         < setup + 9     (%%)
attr            res     1                       ' palette location      < setup +11     (%%)
ecnt            res     1                       ' element count
scnt            res     1                       ' scanline count

temp            res     1                       '                       < setup + 7     (%%)

zwei            res     1                       '                       < setup +23     (%%)

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
  hv_idle = $01010101 * %00 {%hv}               ' h/v sync inactive
  
  res_x   = 320                                 ' |
  res_y   = 256                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0
  
DAT