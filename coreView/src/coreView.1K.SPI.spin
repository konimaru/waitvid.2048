''
''        Author: Marko Lukat
'' Last modified: 2015/12/20
''       Version: 0.8
''
'' 20151214: initial version
'' 20151215: LSB goes out first
'' 20151216: added reset function
''
VAR
  long  link[res_m]
  
PUB null
'' This is not a top level object.

PRI exec(parameters, command)

  command.word[1] := parameters
  link{0} := command
  repeat
  while link{0}

PUB swap(surface)

  exec(surface, cmd_swap)

PUB cmd1(command)

  exec(command, cmd_cmd1)
  
PUB cmdN(buffer, count)

  exec(@buffer, cmd_cmdN)
  
PUB boot

  exec(0, cmd_boot)
  
PUB init

  ifnot cognew(@driver, @link{0}) +1
    abort

  exec(0, cmd_idle)                             ' make sure cog is running
  longfill(@driver{$00}, 0, 64)                 ' before making DAT public
  longfill(@driver[$C0], 0, 64)

  return @driver{0}

CON
'   cmd[8..0]: cog entry address
'     cmd[12]: command has(1) no(0) arguments
' cmd[15..13]: number of arguments -1

  cmd_idle      = %111_0 << 12|$001
  cmd_swap      = %111_0 << 12|$00A
  cmd_cmd1      = %111_0 << 12|$018
  cmd_cmdN      = %001_1 << 12|$019
  cmd_boot      = %111_0 << 12|$027
  
DAT             org     0                       ' display driver

driver          jmpret  $, #setup               ' once

{done}          wrlong  zero, par
{idle}          rdlong  code, par wz
                test    code, argn wc           ' check for arguments
        if_z    jmp     #$-2

                mov     addr, code              '  +0 = args:n:[!Z]:cmd = 16:4:3:9
                ror     addr, #16               '  +4   extract argument location
        if_c    call    #args                   '  +8   fetch arguments
        if_c    addx    addr, #3                '       advance beyond last argument
                jmp     code                    '       execute function

' transfer hub buffer to display

func_0          mov     scnt, #31               ' number of segments -1

                or      outa, mdnc              ' data mode
                andn    outa, msel              ' active
                mov     frqa, #1                ' enable clock

:loop           call    #load                   ' load 8 longs (8*32 pixel) into segment buffer
                call    #emit                   ' send segment to display

                test    scnt, #%11 wz
                add     addr, #4                ' next segment location
        if_nz   sub     addr, #7*16             ' adjust for load advance               (##)

                sub     scnt, #1 wc
        if_ae   jmp     #:loop

                mov     frqa, #0                ' disable clock
                or      outa, msel              ' inactive

                jmp     %%0                     ' return

' send single byte command to display

func_1          mov     phsb, addr

'               carry clear (no arguments)

' send multi byte command to display

func_2          andn    outa, mdnc              ' command mode
                andn    outa, msel              ' active
                mov     frqa, #1                ' enable clock

:loop   if_c    rdbyte  phsb, arg0
                shl     phsb, #23               ' adjust (less one bit)
                mov     bcnt, #8

                neg     phsa, #8                ' low clock pulse for 8 cycles
                shl     phsb, #1                ' setup data bit N
                djnz    bcnt, #$-2              ' for all 8 bits

        if_c    add     arg0, #1
        if_c    djnz    arg1, #:loop

                mov     frqa, #0                ' disable clock
                or      outa, msel              ' inactive
                
                jmp     %%0                     ' return

' reset display h/w (min 3us, 240 clocks @80MHz)

func_3          andn    outa, mres              ' hard reset

func_3_wait     mov     cnt, cnt
                add     cnt, #9{14} + 306       ' min 3us reset pulse (4us)
                waitcnt cnt, #0

                or      outa, mres              ' normal operation

                jmp     %%0                     ' return

' initialised data and/or presets

delta           long    %001_0 << 28 | $FFFC    '  %10  deal with movi setup
                                                ' -(-4) address increment
argn            long    |< 12                   ' function does have arguments

msel            long    |< SPI_SEL
mres            long    |< SPI_RES
mdnc            long    |< SPI_DnC

' support code

args            rdlong  arg0, addr              ' read 1st argument
                cmpsub  addr, delta wc          ' [increment address and] check exit
        if_nc   jmpret  zero, args_ret nr,wc    ' cond: early return
        
                rdlong  arg1, addr              ' read 2nd argument
'               cmpsub  addr, delta wc
'       if_nc   jmpret  zero, args_ret nr,wc

args_ret        ret

' Stuff below is re-purposed for temporary storage.

setup           mov     ctra, ctr0              ' SPI_CLK
                mov     ctrb, ctr1              ' SPI_MOSI

                mov     outa, msel              ' not selected
                max     dira, mask              ' drive outputs/reset

                jmp     #func_3_wait            ' reset, then command loop

