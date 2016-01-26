''
'' prerequisites, dependencies & Co, Parallax eBadge
''
''        Author: Marko Lukat
'' Last modified: 2016/01/26
''       Version: 0.1
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  #9, AUDIO_L, AUDIO_R                                  ' AUDIO channels
  
PUB null
'' This is not a top level object.

DAT