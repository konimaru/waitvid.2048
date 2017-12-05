''
''        Author: Marko Lukat
'' Last modified: 2017/12/05
''       Version: 0.1
''
CON
  columns  = driver#res_x / 16
  rows     = driver#res_y / 32
  bcnt     = columns * rows

  rows_raw = (driver#res_y + 32 - 1) / 32
  bcnt_raw = columns * rows_raw

OBJ
  driver: "waitvid.40x15.plte.driver"

VAR
  long  link[driver#res_m]                              ' driver mailbox

' word  scrn[bcnt_raw / 2]                              ' screen buffer (2n aligned)
' word  indx[bcnt_raw / 2]                              ' colour buffer (2n aligned)
 
PUB null
'' This is not a top level object.

PUB init(config) : c

  link{0} := @scrn{0}                                   ' initial screen and
  link[2] := @indx{0}                                   ' colour index buffer (default palette)
  link[3] := config                                     ' lock/vgrp/vpin

  return driver.init(-1, @link{0})                      ' video driver and pixel generator

PUB fill : c

  repeat bcnt_raw
    scrn.byte[c] := c
    c++

DAT
  scrn  word    0[bcnt_raw / 2]                         ' screen buffer (2n aligned)
  indx  word    0[bcnt_raw / 2]                         ' colour buffer (2n aligned)

DAT