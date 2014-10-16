#include <propeller.h>
#include <stdlib.h>

#define VGRP 2              // video pin group
#define MODE 1              // 0: FG on/off, 1: FG :==: BG

#define COLUMNS 80
#define ROWS    25
#define BCNT    (COLUMNS*ROWS)
                              
#define VIDEO (((VGRP) << 9 | (MODE) << 8 | 0xFC) << 21)

#define CURSOR_ON    (1 << 2)
#define CURSOR_OFF   (0 << 2)
#define CURSOR_ULINE (1 << 1)
#define CURSOR_BLOCK (0 << 1)
#define CURSOR_FLASH (1 << 0)
#define CURSOR_SOLID (0 << 0)

#define CURSOR_MASK  (CURSOR_ON|CURSOR_ULINE|CURSOR_FLASH)


typedef union {
    struct {
        unsigned char mode;
        unsigned char x, y;
    } payload;
    uint32_t pad;
} cursor;


static volatile uint32_t link[4];

static uint32_t scrn[BCNT / 2];
static cursor one = {{CURSOR_ON|CURSOR_ULINE|CURSOR_FLASH, 0, 0}};

extern const uint16_t font[];
extern const uint32_t driver[];


static int launch(int ID, const void *code, uint32_t data) {
    if (!(ID & -8)) coginit(ID++, code, data);
    else if (!(ID = cognew(code, data) + 1))
        clkset(128, 0);     // abort
        
    return ID;
}

static int init(void) {
    int cog;

    link[3] = 0;
    
    cog = launch( -1, driver, (uint32_t)&link[0]) & 7;
    cog = launch(cog, driver, (uint32_t)&link[0]|0x8000);
    
    while (link[3] != 0xFFFF);
    
    link[3] = 0;
    
    return cog;
}

static void printChar(unsigned char attr, unsigned char c) {
    uint16_t *word = (uint16_t *)&scrn[0];
    unsigned char x = one.payload.x;
    unsigned char y = one.payload.y;
    
    word[BCNT - y * COLUMNS - ++x] = attr | (c & 127) << 8;
    if (!(x %= COLUMNS))
        y = (y+1) % ROWS;
        
    one.payload.x = x;
    one.payload.y = y;
}

int main(int argc, char **argv) {
    link[0] =      VIDEO | (uint32_t)&scrn[0];
    link[1] =   16 << 24 | (uint32_t)&font[0];
    link[2] = 0x00010001 * (uint32_t)&one;

    init();

    for (int i = 0; i < BCNT; i++) {
        unsigned char c = FRQA++;
        c = c << 1 | (c > 127);
        printChar(c, i);
    }
    exit(0);
}
