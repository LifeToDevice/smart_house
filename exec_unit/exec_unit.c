#include "exec_unit.h"

#define USB_REPORT_SIZE 64
#include "../common/usb.h"

#include "../common/internal_eeprom.h"

#include "../common/crc.h"

#define DEFAULT_ADDRESS 1

// ��������� (��������� ����������)
ulong curr_sensors_state = 0;
ulong prev_sensors_state = 0;
ulong curr_motors_state  = 0;
ulong prev_motors_state  = 0;

// ��������� ���������� (2 �����)
ulong motors_state       = 0;
// ��������� �������� (3 �����)
ulong sensors_state      = 0;

// ���������
uchar changes            = FALSE;

// ������� ������ � ����
uchar is_connected       = FALSE;

// ������������
uchar reboot_needed      = FALSE;

// ���� ����������� ������ USB
uchar usb_state_on       = FALSE;

// ����� (�����) �����
uchar unit_number        = DEFAULT_ADDRESS;

// ���������� ���������� � �������
uchar protected_motors   = 0;

// ���������
struct s_motor motors[MOTOR_MAX];

code ulong protected_mask[MOTOR_MAX + 1] =
{ 
    0b111111111111111111111111,              // ��� ���������� � �������
    0b101111111111111111111111,              // 1 ��������� � �������
    0b100111111111111111111111,              // 2 ��������� � �������
    0b100011111111111111111111,              // 3 ��������� � �������
    0b100001111111111111111111,              // 4 ��������� � �������
    0b100000111111111111111111,              // 5 ���������� � �������
    0b100000011111111111111111,              // 6 ���������� � �������
    0b100000001111111111111111,              // 7 ���������� � �������
    0b100000000111111111111111,              // 8 ���������� � �������
};


// �������������
void motor_init( )
{
    M1_DIR = 0;
    M2_DIR = 0;
    M3_DIR = 0;
    M4_DIR = 0;
    M5_DIR = 0;
    M6_DIR = 0;
    M7_DIR = 0;
    M8_DIR = 0;

    M1_PIN = 0;
    M2_PIN = 0;
    M3_PIN = 0;
    M4_PIN = 0;
    M5_PIN = 0;
    M6_PIN = 0;
    M7_PIN = 0;
    M8_PIN = 0;
    
    memset(motors, 0, sizeof(struct s_motor) * MOTOR_MAX);
}

// ��������� ��������� ��������� (��������� ��� ����������)
// motor - ����� ��������� (1..MOTORS_MAX)
// state - 0 - ����������, 1 - ������
void motor_set_state( uchar motor, uchar state )
{
    switch ( motor )
    {
        case 1:
            M1_PIN = state;
            break;
        case 2:
            M2_PIN = state;
            break;
        case 3:
            M3_PIN = state;
            break;
        case 4:
            M4_PIN = state;
            break;
        case 5:
            M5_PIN = state;
            break;
        case 6:
            M6_PIN = state;
            break;
        case 7:
            M7_PIN = state;
            break;
        case 8:
            M8_PIN = state;
            break;
    }
}

// ��������� ������ ����������
uchar motor_get_fail_state( )
{
    char i;
    uchar s = 0;

    for ( i = 0; i < 8; ++i )
        if ( motors[i].state == 2 )
            s |= (1 << i);

    return s;
}

// ������ ��������� ����������
// ������������ ��������: 1 - ���� ���������, 0 - ��� ���������, state - ���������
char motor_read( ulong *state )
{
    char res = 0;

    curr_motors_state = ((M8_PIN << 7) | (M7_PIN << 6) | (M6_PIN << 5) | (M5_PIN << 4) | (M4_PIN << 3) | (M3_PIN << 2) | (M2_PIN << 1) | (M1_PIN << 0));
    if ( curr_motors_state != prev_motors_state )
    {
        *state = ((ushort)motor_get_fail_state() << 8) | (uchar)(curr_motors_state & 0x000000ff);
        prev_motors_state = curr_motors_state;
        res = 1;
    }

    return res;
}

