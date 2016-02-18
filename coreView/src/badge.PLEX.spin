''
'' Parallax eBadge LED/PAD driver (#20000, #20100, #20200)
''
''        Author: Marko Lukat
'' Last modified: 2016/01/24
''       Version: 0.7
''
'' acknowledgements
'' - code based on work done by Jon McPhalen:
''   - Charlieplex driver for Parallax Electronic Conference Badge
''     jm_ebadge_leds (c) 2015 Jon McPhalen
''
'' long[par][0]: [wr] LEDs: combination of LED_* and RGB_* constants
'' long[par][1]: [rd] PADs: combination of PAD_* constants
''
''                     Layout                                    
''              --------------------                             
''      PAD_P5  LED_B5        LED_B0  PAD_P0                     
''      PAD_P4  LED_B4        LED_B1  PAD_P1                     
''      PAD_P3  LED_B3        LED_B2  PAD_P2                     
''              --------------------                                                  
''              RGB_G1        RGB_G0                             
''          RGB_R1 RGB_B1  RGB_R0 RGB_B0                         
''
''                     PAD_P6
''
'' 20160112: initial version
'' 20160116: added pad scanner
''
CON
  LED_B0        = |< 0
  LED_B1        = |< 1
  LED_B2        = |< 2

  LED_B3        = |< 3
  LED_B4        = |< 4
  LED_B5        = |< 5

  RGB_B0        = |< 8
  RGB_G0        = |< 9
  RGB_R0        = |< 10

  RGB_B1        = |< 11
  RGB_G1        = |< 12
  RGB_R1        = |< 13

CON
  PAD_P0        = |< 27
  PAD_P1        = |< 26
  PAD_P2        = |< 25

  PAD_P3        = |< 15
  PAD_P4        = |< 16
  PAD_P5        = |< 17

  PAD_P6        = |< 5

CON
  BLACK         = %000
  BLUE          = %001
  GREEN         = %010
  CYAN          = %011
  RED           = %100
  MAGENTA       = %101
  YELLOW        = %110
  WHITE         = %111

PUB null
'' This is not a top level object.

PUB init(ID{ignored}, mailbox)

  ifnot result := cognew(@charlie, mailbox) +1
    abort

DAT             org     0                       ' LED/PAD driver

charlie         jmpret  $, #setup               '  -4   once

                shl     scan, #1
                cmpsub  scan, #|< 6 -1 wc       ' wrap around (64 -> 1)
                
                mov     dirx, #0                ' |
                mov     outx, pmsk              ' default off (preset pad scanner)
                
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


                waitcnt cnt, time

                mov     dira, #0                ' avoid ghosting
                mov     outa, outx              ' |
                mov     dira, dirx              ' apply new setting

' scan touch pads (if pmsk <> 0)

                add     icnt, #1
                cmpsub  icnt, #PAD_DCHG wc,wz
        if_nc   jmp     %%0                     ' neither charge nor sample
        
        if_nz   or      dira, pmsk              ' charge pads
        if_z    mov     ptmp, ina               '  ...  sample pins
        if_nz   andn    dira, pmsk              ' discharge period starts now
        if_nz   jmp     %%0                     ' continue

' ptmp holds the pin pattern after discharge period

                mov     icnt, #PAD_DCHG         ' reset charge trigger
                and     pads, ptmp              ' collect sample                        (##)
                djnz    ocnt, %%0               ' continue

                and     pads, pmsk              ' only pad pins are of interest
                xor     pads, pmsk              ' active high
                wrlong  pads, padr              ' announce current pad state

                mov     ocnt, #PAD_DCNT         ' reset sample count
                neg     pads, #1                ' reset accumulator                     (##)

                jmp     %%0                     ' ... and again
                
' initialised data and/or presets

scan            long    |< 5                    ' bitmap scanner (1st action is reset)

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

padr            long    +4                      ' pad address

pads            long    -1                      ' sample accumulator                    (##)
pmsk            long    PAD_MASK                ' dis/charge pins
icnt            long    PAD_DCHG                ' discharge time
ocnt            long    PAD_DCNT                ' /idle/ sample count (to register OFF)

' Stuff below is re-purposed for temporary storage.

setup           rdlong  time, #0                '  +0 = clkfreq                         (%%)
                shr     time, #11               '  +8   clkfreq / 2048

                add     padr, par               ' finalize local copy

                mov     cnt, #5{14} + 88 + 4
                add     cnt, cnt                ' first target

                jmp     %%0                     ' ret

EOD{ata}        fit
                
' uninitialised data and/or temporaries

                org     setup

time            res     1                       ' rate control          < setup +1      (%%)
bmap            res     1                       ' LED pattern

dirx            res     1                       ' |
outx            res     1                       ' IO under construction

ptmp            res     1                       ' pad sample after discharge period

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


  PAD_MASK      = PAD_P0|PAD_P1|PAD_P2|PAD_P3|PAD_P4|PAD_P5|PAD_P6

  PAD_DCHG      = 8                             ' discharge time (n/2K, about 4ms)
  PAD_DCNT      = 16                            ' /idle/ sample count

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
