''
''        Author: Marko Lukat
'' Last modified: 2015/12/14
''       Version: 0.1
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
  driver: "coreView.1K.SPI"
  serial: "FullDuplexSerial"
  
PUB main | t

  serial.start(31, 30, %0000, 115200)
  driver.init
  waitcnt(clkfreq*3 + cnt)

  ctra := constant(%0_01010_000 << 23 | 21)
  frqa := 1
  repeat
    phsa := 0
    driver.swap($8000)
    print(phsa)
    waitcnt(clkfreq + cnt)

PRI print(value)

  serial.dec(value)
  serial.tx(13)
  
DAT