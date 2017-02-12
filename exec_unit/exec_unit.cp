#line 1 "C:/projects/elevator/source/mc/exec_unit/exec_unit.c"
#line 1 "c:/projects/elevator/source/mc/exec_unit/exec_unit.h"
#line 1 "c:/projects/elevator/source/mc/exec_unit/../../common/types.h"
#line 17 "c:/projects/elevator/source/mc/exec_unit/../../common/types.h"
typedef unsigned char uchar;
typedef unsigned int ushort;
typedef unsigned long ulong;
#line 1 "c:/projects/elevator/source/mc/exec_unit/../../common/unit_data_exchange.h"
#line 1 "c:/projects/elevator/source/mc/exec_unit/../../common/types.h"
#line 62 "c:/projects/elevator/source/mc/exec_unit/../../common/unit_data_exchange.h"
struct s_cmd_header
{
 uchar name;
 uchar result;
};
#line 80 "c:/projects/elevator/source/mc/exec_unit/../../common/unit_data_exchange.h"
struct s_eu_motors_state
{
 struct s_cmd_header cmd;
 uchar state;
 uchar protect;
};


struct s_eu_sensors_state
{
 struct s_cmd_header cmd;
 uchar count;
 ulong state;
};


struct s_eu_motor_config
{
 struct s_cmd_header cmd;
 uchar number;
 uchar state;
 uchar protect;
 ushort start_time;
};


struct s_eu_unit_number
{
 struct s_cmd_header cmd;
 uchar number;
};


struct s_eu_motor_state
{
 struct s_cmd_header cmd;
 uchar number;
 uchar state;
};


struct s_eu_unit_state
{
 struct s_cmd_header cmd;
 uchar state;
};


struct s_eu_config_data
{
 struct s_cmd_header cmd;
 uchar magic[5];
 uchar number;
 uchar protect[24];
 ushort check_sum;
};





struct s_cu_auth
{
 struct s_cmd_header cmd;
 ulong auth_code;
};


struct s_cu_units
{
 struct s_cmd_header cmd;
 uchar index;
 uchar units[32];
};


struct s_cu_unit_state
{
 struct s_cmd_header cmd;
 uchar unit_number;
 uchar motors;
 uchar motors_protect;
 uchar sensors[3];
 uchar protected_motors;
};


struct s_cu_motor_state
{
 struct s_cmd_header cmd;
 uchar unit_number;
 uchar motor_number;
 uchar state;
 uchar ref_unit_number;
 uchar ref_motor_number;
};


struct s_cu_sensor_state
{
 struct s_cmd_header cmd;
 uchar unit_number;
 uchar sensor_number;
 uchar state;
};


struct s_cu_motors_relation
{
 struct s_cmd_header cmd;
 uchar unit_number;
 uchar motor_number;
 uchar dep_unit_number;
 uchar dep_motor_number;
};


struct s_cu_sensor_controlled_state
{
 struct s_cmd_header cmd;
 uchar unit_number;
 uchar sensor_number;
 uchar state;
 uchar motor_unit;
 uchar motor_number;
};


struct s_cu_changes
{
 struct s_cmd_header cmd;
 uchar changes;
};


struct s_cu_advanced_in_out
{
 struct s_cmd_header cmd;
 uchar number;
 uchar mode;
 uchar state;
};


struct s_cu_debug_cmd
{
 struct s_cmd_header cmd;
 uchar dbg_cmd;
 uchar dat[61];
};
#line 1 "c:/projects/elevator/source/mc/exec_unit/../../common/net_commands.h"
#line 10 "c:/projects/elevator/source/mc/exec_unit/../../common/net_commands.h"
struct s_net_cmd
{
 uchar addr;
 uchar cmd;
 ushort dat;
};
#line 1 "c:/projects/elevator/source/mc/exec_unit/../common/transceiver.h"




