CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
  lcd: "LameLCD"
  gfx: "LameGFX"

VAR
  long  buffer[512]

  word  size, sx, sy, data[64]
  
PUB null

  gfx.start(@buffer{0}, lcd.start)

  splash(string("kuroneko"), TRUE)
  
PRI splash(addr, erase{boolean}) : n

  gfx.ClearScreen                 

  size := 128
    sx := 16
    sy := 32                                            ' temporary sprite

  repeat n from 0 to 127 step 16
    place(@data{0}, byte[addr++], n => 64)              ' place char using ROM font
    gfx.Sprite(@data[-3], n, 16, 0)
    repeat 1                                                  
      lcd.WaitForVerticalSync     
    gfx.DrawScreen                
  waitcnt(clkfreq + cnt)

  if erase
    place(@data{0}, " ", FALSE)                         ' place char using ROM font
    repeat n from 0 to 127 step 16   
      gfx.Sprite(@data[-3], n, 16, 0)
      repeat 1                                                
        lcd.WaitForVerticalSync      
      gfx.DrawScreen                 
    waitcnt(clkfreq + cnt)           

PRI place(addr, c, inv{boolean}) | base, m, v

  base := $8000 + (c >> 1) << 7
  repeat m from base to base +127 step 4
    v := ((long[m] >> (c & 1)) ^ inv) & $55555555
    bytemove(addr, @v, 4)
    addr += 4
  
DAT