// ������ ���������
void motor_start( uchar number )
{
    TMR1IE_bit = 0;
    motor_set_state(number + 1, 1);
    motors[number].state = 1;
    motors[number].ready = 0;
    motors[number].start_time_counter = 0;
    TMR1IE_bit = 1;
}

// ��������� ���������
void motor_stop( uchar number, uchar failure )
{
    motor_set_state(number + 1, 0);
    motors[number].state = failure ? 2 : 0;
}

// ������ ������ ����� ������� ����������
void motor_acceleration_control( )
{
    char i;
    for ( i = 0; i < MOTOR_MAX; ++i )
        if ( motors[i].state == 1 && motors[i].ready == FALSE )
            if ( motors[i].start_time_counter++ >= motors[i].start_time )
                motors[i].ready = TRUE;
}

// �������� ������
void motor_protect_control( )
{
    char i;
    for ( i = 0; i < MOTOR_MAX; ++i )
    {
        // ���������� ������������ ���������, ��������� �� ����������� ������� � ��������� ��� ������
        if ( motors[i].state != 1 || motors[i].protect == 0 )
            continue;

        // ���� ��������� �������� � �������� ������ �������� ��������
        if ( motors[i].ready && motors[i].sensor_state )
        {
            // ��������� ���������
            motor_stop(i, TRUE);
        }
    }
}

// ����� ���������� ��������� ����������
void motor_reset_fail_state( )
{
    char i;
    for ( i = 0; i < MOTOR_MAX; ++i )
        if ( motors[i].state == 2 )
            motors[i].state = 0;
}

// ��������� �������������� ����������
unsigned char motor_get_protected( )
{
    char i, n = 0;
    for ( i = 0; i < MOTOR_MAX; ++i )
        if ( motors[i].protect )
            n++;
    return n;
}


void timer1_init( )
{
    // ������ 1 - 100 ��
    T1CON      = 0x31;
    TMR1IF_bit = 0;
    TMR1H      = 0x0B;
    TMR1L      = 0xD9;
    TMR1IE_bit = 1;
}

// �������� ������������ ��������������� �����
void load_config( )
{
    uchar i, n, byte_val;
    ushort word_val;
    // ����� (�����) �����
    byte_val = ee_read(0x00);
    if ( byte_val != 0xff )
        unit_number = byte_val;
    
    n = 0;
    for ( i = 0; i < 8; ++i )
    {
        // ������������� ������
        byte_val = ee_read(0x01 + n);
        // ����� �������
        word_val = ((ushort)ee_read(0x03 + n) << 8) | ee_read(0x02 + n);
        
        if ( byte_val == 0xff )  // ���������� ������ ������
            continue;
            
        motors[i].protect    = byte_val;
        motors[i].start_time = word_val;
        
        n += 3;
    }
    
    protected_motors = motor_get_protected();
}

// ������ �����
uchar write_config_byte( uchar addr, uchar dat )
{
    return (ee_write(addr, dat) && (ee_read(addr) == dat));
}

// ������ 2-� ������
uchar write_config_word( uchar addr, ushort dat )
{
    return (ee_write(addr, dat & 0x00ff) && ee_write(addr + 1, (dat >> 8) & 0x00ff) && (ee_read(addr) == (dat & 0x00ff)) && (ee_read(addr + 1) == ((dat >> 8) & 0x00ff)));
}


// �������������� ������ ����� �� �� ����� ������� ��������
void protect_restore( )
{
    SENSORS_PWR_RESTORE_PIN = 1;
    delay_ms(100);
    SENSORS_PWR_RESTORE_PIN = 0;
}


