CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
  serial: "FullDuplexSerial"

VAR
  long  storage[5]
  
PUB null

' serial.start(31, 30, %0000, 115200)
  waitcnt(clkfreq*3 + cnt)
  
  repeat 6
    cognew(@entry, @storage)
{
  repeat
    repeat until storage{0}
    serial.hex(storage{0}, 8)
    serial.tx(32)
    serial.hex(storage[1], 8)
    serial.tx(32)
    serial.hex(storage[2]-storage[1], 8)
    serial.tx(32)
    serial.hex(storage[3]-storage[2], 8)
    serial.tx(32)
    serial.hex(storage[4]-storage[3], 8)
    serial.tx(13)
    storage{0} := 0
    waitcnt(clkfreq + cnt)
}   
DAT             org     0
{                                         v             v           v           v                 v       v
        |------|R-----------------|------|------------------|------|------------------|------|------------------|------|
        |------|R----------------|------|------------------|------|------------------|------|------------------|------|
        |------|R-----------------|------|-----------------|------|------------------|------|------------------|------|
        |------|R----------------|------|-----------------|------|------------------|------|------------------|------|
        |------|R-----------------|------|------------------|------|-----------------|------|------------------|------|
        |------|R----------------|------|------------------|------|-----------------|------|------------------|------|
        |------|R-----------------|------|-----------------|------|-----------------|------|------------------|------|
        |------|R----------------|------|-----------------|------|-----------------|------|------------------|------|
        |------|R-----------------|------|------------------|------|------------------|------|-----------------|------|
        |------|R----------------|------|------------------|------|------------------|------|-----------------|------|
        |------|R-----------------|------|-----------------|------|------------------|------|-----------------|------|
        |------|R----------------|------|-----------------|------|------------------|------|-----------------|------|
        |------|R-----------------|------|------------------|------|-----------------|------|-----------------|------|
        |------|R----------------|------|------------------|------|-----------------|------|-----------------|------|
        |------|R-----------------|------|-----------------|------|-----------------|------|-----------------|------|
        |------|R----------------|------|-----------------|------|-----------------|------|-----------------|------|
  ref     M-------=0======M-------========|-------========N-------========N-------========N-------========            #
                    1                      |-------========N-------========N-------========N-------========           #
                     2                      |-------========N-------========N-------========N-------========          /
                      3                      |-------========N-------========N-------========N-------========         /
                       4                      |-------========N-------========N-------========N-------========        /
                        5                      |-------========N-------========N-------========N-------========       /
                                                |-------========N-------========N-------========N-------========      #
                                                 |-------========N-------========N-------========N-------========     #
                                                  N-------========N-------========N-------========|-------========    #
                                                   N-------========N-------========N-------========|-------========   #
                                                    N-------========|-------========N-------========N-------========  ?
                                                     N-------========|-------========N-------========N-------======== ?
                                                      N-------========|-------========N-------========N-------======= ?
                                                       N-------========|-------========N-------========N-------====== ?
                                                        N-------========|-------========N-------========N-------===== ?
         M-------========M-------========M-------========N-------========|-------========N-------========N-------==== ?
}

entry           long    3, 3, 3 ,3 ,3 ,3, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2
                long    3, 3, 3 ,3 ,3 ,3, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2

                cogid   $ nr
                neg     temp, cnt
                add     temp, #3+15
                and     temp, #%1111

                add     copy, temp              ' apply offset
                mov     temp, #16

copy            mov     entry, entry
                add     $-1, d1s1
                djnz    temp, #copy

                
                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 25.175MHz

                mov     vscl, hvis              ' 2/8
                movi    vcfg, #%0_01_1_00_000   ' VGA, 4 colour mode

                rdlong  cnt, #0
                shr     cnt, #10
                add     cnt, cnt
                waitcnt cnt, #0                 ' stabilize PLL
                
                mov     dira, mask
                movi    outa, #1
                
                waitvid zero, #0
loop            waitvid zero, #0                ' 0
                neg     ccnt, cnt
'-----------------------------------------------
                waitvid zero, #0                ' 1
                movd    $+3, cnt
                andn    $+2, vmsk
                add     addr, #4                '       advance address for next load
                shr     0-0, #1 wz,wc,nr        '       set flags
                waitvid zero, #0                ' 2
  if_nz_and_nc  rdlong  temp, addr      {%10}
                waitvid zero, #0                ' 3
  if_nz_and_c   rdlong  temp, addr      {%11}
                waitvid zero, #0                ' 4
  if_z_and_nc   rdlong  temp, addr      {%00}
'-----------------------------------------------
                waitvid zero, #0                ' 5
                waitvid zero, #0                ' 6th interval
                add     ccnt, cnt
                cmp     ccnt, #6*26 wc,wz
        if_a    hubop   $, #%10000_000          ' upper limit exceeded
                waitvid zero, #0
                waitvid zero, #0
                jmp     #loop
                
'vmsk           long    %111110000 << 9
frqx            long    $1423D70A
hvis            long    2 << 12 | 8
mask            long    $00FF0000
d1s1            long    1 << 9 | 1

temp            res     1
ccnt            res     1
'addr           res     1

                fit
                
DAT

secondary       waitvid vier, #%%3210
                rdlong  temp, addr

primary         waitvid one+$04, #%%3210        ' in place      E
                mov     two+$00, temp           '               T
                mov     zwei, one+$01           '               B
                mov     drei, one+$02           '               C
                mov     vier, one+$03           '               D
                waitvid one+$00, #%%3210        ' in place      A
                movs    $+3, cnt
                andn    $+2, #%111110000
                add     addr, #4                ' advance address for next load
                jmp     0-0                     ' select target