void transceiver_init( )
{
  TRISB7_bit  = 0;
  RB7_bit  = 1;
  TRISB6_bit  = 0;
  RB6_bit  = 1;
  TRISB5_bit  = 0;
  RB5_bit  = 0;
  TRISB4_bit  = 0;
  RB4_bit  = 0;
  TRISB3_bit  = 1;

 delay_ms(50);
}










unsigned char transceiver_send( unsigned char *cmd, unsigned char *result )
{
 signed char i, n;
 unsigned char d[5];

 memcpy(d, cmd, 5);

  RB7_bit  = 0;
  RB6_bit  = 1;
  RB5_bit  = 0;

 while ( ! RB3_bit  );

 if ( ! RB3_bit  )
 {
  RB7_bit  = 1;
 return 0;
 }

  TRISB4_bit  = 0;

 GIE_bit = 0;

 for ( n = 4; n >= 0; --n )
 {
 for ( i = 0; i < 8; ++i )
 {
 if ( d[n] & 0x80 )
  RB4_bit  = 1;
 else
  RB4_bit  = 0;

  RB5_bit  = 1;
 delay_us( 10 );
  RB5_bit  = 0;
 delay_us( 10 );

 d[n] <<= 1;
 }
 }

 GIE_bit = 1;

 memset(d, 0, 5);



  TRISB4_bit  = 1;
  RB7_bit  = 1;
  RB6_bit  = 0;

 while (  RB3_bit  );

 GIE_bit = 0;

 for ( n = 4; n >= 0; --n )
 {
 for ( i = 0; i < 8; ++i )
 {
  RB5_bit  = 1;
 delay_us( 10 );

 d[n] <<= 1;
 if (  RB4_bit  )
 d[n] |= 1;

  RB5_bit  = 0;
 delay_us( 10 );
 }
 }

 GIE_bit = 1;

  RB7_bit  = 1;
  RB6_bit  = 1;

 memcpy(result, d, 5);

 return 1;
}







unsigned char transceiver_recv( unsigned char *result )
{
 signed char i, n;
 unsigned char d[5];

 memset(d, 0, 5);

  TRISB4_bit  = 1;

  RB7_bit  = 0;
  RB6_bit  = 0;
  RB5_bit  = 0;

 delay_ms(1);

 if ( ! RB3_bit  )
 {
  RB7_bit  = 1;
  RB6_bit  = 1;
 return 0;
 }

 GIE_bit = 0;

 for ( n = 4; n >= 0; --n )
 {
 for ( i = 0; i < 8; ++i )
 {
  RB5_bit  = 1;
 delay_us( 10 );

 d[n] <<= 1;
 if (  RB4_bit  )
 d[n] |= 1;

  RB5_bit  = 0;
 delay_us( 10 );
 }
 }

 GIE_bit = 1;

  RB7_bit  = 1;
  RB6_bit  = 1;

 memcpy(result, d, 5);

 return 1;
}
#line 1 "c:/projects/elevator/source/mc/exec_unit/../common/net.h"
static net_send_attempts = 1;

void net_init( char send_attempts )
{
 net_send_attempts = send_attempts;
}






unsigned char net_set_params( unsigned char addr, unsigned char ack_wait_time )
{
 unsigned char d[5], res[5];

 memset(res, 0, 5);

 d[0] = 255;
 d[1] = addr;
 d[2] = ack_wait_time;
 d[3] = 0;
 d[4] = 0;

 if ( !transceiver_send(d, res) )
 return 1;

 return memcmp(d, res, 5);
}






unsigned char _net_send( unsigned char addr, unsigned char cmd, unsigned char *dat )
{
 uchar d[5];
 uchar res[5];

 memset(res, 0, 5);

 d[0] = addr;
 d[1] = cmd;
 d[2] = 0;
 d[3] = 0;
 d[4] = 0;

 if ( dat )
 memcpy(&d[2], dat, 3);

 if ( !transceiver_send(d, res) )
 return 1;

 return !memcmp(d, res, 5) ? 0 : 2;
}







