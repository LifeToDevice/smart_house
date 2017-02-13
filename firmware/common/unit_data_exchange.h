#ifndef _UNIT_DATA_EXCHANGE_H_
#define _UNIT_DATA_EXCHANGE_H_

#include "types.h"

// Результат выполнения команд
#define CMD_RESULT_OK                       0                                   // Успешно
#define CMD_RESULT_FAIL                     1                                   // Ошибка
#define CMD_RESULT_SEND_FAIL                2                                   // Отправка не удалась
#define CMD_RESULT_SEND_FAIL_BUSY           3                                   // Приемопередатчик занят
#define CMD_RESULT_BAD_INDEX                4                                   // Некорректный номер блока
#define CMD_RESULT_BAD_PROTECT_ORDER        5                                   // Нарущение очередности установки защиты
#define CMD_RESULT_EEPROM_WRITE_FAIL        6                                   // Ошибка записи в EEPROM
#define CMD_RESULT_UNIT_IS_ONLINE           7                                   // Блок в данный момент в сети и не поддерживает какие-либо операции записи
#define CMD_RESULT_BAD_FORMAT               8                                   // Некорректный формат
#define CMD_RESULT_BAD_CHECK_SUM            9                                   // Некорректный файл
#define CMD_RESULT_UNKNOWN                  255                                 // Состояние неопределено


// Исполнительный блок (клиент)
#define CMD_EU_UNKNOWN                      0                                   // Неизвестная команда
#define CMD_EU_GET_UNIT_NUMBER              1                                   // Чтение номера (адреса) блока
#define CMD_EU_SET_UNIT_NUMBER              2                                   // Запись номера (адреса) блока
#define CMD_EU_GET_SENSORS_STATE            3                                   // Чтение состояния датчиков
#define CMD_EU_GET_MOTORS_STATE             4                                   // Чтение состояния двигателей
#define CMD_EU_GET_MOTOR_CONFIG             5                                   // Чтение конфигурации двигателя
#define CMD_EU_SET_MOTOR_CONFIG             6                                   // Запись конфигурации двигателя
#define CMD_EU_GET_MOTOR_STATE              7                                   // Чтение состояния двигателя (вкл/выкл)
#define CMD_EU_SET_MOTOR_STATE              8                                   // Установка состояния двигателя (вкл/выкл)
#define CMD_EU_GET_UNIT_STATE               9                                   // Состояние блока (1 - в сети, 0 - не в сети)
#define CMD_EU_LOAD_CONFIG                  10                                  // Загрузка конфигурации из файла
#define CMD_EU_SAVE_CONFIG                  11                                  // Сохранение конфигурации в файл

// Управляющий блок (сервер)
#define CMD_CU_UNKNOWN                      0
#define CMD_CU_AUTH                         1
#define CMD_CU_GET_AVAILABLE_UNITS          2
#define CMD_CU_SET_USED_UNITS               3
#define CMD_CU_GET_USED_UNITS               4
#define CMD_CU_GET_UNIT_STATE               5
#define CMD_CU_SET_MOTOR_STATE              6
#define CMD_CU_GET_SENSOR_STATE             7
#define CMD_CU_SET_MOTORS_RELATION          9
#define CMD_CU_CHECK_CHANGES                10
#define CMD_CU_SET_SENSOR_CONTROLLED_STATE  11
#define CMD_CU_ADVANCED_OUTPUT              12
#define CMD_CU_ADVANCED_INPUT               13
#define CMD_CU_REQUERY                      14
#define CMD_CU_DBG_COMMAND                  255  // fix 15 ?
// Под комадны CMD_CU_DBG_COMMAND
#define CMD_CU_DBG_SET_SENSOR_STATE         1
#define CMD_CU_DBG_SET_MOTOR_STATE          2
#define CMD_CU_DBG_EEPROM_WRITE             3
#define CMD_CU_DBG_EEPROM_READ              4
#define CMD_CU_RESTORE_PROTECT              5


#ifdef WIN32                                 // Windows
#pragma pack(push, 1)
#endif

// Заголовок команды
struct s_cmd_header
{
        uchar name;                          // Команда 
        uchar result;                        // Результат выполнения (1 - успешно, 0 - ошибка)
};

/*
// Блок
struct s_unit_data
{
        struct s_cmd_header cmd;             // Команда
        uchar               unit;            // Блок
}; 
*/

//  ****************** Исполнительный блок (клиент)  ****************** //