// ���������� �������� ������
void exec_commands( )
{
    uchar buff[5];                                                              // �������� �����

    while ( 1 )                                                                 // ������ �� �����������������, ���� ���� ������
    {
        delay_ms(1);
        memset(buff, 0, 5);
        if ( transceiver_recv(buff) )                                           // ���� ������
        {
            is_connected = TRUE;                                                // ������ ���� ������� �� ������� ���� �������
            
            switch ( buff[1] )                                                  // �������
            {
                // �������� ���������� � �����
                /*case NET_CMD_UNIT_INFO:
                    send_motor_info(buff[0]);
                    break; */
                    
                // ������ ����������
                case NET_CMD_REQUERY:
                    LED_PIN = ~LED_PIN;
                    changes = TRUE;
                    break;
                
                // ��������� ��������� ��������� (���/����)
                case NET_CMD_SET_MOTOR_STATE:
                    if ( buff[2] )
                        motor_start(buff[3] - 1);
                    else
                        motor_stop(buff[3] - 1, FALSE);
                    break;
                    
                // ������� �������������� ������
                case NET_CMD_RESTORE_PROTECT:
                    protect_restore();
                    break;
                    
                //
            }
        }
        else
        {
            break;  // ������ ������ ���
        }
    }
    
    delay_ms(100);                                                              // ???
}

// ������ ��������� ��������
// ������������ ��������: 1 - ���� ���������, 0 - ��� ���������
char sensors_read( ulong *state )
{
    ulong st;
    char res = 0;
    char i;
    
    st = hc165_read(24);
    
    // ��� ��� ������� �������� �� �� �������, �������� �������
    curr_sensors_state = 0;
    if ( st & 0b000000000000000000100000 ) curr_sensors_state |= 0b000000000000000000000001;
    if ( st & 0b000000000000000001000000 ) curr_sensors_state |= 0b000000000000000000000010;
    if ( st & 0b000000000000000010000000 ) curr_sensors_state |= 0b000000000000000000000100;
    if ( st & 0b000000000000000000001000 ) curr_sensors_state |= 0b000000000000000000001000;
    if ( st & 0b000000000000000000000100 ) curr_sensors_state |= 0b000000000000000000010000;
    if ( st & 0b000000000000000000000010 ) curr_sensors_state |= 0b000000000000000000100000;
    if ( st & 0b000000000000000000000001 ) curr_sensors_state |= 0b000000000000000001000000;
    if ( st & 0b000000000001000000000000 ) curr_sensors_state |= 0b000000000000000010000000;
    if ( st & 0b000000000010000000000000 ) curr_sensors_state |= 0b000000000000000100000000;
    if ( st & 0b000000000100000000000000 ) curr_sensors_state |= 0b000000000000001000000000;
    if ( st & 0b000000001000000000000000 ) curr_sensors_state |= 0b000000000000010000000000;
    if ( st & 0b000000000000000100000000 ) curr_sensors_state |= 0b000000000000100000000000;
    if ( st & 0b000000000000001000000000 ) curr_sensors_state |= 0b000000000001000000000000;
    if ( st & 0b000000000000010000000000 ) curr_sensors_state |= 0b000000000010000000000000;
    if ( st & 0b000000000000100000000000 ) curr_sensors_state |= 0b000000000100000000000000;
    if ( st & 0b000100000000000000000000 ) curr_sensors_state |= 0b000000001000000000000000;
    if ( st & 0b001000000000000000000000 ) curr_sensors_state |= 0b000000010000000000000000;
    if ( st & 0b010000000000000000000000 ) curr_sensors_state |= 0b000000100000000000000000;
    if ( st & 0b100000000000000000000000 ) curr_sensors_state |= 0b000001000000000000000000;
    if ( st & 0b000010000000000000000000 ) curr_sensors_state |= 0b000010000000000000000000;
    if ( st & 0b000001000000000000000000 ) curr_sensors_state |= 0b000100000000000000000000;
    if ( st & 0b000000100000000000000000 ) curr_sensors_state |= 0b001000000000000000000000;
    if ( st & 0b000000010000000000000000 ) curr_sensors_state |= 0b010000000000000000000000;
    if ( st & 0b000000000000000000010000 ) curr_sensors_state |= 0b100000000000000000000000;
    
    // ����������� �������� ������ ����������
    for ( i = 0; i < protected_motors; ++i )
        motors[i].sensor_state = (curr_sensors_state & (0x00400000 >> i)) ? 0 : 1;    // 0x00400000 - 23-� ����
        //motors[i].sensor_state = (curr_sensors_state & (~protected_mask[i + 1])) ? 0 : 1;

    // �� ���������� ������� ��������������� ��� ������ ����������
    curr_sensors_state &= protected_mask[protected_motors];

    // ��������� ����������
    if ( curr_sensors_state != prev_sensors_state )
    {
        *state = curr_sensors_state;
        prev_sensors_state = curr_sensors_state;
        res = 1;
    }
    
    delay_ms(50);
    
    return res;
}

