''
'' LameGFX Fast Drawing Library
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2013-2014 LameStation LLC
'' See end of file for terms of use.
''
'' Authors: Brett Weir, Marko Lukat
'' -------------------------------------------------
'' This is a graphics library designed for use on the
'' LameStation portable gaming handheld. It is designed
'' to be straightforward to use and easy to set up.
''
'' Creating your first program is simple! First, include
'' the graphics object in an object block.
''
'' * **instruction** - send data to assembly cog
''
CON

    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2

    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE = SCREEN_W*SCREEN_H

    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    SCREENSIZE_BYTES_END = SCREENSIZE_BYTES-1

    ' text printing
    NL = 10
    LF = 13

'' This table
''
'' +------+-------+------+-------------+
'' | Flip | Color | Mask | Color       |
'' +------+-------+------+-------------+
'' |   0  |   0   |   0  | Black       |
'' +------+-------+------+-------------+
'' |   0  |   1   |   0  | White       |
'' +------+-------+------+-------------+
'' |   1  |   0   |   1  | Transparent |
'' +------+-------+------+-------------+
'' |   1  |   1   |   0  | Gray        |
'' +------+-------+------+-------------+
''
'' This operation is equivalent to `Mask = Flip & !Color`.
''
'' The color constant definitions here correspond to this.
''
    BLACK = 0
    WHITE = 1
    TRANSPARENT = 2
    GRAY = 3


    ' draw map function
    COLLIDEBIT = $80
    TILEBYTE = COLLIDEBIT-1


VAR
'' These longs make up the interface between Spin and
'' assembly.
'' They must apppear in this order.
'' ---------------------------------------------------
    long    instruction
    long    drawsurface
'' ---------------------------------------------------
    word    copysurface

    word    font
    byte    startingchar
    byte    tilesize_x
    byte    tilesize_y

VAR
    long    c_blitscreen, c_sprite, c_setcliprect, c_translate
    long    c_parameters[4]

PUB null
'' This is not a top level object.

PUB Start(buffer, screen)

    drawsurface := buffer
    copysurface := screen
    cognew(@graphicsdriver, @instruction)
'                                                 function has(1) no(0) argument(s) ----+
'                                                            number of arguments -1 --+ |
'                                                                                     | |
    c_blitscreen  := @c_parameters << 16 | (@blitscreen  - @graphicsdriver) >> 2 | %000_1 << 12
    c_sprite      := @c_parameters << 16 | (@drawsprite  - @graphicsdriver) >> 2 | %011_1 << 12
    c_setcliprect := @c_parameters << 16 | (@setcliprect - @graphicsdriver) >> 2 | %011_1 << 12
    c_translate   := @c_parameters << 16 | (@translate   - @graphicsdriver) >> 2 | %001_1 << 12

PUB WaitToDraw

    repeat
    while instruction

PUB ClearScreen
'' This command clears the screen to black. Recommended if your game
'' display is sparse and not likely to be overdrawn every frame (like
'' in a tile-based game).

    Blit(0)

PUB Blit(source)
'' This command blits a 128x64 size image to the screen. This command is
'' primarily influenced for reference on drawing to the screen, not for
'' its game utility so much.

    repeat
    while instruction

    c_parameters{0} := source
    instruction := c_blitscreen

PUB Box(source, x, y)
'' This function displays an 8x8 tile from an address. This address could
'' be a single image or it could be full tileset; the user is responsible
'' for structuring their data. However, take a look at some of the tile
'' functions to see how Box can be used to build larger functionality
'' like tile mapping.

    Sprite(source, x, y, 0)

PUB Sprite(source, x, y, frame)
'' * **source** - Memory address of the source image
'' * **x** - Horizontal destination position (0-15)
'' * **y** - Vertical destination position (0-7)
'' * **frame** - If the image has multiple frames, this integer will select which to use.
''
'' This function allows the user to blit an arbitrarily-sized image
'' from a memory address. It is designed to accept the sprite output from img2dat,
'' and can handle multi-frame sprites, 3-color sprites, and sprites with transparency.
''
'' Read more on img2dat to see how you can generate source images to use with this
'' drawing command.

    repeat
    while instruction

    longmove(@c_parameters{0}, @source, 4)
    instruction := c_sprite

' *********************************************************
'  Maps
' *********************************************************
VAR
    word    map_tilemap
    word    map_levelmap

PUB LoadMap(source_tilemap, source_levelmap)

    map_tilemap  := source_tilemap
    map_levelmap := source_levelmap