// Данные двигателей
struct s_eu_motors_state
{
        struct s_cmd_header cmd;             // Команда
        uchar               state;           // Состояние (запущен/остановлен)
        uchar               protect;         // Состояние защиты (вкл/выкл)
};

// Данные датчиков
struct s_eu_sensors_state
{
        struct s_cmd_header cmd;             // Команда
        uchar               count;           // Количество доступных датчиков
        ulong               state;           // Состояние (вкл/выкл)
};

// Конфигурация двигателя
struct s_eu_motor_config
{
        struct s_cmd_header cmd;             // Команда
        uchar               number;          // Номер двигателя
        uchar               state;           // Состояние
        uchar               protect;         // Состояние защиты
        ushort              start_time;      // Время запуска
};

// Номер блока (адрес)
struct s_eu_unit_number
{
        struct s_cmd_header cmd;             // Команда
        uchar               number;          // Номер блока
};

// Включение/Отключение двигателя
struct s_eu_motor_state
{
        struct s_cmd_header cmd;             // Команда
        uchar               number;          // Номер двигателя
        uchar               state;           // Состояние(вкл/выкл)
};

// Включение/Отключение двигателя
struct s_eu_unit_state
{
        struct s_cmd_header cmd;             // Команда
        uchar               state;           // Состояние
};

// Конфигурация из файла
struct s_eu_config_data
{
        struct s_cmd_header cmd;             // Команда
        uchar               magic[5];
        uchar               number;          // Номер блока
        uchar               protect[24];     // Данные защиты ((protect (1 byte) + start_time (2 bytes)) * 8 = 24 bytes)
        ushort              check_sum;       //
};


// ****************** Управляющий блок (сервер)  ****************** //

// Авторизация
struct s_cu_auth
{
        struct s_cmd_header cmd;
        ulong               auth_code;
};
 
// Доступные/Используемые блоки
struct s_cu_units
{
        struct s_cmd_header cmd;
        uchar               index;            // 0..7
        uchar               units[32];        // 8 блока
};

// Состояние блока
struct s_cu_unit_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;       // Номер блока
        uchar               motors;            // Состояние двигателей (бит установлен - работает, сброшен - остановлен)
        uchar               motors_protect;    // Состояние защиты датчиков двигателей (бит установлен - стаботала (аварийная остановки двигателя))
        uchar               sensors[3];        // Состояние датчиков (бит установлен - замкнут, сброшен - разомкнут)
        uchar               protected_motors;  // количество двигателей с защитой
};

// Состояние двигателя 
struct s_cu_motor_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;       // Номер блока
        uchar               motor_number;      // Номер двигателя
        uchar               state;             // Состояние 0 - остановлен, 1 - запущен
        uchar               ref_unit_number;   // Номер блока для связи (0 - есди не используется)
        uchar               ref_motor_number;  // Номер зависимого двигателя (0 - есди не используется)
};

// Состояние датчика 
struct s_cu_sensor_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;      // Номер блока
        uchar               sensor_number;    // Номер датчика
        uchar               state;            // Состояние 0 - разомкнут, 1 - замкнут
};

// Связи 
struct s_cu_motors_relation
{
        struct s_cmd_header cmd;
        uchar               unit_number;      // Номер блока
        uchar               motor_number;     // Номер двигателя
        uchar               dep_unit_number;  // Номер блока
        uchar               dep_motor_number; // Номер двигателя
};

// Состояние датчика
struct s_cu_sensor_controlled_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;      // Номер блока
        uchar               sensor_number;    // Номер датчика
        uchar               state;            // Состояние 0 - разомкнут, 1 - замкнут
        uchar               motor_unit;       // Номер блока
        uchar               motor_number;     // Номер двигателя
};

// Наличие изменений
struct s_cu_changes
{
        struct s_cmd_header cmd;             // Команда
        uchar               changes;         // 0 - нет измений, 0xff - есть изменения
};

// Дополнительный ввод/вывод
struct s_cu_advanced_in_out
{
        struct s_cmd_header cmd;             // Команда
        uchar               number;          // Номер
        uchar               mode;            // 0 - установка состояния, 1 - получение состояния (для ввода не имеет значения)
        uchar               state;           // Состояние порта ввода/вывода
};

// Отладочная команда
struct s_cu_debug_cmd
{
        struct s_cmd_header cmd;
        uchar               dbg_cmd;
        uchar               dat[61];
};


#ifdef WIN32                                 // Windows
#pragma pack(pop)
#endif


#endif