// ������� ����� ��������� ���������� ������
char motor_get_protect_mask( char count )
{
    switch ( count )
    {
        case 1:
            return 0b00000001;
        case 2:
            return 0b00000011;
        case 3:
            return 0b00000111;
        case 4:
            return 0b00001111;
        case 5:
            return 0b00011111;
        case 6:
            return 0b00111111;
        case 7:
            return 0b01111111;
        case 8:
            return 0b11111111;
    }
    return 0;
}


void init( )
{
    ADCON1 |= 0x0F;                                                             // Configure all ports with analog function as digital
    CMCON  |= 7;                                                                // Comparator off

    LED_DIR = 0;
    LED_PIN = 0;
    
    SENSORS_PWR_RESTORE_DIR = 0;
    SENSORS_PWR_RESTORE_PIN = 0;
    
    USB_PWR_DIR = 1;
}

void interrupt()
{
    if ( USBIF_bit )
    {
        USB_Interrupt_Proc();                                                   // USB servicing is done inside the interrupt
        USBIF_bit = 0;
    }

    // ���������� ������� 1
    if ( TMR1IF_bit )
    {
        TMR1IF_bit = 0;
        TMR1H      = 0x0B;
        TMR1L      = 0xD9;

        motor_acceleration_control();
    }
}

