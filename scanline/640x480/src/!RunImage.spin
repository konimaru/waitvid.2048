''
'' VGA scanline driver 640x480 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/05/13
''       Version: 0.3
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  res_x = driver#res_x
  res_y = driver#res_y

  quads = res_x / 4

CON
  vgrp     = 2                                          ' video pin group
  vpin     = %%333_3                                    ' video pin mask
  video    = (vgrp << 9 | vpin) << 21

OBJ
  driver: "waitvid.640x480.driver.2048"
  
VAR
  long  link[driver#res_m]
  long  scn0[quads]
  long  scn1[quads]

PUB selftest : n

' simple double buffer setup

  link{0} := @scn1{0} << 16 | @scn0{0}
  link[1] := video

  driver.init(-1, @link{0})

  repeat 180
    waitVBL

' Vertical yellow line from left to right.

  waitVBL
  scn0.byte[n] := %%3300
  scn0.byte[n] := %%3300

  repeat constant(res_x -1)
    waitVBL
    scn0.byte[n]   := %%0000
    scn1.byte[n++] := %%0000
    scn0.byte[n] := scn1.byte[n] := %%3300

' Vertical purple line from right to left.

  waitVBL
  scn0.byte[n] := %%3030
  scn1.byte[n] := %%3030

  repeat constant(res_x -1)
    waitVBL
    scn0.byte[n]   := %%0000
    scn1.byte[n--] := %%0000
    scn0.byte[n] := scn1.byte[n] := %%3030

  scn0{0} := scn1{0} := 0

' Vertical scrollers.

  chain

PRI waitVBL

  repeat
  until link.word[2] == res_y                   ' last line has been fetched
  repeat
  until link.word[2] <> res_y                   ' vertical blank starts (res_y/0 transition)

PRI chain : n

  repeat n from 0 to 16 step 4
    waitcnt(clkfreq + cnt)
    workspace[n +0] += @scn0{0}
    workspace[n +1] += @scn1{0}
    workspace[n +3] := @link.word[2]
    cognew(@entry, @workspace[n])
    
DAT
                long
workspace       word      +0,   +0, 128, 0
                word    +128, +128, 128, 0
                word    +256, +256, 128, 0
                word    +384, +384, 128, 0
                word    +512, +512, 128, 0
                
DAT             org     0

entry           jmpret  $, #setup

                rdword  indx, fcnt_             ' |
                cmpsub  indx, #res_y wz         ' |
        if_ne   jmp     #$-2                    ' waiting for last line to be fetched

                mov     addr, base

                call    #copy                   ' primary
line            call    #copy                   ' secondary/next
                
                cmp     indx, #res_y -2 wz
        if_e    add     base, steps             ' shift n lines per frame
        if_e    jmp     %%0

                add     indx, #1                ' line done, advance target

                rdword  temp, fcnt_             ' |
                cmp     temp, indx wz           ' |
        if_ne   jmp     #$-2                    ' FI:indx-1/indx
                jmp     #line                   ' for all lines


copy            mov     eins, addr              ' |
                mov     zwei, strip             ' working copy

                mov     ecnt, s_len             ' number of bytes

:loop           rdlong  temp, eins
                add     eins, #4
                sub     ecnt, #3
                wrlong  temp, zwei
                add     zwei, #4
                djnz    ecnt, #:loop

                rol     strip, #16              ' swap buffers
                add     addr, s_len             ' advance source address
copy_ret        ret

' initialised data and/or presets

fcnt_           long    +6                      ' @word[par][3]

' Stuff below is re-purposed for temporary storage.

setup           rdlong  strip, par              ' double buffer reference

                add     zwei_, par
                add     fcnt_, par

                rdword  s_len, zwei_            ' strip length
                andn    s_len, #3               ' 4n
                rdword  fcnt_, fcnt_            ' frame counter location

                cogid   steps
                cmpsub  steps, #3
                cmpsub  steps, #3               ' steps := cogid // 3

                cmp     steps, #1 wz,wc
                mov     steps, s_len             ' 1x
        if_ae   add     steps, s_len             ' 2x
        if_a    add     steps, s_len             ' 3x

                jmp     %%0                     ' return

' Local data, used only once.

zwei_           long    +4                      ' @word[par][2]

EOD{ata}        fit

' uninitialised data and/or temporaries

                org     setup

strip           res     1
s_len           res     1
steps           res     1

addr            res     1
indx            res     1
base            res     1
ecnt            res     1

temp            res     1

eins            res     1
zwei            res     1

tail            fit

DAT