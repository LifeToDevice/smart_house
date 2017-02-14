/***********************************************************************************************************************

 Структура пакета

 |-------------------------------------------------------------------------------------------------------------------------------|
 |                                                            8 BYTES                                                            |
 |---------------|---------------|---------------|---------------|---------------|---------------|---------------|---------------|
 |7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|
 |---------------|---------------|-|-------------|---------------|---------------|---------------|---------------|---------------|
 |               |               |A|             |               |               |               |               |               |
 |    SRC ADDR   |   DST ADDR    |C|   NUMBER    |     DATA1     |     DATA2     |     DATA3     |     DATA4     |   CHECKSUM    |
 |               |               |K|             |               |               |               |               |               |
 |---------------|---------------|-|-------------|---------------|---------------|---------------|---------------|---------------|

 SRC ADDR  - адрес отправителя                   - 8 бит (1..255)
 DST ADDR  - адрес получателя                    - 8 бит (1..255)
 ACK       - бит подтверждения                   - 1 бит (0..1)
 NUMBER    - номер пакета                        - 7 бит (1..127)
 DATA1     - данные (байт 1)                     - 8 бит
 DATA2     - данные (байт 2)                     - 8 бит
 DATA3     - данные (байт 3)                     - 8 бит
 DATA4     - данные (байт 4)                     - 8 бит
 CHECKSUM  - контрольная сумма предыдущих 6 байт - 8 бит
 
 -----------------------------------------------------------------------------------------------------------------------
 
 Структура команды
                                                
 |-----------------------------------------------------------------------------------------------------------------------|
 |                                                    DWORD (5 BYTES)                                                    |
 |-----------------------|-----------------------|-----------------------|-----------------------|-----------------------|
 |39|38|37|36|35|34|33|32|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|8 |8 |7 |6 |5 |4 |3 |2 |1 |0 |
 |-----------------------|-----------------------|-----------------------|-----------------------|-----------------------|
 |         СONFIG        |           CMD         |                       |                       |                       |
 |           /           |            /          |         DATA2         |         DATA3         |         DATA4         |
 |        DST ADDR       |          DATA1        |                       |                       |                       |
 |-----------------------|-----------------------|-----------------------|-----------------------|-----------------------|
                          
 CONFIG(DST ADDR) - 0 - установка параметров, 1..255 - адрес получателя   - 8 бит
 CMD(DATA1)       - если CONFIG = 0 - команда, иначе данные (байт 1)      - 8 бит
 DATA2            - если CONFIG = 0 - параметр 1, иначе данные (байт 2)   - 8 бит
 DATA3            - если CONFIG = 0 - параметр 2, иначе данные (байт 3)   - 8 бит
 DATA4            - если CONFIG = 0 - параметр 3, иначе данные (байт 4)   - 8 бит

***********************************************************************************************************************/


// Пины управления MAX485
#define RO_PIN                  RB0_bit                                         // Receiver output pin
#define RO_DIR                  TRISB0_bit                                      // Receiver output direction

#define DI_PIN                  RB2_bit                                         // Driver input pin
#define DI_DIR                  TRISB2_bit                                      // Driver input direction

#define DE_RE_PIN               RB1_bit                                         // Driver enable/Receiver enable pin
#define DE_RE_DIR               TRISB1_bit                                      // Driver enable/Receiver direction

// Пины интерфейса обмена данными с мастер устройством
#define COMM_WR_PIN             RB3_bit                                         // Write enable
#define COMM_WR_DIR             TRISB3_bit                                      // Write enable direction

#define COMM_RD_PIN             RB4_bit                                         // Read enable
#define COMM_RD_DIR             TRISB4_bit                                      // Read enable direction

#define COMM_CLK_PIN            RB5_bit                                         // Clock
#define COMM_CLK_DIR            TRISB5_bit                                      // Clock direction

#define COMM_DATA_PIN           RB6_bit                                         // Data
#define COMM_DATA_DIR           TRISB6_bit                                      // Data direction

#define COMM_DATA_READY_PIN     RB7_bit                                         // Data ready
#define COMM_DATA_READY_DIR     TRISB7_bit                                      // Data ready direction

#define LED_PIN                 RA1_bit
#define LED_DIR                 TRISA1_bit

// Результат отправки пакета
#define ERR_OK                  0                                               // Успешно
#define ERR_BUS_BUSY            1                                               // Линия занята
#define ERR_PACKET_LOST         2                                               // Пакет потерян