// ����� ������� � ��
void pc_data_exchange( )
{
    if ( USB_PWR_PIN )
    {
        if ( !usb_state_on )   // ��������� USB ������, �������� USB HID
        {
            usb_on();
            usb_state_on = TRUE;
        }
    }
    else
    {
        if ( usb_state_on )    // �������� USB ������, ��������� USB HID
        {
            usb_off();
            usb_state_on = FALSE;
        }
    }
    
    if ( usb_state_on )
    {
        if ( usb_read() )                                                       // �������� ������� �� ��
        {
            struct s_cmd_header *head = (struct s_cmd_header *)readbuff;

            switch ( head->name )
            {
                // ������ ������ �����
                case CMD_EU_GET_UNIT_NUMBER:
                {
                    struct s_eu_unit_number *rd = (struct s_eu_unit_number *)readbuff;
                    struct s_eu_unit_number *wr = (struct s_eu_unit_number *)writebuff;

                    wr->cmd.name   = CMD_EU_GET_UNIT_NUMBER;
                    wr->number     = unit_number;                               // ����� �����
                    wr->cmd.result = CMD_RESULT_OK;
                }
                break;
                
                // ������ ������ �����
                case CMD_EU_SET_UNIT_NUMBER:
                {
                    struct s_eu_unit_number *rd = (struct s_eu_unit_number *)readbuff;
                    struct s_eu_unit_number *wr = (struct s_eu_unit_number *)writebuff;

                    wr->cmd.name = CMD_EU_SET_UNIT_NUMBER;
                    
                    if ( rd->number >= 1 && rd->number <= 253 )
                    {
                        if ( write_config_byte(0x00, rd->number) )
                        {
                            unit_number    = rd->number;                            // ����� �����
                            wr->cmd.result = CMD_RESULT_OK;                         // �������
                            reboot_needed  = TRUE;                                  // ��������� ������������
                        }
                        else
                        {
                            wr->cmd.result = CMD_RESULT_EEPROM_WRITE_FAIL;          // ������ ��� ������ EEPROM
                        }
                    }
                    else
                    {
                        wr->cmd.result = CMD_RESULT_BAD_INDEX;                       // ������������ ����� �����
                    }
                }
                break;
                
                // ������ ��������� ��������
                case CMD_EU_GET_SENSORS_STATE:
                {
                    struct s_eu_sensors_state *rd = (struct s_eu_sensors_state *)readbuff;
                    struct s_eu_sensors_state *wr = (struct s_eu_sensors_state *)writebuff;

                    wr->cmd.name   = CMD_EU_GET_SENSORS_STATE;
                    wr->count      = SENSORS_COUNT - protected_motors;          // ���������� ��������� ��������
                    wr->state      = sensors_state;                             // ��������� ��������
                    wr->cmd.result = CMD_RESULT_OK;
                }
                break;
                
                // ������ ��������� ����������
                case CMD_EU_GET_MOTORS_STATE:
                {
                    struct s_eu_motors_state *rd = (struct s_eu_motors_state *)readbuff;
                    struct s_eu_motors_state *wr = (struct s_eu_motors_state *)writebuff;

                    wr->cmd.name   = CMD_EU_GET_MOTORS_STATE;
                    wr->state      = (char)(motors_state & 0x000000ff);         // ��������� ���������� (���/����)
                    wr->protect    = motor_get_protect_mask(protected_motors);  // �������� ������ (������������/�� ������������)
                    wr->cmd.result = CMD_RESULT_OK;
                }
                break;
                
                // ������ ������������ ���������
                case CMD_EU_GET_MOTOR_CONFIG:
                {
                    struct s_eu_motor_config *rd = (struct s_eu_motor_config *)readbuff;
                    struct s_eu_motor_config *wr = (struct s_eu_motor_config *)writebuff;

                    wr->cmd.name   = CMD_EU_GET_MOTOR_CONFIG;
                    if ( rd->number >= 0 && rd->number < 8 )
                    {
                        wr->number     = rd->number;
                        wr->state      = (motors_state & (1 << rd->number)) ? TRUE : FALSE;   // ���/����
                        wr->protect    = motors[rd->number].protect;                          // ������������/�� ������������
                        wr->start_time = motors[rd->number].start_time / 10;                  // ����� �������
                        wr->cmd.result = CMD_RESULT_OK;
                    }
                    else
                    {
                        wr->cmd.result = CMD_RESULT_BAD_INDEX;
                    }
                }
                break;
                
                // ������ ������������ ���������
                case CMD_EU_SET_MOTOR_CONFIG:
                {
                    struct s_eu_motor_config *rd = (struct s_eu_motor_config *)readbuff;
                    struct s_eu_motor_config *wr = (struct s_eu_motor_config *)writebuff;

                    wr->cmd.name = CMD_EU_SET_MOTOR_CONFIG;
                    if ( rd->number >= 0 && rd->number < 8 )
                    {
                        char i, enable = TRUE;

                        // ��������� �������
                        if ( rd->protect )
                        {
                            for ( i = 0; i < rd->number; ++i )
                                if ( !motors[i].protect )
                                    enable = FALSE;
                        }
                        else
                        {
                            for ( i = 8 - 1; i > rd->number; --i )
                                if ( motors[i].protect )
                                    enable = FALSE;
                        }
                        
                        // ������� ������
                        if ( enable )
                        {
                            motor_stop(rd->number, FALSE);                       // ������������� ���������
                            
                            if ( write_config_byte(0x01 + (rd->number * 3), rd->protect) && write_config_word(0x02 + (rd->number * 3), rd->start_time * 10) )
                            {
                                motors[rd->number].protect = rd->protect;            // ������
                                motors[rd->number].start_time = rd->start_time * 10; // ����� �������

                                protected_motors = motor_get_protected();            // ������������� ���������� �������������� ����������
                            
                                wr->cmd.result = CMD_RESULT_OK;
                            }
                            else
                            {
                                wr->cmd.result = CMD_RESULT_EEPROM_WRITE_FAIL;
                            }
                        }
                        else
                        {
                            wr->cmd.result = CMD_RESULT_BAD_PROTECT_ORDER;
                        }
                    }
                    else
                    {
                        wr->cmd.result = CMD_RESULT_BAD_INDEX;
                    }
                }
                break;
                
                // ��������� ��������� ���������
                case CMD_EU_GET_MOTOR_STATE:
                {
                    struct s_eu_motor_state *rd = (struct s_eu_motor_state *)readbuff;
                    struct s_eu_motor_state *wr = (struct s_eu_motor_state *)writebuff;

                    wr->cmd.name = CMD_EU_GET_MOTOR_STATE;
                    if ( rd->number >= 0 && rd->number < 8 )
                    {
                        wr->state = (motors_state & (1 << rd->number)) ? TRUE : FALSE;  // ��������� ���������
                        wr->cmd.result = CMD_RESULT_OK;
                    }
                    else
                    {
                        wr->cmd.result = CMD_RESULT_BAD_INDEX;
                    }
                }
                break;
                
                // ��������� ��������� ���������
                case CMD_EU_SET_MOTOR_STATE:
                {
                    struct s_eu_motor_state *rd = (struct s_eu_motor_state *)readbuff;
                    struct s_eu_motor_state *wr = (struct s_eu_motor_state *)writebuff;

                    wr->cmd.name = CMD_EU_SET_MOTOR_STATE;
                    if ( rd->number >= 0 && rd->number < 8 )
                    {
                        if ( rd->state )
                            motor_start(rd->number);                            // ������
                        else
                            motor_stop(rd->number, FALSE);                      // ���������
                            
                        wr->cmd.result = CMD_RESULT_OK;
                    }
                    else
                    {
                        wr->cmd.result = CMD_RESULT_BAD_INDEX;
                    }
                }
                break;
                
                // ��������� (� ����/�� � ����)
                case CMD_EU_GET_UNIT_STATE:
                {
                    struct s_eu_unit_state *rd = (struct s_eu_unit_state *)readbuff;
                    struct s_eu_unit_state *wr = (struct s_eu_unit_state *)writebuff;

                    wr->cmd.name   = CMD_EU_GET_UNIT_STATE;
                    wr->state      = is_connected;                              // ��������� �����
                    wr->cmd.result = CMD_RESULT_OK;
                }
                break;
                
                // �������� ������������
                case CMD_EU_LOAD_CONFIG:
                {
                    struct s_eu_config_data *rd = (struct s_eu_config_data *)readbuff;
                    struct s_eu_config_data *wr = (struct s_eu_config_data *)writebuff;

                    wr->cmd.name = CMD_EU_LOAD_CONFIG;
                    
                    if ( !(rd->magic[0] == 'E' && rd->magic[1] == 'C' && rd->magic[2] == 'O' && rd->magic[3] == 'N' && rd->magic[4] == 'F') )
                    {
                        wr->cmd.result = CMD_RESULT_BAD_FORMAT;
                    }
                    else
                    {
                        if ( crc16(rd->magic, 30) == rd->check_sum )
                        {
                            uchar res = TRUE;
                            uchar i;
                            uchar *p;
                            
                            res = write_config_byte(0x00, rd->number);
                            
                            p = rd->protect;
                            for ( i = 0; i < 24; i += 3 )
                            {
                                res &= write_config_byte(0x01 + i, *(uchar *)p);
                                p += 1;
                                res &= write_config_word(0x02 + i, *(ushort *)p);
                                p += 2;
                            }
                            
                            if ( res )
                            {
                                wr->cmd.result = CMD_RESULT_OK;                 // �������
                                reboot_needed  = TRUE;                          // ��������� ������������
                            }
                            else
                                wr->cmd.result = CMD_RESULT_EEPROM_WRITE_FAIL;  // ������ ��� ������ EEPROM
                        }
                        else
                        {
                            wr->cmd.result = CMD_RESULT_BAD_CHECK_SUM;
                        }
                    }
                }
                break;
                
                // ���������� ������������
                case CMD_EU_SAVE_CONFIG:
                {
                    struct s_eu_config_data *rd = (struct s_eu_config_data *)readbuff;
                    struct s_eu_config_data *wr = (struct s_eu_config_data *)writebuff;
                    uchar i;
                    uchar *p;
                    
                    wr->cmd.name = CMD_EU_SAVE_CONFIG;
                    
                    wr->magic[0] = 'E';
                    wr->magic[1] = 'C';
                    wr->magic[2] = 'O';
                    wr->magic[3] = 'N';
                    wr->magic[4] = 'F';
                    wr->number   = unit_number;

                    p = wr->protect;
                    for ( i = 0; i < MOTOR_MAX; ++i )
                    {
                        *(uchar *)p  = motors[i].protect;
                        p += 1;
                        *(ushort *)p = motors[i].start_time;
                        p += 2;
                    }
                    
                    wr->check_sum = crc16(wr->magic, 30);                       // ������������ ����������� �����, ������� � magic
                    
                    wr->cmd.result = CMD_RESULT_OK;
                }
                break;
                
                // ������������ �������
                default:
                {
                    struct s_cmd_header *wr = (struct s_cmd_header *)writebuff;
                    memset(writebuff, 0, USB_REPORT_SIZE);
                    wr->name = CMD_EU_UNKNOWN;
                    wr->result = CMD_RESULT_FAIL;
                }
            }
            
            usb_write();                                                        // �������� ������� � ��
        }
    }
}

