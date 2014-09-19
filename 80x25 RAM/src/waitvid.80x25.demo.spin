''
'' VGA display 80x25 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2014/09/18
''       Version: 0.6
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  columns  = driver#res_x / 9
  rows     = driver#res_y / font#height
  bcnt     = columns * rows

  rows_raw = (driver#res_y + font#height - 1) / font#height
  bcnt_raw = columns * rows_raw

CON
  vgrp     = 2                                          ' video pin group
  mode     = 1                                          ' 0: FG on/off, 1: FG :==: BG

  video    = (vgrp << 9 | mode << 8 | %%333_0) << 21
  
OBJ
  driver: "waitvid.80x25.driver.2048"
    font: "halfrange8x16-2font"
  
VAR
  long  scrn[bcnt_raw / 2]                              ' screen buffer
  long  link[driver#res_m]                              ' mailbox
  
PUB selftest : n | c

  link{0} := video | @scrn{0}
  link[1] := font#height << 24 | font.addr
  link[2] := 0
  
  driver.init(-1, @link{0})                             ' start driver

  repeat bcnt                                           ' fill screen
    c := frqa++ & 255
    c := c << 1 | ||(c > 127)
'
'   colour format: %FFFF_BBB_A
'
'     FFFF: foreground index
'      BBB: background index
'        A: blink mode (0/1 = off/on)

    scrn.word[bcnt - ++n] := ((n & $7F) << 8 | c.byte{0})

PRI redef(c, cdef) : s

  repeat s from 0 to 15 step 2
    word[font.addr][64 * s + c] := byte[cdef][s] << 8 | byte[cdef][s+1]
    
PRI printTextAt(x, y, attr, s)

  repeat strsize(s)
    printCharAt(x++, y, attr, byte[s++])
    ifnot x //= columns                                 ' wrap right
      y := ++y // rows                                  ' wrap bottom (page mode)
      
PRI printCharAt(x, y, attr, c)

  x //= columns                                         ' |
  y //= rows                                            ' |
  c  &= 127                                             ' optional
  
  attr.byte[1] := c
  scrn.word[bcnt_raw - y * columns - ++x] := attr 

PRI clearScreen(attr)

  wordfill(@scrn{0}, $2000 | attr, bcnt)
  
DAT