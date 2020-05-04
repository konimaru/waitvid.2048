''
'' VGA display 80x30 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2019/04/28
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
  driver: "waitvid.80x30.c0df.driver.2048"
    font: "generic8x16-4font"
  
VAR
  long  scrn[bcnt_raw / 2]                              ' screen buffer
  long  link[driver#res_m]                              ' mailbox

  long  cursor                                          ' text cursor
  
PUB selftest : n

  link{0} := video | @scrn{0}
  link[1] := @palette << 16 | font.addr
  link[2] := @cursor * $00010001

  driver.init(-1, @link{0})                             ' start driver

' setCursor(CURSOR_ON|CURSOR_ULINE|CURSOR_FLASH)

  repeat bcnt                                           ' fill screen
    printChar(n, n++)

  block( 5, 1, $30)
  block(23, 1, $20)
  block(41, 1, $50)
  block(59, 1, $70)

PRI block(sx, sy, c) : n | x, y

  repeat y from 0 to 15
    repeat x from 0 to 15
      printCharAt(sx+x, sy+y, c, n++)

PRI redef(char, cdef) | addr

  addr := font.addr

  repeat 4
    long[addr][char] := byte[cdef]{0} << 24 | byte[cdef][1] << 16 | byte[cdef][2] << 8 | byte[cdef][3]
    
    addr += 1024
    cdef += 4

PRI printTextAt(x, y, attr, s)

  x //= columns                                         ' |
  y //= rows                                            ' optional

  repeat strsize(s)
    printCharAt(x++, y, attr, byte[s++])
    ifnot x //= columns                                 ' wrap right
      y := ++y // rows                                  ' wrap bottom (page mode)
      
PRI printCharAt(x, y, attr, char)

  x //= columns                                         ' |
  y //= rows                                            ' optional
  
  attr.byte[1] := char
  scrn.word[bcnt_raw - y * columns - ++x] := attr 

PRI printText(attr, s)

  repeat strsize(s)
    printChar(attr, byte[s++])
      
PRI printChar(attr, char) | x, y

  x := cursor.byte[CX]
  y := cursor.byte[CY]
  
  attr.byte[1] := char
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
'
' Each of the 256 (word) palette entries holds FG colour in the high and BG colour in the low byte. Bits 1, 8 and 9 are unused and should be 0.
' Bit 0 defines whether this colour should blink (1) or not (0). IOW, if the blink attribute is not required all 256 entries are available for
' user defined colour pairs.
'
' For a setup which requires a blink attribute (see below) each colour is doubled (2n: colour|%%0, 2n+1: colour|%%1), e.g.
'
'   colour format: %FFFF_BBB_A
'
'     FFFF: foreground index
'      BBB: background index
'        A: blink mode (0/1 = off/on)
'
palette         word    %%022_0_001_0, %%022_0_001_1, %%000_0_200_0, %%000_0_200_1, %%000_0_020_0, %%000_0_020_1, %%000_0_210_0, %%000_0_210_1
                word    %%000_0_002_0, %%000_0_002_1, %%000_0_202_0, %%000_0_202_1, %%000_0_022_0, %%000_0_022_1, %%000_0_222_0, %%000_0_222_1
                word    %%200_0_000_0, %%200_0_000_1, %%200_0_200_0, %%200_0_200_1, %%200_0_020_0, %%200_0_020_1, %%200_0_210_0, %%200_0_210_1
                word    %%200_0_002_0, %%200_0_002_1, %%200_0_202_0, %%200_0_202_1, %%200_0_022_0, %%200_0_022_1, %%200_0_222_0, %%200_0_222_1
                word    %%020_0_000_0, %%020_0_000_1, %%020_0_200_0, %%020_0_200_1, %%020_0_020_0, %%020_0_020_1, %%020_0_210_0, %%020_0_210_1
                word    %%020_0_002_0, %%020_0_002_1, %%020_0_202_0, %%020_0_202_1, %%020_0_022_0, %%020_0_022_1, %%020_0_222_0, %%020_0_222_1
                word    %%210_0_000_0, %%210_0_000_1, %%210_0_200_0, %%210_0_200_1, %%210_0_020_0, %%210_0_020_1, %%210_0_210_0, %%210_0_210_1
                word    %%210_0_002_0, %%210_0_002_1, %%210_0_202_0, %%210_0_202_1, %%210_0_022_0, %%210_0_022_1, %%210_0_222_0, %%210_0_222_1
                word    %%002_0_000_0, %%002_0_000_1, %%002_0_200_0, %%002_0_200_1, %%002_0_020_0, %%002_0_020_1, %%002_0_210_0, %%002_0_210_1
                word    %%002_0_002_0, %%002_0_002_1, %%002_0_202_0, %%002_0_202_1, %%002_0_022_0, %%002_0_022_1, %%002_0_222_0, %%002_0_222_1
                word    %%202_0_000_0, %%202_0_000_1, %%202_0_200_0, %%202_0_200_1, %%202_0_020_0, %%202_0_020_1, %%202_0_210_0, %%202_0_210_1
                word    %%202_0_002_0, %%202_0_002_1, %%202_0_202_0, %%202_0_202_1, %%202_0_022_0, %%202_0_022_1, %%202_0_222_0, %%202_0_222_1
                word    %%022_0_000_0, %%022_0_000_1, %%022_0_200_0, %%022_0_200_1, %%022_0_020_0, %%022_0_020_1, %%022_0_210_0, %%022_0_210_1
                word    %%022_0_002_0, %%022_0_002_1, %%022_0_202_0, %%022_0_202_1, %%022_0_022_0, %%022_0_022_1, %%022_0_222_0, %%022_0_222_1
                word    %%222_0_000_0, %%222_0_000_1, %%222_0_200_0, %%222_0_200_1, %%222_0_020_0, %%222_0_020_1, %%222_0_210_0, %%222_0_210_1
                word    %%222_0_002_0, %%222_0_002_1, %%222_0_202_0, %%222_0_202_1, %%222_0_022_0, %%222_0_022_1, %%222_0_222_0, %%222_0_222_1
                word    %%111_0_000_0, %%111_0_000_1, %%111_0_200_0, %%111_0_200_1, %%111_0_020_0, %%111_0_020_1, %%111_0_210_0, %%111_0_210_1
                word    %%111_0_002_0, %%111_0_002_1, %%111_0_202_0, %%111_0_202_1, %%111_0_022_0, %%111_0_022_1, %%111_0_222_0, %%111_0_222_1
                word    %%311_0_000_0, %%311_0_000_1, %%311_0_200_0, %%311_0_200_1, %%311_0_020_0, %%311_0_020_1, %%311_0_210_0, %%311_0_210_1
                word    %%311_0_002_0, %%311_0_002_1, %%311_0_202_0, %%311_0_202_1, %%311_0_022_0, %%311_0_022_1, %%311_0_222_0, %%311_0_222_1
                word    %%131_0_000_0, %%131_0_000_1, %%131_0_200_0, %%131_0_200_1, %%131_0_020_0, %%131_0_020_1, %%131_0_210_0, %%131_0_210_1
                word    %%131_0_002_0, %%131_0_002_1, %%131_0_202_0, %%131_0_202_1, %%131_0_022_0, %%131_0_022_1, %%131_0_222_0, %%131_0_222_1
                word    %%331_0_000_0, %%331_0_000_1, %%331_0_200_0, %%331_0_200_1, %%331_0_020_0, %%331_0_020_1, %%331_0_210_0, %%331_0_210_1
                word    %%331_0_002_0, %%331_0_002_1, %%331_0_202_0, %%331_0_202_1, %%331_0_022_0, %%331_0_022_1, %%331_0_222_0, %%331_0_222_1
                word    %%113_0_000_0, %%113_0_000_1, %%113_0_200_0, %%113_0_200_1, %%113_0_020_0, %%113_0_020_1, %%113_0_210_0, %%113_0_210_1
                word    %%113_0_002_0, %%113_0_002_1, %%113_0_202_0, %%113_0_202_1, %%113_0_022_0, %%113_0_022_1, %%113_0_222_0, %%113_0_222_1
                word    %%313_0_000_0, %%313_0_000_1, %%313_0_200_0, %%313_0_200_1, %%313_0_020_0, %%313_0_020_1, %%313_0_210_0, %%313_0_210_1
                word    %%313_0_002_0, %%313_0_002_1, %%313_0_202_0, %%313_0_202_1, %%313_0_022_0, %%313_0_022_1, %%313_0_222_0, %%313_0_222_1
                word    %%133_0_000_0, %%133_0_000_1, %%133_0_200_0, %%133_0_200_1, %%133_0_020_0, %%133_0_020_1, %%133_0_210_0, %%133_0_210_1
                word    %%133_0_002_0, %%133_0_002_1, %%133_0_202_0, %%133_0_202_1, %%133_0_022_0, %%133_0_022_1, %%133_0_222_0, %%133_0_222_1
                word    %%333_0_000_0, %%333_0_000_1, %%333_0_200_0, %%333_0_200_1, %%333_0_020_0, %%333_0_020_1, %%333_0_210_0, %%333_0_210_1
                word    %%333_0_002_0, %%333_0_002_1, %%333_0_202_0, %%333_0_202_1, %%333_0_022_0, %%333_0_022_1, %%333_0_222_0, %%333_0_222_1

DAT
'
' Blink attribute not used.
'
palette_cdup    word    $2804, $0080, $0020, $0090, $0008, $0088, $0028, $00A8, $0054, $00D4, $0074, $00F4, $005C, $00DC, $007C, $00FC
                word    $8000, $2804, $8020, $8090, $8008, $8088, $8028, $80A8, $8054, $80D4, $8074, $80F4, $805C, $80DC, $807C, $80FC
                word    $2000, $2080, $2804, $2090, $2008, $2088, $2028, $20A8, $2054, $20D4, $2074, $20F4, $205C, $20DC, $207C, $20FC
                word    $9000, $9080, $9020, $2804, $9008, $9088, $9028, $90A8, $9054, $90D4, $9074, $90F4, $905C, $90DC, $907C, $90FC
                word    $0800, $0880, $0820, $0890, $2804, $0888, $0828, $08A8, $0854, $08D4, $0874, $08F4, $085C, $08DC, $087C, $08FC
                word    $8800, $8880, $8820, $8890, $8808, $2804, $8828, $88A8, $8854, $88D4, $8874, $88F4, $885C, $88DC, $887C, $88FC
                word    $2800, $2880, $2820, $2890, $2808, $2888, $2804, $28A8, $2854, $28D4, $2874, $28F4, $285C, $28DC, $287C, $28FC
                word    $A800, $A880, $A820, $A890, $A808, $A888, $A828, $2804, $A854, $A8D4, $A874, $A8F4, $A85C, $A8DC, $A87C, $A8FC
                word    $5400, $5480, $5420, $5490, $5408, $5488, $5428, $54A8, $2804, $54D4, $5474, $54F4, $545C, $54DC, $547C, $54FC
                word    $D400, $D480, $D420, $D490, $D408, $D488, $D428, $D4A8, $D454, $2804, $D474, $D4F4, $D45C, $D4DC, $D47C, $D4FC
                word    $7400, $7480, $7420, $7490, $7408, $7488, $7428, $74A8, $7454, $74D4, $2804, $74F4, $745C, $74DC, $747C, $74FC
                word    $F400, $F480, $F420, $F490, $F408, $F488, $F428, $F4A8, $F454, $F4D4, $F474, $2804, $F45C, $F4DC, $F47C, $F4FC
                word    $5C00, $5C80, $5C20, $5C90, $5C08, $5C88, $5C28, $5CA8, $5C54, $5CD4, $5C74, $5CF4, $2804, $5CDC, $5C7C, $5CFC
                word    $DC00, $DC80, $DC20, $DC90, $DC08, $DC88, $DC28, $DCA8, $DC54, $DCD4, $DC74, $DCF4, $DC5C, $2804, $DC7C, $DCFC
                word    $7C00, $7C80, $7C20, $7C90, $7C08, $7C88, $7C28, $7CA8, $7C54, $7CD4, $7C74, $7CF4, $7C5C, $7CDC, $2804, $7CFC
                word    $FC00, $FC80, $FC20, $FC90, $FC08, $FC88, $FC28, $FCA8, $FC54, $FCD4, $FC74, $FCF4, $FC5C, $FCDC, $FC7C, $2804

DAT