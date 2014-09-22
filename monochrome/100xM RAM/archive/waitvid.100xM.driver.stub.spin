''
'' VGA display 100xM (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2013/02/18
''       Version: 0.7
''
'' long[par][0]:  screen:   [!Z]:addr =  16:16 -> zero (accepted), 2n
'' long[par][1]:    font: size:*:addr = 8:8:16 -> zero (accepted), 2n
'' long[par][2]: palette:  [!Z]:fg:bg = 16:8:8 -> zero (accepted), optional colour
'' long[par][3]: frame indicator
''
'' 20130216: initial version (800x600@60Hz timing, %00 sync locked)
''           capable of using 64/256 colours (RRGGBBHV / RRGGBBgr + xxxxxxHV)
''
CON
  res_x   = 800                                 ' |
  res_y   = 600                                 ' |
  res_m   = 4                                   ' UI support
  
OBJ
  system: "core.con.system"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox)
                                      
  return system.launch(ID, @drv[drv.word[2]], mailbox)
  
DAT drv long    'waitvid.100xM.driver.2048.cog' ' built-in binary
        file    "waitvid.100xM.driver.2048.cog"
DAT