''
'' VGA display 80x25 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2018/11/24
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

CON
  CURSOR_ON    = driver#CURSOR_ON
  CURSOR_OFF   = driver#CURSOR_OFF
  CURSOR_ULINE = driver#CURSOR_ULINE
  CURSOR_BLOCK = driver#CURSOR_BLOCK
  CURSOR_FLASH = driver#CURSOR_FLASH
  CURSOR_SOLID = driver#CURSOR_SOLID

  CURSOR_MASK  = driver#CURSOR_MASK

  #0, CM, CX, CY

OBJ
  driver: "waitvid.80x25.driver.2048"
    font: "generic8x16-2font"
  
VAR
  long  scrn[bcnt_raw / 2]                              ' screen buffer
  long  link[driver#res_m]                              ' mailbox

  long  cursor                                          ' text cursor
  
PUB selftest : n | c

  c := font.addr
  repeat n from 0 to 2047
    word[c][n] ^= $8000

  link{0} := video | @scrn{0}
  link[1] := @palette << 16 | font.addr
  link[2] := @cursor * $00010001

  driver.init(-1, @link{0})                             ' start driver

  setCursor(CURSOR_ON|CURSOR_ULINE|CURSOR_FLASH)

  repeat bcnt                                           ' fill screen
    printChar(frqa++, n++)

PRI redef(c, cdef) : s

  repeat s from 0 to 15 step 2
    word[font.addr][128 * s + c] := byte[cdef][s] << 8 | byte[cdef][s+1]
    
PRI printTextAt(x, y, attr, s)

  x //= columns                                         ' |
  y //= rows                                            ' optional

  repeat strsize(s)
    printCharAt(x++, y, attr, byte[s++])
    ifnot x //= columns                                 ' wrap right
      y := ++y // rows                                  ' wrap bottom (page mode)
      
PRI printCharAt(x, y, attr, c)

  x //= columns                                         ' |
  y //= rows                                            ' optional
  
  attr.byte[1] := c
  scrn.word[bcnt_raw - y * columns - ++x] := attr 

PRI printText(attr, s)

  repeat strsize(s)
    printChar(attr, byte[s++])
      
PRI printChar(attr, c) | x, y

  x := cursor.byte[CX]
  y := cursor.byte[CY]
  
  attr.byte[1] := c
  scrn.word[bcnt_raw - y * columns - ++x] := attr
  ifnot x //= columns                                   ' wrap right
    y := ++y // rows                                    ' wrap bottom (page mode)

  cursor.byte[CX] := x
  cursor.byte[CY] := y
  
PRI clearScreen(attr)

  wordfill(@scrn{0}, $2000 | attr, bcnt_raw)
  cursor.byte[CX] := cursor.byte[CY] := 0
  
PRI setCursor(setup)

  cursor.byte{CM} := (cursor.byte{CM} & constant(!CURSOR_MASK)) | setup
  
DAT

palette         word    $2A06, $0282, $0222, $0292, $020A, $028A, $022A, $02AA, $0256, $02D6, $0276, $02F6, $025E, $02DE, $027E, $02FE
                word    $8202, $2A06, $8222, $8292, $820A, $828A, $822A, $82AA, $8256, $82D6, $8276, $82F6, $825E, $82DE, $827E, $82FE
                word    $2202, $2282, $2A06, $2292, $220A, $228A, $222A, $22AA, $2256, $22D6, $2276, $22F6, $225E, $22DE, $227E, $22FE
                word    $9202, $9282, $9222, $2A06, $920A, $928A, $922A, $92AA, $9256, $92D6, $9276, $92F6, $925E, $92DE, $927E, $92FE
                word    $0A02, $0A82, $0A22, $0A92, $2A06, $0A8A, $0A2A, $0AAA, $0A56, $0AD6, $0A76, $0AF6, $0A5E, $0ADE, $0A7E, $0AFE
                word    $8A02, $8A82, $8A22, $8A92, $8A0A, $2A06, $8A2A, $8AAA, $8A56, $8AD6, $8A76, $8AF6, $8A5E, $8ADE, $8A7E, $8AFE
                word    $2A02, $2A82, $2A22, $2A92, $2A0A, $2A8A, $2A06, $2AAA, $2A56, $2AD6, $2A76, $2AF6, $2A5E, $2ADE, $2A7E, $2AFE
                word    $AA02, $AA82, $AA22, $AA92, $AA0A, $AA8A, $AA2A, $2A06, $AA56, $AAD6, $AA76, $AAF6, $AA5E, $AADE, $AA7E, $AAFE
                word    $5602, $5682, $5622, $5692, $560A, $568A, $562A, $56AA, $2A06, $56D6, $5676, $56F6, $565E, $56DE, $567E, $56FE
                word    $D602, $D682, $D622, $D692, $D60A, $D68A, $D62A, $D6AA, $D656, $2A06, $D676, $D6F6, $D65E, $D6DE, $D67E, $D6FE
                word    $7602, $7682, $7622, $7692, $760A, $768A, $762A, $76AA, $7656, $76D6, $2A06, $76F6, $765E, $76DE, $767E, $76FE
                word    $F602, $F682, $F622, $F692, $F60A, $F68A, $F62A, $F6AA, $F656, $F6D6, $F676, $2A06, $F65E, $F6DE, $F67E, $F6FE
                word    $5E02, $5E82, $5E22, $5E92, $5E0A, $5E8A, $5E2A, $5EAA, $5E56, $5ED6, $5E76, $5EF6, $2A06, $5EDE, $5E7E, $5EFE
                word    $DE02, $DE82, $DE22, $DE92, $DE0A, $DE8A, $DE2A, $DEAA, $DE56, $DED6, $DE76, $DEF6, $DE5E, $2A06, $DE7E, $DEFE
                word    $7E02, $7E82, $7E22, $7E92, $7E0A, $7E8A, $7E2A, $7EAA, $7E56, $7ED6, $7E76, $7EF6, $7E5E, $7EDE, $2A06, $7EFE
                word    $FE02, $FE82, $FE22, $FE92, $FE0A, $FE8A, $FE2A, $FEAA, $FE56, $FED6, $FE76, $FEF6, $FE5E, $FEDE, $FE7E, $2A06

DAT