/*
// Временные интервалы кодирования
#define BIT_START_TIME          20                                              // Время стартового условия передачи бита
#define BIT_ONE_TIME            2000                                            // Время кодирования 1
#define BIT_ZERO_TIME           1000                                            // Время кодирования 0  */

#define BIT_START_TIME          10                                              // Время стартового условия передачи бита
#define BIT_ONE_TIME            30                                              // Время кодирования 1
#define BIT_ZERO_TIME           10                                              // Время кодирования 0


// Временные интервалы приема битов
#define HI_TIME_MIN             55                                              // Минимальное время кодирования 1
#define HI_TIME_MAX             65                                              // Максимальное время кодирования 1
#define LO_TIME_MIN             28                                              // Минимальное время кодирования 0
#define LO_TIME_MAX             36                                              // Максимальное время кодирования 0

// Размеры буферов
#define PACKET_SIZE             8                                               // Размер пакета (в байтах)
#define COMMAND_SIZE            5                                               // Размер команды (в байтах)

#define QUEUE_SIZE              16                                              // Максимальный размер очереди принятых команд (в командах)

// Время ожидания подтверждения (мс)
//#define ACK_TIMEOUT             10

// Управление MAX485
#define MAX485_TRANSMIT         { DE_RE_PIN = 1; DI_PIN = 0; }                  // Режим передачи
#define MAX485_RECEIVE          { DE_RE_PIN = 0; DI_PIN = 0; }                  // Режим приема

// Прерывания
#define INT_ENABLE              { INTCON.GIE = 1; }                             // Все прерывания разрешены
#define INT_DISABLE             { INTCON.GIE = 0; }                             // Все прерывания запрещены

struct s_data_queue
{
    unsigned char b[COMMAND_SIZE];
};

// Глобальные переменные
unsigned char device_addr = 0;                                                  // Адрес устройства ( 0 .. 254 )
unsigned char packet_num = 0;                                                   // Номер пакета ( 1..127 )

unsigned char send_buf[PACKET_SIZE];                                            // Буфер передачи
unsigned char recv_buf[PACKET_SIZE];                                            // Буфер приема

struct s_data_queue data_queue[QUEUE_SIZE];                                     // Очередь принятых команд
unsigned char       data_queue_size = 0;                                        // Текущий размер очереди

unsigned char bit_time = 0;                                                     // Время между стартовыми условиями передачи бита
unsigned char recv_byte = 0;                                                    // Принимаемый байт
unsigned char recv_bit_counter = 0;                                             // Счетчик принимаемых битов
unsigned char recv_byte_counter = 0;                                            // Счетчик принимаемых байтов

bit recv_done;                                                                  // Состояние приемного буфера: 0 - нет данных (или данные в процессе приема), 1 - данные приняты (прием не возможен пока 1)
bit recv_processing;                                                            // Состояние приема:           0 - данные не принимаются, 1 - прием данных

bit comm_clk_prev_state;                                                        // Предыдущее состояние COMM_CLK_PIN
bit comm_wr_processed;                                                          // Флаг процесса приема данных от мастер устройства
bit comm_rd_complete;
struct s_data_queue comm_cmd;                                                   // Буфер приема/передачи от мастер устройства

unsigned char ack_timeout = 100;

