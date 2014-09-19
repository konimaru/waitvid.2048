''
'' VGA display 50x18 (single cog, ROM font) - user interface
''
''        Author: Marko Lukat
'' Last modified: 2013/10/16
''       Version: 0.3
''
CON
  columns  = driver#res_x / 16
  rows     = driver#res_y / 32
  bcnt     = columns * rows

  rows_raw = (driver#res_y + 32 - 1) / 32
  bcnt_raw = columns * rows_raw

CON
  #8, BS, TAB, LF, VT, FF, CR, ESC = 27

  dcolour_fg = (driver#dcolour >> 8) & %%3330 | %%3{!Z} ' %%RGB- full colour
  dcolour_bg = (driver#dcolour >> 0) & %%3330 | %%3{!Z} ' %%RGB- full colour
  
OBJ
  driver: "waitvid.50x18.driver.2048"
    
VAR
  long  link[driver#res_m]                              ' driver mailbox
  word  scrn[bcnt_raw / 2]                              ' screen buffer (2n aligned)
  long  cols[bcnt_raw / 2]                              ' colour buffer (4n aligned)

  byte  x, y, page                                      ' cursor position, page mode
  word  flag, colour
  
PUB null
'' This is not a top level object.

PUB init

  str(string(ESC, "c", dcolour_fg, dcolour_bg, FF))     ' set default colour, clear screen
  
  link{0} := @scrn{0}                                   ' initial screen and
  link[2] := @cols{0}                                   ' colour buffer

  return driver.init(-1, @link{0})                      ' video driver and pixel generator

PUB putc(c)

  cols.word[y * columns + x] := colour                  ' update colour
  scrn.byte[y * columns + x] := c                       ' update character
  if ++x == columns                                       
    x := newline                                        ' CR/LF

PRI newline

  if ++y == rows
    if page                                             ' page/scroll?
      y := 0
      return
    y--

    wordmove(@cols{0}, @cols.word[columns], constant(bcnt_raw - columns))
    wordmove(@scrn{0}, @scrn.byte[columns], constant((bcnt_raw - columns) / 2))
    if rows_raw == rows
      wordfill(@cols.word[constant(bcnt_raw - columns)], colour, columns)
      wordfill(@scrn.byte[constant(bcnt_raw - columns)], $2020, constant(columns / 2))

PUB str(addr)

  repeat strsize(addr)
    out(byte[addr++])

PUB out(c) : succ
'' Output a character
''
''     $00 = NUL   clear screen
''     $01 = SOH   home
''     $08 = BS  * backspace
''     $09 = TAB * tab
''     $0A = LF    set X position (X follows)
''     $0B = VT    set Y position (Y follows)
''     $0C = FF  * clear screen
''     $0D = CR  * return
''     $1B = ESC sequence(s)
''  others = printable characters

  case flag.byte{0}
    $00: case c                                             
           $00..$01,FF:                            
             if c <> $01                           
               wordfill(@cols{0}, colour, bcnt_raw)
               wordfill(@scrn{0}, $2020, constant(bcnt_raw / 2))
             x := y := 0                           
           $08: x := (x - 1) #> 0                  
           TAB: repeat 8 - (x & 7)                    
                  putc(" ")                         
           $0A..$0B: flag := c << 8 | "="               ' emulate head/tail of ESC=<x><y>
           $0D: x := newline                            ' CR/LF
           ESC: flag := c                           
           other: putc(c)                            
    ESC: case c
           "s", "S": page := c & $20                    ' page (ESC+s) and scroll mode (ESC+S)
           "=":      succ := constant($0200 | "=")      ' ESC=<x><y>
           "c":      succ := constant($0200 | "c")      ' ESCc<foreground><background>
         flag := succ~
    "=": case flag.byte[1]--
           2..10: flag &= tr(c, @x, columns, flag >> 11)
           other: flag := tr(c, @y, rows, TRUE)
    "c": case flag.byte[1]--
           2:{flag |=}sc(c, 1)
           1: flag := sc(c, 0)
         
PRI tr(c, addr, limit, response)

  if c.byte{0} < 255
    byte[addr] := c.byte{0} // limit

  return not response

PRI sc(c, idx)

  colour.byte[idx] := c
  
DAT