''
'' MMA7660FC 3-axis accelerometer definitions
''
''        Author: Marko Lukat
'' Last modified: 2016/02/16
''       Version: 0.1
''
'' acknowledgements
'' - MMA7660FC 3-Axis accelerometer interface, Copyright (C) 2015 Jon McPhalen
''
CON
  ID            = %0_1001100                            ' device ID

  XOUT          = $00                                   ' signed 6-bit output value X              
  YOUT          = $01                                   ' signed 6-bit output value Y              
  ZOUT          = $02                                   ' signed 6-bit output value Z              
  TILT          = $03                                   ' tilt status                              
  SRST          = $04                                   ' sampling rate status                     
  SPCNT         = $05                                   ' sleep count                              
  INTSU         = $06                                   ' interrupt setup                          
  MODE          = $07                                   ' mode                                     
  SR            = $08                                   ' auto-wake/sleep, P/L SPS, debounce filter
  PDET          = $09                                   ' tap detection                            
  PD            = $0A                                   ' tap debounce count                       

  TAP_BIT       = %0010_0000                            ' device has been tapped
  ALERT_BIT     = %0100_0000                            ' set when reading could be corrupted
  ALERT_XYZT    = ALERT_BIT * $01010101                 ' for reading x, y, z, and tilt at once
  SHAKE_BIT     = %1000_0000                            ' device has been shaken

PUB null
'' This is not a top level object.

DAT