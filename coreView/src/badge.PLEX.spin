''
'' Parallax eBadge LED driver
''
''        Author: Marko Lukat
'' Last modified: 2016/01/14
''       Version: 0.3
''
'' acknowledgements
'' - code based on work done by Jon McPhalen:
''   - Charlieplex driver for Parallax Electronic Conference Badge
''     jm_ebadge_leds (C) 2015 Jon McPhalen
''
'' 20160112: initial version
''
PUB null
'' This is not a top level object.

PUB init(ID{ignored}, mailbox)

  ifnot result := cognew(@charlie, mailbox) +1
    abort

DAT             org     0

charlie         jmpret  $, #setup               '  -4   once

                mov     dirx, #0                ' |
                mov     outx, #0                ' default off
                
        if_c    movs    ch_0, #blue_tbl +0      ' |
        if_c    movs    ch_1, #blue_tbl +1      ' |
        if_c    movs    ch_2, #rgbx_tbl +0      ' |
        if_c    movs    ch_3, #rgbx_tbl +1      ' preset


                rdword  bmap, par               ' %00RGBRGB_00BBBBBB
                test    bmap, scan wc           ' blue LEDs

ch_0    if_c    or      dirx, 0-0               ' grab settings if
ch_1    if_c    or      outx, 1-1               ' LED is marked on

                add     ch_0, #2                ' |
                add     ch_1, #2                ' next table entry


                shr     bmap, #8                ' %00000000_00RGBRGB
                test    bmap, scan wc           ' RGB LEDs

ch_2    if_c    or      dirx, 2-2               ' grab settings if
ch_3    if_c    or      outx, 3-3               ' LED is marked on

                add     ch_2, #2                ' |
                add     ch_3, #2                ' next table entry


                shl     scan, #1
                cmpsub  scan, #|< 6 -1 wc       ' wrap around (64 -> 1)

                waitcnt cnt, time

                mov     dira, #0                ' avoid ghosting
                mov     outa, outx              ' |
                mov     dira, dirx              ' apply new setting

                jmp     %%0                     ' ... and again
                
' initialised data and/or presets

scan            long    |< 0                    ' bitmap scanner

blue_tbl        long    |< BLU_CP2 | |< BLU_CP1, |< BLU_CP1
                long    |< BLU_CP2 | |< BLU_CP0, |< BLU_CP2
                long    |< BLU_CP2 | |< BLU_CP0, |< BLU_CP0
                long    |< BLU_CP2 | |< BLU_CP1, |< BLU_CP2
                long    |< BLU_CP1 | |< BLU_CP0, |< BLU_CP1
                long    |< BLU_CP1 | |< BLU_CP0, |< BLU_CP0

rgbx_tbl        long    |< RGB_CP2 | |< RGB_CP0, |< RGB_CP2
                long    |< RGB_CP1 | |< RGB_CP0, |< RGB_CP1
                long    |< RGB_CP2 | |< RGB_CP1, |< RGB_CP1
                long    |< RGB_CP2 | |< RGB_CP0, |< RGB_CP0
                long    |< RGB_CP1 | |< RGB_CP0, |< RGB_CP0
                long    |< RGB_CP2 | |< RGB_CP1, |< RGB_CP2

' Stuff below is re-purposed for temporary storage.

setup           rdlong  time, #0                '  +0 = clkfreq                         (%%)
                shr     time, #11               '  +8   clkfreq / 2048

                mov     cnt, #5{14} + 88
                add     cnt, cnt                ' first target

                jmpret  zero, %%0 wc,nr         ' carry set

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup

time            res     1                       ' rate control          < setup +1      (%%)
bmap            res     1                       ' LED pattern

dirx            res     1                       ' |
outx            res     1                       ' IO under construction

tail            fit
                        
CON
  zero          = $1F0                          ' par (dst only)

  res_m         = 2                             ' UI support


  BLU_CP2       = 8                             ' LEDc
  BLU_CP1       = 7                             ' LEDb
  BLU_CP0       = 6                             ' LEDa

  RGB_CP2       = 3                             ' RGBc
  RGB_CP1       = 2                             ' RGBb
  RGB_CP0       = 1                             ' RGBa


  PAD_NE        = |< 27
  PAD_E         = |< 26
  PAD_SE        = |< 25

  PAD_S         = |< 5

  PAD_SW        = |< 15
  PAD_W         = |< 16
  PAD_NW        = |< 17

  PAD_MASK      = PAD_NE|PAD_E|PAD_SE|PAD_S|PAD_SW|PAD_W|PAD_NW

  PAD_DCHG      = 586                           ' *clkfreq/2K (about 15ms)
  PAD_ECNT      = 16                            ' number of consecutive /equal/ scans

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT