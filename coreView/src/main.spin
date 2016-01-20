''
''        Author: Marko Lukat
'' Last modified: 2016/01/19
''       Version: 0.5
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  PAD_NE        = plex#PAD_P0
  PAD_E         = plex#PAD_P1
  PAD_SE        = plex#PAD_P2

  PAD_S         = plex#PAD_P6

  PAD_NW        = plex#PAD_P5
  PAD_W         = plex#PAD_P4
  PAD_SW        = plex#PAD_P3

OBJ
  SSD1306: "core.con.ssd1306"
     view: "coreView.1K.SPI"
     draw: "coreDraw"
     plex: "badge.PLEX"
     tilt: "jm_mma7660fc"
  
VAR
  long  surface
  long  LEDs, pads
  
PUB null : n | m, rgb, switched, i

  init

  repeat i from 0 to 14
    m := @drwuro[i]
    repeat n from 0 to 63
      bytemove(surface + n << 4, m, 16)
      m += 30
    waitcnt(clkfreq/8 + cnt)
    view.swap(surface)
{
  repeat
    LEDs := tilt.read_tilt
    waitcnt(clkfreq/8 + cnt)
}
  rgb := switched := 0
  
  repeat
    n := 0
    m := pads

    if m & PAD_NE
      n |= 1
    if m & PAD_E
      n |= 2
    if m & PAD_SE
      n |= 4

    if m & PAD_SW
      n |= 8
    if m & PAD_W
      n |= 16
    if m & PAD_NW
      n |= 32

    if m & PAD_S
      n |= %001001*rgb << 8
      switched := FALSE
    elseifnot switched
      rgb := (++rgb & 7) #> 1
      switched := TRUE

    LEDs := n
    
DAT                                                     ' display initialisation sequence
        byte    6
iseq    byte    SSD1306#SET_MEMORY_MODE, %111111_00     ' horizontal mode
        byte    SSD1306#SET_SEGMENT_REMAP|1             ' |
        byte    SSD1306#SET_COM_SCAN_DEC                ' rotate 180 deg
        byte    SSD1306#SET_CHARGE_PUMP, %11_010100     ' no external Vcc

