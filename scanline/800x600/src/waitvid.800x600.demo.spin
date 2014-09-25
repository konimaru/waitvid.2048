''
'' VGA scanline driver 800x600 (dual cog) - demo
''
''        Author: Marko Lukat
'' Last modified: 2014/09/25
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
  driver: "waitvid.800x600.driver.2048"
  
VAR
  long  frame, scan[quads]
  long  storage[8]
  
PUB selftest : n

  longfill(@storage{0}, @scan{0}, 8)
  
  n := 7 & driver.init(7 & (cogid+1), @scan{0})

  storage[n]   |=  0 << 16
  coginit(n,   @entry, @storage[n])             ' remainder in PASM
  storage[n^4] |=  4 << 16
  coginit(n^4, @entry, @storage[n^4])           ' remainder in PASM
  storage[++n] |=  8 << 16
  coginit(n,   @entry, @storage[n])             ' remainder in PASM
  storage[n^4] |= 12 << 16
  coginit(n^4, @entry, @storage[n^4])           ' remainder in PASM

  repeat n from 32 to 47
    long[n*256 +  8] := $C0C0C0C0
    long[n*256 + 12] := $30303030
    long[n*256 + 16] := $0C0C0C0C
    long[n*256 + 20] := $FCFCFCFC               ' coloured box 0

  repeat n from 64 to 79
    long[n*256 +  8] := $3C3C3C3C
    long[n*256 + 12] := $CCCCCCCC
    long[n*256 + 16] := $F0F0F0F0
    long[n*256 + 20] := $55555555               ' coloured box 1

  str($3F30, string("256", 215, "256px"))
  str($5EF0, string("P8X32A RAM", 215, " ROM", 5))
  
PRI str(addr, s)

  repeat strsize(s)
    chr(addr += 16, byte[s++])
    
PRI chr(addr, c) | b, m, v

  b := $8000 + (c >> 1) << 7
  repeat m from b to b +127 step 4
    v := long[m] >> (c & 1)
    repeat 16
      byte[addr++] := byte[$872A][v & 1]
      v >>= 2
    addr += 240
  
PRI waitVBL

  repeat
  until frame
  repeat
  while frame
  
DAT             org     0

entry           rdlong  hpos, par
                add     blnk, hpos
                ror     hpos, #16
                movs    drei, hpos
                ror     hpos, #16
                add     hpos, drei

loop            rdlong  lcnt, blnk
                cmp     lcnt, vres wz
        if_ne   jmp     #$-2                    ' wait for vblank

                mov     trgt, #40
                mov     base, drei


main            rdlong  lcnt, blnk
                cmp     lcnt, trgt wz
        if_ne   jmp     #$-2                    ' wait for target

                mov     eins, #16
                mov     scrn, hpos
                add     scrn, #40

fill            rdlong  zwei, base
                add     base, #16
                wrlong  zwei, scrn
                add     scrn, #16
                djnz    eins, #fill

                add     trgt, #1
                cmp     trgt, #40+256 wz
        if_ne   jmp     #main


                rdlong  lcnt, blnk
                cmp     lcnt, trgt wz
        if_ne   jmp     #$-2                    ' wait for target

                mov     eins, #16
                mov     scrn, hpos
                add     scrn, #40

                wrlong  zero, scrn
                add     scrn, #16
                djnz    eins, #$-2

                jmp     #loop

vres            long    res_y
blnk            long    -4
drei            long    0

hpos            res     1
trgt            res     1

eins            res     1
zwei            res     1
lcnt            res     1
base            res     1
scrn            res     1

                fit

CON             
  zero = $1F0                                   ' par (dst only)

DAT