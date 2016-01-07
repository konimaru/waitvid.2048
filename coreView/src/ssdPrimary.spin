''
''        Author: Marko Lukat
'' Last modified: 2016/01/07
''       Version: 0.2
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
  driver: "coreView.1K.SPI"
  
PUB selftest : surface

  surface := driver.init                                ' start driver
  driver.cmdN(string($A1, $C8, $20, $FC, $8D, $14), 6)  ' finish setup
  driver.swap(surface)                                  ' show initial screen
  driver.cmd1($AF)                                      ' display on

DAT