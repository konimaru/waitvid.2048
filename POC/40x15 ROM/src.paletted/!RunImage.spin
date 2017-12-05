''
''        Author: Marko Lukat
'' Last modified: 2017/12/05
''       Version: 0.1
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

OBJ
  client: "core.con.client.demoboard"
  vga[4]: "vga"
  
PUB selftest

  init

PRI init : i | lock

  vga[0].fill

  lock := ((cnt >> 16 + 2) | 1) << 16
  repeat i from 0 to 3
    vga[i].init(lock|vconfig[i])

DAT
                
vconfig long    2 << 9 | %%300_3                ' red,        sync
        long    2 << 9 | %%020_0                ' green 1, no sync
        long    2 << 9 | %%010_0                ' green 0, no sync
        long    2 << 9 | %%003_0                ' blue,    no sync

DAT