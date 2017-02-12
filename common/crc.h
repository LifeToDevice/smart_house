/*
  Name  : CRC-8
  Poly  : 0x31    x^8 + x^5 + x^4 + 1
  Init  : 0xFF
  Revert: false
  XorOut: 0x00
  Check : 0xF7 ("123456789")
  MaxLen: 15 байт(127 бит) - обнаружение
  одинарных, двойных, тройных 
  и всех нечетных ошибок
*/

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

/*
  Name  : CRC-16 CCITT
  Poly  : 0x1021    x^16 + x^12 + x^5 + 1
  Init  : 0xFFFF
  Revert: false
  XorOut: 0x0000
  Check : 0x29B1 ("123456789")
  MaxLen: 4095 байт (32767 бит) - обнаружение
    одинарных, двойных, тройных и всех нечетных ошибок
*/

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