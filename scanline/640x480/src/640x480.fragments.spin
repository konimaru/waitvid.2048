''
'' VGA scanline driver 640x480 (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2019/05/12
''       Version: 0.1
''
'' acknowledgements
'' - loader code based on work done by Phil Pilgrim (PhiPi)
''
'' 20190512: initial version
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000
  
CON
  vgrp     = 2                                          ' video pin group
  vpin     = %%333_3                                    ' video pin mask
  video    = (vgrp << 9 | vpin) << 21

VAR
  long  mbox[res_m]
  long  scn0[res_x /4]
  long  scn1[res_x /4]
  
PUB selftest : n

  scn0[0] := %%3000'%%3000_0300_0030_3300
  scn1[0] := %%2220_2220_2220_2220

  scn0[159] := %%3000_0000_0000_0000
  scn1[159] := %%2220_2220_2220_2220

  mbox{0} := @scn1{0} << 16 | @scn0{0}
  mbox[1] := video
  
  init(-1, @mbox{0})

  repeat
    repeat n from 0 to res_x /4 -1
      waitVBL
      scn0[n] := %%0000_0000_0000_2222
      waitVBL
      scn0[n] := %%0000_0000_2222_2222
      waitVBL
      scn0[n] := %%0000_2222_2222_2222
      waitVBL
      scn0[n] := %%2222_2222_2222_2222
     
    repeat n from res_x /4 -1 to 0
      waitVBL
      scn0[n] := %%0000_2222_2222_2222
      waitVBL
      scn0[n] := %%0000_0000_2222_2222
      waitVBL
      scn0[n] := %%0000_0000_0000_2222
      waitVBL
      scn0[n] := %%0000_0000_0000_0000
     
PRI waitVBL

  repeat
  until mbox[1] == res_y                        ' last line has been fetched
  repeat                  
  until mbox[1] <> res_y                        ' vertical blank starts (res_y/0 transition)

OBJ
  system: "core.con.system"

PUB null
'' This is not a top level object.

PUB init(ID, mailbox) : cog

  word[mailbox][2] := 0

  cog := system.launch( ID, @driver, mailbox) & 7
  cog := system.launch(cog, @driver, mailbox|$8000)

  repeat
  until word[mailbox][2] == $FFFF               ' OK (secondary/primary)

  word[mailbox][2] := 0                         ' release sync lock

DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

' horizontal timing 640(640) 16(16) 96(96) 48(48)
'   vertical timing 480(480) 10(10)  2(2)  33(33)

                cmpsub  lcnt, #res_y            ' reset line counter
        if_c    wrlong  zero, fcnt_             ' indicate vertical blank

'                               +---------------- front porch
'                               | +-------------- sync
'                               | |    +--------- back porch
'                               | |    |
vsync           mov     ecnt, #10+2+(33-2)

                cmp     ecnt, #33 wz
        if_ne   cmp     ecnt, #31 wz
        if_e    xor     sync, #$0101            ' in/active

                call    #blank
                djnz    ecnt, #vsync+1


        if_c    call    #blank                  ' secondary delayed by one row

                mov     vscl, line              ' |
                waitvid sync, #%%000            ' blank line (no sync)

                mov     vscl, seqc              ' |
                waitvid sync, seqc_value        ' sync + (off)line

                mov     cnt, cnt                ' |
                add     cnt, fcnt               ' record sync point
                
                call    #load                   ' fill colour buffer

' Vertical sync chain done, do visible area.

                mov     ecnt, #res_y /2 -1      ' rows (split between primary and secondary)
                mov     link, seqc              ' full sequence (long tail)
                
:loop           call    #emit                   ' display scanline
                call    #load                   ' fill colour buffer
                
                djnz    ecnt, #:loop            ' for all but last row

        if_c    mov     link, wrap              ' secondary runs short tail
                call    #emit                   ' last line

                jmp     %%0                     ' next frame


blank           mov     vscl, line              ' 256/640
                waitvid sync, #%%000            ' latch blank line

                mov     vscl, wrap              ' |
                waitvid sync, wrap_value        ' horizontal sync pulse
blank_ret       ret


load            muxnc   flag, $                 ' preserve carry flag

                movd    :ld0, #col +160 -1
                movd    :ld1, #col +160 -2
                mov     eins, scan              ' hub source
                
:ld0            rdlong  0-0, eins               ' |
                sub     $-1, dst2               ' |
                sub     eins, i2s7 wc           ' |
:ld1            rdlong  0-0, eins               ' |
                sub     $-1, dst2               ' |
        if_nc   djnz    eins, #:ld0             ' sub #7/djnz (Thanks Phil!)

                wrlong  lcnt, fcnt_             ' buffer has been fetched
                add     lcnt, #2                ' advance

load_ret        jmpret  flag, #0-0 nr,wc        ' restore carry flag


emit            waitcnt cnt, #0                 ' re-sync after back porch

                mov     outa, idle              ' take over sync lines
                mov     vscl, hvis              '   1/4, speed up (one pixel per frame clock)

                waitvid col+  0, #%%3210
                waitvid col+  1, #%%3210
                waitvid col+  2, #%%3210
                waitvid col+  3, #%%3210
                waitvid col+  4, #%%3210
                waitvid col+  5, #%%3210
                waitvid col+  6, #%%3210
                waitvid col+  7, #%%3210
                waitvid col+  8, #%%3210
                waitvid col+  9, #%%3210
                waitvid col+ 10, #%%3210
                waitvid col+ 11, #%%3210
                waitvid col+ 12, #%%3210
                waitvid col+ 13, #%%3210
                waitvid col+ 14, #%%3210
                waitvid col+ 15, #%%3210        ' pixels 0..63

                waitvid col+ 16, #%%3210
                waitvid col+ 17, #%%3210
                waitvid col+ 18, #%%3210
                waitvid col+ 19, #%%3210
                waitvid col+ 20, #%%3210
                waitvid col+ 21, #%%3210
                waitvid col+ 22, #%%3210
                waitvid col+ 23, #%%3210
                waitvid col+ 24, #%%3210
                waitvid col+ 25, #%%3210
                waitvid col+ 26, #%%3210
                waitvid col+ 27, #%%3210
                waitvid col+ 28, #%%3210
                waitvid col+ 29, #%%3210
                waitvid col+ 30, #%%3210
                waitvid col+ 31, #%%3210        ' pixels 64..127

                waitvid col+ 32, #%%3210
                waitvid col+ 33, #%%3210
                waitvid col+ 34, #%%3210
                waitvid col+ 35, #%%3210
                waitvid col+ 36, #%%3210
                waitvid col+ 37, #%%3210
                waitvid col+ 38, #%%3210
                waitvid col+ 39, #%%3210
                waitvid col+ 40, #%%3210
                waitvid col+ 41, #%%3210
                waitvid col+ 42, #%%3210
                waitvid col+ 43, #%%3210
                waitvid col+ 44, #%%3210
                waitvid col+ 45, #%%3210
                waitvid col+ 46, #%%3210
                waitvid col+ 47, #%%3210        ' pixels 128..191

                waitvid col+ 48, #%%3210
                waitvid col+ 49, #%%3210
                waitvid col+ 50, #%%3210
                waitvid col+ 51, #%%3210
                waitvid col+ 52, #%%3210
                waitvid col+ 53, #%%3210
                waitvid col+ 54, #%%3210
                waitvid col+ 55, #%%3210
                waitvid col+ 56, #%%3210
                waitvid col+ 57, #%%3210
                waitvid col+ 58, #%%3210
                waitvid col+ 59, #%%3210
                waitvid col+ 60, #%%3210
                waitvid col+ 61, #%%3210
                waitvid col+ 62, #%%3210
                waitvid col+ 63, #%%3210        ' pixels 192..255

                waitvid col+ 64, #%%3210
                waitvid col+ 65, #%%3210
                waitvid col+ 66, #%%3210
                waitvid col+ 67, #%%3210
                waitvid col+ 68, #%%3210
                waitvid col+ 69, #%%3210
                waitvid col+ 70, #%%3210
                waitvid col+ 71, #%%3210
                waitvid col+ 72, #%%3210
                waitvid col+ 73, #%%3210
                waitvid col+ 74, #%%3210
                waitvid col+ 75, #%%3210
                waitvid col+ 76, #%%3210
                waitvid col+ 77, #%%3210
                waitvid col+ 78, #%%3210
                waitvid col+ 79, #%%3210        ' pixels 256..319

                waitvid col+ 80, #%%3210
                waitvid col+ 81, #%%3210
                waitvid col+ 82, #%%3210
                waitvid col+ 83, #%%3210
                waitvid col+ 84, #%%3210
                waitvid col+ 85, #%%3210
                waitvid col+ 86, #%%3210
                waitvid col+ 87, #%%3210
                waitvid col+ 88, #%%3210
                waitvid col+ 89, #%%3210
                waitvid col+ 90, #%%3210
                waitvid col+ 91, #%%3210
                waitvid col+ 92, #%%3210
                waitvid col+ 93, #%%3210
                waitvid col+ 94, #%%3210
                waitvid col+ 95, #%%3210        ' pixels 320..383

                waitvid col+ 96, #%%3210
                waitvid col+ 97, #%%3210
                waitvid col+ 98, #%%3210
                waitvid col+ 99, #%%3210
                waitvid col+100, #%%3210
                waitvid col+101, #%%3210
                waitvid col+102, #%%3210
                waitvid col+103, #%%3210
                waitvid col+104, #%%3210
                waitvid col+105, #%%3210
                waitvid col+106, #%%3210
                waitvid col+107, #%%3210
                waitvid col+108, #%%3210
                waitvid col+109, #%%3210
                waitvid col+110, #%%3210
                waitvid col+111, #%%3210        ' pixels 384..447

                waitvid col+112, #%%3210
                waitvid col+113, #%%3210
                waitvid col+114, #%%3210
                waitvid col+115, #%%3210
                waitvid col+116, #%%3210
                waitvid col+117, #%%3210
                waitvid col+118, #%%3210
                waitvid col+119, #%%3210
                waitvid col+120, #%%3210
                waitvid col+121, #%%3210
                waitvid col+122, #%%3210
                waitvid col+123, #%%3210
                waitvid col+124, #%%3210
                waitvid col+125, #%%3210
                waitvid col+126, #%%3210
                waitvid col+127, #%%3210        ' pixels 448..511

                waitvid col+128, #%%3210
                waitvid col+129, #%%3210
                waitvid col+130, #%%3210
                waitvid col+131, #%%3210
                waitvid col+132, #%%3210
                waitvid col+133, #%%3210
                waitvid col+134, #%%3210
                waitvid col+135, #%%3210
                waitvid col+136, #%%3210
                waitvid col+137, #%%3210
                waitvid col+138, #%%3210
                waitvid col+139, #%%3210
                waitvid col+140, #%%3210
                waitvid col+141, #%%3210
                waitvid col+142, #%%3210
                waitvid col+143, #%%3210        ' pixels 512..575

                waitvid col+144, #%%3210
                waitvid col+145, #%%3210
                waitvid col+146, #%%3210
                waitvid col+147, #%%3210
                waitvid col+148, #%%3210
                waitvid col+149, #%%3210
                waitvid col+150, #%%3210
                waitvid col+151, #%%3210
                waitvid col+152, #%%3210
                waitvid col+153, #%%3210
                waitvid col+154, #%%3210
                waitvid col+155, #%%3210
                waitvid col+156, #%%3210
                waitvid col+157, #%%3210
                waitvid col+158, #%%3210
                waitvid col+159, #%%3210        ' pixels 576..639

                mov     vscl, link              ' |
                waitvid sync, seqc_value        ' tail (long/short)

                mov     cnt, cnt                ' |
                add     cnt, fcnt               ' record sync point

                mov     outa, #0                ' stop interfering
emit_ret        ret

' initialised data and/or presets
                
fcnt            long    9{14} +(3000 -14)       ' ~960 pixel clocks
lcnt            long    1                       ' line counter

flag            long    0                       ' loader flag storage
idle            long    hv_idle
sync            long    (hv_idle ^ $0200) & $FF00FFFF

seqc            long    16 << 12 | 960          '  16/960
wrap            long    16 << 12 | 160          '  16/160
hvis            long     1 << 12 | 4            '   1/4
line            long     0 << 12 | 640          ' 256/640

seqc_value      long
wrap_value      long    %%2222_2200_0111_1110

scan_           long    $00000000 -4            ' |
fcnt_           long    $00000004 -4            ' mailbox addresses (local copy)

dst2            long    2 << 9                  ' dst     +/-= 2
i2s7            long    2 << 23 | 7

' Stuff below is re-purposed for temporary storage.

setup           add     trap, par wc            ' carry set -> secondary
                and     trap, hram              ' confine to hub RAM

                add     scan_, trap             ' @long[par][0]
                add     fcnt_, trap             ' @long[par][1]

                addx    trap, #%00              ' add secondary offset
                wrbyte  hram, trap              ' up and running

                rdword  temp, trap wz           ' |
        if_nz   jmp     #$-1                    ' synchronized start

'   primary: cnt + 0
' secondary: cnt + 2

                rdlong  scan, scan_             ' double buffer
                wrlong  zero, scan_             ' acknowledge buffer
                
                rdlong  eins, fcnt_             ' vcfg setup
                wrlong  zero, fcnt_             ' acknowledge setup

' Perform pending setup.

                addx    lcnt, #0                ' even/odd
                
        if_c    shr     scan, #16               ' secondary buffer
                and     scan, hram              ' confine to hub RAM

                movi    scan, #(res_x /4) -2    ' magic marker
                add     scan, $+1               ' last byte in buffer
                long    res_x -1

' Upset video h/w and relatives.

                rdlong  temp, #0                ' clkfreq
                shr     temp, #10               ' ~1ms
        if_nc   waitpne $, #0                   ' adjust primary

'   primary: cnt + 0 + 6
' secondary: cnt + 2 + 4

                add     temp, cnt

                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 25.175MHz

                mov     vscl, #1                ' reload as fast as possible
                shr     eins, #21               ' vgrp:[!Z]:vpin:[!Z] = 2:1:8:21
                mov     vcfg, eins              ' |
                movi    vcfg, #%0_01_1_00_000   ' VGA, 4 colour mode

                waitcnt temp, #0                ' PLL settled, frame counter flushed

                ror     vcfg, #1                ' freeze video h/w
                mov     vscl, line              ' transfer user value
                rol     vcfg, #1                ' unfreeze
                waitpne $, #0                   ' get some distance
                waitvid zero, #0                ' latch user value

                mov     temp, vcfg              ' |
                shr     temp, #9                ' extract vgrp
                shl     temp, #3                ' 0..3 >> 0..24
                shl     mask, temp              ' finalise mask

                max     dira, mask              ' drive outputs

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return
                
' Local data, used only once.

hram            long    $00007FFF               ' hub RAM mask
trap            long    $FFFF8000 +4            ' primary/secondary trap

frqx            long    $1423D70A               ' 25.175MHz
mask            long    %11111111

EOD{ata}        fit

' uninitialised data and/or temporaries

                org     setup
                
col             res     160                     ' colour buffer

ecnt            res     1                       ' element count
link            res     1                       ' tail selector
scan            res     1                       ' scanline hub location

temp            res     1
eins            res     1

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

  res_x   = 640                                 ' |
  res_y   = 480                                 ' |
  res_m   = 2                                   ' UI support

  alias   = 0

DAT