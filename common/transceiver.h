// Интрефейс взаимодействия с приемопередатчиком //
#define PULSE_TIME 10

// Инициализация
void transceiver_init( )
{
    COMM_WR_DIR         = 0;      // COMM_WR         - выход
    COMM_WR_PIN         = 1;
    COMM_RD_DIR         = 0;      // COMM_RD         - выход
    COMM_RD_PIN         = 1;
    COMM_CLK_DIR        = 0;      // COMM_CLK        - выход
    COMM_CLK_PIN        = 0;
    COMM_DATA_DIR       = 0;      // COMM_DATA       - выход
    COMM_DATA_PIN       = 0;
    COMM_DATA_READY_DIR = 1;      // COMM_DATA_READY - вход
    
    delay_ms(50);
}

// Передача данных
// cmd - команда (5 байт)
// result - результат выполнения. 
// если это отправка пакета, то при успешной отправке все байты result совпадают с cmd
// иначе result заполнен нулями
// если отправка конфигурационной команды, result содержит результат выполения команды
// при успешном выполнении возвращается 1, если передача была отклонена по причине 
// занятости приемопередтчика, то 0

unsigned char transceiver_send( unsigned char *cmd, unsigned char *result )
{
    signed char i, n;
    unsigned char d[5];
    
    memcpy(d, cmd, 5); // Копируем команду во временный буфер

    COMM_WR_PIN  = 0;  // Запись
    COMM_RD_PIN  = 1;  //
    COMM_CLK_PIN = 0;

    while ( !COMM_DATA_READY_PIN ); // Ждем готовности записи

    if ( !COMM_DATA_READY_PIN ) // Запись отклонена
    {
        COMM_WR_PIN = 1; // Запись запрeщена
        return 0;
    }

    COMM_DATA_DIR = 0;  // Выход

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

    memset(d, 0, 5); // после записи очищаем буфер 

    // читаем результат

    COMM_DATA_DIR = 1;  // Вход
    COMM_WR_PIN   = 1;  // Запись запрещена
    COMM_RD_PIN   = 0;

    while ( COMM_DATA_READY_PIN ); // Ждем готовности чтения

    GIE_bit = 0;

    for ( n = 4; n >= 0; --n )
    {
        for ( i = 0; i < 8; ++i )
        {
          COMM_CLK_PIN = 1;
          delay_us(PULSE_TIME);

          d[n] <<= 1;             // Сдвиг
          if ( COMM_DATA_PIN )    // Единица
              d[n] |= 1;

          COMM_CLK_PIN = 0;
          delay_us(PULSE_TIME);
        }
    }

    GIE_bit = 1;

    COMM_WR_PIN = 1; // Запись запрещена
    COMM_RD_PIN = 1; // Чтение запрещено

    memcpy(result, d, 5);
    
    return 1;
}


// Прием данных
// result - принятая команда, если все байты равны 0, буфер приемопередатчика пуст 
// при успешном выполнении возвращается 1, если прием была отклонен по причине 
// занятости приемопередтчика, то 0

unsigned char transceiver_recv( unsigned char *result )
{
    signed char i, n;
    unsigned char d[5];

    memset(d, 0, 5);

    COMM_DATA_DIR = 1;

    COMM_WR_PIN  = 0;  // Запись
    COMM_RD_PIN  = 0;  //
    COMM_CLK_PIN = 0;

    delay_ms(1); // Ждем готовности записи

    if ( !COMM_DATA_READY_PIN ) // Запись отклонена
    {
        COMM_WR_PIN = 1; // Запись запрещена
        COMM_RD_PIN = 1; // Запись запрещена
        return 0;
    }

    GIE_bit = 0;

    for ( n = 4; n >= 0; --n )
    {
        for ( i = 0; i < 8; ++i )
        {
            COMM_CLK_PIN = 1;
            delay_us(PULSE_TIME);

            d[n] <<= 1;           // Сдвиг
            if ( COMM_DATA_PIN )  // Единица
                d[n] |= 1;

            COMM_CLK_PIN = 0;
            delay_us(PULSE_TIME);
        }
    }

    GIE_bit = 1;

    COMM_WR_PIN = 1; // Запись запрещена
    COMM_RD_PIN = 1; // Чтение запрещено

    memcpy(result, d, 5);
    
    return 1;
}