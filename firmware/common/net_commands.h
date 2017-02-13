#ifndef _NET_COMMANDS_H_
#define _NET_COMMANDS_H_


#ifdef WIN32                                 // Windows
#pragma pack(push, 1)
#endif

// �������
struct s_net_cmd
{
        uchar  addr;
        uchar  cmd;
        ushort dat;
};

#ifdef WIN32                                 // Windows
#pragma pack(pop)
#endif


#define NET_CMD_REQ_UNIT               1           // ��������� ��������� ����� (�����, �����)
#define NET_CMD_GET_UNIT               2           // �������� ��������� ����� (�����, �����)
#define NET_CMD_REQ_MOTOR_STATE        3           // ��������� ��������� ��������� (���������, �����) ->
#define NET_CMD_GET_MOTOR_STATE        4           // �������� ��������� ��������� (���������, ���������) <-
#define NET_CMD_SET_MOTOR_STATE        5           // ���������� ��������� ��������� (���������, ���������) ->
#define NET_CMD_REQ_SENSORS_STATE      6           // ��������� ��������� �������� (�����, �����) ->
#define NET_CMD_GET_SENSORS_STATE      7           // �������� ��������� �������� (���������, �����) <-
#define NET_CMD_SENSOR_CHANGE          8           // ��������� ��������� ������� (������, ����� ���������)
#define NET_CMD_MOTOR_FAILURE          9           // �������� ������ (���������, �����) ->

#define NET_CMD_SENSORS_STATE          10          // �������� ��������� �������� ����� ����������
#define NET_CMD_SCAN                   11
#define NET_CMD_MOTORS_STATE           12
#define NET_CMD_RESTORE_PROTECT        14
#define NET_CMD_UNIT_INFO              15          //
#define NET_CMD_REQUERY                16

#endif