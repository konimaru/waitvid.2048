''
'' VGA scanline driver 256x192 (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2012/10/07
''       Version: 0.12
''
'' - timing signalled as XGA 1024x768
'' - vertical blank start sets frame indicator (FI) to 0
'' - once the Nth scanline has been fetched the FI is set to N+1       
''
'' 20120922: make scanline buffer configurable
'' 20120923: match old-style line indicator
'' 20121007: added minimal translation table
''
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
                
DAT             org     0

driver          neg     href, cnt               ' hub window reference (-4)

                add     blnk, par               ' frame indicator
                add     base, par               ' scanline buffer

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_111     ' PLL, VCO/1
                movi    frqa, #%0001_00000      ' 5MHz * 16 / 1 = 80MHz

                mov     vscl, #64               ' 1/64

                movd    vcfg, #vgrp             ' pin group
                movs    vcfg, #vpin             ' pins
                movi    vcfg, #%0_01_1_00_000   ' VGA, 4 colour mode
                
                rdlong  cnt, #0
                shr     cnt, #10                ' ~1ms
                add     cnt, cnt
                waitcnt cnt, #0                 ' PLL needs to settle

' The first issued waitvid is a bit of a gamble if we don't know where the WHOP
' is located. We could do some fancy math or simply issue a dummy waitvid.

                waitvid zero, #0                ' dummy (first one is unpredictable)
                waitvid zero, #0                ' point of reference

                add     href, cnt               ' get current sync slot
                sub     href, #11
                and     href, #%1111

                sub     vscl, href              ' |
                waitvid zero, #0                ' shorten frame
                add     vscl, href              ' |
                waitvid zero, #0                ' restore frame

                mov     dira, mask

' Setup complete, enter display loop.
                
vsync           mov     lcnt, #0                ' |
                wrlong  lcnt, blnk              ' reset line counter (once)

                mov     ecnt, #3
                call    #blank                  ' front porch
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' active

                mov     ecnt, #6
                call    #blank                  ' vertical sync
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

                mov     ecnt, #29 -1
:last           call    #blank                  ' back porch
                djnz    ecnt, #$-1

' The following instruction (performing unsigned borrow) exploits the
' fact that a ret insn has its wr bit cleared and is therefore unsigned
' smaller than a call (wr set).
'
' call #blank   %010111_001i_cccc_ddddddddd_sssssssss
' ret           %010111_000i_cccc_ddddddddd_sssssssss
                                                
                jmpret  blank_ret, :last wc     ' last blank line done manually (%%)
                                                ' to start pixel loading            
' Vertical sync chain done, do visible area.

                mov     scnt, #res_y

:loop           mov     outa, idle              ' take over sync lines
                andn    vcfg, #%11              ' disconnect from video h/w     (##)

                jmpret  hsync_ret, #emit_0

                mov     outa, idle              ' take over sync lines
                andn    vcfg, #%11              ' disconnect from video h/w     (##)

                jmpret  hsync_ret, #emit_12

                mov     outa, idle              ' take over sync lines
                andn    vcfg, #%11              ' disconnect from video h/w     (##)

                jmpret  hsync_ret, #emit_12

                mov     outa, idle              ' take over sync lines
                andn    vcfg, #%11              ' disconnect from video h/w     (##)

' Note: The worst case timing between the last waitvid triggered by emit_3 and the
'       first for vertical blank is 44 cycles (which has to cover one more hubop).

                jmpret  hsync_ret, #emit_3
                
                djnz    scnt, #:loop

                jmp     #vsync


blank           mov     vscl, line              ' 256/1280
                waitvid sync, #%%00000

hsync           mov     vscl, #30               ' 256/30
                waitvid sync, #%%0              ' latch front porch

                or      vcfg, #%11              ' drive sync lines              (##)
                mov     outa, #0                ' stop interfering

                mov     vscl, slow              ' 170/370
                waitvid sync, #%%1              ' latch sync and back porch

                cmp     lcnt, #0 wz             ' only non-null numbers
        if_nz   wrlong  lcnt, blnk              ' report current line
                
                add     base, #4                ' get all 4n+1 longs a bit earlier
        if_c    rdlong  pal+$01, base
                add     base, #16
        if_c    rdlong  pal+$05, base
                add     base, #16
        if_c    rdlong  pal+$09, base
                add     base, #16
        if_c    rdlong  pal+$0D, base
                add     base, #16
        if_c    rdlong  pal+$11, base
                add     base, #16
        if_c    rdlong  pal+$15, base
                add     base, #16
        if_c    rdlong  pal+$19, base
                add     base, #16
        if_c    rdlong  pal+$1D, base

                nop                             ' make sure the minimal length covers sync
                add     base, #16
        if_c    rdlong  pal+$21, base
                nop                             ' *
                add     base, #16
        if_c    rdlong  pal+$25, base
                nop                             ' *
                add     base, #16
        if_c    rdlong  pal+$29, base
                nop                             ' *
                add     base, #16
        if_c    rdlong  pal+$2D, base
                nop                             ' *
                add     base, #16
        if_c    rdlong  pal+$31, base
                nop                             ' *
                add     base, #16
        if_c    rdlong  pal+$35, base
                nop                             ' *
                add     base, #16
        if_c    rdlong  pal+$39, base
                nop                             ' * (32)
                add     base, #16
        if_c    rdlong  pal+$3D, base

                sub     base, #$F4 wc           ' restore                       (%%)
hsync_ret
blank_ret       ret


emit_0          mov     addr, base              '  -8
                mov     vscl, hvis              '  -4   pixel timing

                rdlong  pal+$00, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$00, #%%3210
                waitvid pal+$01, #%%3210

                rdlong  pal+$02, addr           '  +0 =
                cmp     pal+$02, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$03, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$03, #%%3210        '  -4   WHOP    0..15


                rdlong  pal+$04, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$04, #%%3210
                waitvid pal+$05, #%%3210

                rdlong  pal+$06, addr           '  +0 =
                cmp     pal+$06, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$07, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$07, #%%3210        '  -4   WHOP    16..31


                rdlong  pal+$08, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$08, #%%3210
                waitvid pal+$09, #%%3210

                rdlong  pal+$0A, addr           '  +0 =
                cmp     pal+$0A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$0B, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$0B, #%%3210        '  -4   WHOP    32..47


                rdlong  pal+$0C, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$0C, #%%3210
                waitvid pal+$0D, #%%3210

                rdlong  pal+$0E, addr           '  +0 =
                cmp     pal+$0E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$0F, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$0F, #%%3210        '  -4   WHOP    48..63


                rdlong  pal+$10, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$10, #%%3210
                waitvid pal+$11, #%%3210

                rdlong  pal+$12, addr           '  +0 =
                cmp     pal+$12, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$13, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$13, #%%3210        '  -4   WHOP    64..79


                rdlong  pal+$14, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$14, #%%3210
                waitvid pal+$15, #%%3210

                rdlong  pal+$16, addr           '  +0 =
                cmp     pal+$16, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$17, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$17, #%%3210        '  -4   WHOP    80..95


                rdlong  pal+$18, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$18, #%%3210
                waitvid pal+$19, #%%3210

                rdlong  pal+$1A, addr           '  +0 =
                cmp     pal+$1A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$1B, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$1B, #%%3210        '  -4   WHOP    96..111


                rdlong  pal+$1C, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$1C, #%%3210
                waitvid pal+$1D, #%%3210

                rdlong  pal+$1E, addr           '  +0 =
                cmp     pal+$1E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$1F, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$1F, #%%3210        '  -4   WHOP    112..127


                rdlong  pal+$20, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$20, #%%3210
                waitvid pal+$21, #%%3210

                rdlong  pal+$22, addr           '  +0 =
                cmp     pal+$22, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$23, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$23, #%%3210        '  -4   WHOP    128..143


                rdlong  pal+$24, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$24, #%%3210
                waitvid pal+$25, #%%3210

                rdlong  pal+$26, addr           '  +0 =
                cmp     pal+$26, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$27, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$27, #%%3210        '  -4   WHOP    144..159


                rdlong  pal+$28, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$28, #%%3210
                waitvid pal+$29, #%%3210

                rdlong  pal+$2A, addr           '  +0 =
                cmp     pal+$2A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$2B, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$2B, #%%3210        '  -4   WHOP    160..175


                rdlong  pal+$2C, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$2C, #%%3210
                waitvid pal+$2D, #%%3210

                rdlong  pal+$2E, addr           '  +0 =
                cmp     pal+$2E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$2F, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$2F, #%%3210        '  -4   WHOP    176..191


                rdlong  pal+$30, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$30, #%%3210
                waitvid pal+$31, #%%3210

                rdlong  pal+$32, addr           '  +0 =
                cmp     pal+$32, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$33, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$33, #%%3210        '  -4   WHOP    192..207


                rdlong  pal+$34, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$34, #%%3210
                waitvid pal+$35, #%%3210

                rdlong  pal+$36, addr           '  +0 =
                cmp     pal+$36, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$37, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$37, #%%3210        '  -4   WHOP    208..223


                rdlong  pal+$38, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$38, #%%3210
                waitvid pal+$39, #%%3210

                rdlong  pal+$3A, addr           '  +0 =
                cmp     pal+$3A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$3B, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$3B, #%%3210        '  -4   WHOP    224..239


                rdlong  pal+$3C, addr           '  +0 =
                add     addr, #8                '  +8   skip 4n+1
                waitvid pal+$3C, #%%3210
                waitvid pal+$3D, #%%3210

                rdlong  pal+$3E, addr           '  +0 =
                cmp     pal+$3E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4

                rdlong  pal+$3F, addr           '  +0 =
                add     addr, #4                '  +8
                cmp     pal+$3F, #%%3210        '  -4   WHOP    240..255

                add     lcnt, #1                ' line has been fetched

                jmp     #hsync                  ' chain call

emit_12         movd    :vid, #pal+0            ' restore initial settings
                mov     ecnt, #64 -1            ' quad pixel count

                mov     vscl, hvis              ' pixel timing
:vid            waitvid 0-0, #%%3210            ' send scanline
                add     $-1, dst1               ' advance dst
                djnz    ecnt, #:vid

                waitvid pal+63, #%%3210
                
                jmp     #hsync                  ' chain call

emit_3          movd    :vid, #pal+0            ' restore initial settings
                mov     ecnt, #64 -1            ' quad pixel count

                mov     vscl, hvis              ' pixel timing
:vid            waitvid 0-0, #%%3210            ' send scanline
                add     $-1, dst1               ' advance dst
                djnz    ecnt, #:vid

                waitvid pal+63, #%%3210
                
                jmpret  zero, #hsync nr,wc      ' chain call (start loading)    (%%)

' initialised data and/or presets

idle            long    hv_idle
sync            long    hv_idle ^ $0200
                        
hvis            long      5 << 12 | 20          '   5/20
slow            long    170 << 12 | 370         ' 170/370
line            long      0 << 12 | 1280        ' 256/1280

mask            long    vpin << (vgrp * 8)      ' pin I/O setup

dst1            long    1 << 9                  ' dst +/-= 1

blnk            long    -4
base            long    +0

' uninitialised data and/or temporaries

href            res     1                       ' hub window reference

ecnt            res     1                       ' element count
lcnt            res     1                       ' line counter
scnt            res     1                       ' scanlines
addr            res     1                       ' colour buffer reference

pal             res     64                      ' colour buffer

tail            fit

DAT                                             ' translation table

__table         word    (@__names - @__table)/2

                word    res_x
                word    res_y
                
__names         byte    "res_x", 0
                byte    "res_y", 0

CON
  zero    = $1F0                                ' par (dst only)
  vpin    = $0FF                                ' pin group mask
  vgrp    = 2                                   ' pin group
  hv_idle = $01010101 * %11 {%hv}               ' h/v sync inactive

  res_x   = 256                                 ' |
  res_y   = 192                                 ' UI support
  
DAT