void interrupt( )
{
    if ( TMR0IF_bit )                                                           // Переполение таймера 0 (данные не передаются в течении длительного времени)
    {
        TMR0IF_bit = 0;                                                         // Сброс флага переполнения таймера 0
        recv_done = 0;
        recv_processing = 0;                                                    // Устанавливаем состояние свободной линии (никто не передает данные)
    }
    
    if ( INTF_bit )                                                             // Прерывание INT0 (прием данных)
    {
        INTF_bit = 0;                                                           // Сброс флага INT0
        
        if ( recv_done == 0 )                                                   // Прием разрешен (все предыдущие пакеты обработаны)
        {
            if ( recv_processing == 0 )                                         // Если прием данных еще не начат (начало приема)
            {
                recv_processing = 1;                                            // Прием начат
                recv_byte = 0;                                                  // Обнуляем приемный байт
                recv_bit_counter = 0;                                           // Обнуляем счетчик битов
                recv_byte_counter = 0;                                          // Обнуляем счетчик байтов
                TMR0 = 0;                                                       // Сбрасываем таймер 0
            }
            else                                                                // Продолжение приема данных
            {
                bit_time = TMR0; 

                if ( (bit_time > 20) && (bit_time < 30) )                       // Единица
                {
                    recv_byte <<= 1;                                            // Сдвиг
                    recv_byte |= 1;                                             // Установка бита
                }

                if ( bit_time > 8 && bit_time < 16 )                            // Ноль
                {
                    recv_byte <<= 1; 
                    asm {nop};                                                  // Сдвиг
                }

                if ( ++recv_bit_counter == 8 )                                  // Принято 8 бит (байт)
                {
                    recv_buf[recv_byte_counter] = recv_byte;                    // Помещаем принятый байт в приемный буфер
                    recv_byte = 0;                                              // Очищаем байт
                    recv_bit_counter = 0;                                       // Обнуляем счетчик битов

                    if ( ++recv_byte_counter == PACKET_SIZE )                   // Увеличиваем счетчик байтов
                        recv_done = 1;                                          // Прием пакета завершен (необходимо забрать и обработать данные из приемного буфера)
                }

                TMR0 = 0;                                                       // Обнуляем таймер 0
            }
        }
    }
}