unsigned char net_send( unsigned char addr, unsigned char cmd, unsigned char *dat, unsigned char attempts )
{
 char res;

 if ( attempts == 0 )
 attempts = net_send_attempts;

 while ( attempts-- )
 {
 res = _net_send(addr, cmd, dat);
 if ( res == 0 )
 return 0;

 if ( attempts )
 delay_ms(100);
 }

 return res;
}
#line 1 "c:/projects/elevator/source/mc/exec_unit/hc165.h"
#line 1 "c:/projects/elevator/source/mc/exec_unit/../../common/types.h"
#line 7 "c:/projects/elevator/source/mc/exec_unit/hc165.h"
void hc165_init( )
{
  TRISD7_bit  = 0;
  TRISD6_bit  = 0;
  TRISD5_bit  = 1;

  RD7_bit  = 1;
  RD6_bit  = 0;
}



ulong hc165_read( uchar bits_count )
{
 unsigned char i;
 ulong val = 0;

  RD7_bit  = 0;
 delay_us(1);
  RD7_bit  = 1;

 for ( i = 0; i < bits_count; i++ )
 {
 val <<= 1;
 if (  RD5_bit  == 0 )
 val |= 1;

  RD6_bit  = 0;
 delay_us(1);
  RD6_bit  = 1;
 delay_us(1);
 }

 return val;
}
#line 75 "c:/projects/elevator/source/mc/exec_unit/exec_unit.h"
struct s_motor
{
 uchar state;
 uchar protect;
 uchar sensor_state;
 ushort start_time;
 uchar ready;
 ushort start_time_counter;
};

void motor_init( );
void motor_acceleration_control( );
void motor_start( uchar number );
void motor_stop( uchar number, uchar failure );
#line 1 "c:/projects/elevator/source/mc/exec_unit/../common/usb.h"
unsigned char readbuff[ 64 ] absolute 0x500;
unsigned char writebuff[ 64 ] absolute 0x500 +  64 ;

void usb_on( )
{
 HID_Enable(&readbuff, &writebuff);
}

char usb_read( )
{
 return HID_Read();
}

char usb_write( )
{
 return HID_Write(&writebuff,  64 );
}

void usb_off( )
{
 HID_Disable();
}
#line 1 "c:/projects/elevator/source/mc/exec_unit/../common/internal_eeprom.h"

unsigned char ee_read( unsigned char addr )
{
 while ( WR_bit );
 EEADR = addr;
 EEPGD_bit = 0;
 CFGS_bit = 0;
 RD_bit = 1;
 return EEDATA;
}


unsigned char ee_write( unsigned char addr, unsigned char val )
{
 char int_state = GIE_Bit;
 while ( WR_bit );
 EEADR = addr;
 EEDATA = val;
 EEPGD_bit = 0;
 CFGS_bit = 0;
 WREN_bit = 1;
 GIE_Bit = 0;
 EECON2 = 0x55;
 EECON2 = 0xAA;
 WR_bit = 1;
 GIE_Bit = int_state;
 WREN_bit = 0;
 while ( WR_bit );
 return (WRERR_bit == 0);
}
#line 1 "c:/projects/elevator/source/mc/exec_unit/../common/crc.h"
#line 13 "c:/projects/elevator/source/mc/exec_unit/../common/crc.h"
unsigned char crc8( uchar *block, uchar len )
{
 uchar crc = 0xFF;
 uchar i;

 while ( len-- )
 {
 crc ^= *block++;
 for ( i = 0; i < 8; i++ )
 crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
 }

 return crc;
}
#line 39 "c:/projects/elevator/source/mc/exec_unit/../common/crc.h"
unsigned short crc16( uchar *block, ushort len )
{
 ushort crc = 0xFFFF;
 uchar i;

 while ( len-- )
 {
 crc ^= *block++ << 8;
 for ( i = 0; i < 8; i++ )
 crc = crc & 0x8000 ? (crc << 1) ^ 0x1021 : crc << 1;
 }
 return crc;
}
#line 13 "C:/projects/elevator/source/mc/exec_unit/exec_unit.c"
ulong curr_sensors_state = 0;
ulong prev_sensors_state = 0;
ulong curr_motors_state = 0;
ulong prev_motors_state = 0;


