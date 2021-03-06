''
''        Author: Marko Lukat
'' Last modified: 2016/01/24
''       Version: 0.4
''
'' 20160124: first working version
''
PUB null
'' This is not a top level object.

PUB init(ID{ignored}, mailbox)

  ifnot result := cognew(@driver, mailbox) +1
    abort

CON
'   cmd[8..0]: cog entry address
'     cmd[12]: command has(1) no(0) arguments
' cmd[15..13]: number of arguments -1

  cmd_clip      = %011_1 << 12|$00A
  cmd_blit      = %101_1 << 12|$017

DAT             org     0                       ' graphics driver

driver          jmpret  $, #setup

{done}          wrlong  zero, par
{idle}          rdlong  code, par wz
                test    code, argn wc           ' check for arguments
        if_z    jmp     #$-2

                mov     addr, code              ' args:n:[!Z]:cmd = 16:4:3:9
                ror     addr, #16               ' extract argument location
        if_c    call    #args                   ' fetch arguments
        if_c    addx    addr, #3                ' advance beyond last argument
                jmp     code                    ' execute function

' #### SET CLIP RECTANGLE
' ------------------------------------------------------
' parameters:   arg0: x1
'               arg1: y1 inclusive
'               arg2: x2
'               arg3: y2 exclusive

setclip         mov     c_x1, arg0              ' copy and sanity check
                mins    c_x1, #0
                maxs    c_x1, #res_x

                mov     c_y1, arg1
                mins    c_y1, #0
                maxs    c_y1, #res_y

                mov     c_x2, arg2
                mins    c_x2, #0
                maxs    c_x2, #res_x

                mov     c_y2, arg3
                mins    c_y2, #0
                maxs    c_y2, #res_y

                jmp     %%0                     ' return

' #### BLIT SPRITE
' ------------------------------------------------------
' parameters:   arg0: dst buffer (word aligned) or NULL
'               arg1: src buffer (word aligned) + header
'               arg2: x
'               arg3: y
'               arg4: frame index
'               arg5: mask or NULL

blit            cmp     arg0, #0 wz
        if_e    rdword  arg0, surface           ' draw surface

' The header is located before the buffer data (negative offsets).
' Fetch everything necessary.

                mov     wb, #15                 ' prepare alignment             (==)

                sub     arg1, #6                ' access to header
                rdword  arg6, arg1              ' frame size in bytes
                add     arg1, #2

                neg     xs, arg2                ' xs := -x                      (%%)
                rdword  ws, arg1                ' logical frame width
                add     arg1, #2

                neg     ys, arg3                ' ys := -y                      (##)
                rdword  hs, arg1                ' logical frame height
                add     arg1, #2

                add     wb, ws                  ' take a copy for final drawing (==)
                andn    wb, #15                 ' align to 16n                  (==)
                shr     wb, #3                  ' byte count (8 px/byte)

{multiply?}     tjz     arg4, #blit_cy

                shl     arg6, #8 -1             ' align operand for 16x8bit

                shr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc           ' 16x4bit, precision: 8

                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg6 wc           ' 16x4bit, precision: 8

                cmp     arg5, #0 wz
        if_ne   add     arg5, arg4              ' |
                add     arg1, arg4              ' apply offset

' Do all the necessary vertical clipping.

blit_cy         add     hs, arg3                ' lower edge
                maxs    hs, c_y2                ' min(lower edge, c_y2)
                mins    arg3, c_y1              ' max(y, c_y1)

                cmps    hs, arg3 wz,wc,wr       ' if lower edge =< y
        if_be   jmp     %%0                     '   early exit

{multiply?}     add     ys, arg3 wz             ' ys == 0|c_y1 - y              (##)
        if_z    jmp     #blit_cx

' An offset into the source buffer needs to be applied. The following
' code performs ys *= wb. The range of ys is configurable during core
' initialisation (4/8/12/16bit).

blit_s          shl     wb, #16{bit} -1         ' align operand for 16xNbit
blit_m          jmpret  $, #$+1 wc,nr           ' clear carry

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16/12

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16/12/8

                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc
                rcr     ys, #1 wc
        if_c    add     ys, wb wc               ' 16x4bit, precision: 16/12/8/4

                shr     wb, blit_s              ' restore width

' Do all the necessary horizontal clipping.

blit_cx         add     ws, arg2                ' right edge
                maxs    ws, c_x2                ' min(right edge, c_x2)
                mins    arg2, c_x1              ' max(x, c_x1)

                cmps    ws, arg2 wz,wc,wr       ' if x => right edge
        if_be   jmp     %%0                     '   early exit

                add     xs, arg2                ' xs == 0|c_x1 - x              (%%)

' dst += (y * 128 + x) / 8 (byte address)

                shl     arg3, #4                ' *16
                add     arg0, arg3
                
                ror     arg2, #3                ' /8
                add     arg0, arg2
                
                shr     arg2, #29 wc            ' |                                     rol ???, #3
                muxc    arg2, #%1000            ' bit index in word (0..15)             and ???, #%1111

