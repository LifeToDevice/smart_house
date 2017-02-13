// ������ ���������� EEPROM
unsigned char ee_read( unsigned char addr )
{
    while ( WR_bit );                                                           // ���� ���� ������, ����
    EEADR     = addr;                                                           // ������������� �����
    EEPGD_bit = 0;                                                              // ��������� � EEPROM
    CFGS_bit  = 0;                                                              // ��������� � EEPROM
    RD_bit    = 1;                                                              // ������ ������
    return EEDATA;                                                              // ���������� ��������
}

// ������ ���������� EEPROM
unsigned char ee_write( unsigned char addr, unsigned char val )
{
    char int_state = GIE_bit;                                                   // ���������� ��������� ����������
    while ( WR_bit );                                                           // ���� ���� ������, ����
    EEADR     = addr;                                                           // ������������� �����
    EEDATA    = val;                                                            // ������������� ������������ ������
    EEPGD_bit = 0;                                                              // ��������� � EEPROM
    CFGS_bit  = 0;                                                              // ��������� � EEPROM
    WREN_bit  = 1;                                                              // ��������� ������
    GIE_bit   = 0;                                                              // ��������� ����������
    EECON2    = 0x55;                                                           // ������������� 0x55
    EECON2    = 0xAA;                                                           // ������������� 0xAA
    WR_bit    = 1;                                                              // ������ ������
    GIE_bit   = int_state;                                                      // ��������������� ��������� ����������
    WREN_bit  = 0;                                                              // ��������� ������
    while ( WR_bit );                                                           // ������� ��������� ������
    return (WRERR_bit == 0);                                                    // ���������� ��������� ����������
}