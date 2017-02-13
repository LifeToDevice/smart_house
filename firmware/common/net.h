static net_send_attempts = 1;

void net_init( char send_attempts )
{
    net_send_attempts = send_attempts;
}

// ��������� ���������� �����������������
// addr - �����
// ack_wait_time - ����� �������� ��������������� �������� ������

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

// ��������
// addr - �����
// cmd  - ����� �������
// dat  - ������ (3 �����)
// ������������ ������� 0 - �������, 1 - ����� ������, 2 - ����� �� �������
unsigned char _net_send( unsigned char addr, unsigned char cmd, unsigned char *dat )
{
    uchar d[5];
    uchar res[5];

    memset(res, 0, 5);

    d[0] = addr;  // �����
    d[1] = cmd;   // �������
    d[2] = 0;     // ������ (���� 1)
    d[3] = 0;     // ������ (���� 2)
    d[4] = 0;     // ������ (���� 3)

    if ( dat )    // ���� � �������� ���������� ������
         memcpy(&d[2], dat, 3);

    if ( !transceiver_send(d, res) )
        return 1;  // ����� ������

    return !memcmp(d, res, 5) ? 0 : 2;
}

// �������� � ��������� ���������� �������
// addr     - �����
// cmd      - ����� �������
// dat      - ������ (3 �����)
// attempts - ����� ���������� ������� ��������, ���� ���������� �������� ��������� ���������
// ������������ ������� 0 - �������, 1 - ����� ������, 2 - ����� �� �������
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
            Delay_ms(100); // ��������
    }
    
    return res;
}