' src += ys * wb + xs / 8 (byte address)

                ror     xs, #3                  ' /8
                add     arg1, ys{*wb}           ' |
                add     arg1, xs                ' apply to source

                cmp     arg5, #0 wz
        if_ne   add     arg5, ys{*wb}           ' |
        if_ne   add     arg5, xs                ' apply to mask

                muxnz   mskA, #2                ' 0/2
                muxnz   mskS, wb                ' 0/wb
        if_e    movd    arg5, #%00_1000_000     ' fake mask location (all bits)

                shr     xs, #29 wc              ' |                                     rol ???, #3
                muxc    xs, #%1000 wz           ' bit index in word (0..15)     (&&)    and ???, #%1111 wz
                muxz    :jump, #%11             ' select hblit function

' calculate clipping mask update based on length overhead (if zero then carry clear)

                add     ws, xs                  ' avoid calculating (16 - xs)
        if_nz   cmp     ws, #16 +1 wc           ' all columns from same word    (&&)
        if_nz   muxc    :jump, #%01             ' outa vs outb                  (&&)

                mov     arg3, ws
        if_c    sub     arg3, xs                ' all columns from same word
                and     arg3, #%1111

                neg     clip, #1
                shl     clip, arg3              ' create tail window

                mov     arg3, arg2
        if_a    sub     arg3, xs                '                               (&&)
        if_a    and     arg3, #%1111            '                               (&&)
                shl     clip, arg3              ' now aligned with dst

' arg0: r/u c   dst  byte address (xxword OK)
' arg1: r/u c   src  byte address (xxword OK)
' arg5: r/u c   mask byte address (xxword OK)
' arg2: r/o c   dst bit index
'   xs: r/o     src bit index
'   ws: r/o c   bit width
'   hs: r/u     row count
'   wb: r/o     source width in bytes (row advance)
'
' arg3: r/w     temporary
' arg4: r/w     temporary

:loop           mov     dstT, arg0              ' |
                mov     srcT, arg1              ' |
                mov     mskT, arg5              ' |
                mov     arg3, arg2              ' |
                mov     arg4, ws                ' working copy

:jump           jmpret  link, func              ' hblit

                add     arg0, #128/8            ' |
                add     arg1, wb                ' |
                add     arg5, mskS{tride}       ' advance

                djnz    hs, #:loop              ' for all rows

                jmp     %%0                     ' return


fn_01           rdword  dstL, dstT              '  +0 =
                add     dstT, #2                '  +8
                cmp     arg4, #16 wz,wc         '  -4   check column count
                rdword  dstH, dstT              '  +0 =
                shl     dstH, #16               '  +8
                or      dstL, dstH              '  -4   extract 32 dst pixel

                rdword  mskW, mskT              '  +0 = extract 16 mask bits
                shr     mskW, xs                '  +8   xs <> 0, mskT advance n/a
                shl     mskW, arg3              '  -4   align with dst

                rdword  srcW, srcT              '  +0 = extract 16 src pixel
                shr     srcW, xs                '  +8   xs <> 0, srcT advance n/a
                shl     srcW, arg3              '  -4   align with dst

        if_b    andn    mskW, clip              '  +0 = apply patch for columns
        
                and     srcW, mskW              '  +4   clear transparent pixels
                andn    dstL, mskW              '  +8   make space for src
                or      dstL, srcW              '  -4   combine dst/src

                shr     mskW, #16 wz            '  +0 = check for high word change
                muxnz   :p11, mskF              '  +4   if_be/if_never
                cmp     arg4, #16 wz,wc         '  +8   check column count (restore flags)

                sub     dstT, #2                '  -4   rewind
                wrword  dstL, dstT              '  +0 = update low word
                shr     dstL, #16               '  +8   dstL := dstH
                add     dstT, #2                '  -4   advance (again)
:p11    if_be   wrword  dstL, dstT              '  +0 = update high word

                jmp     link                    '       return


fn_00           rdword  dstL, dstT              '  +0 =
                add     dstT, #2                '  +8
                sub     arg4, #16               '  -4   update column count
                rdword  dstH, dstT              '  +0 =
                shl     dstH, #16               '  +8
                or      dstL, dstH              '  -4   extract 32 dst pixel

                rdword  mskW, mskT              '  +0 = extract 16 mask bits
                add     mskT, mskA{dvance}      '  +8   0/2
                shr     mskW, xs                '  -4   xs <> 0

                rdword  srcW, srcT              '  +0 = extract 16 src pixel
                add     srcT, #2                '  +8
                shr     srcW, xs                '  -4   xs <> 0

                shl     srcW, arg3              '  +0 = |
                shl     mskW, arg3              '  +4   align with dst

                and     srcW, mskW              '  +8   clear transparent pixels
                andn    dstL, mskW              '  -4   make space for src
                or      dstL, srcW              '  +0 = combine dst/src

                shr     mskW, #16 wz            '  +4   check for high word change
                muxnz   fn_11_exit, mskF        '  +8   if_be/if_never

                sub     arg3, xs wc             '  -4
                and     arg3, #%1111            '  +0 = adjust dst bit index
        if_nc   jmp     #fn_11_tail wz          '  +4   business as usual (flags: above)

                cmp     arg4, #16 wz,wc         '  +8   check column count
                jmp     #fn_11_next             '  -4   gap in dstL


