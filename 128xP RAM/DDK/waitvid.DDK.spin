''
'' VGA display 128xP (quad cog) - low level demo
''
''        Author: Marko Lukat
'' Last modified: 2012/04/16
''       Version: 0.4
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

CON
  columns  = 1024 / 8
  rows     = 768 / fnt0#height
  bcnt     = columns * rows

  rows_raw = (768 + fnt0#height - 1) / fnt0#height
  bcnt_raw = columns * rows_raw

OBJ
  client: "core.con.client.demoboard"
  thread: "core.aux.thread"
    fnt0: "generic8x12-4font"
    
VAR
  long  mailbox[4], cursor[2]
  long  scrn, font, crs0, crs1, plte, bgnd

  word  screen[bcnt_raw / 2]
  word  colour[bcnt_raw / 2]
  
PUB selftest : release | cog, n, dcolour, bcolour

' Start drivers without any default settings.

' mailbox{0} := @screen.byte[bcnt_raw - columns]        ' screen buffer
' mailbox[1] := fnt0#height << 24 | fnt0.addr           ' font
' mailbox[2] := @cursor{0}                              ' primary cursor
  mailbox[3] := @release

  cog := 7 & thread.launch( -1, @one, @mailbox{0},       %11)
  cog := 7 & thread.launch(cog, @one, @mailbox{0}|$8000, %11)
  cog := 7 & thread.launch(cog, @two, @mailbox{0},       %11)
 {cog := 7 &}thread.launch(cog, @two, @mailbox{0}|$8000, %11)

  repeat
  until release == $FFFFFFFF                            ' OK (SR:PR:SL:PL)

  release := FALSE                                      ' release sync lock

' Collect commands/colours from the driver (either one can be used).

  scrn    := thread.resolve(@one, string("scrn"), 0)    ' screen buffer
  font    := thread.resolve(@one, string("font"), 0)    ' font
  crs0    := thread.resolve(@one, string("crs0"), 0)    ' primary cursor
  crs1    := thread.resolve(@one, string("crs1"), 0)    ' secondary cursor
  plte    := thread.resolve(@one, string("plte"), 0)    ' colour [buffer]
  bgnd    := thread.resolve(@one, string("bgnd"), 0)    ' background palette

  dcolour := thread.resolve(@two, string("dcolour"), NEGX|%%0220_0010)
  bcolour := thread.resolve(@two, string("bcolour"), 0)
  
' Prepare font and screen buffer, set default colour.

  wordfill(@screen, $2020, constant(bcnt_raw / 2))      ' clear screen

  setn(scrn, @screen.byte[bcnt_raw - columns])          ' register screen buffer
  setn(font, fnt0#height << 24 | fnt0.addr)             ' register font
  setn(plte, dcolour)                                   ' default colour

' Register both cursors and place them somewhere.

  cursor.byte{0} := %0111                               ' mode (underline|flashing|on)
  cursor.byte[1] := 10{x}
  cursor.byte[2] := 10{y}
  
  cursor.byte[4] := %0001                               ' mode (block|static|on)
  cursor.byte[5] := 12{x}
  cursor.byte[6] := 10{y}

  setn(crs0, @cursor{0})
  setn(crs1, @cursor[1])

' Change colour (we are still in monochrome mode).

  waitcnt(clkfreq*3 + cnt)
  setn(plte, NEGX|%%0000_1110)                          ' black on grey

' Print some text, note that the screen is displayed back to front.

  print(10, 12, string("The quick brown fox jumps over the lazy dog."))

' Now add some more colour. Note that we switch to paletted mode. The colour
' below is yellow (%%330-) on background colour %%---1 (blue).

  waitcnt(clkfreq*3 + cnt)
  wordfill(@colour{0}, %%3301_3301, constant(bcnt_raw / 2))
  setn(plte, @colour{0})

' Cycle the background palette.

  waitcnt(clkfreq*3 + cnt)
  repeat 4
    bcolour <-= 8
    setn(bgnd, bcolour)
    waitcnt(clkfreq + cnt)

' Finally change the "fox" to white (location 26, 12).

  repeat n from 0 to 2
    colour.byte[12 * columns + 26 + n] := %%3331

PRI print(x, y, addr)

  if addr
    repeat strsize(addr)
      screen.byte[bcnt_raw - y * columns - ++x] := byte[addr++]
      
PRI setn(command, parameter)

  mailbox[1] := parameter
  mailbox{0} := command

  repeat
  while mailbox{0}
  
DAT one long    'waitvid.128xP.driver.L.2048.cog'       ' built-in binaries
        file    "waitvid.128xP.driver.L.2048.cog"
DAT two long    'waitvid.128xP.driver.R.2048.cog'       ' |
        file    "waitvid.128xP.driver.R.2048.cog"
DAT