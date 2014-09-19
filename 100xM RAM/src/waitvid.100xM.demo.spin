''
'' VGA display 100xM (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2013/02/22
''       Version: 0.3
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

OBJ
  client: "core.con.client.demoboard"
     vga: "waitvid.100xM.ui"
  
PUB selftest : c

  vga.init

  vga.str(string(vga#ESC, "s"))                         ' page mode

  repeat vga#bcnt                                       ' fill screen
    vga.putc(c++)

  waitcnt(clkfreq*3 + cnt)

' Changing colour (monochrome only).

  repeat 16
    c |= %0101010
    vga.setn(2, NEGX|((c++ & %%1111) * 3) << 8)
    waitcnt(clkfreq/2 + cnt)

  vga.out(vga#FF)
  vga.setn(2, NEGX|%%2220_0000)
  waitcnt(clkfreq + cnt)
  
' String output using ESC sequence(s).

  vga.str(string(vga#ESC, "=", vga#columns -19, vga#rows -2))
  vga.str(string("monochrome message"))

  waitcnt(clkfreq*2 + cnt)

  vga.setn(2, NEGX|%%0220_0010)

DAT