/*

  Контрольная сумма

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
unsigned char crc8( unsigned char *block )
{
    unsigned char crc = 0xFF;
    unsigned char len = PACKET_SIZE - 1; // Размер пакета минус 1 байт
    unsigned char i;

    while ( len-- )
    {
        crc ^= *block++;
        for ( i = 0; i < 8; i++ )
            crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
    }
    
    return crc;
}


// Передача данных (d - данные, size - размер)
void send_data( unsigned char *d, unsigned char size )
{
    unsigned char b, i;
    
    while ( size-- )                                                            // Последовательно передаем все байты
    {
        b = *d++;
    
        for ( i = 0; i < 8; i++ )                                               // Последовательная передача 8-ми бит
        {
            DI_PIN = 0;                                                         // Стартовое условие
            Delay_us(BIT_START_TIME);
            DI_PIN = 1;
        
            if ( b & 0b10000000 )                                               // Единица
                Delay_us(BIT_ONE_TIME);
            else                                                                // Ноль
                Delay_us(BIT_ZERO_TIME);

            b <<= 1;                                                            // Сдвиг
        }
    }
    

    DI_PIN = 0;                                                                 // Завершение передачи данных
    Delay_us(BIT_START_TIME);
    DI_PIN = 1;
}

// Передача пакета подтверждения (d - принятый буфер)
void send_ack( unsigned char *bf )
{
    Delay_us(500);
    
    send_buf[0] = device_addr;                                                  // Отправитель
    send_buf[1] = bf[0];                                                        // Получатель
    send_buf[2] = bf[2] | 0b10000000;                                           // Номер пакета (устанавливаем 8 бит номера пакета - признак того, что данный пакет подтверждающий)
    send_buf[3] = 0;                                                            // 1 байт данных (пусто)
    send_buf[4] = 0;                                                            // 2 байт данных (пусто)
    send_buf[5] = 0;                                                            // 3 байт данных (пусто)
    send_buf[6] = 0;                                                            // 4 байт данных (пусто)
    send_buf[7] = crc8(send_buf);                                               // Контрольная сумма пакета
    
    MAX485_TRANSMIT;
    
    send_data(send_buf, PACKET_SIZE);                                           // Передаем
    
    MAX485_RECEIVE;                                                             // Переводим MAX485 в режим приема
}

// Передача пакета ( cmd - данные (1 байт - получатель, 3 байта - данные))
unsigned char send_packet( unsigned char *cmd )
{
    unsigned char res = ERR_PACKET_LOST;                                        // Результат выполнения
    signed char ack_wait = ack_timeout;                                         // Время одижания получения подтверждения
    
    if ( ++packet_num > 127 )                                                   // Увеличиваем номер пакета
        packet_num = 0;
    
    send_buf[0] = device_addr;                                                  // Отправитель
    send_buf[1] = cmd[0];                                                       // Получатель
    send_buf[2] = packet_num;                                                   // Номер пакета
    send_buf[3] = cmd[1];                                                       // Первый байт данных (адрес)
    send_buf[4] = cmd[2];                                                       // Второй байт данных
    send_buf[5] = cmd[3];                                                       // Третий байт данных
    send_buf[6] = cmd[4];                                                       // Четвертый байт данных
    send_buf[7] = crc8(send_buf);                                               // Контрольная сумма пакета
    
    recv_done = 0;                                                              // Приемник готов к приему данных
    recv_processing = 0;
    
    MAX485_TRANSMIT;                                                            // Переводим MAX485 в режим передачи
    
    send_data(send_buf, PACKET_SIZE);                                           // Отправляем пакет адресату
    
    MAX485_RECEIVE;                                                             // Переводим MAX485 в режим приема
    
    
    INTCON.T0IE = 0;                                                            // Отключаем таймер для того чтобы не потерять ACK
    TMR0 = 0;
    
    INT_ENABLE;                                                                 // Разрешаем прерывания
    
    while ( ack_wait-- > 0 )                                                    // Ожидаем приема подтверждения получения команды
    {
        if ( recv_done )                                                        // Данные получены
        {
            INT_DISABLE;
            
            if ( crc8(recv_buf) == recv_buf[PACKET_SIZE - 1] )                   // Если контрольная сумма верная
            {
                if ( recv_buf[2] & 0b10000000 )                                 // Если полученные данные это подтверждение (ACK) ( установлен 8-й бит в номере пакета)
                {
                    if ( (recv_buf[0] == cmd[0]) && (recv_buf[1] == device_addr) && ((recv_buf[2] & 0b01111111) == packet_num) )  // Если ACK данные получателя, отправителя и номер пакета совпадают
                    {
                        res = ERR_OK;                                           // Подтверждение получено, команда принята получателем
                        break;
                    }
                }
            }
            recv_processing = 0;                                                // Устанавливаем прием нового пакета
            recv_done = 0;
            
            INT_ENABLE;
        }
        
        Delay_ms(1);                                                            // Ждем ответа
    }
    
    INT_DISABLE;                                                                // Запрещаем прерывания
    
    INTCON.T0IE = 1;                                                            // Восстанавливаем таймер
    
    recv_processing = 0;                                                        // Устанавливаем прием нового пакета
    recv_done = 0;
    
    return res;                                                                 // Возвращаем результат
}

// Добавляем полученную команду в конец очереди
void push_command( )
{
    if ( data_queue_size == QUEUE_SIZE - 1 )                                    // Если очередь полностью заполнена, игнорируем принимаемые данные
        return;
    
    data_queue[data_queue_size].b[0] = recv_buf[0];                             // Отправитель
    data_queue[data_queue_size].b[1] = recv_buf[3];                             // Первый байт данных
    data_queue[data_queue_size].b[2] = recv_buf[4];                             // Второй байт данных
    data_queue[data_queue_size].b[3] = recv_buf[5];                             // Третий байт данных
    data_queue[data_queue_size].b[4] = recv_buf[6];                             // Третий байт данных

    data_queue_size++;                                                          // Смещаем указатель на последний элемент очереди
}

// Извлекаем первую в очереди команду
void pop_command( struct s_data_queue *cmd )
{
    unsigned char i;
    
    if ( data_queue_size == 0 )                                                     // Если очередь пуста, ничего не делаем
        return;
    
    memcpy(cmd, &data_queue[0], sizeof(struct s_data_queue));                    // Извлекаем первый элемент из очереди
    
    for ( i = 0; i < data_queue_size - 1; ++i )                                 // Смещаем очередь
        memcpy(&data_queue[i], &data_queue[i + 1], sizeof(struct s_data_queue));

    data_queue_size--;                                                          // Уменьшаем размер очереди
}

// Обработка полученного пакета
void process_received_packet( )
{
    if ( recv_done )                                                            // Данные получены
    {
        INT_DISABLE;                                                            // Запрещаем прерывания
        
        if ( crc8(recv_buf) == recv_buf[PACKET_SIZE - 1] )                      // Проверяем контрольную сумму принятых данных (последний элемент приемного буфера)
        {
            if ( (recv_buf[1] == device_addr) && !(recv_buf[2] & 0b10000000) )  // Если пакет адресован получателю и не является подтверждающим
            {
                send_ack(recv_buf);                                             // Посылаем подтверждение отправителю
                push_command();                                                 // Помещаем данные в очередь
            }
        }

        recv_processing = 0;                                                    // Устанавливаем прием нового пакета
        recv_done = 0;                                                          // Разрешаем перезапись буфера приема
        
        INT_ENABLE;                                                             // Разрешаем прерывания
    }
}

// Прием данных от мастер устройства
void comm_read( )
{
    unsigned char i, n;

    i = COMMAND_SIZE - 1;
    n = 0;
    
    memset(&comm_cmd, 0, sizeof(struct s_data_queue));
    
    //comm_rw_value = 0;                                                          // 4-х байтовая переменная
    comm_clk_prev_state = 0;                                                    // Предыдущее состоянии COMM_CLK_PIN
    comm_rd_complete = 0;
        
    COMM_DATA_READY_PIN = 0;                                                    // Устройство не готово к приему
    
    INT_DISABLE;
    
    if ( recv_processing ) 
    {                                                                           // Если идет процесс приема пакета, ничего не делаем
        INT_ENABLE;
        return;
    }
    
    while ( !COMM_WR_PIN && COMM_RD_PIN )                                       // Если COMM_WR_PIN = 0 и COMM_RD_PIN = 1 мастер устройство начало процесс отправки данных
    {
        comm_rd_complete = 1;
        COMM_DATA_DIR = 1;                                                      // Пин данных - вход
        COMM_DATA_READY_PIN = 1;                                                // Устанавливаем готовность к приему данных от мастер устройства

        if ( COMM_CLK_PIN && comm_clk_prev_state == 0 )                         // Тактирование от мастер устройства (высокий уровень)
        {
            comm_clk_prev_state = 1;
            
            comm_cmd.b[i] <<= 1;                                                  // Сдвиг
            if ( COMM_DATA_PIN )                                                // Единица
                comm_cmd.b[i] |= 1;
                
            if ( ++n >= 8 )
            {
                if ( i )
                    i--;
                n = 0;
            }
        }
        
        if ( !COMM_CLK_PIN )                                                    // Тактирование от мастер устройства (низкий уровень)
            comm_clk_prev_state = 0;
    }
    
    comm_clk_prev_state = 0;

    
    if ( comm_rd_complete )                                                     // Принята команда
    {
        if ( comm_cmd.b[0] == 255 )                              // Установка адреса устройства (если адрес получателя 0)  // fix 255 ?
        {
            device_addr = comm_cmd.b[1];
            ack_timeout = comm_cmd.b[2];
            Delay_ms(50);
        }
        else
        {
            if ( send_packet(comm_cmd.b) == ERR_PACKET_LOST ) // Отправка пакета
               memset(&comm_cmd, 0, sizeof(struct s_data_queue));                                                  // Ошибка отправки ( подтверждение не получено) - 0
        }
    }
    
    i = COMMAND_SIZE - 1;
    n = 0;
    while ( !COMM_RD_PIN && COMM_WR_PIN )                                       // Если COMM_WR_PIN = 1 и COMM_RD_PIN = 0 мастер устройство начало процесс отправки данных
    {
        COMM_DATA_DIR = 0;                                                      // Пин данных - вход
        COMM_DATA_READY_PIN = 0;
        
        if ( COMM_CLK_PIN && comm_clk_prev_state == 0 )                         // Тактирование от мастер устройства (высокий уровень)
        {
            comm_clk_prev_state = 1;

             if ( comm_cmd.b[i] & 0x80 )
                COMM_DATA_PIN = 1;                                              // Единица
            else
                COMM_DATA_PIN = 0;                                              // Ноль

            comm_cmd.b[i] <<= 1;                                                     // Сдвиг
            if ( ++n >= 8 )
            {
                if ( i )
                    i--;
                n = 0;
            }
        }

        if ( !COMM_CLK_PIN )                                                    // Тактирование от мастер устройства (низкий уровень)
            comm_clk_prev_state = 0;
    }
    
    COMM_DATA_READY_PIN = 0;
    COMM_DATA_DIR = 1;
    
    INT_ENABLE;
}



// Передача данных в мастер устройство
void comm_write( )
{
    unsigned char i, n;
    
    i = COMMAND_SIZE - 1;
    n = 0;
    
    memset(&comm_cmd, 0, sizeof(struct s_data_queue));
    
    //comm_rw_value = 0;                                                          // 4-х байтовая переменная
    comm_clk_prev_state = 0;                                                    // Предыдущее состоянии COMM_CLK_PIN
    comm_wr_processed = 0;                                                      // Процесс передачи не начат
    
    COMM_DATA_READY_PIN = 0;                                                    // Устройство не готово к приему
    
    INT_DISABLE;
    
    if ( recv_processing || data_queue_size == 0 )                                    // Если идет процесс приема пакета или очередь пуста, ничего не делаем
    {
        INT_ENABLE;
        return;
    }
    
    while ( !COMM_RD_PIN && !COMM_WR_PIN )                                                      // Если COMM_WR_PIN = 0 мастер устройство начало процесс приема данных
    {
        if ( !comm_wr_processed )                                               // Если передача не начата
        {
            comm_wr_processed = 1;                                              // Начинаем процесс передачи
            
            if ( data_queue_size )                                              // Если очередь команд не пуста
            {
                i = COMMAND_SIZE - 1;
                n = 0;
                pop_command(&comm_cmd);                                              // Извлекаем команду из очереди
                COMM_DATA_DIR = 0;                                              // Пин данных - выход
                COMM_DATA_READY_PIN = 1;                                        // Устанавливаем готовность передачи данных мастер устройству
            }
        }
        
        if ( COMM_CLK_PIN && comm_clk_prev_state == 0 )                         // Тактирование от мастер устройства (высокий уровень)
        {
            comm_clk_prev_state = 1;

            if ( comm_cmd.b[i] & 0x80 )
                COMM_DATA_PIN = 1;                                              // Единица
            else
                COMM_DATA_PIN = 0;                                              // Ноль
               
            comm_cmd.b[i] <<= 1;                                                     // Сдвиг
            if ( ++n >= 8 )
            {
                if ( i )
                    i--;
                n = 0;
            }
        }

        if ( !COMM_CLK_PIN )                                                    // Тактирование от мастер устройства (низкий уровень)
            comm_clk_prev_state = 0;
    }
    
    COMM_DATA_READY_PIN = 0;                                                    // Устройство не готово к приему (мастер устройство прекратило прием)
    COMM_DATA_DIR = 1;                                                          // Пин данных - вход
    
    INT_ENABLE;
}


void main()
{
    unsigned long led_counter = 0;
    
    CMCON               = 0x07;                                                 // Компаратор выключен
    
    LED_DIR             = 0;
    LED_PIN             = 0;
    
    COMM_WR_DIR         = 1;                                                    // COMM_WR         - вход
    COMM_RD_DIR         = 1;                                                    // COMM_RD         - вход
    COMM_CLK_DIR        = 1;                                                    // COMM_CLK        - вход
    COMM_DATA_DIR       = 1;                                                    // COMM_DATA       - вход
    COMM_DATA_READY_DIR = 0;                                                    // COMM_DATA_READY - выход
    COMM_DATA_READY_PIN = 0;                                                    // COMM_DATA_READY = 0

    RO_DIR              = 1;                                                    // RO    - вход
    DE_RE_DIR           = 0;                                                    // RE/DE - выход
    DI_DIR              = 0;                                                    // DI    - выход

    MAX485_RECEIVE;                                                             // MAX485 в режиме приема

    OPTION_REG.INTEDG   = 1;                                                    // Прерывание INT0 по нарастающему фронту
    OPTION_REG.T0CS     = 0;                                                    // Тактирование таймера 0 от внутреннего генератора
    OPTION_REG.PSA      = 0;                                                    // Использовать пределитель для таймера 0
    OPTION_REG.PS2      = 0;                                                    // Предделитель
    OPTION_REG.PS1      = 1;  //1
    OPTION_REG.PS0      = 0;

    INTCON.PEIE         = 1;                                                    // Разрешаем периферийные прерывания
    INTCON.T0IE         = 1;                                                    // Разрешаем прерывание таймера 0
    INTCON.INTE         = 1;                                                    // Разрешаем прерывание INT0
    
    recv_done           = 0;                                                    // Инициализация флагов
    recv_processing     = 0;
    comm_clk_prev_state = 0;
    comm_rd_complete    = 0;
    comm_wr_processed   = 0;
    
    INT_ENABLE;                                                                 // Разрешаем все прерывания
    
    while ( 1 )
    {
        process_received_packet();                                              // Обработка принятых данных
        
        comm_read();                                                            // Прием данных мастер устройства

        comm_write();                                                           // Передача данных в мастер устройство
        
        if ( led_counter++ > 10000 )
        {
            led_counter = 0;
            LED_PIN = ~LED_PIN;
        }
    }
}