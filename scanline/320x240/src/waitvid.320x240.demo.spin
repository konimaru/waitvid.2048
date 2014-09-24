''
'' VGA scanline driver 320x240 (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2013/03/01
''       Version: 0.2
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  res_x = driver#res_x
  res_y = driver#res_y

  quads = res_x / 4
  
OBJ
  driver: "waitvid.320x240.driver.2048"
    
VAR
  long  link[driver#res_m]
  long  scn0[quads]
  long  scn1[quads]
  
PUB selftest

  longfill(@scn0{0}, %%3000_0300_0030_3330, constant(res_x / 4))
  longfill(@scn1{0}, %%0300_0030_3330_3000, constant(res_x / 4))

' simple double buffer setup

  link{0} := @scn1{0} << 16 | @scn0{0}

  driver.init(-1, @link{0})

  repeat 240
    waitVBL

' switch to multi buffer mode (first line is always from the primary buffer)

  coginit(cogid, @entry, @link{0})
    
PRI waitVBL

  repeat
  until link{0} == res_y                        ' last line has been fetched
  repeat                  
  until link{0} <> res_y                        ' vertical blank starts (res_y/0 transition)

DAT             org     0

entry           add     extn, par               ' 3rd party buffer location, frame indicator
                
                rdlong  indx, extn              ' |
                cmpsub  indx, #res_y wz         ' |
        if_ne   jmp     #$-2                    ' waiting for last line to be fetched

main            mov     addr, base              ' |
line            wrword  addr, extn              ' set 3rd party buffer address

                add     indx, #1                ' line done, advance target
                
                rdlong  temp, extn              ' |
                cmp     temp, indx wz           ' |
        if_ne   jmp     #$-2                    ' FI:indx-1/indx

                add     addr, #res_x            ' advance address
                cmpsub  indx, #res_y wz         ' optionally wrap line index
        if_ne   jmp     #line                   ' for all lines

                add     base, #res_x            ' shift one line per frame
                jmp     #main

' initialised data and/or presets

base            long    1                       ' must be non-zero, use alignment bit(s)
extn            long    2                       ' word offset in mailbox

' uninitialised data and/or temporaries

addr            res     1
indx            res     1
temp            res     1

                fit
                
DAT