''
'' VGA scanline driver 800x600 (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2014/05/25
''       Version: 0.5
''
'' - timing signalled as SVGA 800x600
'' - vertical blank start sets frame indicator (FI) to 0
'' - once the Nth scanline has been fetched the FI is set to N+1       
''
'' 20140523: initial version (800x600@60Hz timing, %00 sync locked)
'' 20140524: release
''
OBJ
  system: "core.con.system"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox) : cog
                                                        
  cog := system.launch(ID,    @driver, mailbox) -1
  cog := system.launch(cog^4, @driver, mailbox^$8000)
  
DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

        if_nc   call    #match                  ' primary syncs with secondary

                max     dira, mask              ' drive outputs

' horizontal timing 800(800) 40(40) 128(128) 88(88)
'   vertical timing 600(600)  1(1)    4(4)   23(23)

vsync   if_c    mov     lcnt, #0                ' |
        if_c    wrlong  lcnt, blnk              ' reset line counter (once)

'               mov     ecnt, #1
                call    #blank                  ' front porch
'               djnz    ecnt, #$-1

                xor     sync, #$0101            ' active

                mov     ecnt, #4
                call    #blank                  ' vertical sync
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

                mov     ecnt, #23
                call    #blank                  ' back porch
                djnz    ecnt, #$-1

' Vertical sync chain done, do visible area.

                mov     scnt, vres

scan            waitcnt cnt, #0                 ' re-sync after back porch              (##)

                mov     vcfg, vcfg_norm         ' -20   disconnect sync from video h/w
                mov     addr, base              ' -16   working copy
                mov     vscl, hvis              ' -12   1/4
                mov     misc, #0                '  -8
                
                jmpret  hsync_ret, #line        '  -4   emit line
                djnz    scnt, #scan

                jmp     #vsync                  ' next frame


blank           mov     vscl, phsa              ' 256/800
                waitvid sync, #%%0000           ' latch blank line

hsync           mov     vscl, #40 wc            ' 256/40
                waitvid sync, #%%0              ' latch front porch

' hsync_2nd entry is carry set (secondary only)

hsync_2nd       mov     vcfg, vcfg_sync         ' switch back to sync mode              (&&)

        if_c    add     lcnt, #1                ' |
        if_c    wrlong  lcnt, blnk              ' report current line
              
                mov     vscl, wrap              ' 128/216
                waitvid sync, #%%01             ' latch sync and back porch

                mov     cnt, cnt                ' record sync point                     (##)
                add     cnt, #9{14} + 391 -8    '                                       (##)
hsync_ret
blank_ret       ret


match           mov     vscl, #8                ' switch to "every hub window"
                waitvid zero, #0                ' start after long wait                 ($$)

                rdlong  lcnt, blnk wz           ' |
        if_z    jmp     #$-1                    ' |
                rdlong  lcnt, blnk wz           ' vres/0 transition
        if_nz   jmp     #$-1                    ' |

                mov     vscl, #8*22             ' cover remainder
match_ret       jmpret  zero, #0-0 nr           ' WHOP

' initialised data and/or presets

sync            long    $0200                   ' locked to %00 {%hv}

wrap            long    128 << 12 | 216         ' 128/216
hvis            long      1 << 12 | 4           '   1/4

vcfg_norm       long    %0_01_1_00_000 << 23 | vgrp << 9 | vpin
vcfg_sync       long    %0_01_1_00_000 << 23 | sgrp << 9 | %11

mask            long    vpin << (vgrp * 8) | %11 << (sgrp * 8)

blnk            long    -4
base            long    $FFFF8000

vres            long    res_y

' Stuff below is re-purposed for temporary storage.

setup           rdlong  cnt, #0                 '  +0 = clkfreq
hram            long    $00007FFF               '  +8   hub RAM mask
                neg     href, cnt               '  -4   hub window reference            (%%)
                
                add     base, par wc            '  +0 = carry set -> secondary
                and     base, hram              '  +4   confine to hub RAM
                add     blnk, base              '  +8   frame indicator

        if_nc   movs    vcfg_sync, #0           ' primary doesn't drive sync
        if_nc   movi    code+4, #%010111_000    ' and update frame indicator
        if_c    add     base, #4                ' secondary starts with 8n+4
        
' Upset video h/w and relatives.

                movi    ctra, #%0_00001_110     ' PLL, VCO/2
                movi    frqa, #%0001_00000      ' 5MHz * 16 / 2 = 40MHz
                movs    frqa, #res_x/4          ' |
                movs    frqa, #0                ' insert res_x into phsa
                
                mov     vscl, #32               ' 256/32
                mov     vcfg, vcfg_sync         ' VGA, 4 colour mode

                shr     cnt, #10                ' ~1ms
                add     cnt, cnt
                waitcnt cnt, #0                 ' PLL needs to settle

                waitvid zero, #0                ' dummy (first one is unpredictable)
                waitvid zero, #0                ' point of reference

                add     href, cnt               ' get current sync slot
                shr     href, #1                ' 2 system clocks per pixel

                sub     href, #5                ' shift range
                neg     href, href              ' |
                and     href, #%111             ' calculate adjustment

                add     vscl, href              ' |            
                waitvid zero, #0                ' stretch frame
                sub     vscl, href              ' |            
                waitvid zero, #0                ' restore frame

                shl     vscl, #5                ' 256/1024 -> 2K system clocks
                waitvid zero, #0                ' cover stuff until first blank line    ($$)

' Move emitter generator (out of the way).

                mov     line+296, code+0        ' |
                mov     line+297, code+1        ' |
                mov     line+298, code+2        ' copy last fragment
                mov     line+299, code+3        ' |
                mov     line+300, code+4        ' |

                mov     $1F1, code+5            ' |
                mov     $1F2, code+6            ' |
                mov     $1F3, code+7            ' |
                mov     $1F4, code+8            ' copy generator
                mov     $1F5, code+9            ' |

                mov     misc, #1                ' |
                movd    misc, misc              ' d1s1

                jmp     #$1F1                   ' generate emitter
        {295}
code{+0}{296}   add     addr, #8                ' |
        {297}   rdlong  misc, addr              ' |                     WHOP
        {298}   cmps    misc, #%%3210           ' |                     WHOP
        {299}   mov     vscl, #40 wc            ' line emitter fragment
        {300}   jmpret  zero, #hsync_2nd wc,nr  ' |                     WHOP (hsync)    (&&)

{code+5}{$1F1}  mov     line+295, line+298      ' |
        {$1F2}  sub     $1F1, misc              ' |
        {$1F3}  djnz    $1F4, #$1F1             ' |
        {outa}  long    3 * (100 - 1)           ' we have one but need more
        {$1F5}  jmp     %%0                     ' return

                fit

' uninitialised data and/or temporaries

                org     setup
                
misc            res     alias                   ' address increment and colour
ecnt            res     alias                   ' element count
href            res     1                       ' hub window reference  < setup +2      (%%)

lcnt            res     1                       ' line counter
scnt            res     1                       ' scanlines

addr            res     1                       ' colour buffer reference and line underflow
line            res     299
                res     1
{line_ret}      res     1

tail            fit

DAT                                             ' translation table

__table         word    (@__names - @__table)/2

                word    res_x
                word    res_y
                
__names         byte    "res_x", 0
                byte    "res_y", 0

CON
  zero  = $1F0                                  ' par (dst only)
  vpin  = $0FC                                  ' pin group mask
  vgrp  = 2                                     ' pin group
  sgrp  = 2                                     ' pin group sync

  res_x = 800                                   ' |
  res_y = 600                                   ' UI support

  alias = 0
  
DAT
