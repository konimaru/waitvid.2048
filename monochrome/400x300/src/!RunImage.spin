''
'' VGA display 400x300 (single cog, monochrome) - demo
''
''        Author: Marko Lukat
'' Last modified: 2017/08/16
''       Version: 0.1
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  res_x = driver#res_x
  res_y = driver#res_y

  res_m = driver#res_m
  
OBJ
  driver: "waitvid.400x300.mono.driver"

VAR
  long  link[res_m]
  word  screen[res_x/8 * res_y / 2]

PUB null

  init
  demo

PRI demo : rnd | x, y, c

  hline(1, res_x -2,        0, 1)                       ' top
  hline(1, res_x -2, res_y -1, 1)                       ' bottom

  vline(       0, 1, res_y -2, 1)                       ' left
  vline(res_x -1, 1, res_y -2, 1)                       ' right

  repeat
    rnd?                                                ' pseudo random number
    x := rnd.byte{0}                                    ' extract x
    y := rnd.byte[1]                                    ' extract y
    c := rnd >> 31                                      ' extract colour
    pixel(22 + x, 22 + y, c)                            ' plot pixel

PRI init

  link{0} := @screen{0}                                 ' screen address
  driver.init(-1, @link{0})                             ' init driver
  
PRI pixel(x, y, c{0|1}) : addr

  addr := (x >> 3) + y * constant(400 / 8)              ' byte holding pixel
  if c
    screen.byte[addr] |=  (|< (x & 7))                  ' set bit
  else
    screen.byte[addr] &= !(|< (x & 7))                  ' reset bit

PRI hline(x1, x2, y, c) : x

  repeat x from x1 to x2
    pixel(x, y, c)
    
PRI vline(x, y1, y2, c) : y

  repeat y from y1 to y2
    pixel(x, y, c)
    
DAT