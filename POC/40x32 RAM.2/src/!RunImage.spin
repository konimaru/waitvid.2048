''
'' VGA driver 320x256 (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/01/26
''       Version: 0.1
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
  vpin     = %%333_0                                    ' video pin mask

  video    = (vgrp << 9 | vpin) << 21

OBJ
  driver: "waitvid.320x256.driver.2048"
    font: "generic8x16-4font"
  
VAR
  long  scrn[bcnt_raw / 2]                              ' screen buffer
  long  link[driver#res_m]                              ' mailbox

  long  cursor                                          ' text cursor
  
PUB selftest : n

  link{0} := video | @scrn{0}
  link[1] := font.addr

  driver.init(-1, @link{0})                             ' start driver
{
' setCursor(CURSOR_ON|CURSOR_ULINE|CURSOR_FLASH)

  repeat bcnt                                           ' fill screen
    printChar(n, n++)

  block( 5, 1, $30)
  block(23, 1, $20)
  block(41, 1, $50)
  block(59, 1, $70)
'}
DAT