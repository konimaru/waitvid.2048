''
'' VGA scanline driver 400x300 - demo
''
''   Based on "Ball" demo for Gameduino
''   Copyright (c) 2011 by James Bowman <jamesb@excamera.com>
''
''        Author: Marko Lukat
'' Last modified: 2012/12/24
''       Version: 0.10
''
'' A few notes on timing. A (double) scan line lasts 2*(100+32) hub windows.
'' The background renderer fills the scan line as soon as the video driver
'' has read the relevant quad. At the same time the foreground renderer
'' fetches its data line.
''
''   +-- video driver reads line N                                            
''   +-- background renderer fills line N+1                                   
''   +-- foreground renderer fetches data for line N+1                        
''   |                                                                        
''   |                          +-- scanline N completely fetched             
''   |                          +-- background renderer idle                  
''   |   visible line area      +-- foreground renderer draws shadow and ball
''   |                          |                                             
''   ----------- 100 -----------#---32---                                     
''   ----------- 100 -----------+---32---                                     
''   ----------- 100 -----------#---32---                                     
''   |                                                                        
''   +-- video driver reads line N+1                                          
'' 
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  res_x = driver#res_x
  res_y = driver#res_y
  
OBJ
  driver: "waitvid.400x300.driver.2048"

    back: "xmas.400x300.background"
    ball: "xmas.400x300.foreground"
    anim: "xmas.400x300.feeder"
    
VAR
  long  feeder                                  ' @scan[-3]
  long  coordinates                             ' @scan[-2]
  long  frame                                   ' @scan[-1]
  long  scan[res_x / 4]

PUB selftest

  init
  main
  
PRI init

  driver.init(-1, @scan{0})                     ' scanline driver

  back.init(-1, @scan{0})                       ' background
  ball.init(-1, @scan{0})                       ' foreground
  anim.init(-1, @scan{0})                       ' image feeder

  anim.uncompress(FALSE)                        ' uncompress image
  
CON
  LBASE = 0
  RBASE = res_x - ball#BSIZE
  YBASE = res_y - ball#BSIZE
  
PRI main : r | bx, by, bxv, byv

  bx  := 0
  by  := 0
  bxv := 2
  byv := 1

  repeat
    bx += bxv
    by += byv

    if bx < LBASE
      bx := constant(2*LBASE) - bx
      -bxv

    if bx > RBASE
      bx := constant(2*RBASE) - bx
      -bxv
      
    if by > YBASE
      by := constant(2*YBASE) - by
      -byv

    ifnot ++r & 7                               ' add some gravity
      byv++

    repeat 1
      waitVBL
    coordinates.word{0} := bx                   ' |
    coordinates.word[1] := by                   ' update coordinates
    
PRI waitVBL

  repeat
  until frame == res_y                          ' last line has been fetched
  repeat                  
  until frame <> res_y                          ' vertical blank starts (res_y/0 transition)

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT