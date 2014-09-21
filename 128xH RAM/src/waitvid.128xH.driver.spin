''
'' VGA display 128xH (quad cog) - wrapper for video drivers
''
''        Author: Marko Lukat
'' Last modified: 2012/04/03
''       Version: 0.2
''
OBJ
  LHS: "waitvid.128xH.driver.L.2048"
  RHS: "waitvid.128xH.driver.R.2048"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox) : release | cog

  long[mailbox][3] := @release
                                      
  cog := LHS.init( ID, mailbox) & 7
 {cog :=}RHS.init(cog, mailbox)

  repeat
  until release == $FFFFFFFF                            ' OK (SR:PR:SL:PL)

  release := FALSE                                      ' release sync lock

CON
  dcolour = LHS#dcolour                                 ' default colour

  res_x   = LHS#res_x                                   ' |
  res_y   = LHS#res_y                                   ' |
  res_m   = LHS#res_m                                   ' UI support
  
DAT