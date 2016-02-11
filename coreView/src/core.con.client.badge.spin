''
'' prerequisites, dependencies & Co, Parallax eBadge
''
''        Author: Marko Lukat
'' Last modified: 2016/02/11
''       Version: 0.2
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  #9, AUDIO_L, AUDIO_R                                  ' AUDIO channels

  SCL = 28                                              ' |
  SDA = 29                                              ' I2C bus
  
PUB null
'' This is not a top level object.

DAT