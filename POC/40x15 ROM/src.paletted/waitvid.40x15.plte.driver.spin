''
'' VGA display 40x15 (single cog, ROM font, palette) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2017/12/05
''       Version: 0.6.pal.13
''
'' long[par][0]:   screen:   [!Z]:addr =   16:16 -> zero (accepted), 2n
'' long[par][1]: pal/user: u:[!Z]:addr = 1:15:16 -> zero (accepted), 2n/4n
'' long[par][2]:   colour:   [!Z]:addr =   16:16 -> zero (accepted), 2n
'' long[par][3]: frame indicator, lock target and vcfg on startup (16:7:9)
''
'' The pal/user parameter is encoded as follows:
''  %0--//--- palette address if not zero
''  %1--//--- custom character base address
''
'' 20131001: initial version (640x480@60Hz timing, %11 sync locked)
'' 20131004: now uses palette (4/4 split)
'' 20131019: shortened palette code (loop), characters 0..31 can be customised
'' 20131020: simplified palette loader even further
'' 20131025: allow for startup vgrp/vpin configuration
'' 20171205: added multi screen sync capability
''
OBJ
  system: "core.con.system"

PUB null
'' This is not a top level object.
  
PUB init(ID, mailbox)

  return system.launch(ID, @driver, mailbox)
  
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

' horizontal timing 640(640)  1(16) 6(96)  3(48)
'   vertical timing 480(480) 10(10) 2(2)  33(33)

vsync           rdlong  plte, plte_ wz          ' fetch pending updates
        if_nz   wrlong  zero, plte_             ' acknowledge palette/character base address

                mov     ecnt, #10
                call    #blank                  ' front porch
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' active
                                                '                       mov     ecnt, #2  
                call    #blank                  ' |                     call    #blank    
                call    #blank                  ' vertical sync         djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

' Start fetch during last 32 blank lines.

                call    #blank                  ' back porch (1st line)

                mov     eins, scrn              ' screen base address
                mov     vier, indx              ' colour buffer
                mov     drei, #res_y            ' max visible scanlines

                mov     scnt, #33 -1            ' scnt controls fetch (32..1)
                call    #blank                  ' back porch
                djnz    scnt, #$-1

' Vertical sync chain done, do visible area.

line            mov     frqb, #0 wc             ' initial font row index
                mov     scnt, #32               ' font size
                max     scnt, drei              ' limit against what's left
                sub     drei, scnt              ' update what's left

scan            waitcnt cnt, #0                 ' re-sync after back porch              (##)

                mov     outa, idle              ' take over sync lines
vcfg_norm       xor     vcfg, #0-0              ' disconnect from video h/w             (&&)

                jmpret  hsync_ret, #emit        ' display scanline
                
                add     frqb, #2                ' next row in character definition(s)
                djnz    scnt, #scan             ' repeat for font size
                tjnz    drei, #line             ' repeat for all rows

                wrlong  cnt, fcnt_              ' announce vertical blank

                jmp     #vsync                  ' next frame


blank           mov     vscl, dark              ' 256/640
                waitvid sync, #%%000            ' latch blank line

                call    #palette                ' override current palette
                
hsync           mov     vscl, wrap              ' horizontal sync
                waitvid sync, wrap_value

vcfg_sync       movs    vcfg, #%0_00000011      ' drive sync lines                      (&&)
                mov     outa, #0                ' stop interfering

                mov     cnt, cnt                ' record sync point                     (##)
                add     cnt, #9{14}+412           

                call    #fetch
hsync_ret
blank_ret       ret


emit            mov     vscl, hvis              ' 1/16
                mov     ecnt, #40               ' character count

        if_nc   xor     $+2, #addr^(addr+40)    ' address array |
        if_nc   xor     $+2, #cols^(cols+40)    ' colour array  | primary <> secondary

                movs    :one, #addr             ' |
                movd    :two, #cols             ' reset
                
:one            mov     phsb, addr              ' character pixmap address
                rdlong  temp, phsb              ' read from address + 2frqb (row adjustment)
:two            waitvid cols, temp                

                add     :one, #1                ' next address |
                add     :two, dst1              ' next colour  | cog array

                djnz    ecnt, #:one             ' next 16px
    
{emit_ret}      jmpret  zero, #hsync wc,nr      ' set carry


fetch           cmp     drei, #0 wz             ' enabled?
        if_e    jmp     fetch_ret

                cmp     scnt, #21 wz,wc         ' 21..32
        if_ae   jmp     #f_21                   ' re-initialise sequence

                call    #ascii
                call    #ascii
                
fetch_ret       jmpret  zero, #0-0 wc,nr        ' set carry


f_21    if_e    xor     $+2, #addr^(addr+40)    ' |
        if_e    xor     $+2, #cols^(cols+40)    ' swap buffers

        if_e    movd    f_00, #addr             ' |
        if_e    movd    f_01, #cols             ' preset filler code
                jmpret  zero, fetch_ret wc,nr   ' set carry


ascii           rdbyte  temp, vier              ' fetch colour index
                ror     temp, #4                ' extract foreground
                add     temp, #ntry             ' apply table offset

                movs    f_fg, temp              ' inject address
                shr     temp, #28               ' extract background
                add     temp, #ntry +16         ' apply table offset
                movs    f_bg, temp              ' inject address
                
                rdbyte  temp, eins              ' fetch character
                add     eins, #1                ' advance address

                shr     temp, #1 wc             ' even/odd
                testn   temp, #32/2 -1 wz       ' 0..31 are custom characters
        if_nz   or      temp, #%1_00000000      ' ROM base address
                shl     temp, #7                ' final location
        if_z    add     temp, user              ' custom character base address