ctr0            long    %0_00101_000 << 23 | SPI_CLK << 9 | SPI_IDLE
ctr1            long    %0_00100_000 << 23 |                SPI_MOSI
mask            long    SPI_MASK

                long    -1[0 #> ($40 - $)]

                fit     64

                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1111111111100011, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000011100, %0000000000000000
                word    %1000111111100011, %1000111111100011, %1111100000100011, %1111100000111111, %0000011111011100, %0000011111000000, %0111000000011100, %0000011111000000
                word    %1000011111100011, %1000111111100011, %1110000000000011, %1110000000001111, %0001111111111100, %0001111111110000, %0111100000011100, %0001111111110000
                word    %1100001111100011, %1000111111100011, %1100000000000011, %1100000000000111, %0011111111111100, %0011111111111000, %0011110000011100, %0011111111111000
                word    %1110000111100011, %1000111111100011, %1000011111000011, %1100011111000111, %0011100000111100, %0011100000111000, %0001111000011100, %0011100000111000
                word    %1111000011100011, %1000111111100011, %1000111111100011, %1000111111100011, %0111000000011100, %0111000000011100, %0000111100011100, %0111000000011100
                word    %1111100000000011, %1000111111100011, %1111111111100011, %1000111111100011, %0111000000011100, %0111111111111100, %0000011111111100, %0111000000011100
                word    %1111110000000011, %1000111111100011, %1111111111100011, %1000111111100011, %0111000000011100, %0111111111111100, %0000001111111100, %0111000000011100
                word    %1111110000000011, %1000111111100011, %1111111111100011, %1000111111100011, %0111000000011100, %0111111111111100, %0000001111111100, %0111000000011100
                word    %1111100000000011, %1000111111100011, %1111111111100011, %1000111111100011, %0111000000011100, %0000000000011100, %0000011111111100, %0111000000011100
                word    %1111000011100011, %1000111111100011, %1111111111100011, %1000111111100011, %0111000000011100, %0000000000011100, %0000111100011100, %0111000000011100
                word    %1110000111100011, %1000011111000111, %1111111111100011, %1100011111000111, %0111000000011100, %0111000000111000, %0001111000011100, %0011100000111000
                word    %1100001111100011, %1000000000000111, %1111111111100011, %1100000000000111, %0111000000011100, %0111111111111000, %0011110000011100, %0011111111111000
                word    %1000011111100011, %1000000000001111, %1111111111100011, %1110000000001111, %0111000000011100, %0011111111110000, %0111100000011100, %0001111111110000
                word    %1000111111100011, %1000100000111111, %1111111111100011, %1111100000111111, %0111000000011100, %0000111111000000, %0111000000011100, %0000011111000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000
                word    %1111111111111111, %1111111111111111, %1111111111111111, %1111111111111111, %0000000000000000, %0000000000000000, %0000000000000000, %0000000000000000

' support code

load            rdlong  seg0, addr              ' row 8n+0, columns 32n+0..32n+31
                add     addr, #16               ' y++
                rev     seg0, #{32-}0           ' LSB first

                rdlong  seg1, addr              ' row 8n+1
                add     addr, #16
                rev     seg1, #{32-}0

                rdlong  seg2, addr              ' row 8n+2
                add     addr, #16
                rev     seg2, #{32-}0

                rdlong  seg3, addr              ' row 8n+3
                add     addr, #16
                rev     seg3, #{32-}0

                rdlong  seg4, addr              ' row 8n+4
                add     addr, #16
                rev     seg4, #{32-}0

                rdlong  seg5, addr              ' row 8n+5
                add     addr, #16
                rev     seg5, #{32-}0

                rdlong  seg6, addr              ' row 8n+6
                add     addr, #16
                rev     seg6, #{32-}0

                rdlong  seg7, addr              ' row 8n+7, columns 32n+0..32n+31
'               add     addr, #16               ' y++                                   (##)
                rev     seg7, #{32-}0           ' LSB first
load_ret        ret


emit            mov     ccnt, #32

                neg     phsa, #8                ' low clock pulse for 8 cycles
                mov     phsb, seg7              ' setup data bit 7
                rol     seg7, #1                ' prepare next bit

                neg     phsa, #8
                mov     phsb, seg6              '            bit 6
                rol     seg6, #1

                neg     phsa, #8
                mov     phsb, seg5              '            bit 5
                rol     seg5, #1

                neg     phsa, #8
                mov     phsb, seg4              '            bit 4
                rol     seg4, #1

                neg     phsa, #8
                mov     phsb, seg3              '            bit 3
                rol     seg3, #1

                neg     phsa, #8
                mov     phsb, seg2              '            bit 2
                rol     seg2, #1

                neg     phsa, #8
                mov     phsb, seg1              '            bit 1
                rol     seg1, #1 

                neg     phsa, #8                ' low clock pulse for 8 cycles
                mov     phsb, seg0              ' setup data bit 0            
                rol     seg0, #1                ' prepare next bit            

                djnz    ccnt, #$-3*8            ' for all 32*8 bits

emit_ret        ret

EOD{ata}        fit

' uninitialised data and/or temporaries

                org     setup

addr            res     1                       ' parameter pointer
code            res     1                       ' function entry point

arg0            res     1                       ' |
arg1            res     1                       ' command arguments

seg0            res     1                       ' |
seg1            res     1                       ' |
seg2            res     1                       ' |
seg3            res     1                       ' |
seg4            res     1                       ' |
seg5            res     1                       ' |
seg6            res     1                       ' |
seg7            res     1                       ' segment buffer

bcnt            res     1                       ' bit count
ccnt            res     1                       ' segment column counter
scnt            res     1                       ' segment count

tail            fit     load

EndOfBinary     long    -1[0 #> (256 - (@EndOfBinary - @driver) / 4)]

CON
  zero          = $1F0                          ' par (dst only)

  res_m         = 1                             ' UI support
  res_a         = 2                             ' max command arguments

  alias         = 0
  
CON
  SPI_SEL       = 18            
  SPI_RES       = 19
  SPI_DnC       = 20
  SPI_CLK       = 21
  SPI_MOSI      = 22

  SPI_MASK      = |< SPI_MOSI | |< SPI_CLK | |< SPI_DnC | |< SPI_RES | |< SPI_SEL
  SPI_IDLE      = >|(!SPI_MASK)-1               ' unused pin not in SPI_MASK
  
DAT
