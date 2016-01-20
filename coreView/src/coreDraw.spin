''
''        Author: Marko Lukat
'' Last modified: 2016/01/20
''       Version: 0.1
''
OBJ
  driver: "coreDraw.1K.driver"
  
VAR
  long  instruction
  long  drawsurface
  
PUB null
'' This is not a top level object.

PUB init(surface)

  instruction := -1
  drawsurface := surface
  
  result := driver.init(-1, @instruction)

  repeat
  while instruction                                     ' wait until cog is running
  
DAT