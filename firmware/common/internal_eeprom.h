// Чтение внутренней EEPROM
unsigned char ee_read( unsigned char addr )
{
    while ( WR_bit );                                                           // Если идет запись, ждем
    EEADR     = addr;                                                           // Устанавливаем адрес
    EEPGD_bit = 0;                                                              // Обращение к EEPROM
    CFGS_bit  = 0;                                                              // Обращение к EEPROM
    RD_bit    = 1;                                                              // Запуск чтения
    return EEDATA;                                                              // Возвращаем значение
}

// Запись внутренней EEPROM
unsigned char ee_write( unsigned char addr, unsigned char val )
{
    char int_state = GIE_bit;                                                   // Запоминаем состояние прерываний
    while ( WR_bit );                                                           // Если идет запись, ждем
    EEADR     = addr;                                                           // Устанавливаем адрес
    EEDATA    = val;                                                            // Устанавливаем записываемые данные
    EEPGD_bit = 0;                                                              // Обращение к EEPROM
    CFGS_bit  = 0;                                                              // Обращение к EEPROM
    WREN_bit  = 1;                                                              // Разрешаем запись
    GIE_bit   = 0;                                                              // Запрещаем прерывания
    EECON2    = 0x55;                                                           // Устанавливаем 0x55
    EECON2    = 0xAA;                                                           // Устанавливаем 0xAA
    WR_bit    = 1;                                                              // Запуск записи
    GIE_bit   = int_state;                                                      // Восстанавливаем состояние прерывания
    WREN_bit  = 0;                                                              // Запрещаем запись
    while ( WR_bit );                                                           // Ожидаем окончания записи
    return (WRERR_bit == 0);                                                    // Возвращаем результат выволнения
}