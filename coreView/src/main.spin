''
''        Author: Marko Lukat
'' Last modified: 2016/01/20
''       Version: 0.6
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

   serial: "FullDuplexSerial"
  
VAR
  long  surface
  long  LEDs, pads
  
PUB null : n | m, rgb, switched, i, t

  init

  draw.init($02000000|surface)
  t := cnt
'{
  repeat n from 127 to -32
    draw.blit(0, @drwuro, n, n/2, 0, 0)
    waitcnt(t += clkfreq/30)
    view.swap(surface)
'}
  waitpne(0, 0, 0)

{
  serial.start(31, 30, %0000, 115200)
  draw.init($02000000|surface)
  draw.blit($1000, @drwuro, 0, -1, 0, $3000)
  waitcnt(clkfreq*3 + cnt)
  serial.tx(0)

  n := $8000
  repeat 11
    serial.hex(long[n -= 4], 8)
    serial.tx(13)

  waitpne(0, 0, 0)
'}
  repeat i from 0 to 14
    m := @drwuro.byte[i]
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
        word    1920            ' frame size
        word    240, 64         ' width, height

drwuro  word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $FFFC, $FFFF, $03FF, $FFF8, $FF81, $001F, $0000, $803F, $3F3F, $F9F8, $01FF, $0FFE, $0000, $0000
        word    $0000, $FFFE, $FFFF, $03FF, $FFF8, $FF83, $003F, $0000, $803F, $3F3F, $F9F8, $03FF, $1FFF, $0000, $0000
        word    $0000, $FFFF, $FFFF, $03FF, $FFF8, $FF87, $007F, $0000, $803F, $3F3F, $F9F8, $87FF, $3FFF, $0000, $0000
        word    $8000, $FFFF, $FFFF, $03FF, $FFF8, $FF8F, $00FF, $0000, $803F, $3F3F, $F9F8, $CFFF, $7FFF, $0000, $0000
        word    $C000, $FFFF, $FFFF, $03FF, $FFF8, $FF8F, $00FF, $0000, $803F, $3F3F, $F9F8, $CFFF, $7FFF, $0000, $0000
        word    $E000, $FFFF, $FFFF, $03E7, $FFF8, $FF8F, $00FF, $0000, $843F, $3F3F, $F9F8, $CFFF, $7FFF, $0000, $0000
        word    $F000, $FFFF, $FFFF, $03E3, $C000, $000F, $00FC, $0000, $8E3F, $3F3F, $01F8, $0FC0, $7E00, $0000, $0000
        word    $F800, $FFFF, $FFFF, $03E1, $C000, $000F, $00FC, $0000, $9F3F, $3F3F, $01F8, $0FC0, $7E00, $0000, $0000
        word    $FC00, $FFFF, $FFFF, $03E0, $C000, $000F, $00FC, $0000, $9F3F, $3F3F, $01F8, $0FC0, $7E00, $0000, $0000
        word    $FE00, $FFFF, $7FFF, $03E4, $C1F8, $FF8F, $00FF, $0000, $9F3F, $3F3F, $F9F8, $CFFF, $7E0F, $0000, $0000
        word    $FF00, $FFFF, $3FFF, $03E6, $C1F8, $FF8F, $007F, $0000, $9F3F, $3F3F, $F9F8, $C7FF, $7E0F, $0000, $0000
        word    $FF80, $FFFF, $0FFF, $03E7, $C1F8, $FF8F, $003F, $0000, $9F3F, $3F3F, $F9F8, $C3FF, $7E0F, $0000, $0000
        word    $FFC0, $FFFF, $87FF, $03E7, $C1F8, $FF8F, $001F, $0000, $9F3F, $3F3F, $F9F8, $C1FF, $7E0F, $0000, $0000
        word    $FFC0, $FFFF, $C1FF, $03E7, $C1F8, $FF8F, $003F, $0000, $9F3F, $3F3F, $F9F8, $C3FF, $7E0F, $0000, $0000
        word    $FFC0, $FFFF, $E0FF, $03E7, $C1F8, $FF8F, $007F, $0000, $9F3F, $3F3F, $F9F8, $C7FF, $7E0F, $0000, $0000
        word    $FFC0, $FFFF, $C03F, $03E7, $C1F8, $FF8F, $00FF, $0000, $9F3F, $3F3F, $F9F8, $CFFF, $7E0F, $0000, $0000
        word    $FFC0, $FFFF, $C40F, $03E7, $C1F8, $1F8F, $00FC, $0000, $9F3F, $3F3F, $F9F8, $CFC1, $7E0F, $0000, $0000
        word    $FFC0, $FFFF, $C703, $03E7, $C1F8, $1F8F, $00FC, $0000, $9F3F, $3F3F, $F9F8, $CFC1, $7E0F, $0000, $0000
        word    $FFC0, $7FFF, $8FE0, $03E7, $FFF8, $1F8F, $FCFC, $0000, $FFFF, $FF3F, $F9FF, $CFC1, $7FFF, $0000, $0000
        word    $FFC0, $0FFF, $8FF0, $03E3, $FFF8, $1F8F, $FCFC, $0000, $FFFF, $FF3F, $F9FF, $CFC1, $7FFF, $0000, $0000
        word    $FFC0, $00FF, $9FF8, $03E3, $FFF8, $1F8F, $FCFC, $0000, $FFFF, $FF3F, $F9FF, $CFC1, $7FFF, $0000, $0000
        word    $FFC0, $C007, $1FF8, $03F3, $FFF8, $1F87, $FCFC, $0000, $F7FF, $FF1F, $F8FF, $8FC1, $3FFF, $0000, $0000
        word    $3FC0, $F800, $3FF9, $03F1, $FFF8, $1F83, $FCFC, $0000, $F3FF, $FF1F, $F87F, $0FC1, $1FFF, $0000, $0000
        word    $01C0, $FF00, $3FF1, $03F0, $FFF8, $1F81, $FCFC, $0000, $F1FF, $FF0F, $F83F, $0FC1, $0FFE, $0000, $0000
        word    $00C0, $FF3F, $7FF3, $03F8, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $F8C0, $FF3F, $7FF3, $03F8, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $F9C0, $FE3F, $FFE3, $03FC, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $F1C0, $FE3F, $7FE3, $03FC, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $F1C0, $FE7F, $3FE7, $03FE, $F3F8, $9F83, $1FFF, $E0FC, $FF07, $FF3F, $F9FF, $C1FF, $FFCF, $F07F, $03FF
        word    $E3C0, $FE7F, $0FC7, $03FF, $F3F8, $9F83, $3FFF, $E0FC, $FF87, $FF3F, $F9FF, $C3FF, $FFCF, $F87F, $03FF
        word    $E3C0, $FE7F, $87C7, $03FF, $F3F8, $9F87, $7FFF, $E0FC, $FFC7, $FF3F, $F9FF, $C7FF, $FFCF, $FC7F, $03FF
        word    $C7C0, $FC7F, $C38F, $03FF, $F3F8, $9F87, $FFFF, $E0FC, $FFE7, $FF3F, $F9FF, $CFFF, $FFCF, $FE7F, $03FF
        word    $8FC0, $FC7F, $E09F, $03FF, $F3F8, $9F8F, $FFFF, $E0FC, $FFE7, $FF3F, $F9FF, $CFFF, $FFCF, $FE7F, $03FF
        word    $0FC0, $FC7E, $F01F, $03FF, $F3F8, $9F8F, $FFFF, $E0FC, $FFE7, $FF3F, $F9FF, $CFFF, $FFCF, $FE7F, $03FF
        word    $3FC0, $FCFC, $FC0F, $03FF, $F3F8, $1F9F, $FC00, $E0FC, $07E7, $E000, $000F, $CFC0, $0FCF, $7E00, $0000
        word    $7FC0, $FCE0, $FF00, $03FF, $F3F8, $1F9F, $FC00, $E0FC, $07E7, $E000, $000F, $CFC0, $0FCF, $7E00, $0000
        word    $FFC0, $0001, $FFC0, $03FF, $F3F8, $1FBF, $FC00, $E0FC, $07E7, $E000, $000F, $CFC0, $0FCF, $7E00, $0000
        word    $FFC0, $0007, $FFF8, $03FF, $F3F8, $9FBF, $FC1F, $E0FC, $FFE7, $E007, $F80F, $CFFF, $FFCF, $FE0F, $007F
        word    $FFC0, $C07F, $FFFF, $03FF, $F3F8, $9FFF, $FC1F, $E0FC, $FFE7, $E00F, $F80F, $C7FF, $FFCF, $FE0F, $00FF
        word    $FFC0, $FFFF, $FFFF, $03FF, $F3F8, $9FFF, $FC1F, $E0FC, $FFE7, $E01F, $F80F, $C3FF, $FFCF, $FE0F, $01FF
        word    $FFC0, $FFFF, $FFFF, $01FF, $F3F8, $9FFF, $FC1F, $E0FC, $FFC7, $E03F, $F80F, $C1FF, $FFCF, $FC0F, $03FF
        word    $FFC0, $FFFF, $FFFF, $00FF, $F3F8, $9FFF, $FC1F, $E0FC, $FF87, $E03F, $F80F, $C3FF, $FFCF, $F80F, $03FF
        word    $FFC0, $FFFF, $FFFF, $007F, $F3F8, $9FFB, $FC1F, $E0FC, $FF07, $E03F, $F80F, $C7FF, $FFCF, $F00F, $03FF
        word    $FFC0, $FFFF, $FFFF, $003F, $F3F8, $9FFB, $FC1F, $E0FC, $0007, $E03F, $F80F, $CFFF, $0FCF, $0000, $03F0
        word    $FFC0, $FFFF, $FFFF, $001F, $F3F8, $9FF3, $FC1F, $E0FC, $0007, $E03F, $F80F, $CFC1, $0FCF, $0000, $03F0
        word    $FFC0, $FFFF, $FFFF, $000F, $F3F8, $9FF3, $FC1F, $E0FC, $0007, $E03F, $F80F, $CFC1, $0FCF, $0000, $03F0
        word    $FFC0, $FFFF, $FFFF, $0007, $F3F8, $9FE3, $FFFF, $FFFC, $FFE7, $E03F, $F80F, $CFC1, $FFCF, $FE7F, $03FF
        word    $FFC0, $FFFF, $FFFF, $0003, $F3F8, $9FE3, $FFFF, $FFFC, $FFE7, $E03F, $F80F, $CFC1, $FFCF, $FE7F, $03FF
        word    $FFC0, $FFFF, $FFFF, $0001, $F3F8, $9FC3, $FFFF, $FFFC, $FFE7, $E03F, $F80F, $CFC1, $FFCF, $FE7F, $03FF
        word    $FFC0, $FFFF, $FFFF, $0000, $F3F8, $9FC3, $7FFF, $FFFC, $FFE3, $E01F, $F80F, $CFC1, $FF8F, $FE7F, $01FF
        word    $FFC0, $FFFF, $7FFF, $0000, $F3F8, $9F83, $3FFF, $FFFC, $FFE1, $E00F, $F80F, $CFC1, $FF0F, $FE7F, $00FF
        word    $FFC0, $FFFF, $3FFF, $0000, $F3F8, $9F83, $1FFF, $FFFC, $FFE0, $E007, $F80F, $CFC1, $FE0F, $FE7F, $007F
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

DAT