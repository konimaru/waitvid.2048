''
'' VGA driver test 720x400@85Hz
''
''        Author: Marko Lukat
'' Last modified: 2019/04/19
''       Version: 0.1
''
'' 20190419: initial release
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

' horizontal timing 720(720) 1(36) 2(72) 3(108)
'   vertical timing 400(400) 1(1)  3(3)  42(42)

'               mov     ecnt, #1
vsync           call    #blank                  ' front porch
'               djnz    ecnt, #$-1

                xor     sync, #$0101            ' active

                mov     ecnt, #3
                call    #blank                  ' vertical sync
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

                mov     ecnt, #42
                call    #blank                  ' back porch
                djnz    ecnt, #$-1

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

hsync           mov     vscl, wrap              ' |
                waitvid sync, #%000110          ' horizontal sync pulse (1/2/3 reverse)
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
                        
wrap            long     36 << 12 | 216         '  36/216
hvis            long      1 << 12 | 18          '   1/18
line            long    180 << 12 | 720         ' 180/720

p0              long    %001100110011001100
p1              long    %110011001100110011

plte            long    $00002804 | hv_idle

' Stuff below is re-purposed for temporary storage.

setup

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_110     ' PLL, VCO/2
                mov     frqa, frqx              ' 35.5MHz

                mov     vscl, line              ' transfer user value
                movd    vcfg, #vgrp
                movs    vcfg, #vpin
                movi    vcfg, #%0_01_0_00_000   ' VGA, 2 colour mode

                max     dira, mask              ' drive outputs

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return

' Local data, used only once.

frqx            long    $0E333333               ' 35.5MHz
mask            long    vpin << (vgrp * 8)

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup
                
ecnt            res     1                       ' element count
scnt            res     1                       ' scanlines

tail            fit

CON
  zero    = $1F0                                ' par (dst only)
  hv_idle = $01010101 * %10 {%hv}               ' h/v sync inactive

  vpin    = $0FF                                ' pin group mask
  vgrp    = 2                                   ' pin group

  res_x   = 720                                 ' |
  res_y   = 400                                 ' |
  res_m   = 0                                   ' UI support

  alias   = 0
  
DAT