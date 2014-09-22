''
'' VGA display 51xG (dual cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2012/09/17
''       Version: 0.7
''
'' long[par][0]:  screen:      [!Z]:addr =  16:16 -> zero (accepted)
'' long[par][1]:    font: size:[!Z]:addr = 8:8:16 -> zero (accepted)
'' long[par][2]: palette:      [!Z]:addr =  16:16 -> zero (accepted)
'' long[par][3]: frame indicator/sync lock
''
'' acknowledgements
'' - loader code based on work done by Phil Pilgrim (PhiPi) and Ray Rodrick (Cluso99)
''
'' 20120915: horizontal character scrolling operational
'' 20120916: horizontal pixel scrolling operational
'' 20120917: vertical pixel scrolling operational
''
CON
  res_x   = 512                                 ' |
  res_y   = 512                                 ' |
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
  
DAT drv long    'waitvid.51xG.driver.2048.cog'  ' built-in binary
        file    "waitvid.51xG.driver.2048.cog"
DAT