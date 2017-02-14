#line 1 "C:/Users/GL/Downloads/‘айлы Mail.Ru јгента/grishin-d@mail.ru/Ёлеватор_V1.8.8/transceiver/transceiver.c"
#line 117 "C:/Users/GL/Downloads/‘айлы Mail.Ru јгента/grishin-d@mail.ru/Ёлеватор_V1.8.8/transceiver/transceiver.c"
struct s_data_queue
{
 unsigned char b[ 5 ];
};


unsigned char device_addr = 0;
unsigned char packet_num = 0;

unsigned char send_buf[ 8 ];
unsigned char recv_buf[ 8 ];

struct s_data_queue data_queue[ 16 ];
unsigned char data_queue_size = 0;

unsigned char bit_time = 0;
unsigned char recv_byte = 0;
unsigned char recv_bit_counter = 0;
unsigned char recv_byte_counter = 0;

bit recv_done;
bit recv_processing;

bit comm_clk_prev_state;
bit comm_wr_processed;
bit comm_rd_complete;
struct s_data_queue comm_cmd;

unsigned char ack_timeout = 100;

void interrupt( )
{
 if ( TMR0IF_bit )
 {
 TMR0IF_bit = 0;
 recv_done = 0;
 recv_processing = 0;
 }

 if ( INTF_bit )
 {
 INTF_bit = 0;

 if ( recv_done == 0 )
 {
 if ( recv_processing == 0 )
 {
 recv_processing = 1;
 recv_byte = 0;
 recv_bit_counter = 0;
 recv_byte_counter = 0;
 TMR0 = 0;
 }
 else
 {
 bit_time = TMR0;

 if ( (bit_time > 20) && (bit_time < 30) )
 {
 recv_byte <<= 1;
 recv_byte |= 1;
 }

 if ( bit_time > 8 && bit_time < 16 )
 {
 recv_byte <<= 1;
 asm {nop};
 }

 if ( ++recv_bit_counter == 8 )
 {
 recv_buf[recv_byte_counter] = recv_byte;
 recv_byte = 0;
 recv_bit_counter = 0;

 if ( ++recv_byte_counter ==  8  )
 recv_done = 1;
 }

 TMR0 = 0;
 }
 }
 }
}
#line 217 "C:/Users/GL/Downloads/‘айлы Mail.Ru јгента/grishin-d@mail.ru/Ёлеватор_V1.8.8/transceiver/transceiver.c"
unsigned char crc8( unsigned char *block )
{
 unsigned char crc = 0xFF;
 unsigned char len =  8  - 1;
 unsigned char i;

 while ( len-- )
 {
 crc ^= *block++;
 for ( i = 0; i < 8; i++ )
 crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
 }

 return crc;
}



void send_data( unsigned char *d, unsigned char size )
{
 unsigned char b, i;

 while ( size-- )
 {
 b = *d++;

 for ( i = 0; i < 8; i++ )
 {
  RB2_bit  = 0;
 Delay_us( 10 );
  RB2_bit  = 1;

 if ( b & 0b10000000 )
 Delay_us( 30 );
 else
 Delay_us( 10 );

 b <<= 1;
 }
 }


  RB2_bit  = 0;
 Delay_us( 10 );
  RB2_bit  = 1;
}


void send_ack( unsigned char *bf )
{
 Delay_us(500);

 send_buf[0] = device_addr;
 send_buf[1] = bf[0];
 send_buf[2] = bf[2] | 0b10000000;
 send_buf[3] = 0;
 send_buf[4] = 0;
 send_buf[5] = 0;
 send_buf[6] = 0;
 send_buf[7] = crc8(send_buf);

  { RB1_bit  = 1; RB2_bit  = 0; } ;

 send_data(send_buf,  8 );

  { RB1_bit  = 0; RB2_bit  = 0; } ;
}


