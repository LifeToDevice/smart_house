#line 1 "C:/projects/elevator/source/mc/exec_unit/hc165.c"
#line 1 "c:/projects/elevator/source/mc/exec_unit/hc165.h"
#line 1 "c:/projects/elevator/source/mc/exec_unit/../../common/types.h"
#line 17 "c:/projects/elevator/source/mc/exec_unit/../../common/types.h"
typedef unsigned char uchar;
typedef unsigned int ushort;
typedef unsigned long ulong;
#line 6 "c:/projects/elevator/source/mc/exec_unit/hc165.h"
void hc165_init( );
ulong hc165_read( );
#line 3 "C:/projects/elevator/source/mc/exec_unit/hc165.c"
void hc165_init( )
{
 HC165_LOAD_DIR = 0;
 HC165_CLOCK_DIR = 0;
 HC165_DATA_DIR = 1;

 HC165_LOAD_PIN = 1;
 HC165_CLOCK_PIN = 0;
}

ulong hc165_read( )
{
 unsigned char i;
 ulong val = 0;

 HC165_LOAD_PIN = 0;
 delay_us(1);
 HC165_LOAD_PIN = 1;

 for ( i = 0; i < 24; i++ )
 {
 val <<= 1;
 if ( !HC165_DATA_PIN )
 val |= 1;

 HC165_CLOCK_PIN = 0;
 delay_us(1);
 HC165_CLOCK_PIN = 1;
 delay_us(1);
 }

 return val;
}
