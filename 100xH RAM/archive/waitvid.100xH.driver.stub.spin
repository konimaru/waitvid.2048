''
'' VGA display 100x50 (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2012/03/16
''       Version: 0.1
''
'' long[par][0]:  screen:      [!Z]:addr =   16:16 -> zero (accepted)
'' long[par][1]:    font: size:[!Z]:addr =  8:8:16 -> zero (accepted)
'' long[par][2]: palette:  c/a:[!Z]:addr = 1:15:16 -> zero (accepted), optional colour [buffer]
'' long[par][3]: frame indicator/sync lock
''
'' The colour buffer is either an address (%0--//--0) or a colour value (%1--//---).
''
'' acknowledgements
'' - loader and emitter code based on work done by Phil Pilgrim (PhiPi) and Ray Rodrick (Cluso99)
''
CON
  hv_idle = $01010101 * %00 {%hv}               ' h/v sync inactive
  hv_mask = $FCFCFCFC                           ' colour mask
  dcolour = %%0220_0010 & hv_mask | hv_idle     ' default colour

  res_x   = 800                                 ' |
  res_y   = 600                                 ' |
  res_m   = 4                                   ' UI support
  
OBJ
  system: "core.con.system"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox) : release | cog
                                      
  word[mailbox][6] := word[mailbox][7] := @release

  cog := system.launch( ID, @drv[drv.word[2]], mailbox) & 7
 {cog :=}system.launch(cog, @drv[drv.word[2]], mailbox|$8000)

  repeat
  while long[mailbox][3]

  release := TRUE
  
DAT drv long    'waitvid.100xH.driver.2048.cog' ' built-in binary
        file    "waitvid.100xH.driver.2048.cog"
DAT