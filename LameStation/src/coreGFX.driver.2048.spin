''
''        Author: Marko Lukat
'' Last modified: 2014/07/23
''       Version: 0.26
''
'' long[par][0]: command: args:n:[!Z]:cmd = 16:4:3:9 -> zero (accepted)
'' long[par][1]: surface:     mres:*:addr = 8:8:16, 2n
''
'' -    n: 4bit parameter identifier (see CON section below)
'' - mres: expected sprite height resolution (4/8/12/16bit -> 3/2/1/0)
''
'' 20140602: blit code, WIP
'' 20140603: blit code, sorted out source offset multiplier(s)
'' 20140605: blit code, xs = 0 operational
'' 20140608: blit code, fully operational
'' 20140611: removed LCD translation code (now part of display driver)
'' 20140616: fixed rhs clipping
'' 20140703: export DAT section(s) for reuse
'' 20140709: sprite width may not be 8n any longer (force 8n alignment)
''
OBJ
  system: "core.con.system"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox)

  result{long[0]}:= system.launch(ID, @driver, mailbox)
  result.word[1] := @header_2048

CON
'   cmd[8..0]: cog entry address
'     cmd[12]: command has(1) no(0) arguments
' cmd[15..13]: number of arguments -1

  cmd_fillbuffer = $3_00A
  cmd_copybuffer = $3_011
  cmd_setclip    = $7_01A
  cmd_blitsprite = $9_027
  
DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
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

' #### FILL BUFFER
' ------------------------------------------------------
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: fill value

fillbuffer      cmp     arg0, #0 wz
        if_e    rdword  arg0, surface           ' draw surface
                mov     arg3, wcnt              ' words per buffer
                                                        
:loop           wrword  arg1, arg0                      
                add     arg0, #2                        
                djnz    arg3, #:loop                    
                                                        
                jmp     %%0                     ' return

' #### COPY BUFFER
' ------------------------------------------------------
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: src buffer (word aligned)

copybuffer      cmp     arg0, #0 wz
        if_e    rdword  arg0, surface           ' draw surface
                                                                                         
' #### POST BUFFER (VGA)                                                                 
' ------------------------------------------------------                                 
' parameters: arg0: dst buffer (word aligned)                                            
'             arg1: src buffer (word aligned)                                            
                                                                                         
postbufferVGA   mov     arg3, wcnt              ' words per buffer                       

:loop           rdword  arg2, arg1                                                       
                add     arg1, #2                                                         
                wrword  arg2, arg0                                                       
                add     arg0, #2                                                         
                djnz    arg3, #:loop                                                     
                                                                                                                                                                                            
                jmp     %%0                     ' return                                                                                                                                    
                                                                                                                                                                                            
' #### SET CLIP RECTANGLE                                                                                                                                                                   
' ------------------------------------------------------                                                                                                                                    
' parameters: arg0: x1                                                                                                                                                                      
'             arg1: y1 inclusive                                                                                                                                                            
'             arg2: x2                                                                                                                                                                      
'             arg3: y2 exclusive                                                                                                                                                            
                                                                                                                                                                                            
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
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: src buffer (word aligned) + header                                                                                                                                      
'             arg2: x                                                                                                                                                                       
'             arg3: y                                                                                                                                                                       
'             arg4: frame                                                                                                                                                                   
                                                                                                                                                                                            
blit            cmp     arg0, #0 wz
        if_e    rdword  arg0, surface           ' draw surface

' The header is located before the buffer data (negative offsets).
' Fetch everything necessary.

                sub     arg1, #6                ' access to header
                rdword  arg5, arg1              ' frame size in bytes                                                                                                                       
                add     arg1, #2                                                                                                                                                            

                neg     xs, arg2                ' xs := -x                      (%%)                                                                                                        
                rdword  ws, arg1                ' logical frame width                                                                                                                       
                add     arg1, #2                                                                                                                                                            

                neg     ys, arg3                ' ys := -y                      (##)                                                                                                        
                rdword  hs, arg1                ' logical frame height                                                                                                                      
                add     arg1, #2

                mov     wb, ws                  ' take a copy for final drawing
                add     wb, #7                  ' |
                andn    wb, #7                  ' round up to 8n
                shr     wb, #2                  ' byte count (4 px/byte)

                cmp     arg4, #0 wz {multiply?}
        if_z    jmp     #blit_cy

                shl     arg5, #8 -1             ' align operand for 16x8bit

                shr     arg4, #1 wc
        if_c    add     arg4, arg5 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc           ' 16x4bit, precision: 8

                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc
                rcr     arg4, #1 wc
        if_c    add     arg4, arg5 wc           ' 16x4bit, precision: 8

                add     arg1, arg4              ' apply offset

