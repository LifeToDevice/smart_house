static net_send_attempts = 1;

void net_init( char send_attempts )
{
    net_send_attempts = send_attempts;
}

// Установка параметров приемопередатчика
// addr - адрес
// ack_wait_time - время ожидания подтверждающего отвеного пакета

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

// Отправка
// addr - адрес
// cmd  - номер команды
// dat  - данные (3 байта)
// Возвращаемое знаение 0 - успешно, 1 - линия занята, 2 - ответ не получен
unsigned char _net_send( unsigned char addr, unsigned char cmd, unsigned char *dat )
{
    uchar d[5];
    uchar res[5];

    memset(res, 0, 5);

    d[0] = addr;  // адрес
    d[1] = cmd;   // команда
    d[2] = 0;     // Данные (байт 1)
    d[3] = 0;     // Данные (байт 2)
    d[4] = 0;     // Данные (байт 3)

    if ( dat )    // Если с командой передаются данные
         memcpy(&d[2], dat, 3);

    if ( !transceiver_send(d, res) )
        return 1;  // Линия занята

    return !memcmp(d, res, 5) ? 0 : 2;
}

// Отправка с указанием количества попыток
// addr     - адрес
// cmd      - номер команды
// dat      - данные (3 байта)
// attempts - общее количество попыток отправки, если предыдущая отправка оказалась неудачной
// Возвращаемое знаение 0 - успешно, 1 - линия занята, 2 - ответ не получен
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
            Delay_ms(100); // подождем
    }
    
    return res;
}