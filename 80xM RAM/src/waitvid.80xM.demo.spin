''
'' VGA display 80xM (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2013/11/23
''       Version: 0.1
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  columns  = driver#res_x / 8
  rows     = driver#res_y / font#height
  bcnt     = columns * rows

  rows_raw = (driver#res_y + font#height - 1) / font#height
  bcnt_raw = columns * rows_raw

OBJ
  driver: "waitvid.80xM.driver.2048"
    font: "generic8x12-1font"
    
VAR
  long  link[driver#res_m]
  word  scrn[bcnt_raw / 2]
  
PUB selftest : n

  wordfill(@scrn{0}, $2020, bcnt_raw/2)                 ' clear screen
                                                        
  link{0} := @scrn{0}
  link[1] := font#height << 24 | font.addr
  link[2] := NEGX|%%0220_0010
  
  driver.init(-1, @link{0})                             ' start driver

  repeat bcnt
    scrn.byte[n++] := n

DAT