' Do all the necessary vertical clipping.

blit_cy         add     hs, arg3                ' lower edge                                                                                                                                
                maxs    hs, c_y2                ' min(lower edge, c_y2)
                mins    arg3, c_y1              ' max(y, c_y1)
                                                                                       
                cmps    hs, arg3 wz,wc,wr       ' if lower edge =< y
        if_be   jmp     %%0                     '   early exit                         

                add     ys, arg3 wz {multiply?} ' ys == 0|c_y1 - y              (##)
        if_z    jmp     #blit_cx

' An offset into the source buffer needs to be applied. The following
' code performs ys *= wb. The range of ys is configurable during core
' initialisation (4/8/12/16bit).

                shl     wb, mshx                ' align operand for 16xNbit
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

                shr     wb, mshx                ' restore width

' Do all the necessary horizontal clipping.
                                                                                                                                                                                            
blit_cx         add     ws, arg2                ' right edge                           
                maxs    ws, c_x2                ' min(right edge, c_x2)
                mins    arg2, c_x1              ' max(x, c_x1)
                
                cmps    ws, arg2 wz,wc,wr       ' if x => right edge
        if_be   jmp     %%0                     '   early exit

                add     xs, arg2                ' xs == 0|c_x1 - x              (%%)

' dst += (y * 128 + x) / 4 (byte address)

                shl     arg3, #5                ' *32
                add     arg0, arg3

                ror     arg2, #2                ' /4
                add     arg0, arg2
                
                shr     arg2, #29 wc            ' collect byte selector
                muxc    arg2, #%1000            ' bit index in word (0..14)

' src += ys * wb + xs / 4 (byte address)

                add     arg1, ys
                ror     xs, #2                  ' /4
                add     arg1, xs
                
                shr     xs, #29 wc              ' collect byte selector
                muxc    xs, #%1000 wz           ' bit index in word (0..14)     (&&)
                muxz    :jump, #%11             ' select hblit function

' calculate clipping mask update based on length overhead (if zero then carry clear)

                shl     ws, #1                  ' bit width
                add     ws, xs                  ' avoid calculating (8*2 - xs)
        if_nz   cmp     ws, #8*2 +1 wc          ' all columns from same word    (&&)
        if_nz   muxc    :jump, #%01             ' outa vs outb                  (&&)

                mov     arg3, ws
        if_c    sub     arg3, xs                ' all columns from same word
                and     arg3, #%1110

                neg     clip, #1
                shl     clip, arg3              ' create tail window

                mov     arg3, arg2
        if_a    sub     arg3, xs                '                               (&&)
        if_a    and     arg3, #%1110            '                               (&&)
                shl     clip, arg3              ' now aligned with dst

' preset transparency mask

                mov     arg3, trns              ' high word only
                sar     arg3, xs                ' plus non-zero offset
                andn    arg3, grid              ' %11 -> %10

' arg0: r/u c   dst byte address (xxword OK)
' arg1: r/u c   src byte address (xxword OK)
' arg2: r/o c   dst bit index
' arg3: r/o     source transparency mask (xs <> 0)
'   xs: r/o     src bit index
'   ws: r/o c   bit width
'   hs: r/u     row count
'   wb: r/o     source width in byte (row advance)
'
' arg4: r/w     temporary
' arg5: r/w     temporary

:loop           mov     dstT, arg0              ' |
                mov     srcT, arg1              ' |
                mov     arg4, ws                ' working copy
                mov     arg5, arg2              ' |

:jump           jmpret  link, func              ' hblit

                add     arg0, #128/4            ' |
                add     arg1, wb                ' advance

                djnz    hs, #:loop              ' for all rows

                jmp     %%0                     ' return