f_00            mov     0-0, temp
                add     $-1, dst1

f_fg            mov     zwei, 0-0               ' read foreground
                shl     zwei, #8                ' slot 1
f_bg            or      zwei, 0-0               ' read background
                add     vier, #1                ' advance address

                mov     temp, zwei              ' $0000BBAA     
        if_c    shr     temp, #8
                shl     temp, #16               ' $BBAA0000/$00BB0000
                or      temp, zwei              ' $BBAABBAA/$00BBBBAA

        if_c    shl     temp, #8                ' $BBBBAA00
        if_c    and     zwei, #$FF
        if_c    or      temp, zwei              ' $BBBBAAAA
                
f_01            mov     0-0, temp
                add     $-1, dst1

ascii_ret       ret


palette         cmps    plte, #0 wz,wc          ' pending?
        if_b    mov     user, plte              ' new custom character base address
        if_be   jmp     palette_ret             ' no update required

                mov     frqb, plte              ' base address
                shr     frqb, #1{/2}            ' added twice

                rdbyte  ntry, plte              ' process index 0

                movd    :one, #ntry +31         ' p/reset
                mov     phsb, #31               ' last index first

:one            rdbyte  0-0, phsb               ' load palette entry
                sub     $-1, dst1               ' advance address
                djnz    phsb, #:one             ' process index 31..1

                mov     plte, #0                ' done
palette_ret     ret

' initialised data and/or presets

idle            long    hv_idle
sync            long    hv_idle ^ $0200

frqx            long    $1423D70A               ' 25.175MHz
                        
wrap_value      long    %%0001111110            ' horizontal sync pulse (1/6/3 reverse)
wrap            long    16 << 12 | 160          '  16/160
hvis            long     1 << 12 | 16           '   1/16
dark            long     0 << 12 | 640          ' 256/640

scrn_           long    +0                      ' |
plte_           long    +4                      ' |
indx_           long    +8                      ' |
fcnt_           long    12                      ' mailbox addresses (local copy)

user            long    $8000                   ' default to ROM font

drei            long    0                       ' no fetch on startup
dst1            long    1 << 9                  ' dst +/-= 1

ntry            long    (dcolour >>  8)[16]     ' foreground
                long    (dcolour & $FF)[16]     ' background
                
' Stuff below is re-purposed for temporary storage.

setup           rdlong  cnt, #0                 ' clkfreq

                add     scrn_, par              ' @long[par][0]
                add     plte_, par              ' @long[par][1]
                add     indx_, par              ' @long[par][2]
                add     fcnt_, par              ' @long[par][3]
                add     lock_, par              ' @word[par][7]

                rdlong  scrn, scrn_ wz          ' get screen address                    (%%)
        if_nz   wrlong  zero, scrn_             ' acknowledge screen buffer setup

                rdlong  indx, indx_ wz          ' get font colour                       (%%)
        if_nz   wrlong  zero, indx_             ' acknowledge font colour

' Upset video h/w and relatives.

                rdword  cnfg, fcnt_             ' vgrp/vpin (keep out of {sync})
                rdword  temp, lock_ wz          ' sync required?                        (%%)
        if_nz   shl     temp, #16               ' |
{sync}  if_nz   waitcnt temp, #0                ' yes
{ \/ }
                movi    ctrb, #%0_11111_000     ' LOGIC always (loader support)
                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                mov     frqa, frqx              ' 25.175MHz
                
                mov     vscl, #1                ' reload as fast as possible
                mov     vcfg, cnfg              ' vgrp/vpin
                movi    vcfg, #%0_01_1_00_000   ' VGA, 4 colour mode

                shr     cnt, #10                ' ~1ms
{ /\ }          add     cnt, cnt                ' from now
{sync}          waitcnt cnt, #0                 ' PLL settled, frame counter flushed

                ror     vcfg, #1                ' freeze video h/w
                mov     vscl, dark              ' transfer user value
                rol     vcfg, #1                ' unfreeze
                waitpne $, #0                   ' get some distance
                waitvid zero, #0                ' latch user value

                movs    vcfg_norm, vcfg         ' record xor mask

                and     mask, vcfg              ' transfer vpin
                mov     temp, vcfg              ' |
                shr     temp, #9                ' extract vgrp
                shl     temp, #3                ' 0..3 >> 0..24
                shl     mask, temp              ' finalise mask

                max     dira, mask              ' drive outputs

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return

lock_           long    +14                     ' @word[par][7]
mask            long    %111111_11              ' v/pin mask

                fit
                
' uninitialised data and/or temporaries

                org     setup

scrn            res     1                       ' screen buffer         < setup +6      (%%)
indx            res     1                       ' colour buffer         < setup +8      (%%)
plte            res     1                       ' user palette
cnfg            res     alias                   ' vcfg: vgrp/vpin
ecnt            res     1                       ' element count
scnt            res     1                       ' scanlines (per char)
temp            res     1                       '                       < setup +11     (%%)

eins            res     1
zwei            res     1
vier            res     1

addr            res     40 *2
cols            res     40 *2

tail            fit
                
CON
  zero    = $1F0                                ' par (dst only)
  hv_idle = $01010101 * %11 {%hv}               ' h/v sync inactive
  dcolour = %%0220_0010                         ' default colour
  
  res_x   = 640                                 ' |
  res_y   = 480                                 ' |
  res_m   = 4                                   ' UI support

  alias   = 0
  
DAT
