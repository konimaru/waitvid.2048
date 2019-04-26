''
'' VGA driver test 720x480@60Hz
''
''        Author: Marko Lukat
'' Last modified: 2019/04/26
''       Version: 0.3
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

' horizontal timing 720(720) 16(16) 62(62) 60(60)
'   vertical timing 480(480)  9(9)   6(6)  30(30)
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

                mov     scnt, #res_y /2         ' actual scanline count

:loop           call    #emit0
                call    #emit1

                djnz    scnt, #:loop            ' for all scanlines

                jmp     %%0                     ' next frame


blank           mov     vscl, line              ' 256/720
                waitvid sync, #%0000            ' latch blank line

hsync           mov     vscl, #16 *3            ' 256/16
                waitvid sync, #%0000            ' front

                mov     vscl, wrap              '  62/122
                waitvid sync, #%0001            ' sync+back
hsync_ret
blank_ret       ret


emit0           mov     vscl, hvis
                mov     ecnt, #res_x /9 /2

:loop           waitvid plte, p0
                djnz    ecnt, #:loop

                call    #hsync
emit0_ret       ret


emit1           mov     vscl, hvis
                mov     ecnt, #res_x /9 /2

:loop           waitvid plte, p1
                djnz    ecnt, #:loop

                call    #hsync
emit1_ret       ret

' initialised data and/or presets

sync            long    hv_idle ^ $0200
                        
wrap            long    186 << 12 | 366         '  62/122
hvis            long      3 << 12 | 54          '   1/18
line            long      0 << 12 | 2160        ' 256/720

p0              long    %010101010_101010101
p1              long    %101010101_010101010

plte            long    $00002804 | hv_idle

' Stuff below is re-purposed for temporary storage.

setup

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_111     ' PLL, VCO/1
                movi    frqa, #%0001_00000      ' 80MHz

                mov     vscl, line              ' transfer user value
                movd    vcfg, #vgrp
                movs    vcfg, #vpin
                movi    vcfg, #%0_01_0_00_000   ' VGA, 2 colour mode

                max     dira, mask              ' drive outputs

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return

' Local data, used only once.

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