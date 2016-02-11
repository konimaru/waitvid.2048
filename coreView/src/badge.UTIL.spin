''
''        Author: Marko Lukat
'' Last modified: 2016/02/11
''       Version: 0.2
''
OBJ
' util: "I2C PASM driver v1.8od"
  util: "jm_mma7660fc"
  
VAR
  long  tzyx, orientation, up, down, right, left
  long  stack[32]
  
PUB null
'' This is not a top level object.

PUB init(SCL, SDA, base, layout) : n

  util.start(SCL, SDA{, 400_000})
  
  tzyx        := base
  orientation := base + 4

  repeat n from 0 to 3
    up[n] := base + layout.byte[n]

  cognew(task, @stack{0})
  
PRI task

  repeat
    util.read_all_raw(tzyx)
    case byte[tzyx][3] & %000_111_00
      %000_110_00: long[orientation] := long[up]
      %000_101_00: long[orientation] := long[down]
      %000_010_00: long[orientation] := long[right]
      %000_001_00: long[orientation] := long[left]
    waitcnt(clkfreq/4 + cnt)
    
DAT