fn_00           rdword  dstL, dstT              '  +0 =                          
                sub     arg4, #8*2              '  +8   update column count
                add     dstT, #2                '  -4                            
                rdword  dstH, dstT              '  +0 =                          
                shl     dstH, #16               '  +8                            
                or      dstL, dstH              '  -4   extract 16 dst pixel     

                rdword  srcW, srcT              '  +0 = extract 8 src pixel         
                add     srcT, #2                '  +8                               
                shr     srcW, xs                '  -4   xs <> 0                     
                or      srcW, arg3              '  +0 = add transparency (pre-shifted)
                rol     srcW, arg5              '  +4   now aligned with dst        
                                                                                    
                mov     frqb, srcW              '  +8   %10 is transparent          
                shr     frqb, #1                '  -4                               
                andn    frqb, srcW              '  +0 =                             
                and     frqb, grid              '  +4   extract transparent pixel   
                                                                                    
                mov     phsb, frqb              '  +8   |                           
                mov     frqb, phsb              '  -4   frqb := frqb*3              

                andn    srcW, frqb              '  +0 = clear transparent pixels    
                and     dstL, frqb              '  +4   make space for src          
                or      dstL, srcW              '  +8   combine dst/src

                sub     arg5, xs wc             '  -4   
                and     arg5, #%1110            '  +0 = adjust dst bit index
        if_nc   jmp     #fn_11_tail wz          '  +4   business as usual (flags: above)
                sub     arg4, #8*2 wz,wc        '  +8   update/check column count
                jmp     #fn_11_next             '  -4   gap in dstL
                

fn_01           rdword  dstL, dstT              '  +0 =                          
                cmp     arg4, #8*2 wz,wc        '  +8   check column count
                add     dstT, #2                '  -4                            
                rdword  dstH, dstT              '  +0 =                          
                shl     dstH, #16               '  +8                            
                or      dstL, dstH              '  -4   extract 16 dst pixel     

                rdword  srcW, srcT              '  +0 = extract 8 src pixel           
                shr     srcW, xs                '  +8   xs <> 0, srcT advance n/a     
                or      srcW, arg3              '  -4   add transparency (pre-shifted)
                rol     srcW, arg5              '  +0 = now aligned with dst
                                                                                      
                mov     frqb, srcW              '  +4   %10 is transparent       
                shr     frqb, #1                '  +8                            
                andn    frqb, srcW              '  -4                            
                and     frqb, grid              '  +0 = extract transparent pixel
                                         
                mov     phsb, frqb              '  +4   |                           
                mov     frqb, phsb              '  +8   frqb := frqb*3              

' If column 7 is included (e.g. xs = 3, ws = 5) then the existing mask in frqb will
' already be big enough. Applying clip would be optional in this case but doesn't do
' any harm either (if applied). For consistency(?) we stick with the fn_11 version.

        if_b    or      frqb, clip              '  -4   apply patch for columns          

                andn    srcW, frqb              '  +0 = clear transparent pixels    
                and     dstL, frqb              '  +4   make space for src          
                or      dstL, srcW              '  +8   combine dst/src             
                                                                                    
                sub     dstT, #2                '  -4   rewind                      
                wrword  dstL, dstT              '  +0 = update low word             
                shr     dstL, #16               '  +8   dstL := dstH                
                add     dstT, #2                '  -4   advance (again)             
                wrword  dstL, dstT              '  +0 = update high word

                jmp     link                    '       return


fn_11           rdword  dstL, dstT              '  +0 =
fn_11_loop      sub     arg4, #8*2 wz,wc        '  +8   update/check column count
                add     dstT, #2                '  -4
                rdword  dstH, dstT              '  +0 =
                shl     dstH, #16               '  +8
                or      dstL, dstH              '  -4   extract 16 dst pixel