ulong motors_state = 0;

ulong sensors_state = 0;


uchar changes =  0 ;


uchar is_connected =  0 ;


uchar reboot_needed =  0 ;


uchar usb_state_on =  0 ;


uchar unit_number =  1 ;


uchar protected_motors = 0;


struct s_motor motors[ 8 ];

code ulong protected_mask[ 8  + 1] =
{
 0b111111111111111111111111,
 0b101111111111111111111111,
 0b100111111111111111111111,
 0b100011111111111111111111,
 0b100001111111111111111111,
 0b100000111111111111111111,
 0b100000011111111111111111,
 0b100000001111111111111111,
 0b100000000111111111111111,
};



void motor_init( )
{
  TRISD0_bit  = 0;
  TRISC2_bit  = 0;
  TRISC1_bit  = 0;
  TRISC0_bit  = 0;
  TRISE2_bit  = 0;
  TRISE1_bit  = 0;
  TRISE0_bit  = 0;
  TRISA5_bit  = 0;

  RD0_bit  = 0;
  RC2_bit  = 0;
  RC1_bit  = 0;
  RC0_bit  = 0;
  RE2_bit  = 0;
  RE1_bit  = 0;
  RE0_bit  = 0;
  RA5_bit  = 0;

 memset(motors, 0, sizeof(struct s_motor) *  8 );
}




void motor_set_state( uchar motor, uchar state )
{
 switch ( motor )
 {
 case 1:
  RD0_bit  = state;
 break;
 case 2:
  RC2_bit  = state;
 break;
 case 3:
  RC1_bit  = state;
 break;
 case 4:
  RC0_bit  = state;
 break;
 case 5:
  RE2_bit  = state;
 break;
 case 6:
  RE1_bit  = state;
 break;
 case 7:
  RE0_bit  = state;
 break;
 case 8:
  RA5_bit  = state;
 break;
 }
}


uchar motor_get_fail_state( )
{
 char i;
 uchar s = 0;

 for ( i = 0; i < 8; ++i )
 if ( motors[i].state == 2 )
 s |= (1 << i);

 return s;
}



char motor_read( ulong *state )
{
 char res = 0;

 curr_motors_state = (( RA5_bit  << 7) | ( RE0_bit  << 6) | ( RE1_bit  << 5) | ( RE2_bit  << 4) | ( RC0_bit  << 3) | ( RC1_bit  << 2) | ( RC2_bit  << 1) | ( RD0_bit  << 0));
 if ( curr_motors_state != prev_motors_state )
 {
 *state = ((ushort)motor_get_fail_state() << 8) | (uchar)(curr_motors_state & 0x000000ff);
 prev_motors_state = curr_motors_state;
 res = 1;
 }

 return res;
}


void motor_start( uchar number )
{
 TMR1IE_bit = 0;
 motor_set_state(number + 1, 1);
 motors[number].state = 1;
 motors[number].ready = 0;
 motors[number].start_time_counter = 0;
 TMR1IE_bit = 1;
}


void motor_stop( uchar number, uchar failure )
{
 motor_set_state(number + 1, 0);
 motors[number].state = failure ? 2 : 0;
}


void motor_acceleration_control( )
{
 char i;
 for ( i = 0; i <  8 ; ++i )
 if ( motors[i].state == 1 && motors[i].ready ==  0  )
 if ( motors[i].start_time_counter++ >= motors[i].start_time )
 motors[i].ready =  1 ;
}


void motor_protect_control( )
{
 char i;
 for ( i = 0; i <  8 ; ++i )
 {

 if ( motors[i].state != 1 || motors[i].protect == 0 )
 continue;


 if ( motors[i].ready && motors[i].sensor_state )
 {

 motor_stop(i,  1 );
 }
 }
}