PUB TestMapCollision(objx, objy, objw, objh) | objtilex, objtiley, tile, tilecnt, tilecnttemp, x, y
'' Returns 1 if collision, 0 otherwise

    objx #>= 0
    objy #>= 0
    objtilex := objx >> 3
    objtiley := objy >> 3

    tilecnt := 0
    tilecnttemp := 2 + byte[map_levelmap]{0} * objtiley

    repeat y from objtiley to objtiley + (objh>>3)
        repeat x from objtilex to objtilex + (objw>>3)
            tilecnt := tilecnttemp + x
            if (byte[map_levelmap][tilecnt] & COLLIDEBIT)
                return 1
        tilecnttemp += byte[map_levelmap]{0}

PUB GetMapWidth

    return byte[map_levelmap]{0}

PUB GetMapHeight

    return byte[map_levelmap][1]

PUB DrawMap(offset_x, offset_y, box_x1, box_y1, box_x2, box_y2) | tile, tilecnt, tilecnttemp, x, y
'' This function uses the Box command to draw an array of tiles to the screen.
'' Used in conjunction with the map2dat program included with this kit, it is
'' an easy way to draw your first game world to the screen.
''
'' * **offset_x** -
'' * **offset_y** -
'' * **width** -
'' * **height** -
''

    SetClipRectangle(box_x1<<3, box_y1<<3, box_x2<<3, box_y2<<3)

    tilecnt := 0
    tilecnttemp := 2 + byte[map_levelmap]{0} * (offset_y>>3)

    repeat y from 0 to box_y2-box_y1
        repeat x from 0 to box_x2-box_x1
            tilecnt := tilecnttemp + (offset_x >> 3) + x
            tile := (byte[map_levelmap][tilecnt] & TILEBYTE) - 1
            if tile => 0
                 Sprite(map_tilemap, (box_x1<<3) + (x << 3) - (offset_x & $7), (box_y1<<3) + (y<<3) - (offset_y & $7),tile)

        tilecnttemp += byte[map_levelmap]{0}

    SetClipRectangle(0, 0, 128, 64)

' *********************************************************
'  Text
' *********************************************************
PUB LoadFont(sourcevar, startingcharvar, tilesize_xvar, tilesize_yvar)

    font := sourcevar
    startingchar := startingcharvar
    tilesize_x := tilesize_xvar
    tilesize_y := tilesize_yvar

PUB PutChar(char, x, y)

    Sprite(font, x, y, char - startingchar)

PUB PutString(stringvar, origin_x, origin_y)

    repeat strsize(stringvar)
        Sprite(font, origin_x, origin_y, byte[stringvar++] - startingchar)
        origin_x += tilesize_x

PUB TextBox(stringvar, origin_x, origin_y, w, h) | char, x, y

    x := origin_x
    y := origin_y

    repeat strsize(stringvar)
        char := byte[stringvar++]
        if char == NL or char == LF
            y += tilesize_y
            x := origin_x
        elseif char == " "
            x += tilesize_x
        else
            Sprite(font, x, y, char - startingchar)
            if x+tilesize_x => origin_x+w
                y += tilesize_y
                x := origin_x
            else
                x += tilesize_x

PUB SetClipRectangle(clipx1, clipy1, clipx2, clipy2)
'' Sets bounding box for tile/sprite drawing operations, to prevent overdraw.
'' Defaults to 0, 0, 128, 64. Use only multiples of 8.

    repeat
    while instruction

    longmove(@c_parameters{0}, @clipx1, 4)
    instruction := c_setcliprect

PUB TranslateBuffer(sourcebuffer, destbuffer)
'' This command used to convert a linear framebuffer to one formatted
'' for the KS0108 LCD memory map. After the transformation had been
'' moved to the LCD driver this call simply does a linear copy from
'' source buffer to destination buffer.

    repeat
    while instruction

    longmove(@c_parameters{0}, @sourcebuffer, 2)
    instruction := c_translate

PUB DrawScreen
'' Copy render buffer to screen buffer.

    TranslateBuffer(drawsurface, copysurface)

DAT                     org     0

graphicsdriver          jmpret  $, #setup

{done}                  wrlong  zero, par
{idle}                  rdlong  code, par wz
                        test    code, argn wc           ' check for arguments
                if_z    jmp     #$-2

                        mov     addr, code              ' args:n:[!Z]:cmd = 16:4:3:9
                        ror     addr, #16               ' extract argument location
                if_c    call    #args                   ' fetch arguments
