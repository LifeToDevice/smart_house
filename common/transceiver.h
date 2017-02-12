// ��������� �������������� � ������������������ //
#define PULSE_TIME 10

// �������������
void transceiver_init( )
{
    COMM_WR_DIR         = 0;      // COMM_WR         - �����
    COMM_WR_PIN         = 1;
    COMM_RD_DIR         = 0;      // COMM_RD         - �����
    COMM_RD_PIN         = 1;
    COMM_CLK_DIR        = 0;      // COMM_CLK        - �����
    COMM_CLK_PIN        = 0;
    COMM_DATA_DIR       = 0;      // COMM_DATA       - �����
    COMM_DATA_PIN       = 0;
    COMM_DATA_READY_DIR = 1;      // COMM_DATA_READY - ����
    
    delay_ms(50);
}

// �������� ������
// cmd - ������� (5 ����)
// result - ��������� ����������. 
// ���� ��� �������� ������, �� ��� �������� �������� ��� ����� result ��������� � cmd
// ����� result �������� ������
// ���� �������� ���������������� �������, result �������� ��������� ��������� �������
// ��� �������� ���������� ������������ 1, ���� �������� ���� ��������� �� ������� 
// ��������� ����������������, �� 0

unsigned char transceiver_send( unsigned char *cmd, unsigned char *result )
{
    signed char i, n;
    unsigned char d[5];
    
    memcpy(d, cmd, 5); // �������� ������� �� ��������� �����

    COMM_WR_PIN  = 0;  // ������
    COMM_RD_PIN  = 1;  //
    COMM_CLK_PIN = 0;

    while ( !COMM_DATA_READY_PIN ); // ���� ���������� ������

    if ( !COMM_DATA_READY_PIN ) // ������ ���������
    {
        COMM_WR_PIN = 1; // ������ ����e����
        return 0;
    }

    COMM_DATA_DIR = 0;  // �����

    GIE_bit = 0;

    for ( n = 4; n >= 0; --n )
    {
        for ( i = 0; i < 8; ++i )
        {
            if ( d[n] & 0x80 )
                COMM_DATA_PIN = 1;
            else
                COMM_DATA_PIN = 0;

            COMM_CLK_PIN = 1;
            delay_us(PULSE_TIME);
            COMM_CLK_PIN = 0;
            delay_us(PULSE_TIME);   //?????

            d[n] <<= 1;
        }
    }

    GIE_bit = 1;

    memset(d, 0, 5); // ����� ������ ������� ����� 

    // ������ ���������

    COMM_DATA_DIR = 1;  // ����
    COMM_WR_PIN   = 1;  // ������ ���������
    COMM_RD_PIN   = 0;

    while ( COMM_DATA_READY_PIN ); // ���� ���������� ������

    GIE_bit = 0;

    for ( n = 4; n >= 0; --n )
    {
        for ( i = 0; i < 8; ++i )
        {
          COMM_CLK_PIN = 1;
          delay_us(PULSE_TIME);

          d[n] <<= 1;             // �����
          if ( COMM_DATA_PIN )    // �������
              d[n] |= 1;

          COMM_CLK_PIN = 0;
          delay_us(PULSE_TIME);
        }
    }

    GIE_bit = 1;

    COMM_WR_PIN = 1; // ������ ���������
    COMM_RD_PIN = 1; // ������ ���������

    memcpy(result, d, 5);
    
    return 1;
}


// ����� ������
// result - �������� �������, ���� ��� ����� ����� 0, ����� ����������������� ���� 
// ��� �������� ���������� ������������ 1, ���� ����� ���� �������� �� ������� 
// ��������� ����������������, �� 0

unsigned char transceiver_recv( unsigned char *result )
{
    signed char i, n;
    unsigned char d[5];

    memset(d, 0, 5);

    COMM_DATA_DIR = 1;

    COMM_WR_PIN  = 0;  // ������
    COMM_RD_PIN  = 0;  //
    COMM_CLK_PIN = 0;

    delay_ms(1); // ���� ���������� ������

    if ( !COMM_DATA_READY_PIN ) // ������ ���������
    {
        COMM_WR_PIN = 1; // ������ ���������
        COMM_RD_PIN = 1; // ������ ���������
        return 0;
    }

    GIE_bit = 0;

    for ( n = 4; n >= 0; --n )
    {
        for ( i = 0; i < 8; ++i )
        {
            COMM_CLK_PIN = 1;
            delay_us(PULSE_TIME);

            d[n] <<= 1;           // �����
            if ( COMM_DATA_PIN )  // �������
                d[n] |= 1;

            COMM_CLK_PIN = 0;
            delay_us(PULSE_TIME);
        }
    }

    GIE_bit = 1;

    COMM_WR_PIN = 1; // ������ ���������
    COMM_RD_PIN = 1; // ������ ���������

    memcpy(result, d, 5);
    
    return 1;
}