void motor_reset_fail_state( )
{
 char i;
 for ( i = 0; i <  8 ; ++i )
 if ( motors[i].state == 2 )
 motors[i].state = 0;
}


unsigned char motor_get_protected( )
{
 char i, n = 0;
 for ( i = 0; i <  8 ; ++i )
 if ( motors[i].protect )
 n++;
 return n;
}


void timer1_init( )
{

 T1CON = 0x31;
 TMR1IF_bit = 0;
 TMR1H = 0x0B;
 TMR1L = 0xD9;
 TMR1IE_bit = 1;
}


void load_config( )
{
 uchar i, n, byte_val;
 ushort word_val;

 byte_val = ee_read(0x00);
 if ( byte_val != 0xff )
 unit_number = byte_val;

 n = 0;
 for ( i = 0; i < 8; ++i )
 {

 byte_val = ee_read(0x01 + n);

 word_val = ((ushort)ee_read(0x03 + n) << 8) | ee_read(0x02 + n);

 if ( byte_val == 0xff )
 continue;

 motors[i].protect = byte_val;
 motors[i].start_time = word_val;

 n += 3;
 }

 protected_motors = motor_get_protected();
}


uchar write_config_byte( uchar addr, uchar dat )
{
 return (ee_write(addr, dat) && (ee_read(addr) == dat));
}


uchar write_config_word( uchar addr, ushort dat )
{
 return (ee_write(addr, dat & 0x00ff) && ee_write(addr + 1, (dat >> 8) & 0x00ff) && (ee_read(addr) == (dat & 0x00ff)) && (ee_read(addr + 1) == ((dat >> 8) & 0x00ff)));
}



void protect_restore( )
{
  RD1_bit  = 1;
 delay_ms(100);
  RD1_bit  = 0;
}



void exec_commands( )
{
 uchar buff[5];

 while ( 1 )
 {
 delay_ms(1);
 memset(buff, 0, 5);
 if ( transceiver_recv(buff) )
 {
 is_connected =  1 ;

 switch ( buff[1] )
 {
#line 296 "C:/projects/elevator/source/mc/exec_unit/exec_unit.c"
 case  16 :
  RD4_bit  = ~ RD4_bit ;
 changes =  1 ;
 break;


 case  5 :
 if ( buff[2] )
 motor_start(buff[3] - 1);
 else
 motor_stop(buff[3] - 1,  0 );
 break;


 case  14 :
 protect_restore();
 break;


 }
 }
 else
 {
 break;
 }
 }

 delay_ms(100);
}



