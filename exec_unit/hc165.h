#ifndef _HC165_H_
#define _HC165_H_

#include "../../common/types.h"

// Инициализация HC165
void hc165_init( )
{
    HC165_LOAD_DIR  = 0;
    HC165_CLOCK_DIR = 0;
    HC165_DATA_DIR  = 1;

    HC165_LOAD_PIN  = 1;
    HC165_CLOCK_PIN = 0;
}

// Чтения состояния HC165 
// bits_count - количество бит ( одна HC165 - 8 бит, две - 16, три - 24, четыре - 32)
ulong hc165_read( uchar bits_count )
{
    unsigned char i;
    ulong val = 0;

    HC165_LOAD_PIN = 0;
    delay_us(1);
    HC165_LOAD_PIN = 1;

    for ( i = 0; i < bits_count; i++ )
    {
        val <<= 1;
        if ( HC165_DATA_PIN == 0 ) // Инвертировано
            val |= 1;

        HC165_CLOCK_PIN = 0;
        delay_us(1);
        HC165_CLOCK_PIN = 1;
        delay_us(1);
    }

    return val;
}

#endif