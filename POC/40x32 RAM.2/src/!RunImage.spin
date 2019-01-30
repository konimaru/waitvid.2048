''
'' VGA driver 320x256 (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/01/30
''       Version: 0.2
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  columns  = driver#res_x / 8
  rows     = driver#res_y
  bcnt     = columns * rows

CON
  vgrp     = 2                                          ' video pin group
  vpin     = %%333_0                                    ' video pin mask

  video    = (vgrp << 9 | vpin) << 21

OBJ
  driver: "waitvid.320x256.driver.2048"
    font: "generic8x8-1font"
  
VAR
  byte  scrn[bcnt]                                      ' screen buffer
  byte  attr[bcnt]                                      ' colour buffer
  long  link[driver#res_m]                              ' mailbox
  long  base
  
PUB selftest : n | x, y

  init

  repeat y from 0 to 31
    repeat x from 0 to 39
      print(x, y, n, n++)

PRI init

  link{0} := video | @scrn{0}
  link[1] := @attr{0}

  driver.init(-1, @link{0})                             ' start driver

  base := font.addr
  
PRI print(x, y, c, col) : b

  b := x + y * 320
  c &= 255
  
  repeat 8
    scrn[b] := byte[base][c]
    attr[b] := col
    b += 40
    c += 256
  
DAT