'{n/a}          if_c    addx    addr, #3                ' advance beyond last argument
                        jmp     code                    ' execute function

' #### DRAW SPRITE
' ------------------------------------------------------
' parameters: arg0: source buffer (word aligned)
'             arg1: x
'             arg2: y
'             arg3: frame

drawsprite              rdword  scrn, destscrn          ' render buffer

                        rdword  arg4, arg0              ' frame size in bytes
                        add     arg0, #2

                        neg     xs, arg1                ' xs := -x
                        rdword  ws, arg0                ' frame width
                        add     arg0, #2

                        neg     ys, arg2                ' ys := -y
                        rdword  hs, arg0                ' frame height
                        add     arg0, #2

                        mov     wb, ws                  ' take a copy for final drawing
                        shr     wb, #2                  ' byte count (4 px/byte)

                        cmp     arg3, #0 wz             ' frame index
                if_nz   add     arg0, arg4              ' a proper multiply may be beneficial here
                if_nz   djnz    arg3, #$-1              ' depending on max framecount

blit_cy                 add     hs, arg2                ' lower edge                                                                                                                        
                        maxs    hs, _clipy2             ' min(lower edge, c_y2)             
                        mins    arg2, _clipy1           ' max(y, c_y1)                      
                                                                                            
                        cmps    hs, arg2 wz,wc,wr       ' if lower edge =< y                
                if_be   jmp     %%0                     '   early exit                      
                                                                                            
                        add     ys, arg2 wz {multiply?} ' ys == 0|c_y1 - y
                if_z    jmp     #blit_cx                                                    

'                       ys *= wb
                        hubop   $, #128

blit_cx                 add     ws, arg1                ' right edge                        
                        maxs    ws, _clipx2             ' min(right edge, c_x2)             
                        mins    arg1, _clipx1           ' max(x, c_x1)                      
                                                                                            
                        cmps    ws, arg1 wz,wc,wr       ' if x => right edge                
                if_be   jmp     %%0                     '   early exit                      
                                                                                            
                        add     xs, arg1                ' xs == 0|c_x1 - x

' dst += (y * 128 + x) / 4 (byte address)

                        shl     arg2, #5                ' *32                      
                        add     scrn, arg2                                         
                                                                                   
                        ror     arg1, #2                ' /4                       
                        add     scrn, arg1                                         
                                                                                   
                        shr     arg1, #29 wc            ' collect byte selector    
                        muxc    arg1, #%1000            ' bit index in word (0..14)

' src += ys * wb + xs / 4 (byte address)

                        add     arg0, ys                                                    
                        ror     xs, #2                  ' /4                                
                        add     arg0, xs                                                    
                                                                                            
                        shr     xs, #29 wc              ' collect byte selector             
                        muxc    xs, #%1000 wz           ' bit index in word (0..14)     (&&)

' preset transparency mask

                        mov     arg2, hAAAA0000         ' high word only      
                        sar     arg2, xs                ' plus non-zero offset
                        andn    arg2, h55555555         ' %11 -> %10          

                        shl     ws, #1                  ' bit width

' scrn: r/u c   dst byte address (xxword OK)
' arg0: r/u c   src byte address (xxword OK)
' arg1: r/o c   dst bit index
' arg2: r/o     source transparency mask (xs <> 0)
'   xs: r/o     src bit index
'   ws: r/o c   bit width
'   hs: r/u     row count
'   wb: r/o     source width in byte (row advance)

:loop                   mov     dstT, scrn              ' |           
                        mov     srcT, arg0              ' |           
                        mov     arg3, ws                ' working copy
                        mov     arg4, arg1                            

                        rdword  dstL, dstT
