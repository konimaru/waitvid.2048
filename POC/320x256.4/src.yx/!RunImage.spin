''
'' VGA driver 320x256 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/06/19
''       Version: 0.2.yx.3
''
'' 20190619: added test for 8+2 in 6+2 environments
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

  long  sH[32], sV[32]
  
PUB selftest : n | x, y

  link{0} := (2 << 9 | %%333_0) << 21 | @scrn{0}
  link[1] := (2 << 9 | %%000_3) << 21 | @attr{0}
  driver.init(-1, @link{0})                             ' start driver

' cognew(plink(16, 2, 0), @sV{0})                       ' |
' cognew(plink(17, 3, 1), @sH{0})                       ' H/V bit links

  base := font.addr
  frqa := frqb := cnt

  repeat                                                  
    fill_1

PRI plink(a,{<<}b,{<<}c)

  dira := |< a | |< b
  ctra := %0_01001_000 << 23 | a << 9 | b               ' outa[a] := !ina[b]
  ctrb := %0_01001_000 << 23 | b << 9 | c               ' outa[b] := !ina[c]

  waitpne(0, 0, 0)
  
PRI fill_1 : n | x, y

  repeat y from 0 to 31         
    repeat x from 0 to 39       
      print(x, y, n++, ?frqb & mbyte)
      waitcnt(clkfreq/120 + cnt)

  scroll

  repeat x from 39 to 0
    repeat 1
      waitVBL
    n := x << 6
    repeat 64
      scrn[n]   := ?frqa
      attr[n++] := ?frqb & mlong
     
  scroll
  
PRI print(x, y, c, col) : b

  b := x << 8 + y << 3
  c &= 255
  
  repeat 8
    scrn.byte[b] := byte[base][c]
    attr.byte[b] := col
    b += 1
    c += 256
  
PRI scroll

  repeat 40
    repeat 1
      waitVBL
    longmove(@attr{0}, @attr[64], constant(bcnt /4 - 64))
    longfill(@attr[constant(bcnt /4 - 64)], $29292929, 64)
    
PRI waitVBL : n

  n := link[3]
  repeat
  while n == link[3]
  
DAT