PRI init

  surface := view.init                                  ' start OLED driver
  view.cmdN(@iseq, iseq[-1])                            ' finish setup
  view.swap(surface)                                    ' show initial screen
  view.cmd1(SSD1306#DISPLAY_ON)                         ' display on

  plex.init(-1, @LEDs)                                  ' start LED/PAD driver

  tilt.start(28, 29)

DAT

drwuro  byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $FC, $FF, $FF, $FF, $FF, $03, $F8, $FF, $81, $FF, $1F, $00, $00, $00, $3F, $80, $3F, $3F, $F8, $F9, $FF, $01, $FE, $0F, $00, $00, $00, $00
        byte    $00, $00, $FE, $FF, $FF, $FF, $FF, $03, $F8, $FF, $83, $FF, $3F, $00, $00, $00, $3F, $80, $3F, $3F, $F8, $F9, $FF, $03, $FF, $1F, $00, $00, $00, $00
        byte    $00, $00, $FF, $FF, $FF, $FF, $FF, $03, $F8, $FF, $87, $FF, $7F, $00, $00, $00, $3F, $80, $3F, $3F, $F8, $F9, $FF, $87, $FF, $3F, $00, $00, $00, $00
        byte    $00, $80, $FF, $FF, $FF, $FF, $FF, $03, $F8, $FF, $8F, $FF, $FF, $00, $00, $00, $3F, $80, $3F, $3F, $F8, $F9, $FF, $CF, $FF, $7F, $00, $00, $00, $00
        byte    $00, $C0, $FF, $FF, $FF, $FF, $FF, $03, $F8, $FF, $8F, $FF, $FF, $00, $00, $00, $3F, $80, $3F, $3F, $F8, $F9, $FF, $CF, $FF, $7F, $00, $00, $00, $00
        byte    $00, $E0, $FF, $FF, $FF, $FF, $E7, $03, $F8, $FF, $8F, $FF, $FF, $00, $00, $00, $3F, $84, $3F, $3F, $F8, $F9, $FF, $CF, $FF, $7F, $00, $00, $00, $00
        byte    $00, $F0, $FF, $FF, $FF, $FF, $E3, $03, $00, $C0, $0F, $00, $FC, $00, $00, $00, $3F, $8E, $3F, $3F, $F8, $01, $C0, $0F, $00, $7E, $00, $00, $00, $00
        byte    $00, $F8, $FF, $FF, $FF, $FF, $E1, $03, $00, $C0, $0F, $00, $FC, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $01, $C0, $0F, $00, $7E, $00, $00, $00, $00
        byte    $00, $FC, $FF, $FF, $FF, $FF, $E0, $03, $00, $C0, $0F, $00, $FC, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $01, $C0, $0F, $00, $7E, $00, $00, $00, $00
        byte    $00, $FE, $FF, $FF, $FF, $7F, $E4, $03, $F8, $C1, $8F, $FF, $FF, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $CF, $0F, $7E, $00, $00, $00, $00
        byte    $00, $FF, $FF, $FF, $FF, $3F, $E6, $03, $F8, $C1, $8F, $FF, $7F, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $C7, $0F, $7E, $00, $00, $00, $00
        byte    $80, $FF, $FF, $FF, $FF, $0F, $E7, $03, $F8, $C1, $8F, $FF, $3F, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $C3, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $FF, $FF, $87, $E7, $03, $F8, $C1, $8F, $FF, $1F, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $C1, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $FF, $FF, $C1, $E7, $03, $F8, $C1, $8F, $FF, $3F, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $C3, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $FF, $FF, $E0, $E7, $03, $F8, $C1, $8F, $FF, $7F, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $C7, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $FF, $3F, $C0, $E7, $03, $F8, $C1, $8F, $FF, $FF, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $FF, $CF, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $FF, $0F, $C4, $E7, $03, $F8, $C1, $8F, $1F, $FC, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $C1, $CF, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $FF, $03, $C7, $E7, $03, $F8, $C1, $8F, $1F, $FC, $00, $00, $00, $3F, $9F, $3F, $3F, $F8, $F9, $C1, $CF, $0F, $7E, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $7F, $E0, $8F, $E7, $03, $F8, $FF, $8F, $1F, $FC, $FC, $00, $00, $FF, $FF, $3F, $FF, $FF, $F9, $C1, $CF, $FF, $7F, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $0F, $F0, $8F, $E3, $03, $F8, $FF, $8F, $1F, $FC, $FC, $00, $00, $FF, $FF, $3F, $FF, $FF, $F9, $C1, $CF, $FF, $7F, $00, $00, $00, $00
        byte    $C0, $FF, $FF, $00, $F8, $9F, $E3, $03, $F8, $FF, $8F, $1F, $FC, $FC, $00, $00, $FF, $FF, $3F, $FF, $FF, $F9, $C1, $CF, $FF, $7F, $00, $00, $00, $00
        byte    $C0, $FF, $07, $C0, $F8, $1F, $F3, $03, $F8, $FF, $87, $1F, $FC, $FC, $00, $00, $FF, $F7, $1F, $FF, $FF, $F8, $C1, $8F, $FF, $3F, $00, $00, $00, $00
        byte    $C0, $3F, $00, $F8, $F9, $3F, $F1, $03, $F8, $FF, $83, $1F, $FC, $FC, $00, $00, $FF, $F3, $1F, $FF, $7F, $F8, $C1, $0F, $FF, $1F, $00, $00, $00, $00
        byte    $C0, $01, $00, $FF, $F1, $3F, $F0, $03, $F8, $FF, $81, $1F, $FC, $FC, $00, $00, $FF, $F1, $0F, $FF, $3F, $F8, $C1, $0F, $FE, $0F, $00, $00, $00, $00
        byte    $C0, $00, $3F, $FF, $F3, $7F, $F8, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $C0, $F8, $3F, $FF, $F3, $7F, $F8, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $C0, $F9, $3F, $FE, $E3, $FF, $FC, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $C0, $F1, $3F, $FE, $E3, $7F, $FC, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $C0, $F1, $7F, $FE, $E7, $3F, $FE, $03, $F8, $F3, $83, $9F, $FF, $1F, $FC, $E0, $07, $FF, $3F, $FF, $FF, $F9, $FF, $C1, $CF, $FF, $7F, $F0, $FF, $03
        byte    $C0, $E3, $7F, $FE, $C7, $0F, $FF, $03, $F8, $F3, $83, $9F, $FF, $3F, $FC, $E0, $87, $FF, $3F, $FF, $FF, $F9, $FF, $C3, $CF, $FF, $7F, $F8, $FF, $03
        byte    $C0, $E3, $7F, $FE, $C7, $87, $FF, $03, $F8, $F3, $87, $9F, $FF, $7F, $FC, $E0, $C7, $FF, $3F, $FF, $FF, $F9, $FF, $C7, $CF, $FF, $7F, $FC, $FF, $03
        byte    $C0, $C7, $7F, $FC, $8F, $C3, $FF, $03, $F8, $F3, $87, $9F, $FF, $FF, $FC, $E0, $E7, $FF, $3F, $FF, $FF, $F9, $FF, $CF, $CF, $FF, $7F, $FE, $FF, $03
        byte    $C0, $8F, $7F, $FC, $9F, $E0, $FF, $03, $F8, $F3, $8F, $9F, $FF, $FF, $FC, $E0, $E7, $FF, $3F, $FF, $FF, $F9, $FF, $CF, $CF, $FF, $7F, $FE, $FF, $03
        byte    $C0, $0F, $7E, $FC, $1F, $F0, $FF, $03, $F8, $F3, $8F, $9F, $FF, $FF, $FC, $E0, $E7, $FF, $3F, $FF, $FF, $F9, $FF, $CF, $CF, $FF, $7F, $FE, $FF, $03
        byte    $C0, $3F, $FC, $FC, $0F, $FC, $FF, $03, $F8, $F3, $9F, $1F, $00, $FC, $FC, $E0, $E7, $07, $00, $E0, $0F, $00, $C0, $CF, $CF, $0F, $00, $7E, $00, $00
        byte    $C0, $7F, $E0, $FC, $00, $FF, $FF, $03, $F8, $F3, $9F, $1F, $00, $FC, $FC, $E0, $E7, $07, $00, $E0, $0F, $00, $C0, $CF, $CF, $0F, $00, $7E, $00, $00
        byte    $C0, $FF, $01, $00, $C0, $FF, $FF, $03, $F8, $F3, $BF, $1F, $00, $FC, $FC, $E0, $E7, $07, $00, $E0, $0F, $00, $C0, $CF, $CF, $0F, $00, $7E, $00, $00
        byte    $C0, $FF, $07, $00, $F8, $FF, $FF, $03, $F8, $F3, $BF, $9F, $1F, $FC, $FC, $E0, $E7, $FF, $07, $E0, $0F, $F8, $FF, $CF, $CF, $FF, $0F, $FE, $7F, $00
        byte    $C0, $FF, $7F, $C0, $FF, $FF, $FF, $03, $F8, $F3, $FF, $9F, $1F, $FC, $FC, $E0, $E7, $FF, $0F, $E0, $0F, $F8, $FF, $C7, $CF, $FF, $0F, $FE, $FF, $00
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $FF, $03, $F8, $F3, $FF, $9F, $1F, $FC, $FC, $E0, $E7, $FF, $1F, $E0, $0F, $F8, $FF, $C3, $CF, $FF, $0F, $FE, $FF, $01
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $FF, $01, $F8, $F3, $FF, $9F, $1F, $FC, $FC, $E0, $C7, $FF, $3F, $E0, $0F, $F8, $FF, $C1, $CF, $FF, $0F, $FC, $FF, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $FF, $00, $F8, $F3, $FF, $9F, $1F, $FC, $FC, $E0, $87, $FF, $3F, $E0, $0F, $F8, $FF, $C3, $CF, $FF, $0F, $F8, $FF, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $7F, $00, $F8, $F3, $FB, $9F, $1F, $FC, $FC, $E0, $07, $FF, $3F, $E0, $0F, $F8, $FF, $C7, $CF, $FF, $0F, $F0, $FF, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $3F, $00, $F8, $F3, $FB, $9F, $1F, $FC, $FC, $E0, $07, $00, $3F, $E0, $0F, $F8, $FF, $CF, $CF, $0F, $00, $00, $F0, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $1F, $00, $F8, $F3, $F3, $9F, $1F, $FC, $FC, $E0, $07, $00, $3F, $E0, $0F, $F8, $C1, $CF, $CF, $0F, $00, $00, $F0, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $0F, $00, $F8, $F3, $F3, $9F, $1F, $FC, $FC, $E0, $07, $00, $3F, $E0, $0F, $F8, $C1, $CF, $CF, $0F, $00, $00, $F0, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $07, $00, $F8, $F3, $E3, $9F, $FF, $FF, $FC, $FF, $E7, $FF, $3F, $E0, $0F, $F8, $C1, $CF, $CF, $FF, $7F, $FE, $FF, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $03, $00, $F8, $F3, $E3, $9F, $FF, $FF, $FC, $FF, $E7, $FF, $3F, $E0, $0F, $F8, $C1, $CF, $CF, $FF, $7F, $FE, $FF, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $01, $00, $F8, $F3, $C3, $9F, $FF, $FF, $FC, $FF, $E7, $FF, $3F, $E0, $0F, $F8, $C1, $CF, $CF, $FF, $7F, $FE, $FF, $03
        byte    $C0, $FF, $FF, $FF, $FF, $FF, $00, $00, $F8, $F3, $C3, $9F, $FF, $7F, $FC, $FF, $E3, $FF, $1F, $E0, $0F, $F8, $C1, $CF, $8F, $FF, $7F, $FE, $FF, $01
        byte    $C0, $FF, $FF, $FF, $FF, $7F, $00, $00, $F8, $F3, $83, $9F, $FF, $3F, $FC, $FF, $E1, $FF, $0F, $E0, $0F, $F8, $C1, $CF, $0F, $FF, $7F, $FE, $FF, $00
        byte    $C0, $FF, $FF, $FF, $FF, $3F, $00, $00, $F8, $F3, $83, $9F, $FF, $1F, $FC, $FF, $E0, $FF, $07, $E0, $0F, $F8, $C1, $CF, $0F, $FE, $7F, $FE, $7F, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

DAT