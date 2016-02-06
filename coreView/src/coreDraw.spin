''
''        Author: Marko Lukat
'' Last modified: 2016/02/06
''       Version: 0.4
''
CON
  res_x         = driver#res_x
  res_y         = driver#res_y

OBJ
  driver: "coreDraw.1K.SPI"
  
VAR
  long  instruction
  long  drawsurface

  long  cmd_blit, cmd_clip
  long  parameters[driver#res_a]
  
PUB null
'' This is not a top level object.

PUB blit(dst, src, x, y, idx, mask)

  repeat
  while instruction

  longmove(@parameters{0}, @dst, 6)
  instruction := cmd_blit

PUB clip(x1, y1, x2, y2)

  repeat
  while instruction

  longmove(@parameters{0}, @x1, 4)
  instruction := cmd_clip

PUB copy(dst, src)

  longmove(dst, src, 256)

PUB fill(dst, value)

  longfill(dst, value, 256)

PUB idle

  return not instruction
  
PUB init(surface{8:*:16})

  instruction := -1
  drawsurface := surface
  
  driver.init(-1, @instruction)

  longfill(@cmd_blit, @parameters{0} << 16, 2)          ' set parameter buffer
  cmd_blit |= driver#cmd_blit                           ' |
  cmd_clip |= driver#cmd_clip                           ' add command code(s)

  return drawsurface
  
PRI exec(args, command)                                 ' composite mode

  command.word[1] := args
  instruction := command
  repeat
  while instruction

PUB swap(surface)                                       ' composite mode

  exec(surface, driver#cmd_swap)

PUB cmd1(command)                                       ' composite mode

  exec(command, driver#cmd_cmd1)
  
PUB cmdN(buffer, count)                                 ' composite mode

  exec(@buffer, driver#cmd_cmdN)
  
PUB boot                                                ' composite mode

  exec(0, driver#cmd_boot)
  
DAT