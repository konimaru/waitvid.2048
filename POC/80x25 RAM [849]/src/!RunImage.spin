''
'' VGA display 80x25 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2015/06/15
''       Version: 0.9
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

CON
  CURSOR_ON    = driver#CURSOR_ON
  CURSOR_OFF   = driver#CURSOR_OFF
  CURSOR_ULINE = driver#CURSOR_ULINE
  CURSOR_BLOCK = driver#CURSOR_BLOCK
  CURSOR_FLASH = driver#CURSOR_FLASH
  CURSOR_SOLID = driver#CURSOR_SOLID

  CURSOR_MASK  = driver#CURSOR_MASK

  #0, CM, CX, CY

OBJ
  driver: "waitvid.80x25.driver.2048"
    font: "generic8x16-2font"
  
VAR
  long  scrn[bcnt_raw / 2]                              ' screen buffer
  long  link[driver#res_m]                              ' mailbox

  long  cursor                                          ' text cursor
  
PUB selftest : n | c

  link{0} := video | @scrn{0}
  link[1] := font#height << 24 | font.addr
  link[2] := @cursor * $00010001

  driver.init(-1, @link{0})                             ' start driver

  setCursor(CURSOR_ON|CURSOR_BLOCK|CURSOR_FLASH)

  repeat bcnt                                           ' fill screen
    c := (frqa++ & 127) << 1
'
'   colour format: %FFFF_BBB_A
'
'     FFFF: foreground index
'      BBB: background index
'        A: blink mode (0/1 = off/on)
'
    printChar(c, n++)

PRI redef(c, cdef) : s

  repeat s from 0 to 15 step 2
    word[font.addr][128 * s + c] := byte[cdef][s] << 8 | byte[cdef][s+1]
    
PRI printTextAt(x, y, attr, s)

  x //= columns                                         ' |
  y //= rows                                            ' optional

  repeat strsize(s)
    printCharAt(x++, y, attr, byte[s++])
    ifnot x //= columns                                 ' wrap right
      y := ++y // rows                                  ' wrap bottom (page mode)
      
PRI printCharAt(x, y, attr, c)

  x //= columns                                         ' |
  y //= rows                                            ' optional
  
  attr.byte[1] := c
  scrn.word[bcnt_raw - y * columns - ++x] := attr 

PRI printText(attr, s)

  repeat strsize(s)
    printChar(attr, byte[s++])
      
PRI printChar(attr, c) | x, y

  x := cursor.byte[CX]
  y := cursor.byte[CY]
  
  attr.byte[1] := c
  scrn.word[bcnt_raw - y * columns - ++x] := attr
  ifnot x //= columns                                   ' wrap right
    y := ++y // rows                                    ' wrap bottom (page mode)

  cursor.byte[CX] := x
  cursor.byte[CY] := y
  
PRI clearScreen(attr)

  wordfill(@scrn{0}, $2000 | attr, bcnt_raw)
  cursor.byte[CX] := cursor.byte[CY] := 0
  
PRI setCursor(setup)

  cursor.byte{CM} := (cursor.byte{CM} & constant(!CURSOR_MASK)) | setup
  
DAT