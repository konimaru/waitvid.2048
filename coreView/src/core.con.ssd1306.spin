''
'' SSD1306 OLED/PLED driver+controller commands
''
''        Author: Marko Lukat
'' Last modified: 2016/01/10
''       Version: 0.1
''
CON
  SET_CONTRAST                  = $81
  DISPLAY_FOLLOW_RAM            = $A4
  DISPLAY_IGNORE_RAM            = $A5
  DISPLAY_NORMAL                = $A6
  DISPLAY_INVERTED              = $A7
  DISPLAY_OFF                   = $AE
  DISPLAY_ON                    = $AF

  PAM_SET_L_COLUMN              = $00
  PAM_SET_H_COLUMN              = $10
  PAM_SET_PAGE                  = $B0
  SET_MEMORY_MODE               = $20
  SET_COLUMN_ADDR               = $21
  SET_PAGE_ADDR                 = $22

  SET_START_LINE                = $40
  SET_SEGMENT_REMAP             = $A0
  SET_MULTIPLEX_RATIO           = $A8
  SET_COM_SCAN_INC              = $C0
  SET_COM_SCAN_DEC              = $C8
  SET_DISPLAY_OFFSET            = $D3
  SET_COM_PINS                  = $DA

  CHARGE_PUMP                   = $8D
  SET_DISPLAY_CLOCK_DIV         = $D5
  SET_PRECHARGE_PERIOD          = $D9
  SET_VCOMH_DESELECT            = $DB

PUB null
'' This is not a top level object.

DAT