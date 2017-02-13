#include "../common/types.h"
#include "../common/unit_data_exchange.h"
#include "../common/net_commands.h"


#define COMM_WR_PIN             RB7_bit                                         // Write enable
#define COMM_WR_DIR             TRISB7_bit                                      // Write enable direction

#define COMM_RD_PIN             RB6_bit                                         // Read enable
#define COMM_RD_DIR             TRISB6_bit                                      // Read enable direction

#define COMM_CLK_PIN            RB5_bit                                         // Clock
#define COMM_CLK_DIR            TRISB5_bit                                      // Clock direction

#define COMM_DATA_PIN           RB4_bit                                         // Data
#define COMM_DATA_DIR           TRISB4_bit                                      // Data direction

#define COMM_DATA_READY_PIN     RB3_bit                                         // Data ready
#define COMM_DATA_READY_DIR     TRISB3_bit                                      // Data ready direction

#include "../common/transceiver.h"
#include "../common/net.h"

// HC165 //
#define HC165_LOAD_PIN  RD7_bit
#define HC165_CLOCK_PIN RD6_bit
#define HC165_DATA_PIN  RD5_bit

#define HC165_LOAD_DIR  TRISD7_bit
#define HC165_CLOCK_DIR TRISD6_bit
#define HC165_DATA_DIR  TRISD5_bit

#include "hc165.h"

// Пины управлениями двигателями //
#define M1_PIN   RD0_bit
#define M2_PIN   RC2_bit
#define M3_PIN   RC1_bit
#define M4_PIN   RC0_bit
#define M5_PIN   RE2_bit
#define M6_PIN   RE1_bit
#define M7_PIN   RE0_bit
#define M8_PIN   RA5_bit

#define M1_DIR   TRISD0_bit
#define M2_DIR   TRISC2_bit
#define M3_DIR   TRISC1_bit
#define M4_DIR   TRISC0_bit
#define M5_DIR   TRISE2_bit
#define M6_DIR   TRISE1_bit
#define M7_DIR   TRISE0_bit
#define M8_DIR   TRISA5_bit

// Индикатор
#define LED_PIN                  RD4_bit
#define LED_DIR                  TRISD4_bit

// Пины восстановления защиты от короткого замыкания на линии датчиков
#define SENSORS_PWR_RESTORE_PIN  RD1_bit
#define SENSORS_PWR_RESTORE_DIR  TRISD1_bit

// Индикатор
#define USB_PWR_PIN              RD2_bit
#define USB_PWR_DIR              TRISD2_bit

// Адрес основного блока
#define SERVER_ADDRESS           254

// Количество двигателей
#define MOTOR_MAX                8

// Количество датчиков
#define SENSORS_COUNT            23

struct s_motor
{
    uchar  state;                 // Состояние: 0 - выкл; 1 - вкл; 2 - выкл(стаботала защита)
    uchar  protect;               // Защита: 0 - не используется; 1 - используется
    uchar  sensor_state;          // Состояние датчика защиты: 0 - не сработал; 1 - сработал
    ushort start_time;            // Время набора оборотов (в 100 миллисекундных долях)
    uchar  ready;                 // Готовность: 0 - двигатель еще не набрал обороты, 1 - двигатель набрал обороты
    ushort start_time_counter;    // Счетчик разгона
};

void motor_init( );
void motor_acceleration_control( );
void motor_start( uchar number );
void motor_stop( uchar number, uchar failure );