unsigned char send_packet( unsigned char *cmd )
{
 unsigned char res =  2 ;
 signed char ack_wait = ack_timeout;

 if ( ++packet_num > 127 )
 packet_num = 0;

 send_buf[0] = device_addr;
 send_buf[1] = cmd[0];
 send_buf[2] = packet_num;
 send_buf[3] = cmd[1];
 send_buf[4] = cmd[2];
 send_buf[5] = cmd[3];
 send_buf[6] = cmd[4];
 send_buf[7] = crc8(send_buf);

 recv_done = 0;
 recv_processing = 0;

  { RB1_bit  = 1; RB2_bit  = 0; } ;

 send_data(send_buf,  8 );

  { RB1_bit  = 0; RB2_bit  = 0; } ;


 INTCON.T0IE = 0;
 TMR0 = 0;

  { INTCON.GIE = 1; } ;

 while ( ack_wait-- > 0 )
 {
 if ( recv_done )
 {
  { INTCON.GIE = 0; } ;

 if ( crc8(recv_buf) == recv_buf[ 8  - 1] )
 {
 if ( recv_buf[2] & 0b10000000 )
 {
 if ( (recv_buf[0] == cmd[0]) && (recv_buf[1] == device_addr) && ((recv_buf[2] & 0b01111111) == packet_num) )
 {
 res =  0 ;
 break;
 }
 }
 }
 recv_processing = 0;
 recv_done = 0;

  { INTCON.GIE = 1; } ;
 }

 Delay_ms(1);
 }

  { INTCON.GIE = 0; } ;

 INTCON.T0IE = 1;

 recv_processing = 0;
 recv_done = 0;

 return res;
}


void push_command( )
{
 if ( data_queue_size ==  16  - 1 )
 return;

 data_queue[data_queue_size].b[0] = recv_buf[0];
 data_queue[data_queue_size].b[1] = recv_buf[3];
 data_queue[data_queue_size].b[2] = recv_buf[4];
 data_queue[data_queue_size].b[3] = recv_buf[5];
 data_queue[data_queue_size].b[4] = recv_buf[6];

 data_queue_size++;
}


void pop_command( struct s_data_queue *cmd )
{
 unsigned char i;

 if ( data_queue_size == 0 )
 return;

 memcpy(cmd, &data_queue[0], sizeof(struct s_data_queue));

 for ( i = 0; i < data_queue_size - 1; ++i )
 memcpy(&data_queue[i], &data_queue[i + 1], sizeof(struct s_data_queue));

 data_queue_size--;
}


void process_received_packet( )
{
 if ( recv_done )
 {
  { INTCON.GIE = 0; } ;

 if ( crc8(recv_buf) == recv_buf[ 8  - 1] )
 {
 if ( (recv_buf[1] == device_addr) && !(recv_buf[2] & 0b10000000) )
 {
 send_ack(recv_buf);
 push_command();
 }
 }

 recv_processing = 0;
 recv_done = 0;

  { INTCON.GIE = 1; } ;
 }
}


