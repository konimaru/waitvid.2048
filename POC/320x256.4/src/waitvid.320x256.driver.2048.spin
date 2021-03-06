''
'' VGA driver 320x256 (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2019/06/17
''       Version: 0.3
''
'' long[par][0]: vgrp:[!Z]:vpin:[!Z]:addr = 2:1:8:5:16 -> zero (accepted) screen buffer
'' long[par][1]: sgrp:[!Z]:----:[!Z]:addr = 2:1:8:5:16 -> zero (accepted) colour buffer
'' long[par][2]: unused
'' long[par][3]: frame indicator/sync lock
''
'' acknowledgements
'' - loader code based on work done by Phil Pilgrim (PhiPi)
''
'' 20190130: initial release
'' 20190617: 6bit/8bit colour
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
                long    $00080800, $0C08080C, $30080830, $3C08083C, $C00808C0, $CC0808CC, $F00808F0, $FC0808FC
                long    $00101000, $0C10100C, $30101030, $3C10103C, $C01010C0, $CC1010CC, $F01010F0, $FC1010FC
                long    $00181800, $0C18180C, $30181830, $3C18183C, $C01818C0, $CC1818CC, $F01818F0, $FC1818FC
                long    $00202000, $0C20200C, $30202030, $3C20203C, $C02020C0, $CC2020CC, $F02020F0, $FC2020FC
                long    $00282800, $0C28280C, $30282830, $3C28283C, $C02828C0, $CC2828CC, $F02828F0, $FC2828FC
                long    $00303000, $0C30300C, $30303030, $3C30303C, $C03030C0, $CC3030CC, $F03030F0, $FC3030FC
                long    $00383800, $0C38380C, $30383830, $3C38383C, $C03838C0, $CC3838CC, $F03838F0, $FC3838FC
                long    $00808000, $0C80800C, $30808030, $3C80803C, $C08080C0, $CC8080CC, $F08080F0, $FC8080FC
                long    $00888800, $0C88880C, $30888830, $3C88883C, $C08888C0, $CC8888CC, $F08888F0, $FC8888FC
                long    $00909000, $0C90900C, $30909030, $3C90903C, $C09090C0, $CC9090CC, $F09090F0, $FC9090FC
                long    $00989800, $0C98980C, $30989830, $3C98983C, $C09898C0, $CC9898CC, $F09898F0, $FC9898FC
                long    $00A0A000, $0CA0A00C, $30A0A030, $3CA0A03C, $C0A0A0C0, $CCA0A0CC, $F0A0A0F0, $FCA0A0FC
                long    $00A8A800, $0CA8A80C, $30A8A830, $3CA8A83C, $C0A8A8C0, $CCA8A8CC, $F0A8A8F0, $FCA8A8FC
                long    $00B0B000, $0CB0B00C, $30B0B030, $3CB0B03C, $C0B0B0C0, $CCB0B0CC, $F0B0B0F0, $FCB0B0FC
                long    $00B8B800, $0CB8B80C, $30B8B830, $3CB8B83C, $C0B8B8C0, $CCB8B8CC, $F0B8B8F0, $FCB8B8FC

' horizontal timing 320(1280) 6(48) 14(112) 31(248)
'   vertical timing 256(1024) 1(1)   3(3)   38(38)

'               mov     ecnt, #1
vsync           call    #blank                  ' front porch
'               djnz    ecnt, #$-1

                add     fcnt, #1                ' next frame
                cmpsub  fcnt, #30 wz            ' N frames per phase (on/off)
        if_z    rev     rmsk, #{32-}0           ' 16 vs 0; 60/(2*30), ~1Hz

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

                mov     eins, scrn              ' screen base
                mov     drei, attr              ' colour info

        if_nc   add     eins, #res_x /8         ' |
        if_nc   add     drei, #res_x /8         ' interleaved

:scan           mov     vscl, #0                ' four lines we don't use
                waitvid zero, #0                ' ~316 hub windows

                call    #load                   ' load pixels and colours for the next line
                
                mov     vscl, #484
                waitvid zero, #0
                waitvid zero, #0

                add     cnt, $+1                ' adjust sync point by 4 scanlines
                long    (1266*4*80000)/80000

                call    #emit                   ' |
                call    #emit                   ' |
                call    #emit                   ' display scanlines
                call    #emit                   ' |

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

                mov     vcfg, vcfg_sync         ' drive sync lines                      (&&)
'               mov     outa, #0                ' stop interfering                      (=0)
                
                mov     cnt, cnt                ' record sync point                     (**)
                add     cnt, #9{14}+200         ' relaxed timing
hsync_ret
blank_ret       ret


load            muxnc   flag, $                 ' preserve carry flag

                movd    :loop, #pix+0           ' |
                movd    :colN, #col+0           ' re/store initial settings

                mov     ecnt, #res_x /8         ' column count
                
' Fetch pixel data and colour for all columns.

:loop           rdbyte  0-0, eins               ' pixel data
                add     $-1, dst1               ' advance dst                           (px)
                add     eins, #1                ' advance src                           (px)

                rdbyte  temp, drei              ' corresponding colour byte
                cmpsub  temp, #%1_0000_000 wc   ' extract blink bit
                movs    :xfer, temp             ' prep index

                add     drei, #1                ' advance src                           (cc)
:xfer           mov     temp, 0-0               ' load palette entry
        if_c    shr     temp, rmsk              ' select alternate palette

:colN           mov     1-1, temp               ' store final palette
                add     $-1, dst1               ' advance dst                           (cc)

                djnz    ecnt, #:loop            ' for all columns

                add     eins, #res_x /8         ' |
                add     drei, #res_x /8         ' skip one scanline (primary/secondary)

load_ret        jmpret  flag, #0-0 nr,wc        ' restore carry flag


emit            waitcnt cnt, #0                 ' re-sync after back porch              (**)

'               mov     outa, idle              ' take over sync lines                  (=0)
                mov     vcfg, vcfg_norm         ' disconnect from video h/w             (&&)

                movs    :two, #pix+0            ' |
                movd    :two, #col+0            ' restore initial settings

                mov     vscl, hvis              ' 3/24, speed up
                mov     ecnt, #res_x /8         ' byte count

:loop           add     :two, d1s1              ' advance (pipeline)
:two            waitvid 0-0, 1-1                ' emit pixels
                djnz    ecnt, #:loop            ' for all columns

                call    #hsync                  ' timing requirement
emit_ret        ret

' initialised data and/or presets

rmsk            long    16                      ' master for blink mode
fcnt            long    0                       ' blink frame count

flag            long    0                       ' loader flag storage
idle            long    hv_idle
sync            long    hv_idle ^ $0200

wrap_value      long    $000FFFC0               ' 31/14/6
wrap            long     6 << 12 | 306          '   2/102
hvis            long     3 << 12 | 24           '   3/24

scrn_           long    $00000000 -12           ' |
attr_           long    $00000004 -12           ' |
fcnt_           long    $0000000C -12           ' mailbox addresses (local copy)        (##)

vcfg_norm       long    %0_01_0_00_000 << 23 | vgrp << 9 | vpin
vcfg_sync       long    %0_01_0_00_000 << 23 | sgrp << 9 | %%000_3

dst1            long    1 << 9                  ' dst     +/-= 1
d1s1            long    1 << 9  | 1             ' dst/src +/-= 1

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
                shr     zwei, #5+16 wz          ' |
        if_z    mov     zwei, vcfg_norm         ' |
        if_nz   movs    vcfg_norm, zwei         ' | replace pins
                shr     zwei, #9                ' |
        if_nz   movd    vcfg_norm, zwei         ' | replace group

                mov     mask, vcfg_norm         ' |
                and     mask, #%%333_3          ' transfer vpin
                shl     zwei, #3                ' 0..3 >> 0..24
                shl     mask, zwei              ' RGB mask

                mov     zwei, attr              ' sgrp:[!Z]:----:[!Z]:scrn = 2:1:8:5:16
                shr     zwei, #5+16 wz          ' |
        if_z    mov     zwei, vcfg_sync         ' |
'{fix}  if_nz   movs    vcfg_sync, zwei         ' | %%000_3
                shr     zwei, #9                ' |
        if_nz   movd    vcfg_sync, zwei         ' | replace group

                mov     eins, vcfg_sync         ' |                                     (%%)
                and     eins, #%%000_3          ' transfer vpin
                shl     zwei, #3                ' 0..3 >> 0..24
                shl     eins, zwei              ' H/V mask

                mov     vcfg, vcfg_sync         ' VGA, 2 colour mode

                waitcnt temp, #0                ' PLL settled, frame counter flushed
                                                  
                ror     vcfg, #1                ' freeze video h/w
                mov     vscl, phsa              ' transfer user value
                rol     vcfg, #1                ' unfreeze
                waitpne $, #0                   ' get some distance
                waitvid zero, #0                ' latch user value

                or      mask, eins              ' finalise mask
                max     dira, mask              ' drive outputs
                mov     $000, pal0              ' restore colour entry 0
        
' Setup complete, do the heavy lifting upstairs ...

                jmp     #vsync                  ' return

' Local data, used only once.

mask            long    0
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

eins            res     1                       '                       < setup +38     (%%)
zwei            res     1                       '                       < setup +23     (%%)
drei            res     1

pix             res     40
col             res     40

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

  vpin    = %%333_0                             ' pin group mask
  vgrp    = 2                                   ' pin group
  sgrp    = 2                                   ' pin group sync
  
  res_x   = 320                                 ' |
  res_y   = 256                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0
  
DAT