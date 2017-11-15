''
'' VGA display 50x18 (single cog, ROM font) - simple video overlay
''
''        Author: Marko Lukat
'' Last modified: 2017/11/15
''       Version: 0.2
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

CON
  columns  = driver#res_x / 16
  rows     = driver#res_y / 32
  bcnt     = columns * rows

  rows_raw = (driver#res_y + 32 - 1) / 32
  bcnt_raw = columns * rows_raw

OBJ
  client: "core.con.client.demoboard"
  driver: "waitvid.50x18.driver.2048"
    
VAR
  long  link[driver#res_m]                              ' driver mailbox
  word  scrn[bcnt_raw / 2]                              ' screen buffer (2n aligned)
  long  cols[bcnt_raw / 2]                              ' colour buffer (4n aligned)

PUB main : c

  init                                                  ' start drivers

  repeat bcnt          
    scrn.byte[c++] := c                                 ' generate some content

PRI init

  bytefill(@scrn{0}, 32, bcnt_raw)                      ' clear screen
  wordfill(@cols{0}, %%3330_0000, bcnt_raw)             ' default colour

  link{0} := @scrn{0}                                   ' initial screen and
  link[2] := @cols{0}                                   ' colour buffer

  driver.init(-1, @link{0})                             ' video driver and pixel generator
  cognew(@overlay, @link{0})                            ' POC overlay

DAT             org     0                       ' video overlay

overlay         jmpret  $, #setup               ' once

' horizontal timing 800(800) 40(40) 128(128) 88(88)
'   vertical timing 600(600)  1(1)    4(4)   23(23)

vsync           mov     temp, #1 + 4 + 23
                call    #blank                  ' timing only
                djnz    temp, #$-1

' Vertical sync chain done, do visible area.

                mov     temp, vres              ' max visible scanlines

:line           call    #emit                   ' overlay 
                call    #hsync
                
                djnz    temp, #:line            ' repeat for all rows

                jmp     %%0                     ' next frame


blank           mov     vscl, phsa              ' 256/800
                waitvid zero, #%%0000           ' latch blank line

hsync           mov     vscl, #256              ' 256/256
                waitvid zero, #%%0
hsync_ret
blank_ret       ret


emit            mov     vscl, hvis              ' 1/16
                mov     ccnt, #50               ' character count

                waitvid ocol, opix
                djnz    ccnt, #$-1              ' next 16px

emit_ret        ret

' initialised data and/or presets

hvis            long    1 << 12 | 16            ' 1/16

vres            long    res_y

ocol            long    %%3300_0030_0300_3000
opix            long    %%3333_2222_1111_0000

' Stuff below is re-purposed for temporary storage.

setup           add     fcnt_, par              ' @long[par][3]

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_110     ' PLL, VCO/2
                movi    frqa, #%0001_00000      ' 5MHz * 16 / 2 = 40MHz
                movs    frqa, #res_x/4          ' |
                movs    frqa, #0                ' insert res_x into phsa
                
                mov     vscl, hvis              ' 1/16
                mov     vcfg, vcfg_base         ' VGA, 4 colour mode

                rdlong  cnt, #0
                shr     cnt, #10                ' ~1ms
                add     cnt, cnt               
                waitcnt cnt, #0                 ' PLL needs to settle


                rdlong  temp, fcnt_
                rdlong  href, fcnt_
                cmp     href, temp wz
        if_e    jmp     #$-2                    ' wait for vsync announcement

' href is set 4 + 9 + 436 cycles after the initial hsync waitvid (see driver)
'
'           hsync     vscl       vsync detection
'          -------   ------   ---------------------
' delay = (256 * 2 - 16 * 2 - (lref - (href - 449))) / 2
'       = (480 - lref + href - 449) / 2
'       = (href + 31 - lref) / 2

                add     href, #31
                
                waitvid zero, #0                ' dummy (first one is unpredictable)
                waitvid zero, #0                ' point of (local) reference

                sub     href, cnt               ' - lref

                shr     href, #1 wc
        if_c    hubop   $, #%10000_000

                mov     vscl, href              ' final adjustment
                waitvid zero, #0                ' latch it
                max     dira, mask              ' drive outputs

                jmp     %%0                     ' return

vcfg_base       long    %0_01_1_00_000 << 23 | vgrp << 9 | vpin
mask            long    vpin << (vgrp * 8)
fcnt_           long    12                      ' mailbox address (local copy)

                fit
                
' uninitialised data and/or temporaries

                org     setup

href            res     1                       ' hsync reference
ccnt            res     1                       ' character count
temp            res     1

tail            fit
                
CON     
  zero  = $1F0                                  ' par (dst only)
  vpin  = $0FC                                  ' pin group mask
  vgrp  = 2                                     ' pin group
  
  res_x = 800                                   ' |
  res_y = 600                                   ' |
  res_m = 4                                     ' UI support

  alias = 0
  
DAT