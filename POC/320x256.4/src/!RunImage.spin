''
'' VGA driver 320x256 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/06/17
''       Version: 0.3
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  columns  = driver#res_x / 8
  rows     = driver#res_y
  bcnt     = columns * rows

  flash    = FALSE
  
  mbyte    = $7F | flash & $80
  mlong    = mbyte * $01010101

OBJ
  driver: "waitvid.320x256.driver.2048"
    font: "generic8x8-1font"
  
VAR
  long  scrn[bcnt /4]                                   ' screen buffer
  long  attr[bcnt /4]                                   ' colour buffer

  long  link[driver#res_m]                              ' mailbox
  long  base
  
PUB selftest : n | x, y

  link{0} := @scrn{0}
  link[1] := @attr{0}
  driver.init(-1, @link{0})                             ' start driver

  base := font.addr
  frqa := frqb := cnt

  repeat                                                  
    fill_1

PRI fill_1 : n | x, y

  repeat y from 0 to 31         
    repeat x from 0 to 39       
      print(x, y, n++, ?frqb & mbyte)
      waitcnt(clkfreq/120 + cnt)

  x := scroll

  repeat n from 0 to 2559
    ifnot n // 10
      repeat 10
        attr[x++] := ?frqb & mlong
    scrn[n] := ?frqa
    waitcnt(clkfreq/480 + cnt)

  scroll
  
PRI print(x, y, c, col) : b

  b := x + y * 320
  c &= 255
  
  repeat 8
    scrn.byte[b] := byte[base][c]
    attr.byte[b] := col
    b += 40
    c += 256
  
PRI scroll

  repeat 256
    waitVBL
    longmove(@attr{0}, @attr[10], constant(bcnt /4 - 10))
    longfill(@attr[constant(bcnt /4 - 10)], $29292929, 10)
    
PRI waitVBL : n

  n := link[3]
  repeat
  while n == link[3]
  
DAT