:xloop                  sub     arg3, #8*2 wz,wc
                        add     dstT, #2
                        rdword  dstH, dstT
                        shl     dstH, #16
                        or      dstL, dstH              ' extract 16 dst pixel

                        rdword  srcW, srcT              ' extract 8 src pixel
                        add     srcT, #2
                        shr     srcW, xs
                        or      srcW, arg2              ' fill remainder with transparency
                        rol     srcW, arg1              ' align with dst

                        mov     frqb, srcW              ' %10 is transparent
                        shr     frqb, #1
                        andn    frqb, srcW
                        and     frqb, h55555555         ' extract transparent pixel

                        mov     phsb, frqb
                        mov     frqb, phsb              ' frqb *= 3
                        nop
                        andn    srcW, frqb              ' clear transparent pixels
                        and     dstL, frqb              ' make space for src      
                        or      dstL, srcW              ' combine dst/src         

                        sub     dstT, #2                ' rewind
                        wrword  dstL, dstT

                        shr     dstL, #16               ' dstL := dstH
                        add     dstT, #2                ' advance (again)
                if_be   wrword  dstL, dstT
                if_a    jmp     #:xloop                 ' for all columns

                                                                      
                        add     scrn, #128/4            ' |           
                        add     arg0, wb                ' advance     
                                                                      
                        djnz    hs, #:loop              ' for all rows

                        wrlong  ws, $+1
                        long    $7FFC
                                                                      
                        jmp     %%0                     ' return      

' ======================
{
                        mov     iter_x, arg1            ' this value rotates the word for the blender
                        shl     iter_x, #1              ' x << 1
                        and     iter_x, #$F             ' x % 8

                        mov     iter_y, arg2            ' row index

                        shl     arg2, #5                ' y * 32
                        add     scrn, arg2              ' line start (inclusive)
                        mov     send, #32
                        add     send, scrn              ' line end (exclusive)

                        sar     arg1, #3                ' x /= 8, n pixels = 2n bits
                        shl     arg1, #1                ' back to byte offset
                        add     arg1, scrn              ' address ready, 2n

                        mov     arg2, _clipx1
                        shr     arg2, #3                ' word offset
                        shl     arg2, #1                ' back to byte offset
                        add     scrn, arg2              ' apply clipping, 2n

                        mov     arg2, #128
                        sub     arg2, _clipx2
                        shr     arg2, #3                ' word offset
                        shl     arg2, #1                ' back to byte offset
                        sub     send, arg2              ' apply clipping, 2n

                        shr     ws, #3                  ' 8 px/word

' arg0: src byte address (xxword OK)
' arg1: dst byte address (xxword OK)
'   ws: column (word) count
'   hs: row count
'   wb: source width in byte (row advance)

' ----- Y LOOP -----------------------------------------
:yloop                  cmps    iter_y, _clipy1 wc      ' ToDo: clipping belongs outside any loop
                if_c    jmp     #:skipall
                        cmps    iter_y, _clipy2 wc
                if_nc   jmp     %%0                     ' if greater equal _clipy2 just exit

                        mov     index_x, ws

                        mov     dstT, arg1
                        mov     srcT, arg0
' ----- X LOOP -----------------------------------------
                        rdword  dstL, dstT
:xloop                  add     dstT, #2
                        rdword  dstH, dstT
                        shl     dstH, #16
                        or      dstL, dstH              ' extract 16 dst pixel

                        rdword  srcW, srcT              ' extract 8 src pixel
                        add     srcT, #2
                        or      srcW, hAAAA0000         ' high word is always transparent
                        rol     srcW, iter_x            ' align with dst

                        mov     frqb, srcW              ' %10 is transparent
                        shr     frqb, #1
                        andn    frqb, srcW
                        and     frqb, h55555555         ' extract transparent pixel

                        mov     phsb, frqb
                        mov     frqb, phsb              ' frqb *= 3

                        cmp     dstT, scrn wz
                if_e    or      frqb, mskLH

                        cmp     dstT, send wz
                if_e    or      frqb, mskRH

                        add     dstT, #2
                        cmp     dstT, send wz
                if_e    or      frqb, mskRL
                        sub     dstT, #4                ' rewind
                        cmp     dstT, scrn wz
                if_e    or      frqb, mskLL
                
                        andn    srcW, frqb              ' clear transparent pixels
                        and     dstL, frqb              ' make space for src      
                        or      dstL, srcW              ' combine dst/src         

                        cmp     dstT, scrn wc
                if_c    jmp     #$+3
                        cmp     dstT, send wc
                if_c    wrword  dstL, dstT

                        shr     dstL, #16               ' dstL := dstH
                        add     dstT, #2                ' advance (again)

                        cmp     dstT, scrn wc
                if_c    jmp     #$+3
                        cmp     dstT, send wc
                if_c    wrword  dstL, dstT

                        djnz    index_x, #:xloop        ' for all columns
' ----- X LOOP END -------------------------------------
:skipall                add     scrn, #128/4            ' |
                        add     send, #128/4            ' |
                        add     arg1, #128/4            ' |
                        add     arg0, wb                ' advance
                        add     iter_y, #1              ' |

                        djnz    hs, #:yloop             ' for all rows
' ----- Y LOOP END -------------------------------------
}                       jmp     %%0                     ' return

