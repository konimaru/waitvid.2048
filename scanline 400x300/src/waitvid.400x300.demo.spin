''
'' VGA scanline driver 400x300 (single cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2012/10/07
''       Version: 0.3
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  res_x = driver#res_x
  res_y = driver#res_y

  quads = res_x / 4
  
OBJ
  driver: "waitvid.400x300.driver.2048"
    
VAR
  long  frame, scan[quads]
  
PUB selftest : n

  driver.init(-1, @scan{0})

' When vertical blank starts the frame indicator is set to 0.
' Once line N (0..299) is fetched it changes to N+1. Following
' that the buffer can be modified.

  waitcnt(clkfreq*3 + cnt)

  longfill(@scan{0}, 0, quads)

' Vertical yellow line from left to right.

  n := 0
  waitVBL
  scan.byte[n] := %%3300

  repeat constant(res_x -1)
    waitVBL
    scan.byte[n++] := %%0000
    scan.byte[n]   := %%3300

  longfill(@scan{0}, 0, quads)

' Vertical purple line from right to left.

  n := res_x
  waitVBL
  scan.byte[--n] := %%3030

  repeat constant(res_x -1)
    waitVBL
    scan.byte[n--] := %%0000
    scan.byte[n]   := %%3030

  longfill(@scan{0}, 0, quads)

' Horizontal red line from top to bottom.

  coginit(cogid, @entry, @scan{0})              ' remainder in PASM
  
PRI waitVBL

  repeat
  until frame == res_y                          ' last line has been fetched
  repeat                  
  until frame <> res_y                          ' vertical blank starts (res_y/0 transition)

DAT             org     0

entry           add     blnk, par               ' frame indicator
                add     base, par               ' scanline buffer
                
                rdlong  temp, blnk
                cmp     temp, #res_y wz
        if_ne   jmp     #$-2                    ' waiting for last line to be fetched

main            mov     indx, #0

idle            rdlong  temp, blnk
                cmp     temp, #0 wz
        if_ne   jmp     #$-2                    ' waiting for vertical blank


                rdlong  temp, blnk
                cmp     temp, indx wz
        if_ne   jmp     #$-2                    ' wait until buffer ready

                mov     zwei, line
                call    #fill

                add     indx, #1                ' line done, advance
                
                rdlong  temp, blnk
                cmp     temp, indx wz
        if_ne   jmp     #$-2                    ' wait until fetched

                mov     zwei, #0
                call    #fill                   ' renderer has local copy now

                cmp     indx, #res_y wc
        if_c    jmp     #idle
                jmp     #main


fill            mov     addr, base
                mov     temp, #quads
                
                wrlong  zwei, addr
                add     addr, #4
                djnz    temp, #$-2
                
fill_ret        ret

' initialised data and/or presets

blnk            long    -4
base            long    +0

line            long    %%3000_3000_3000_3000

' uninitialised data and/or temporaries

addr            res     1
indx            res     1
temp            res     1
zwei            res     1

                fit
                
DAT