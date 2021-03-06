''
'' prerequisites, dependencies & Co
''
''        Author: Marko Lukat
'' Last modified: 2011/10/22
''       Version: 0.9
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  ID_0 = $30B3309C
  ID_1 = $9ED2732B
  ID_2 = $38343032                                      ' cog binary magic number (2048)

  OVERLAY = %00000000_00000001                          ' cog binary is an overlay
  MAPPING = %00000000_00000010                          ' translation table is present

PUB null
'' This is not a top level object.

PUB launch(ID, code, data)
'' PASM quick launch using a specific or the next available ID.
''
'' parameters
''       ID: cog ID
''           0..7: coginit, otherwise cognew (may fail)
''     code: address of code fragment (4n)
''     data: cognew/coginit parameter (4n)
''
'' result
''     == 0: [ABORT] thread creation failed (cognew only)
''     <> 0: thread/cog ID + 1

  ifnot (ID >> 3)
    coginit(ID++, code, data)
  elseifnot ID := cognew(code, data) + 1
    abort
  return ID

DAT
