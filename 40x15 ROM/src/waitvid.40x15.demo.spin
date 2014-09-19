''
'' VGA display 40x15 (single cog, ROM font) - demo
''
''        Author: Marko Lukat
'' Last modified: 2013/10/02
''       Version: 0.2
''
CON
  _clkmode = client#_clkmode
  _xinfreq = client#_xinfreq

OBJ
  client: "core.con.client.demoboard"
     vga: "waitvid.40x15.ui"
  
PUB selftest : c

  vga.init

  vga.str(string(vga#ESC, "s"))                         ' page mode

  repeat vga#bcnt                                       ' fill screen
    vga.putc(c++)

  waitcnt(clkfreq*3 + cnt)

  fill(vga.str(string(vga#ESC, "c", %%3000, %%0003)))
  fill(vga.str(string(vga#ESC, "c", %%0300, %%0003)))
  fill(vga.str(string(vga#ESC, "c", %%0030, %%0003)))

' Random colours.

  frqa := cnt
  
  repeat vga#bcnt * 2
    vga.str(string(vga#ESC, "c"))
    vga.out(?frqa)
    vga.out(?frqa)

    vga.putc(c++)
    waitcnt(clkfreq/100 + cnt)

' String output using ESC sequences.

  vga.str(string(vga#ESC, "c", %%0003, %%0003, vga#FF))
  vga.str(string(vga#ESC, "=", vga#columns -23, vga#rows -2))

  vga.str(string(vga#ESC, "c", %%3003, %%0003, "multi "))
  vga.str(string(vga#ESC, "c", %%0303, %%0003, "coloured "))
  vga.str(string(vga#ESC, "c", %%0033, %%0003, "message"))
  
PRI fill(char)

  vga.str(string(vga#ESC, "=", vga#columns, vga#rows))  ' HOME
  repeat vga#bcnt
    vga.putc(char++)
    waitcnt(clkfreq/200 + cnt)

DAT