// �������� ������������
void reboot_check( )
{
    if ( reboot_needed )
    {
        // ��������� USB
        if ( usb_state_on )
            usb_off();
        
        // ��������
        delay_ms(1000);
        
        // �����
        __asm reset
    }
}


void main()
{
    delay_ms(1000);                                                             // ���� ������������� ��������� �����������
    
    init();                                                                     // ����� �������������
    
    transceiver_init();                                                         // ����������������
    
    hc165_init();                                                               // HC165
    
    motor_init();                                                               // ���������
    
    load_config();                                                              // �������� ������������
    
    timer1_init();
    
    net_init(5);                                                                // ����
    
    net_set_params(unit_number, 20);                                            // ��������� ���������� �����������������
    
    // ��������� ���������� � ������������ ����������
    INTCON.GIE  = 1;
    INTCON.PEIE = 1;

    while ( TRUE )
    {
        // ��������� �������� �������
        exec_commands();
         
        // ���������� ��������� ���������� � ���������� �������
        if ( motor_read(&motors_state) || changes )
            if ( net_send(SERVER_ADDRESS, NET_CMD_MOTORS_STATE, (uchar *)&motors_state, 0) == 0 )
                motor_reset_fail_state(); // ���� ������� � ��������� ���������� ������� ����������, ���������� ��������� ��������� ����������
         
        // ���������� ��������� ������ � ���������� �������
        if ( sensors_read(&sensors_state) || changes )
            net_send(SERVER_ADDRESS, NET_CMD_SENSORS_STATE, (uchar *)&sensors_state, 0);
        
        // ������������ ������� �������� ����������
        motor_protect_control();
        
        // ����� ������ � ��
        pc_data_exchange();
        
        // ��������� ����������
        changes = FALSE;
        
        // ���� reboot_needed = TRUE, ����� ��������� ������������
        reboot_check();
    }
}