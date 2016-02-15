''
''        Author: Marko Lukat
'' Last modified: 2016/02/15
''       Version: 0.4
''
CON
  res_m         = T_END                                 ' UI support

  #0, T_DST, T_SRC, T_LEN, T_END

  T_BLK         = 2048

OBJ
' util: "I2C PASM driver v1.8od"
  util: "jm_mma7660fc"
  
VAR
  long  lock, transfers[8], head, tail
  long  xyzt, orientation, up, down, right, left

  long  stack[32]
  
PUB null
'' This is not a top level object.

PUB init(SCL, SDA, base, layout) : n

  util.start(SCL, SDA{, 400_000})                       ' start driver
  
  xyzt        := base                                   ' |
  orientation := base + 4                               ' locations for raw/custom values

  repeat n from 0 to 3                                  ' |
    up[n] := base + layout.byte[n]                      ' initialise custom source(s)

  lock := locknew                                       ' reserve lock
  cognew(task, @stack{0})                               ' start helper task
  
PUB bget(transfer, dst, src, length, wait{boolean})

  longmove(transfer, @dst, 3)                           ' setup transfer

  repeat
  while lockset(lock)                                   ' acquire lock

  transfers[head++] := transfer                         ' record transfer
  head &= 3                                             ' (there is at most one transfer per client)

  lockclr(lock)                                         ' release lock

  if wait
    repeat
    while long[transfer][T_LEN]                         ' wait for completion
    
PUB complete(transfer)

  return not long[transfer][T_LEN]                      ' transfer size 0 -> done
  
PRI task : mark | transfer, length

  mark := cnt

  repeat
    util.read_all_raw(xyzt)
    case byte[xyzt][3] & %000_111_00
      %000_110_00: long[orientation] := long[up]
      %000_101_00: long[orientation] := long[down]
      %000_010_00: long[orientation] := long[right]
      %000_001_00: long[orientation] := long[left]

    repeat                                                        
      if tail <> head                                   ' transfers available
        transfer := transfers[tail]                     ' grab active transfer

        ifnot long[transfer][T_LEN] -= length := long[transfer][T_LEN] <# T_BLK
          tail := (tail + 1) & 7                        ' remove transfer
                                                                  
'       uti2.readBytes(uti2#EEPROM, long[transfer][T_SRC], long[transfer][T_DST], length)
'       read(long[transfer][T_DST], long[transfer][T_SRC], length)
                                                                  
        long[transfer][T_DST] += length                 ' |       
        long[transfer][T_SRC] += length                 ' update remaining transfer
    while (cnt - mark) < clkfreq >> 2                             
                                                                  
    mark += clkfreq >> 2                                          
      
DAT