''
'' VGA scanline driver 640x480 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/05/12
''       Version: 0.2
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

PRI waitVBL

  repeat
  until link.word[2] == res_y                   ' last line has been fetched
  repeat
  until link.word[2] <> res_y                   ' vertical blank starts (res_y/0 transition)

DAT