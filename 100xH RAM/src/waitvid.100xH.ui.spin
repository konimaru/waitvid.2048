''
'' VGA display 100xH (dual cog) - user interface
''
''        Author: Marko Lukat
'' Last modified: 2012/03/25
''       Version: 0.4
''
'' acknowledgements
'' - conversion and output methods are based on FullDuplexSerial code (except dec)
'' - mikronauts font object(s) are copyright William Henning
''
'' 20120325: don't modify the addr value passed to the driver (setn)
''
CON
  columns  = driver#res_x / 8
  rows     = driver#res_y / font#height
  bcnt     = columns * rows

  rows_raw = (driver#res_y + font#height - 1) / font#height
  bcnt_raw = columns * rows_raw

CON
  #8, BS, TAB, LF, VT, FF, CR, ESC = 27

  dcolour_fg = (driver#dcolour >> 8) & %%3330 | %%3{!Z} ' %%RGB- full colour
  dcolour_bg = (driver#dcolour >> 0) & %%3330 | %%3{!Z} ' %%RGB- full colour
  
OBJ
  driver: "waitvid.100xH.driver.2048"
    font: "generic8x12-4font"
    
VAR
  long  link[driver#res_m], cext                        ' driver mailbox, colour buffer
  word  scrn[bcnt_raw / 2]                              ' screen buffer (2n aligned)

  byte  x, y, page                                      ' cursor position, page mode
  word  flag, colour
  
PUB null
'' This is not a top level object.

PUB init

  str(string(ESC, "c", dcolour_fg, dcolour_bg, FF))     ' set default colour, clear screen
  
  link{0} := @scrn.byte[bcnt_raw - columns]             ' initial screen buffer and
  link[1] := font#height << 24 | font.addr              ' font definition (default palette)

  return driver.init(-1, @link{0})                      ' video driver and pixel generator

PUB setn(n, addr)

  if n == 2                                             ' colour ...
    cext := (addr #> 0) & -2                            ' colour buffer (2n)

  link[n] := addr
  repeat
  while link[n]

PUB putc(c)

  if cext                                               ' colour per position mode
    word[cext][y * columns + x] := colour               ' update colour

  scrn.byte[bcnt_raw - y * columns - ++x] := c          ' pre-increment resolves (bcnt_raw -1)
  if x == columns                                         
    x := newline                                        ' CR/LF

PRI newline

  if ++y == rows
    if page                                             ' page/scroll?
      y := 0
      return
    y--

'   If we have a colour buffer attached scroll it up. The last active line
'   is unconditionally filled with the current colour. An unused line (i.e.
'   bcnt <> bcnt_raw) at the bottom will retain the last clear screen colour.
'
    if cext
      wordmove(cext, @word[cext][columns], constant(bcnt_raw - columns))
      wordfill(@word[cext][constant(bcnt - columns)], colour, columns)
      
    wordmove(@scrn.byte[columns], @scrn{0}, constant((bcnt_raw - columns) / 2))
    if rows_raw == rows
      wordfill(@scrn{0}, $2020, constant(columns / 2))

PUB str(addr)

  repeat strsize(addr)
    out(byte[addr++])

PUB hex(value, digits)

  value <<= (8 - digits) << 2
  repeat digits
    putc(lookupz((value <-= 4) & %1111 : "0".."9", "A".."F"))

PUB bin(value, digits)

  value <<= 32 - digits
  repeat digits
    putc((value <-= 1) & 1 + "0")

PUB dec(value) | s[4], p

  s{0} := value < 0                                     ' remember sign

  p := @p                                               ' initialise string pointer
  byte[--p] := 0                                        ' terminate string
  
  repeat
    byte[--p] := ||(value // 10) + "0"                  ' |
    value /= 10                                         ' |
  while value                                           ' create decimal representation

  if s{0}                                               ' optionally
    byte[--p] := "-"                                    ' prepend sign

  repeat strsize(p)
    putc(byte[p++])                                     ' emit string
  
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
               if cext
                 wordfill(cext, colour, bcnt_raw)
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