' #### SET CLIP RECTANGLE
' ------------------------------------------------------
' parameters: arg0: x1
'             arg1: y1
'             arg2: x2
'             arg3: y2

setcliprect             mov     _clipx1, arg0           ' copy and sanity check
                        mins    _clipx1, #0
                        maxs    _clipx1, #res_x

                        mov     _clipy1, arg1
                        mins    _clipy1, #0
                        maxs    _clipy1, #res_y

                        mov     _clipx2, arg2
                        mins    _clipx2, #0
                        maxs    _clipx2, #res_x

                        mov     _clipy2, arg3
                        mins    _clipy2, #0
                        maxs    _clipy2, #res_y

                        test    $, #1 wc                ' set carry

                        mov     arg0, _clipx1           ' clipping masks
                        and     arg0, #%111
                        mov     mskLL, #0
                        rcl     mskLL, arg0
                        rcl     mskLL, arg0             ' %%00000000_0???????
                        mov     mskLH, mskLL
                        rcl     mskLH, #16              ' %%0???????_????????

                        neg     arg2, _clipx2
                        and     arg2, #%111
                        mov     mskRL, #0
                        rcr     mskRL, arg2
                        rcr     mskRL, arg2             ' %%???????0_00000000
                        mov     mskRH, mskRL
                        rcr     mskRH, #16              ' %%????????_???????0

                        jmp     %%0                     ' return

' #### CLEAR SCREEN
' ------------------------------------------------------
' parameters: none

clear                   mov     arg3, fullscreen

:loop                   wrword  zero, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

' #### BLIT SCREEN
' ------------------------------------------------------
' parameters: arg0: source buffer       (word aligned)
'             arg1: destination buffer  (word aligned)

blitscreen              rdword  arg1, destscrn          ' override destination
                        tjz     arg0, #clear            ' no source, clear screen
                        add     arg0, #6                ' skip sprite header

translate               mov     arg3, fullscreen        ' words per screen

:loop                   rdword  arg2, arg0
                        add     arg0, #2
                        wrword  arg2, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

' support code (fetch up to 4 arguments)

args                    rdlong  arg0, addr              ' read 1st argument
                        cmpsub  addr, delta wc          ' [increment address and] check exit
                if_nc   jmpret  zero, args_ret nr,wc    ' cond: early return

                        rdlong  arg1, addr              ' read 2nd argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret nr,wc

                        rdlong  arg2, addr              ' read 3rd argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret nr,wc

                        rdlong  arg3, addr              ' read 4th argument
'                       cmpsub  addr, delta wc
'               if_nc   jmpret  zero, args_ret nr,wc

args_ret                ret

' initialised data and/or presets

destscrn                long    4

fullscreen              long    SCREENSIZE_BYTES/2  'EXTREMELY IMPORTANT TO DIVIDE BY 2; CONSTANT IS WORD-ALIGNED, NOT BYTE-ALIGNED

h55555555               long    $55555555
hAAAA0000               long    $AAAA0000

_clipx1                 long    0
_clipy1                 long    0
_clipx2                 long    128
_clipy2                 long    64

mskLH                   long    0
mskLL                   long    0
mskRH                   long    0
mskRL                   long    0

delta                   long    %001_0 << 28 | $FFFC    ' %10 deal with movi setup
                                                        ' -(-4) address increment
argn                    long    |< 12                   ' function does have arguments

' Stuff below is re-purposed for temporary storage.

setup                   add     destscrn, par           ' default render buffer location

                        movi    ctrb, #%0_11111_000     ' general magic support
                        jmp     %%0                     ' return

' uninitialised data and/or temporaries

                        org     setup

index_x                 res     1
iter_x                  res     1
iter_y                  res     1

scrn                    res     1
send                    res     1

xs                      res     1
ys                      res     1
ws                      res     1
hs                      res     1
wb                      res     1

dstT{ransfer}           res     1
srcT{ransfer}           res     1

dstH{igh}               res     1
dstL{ow}                res     1
srcW{ord}               res     1


addr                    res     1
code                    res     1

arg0                    res     1
arg1                    res     1
arg2                    res     1
arg3                    res     1
arg4                    res     1

tail                    fit

CON
  zero = $1F0                                           ' par (dst only)

  res_x = 128                                           ' |
  res_y = 64                                            ' UI support

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