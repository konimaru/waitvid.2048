''
'' VGA driver 320x256 (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2013/05/04
''       Version: 0.8
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000
  
CON
  res_x = driver#res_x
  res_y = driver#res_y

  quadP = res_x * res_y / 32
  quadC = res_x * res_y / 128

  flash = FALSE
  
  mbyte = $7F | flash & $80
  mlong = mbyte * $01010101

OBJ
  driver: "waitvid.320x256.driver.2048"
    font: "generic8x8-1font"

VAR
  long  link[driver#res_m], base

  long  screen[quadP]
  long  colour[quadC]
  
PUB selftest

  link{0} := @screen{0}
  link[1] := @colour{0}
  driver.init(-1, @link{0})                             ' start driver

  base := font.addr
  frqa := frqb := cnt

  repeat                                                  
    fill
  
PRI fill : n | x, y

  repeat y from 0 to 31         
    repeat x from 0 to 39       
      print(x, y, n++, ?frqb & mbyte)
      waitcnt(clkfreq/120 + cnt)

  x := scroll

  repeat n from 0 to 2559
    ifnot n // 40
      repeat 10
        colour[x++] := ?frqb & mlong
    screen[n] := ?frqa
    waitcnt(clkfreq/240 + cnt)

  scroll
  
PRI print(x, y, c, col) : b

  b := x + y * 320
  c &= 255
  
  repeat 8
    screen.byte[b] := byte[base][c]
    b += 40
    c += 256

  colour.byte[x + y * 80]      := col
  colour.byte[x + y * 80 + 40] := col
  
PRI scroll

  repeat 64
    waitVBL
    longmove(@colour{0}, @colour[10], constant(quadC - 10))
    longfill(@colour[630], $29292929, 10)
    
PRI waitVBL : n

  n := link[3]
  repeat
  while n == link[3]
  
DAT