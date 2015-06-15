''
'' Font data (one bit/pixel, 8x16)
''
''        Author: Marko Lukat
'' Last modified: 2015/06/15
''       Version: 0.2
''        Layout: two scan lines per character (big-endian)
''
CON
  height = 16

PUB addr

  return @font

DAT

font    word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $FFFF, $0000, $FFFF, $0000, $0000, $0000, $0000, $0000
        word    $0001, $0040, $0000, $0000, $0000, $003E, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0066, $0000, $1818, $0000, $0000, $000C, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $081C, $0000
        word    $000C, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $006E, $0000

        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $0000, $FFFF, $0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFE, $FFBF, $FFFF, $FFFF, $FFFF, $FFC1, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FF99, $FFFF, $E7E7, $FFFF, $FFFF, $FFF3, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $F7E3, $FFFF  
        word    $FFF3, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FF91, $FFFF  


        word    $0000, $7E81, $7EFF, $006C, $0010, $183C, $183C, $0000, $FFFF, $0000, $FFFF, $F0E0, $3C66, $FCCC, $FEC6, $1818
        word    $0307, $6070, $183C, $6666, $FEDB, $6306, $0000, $183C, $183C, $1818, $0000, $0000, $0000, $0000, $0008, $007F
        word    $0000, $183C, $6666, $0066, $3E63, $0083, $1C36, $0C0C, $3018, $0C18, $0000, $0000, $0000, $0000, $0000, $0000
        word    $1C36, $181C, $3E63, $3E63, $3038, $7F03, $3C06, $7F63, $3E63, $3E63, $0000, $0000, $0060, $0000, $0006, $3E63
        word    $003E, $081C, $3F66, $3C66, $1F36, $7F66, $7F66, $3C66, $6363, $3C18, $7830, $6766, $0F06, $6377, $6367, $3E63
        word    $3F66, $3E63, $3F66, $3E63, $7E7E, $6363, $6363, $6363, $6363, $6666, $7F63, $3C0C, $0001, $3C30, $3663, $0000
        word    $0C18, $0000, $0706, $0000, $3830, $0000, $386C, $0000, $0706, $1818, $6060, $0706, $1C18, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $080C, $0000, $0000, $0000, $0000, $0000, $0000, $7018, $1818, $0E18, $3B00, $0000

        word    $FFFF, $817E, $8100, $FF93, $FFEF, $E7C3, $E7C3, $FFFF, $0000, $FFFF, $0000, $0F1F, $C399, $0333, $0139, $E7E7  
        word    $FCF8, $9F8F, $E7C3, $9999, $0124, $9CF9, $FFFF, $E7C3, $E7C3, $E7E7, $FFFF, $FFFF, $FFFF, $FFFF, $FFF7, $FF80  
        word    $FFFF, $E7C3, $9999, $FF99, $C19C, $FF7C, $E3C9, $F3F3, $CFE7, $F3E7, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $E3C9, $E7E3, $C19C, $C19C, $CFC7, $80FC, $C3F9, $809C, $C19C, $C19C, $FFFF, $FFFF, $FF9F, $FFFF, $FFF9, $C19C  
        word    $FFC1, $F7E3, $C099, $C399, $E0C9, $8099, $8099, $C399, $9C9C, $C3E7, $87CF, $9899, $F0F9, $9C88, $9C98, $C19C  
        word    $C099, $C19C, $C099, $C19C, $8181, $9C9C, $9C9C, $9C9C, $9C9C, $9999, $809C, $C3F3, $FFFE, $C3CF, $C99C, $FFFF  
        word    $F3E7, $FFFF, $F8F9, $FFFF, $C7CF, $FFFF, $C793, $FFFF, $F8F9, $E7E7, $9F9F, $F8F9, $E3E7, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $F7F3, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $8FE7, $E7E7, $F1E7, $C4FF, $FFFF  


        word    $0000, $A581, $DBFF, $FEFE, $387C, $3CE7, $7EFF, $0018, $FFFF, $003C, $FFC3, $B098, $6666, $FC0C, $FEC6, $DB3C
        word    $0F1F, $787C, $7E18, $6666, $DBDB, $1C36, $0000, $7E18, $7E18, $1818, $0010, $0004, $0000, $1436, $1C1C, $7F3E
        word    $0000, $3C3C, $2400, $66FF, $4303, $C360, $361C, $0600, $0C0C, $3030, $0066, $0018, $0000, $0000, $0000, $4060
        word    $6363, $1E18, $6030, $6060, $3C36, $0303, $0303, $6030, $6363, $6363, $1818, $1818, $3018, $007E, $0C18, $6360
        word    $6363, $3663, $6666, $4303, $6666, $4616, $4616, $4303, $6363, $1818, $3030, $6636, $0606, $7F7F, $6F7F, $6363
        word    $6666, $6363, $6666, $6306, $5A18, $6363, $6363, $6363, $363E, $6666, $6130, $0C0C, $0307, $3030, $0000, $0000
        word    $0000, $001E, $061E, $003E, $303C, $003E, $4C0C, $006E, $0636, $001C, $0070, $0666, $1818, $0067, $003B, $003E
        word    $003B, $006E, $003B, $003E, $0C3F, $0033, $0063, $00C3, $00C3, $0063, $007F, $1818, $1818, $1818, $0000, $081C

        word    $FFFF, $5A7E, $2400, $0101, $C783, $C318, $8100, $FFE7, $0000, $FFC3, $003C, $4F67, $9999, $03F3, $0139, $24C3  
        word    $F0E0, $8783, $81E7, $9999, $2424, $E3C9, $FFFF, $81E7, $81E7, $E7E7, $FFEF, $FFFB, $FFFF, $EBC9, $E3E3, $80C1  
        word    $FFFF, $C3C3, $DBFF, $9900, $BCFC, $3C9F, $C9E3, $F9FF, $F3F3, $CFCF, $FF99, $FFE7, $FFFF, $FFFF, $FFFF, $BF9F  
        word    $9C9C, $E1E7, $9FCF, $9F9F, $C3C9, $FCFC, $FCFC, $9FCF, $9C9C, $9C9C, $E7E7, $E7E7, $CFE7, $FF81, $F3E7, $9C9F  
        word    $9C9C, $C99C, $9999, $BCFC, $9999, $B9E9, $B9E9, $BCFC, $9C9C, $E7E7, $CFCF, $99C9, $F9F9, $8080, $9080, $9C9C  
        word    $9999, $9C9C, $9999, $9CF9, $A5E7, $9C9C, $9C9C, $9C9C, $C9C1, $9999, $9ECF, $F3F3, $FCF8, $CFCF, $FFFF, $FFFF  
        word    $FFFF, $FFE1, $F9E1, $FFC1, $CFC3, $FFC1, $B3F3, $FF91, $F9C9, $FFE3, $FF8F, $F999, $E7E7, $FF98, $FFC4, $FFC1  
        word    $FFC4, $FF91, $FFC4, $FFC1, $F3C0, $FFCC, $FF9C, $FF3C, $FF3C, $FF9C, $FF80, $E7E7, $E7E7, $E7E7, $FFFF, $F7E3  


        word    $0000, $81BD, $FFC3, $FEFE, $FE7C, $E7E7, $FF7E, $3C3C, $E7C3, $6642, $99BD, $3C66, $663C, $0C0C, $C6C6, $E73C
        word    $7F1F, $7F7C, $1818, $6666, $DED8, $6363, $0000, $1818, $1818, $1818, $307F, $067F, $0303, $7F36, $3E3E, $3E1C
        word    $0000, $3C18, $0000, $6666, $3E60, $3018, $6E3B, $0000, $0C0C, $3030, $3CFF, $187E, $0000, $007F, $0000, $3018
        word    $6B6B, $1818, $180C, $3860, $337F, $3F60, $3F63, $180C, $3E63, $7E60, $0000, $0000, $0C06, $0000, $3060, $3018
        word    $7B7B, $637F, $3E66, $0303, $6666, $1E16, $1E16, $037B, $7F63, $1818, $3030, $1E1E, $0606, $6B63, $7B73, $6363
        word    $3E06, $6363, $3E36, $1C30, $1818, $6363, $6363, $6B6B, $1C1C, $3C18, $180C, $0C0C, $0E1C, $3030, $0000, $0000
        word    $0000, $303E, $3666, $6303, $3633, $637F, $1E0C, $3333, $6E66, $1818, $6060, $361E, $1818, $FFDB, $6666, $6363
        word    $6666, $3333, $6E06, $6303, $0C0C, $3333, $6363, $C3C3, $663C, $6363, $3318, $0E18, $1800, $7018, $0000, $3663

        word    $FFFF, $7E42, $003C, $0101, $0183, $1818, $0081, $C3C3, $183C, $99BD, $6642, $C399, $99C3, $F3F3, $3939, $18C3  
        word    $80E0, $8083, $E7E7, $9999, $2127, $9C9C, $FFFF, $E7E7, $E7E7, $E7E7, $CF80, $F980, $FCFC, $80C9, $C1C1, $C1E3  
        word    $FFFF, $C3E7, $FFFF, $9999, $C19F, $CFE7, $91C4, $FFFF, $F3F3, $CFCF, $C300, $E781, $FFFF, $FF80, $FFFF, $CFE7  
        word    $9494, $E7E7, $E7F3, $C79F, $CC80, $C09F, $C09C, $E7F3, $C19C, $819F, $FFFF, $FFFF, $F3F9, $FFFF, $CF9F, $CFE7  
        word    $8484, $9C80, $C199, $FCFC, $9999, $E1E9, $E1E9, $FC84, $809C, $E7E7, $CFCF, $E1E1, $F9F9, $949C, $848C, $9C9C  
        word    $C1F9, $9C9C, $C1C9, $E3CF, $E7E7, $9C9C, $9C9C, $9494, $E3E3, $C3E7, $E7F3, $F3F3, $F1E3, $CFCF, $FFFF, $FFFF  
        word    $FFFF, $CFC1, $C999, $9CFC, $C9CC, $9C80, $E1F3, $CCCC, $9199, $E7E7, $9F9F, $C9E1, $E7E7, $0024, $9999, $9C9C  
        word    $9999, $CCCC, $91F9, $9CFC, $F3F3, $CCCC, $9C9C, $3C3C, $99C3, $9C9C, $CCE7, $F1E7, $E7FF, $8FE7, $FFFF, $C99C  


        word    $0000, $9981, $E7FF, $7C38, $3810, $1818, $1818, $1800, $C3E7, $4266, $BD99, $6666, $187E, $0C0E, $E6E7, $DB18
        word    $0F07, $7870, $7E3C, $6600, $D8D8, $361C, $7F7F, $7E3C, $1818, $187E, $3010, $0604, $037F, $1400, $7F7F, $1C08
        word    $0000, $1800, $0000, $66FF, $6061, $0C06, $3333, $0000, $0C0C, $3030, $3C66, $1818, $0018, $0000, $0000, $0C06
        word    $6363, $1818, $0603, $6060, $3030, $6060, $6363, $0C0C, $6363, $6060, $0018, $0018, $0C18, $7E00, $3018, $1800
        word    $7B3B, $6363, $6666, $0343, $6666, $0646, $0606, $6363, $6363, $1818, $3333, $3666, $0646, $6363, $6363, $6363
        word    $0606, $6363, $6666, $6063, $1818, $6363, $6336, $6B7F, $3E36, $1818, $0643, $0C0C, $3870, $3030, $0000, $0000
        word    $0000, $3333, $6666, $0303, $3333, $0303, $0C0C, $3333, $6666, $1818, $6060, $1E36, $1818, $DBDB, $6666, $6363
        word    $6666, $3333, $0606, $3E60, $0C0C, $3333, $6363, $DBDB, $183C, $6363, $0C06, $1818, $1818, $1818, $0000, $6363

        word    $FFFF, $667E, $1800, $83C7, $C7EF, $E7E7, $E7E7, $E7FF, $3C18, $BD99, $4266, $9999, $E781, $F3F1, $1918, $24E7  
        word    $F0F8, $878F, $81C3, $99FF, $2727, $C9E3, $8080, $81C3, $E7E7, $E781, $CFEF, $F9FB, $FC80, $EBFF, $8080, $E3F7  
        word    $FFFF, $E7FF, $FFFF, $9900, $9F9E, $F3F9, $CCCC, $FFFF, $F3F3, $CFCF, $C399, $E7E7, $FFE7, $FFFF, $FFFF, $F3F9  
        word    $9C9C, $E7E7, $F9FC, $9F9F, $CFCF, $9F9F, $9C9C, $F3F3, $9C9C, $9F9F, $FFE7, $FFE7, $F3E7, $81FF, $CFE7, $E7FF  
        word    $84C4, $9C9C, $9999, $FCBC, $9999, $F9B9, $F9F9, $9C9C, $9C9C, $E7E7, $CCCC, $C999, $F9B9, $9C9C, $9C9C, $9C9C  
        word    $F9F9, $9C9C, $9999, $9F9C, $E7E7, $9C9C, $9CC9, $9480, $C1C9, $E7E7, $F9BC, $F3F3, $C78F, $CFCF, $FFFF, $FFFF  
        word    $FFFF, $CCCC, $9999, $FCFC, $CCCC, $FCFC, $F3F3, $CCCC, $9999, $E7E7, $9F9F, $E1C9, $E7E7, $2424, $9999, $9C9C  
        word    $9999, $CCCC, $F9F9, $C19F, $F3F3, $CCCC, $9C9C, $2424, $E7C3, $9C9C, $F3F9, $E7E7, $E7E7, $E7E7, $FFFF, $9C9C  


        word    $0000, $817E, $FF7E, $1000, $0000, $3C00, $3C00, $0000, $FFFF, $3C00, $C3FF, $663C, $1818, $0F07, $6703, $1800
        word    $0301, $6040, $1800, $6666, $D8D8, $3063, $7F00, $187E, $1818, $3C18, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $1818, $0000, $6666, $633E, $C3C1, $336E, $0000, $1830, $180C, $0000, $0000, $1818, $0000, $1818, $0301
        word    $361C, $187E, $637F, $633E, $3078, $633E, $633E, $0C0C, $633E, $301E, $1800, $180C, $3060, $0000, $0C06, $1818
        word    $033E, $6363, $663F, $663C, $361F, $667F, $060F, $665C, $6363, $183C, $331E, $6667, $667F, $6363, $6363, $633E
        word    $060F, $6B3E, $6667, $633E, $183C, $633E, $1C08, $7736, $6363, $183C, $637F, $0C3C, $6040, $303C, $0000, $0000
        word    $0000, $336E, $663B, $633E, $336E, $633E, $0C1E, $333E, $6667, $183C, $6060, $6667, $183C, $DBDB, $6666, $633E
        word    $663E, $333E, $060F, $633E, $6C38, $336E, $361C, $FF66, $66C3, $637E, $637F, $1870, $1818, $180E, $0000, $7F00

        word    $FFFF, $7E81, $0081, $EFFF, $FFFF, $C3FF, $C3FF, $FFFF, $0000, $C3FF, $3C00, $99C3, $E7E7, $F0F8, $98FC, $E7FF  
        word    $FCFE, $9FBF, $E7FF, $9999, $2727, $CF9C, $80FF, $E781, $E7E7, $C3E7, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $E7E7, $FFFF, $9999, $9CC1, $3C3E, $CC91, $FFFF, $E7CF, $E7F3, $FFFF, $FFFF, $E7E7, $FFFF, $E7E7, $FCFE  
        word    $C9E3, $E781, $9C80, $9CC1, $CF87, $9CC1, $9CC1, $F3F3, $9CC1, $CFE1, $E7FF, $E7F3, $CF9F, $FFFF, $F3F9, $E7E7  
        word    $FCC1, $9C9C, $99C0, $99C3, $C9E0, $9980, $F9F0, $99A3, $9C9C, $E7C3, $CCE1, $9998, $9980, $9C9C, $9C9C, $9CC1  
        word    $F9F0, $94C1, $9998, $9CC1, $E7C3, $9CC1, $E3F7, $88C9, $9C9C, $E7C3, $9C80, $F3C3, $9FBF, $CFC3, $FFFF, $FFFF  
        word    $FFFF, $CC91, $99C4, $9CC1, $CC91, $9CC1, $F3E1, $CCC1, $9998, $E7C3, $9F9F, $9998, $E7C3, $2424, $9999, $9CC1  
        word    $99C1, $CCC1, $F9F0, $9CC1, $93C7, $CC91, $C9E3, $0099, $993C, $9C81, $9C80, $E78F, $E7E7, $E7F1, $FFFF, $80FF  


        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $FFFF, $0000, $FFFF, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $3E00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $1818, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0C00, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $3070, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $00FF
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3033, $0000, $0000, $6066, $0000, $0000, $0000, $0000, $0000
        word    $0606, $3030, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $6030, $0000, $0000, $1800, $0000, $0000, $0000

        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $0000, $FFFF, $0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $C1FF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $E7E7, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $F3FF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $CF8F, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FF00  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $CFCC, $FFFF, $FFFF, $9F99, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
        word    $F9F9, $CFCF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $9FCF, $FFFF, $FFFF, $E7FF, $FFFF, $FFFF, $FFFF  


        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $FFFF, $0000, $FFFF, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $1E00, $0000, $0000, $3C00, $0000, $0000, $0000, $0000, $0000
        word    $0F00, $7800, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $1F00, $0000, $0000, $0000, $0000, $0000, $0000

        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $0000, $FFFF, $0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $E1FF, $FFFF, $FFFF, $C3FF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  
        word    $F0FF, $87FF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $E0FF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF  

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