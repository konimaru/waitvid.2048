''
'' VGA display 80xM (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2013/11/23
''       Version: 0.1
''
'' long[par][0]:  screen:   [!Z]:addr =  16:16 -> zero (accepted), 2n
'' long[par][1]:    font: size:*:addr = 8:8:16 -> zero (accepted), 2n
'' long[par][2]: palette:  [!Z]:fg:bg = 16:8:8 -> zero (accepted), optional colour
'' long[par][3]: frame indicator
''
'' 201311123: initial version (640x480@60Hz timing, %11 sync locked)
''
CON
  res_x   = 640                                 ' |
  res_y   = 480                                 ' |
  res_m   = 4                                   ' UI support
  
OBJ
  system: "core.con.system"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox)
                                      
  return system.launch(ID, @drv[drv.word[2]], mailbox)
  
DAT drv long    'waitvid.80xM.driver.2048.cog'  ' built-in binary
        file    "waitvid.80xM.driver.2048.cog"
DAT