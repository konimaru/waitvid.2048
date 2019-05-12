CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000
  
CON
  vgrp     = 2                                          ' video pin group
  vpin     = %%333_3                                    ' video pin mask
  video    = (vgrp << 9 | vpin) << 21

VAR
  long  mbox[res_m]
  long  scn0[res_x /4]
  long  scn1[res_x /4]
  
PUB selftest : n

  scn0[0] := %%3000'%%3000_0300_0030_3300
  scn1[0] := %%2220_2220_2220_2220

  scn0[159] := %%3000_0000_0000_0000
  scn1[159] := %%2220_2220_2220_2220

  mbox{0} := @scn1{0} << 16 | @scn0{0}
  mbox[1] := video
  
  init(-1, @mbox{0})

  repeat
    repeat n from 0 to res_x /4 -1
      waitVBL
      scn0[n] := %%0000_0000_0000_2222
      waitVBL
      scn0[n] := %%0000_0000_2222_2222
      waitVBL
      scn0[n] := %%0000_2222_2222_2222
      waitVBL
      scn0[n] := %%2222_2222_2222_2222
     
    repeat n from res_x /4 -1 to 0
      waitVBL
      scn0[n] := %%0000_2222_2222_2222
      waitVBL
      scn0[n] := %%0000_0000_2222_2222
      waitVBL
      scn0[n] := %%0000_0000_0000_2222
      waitVBL
      scn0[n] := %%0000_0000_0000_0000
     
PRI waitVBL

  repeat
  until mbox[1] == res_y                        ' last line has been fetched
  repeat                  
  until mbox[1] <> res_y                        ' vertical blank starts (res_y/0 transition)

DAT