fn_11           rdword  dstL, dstT              '  +0 =
fn_11_loop      add     dstT, #2                '  +8
                cmp     arg4, #16 wz,wc         '  -4   check column count
                rdword  dstH, dstT              '  +0 =
                shl     dstH, #16               '  +8
                or      dstL, dstH              '  -4   extract 32 dst pixel

fn_11_next      rdword  mskW, mskT              '  +0 = extract 16 mask bits
                add     mskT, mskA{dvance}      '  +8   0/2
                shl     mskW, arg3              '  -4   align with dst

                rdword  srcW, srcT              '  +0 = extract 16 src pixel
                add     srcT, #2                '  +8
                shl     srcW, arg3              '  -4   align with dst

        if_b    andn    mskW, clip              '  +0 = apply patch for columns < 16

                and     srcW, mskW              '  +4   clear transparent pixels
                andn    dstL, mskW              '  +8   make space for src
                or      dstL, srcW              '  -4   combine dst/src

                shr     mskW, #16 wz            '  +0 = check for high word change
                muxnz   fn_11_exit, mskF        '  +4   if_be/if_never
                sub     arg4, #16 wz,wc         '  +8   update column count (restore flags)

fn_11_tail      sub     dstT, #2                '  -4   rewind
                wrword  dstL, dstT              '  +0 = update low word
                shr     dstL, #16               '  +8   dstL := dstH
                add     dstT, #2                '  -4   advance (again)
fn_11_exit      wrword  dstL, dstT              '  +0 = update high word (exit path, optional)
        if_a    jmp     #fn_11_loop             '       for all columns

                jmp     link                    '       return

' support code (fetch up to 8 arguments)

args            rdlong  arg0, addr              ' read 1st argument
                cmpsub  addr, delta wc          ' [increment address and] check exit
        if_nc   jmpret  zero, args_ret wc,nr    ' cond: early return

                rdlong  arg1, addr              ' read 2nd argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg2, addr              ' read 3rd argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg3, addr              ' read 4th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg4, addr              ' read 5th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg5, addr              ' read 6th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg6, addr              ' read 7th argument
                cmpsub  addr, delta wc
        if_nc   jmpret  zero, args_ret wc,nr

                rdlong  arg7, addr              ' read 8th argument
'               cmpsub  addr, delta wc
'       if_nc   jmpret  zero, args_ret wc,nr

args_ret        ret

' initialised data and/or presets

surface         long    +4                      ' draw surface location

c_x1            long    0
c_y1            long    0
c_x2            long    res_x
c_y2            long    res_y

delta           long    %001_0 << 28 | $FFFC    ' %10 deal with movi setup
                                                ' -(-4) address increment
argn            long    |< 12                   ' function does have arguments

mskA            long    0{/2}                   ' mask transfer advance
mskS            long    0{/wb}                  ' mask stride
mskF            long    %1110 << 18             ' if_be (c|z)

' Stuff below is re-purposed for temporary storage.

setup           add     surface, par            ' draw surface location

                rdlong  arg0, surface
                shr     arg0, #24 -2
                and     arg0, #%1100            ' 0/4/8/12

                add     blit_m, arg0            ' |
                add     blit_m, arg0            ' adjust jump
                sub     blit_s, arg0            ' adjust pre-shift

                movs    func+%00, #fn_00        ' |
                movs    func+%01, #fn_01        ' |
                movs    func+%11, #fn_11        ' hblit function setup

                jmp     %%0                     ' return

EOD{ata}        fit

' uninitialised data and/or temporaries

                org     setup

arg0            res     1                       ' |
arg1            res     1                       ' |
arg2            res     1                       ' |
arg3            res     1                       ' |
arg4            res     1                       ' |
arg5            res     1                       ' |
arg6            res     1                       ' |                
arg7            res     1                       ' command arguments

addr            res     1                       ' parameter pointer   
code            res     1                       ' function entry point
link            res     1                       ' return address

reuse           res     alias

xs              res     1
ys              res     1
ws              res     1
hs              res     1

wb              res     1
clip            res     1

dstT{ransfer}   res     1
srcT{ransfer}   res     1
mskT{ransfer}   res     1

dstH{igh}       res     1
dstL{ow}        res     1
srcW{ord}       res     1
mskW{ord}       res     1

tail            fit

' aliases (different functions may share VAR space)

                org     reuse

                fit     tail
                
CON
  zero          = $1F0                          ' par (dst only)
  func          = $1F4                          ' outa
  
  res_x         = 128                           ' |
  res_y         = 64                            ' |
  res_m         = 2                             ' UI support
  res_a         = 8                             ' max command arguments

  alias         = 0

DAT