''
''        Author: Marko Lukat
'' Last modified: 2014/07/03
''       Version: 0.15
''
'' 20140620: switched to data reference for sprites (header uses -ve offset)
''
OBJ
  driver: "coreGFX.driver.2048"

VAR
  long  instruction
  long  drawsurface
  long  copysurface

VAR
  long  c_fillbuffer, c_copybuffer, c_setclip, c_blitsprite
  long  c_parameters[driver#res_a]

PUB null
'' This is not a top level object.

PUB init(screen{8:*:16})

  longfill(@instruction, screen|1, 3)
  drawsurface.word{0} := driver.init(-1, @instruction) >> 16

  longfill(@c_fillbuffer, @c_parameters << 16, 4)

  c_fillbuffer |= driver#cmd_fillbuffer
  c_copybuffer |= driver#cmd_copybuffer
  c_setclip    |= driver#cmd_setclip
  c_blitsprite |= driver#cmd_blitsprite

  repeat
  while instruction                                     ' wait until cog is running

  return drawsurface

PUB fillBuffer(dst, value)

  repeat
  while instruction

  longmove(@c_parameters{0}, @dst, 2)
  instruction := c_fillbuffer

PUB copyBuffer(dst, src)

  repeat
  while instruction

  longmove(@c_parameters{0}, @dst, 2)
  instruction := c_copybuffer

PUB postBuffer

  copyBuffer(copysurface, drawsurface)

PUB blitSprite(dst, src, x, y, frame)

  repeat
  while instruction

  longmove(@c_parameters{0}, @dst, 5)
  instruction := c_blitsprite

PUB setClip(x1, y1, x2, y2)

  repeat
  while instruction

  longmove(@c_parameters{0}, @x1, 4)
  instruction := c_setclip

CON
PRI Start(screen)
PRI WaitToDraw
PRI ClearScreen
PRI FillScreen(colour)
PRI Blit(source)
PRI Box(source, x, y)
PRI Sprite(source, x, y, frame)
PRI LoadMap(source_tilemap, source_levelmap)
PRI TestMapCollision(objx, objy, objw, objh)
PRI GetMapWidth
PRI GetMapHeight
PRI DrawMap(offset_x, offset_y)
PRI LoadFont(sourcevar, startingcharvar, tilesize_xvar, tilesize_yvar)
PRI PutChar(char, x, y)
PRI PutString(stringvar, origin_x, origin_y)
PRI TextBox(stringvar, origin_x, origin_y, w, h)
PRI SetClipRectangle(clipx1, clipy1, clipx2, clipy2)
PRI TranslateBuffer(sourcebuffer, destbuffer)
PRI DrawScreen
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