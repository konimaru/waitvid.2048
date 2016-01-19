''
''        Author: Marko Lukat
'' Last modified: 2016/01/19
''       Version: 0.2
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
  SSD1306: "core.con.ssd1306"
     view: "coreView.1K.SPI"
  
VAR
  long  surface
  long  mailbox
  
PUB selftest : n | str, t, cmd

  init

  longfill(surface, 0, 256)
  waitcnt(clkfreq + cnt)
  view.swap(surface)
  waitcnt(clkfreq + cnt)

  str := string("konimaru")
  cmd := SSD1306#DISPLAY_NORMAL
  
  t := cnt
  
  repeat
    repeat n from 0 to 512 step 16
      send(str, surface + n)
      waitcnt(t += clkfreq/30)
      view.swap(surface)

    repeat n from 496 to 16 step 16
      send(str, surface + n)
      waitcnt(t += clkfreq/30)
      view.swap(surface)
                                                        
    view.cmd1(cmd ^= 1)                                 ' normal/inverted
    
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

  cognew(@entry, @mailbox)

PRI send(str, dst)

  str.word[1] := dst
  mailbox := str
  repeat
  while mailbox
  
DAT             org     0

entry           rdlong  text, par wz
                mov     scrn, text
        if_z    jmp     #entry

                shr     scrn, #16

:loop           rdbyte  char, text wz
        if_z    jmp     #:done

                call    #emit
                add     scrn, #2                ' dst
                add     text, #1                ' src
                jmp     #:loop

:done           wrlong  zero, par
                jmp     #entry

' char: $00..$FF
' scrn: destination address (2n)

emit            ror     char, #1                ' - %c0000000_00000000_00000000_0ccccccc
                or      addr, #$100             ' - %c0000000_00000000_00000001_0ccccccc
                shl     addr, #7 wc             ' c %00000000_00000000_10cccccc_c0000000
                muxc    shft, #1                ' even/odd extractor

loop            rdlong  data, addr
shft            shr     data, #1

                shr     data, #2 wc             ' extract bit 0 (left most)
                rcr     trgt, #1                ' insert (packed) into target
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1

                shr     data, #2 wc             ' bit 4
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1

                shr     data, #2 wc             ' bit 8
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1

                shr     data, #2 wc             ' bit 12
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #2 wc
                rcr     trgt, #1
                shr     data, #1 wc
                rcr     trgt, #17               ' push through to bit 15

                add     addr, i16s4 wc          ' advance source and loop

                wrword  trgt, scrn
        if_nc   add     scrn, #16               ' next line (y++)
        if_nc   jmp     #loop                   ' for all lines

                sub     scrn, #16*31            ' restore destination
emit_ret        ret

i16s4           long    16 << 23 | 4

char            res     alias
addr            res     1
data            res     1
scrn            res     1
trgt            res     1

text            res     1

                fit

CON
  zero          = $1F0                          ' par (dst only)
  alias         = 0

DAT