fn_11_next      rdword  srcW, srcT              '  +0 = extract 8 src pixel
                add     srcT, #2                '  +8
                or      srcW, trns              '  -4   add transparency
                rol     srcW, arg5              '  +0 = now aligned with dst

                mov     frqb, srcW              '  +4   %10 is transparent
                shr     frqb, #1                '  +8
                andn    frqb, srcW              '  -4
                and     frqb, grid              '  +0 = extract transparent pixel

                mov     phsb, frqb              '  +4   |
                mov     frqb, phsb              '  +8   frqb := frqb*3

        if_b    or      frqb, clip              '  -4   apply patch for columns < 8

                andn    srcW, frqb              '  +0 = clear transparent pixels
                and     dstL, frqb              '  +4   make space for src
                or      dstL, srcW              '  +8   combine dst/src

fn_11_tail      sub     dstT, #2                '  -4   rewind
                wrword  dstL, dstT              '  +0 = update low word
                shr     dstL, #16               '  +8   dstL := dstH
                add     dstT, #2                '  -4   advance (again)
        if_be   wrword  dstL, dstT              '  +0 = update high word (exit path)
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

surface         long    4                       ' draw surface location       
                                                                              
wcnt            long    res_x * res_y / 4 / 2   ' 4 pixels / byte             
                                                ' 2 bytes / word              
c_x1            long    0                                                     
c_y1            long    0                                                     
c_x2            long    res_x                                                 
c_y2            long    res_y                                                 
                                                                              
delta           long    %001_0 << 28 | $FFFC    ' %10 deal with movi setup    
                                                ' -(-4) address increment     
argn            long    |< 12                   ' function does have arguments
mshx            long    16{bit} -1              ' multiplier pre-shift

trns            long    $AAAA0000               ' transparency base value
grid            long    $55555555               ' transparent bit locations

' Stuff below is re-purposed for temporary storage.

setup           add     surface, par            ' draw surface

                rdlong  arg0, surface
                shr     arg0, #24 -2
                and     arg0, #%1100            ' 0/4/8/12

                add     blit_m, arg0            ' |
                add     blit_m, arg0            ' adjust jump

                sub     mshx, arg0              ' adjust pre-shift

                movi    ctrb, #%0_11111_000     ' general magic support

                movs    func+%00, #fn_00        ' |
                movs    func+%01, #fn_01        ' |
                movs    func+%11, #fn_11        ' hblit function setup
                
                jmp     %%0                     ' return      

                fit
                
' uninitialised data and/or temporaries

                org     setup
                             
arg0            res     1    
arg1            res     1    
arg2            res     1    
arg3            res     1    
arg4            res     1    
arg5            res     1    
arg6            res     1    
arg7            res     1    

addr            res     1    
code            res     1    
link            res     1
    
reuse           res     alias

xs              res     1
ys              res     1
ws              res     1
hs              res     1
wb              res     1
clip            res     1

dstT{ransfer}   res     1
srcT{ransfer}   res     1

dstH{igh}       res     1
dstL{ow}        res     1
srcW{ord}       res     1

tail            fit          

' aliases (different functions may share VAR space)

                org     reuse

                fit     tail

DAT                                             ' translation table

__table         word    (@__names - @__table)/2

'                     function has(1) no(0) argument(s) ----+ 
'                                number of arguments -1 --+ |   
'                                                         | |
{fillbuffer}    word    (@fillbuffer - @driver) >> 2 | %001_1 << 12 ' 2 arguments
{copybuffer}    word    (@copybuffer - @driver) >> 2 | %001_1 << 12 ' 2 arguments
{setclip}       word    (@setclip    - @driver) >> 2 | %011_1 << 12 ' 4 arguments
{blitsprite}    word    (@blit       - @driver) >> 2 | %100_1 << 12 ' 5 arguments

                word    res_m
                word    res_a
                
__names         byte    "fillbuffer", 0
                byte    "copybuffer", 0
                byte    "setclip", 0
                byte    "blitsprite", 0

                byte    "res_m", 0
                byte    "res_a", 0

DAT                                             ' screen padding

EndOfBinary     long    -1[0 #> (512 - (@EndOfBinary - @header_2048) / 4)]

CON
  zero  = $1F0                                  ' par (dst only)
  func  = $1F4                                  ' outa
  
  res_x = 128                                   ' |
  res_y = 64                                    ' |
  res_m = 2                                     ' UI support
  res_a = 8                                     ' max command arguments

  alias = 0
  
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