char sensors_read( ulong *state )
{
 ulong st;
 char res = 0;
 char i;

 st = hc165_read(24);


 curr_sensors_state = 0;
 if ( st & 0b000000000000000000100000 ) curr_sensors_state |= 0b000000000000000000000001;
 if ( st & 0b000000000000000001000000 ) curr_sensors_state |= 0b000000000000000000000010;
 if ( st & 0b000000000000000010000000 ) curr_sensors_state |= 0b000000000000000000000100;
 if ( st & 0b000000000000000000001000 ) curr_sensors_state |= 0b000000000000000000001000;
 if ( st & 0b000000000000000000000100 ) curr_sensors_state |= 0b000000000000000000010000;
 if ( st & 0b000000000000000000000010 ) curr_sensors_state |= 0b000000000000000000100000;
 if ( st & 0b000000000000000000000001 ) curr_sensors_state |= 0b000000000000000001000000;
 if ( st & 0b000000000001000000000000 ) curr_sensors_state |= 0b000000000000000010000000;
 if ( st & 0b000000000010000000000000 ) curr_sensors_state |= 0b000000000000000100000000;
 if ( st & 0b000000000100000000000000 ) curr_sensors_state |= 0b000000000000001000000000;
 if ( st & 0b000000001000000000000000 ) curr_sensors_state |= 0b000000000000010000000000;
 if ( st & 0b000000000000000100000000 ) curr_sensors_state |= 0b000000000000100000000000;
 if ( st & 0b000000000000001000000000 ) curr_sensors_state |= 0b000000000001000000000000;
 if ( st & 0b000000000000010000000000 ) curr_sensors_state |= 0b000000000010000000000000;
 if ( st & 0b000000000000100000000000 ) curr_sensors_state |= 0b000000000100000000000000;
 if ( st & 0b000100000000000000000000 ) curr_sensors_state |= 0b000000001000000000000000;
 if ( st & 0b001000000000000000000000 ) curr_sensors_state |= 0b000000010000000000000000;
 if ( st & 0b010000000000000000000000 ) curr_sensors_state |= 0b000000100000000000000000;
 if ( st & 0b100000000000000000000000 ) curr_sensors_state |= 0b000001000000000000000000;
 if ( st & 0b000010000000000000000000 ) curr_sensors_state |= 0b000010000000000000000000;
 if ( st & 0b000001000000000000000000 ) curr_sensors_state |= 0b000100000000000000000000;
 if ( st & 0b000000100000000000000000 ) curr_sensors_state |= 0b001000000000000000000000;
 if ( st & 0b000000010000000000000000 ) curr_sensors_state |= 0b010000000000000000000000;
 if ( st & 0b000000000000000000010000 ) curr_sensors_state |= 0b100000000000000000000000;


 for ( i = 0; i < protected_motors; ++i )
 motors[i].sensor_state = (curr_sensors_state & (0x00400000 >> i)) ? 0 : 1;



 curr_sensors_state &= protected_mask[protected_motors];


 if ( curr_sensors_state != prev_sensors_state )
 {
 *state = curr_sensors_state;
 prev_sensors_state = curr_sensors_state;
 res = 1;
 }

 delay_ms(50);

 return res;
}


char motor_get_protect_mask( char count )
{
 switch ( count )
 {
 case 1:
 return 0b00000001;
 case 2:
 return 0b00000011;
 case 3:
 return 0b00000111;
 case 4:
 return 0b00001111;
 case 5:
 return 0b00011111;
 case 6:
 return 0b00111111;
 case 7:
 return 0b01111111;
 case 8:
 return 0b11111111;
 }
 return 0;
}


void init( )
{
 ADCON1 |= 0x0F;
 CMCON |= 7;

  TRISD4_bit  = 0;
  RD4_bit  = 0;

  TRISD1_bit  = 0;
  RD1_bit  = 0;

  TRISD2_bit  = 1;
}

void interrupt()
{
 if ( USBIF_bit )
 {
 USB_Interrupt_Proc();
 USBIF_bit = 0;
 }


 if ( TMR1IF_bit )
 {
 TMR1IF_bit = 0;
 TMR1H = 0x0B;
 TMR1L = 0xD9;

 motor_acceleration_control();
 }
}