void comm_read( )
{
 unsigned char i, n;

 i =  5  - 1;
 n = 0;

 memset(&comm_cmd, 0, sizeof(struct s_data_queue));


 comm_clk_prev_state = 0;
 comm_rd_complete = 0;

  RB7_bit  = 0;

  { INTCON.GIE = 0; } ;

 if ( recv_processing )
 {
  { INTCON.GIE = 1; } ;
 return;
 }

 while ( ! RB3_bit  &&  RB4_bit  )
 {
 comm_rd_complete = 1;
  TRISB6_bit  = 1;
  RB7_bit  = 1;

 if (  RB5_bit  && comm_clk_prev_state == 0 )
 {
 comm_clk_prev_state = 1;

 comm_cmd.b[i] <<= 1;
 if (  RB6_bit  )
 comm_cmd.b[i] |= 1;

 if ( ++n >= 8 )
 {
 if ( i )
 i--;
 n = 0;
 }
 }

 if ( ! RB5_bit  )
 comm_clk_prev_state = 0;
 }

 comm_clk_prev_state = 0;


 if ( comm_rd_complete )
 {
 if ( comm_cmd.b[0] == 255 )
 {
 device_addr = comm_cmd.b[1];
 ack_timeout = comm_cmd.b[2];
 Delay_ms(50);
 }
 else
 {
 if ( send_packet(comm_cmd.b) ==  2  )
 memset(&comm_cmd, 0, sizeof(struct s_data_queue));
 }
 }

 i =  5  - 1;
 n = 0;
 while ( ! RB4_bit  &&  RB3_bit  )
 {
  TRISB6_bit  = 0;
  RB7_bit  = 0;

 if (  RB5_bit  && comm_clk_prev_state == 0 )
 {
 comm_clk_prev_state = 1;

 if ( comm_cmd.b[i] & 0x80 )
  RB6_bit  = 1;
 else
  RB6_bit  = 0;

 comm_cmd.b[i] <<= 1;
 if ( ++n >= 8 )
 {
 if ( i )
 i--;
 n = 0;
 }
 }

 if ( ! RB5_bit  )
 comm_clk_prev_state = 0;
 }

  RB7_bit  = 0;
  TRISB6_bit  = 1;

  { INTCON.GIE = 1; } ;
}




void comm_write( )
{
 unsigned char i, n;

 i =  5  - 1;
 n = 0;

 memset(&comm_cmd, 0, sizeof(struct s_data_queue));


 comm_clk_prev_state = 0;
 comm_wr_processed = 0;

  RB7_bit  = 0;

  { INTCON.GIE = 0; } ;

 if ( recv_processing || data_queue_size == 0 )
 {
  { INTCON.GIE = 1; } ;
 return;
 }

 while ( ! RB4_bit  && ! RB3_bit  )
 {
 if ( !comm_wr_processed )
 {
 comm_wr_processed = 1;

 if ( data_queue_size )
 {
 i =  5  - 1;
 n = 0;
 pop_command(&comm_cmd);
  TRISB6_bit  = 0;
  RB7_bit  = 1;
 }
 }

 if (  RB5_bit  && comm_clk_prev_state == 0 )
 {
 comm_clk_prev_state = 1;

 if ( comm_cmd.b[i] & 0x80 )
  RB6_bit  = 1;
 else
  RB6_bit  = 0;

 comm_cmd.b[i] <<= 1;
 if ( ++n >= 8 )
 {
 if ( i )
 i--;
 n = 0;
 }
 }

 if ( ! RB5_bit  )
 comm_clk_prev_state = 0;
 }

  RB7_bit  = 0;
  TRISB6_bit  = 1;

  { INTCON.GIE = 1; } ;
}


void main()
{
 unsigned long led_counter = 0;

 CMCON = 0x07;

  TRISA1_bit  = 0;
  RA1_bit  = 0;

  TRISB3_bit  = 1;
  TRISB4_bit  = 1;
  TRISB5_bit  = 1;
  TRISB6_bit  = 1;
  TRISB7_bit  = 0;
  RB7_bit  = 0;

  TRISB0_bit  = 1;
  TRISB1_bit  = 0;
  TRISB2_bit  = 0;

  { RB1_bit  = 0; RB2_bit  = 0; } ;

 OPTION_REG.INTEDG = 1;
 OPTION_REG.T0CS = 0;
 OPTION_REG.PSA = 0;
 OPTION_REG.PS2 = 0;
 OPTION_REG.PS1 = 1;
 OPTION_REG.PS0 = 0;

 INTCON.PEIE = 1;
 INTCON.T0IE = 1;
 INTCON.INTE = 1;

 recv_done = 0;
 recv_processing = 0;
 comm_clk_prev_state = 0;
 comm_rd_complete = 0;
 comm_wr_processed = 0;

  { INTCON.GIE = 1; } ;

 while ( 1 )
 {
 process_received_packet();

 comm_read();

 comm_write();

 if ( led_counter++ > 10000 )
 {
 led_counter = 0;
  RA1_bit  = ~ RA1_bit ;
 }
 }
}
