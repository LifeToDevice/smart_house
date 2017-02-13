#ifndef _UNIT_DATA_EXCHANGE_H_
#define _UNIT_DATA_EXCHANGE_H_

#include "types.h"

// ��������� ���������� ������
#define CMD_RESULT_OK                       0                                   // �������
#define CMD_RESULT_FAIL                     1                                   // ������
#define CMD_RESULT_SEND_FAIL                2                                   // �������� �� �������
#define CMD_RESULT_SEND_FAIL_BUSY           3                                   // ���������������� �����
#define CMD_RESULT_BAD_INDEX                4                                   // ������������ ����� �����
#define CMD_RESULT_BAD_PROTECT_ORDER        5                                   // ��������� ����������� ��������� ������
#define CMD_RESULT_EEPROM_WRITE_FAIL        6                                   // ������ ������ � EEPROM
#define CMD_RESULT_UNIT_IS_ONLINE           7                                   // ���� � ������ ������ � ���� � �� ������������ �����-���� �������� ������
#define CMD_RESULT_BAD_FORMAT               8                                   // ������������ ������
#define CMD_RESULT_BAD_CHECK_SUM            9                                   // ������������ ����
#define CMD_RESULT_UNKNOWN                  255                                 // ��������� ������������


// �������������� ���� (������)
#define CMD_EU_UNKNOWN                      0                                   // ����������� �������
#define CMD_EU_GET_UNIT_NUMBER              1                                   // ������ ������ (������) �����
#define CMD_EU_SET_UNIT_NUMBER              2                                   // ������ ������ (������) �����
#define CMD_EU_GET_SENSORS_STATE            3                                   // ������ ��������� ��������
#define CMD_EU_GET_MOTORS_STATE             4                                   // ������ ��������� ����������
#define CMD_EU_GET_MOTOR_CONFIG             5                                   // ������ ������������ ���������
#define CMD_EU_SET_MOTOR_CONFIG             6                                   // ������ ������������ ���������
#define CMD_EU_GET_MOTOR_STATE              7                                   // ������ ��������� ��������� (���/����)
#define CMD_EU_SET_MOTOR_STATE              8                                   // ��������� ��������� ��������� (���/����)
#define CMD_EU_GET_UNIT_STATE               9                                   // ��������� ����� (1 - � ����, 0 - �� � ����)
#define CMD_EU_LOAD_CONFIG                  10                                  // �������� ������������ �� �����
#define CMD_EU_SAVE_CONFIG                  11                                  // ���������� ������������ � ����

// ����������� ���� (������)
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
// ��� ������� CMD_CU_DBG_COMMAND
#define CMD_CU_DBG_SET_SENSOR_STATE         1
#define CMD_CU_DBG_SET_MOTOR_STATE          2
#define CMD_CU_DBG_EEPROM_WRITE             3
#define CMD_CU_DBG_EEPROM_READ              4
#define CMD_CU_RESTORE_PROTECT              5


#ifdef WIN32                                 // Windows
#pragma pack(push, 1)
#endif

// ��������� �������
struct s_cmd_header
{
        uchar name;                          // ������� 
        uchar result;                        // ��������� ���������� (1 - �������, 0 - ������)
};

/*
// ����
struct s_unit_data
{
        struct s_cmd_header cmd;             // �������
        uchar               unit;            // ����
}; 
*/

//  ****************** �������������� ���� (������)  ****************** //

// ������ ����������
struct s_eu_motors_state
{
        struct s_cmd_header cmd;             // �������
        uchar               state;           // ��������� (�������/����������)
        uchar               protect;         // ��������� ������ (���/����)
};

// ������ ��������
struct s_eu_sensors_state
{
        struct s_cmd_header cmd;             // �������
        uchar               count;           // ���������� ��������� ��������
        ulong               state;           // ��������� (���/����)
};

// ������������ ���������
struct s_eu_motor_config
{
        struct s_cmd_header cmd;             // �������
        uchar               number;          // ����� ���������
        uchar               state;           // ���������
        uchar               protect;         // ��������� ������
        ushort              start_time;      // ����� �������
};

// ����� ����� (�����)
struct s_eu_unit_number
{
        struct s_cmd_header cmd;             // �������
        uchar               number;          // ����� �����
};

// ���������/���������� ���������
struct s_eu_motor_state
{
        struct s_cmd_header cmd;             // �������
        uchar               number;          // ����� ���������
        uchar               state;           // ���������(���/����)
};

// ���������/���������� ���������
struct s_eu_unit_state
{
        struct s_cmd_header cmd;             // �������
        uchar               state;           // ���������
};

// ������������ �� �����
struct s_eu_config_data
{
        struct s_cmd_header cmd;             // �������
        uchar               magic[5];
        uchar               number;          // ����� �����
        uchar               protect[24];     // ������ ������ ((protect (1 byte) + start_time (2 bytes)) * 8 = 24 bytes)
        ushort              check_sum;       //
};


// ****************** ����������� ���� (������)  ****************** //

// �����������
struct s_cu_auth
{
        struct s_cmd_header cmd;
        ulong               auth_code;
};
 
// ���������/������������ �����
struct s_cu_units
{
        struct s_cmd_header cmd;
        uchar               index;            // 0..7
        uchar               units[32];        // 8 �����
};

// ��������� �����
struct s_cu_unit_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;       // ����� �����
        uchar               motors;            // ��������� ���������� (��� ���������� - ��������, ������� - ����������)
        uchar               motors_protect;    // ��������� ������ �������� ���������� (��� ���������� - ��������� (��������� ��������� ���������))
        uchar               sensors[3];        // ��������� �������� (��� ���������� - �������, ������� - ���������)
        uchar               protected_motors;  // ���������� ���������� � �������
};

// ��������� ��������� 
struct s_cu_motor_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;       // ����� �����
        uchar               motor_number;      // ����� ���������
        uchar               state;             // ��������� 0 - ����������, 1 - �������
        uchar               ref_unit_number;   // ����� ����� ��� ����� (0 - ���� �� ������������)
        uchar               ref_motor_number;  // ����� ���������� ��������� (0 - ���� �� ������������)
};

// ��������� ������� 
struct s_cu_sensor_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;      // ����� �����
        uchar               sensor_number;    // ����� �������
        uchar               state;            // ��������� 0 - ���������, 1 - �������
};

// ����� 
struct s_cu_motors_relation
{
        struct s_cmd_header cmd;
        uchar               unit_number;      // ����� �����
        uchar               motor_number;     // ����� ���������
        uchar               dep_unit_number;  // ����� �����
        uchar               dep_motor_number; // ����� ���������
};

// ��������� �������
struct s_cu_sensor_controlled_state
{
        struct s_cmd_header cmd;
        uchar               unit_number;      // ����� �����
        uchar               sensor_number;    // ����� �������
        uchar               state;            // ��������� 0 - ���������, 1 - �������
        uchar               motor_unit;       // ����� �����
        uchar               motor_number;     // ����� ���������
};

// ������� ���������
struct s_cu_changes
{
        struct s_cmd_header cmd;             // �������
        uchar               changes;         // 0 - ��� �������, 0xff - ���� ���������
};

// �������������� ����/�����
struct s_cu_advanced_in_out
{
        struct s_cmd_header cmd;             // �������
        uchar               number;          // �����
        uchar               mode;            // 0 - ��������� ���������, 1 - ��������� ��������� (��� ����� �� ����� ��������)
        uchar               state;           // ��������� ����� �����/������
};

// ���������� �������
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