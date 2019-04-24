''
'' VGA driver test 720x480@60Hz
''
''        Author: Marko Lukat
'' Last modified: 2019/04/24
''       Version: 0.1
''
'' 20190424: initial release
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
  system: "core.con.system"
    
PUB selftest

  init(-1, 0)

PUB init(ID, mailbox)
                                      
  return system.launch(ID, @driver, mailbox)

DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

' horizontal timing 720(720) 8(16) 31(62) 30(60)
'   vertical timing 480(480) 9(9)   6(6)  30(30)
'
' 27.0 720 736 798 858 480 489 495 525 -/-

'                              +---------------- front porch
'                              | +-------------- sync       
'                              | |  +----------- back porch 
'                              | |  |                       
vsync           mov     ecnt, #9+6+30

                cmp     ecnt, #36 wz
        if_ne   cmp     ecnt, #30 wz
        if_e    xor     sync, #$0101

                call    #blank
                djnz    ecnt, #vsync +1

' Vertical sync chain done, do visible area.

                mov     scnt, #res_y /4         ' actual scanline count

:loop           call    #emit0
                call    #emit0
                call    #emit1
                call    #emit1

                djnz    scnt, #:loop            ' for all scanlines

                jmp     %%0                     ' next frame


blank           mov     vscl, line              ' 180/720
                waitvid sync, #%0000            ' latch blank line

hsync           mov     vscl, wrap_f            '   2/16
                waitvid sync, #%00000000        ' front

                mov     vscl, wrap_sb           '   2/122
                waitvid sync, p2                ' sync+back
hsync_ret
blank_ret       ret


emit0           mov     vscl, hvis
                mov     ecnt, #res_x /9 /4

:loop           waitvid plte, p0
                waitvid plte, p1
                djnz    ecnt, #:loop

                call    #hsync
emit0_ret       ret


emit1           mov     vscl, hvis
                mov     ecnt, #res_x /9 /4

:loop           waitvid plte, p1
                waitvid plte, p0
                djnz    ecnt, #:loop

                call    #hsync
emit1_ret       ret

' initialised data and/or presets

sync            long    hv_idle ^ $0200
                        
wrap_f          long      2 << 12 | 16          '   2/16
wrap_sb         long      2 << 12 | 122         '   2/122
hvis            long      1 << 12 | 18          '   1/18
line            long    180 << 12 | 720         ' 180/720

p0              long    %001100110_011001100
p1              long    %110011001_100110011
p2              long    POSX

plte            long    $00002804 | hv_idle

' Stuff below is re-purposed for temporary storage.

setup

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 27MHz

                mov     vscl, line              ' transfer user value
                movd    vcfg, #vgrp
                movs    vcfg, #vpin
                movi    vcfg, #%0_01_0_00_000   ' VGA, 2 colour mode

                max     dira, mask              ' drive outputs

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return

' Local data, used only once.

frqx            long    $15999999               ' 27MHz
mask            long    vpin << (vgrp * 8)

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup
                
ecnt            res     1                       ' element count
scnt            res     1                       ' scanlines

tail            fit

CON
  zero    = $1F0                                ' par (dst only)
  hv_idle = $01010101 * %11 {%hv}               ' h/v sync inactive

  vpin    = $0FF                                ' pin group mask
  vgrp    = 2                                   ' pin group

  res_x   = 720                                 ' |
  res_y   = 480                                 ' |
  res_m   = 0                                   ' UI support

  alias   = 0
  
DAT