_1st            waitvid zwei, #%%3210
                rdlong  temp, addr
                waitvid drei, #%%3210
                add     primary+5, dst5         ' A++
                add     primary+2, #1           ' B++
                add     primary+3, #1           ' C++
                add     primary+4, #1           ' D++
                waitvid vier, #%%3210
                add     primary+0, dst5         ' E++
                add     primary+1, dst1         ' T++
                djnz    ecnt, #primary
                waitvid one+$4A, #%%3210        ' emit one[74]
                jmp     splice

_2nd            waitvid zwei, #%%3210
                add     primary+5, dst5         ' A++
                add     primary+2, #1           ' B++
                add     primary+3, #1           ' C++
                add     primary+4, #1           ' D++
                waitvid drei, #%%3210
                rdlong  temp, addr
                waitvid vier, #%%3210
                add     primary+0, dst5         ' E++
                add     primary+1, dst1         ' T++
                djnz    ecnt, #primary
                waitvid one+$4A, #%%3210        ' emit one[74]
                jmp     splice

_3rd            waitvid zwei, #%%3210
                add     primary+5, dst5         ' A++
                add     primary+2, #1           ' B++
                add     primary+3, #1           ' C++
                add     primary+4, #1           ' D++
                waitvid drei, #%%3210
                add     primary+0, dst5         ' E++
                add     primary+1, dst1         ' T++
                djnz    ecnt, #secondary
                waitvid vier, #%%3210           ' emit one[73]
                rdlong  temp, addr
                waitvid one+$4A, #%%3210        ' emit one[74]
                jmp     splice

splice          long    common

common          mov     two+$0E, temp           ' last write
                nop
                nop
                waitvid one+$4B, #%%3210        ' emit one[75]
                nop
                nop
                nop
                nop
                waitvid one+$4C, #%%3210        ' emit one[76]
                nop
                nop
                nop
                nop
                waitvid one+$4D, #%%3210        ' emit one[77]
                nop
                nop
                nop
                nop
                waitvid one+$4E, #%%3210        ' emit one[78]
                nop
                nop
                nop
                nop
                waitvid one+$4F, #%%3210        ' emit one[79]
                nop
                nop
                nop
                nop

DAT

emit_0          waitvid one+$00, #%%3210        ' emit one[0..3], load two[0]
                movd    $+3, cnt
                andn    $+2, vmsk
                add     addr, #4                ' advance address for next load
                shr     0-0, #1 wz,wc,nr        ' set flags
                waitvid one+$01, #%%3210
  if_nz_and_nc  rdlong  two+$00, addr
                waitvid one+$02, #%%3210
  if_nz_and_c   rdlong  two+$00, addr
                waitvid one+$03, #%%3210
  if_z_and_nc   rdlong  two+$00, addr

                waitvid one+$04, #%%3210        ' emit one[4..7], load two[1]
                movd    $+3, cnt
                andn    $+2, vmsk
                add     addr, #4                ' advance address for next load
                shr     0-0, #1 wz,wc,nr        ' set flags
                waitvid one+$05, #%%3210
  if_nz_and_nc  rdlong  two+$01, addr
                waitvid one+$06, #%%3210
  if_nz_and_c   rdlong  two+$01, addr
                waitvid one+$07, #%%3210
  if_z_and_nc   rdlong  two+$01, addr

'               ...

                waitvid one+$4C, #%%3210        ' emit one[76..79], load two[19]
                movd    $+3, cnt
                andn    $+2, vmsk
                add     addr, #4                ' advance address for next load
                shr     0-0, #1 wz,wc,nr        ' set flags
                waitvid one+$4D, #%%3210
  if_nz_and_nc  rdlong  two+$13, addr
                waitvid one+$4E, #%%3210
  if_nz_and_c   rdlong  two+$13, addr
                waitvid one+$4F, #%%3210
'               update vscl
  if_z_and_nc   rdlong  two+$13, addr
                waitvid sync, #0


                mov     ecnt, #50/2

emit_1          waitvid one+$00, #%%3210        ' emit one[0..49], transfer two[0..49]
                add     $-1, dst2
                mov     one+$00, two+$00
                add     $-1, d2s2
                cmp     ecnt, #1 wz
                waitvid one+$01, #%%3210
                add     $-1, dst2
                mov     one+$01, two+$01
                add     $-1, d2s2
        if_ne   djnz    ecnt, #emit_1

                waitvid one+$32, #%%3210        ' emit one[50]
'               restore first loop setup
                waitvid one+$33, #%%3210        ' emit one[51]

                mov     ecnt, #27

emit_2          waitvid one+$34, #%%3210        ' emit one[52..78]
                add     $-1, dst1
                cmp     ecnt, #1 wz
        if_ne   djnz    ecnt, #emit_2
                movd    emit_2, #one+$34        ' restore

                waitvid one+$4F, #%%3210        ' emit one[79]
'               update vscl, maintenance
                waitvid sync, #0

                
vmsk            long    %111110000 << 9
dst1            long    1 << 9
dst2            long    2 << 9
dst5            long    5 << 9
d2s2            long    2 << 9 | 2

flags           long    %10                     ' zc
                long    %11                     ' zC
                long    %01                     ' ZC
                long    %00                     ' Zc
                
addr            res     1
ecnt            res     1
sync            res     1

zwei            res     1
drei            res     1
vier            res     1

one             res     80
two             res     50

                fit

DAT
{
        220 emit_0
        130 buffer
}
CON
  zero    = $1F0                                ' par (dst only)

DAT