void pc_data_exchange( )
{
 if (  RD2_bit  )
 {
 if ( !usb_state_on )
 {
 usb_on();
 usb_state_on =  1 ;
 }
 }
 else
 {
 if ( usb_state_on )
 {
 usb_off();
 usb_state_on =  0 ;
 }
 }

 if ( usb_state_on )
 {
 if ( usb_read() )
 {
 struct s_cmd_header *head = (struct s_cmd_header *)readbuff;

 switch ( head->name )
 {

 case  1 :
 {
 struct s_eu_unit_number *rd = (struct s_eu_unit_number *)readbuff;
 struct s_eu_unit_number *wr = (struct s_eu_unit_number *)writebuff;

 wr->cmd.name =  1 ;
 wr->number = unit_number;
 wr->cmd.result =  0 ;
 }
 break;


 case  2 :
 {
 struct s_eu_unit_number *rd = (struct s_eu_unit_number *)readbuff;
 struct s_eu_unit_number *wr = (struct s_eu_unit_number *)writebuff;

 wr->cmd.name =  2 ;
 if ( rd->number >= 1 && rd->number <= 253 )
 {
 if ( write_config_byte(0x00, rd->number) )
 {
 unit_number = rd->number;
 wr->cmd.result =  0 ;
 reboot_needed =  1 ;
 }
 else
 {
 wr->cmd.result =  6 ;
 }
 }
 else
 {
 wr->cmd.result =  4 ;
 }
 }
 break;


 case  3 :
 {
 struct s_eu_sensors_state *rd = (struct s_eu_sensors_state *)readbuff;
 struct s_eu_sensors_state *wr = (struct s_eu_sensors_state *)writebuff;

 wr->cmd.name =  3 ;
 wr->count =  23  - protected_motors;
 wr->state = sensors_state;
 wr->cmd.result =  0 ;
 }
 break;


 case  4 :
 {
 struct s_eu_motors_state *rd = (struct s_eu_motors_state *)readbuff;
 struct s_eu_motors_state *wr = (struct s_eu_motors_state *)writebuff;

 wr->cmd.name =  4 ;
 wr->state = (char)(motors_state & 0x000000ff);
 wr->protect = motor_get_protect_mask(protected_motors);
 wr->cmd.result =  0 ;
 }
 break;


 case  5 :
 {
 struct s_eu_motor_config *rd = (struct s_eu_motor_config *)readbuff;
 struct s_eu_motor_config *wr = (struct s_eu_motor_config *)writebuff;

 wr->cmd.name =  5 ;
 if ( rd->number >= 0 && rd->number < 8 )
 {
 wr->number = rd->number;
 wr->state = (motors_state & (1 << rd->number)) ?  1  :  0 ;
 wr->protect = motors[rd->number].protect;
 wr->start_time = motors[rd->number].start_time / 10;
 wr->cmd.result =  0 ;
 }
 else
 {
 wr->cmd.result =  4 ;
 }
 }
 break;


 case  6 :
 {
 struct s_eu_motor_config *rd = (struct s_eu_motor_config *)readbuff;
 struct s_eu_motor_config *wr = (struct s_eu_motor_config *)writebuff;

 wr->cmd.name =  6 ;
 if ( rd->number >= 0 && rd->number < 8 )
 {
 char i, enable =  1 ;


 if ( rd->protect )
 {
 for ( i = 0; i < rd->number; ++i )
 if ( !motors[i].protect )
 enable =  0 ;
 }
 else
 {
 for ( i = 8 - 1; i > rd->number; --i )
 if ( motors[i].protect )
 enable =  0 ;
 }


 if ( enable )
 {
 motor_stop(rd->number,  0 );

 if ( write_config_byte(0x01 + (rd->number * 3), rd->protect) && write_config_word(0x02 + (rd->number * 3), rd->start_time * 10) )
 {
 motors[rd->number].protect = rd->protect;
 motors[rd->number].start_time = rd->start_time * 10;

 protected_motors = motor_get_protected();

 wr->cmd.result =  0 ;
 }
 else
 {
 wr->cmd.result =  6 ;
 }
 }
 else
 {
 wr->cmd.result =  5 ;
 }
 }
 else
 {
 wr->cmd.result =  4 ;
 }
 }
 break;


 case  7 :
 {
 struct s_eu_motor_state *rd = (struct s_eu_motor_state *)readbuff;
 struct s_eu_motor_state *wr = (struct s_eu_motor_state *)writebuff;

 wr->cmd.name =  7 ;
 if ( rd->number >= 0 && rd->number < 8 )
 {
 wr->state = (motors_state & (1 << rd->number)) ?  1  :  0 ;
 wr->cmd.result =  0 ;
 }
 else
 {
 wr->cmd.result =  4 ;
 }
 }
 break;


 case  8 :
 {
 struct s_eu_motor_state *rd = (struct s_eu_motor_state *)readbuff;
 struct s_eu_motor_state *wr = (struct s_eu_motor_state *)writebuff;

 wr->cmd.name =  8 ;
 if ( rd->number >= 0 && rd->number < 8 )
 {
 if ( rd->state )
 motor_start(rd->number);
 else
 motor_stop(rd->number,  0 );

 wr->cmd.result =  0 ;
 }
 else
 {
 wr->cmd.result =  4 ;
 }
 }
 break;


 case  9 :
 {
 struct s_eu_unit_state *rd = (struct s_eu_unit_state *)readbuff;
 struct s_eu_unit_state *wr = (struct s_eu_unit_state *)writebuff;

 wr->cmd.name =  9 ;
 wr->state = is_connected;
 wr->cmd.result =  0 ;
 }
 break;


 case  10 :
 {
 struct s_eu_config_data *rd = (struct s_eu_config_data *)readbuff;
 struct s_eu_config_data *wr = (struct s_eu_config_data *)writebuff;

 wr->cmd.name =  10 ;

 if ( !(rd->magic[0] == 'E' && rd->magic[1] == 'C' && rd->magic[2] == 'O' && rd->magic[3] == 'N' && rd->magic[4] == 'F') )
 {
 wr->cmd.result =  8 ;
 }
 else
 {
 if ( crc16(rd->magic, 30) == rd->check_sum )
 {
 uchar res =  1 ;
 uchar i;
 uchar *p;

 res = write_config_byte(0x00, rd->number);

 p = rd->protect;
 for ( i = 0; i < 24; i += 3 )
 {
 res &= write_config_byte(0x01 + i, *(uchar *)p);
 p += 1;
 res &= write_config_word(0x02 + i, *(ushort *)p);
 p += 2;
 }

 if ( res )
 {
 wr->cmd.result =  0 ;
 reboot_needed =  1 ;
 }
 else
 wr->cmd.result =  6 ;
 }
 else
 {
 wr->cmd.result =  9 ;
 }
 }
 }
 break;


 case  11 :
 {
 struct s_eu_config_data *rd = (struct s_eu_config_data *)readbuff;
 struct s_eu_config_data *wr = (struct s_eu_config_data *)writebuff;
 uchar i;
 uchar *p;

 wr->cmd.name =  11 ;

 wr->magic[0] = 'E';
 wr->magic[1] = 'C';
 wr->magic[2] = 'O';
 wr->magic[3] = 'N';
 wr->magic[4] = 'F';
 wr->number = unit_number;

 p = wr->protect;
 for ( i = 0; i <  8 ; ++i )
 {
 *(uchar *)p = motors[i].protect;
 p += 1;
 *(ushort *)p = motors[i].start_time;
 p += 2;
 }

 wr->check_sum = crc16(wr->magic, 30);

 wr->cmd.result =  0 ;
 }
 break;


 default:
 {
 struct s_cmd_header *wr = (struct s_cmd_header *)writebuff;
 memset(writebuff, 0,  64 );
 wr->name =  0 ;
 wr->result =  1 ;
 }
 }

 usb_write();
 }
 }
}


void reboot_check( )
{
 if ( reboot_needed )
 {

 if ( usb_state_on )
 usb_off();


 delay_ms(1000);


 __asm reset
 }
}


void main()
{
 delay_ms(1000);

 init();

 transceiver_init();

 hc165_init();

 motor_init();

 load_config();

 timer1_init();

 net_init(5);

 net_set_params(unit_number, 20);


 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 while (  1  )
 {

 exec_commands();


 if ( motor_read(&motors_state) || changes )
 if ( net_send( 254 ,  12 , (uchar *)&motors_state, 0) == 0 )
 motor_reset_fail_state();


 if ( sensors_read(&sensors_state) || changes )
 net_send( 254 ,  10 , (uchar *)&sensors_state, 0);


 motor_protect_control();


 pc_data_exchange();


 changes =  0 ;


 reboot_check();
 }
}
