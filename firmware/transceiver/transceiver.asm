
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;transceiver.c,147 :: 		void interrupt( )
;transceiver.c,149 :: 		if ( TMR0IF_bit )                                                           // Переполение таймера 0 (данные не передаются в течении длительного времени)
	BTFSS      TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
	GOTO       L_interrupt0
;transceiver.c,151 :: 		TMR0IF_bit = 0;                                                         // Сброс флага переполнения таймера 0
	BCF        TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
;transceiver.c,152 :: 		recv_done = 0;
	BCF        _recv_done+0, BitPos(_recv_done+0)
;transceiver.c,153 :: 		recv_processing = 0;                                                    // Устанавливаем состояние свободной линии (никто не передает данные)
	BCF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,154 :: 		}
L_interrupt0:
;transceiver.c,156 :: 		if ( INTF_bit )                                                             // Прерывание INT0 (прием данных)
	BTFSS      INTF_bit+0, BitPos(INTF_bit+0)
	GOTO       L_interrupt1
;transceiver.c,158 :: 		INTF_bit = 0;                                                           // Сброс флага INT0
	BCF        INTF_bit+0, BitPos(INTF_bit+0)
;transceiver.c,160 :: 		if ( recv_done == 0 )                                                   // Прием разрешен (все предыдущие пакеты обработаны)
	BTFSC      _recv_done+0, BitPos(_recv_done+0)
	GOTO       L_interrupt2
;transceiver.c,162 :: 		if ( recv_processing == 0 )                                         // Если прием данных еще не начат (начало приема)
	BTFSC      _recv_processing+0, BitPos(_recv_processing+0)
	GOTO       L_interrupt3
;transceiver.c,164 :: 		recv_processing = 1;                                            // Прием начат
	BSF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,165 :: 		recv_byte = 0;                                                  // Обнуляем приемный байт
	CLRF       _recv_byte+0
;transceiver.c,166 :: 		recv_bit_counter = 0;                                           // Обнуляем счетчик битов
	CLRF       _recv_bit_counter+0
;transceiver.c,167 :: 		recv_byte_counter = 0;                                          // Обнуляем счетчик байтов
	CLRF       _recv_byte_counter+0
;transceiver.c,168 :: 		TMR0 = 0;                                                       // Сбрасываем таймер 0
	CLRF       TMR0+0
;transceiver.c,169 :: 		}
	GOTO       L_interrupt4
L_interrupt3:
;transceiver.c,172 :: 		bit_time = TMR0;
	MOVF       TMR0+0, 0
	MOVWF      _bit_time+0
;transceiver.c,174 :: 		if ( (bit_time > 20) && (bit_time < 30) )                       // Единица
	MOVF       _bit_time+0, 0
	SUBLW      20
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt7
	MOVLW      30
	SUBWF      _bit_time+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt7
L__interrupt102:
;transceiver.c,176 :: 		recv_byte <<= 1;                                            // Сдвиг
	RLF        _recv_byte+0, 1
	BCF        _recv_byte+0, 0
;transceiver.c,177 :: 		recv_byte |= 1;                                             // Установка бита
	BSF        _recv_byte+0, 0
;transceiver.c,178 :: 		}
L_interrupt7:
;transceiver.c,180 :: 		if ( bit_time > 8 && bit_time < 16 )                            // Ноль
	MOVF       _bit_time+0, 0
	SUBLW      8
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt10
	MOVLW      16
	SUBWF      _bit_time+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt10
L__interrupt101:
;transceiver.c,182 :: 		recv_byte <<= 1;
	RLF        _recv_byte+0, 1
	BCF        _recv_byte+0, 0
;transceiver.c,183 :: 		asm {nop};                                                  // Сдвиг
	NOP
;transceiver.c,184 :: 		}
L_interrupt10:
;transceiver.c,186 :: 		if ( ++recv_bit_counter == 8 )                                  // Принято 8 бит (байт)
	INCF       _recv_bit_counter+0, 1
	MOVF       _recv_bit_counter+0, 0
	XORLW      8
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;transceiver.c,188 :: 		recv_buf[recv_byte_counter] = recv_byte;                    // Помещаем принятый байт в приемный буфер
	MOVF       _recv_byte_counter+0, 0
	ADDLW      _recv_buf+0
	MOVWF      FSR
	MOVF       _recv_byte+0, 0
	MOVWF      INDF+0
;transceiver.c,189 :: 		recv_byte = 0;                                              // Очищаем байт
	CLRF       _recv_byte+0
;transceiver.c,190 :: 		recv_bit_counter = 0;                                       // Обнуляем счетчик битов
	CLRF       _recv_bit_counter+0
;transceiver.c,192 :: 		if ( ++recv_byte_counter == PACKET_SIZE )                   // Увеличиваем счетчик байтов
	INCF       _recv_byte_counter+0, 1
	MOVF       _recv_byte_counter+0, 0
	XORLW      8
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;transceiver.c,193 :: 		recv_done = 1;                                          // Прием пакета завершен (необходимо забрать и обработать данные из приемного буфера)
	BSF        _recv_done+0, BitPos(_recv_done+0)
L_interrupt12:
;transceiver.c,194 :: 		}
L_interrupt11:
;transceiver.c,196 :: 		TMR0 = 0;                                                       // Обнуляем таймер 0
	CLRF       TMR0+0
;transceiver.c,197 :: 		}
L_interrupt4:
;transceiver.c,198 :: 		}
L_interrupt2:
;transceiver.c,199 :: 		}
L_interrupt1:
;transceiver.c,200 :: 		}
L_end_interrupt:
L__interrupt113:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_crc8:

;transceiver.c,217 :: 		unsigned char crc8( unsigned char *block )
;transceiver.c,219 :: 		unsigned char crc = 0xFF;
	MOVLW      255
	MOVWF      crc8_crc_L0+0
	MOVLW      7
	MOVWF      crc8_len_L0+0
;transceiver.c,223 :: 		while ( len-- )
L_crc813:
	MOVF       crc8_len_L0+0, 0
	MOVWF      R0+0
	DECF       crc8_len_L0+0, 1
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_crc814
;transceiver.c,225 :: 		crc ^= *block++;
	MOVF       FARG_crc8_block+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      crc8_crc_L0+0, 1
	INCF       FARG_crc8_block+0, 1
;transceiver.c,226 :: 		for ( i = 0; i < 8; i++ )
	CLRF       R3+0
L_crc815:
	MOVLW      8
	SUBWF      R3+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_crc816
;transceiver.c,227 :: 		crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
	BTFSS      crc8_crc_L0+0, 7
	GOTO       L_crc818
	MOVF       crc8_crc_L0+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	RLF        R1+0, 1
	RLF        R1+1, 1
	BCF        R1+0, 0
	MOVLW      49
	XORWF      R1+0, 1
	MOVLW      0
	MOVWF      R1+1
	GOTO       L_crc819
L_crc818:
	MOVF       crc8_crc_L0+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	RLF        R1+0, 1
	RLF        R1+1, 1
	BCF        R1+0, 0
L_crc819:
	MOVF       R1+0, 0
	MOVWF      crc8_crc_L0+0
;transceiver.c,226 :: 		for ( i = 0; i < 8; i++ )
	INCF       R3+0, 1
;transceiver.c,227 :: 		crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
	GOTO       L_crc815
L_crc816:
;transceiver.c,228 :: 		}
	GOTO       L_crc813
L_crc814:
;transceiver.c,230 :: 		return crc;
	MOVF       crc8_crc_L0+0, 0
	MOVWF      R0+0
;transceiver.c,231 :: 		}
L_end_crc8:
	RETURN
; end of _crc8

_send_data:

;transceiver.c,235 :: 		void send_data( unsigned char *d, unsigned char size )
;transceiver.c,239 :: 		while ( size-- )                                                            // Последовательно передаем все байты
L_send_data20:
	MOVF       FARG_send_data_size+0, 0
	MOVWF      R0+0
	DECF       FARG_send_data_size+0, 1
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_send_data21
;transceiver.c,241 :: 		b = *d++;
	MOVF       FARG_send_data_d+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R1+0
	INCF       FARG_send_data_d+0, 1
;transceiver.c,243 :: 		for ( i = 0; i < 8; i++ )                                               // Последовательная передача 8-ми бит
	CLRF       R2+0
L_send_data22:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_send_data23
;transceiver.c,245 :: 		DI_PIN = 0;                                                         // Стартовое условие
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,246 :: 		Delay_us(BIT_START_TIME);
	MOVLW      16
	MOVWF      R13+0
L_send_data25:
	DECFSZ     R13+0, 1
	GOTO       L_send_data25
	NOP
;transceiver.c,247 :: 		DI_PIN = 1;
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,249 :: 		if ( b & 0b10000000 )                                               // Единица
	BTFSS      R1+0, 7
	GOTO       L_send_data26
;transceiver.c,250 :: 		Delay_us(BIT_ONE_TIME);
	MOVLW      49
	MOVWF      R13+0
L_send_data27:
	DECFSZ     R13+0, 1
	GOTO       L_send_data27
	NOP
	NOP
	GOTO       L_send_data28
L_send_data26:
;transceiver.c,252 :: 		Delay_us(BIT_ZERO_TIME);
	MOVLW      16
	MOVWF      R13+0
L_send_data29:
	DECFSZ     R13+0, 1
	GOTO       L_send_data29
	NOP
L_send_data28:
;transceiver.c,254 :: 		b <<= 1;                                                            // Сдвиг
	RLF        R1+0, 1
	BCF        R1+0, 0
;transceiver.c,243 :: 		for ( i = 0; i < 8; i++ )                                               // Последовательная передача 8-ми бит
	INCF       R2+0, 1
;transceiver.c,255 :: 		}
	GOTO       L_send_data22
L_send_data23:
;transceiver.c,256 :: 		}
	GOTO       L_send_data20
L_send_data21:
;transceiver.c,259 :: 		DI_PIN = 0;                                                                 // Завершение передачи данных
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,260 :: 		Delay_us(BIT_START_TIME);
	MOVLW      16
	MOVWF      R13+0
L_send_data30:
	DECFSZ     R13+0, 1
	GOTO       L_send_data30
	NOP
;transceiver.c,261 :: 		DI_PIN = 1;
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,262 :: 		}
L_end_send_data:
	RETURN
; end of _send_data

_send_ack:

;transceiver.c,265 :: 		void send_ack( unsigned char *bf )
;transceiver.c,267 :: 		Delay_us(500);
	MOVLW      4
	MOVWF      R12+0
	MOVLW      61
	MOVWF      R13+0
L_send_ack31:
	DECFSZ     R13+0, 1
	GOTO       L_send_ack31
	DECFSZ     R12+0, 1
	GOTO       L_send_ack31
	NOP
	NOP
;transceiver.c,269 :: 		send_buf[0] = device_addr;                                                  // Отправитель
	MOVF       _device_addr+0, 0
	MOVWF      _send_buf+0
;transceiver.c,270 :: 		send_buf[1] = bf[0];                                                        // Получатель
	MOVF       FARG_send_ack_bf+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _send_buf+1
;transceiver.c,271 :: 		send_buf[2] = bf[2] | 0b10000000;                                           // Номер пакета (устанавливаем 8 бит номера пакета - признак того, что данный пакет подтверждающий)
	MOVLW      2
	ADDWF      FARG_send_ack_bf+0, 0
	MOVWF      FSR
	MOVLW      128
	IORWF      INDF+0, 0
	MOVWF      _send_buf+2
;transceiver.c,272 :: 		send_buf[3] = 0;                                                            // 1 байт данных (пусто)
	CLRF       _send_buf+3
;transceiver.c,273 :: 		send_buf[4] = 0;                                                            // 2 байт данных (пусто)
	CLRF       _send_buf+4
;transceiver.c,274 :: 		send_buf[5] = 0;                                                            // 3 байт данных (пусто)
	CLRF       _send_buf+5
;transceiver.c,275 :: 		send_buf[6] = 0;                                                            // 4 байт данных (пусто)
	CLRF       _send_buf+6
;transceiver.c,276 :: 		send_buf[7] = crc8(send_buf);                                               // Контрольная сумма пакета
	MOVLW      _send_buf+0
	MOVWF      FARG_crc8_block+0
	CALL       _crc8+0
	MOVF       R0+0, 0
	MOVWF      _send_buf+7
;transceiver.c,278 :: 		MAX485_TRANSMIT;
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,280 :: 		send_data(send_buf, PACKET_SIZE);                                           // Передаем
	MOVLW      _send_buf+0
	MOVWF      FARG_send_data_d+0
	MOVLW      8
	MOVWF      FARG_send_data_size+0
	CALL       _send_data+0
;transceiver.c,282 :: 		MAX485_RECEIVE;                                                             // Переводим MAX485 в режим приема
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,283 :: 		}
L_end_send_ack:
	RETURN
; end of _send_ack

_send_packet:

;transceiver.c,286 :: 		unsigned char send_packet( unsigned char *cmd )
;transceiver.c,288 :: 		unsigned char res = ERR_PACKET_LOST;                                        // Результат выполнения
	MOVLW      2
	MOVWF      send_packet_res_L0+0
;transceiver.c,289 :: 		signed char ack_wait = ack_timeout;                                         // Время одижания получения подтверждения
	MOVF       _ack_timeout+0, 0
	MOVWF      send_packet_ack_wait_L0+0
;transceiver.c,291 :: 		if ( ++packet_num > 127 )                                                   // Увеличиваем номер пакета
	INCF       _packet_num+0, 1
	MOVF       _packet_num+0, 0
	SUBLW      127
	BTFSC      STATUS+0, 0
	GOTO       L_send_packet32
;transceiver.c,292 :: 		packet_num = 0;
	CLRF       _packet_num+0
L_send_packet32:
;transceiver.c,294 :: 		send_buf[0] = device_addr;                                                  // Отправитель
	MOVF       _device_addr+0, 0
	MOVWF      _send_buf+0
;transceiver.c,295 :: 		send_buf[1] = cmd[0];                                                       // Получатель
	MOVF       FARG_send_packet_cmd+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _send_buf+1
;transceiver.c,296 :: 		send_buf[2] = packet_num;                                                   // Номер пакета
	MOVF       _packet_num+0, 0
	MOVWF      _send_buf+2
;transceiver.c,297 :: 		send_buf[3] = cmd[1];                                                       // Первый байт данных (адрес)
	INCF       FARG_send_packet_cmd+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _send_buf+3
;transceiver.c,298 :: 		send_buf[4] = cmd[2];                                                       // Второй байт данных
	MOVLW      2
	ADDWF      FARG_send_packet_cmd+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _send_buf+4
;transceiver.c,299 :: 		send_buf[5] = cmd[3];                                                       // Третий байт данных
	MOVLW      3
	ADDWF      FARG_send_packet_cmd+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _send_buf+5
;transceiver.c,300 :: 		send_buf[6] = cmd[4];                                                       // Четвертый байт данных
	MOVLW      4
	ADDWF      FARG_send_packet_cmd+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _send_buf+6
;transceiver.c,301 :: 		send_buf[7] = crc8(send_buf);                                               // Контрольная сумма пакета
	MOVLW      _send_buf+0
	MOVWF      FARG_crc8_block+0
	CALL       _crc8+0
	MOVF       R0+0, 0
	MOVWF      _send_buf+7
;transceiver.c,303 :: 		recv_done = 0;                                                              // Приемник готов к приему данных
	BCF        _recv_done+0, BitPos(_recv_done+0)
;transceiver.c,304 :: 		recv_processing = 0;
	BCF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,306 :: 		MAX485_TRANSMIT;                                                            // Переводим MAX485 в режим передачи
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,308 :: 		send_data(send_buf, PACKET_SIZE);                                           // Отправляем пакет адресату
	MOVLW      _send_buf+0
	MOVWF      FARG_send_data_d+0
	MOVLW      8
	MOVWF      FARG_send_data_size+0
	CALL       _send_data+0
;transceiver.c,310 :: 		MAX485_RECEIVE;                                                             // Переводим MAX485 в режим приема
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,313 :: 		INTCON.T0IE = 0;                                                            // Отключаем таймер для того чтобы не потерять ACK
	BCF        INTCON+0, 5
;transceiver.c,314 :: 		TMR0 = 0;
	CLRF       TMR0+0
;transceiver.c,316 :: 		INT_ENABLE;                                                                 // Разрешаем прерывания
	BSF        INTCON+0, 7
;transceiver.c,318 :: 		while ( ack_wait-- > 0 )                                                    // Ожидаем приема подтверждения получения команды
L_send_packet33:
	MOVF       send_packet_ack_wait_L0+0, 0
	MOVWF      R1+0
	DECF       send_packet_ack_wait_L0+0, 1
	MOVLW      128
	XORLW      0
	MOVWF      R0+0
	MOVLW      128
	XORWF      R1+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_send_packet34
;transceiver.c,320 :: 		if ( recv_done )                                                        // Данные получены
	BTFSS      _recv_done+0, BitPos(_recv_done+0)
	GOTO       L_send_packet35
;transceiver.c,322 :: 		INT_DISABLE;
	BCF        INTCON+0, 7
;transceiver.c,324 :: 		if ( crc8(recv_buf) == recv_buf[PACKET_SIZE - 1] )                   // Если контрольная сумма верная
	MOVLW      _recv_buf+0
	MOVWF      FARG_crc8_block+0
	CALL       _crc8+0
	MOVF       R0+0, 0
	XORWF      _recv_buf+7, 0
	BTFSS      STATUS+0, 2
	GOTO       L_send_packet36
;transceiver.c,326 :: 		if ( recv_buf[2] & 0b10000000 )                                 // Если полученные данные это подтверждение (ACK) ( установлен 8-й бит в номере пакета)
	BTFSS      _recv_buf+2, 7
	GOTO       L_send_packet37
;transceiver.c,328 :: 		if ( (recv_buf[0] == cmd[0]) && (recv_buf[1] == device_addr) && ((recv_buf[2] & 0b01111111) == packet_num) )  // Если ACK данные получателя, отправителя и номер пакета совпадают
	MOVF       FARG_send_packet_cmd+0, 0
	MOVWF      FSR
	MOVF       _recv_buf+0, 0
	XORWF      INDF+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_send_packet40
	MOVF       _recv_buf+1, 0
	XORWF      _device_addr+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_send_packet40
	MOVLW      127
	ANDWF      _recv_buf+2, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORWF      _packet_num+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_send_packet40
L__send_packet103:
;transceiver.c,330 :: 		res = ERR_OK;                                           // Подтверждение получено, команда принята получателем
	CLRF       send_packet_res_L0+0
;transceiver.c,331 :: 		break;
	GOTO       L_send_packet34
;transceiver.c,332 :: 		}
L_send_packet40:
;transceiver.c,333 :: 		}
L_send_packet37:
;transceiver.c,334 :: 		}
L_send_packet36:
;transceiver.c,335 :: 		recv_processing = 0;                                                // Устанавливаем прием нового пакета
	BCF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,336 :: 		recv_done = 0;
	BCF        _recv_done+0, BitPos(_recv_done+0)
;transceiver.c,338 :: 		INT_ENABLE;
	BSF        INTCON+0, 7
;transceiver.c,339 :: 		}
L_send_packet35:
;transceiver.c,341 :: 		Delay_ms(1);                                                            // Ждем ответа
	MOVLW      7
	MOVWF      R12+0
	MOVLW      125
	MOVWF      R13+0
L_send_packet41:
	DECFSZ     R13+0, 1
	GOTO       L_send_packet41
	DECFSZ     R12+0, 1
	GOTO       L_send_packet41
;transceiver.c,342 :: 		}
	GOTO       L_send_packet33
L_send_packet34:
;transceiver.c,344 :: 		INT_DISABLE;                                                                // Запрещаем прерывания
	BCF        INTCON+0, 7
;transceiver.c,346 :: 		INTCON.T0IE = 1;                                                            // Восстанавливаем таймер
	BSF        INTCON+0, 5
;transceiver.c,348 :: 		recv_processing = 0;                                                        // Устанавливаем прием нового пакета
	BCF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,349 :: 		recv_done = 0;
	BCF        _recv_done+0, BitPos(_recv_done+0)
;transceiver.c,351 :: 		return res;                                                                 // Возвращаем результат
	MOVF       send_packet_res_L0+0, 0
	MOVWF      R0+0
;transceiver.c,352 :: 		}
L_end_send_packet:
	RETURN
; end of _send_packet

_push_command:

;transceiver.c,355 :: 		void push_command( )
;transceiver.c,357 :: 		if ( data_queue_size == QUEUE_SIZE - 1 )                                    // Если очередь полностью заполнена, игнорируем принимаемые данные
	MOVF       _data_queue_size+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_push_command42
;transceiver.c,358 :: 		return;
	GOTO       L_end_push_command
L_push_command42:
;transceiver.c,360 :: 		data_queue[data_queue_size].b[0] = recv_buf[0];                             // Отправитель
	MOVLW      5
	MOVWF      R0+0
	MOVF       _data_queue_size+0, 0
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVF       R0+0, 0
	ADDLW      _data_queue+0
	MOVWF      FSR
	MOVF       _recv_buf+0, 0
	MOVWF      INDF+0
;transceiver.c,361 :: 		data_queue[data_queue_size].b[1] = recv_buf[3];                             // Первый байт данных
	MOVLW      5
	MOVWF      R0+0
	MOVF       _data_queue_size+0, 0
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVLW      _data_queue+0
	ADDWF      R0+0, 1
	INCF       R0+0, 0
	MOVWF      FSR
	MOVF       _recv_buf+3, 0
	MOVWF      INDF+0
;transceiver.c,362 :: 		data_queue[data_queue_size].b[2] = recv_buf[4];                             // Второй байт данных
	MOVLW      5
	MOVWF      R0+0
	MOVF       _data_queue_size+0, 0
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVLW      _data_queue+0
	ADDWF      R0+0, 1
	MOVLW      2
	ADDWF      R0+0, 0
	MOVWF      FSR
	MOVF       _recv_buf+4, 0
	MOVWF      INDF+0
;transceiver.c,363 :: 		data_queue[data_queue_size].b[3] = recv_buf[5];                             // Третий байт данных
	MOVLW      5
	MOVWF      R0+0
	MOVF       _data_queue_size+0, 0
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVLW      _data_queue+0
	ADDWF      R0+0, 1
	MOVLW      3
	ADDWF      R0+0, 0
	MOVWF      FSR
	MOVF       _recv_buf+5, 0
	MOVWF      INDF+0
;transceiver.c,364 :: 		data_queue[data_queue_size].b[4] = recv_buf[6];                             // Третий байт данных
	MOVLW      5
	MOVWF      R0+0
	MOVF       _data_queue_size+0, 0
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVLW      _data_queue+0
	ADDWF      R0+0, 1
	MOVLW      4
	ADDWF      R0+0, 0
	MOVWF      FSR
	MOVF       _recv_buf+6, 0
	MOVWF      INDF+0
;transceiver.c,366 :: 		data_queue_size++;                                                          // Смещаем указатель на последний элемент очереди
	INCF       _data_queue_size+0, 1
;transceiver.c,367 :: 		}
L_end_push_command:
	RETURN
; end of _push_command

_pop_command:

;transceiver.c,370 :: 		void pop_command( struct s_data_queue *cmd )
;transceiver.c,374 :: 		if ( data_queue_size == 0 )                                                     // Если очередь пуста, ничего не делаем
	MOVF       _data_queue_size+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_pop_command43
;transceiver.c,375 :: 		return;
	GOTO       L_end_pop_command
L_pop_command43:
;transceiver.c,377 :: 		memcpy(cmd, &data_queue[0], sizeof(struct s_data_queue));                    // Извлекаем первый элемент из очереди
	MOVF       FARG_pop_command_cmd+0, 0
	MOVWF      FARG_memcpy_d1+0
	MOVLW      _data_queue+0
	MOVWF      FARG_memcpy_s1+0
	MOVLW      5
	MOVWF      FARG_memcpy_n+0
	MOVLW      0
	MOVWF      FARG_memcpy_n+1
	CALL       _memcpy+0
;transceiver.c,379 :: 		for ( i = 0; i < data_queue_size - 1; ++i )                                 // Смещаем очередь
	CLRF       pop_command_i_L0+0
L_pop_command44:
	MOVLW      1
	SUBWF      _data_queue_size+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	BTFSS      STATUS+0, 0
	DECF       R1+1, 1
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	XORWF      R1+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__pop_command120
	MOVF       R1+0, 0
	SUBWF      pop_command_i_L0+0, 0
L__pop_command120:
	BTFSC      STATUS+0, 0
	GOTO       L_pop_command45
;transceiver.c,380 :: 		memcpy(&data_queue[i], &data_queue[i + 1], sizeof(struct s_data_queue));
	MOVLW      5
	MOVWF      R0+0
	MOVF       pop_command_i_L0+0, 0
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVF       R0+0, 0
	ADDLW      _data_queue+0
	MOVWF      FARG_memcpy_d1+0
	MOVF       pop_command_i_L0+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVLW      5
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVF       R0+0, 0
	ADDLW      _data_queue+0
	MOVWF      FARG_memcpy_s1+0
	MOVLW      5
	MOVWF      FARG_memcpy_n+0
	MOVLW      0
	MOVWF      FARG_memcpy_n+1
	CALL       _memcpy+0
;transceiver.c,379 :: 		for ( i = 0; i < data_queue_size - 1; ++i )                                 // Смещаем очередь
	INCF       pop_command_i_L0+0, 1
;transceiver.c,380 :: 		memcpy(&data_queue[i], &data_queue[i + 1], sizeof(struct s_data_queue));
	GOTO       L_pop_command44
L_pop_command45:
;transceiver.c,382 :: 		data_queue_size--;                                                          // Уменьшаем размер очереди
	DECF       _data_queue_size+0, 1
;transceiver.c,383 :: 		}
L_end_pop_command:
	RETURN
; end of _pop_command

_process_received_packet:

;transceiver.c,386 :: 		void process_received_packet( )
;transceiver.c,388 :: 		if ( recv_done )                                                            // Данные получены
	BTFSS      _recv_done+0, BitPos(_recv_done+0)
	GOTO       L_process_received_packet47
;transceiver.c,390 :: 		INT_DISABLE;                                                            // Запрещаем прерывания
	BCF        INTCON+0, 7
;transceiver.c,392 :: 		if ( crc8(recv_buf) == recv_buf[PACKET_SIZE - 1] )                      // Проверяем контрольную сумму принятых данных (последний элемент приемного буфера)
	MOVLW      _recv_buf+0
	MOVWF      FARG_crc8_block+0
	CALL       _crc8+0
	MOVF       R0+0, 0
	XORWF      _recv_buf+7, 0
	BTFSS      STATUS+0, 2
	GOTO       L_process_received_packet48
;transceiver.c,394 :: 		if ( (recv_buf[1] == device_addr) && !(recv_buf[2] & 0b10000000) )  // Если пакет адресован получателю и не является подтверждающим
	MOVF       _recv_buf+1, 0
	XORWF      _device_addr+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_process_received_packet51
	BTFSC      _recv_buf+2, 7
	GOTO       L_process_received_packet51
L__process_received_packet104:
;transceiver.c,396 :: 		send_ack(recv_buf);                                             // Посылаем подтверждение отправителю
	MOVLW      _recv_buf+0
	MOVWF      FARG_send_ack_bf+0
	CALL       _send_ack+0
;transceiver.c,397 :: 		push_command();                                                 // Помещаем данные в очередь
	CALL       _push_command+0
;transceiver.c,398 :: 		}
L_process_received_packet51:
;transceiver.c,399 :: 		}
L_process_received_packet48:
;transceiver.c,401 :: 		recv_processing = 0;                                                    // Устанавливаем прием нового пакета
	BCF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,402 :: 		recv_done = 0;                                                          // Разрешаем перезапись буфера приема
	BCF        _recv_done+0, BitPos(_recv_done+0)
;transceiver.c,404 :: 		INT_ENABLE;                                                             // Разрешаем прерывания
	BSF        INTCON+0, 7
;transceiver.c,405 :: 		}
L_process_received_packet47:
;transceiver.c,406 :: 		}
L_end_process_received_packet:
	RETURN
; end of _process_received_packet

_comm_read:

;transceiver.c,409 :: 		void comm_read( )
;transceiver.c,413 :: 		i = COMMAND_SIZE - 1;
	MOVLW      4
	MOVWF      comm_read_i_L0+0
;transceiver.c,414 :: 		n = 0;
	CLRF       comm_read_n_L0+0
;transceiver.c,416 :: 		memset(&comm_cmd, 0, sizeof(struct s_data_queue));
	MOVLW      _comm_cmd+0
	MOVWF      FARG_memset_p1+0
	CLRF       FARG_memset_character+0
	MOVLW      5
	MOVWF      FARG_memset_n+0
	MOVLW      0
	MOVWF      FARG_memset_n+1
	CALL       _memset+0
;transceiver.c,419 :: 		comm_clk_prev_state = 0;                                                    // Предыдущее состоянии COMM_CLK_PIN
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,420 :: 		comm_rd_complete = 0;
	BCF        _comm_rd_complete+0, BitPos(_comm_rd_complete+0)
;transceiver.c,422 :: 		COMM_DATA_READY_PIN = 0;                                                    // Устройство не готово к приему
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,424 :: 		INT_DISABLE;
	BCF        INTCON+0, 7
;transceiver.c,426 :: 		if ( recv_processing )
	BTFSS      _recv_processing+0, BitPos(_recv_processing+0)
	GOTO       L_comm_read52
;transceiver.c,428 :: 		INT_ENABLE;
	BSF        INTCON+0, 7
;transceiver.c,429 :: 		return;
	GOTO       L_end_comm_read
;transceiver.c,430 :: 		}
L_comm_read52:
;transceiver.c,432 :: 		while ( !COMM_WR_PIN && COMM_RD_PIN )                                       // Если COMM_WR_PIN = 0 и COMM_RD_PIN = 1 мастер устройство начало процесс отправки данных
L_comm_read53:
	BTFSC      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_comm_read54
	BTFSS      RB4_bit+0, BitPos(RB4_bit+0)
	GOTO       L_comm_read54
L__comm_read108:
;transceiver.c,434 :: 		comm_rd_complete = 1;
	BSF        _comm_rd_complete+0, BitPos(_comm_rd_complete+0)
;transceiver.c,435 :: 		COMM_DATA_DIR = 1;                                                      // Пин данных - вход
	BSF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;transceiver.c,436 :: 		COMM_DATA_READY_PIN = 1;                                                // Устанавливаем готовность к приему данных от мастер устройства
	BSF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,438 :: 		if ( COMM_CLK_PIN && comm_clk_prev_state == 0 )                         // Тактирование от мастер устройства (высокий уровень)
	BTFSS      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_comm_read59
	BTFSC      _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
	GOTO       L_comm_read59
L__comm_read107:
;transceiver.c,440 :: 		comm_clk_prev_state = 1;
	BSF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,442 :: 		comm_cmd.b[i] <<= 1;                                                  // Сдвиг
	MOVF       comm_read_i_L0+0, 0
	ADDLW      _comm_cmd+0
	MOVWF      R3+0
	MOVF       R3+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R3+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;transceiver.c,443 :: 		if ( COMM_DATA_PIN )                                                // Единица
	BTFSS      RB6_bit+0, BitPos(RB6_bit+0)
	GOTO       L_comm_read60
;transceiver.c,444 :: 		comm_cmd.b[i] |= 1;
	MOVF       comm_read_i_L0+0, 0
	ADDLW      _comm_cmd+0
	MOVWF      R1+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVLW      1
	IORWF      INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
L_comm_read60:
;transceiver.c,446 :: 		if ( ++n >= 8 )
	INCF       comm_read_n_L0+0, 1
	MOVLW      8
	SUBWF      comm_read_n_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_comm_read61
;transceiver.c,448 :: 		if ( i )
	MOVF       comm_read_i_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_comm_read62
;transceiver.c,449 :: 		i--;
	DECF       comm_read_i_L0+0, 1
L_comm_read62:
;transceiver.c,450 :: 		n = 0;
	CLRF       comm_read_n_L0+0
;transceiver.c,451 :: 		}
L_comm_read61:
;transceiver.c,452 :: 		}
L_comm_read59:
;transceiver.c,454 :: 		if ( !COMM_CLK_PIN )                                                    // Тактирование от мастер устройства (низкий уровень)
	BTFSC      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_comm_read63
;transceiver.c,455 :: 		comm_clk_prev_state = 0;
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
L_comm_read63:
;transceiver.c,456 :: 		}
	GOTO       L_comm_read53
L_comm_read54:
;transceiver.c,458 :: 		comm_clk_prev_state = 0;
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,461 :: 		if ( comm_rd_complete )                                                     // Принята команда
	BTFSS      _comm_rd_complete+0, BitPos(_comm_rd_complete+0)
	GOTO       L_comm_read64
;transceiver.c,463 :: 		if ( comm_cmd.b[0] == 255 )                              // Установка адреса устройства (если адрес получателя 0)  // fix 255 ?
	MOVF       _comm_cmd+0, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L_comm_read65
;transceiver.c,465 :: 		device_addr = comm_cmd.b[1];
	MOVF       _comm_cmd+1, 0
	MOVWF      _device_addr+0
;transceiver.c,466 :: 		ack_timeout = comm_cmd.b[2];
	MOVF       _comm_cmd+2, 0
	MOVWF      _ack_timeout+0
;transceiver.c,467 :: 		Delay_ms(50);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_comm_read66:
	DECFSZ     R13+0, 1
	GOTO       L_comm_read66
	DECFSZ     R12+0, 1
	GOTO       L_comm_read66
	DECFSZ     R11+0, 1
	GOTO       L_comm_read66
	NOP
	NOP
;transceiver.c,468 :: 		}
	GOTO       L_comm_read67
L_comm_read65:
;transceiver.c,471 :: 		if ( send_packet(comm_cmd.b) == ERR_PACKET_LOST ) // Отправка пакета
	MOVLW      _comm_cmd+0
	MOVWF      FARG_send_packet_cmd+0
	CALL       _send_packet+0
	MOVF       R0+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_comm_read68
;transceiver.c,472 :: 		memset(&comm_cmd, 0, sizeof(struct s_data_queue));                                                  // Ошибка отправки ( подтверждение не получено) - 0
	MOVLW      _comm_cmd+0
	MOVWF      FARG_memset_p1+0
	CLRF       FARG_memset_character+0
	MOVLW      5
	MOVWF      FARG_memset_n+0
	MOVLW      0
	MOVWF      FARG_memset_n+1
	CALL       _memset+0
L_comm_read68:
;transceiver.c,473 :: 		}
L_comm_read67:
;transceiver.c,474 :: 		}
L_comm_read64:
;transceiver.c,476 :: 		i = COMMAND_SIZE - 1;
	MOVLW      4
	MOVWF      comm_read_i_L0+0
;transceiver.c,477 :: 		n = 0;
	CLRF       comm_read_n_L0+0
;transceiver.c,478 :: 		while ( !COMM_RD_PIN && COMM_WR_PIN )                                       // Если COMM_WR_PIN = 1 и COMM_RD_PIN = 0 мастер устройство начало процесс отправки данных
L_comm_read69:
	BTFSC      RB4_bit+0, BitPos(RB4_bit+0)
	GOTO       L_comm_read70
	BTFSS      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_comm_read70
L__comm_read106:
;transceiver.c,480 :: 		COMM_DATA_DIR = 0;                                                      // Пин данных - вход
	BCF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;transceiver.c,481 :: 		COMM_DATA_READY_PIN = 0;
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,483 :: 		if ( COMM_CLK_PIN && comm_clk_prev_state == 0 )                         // Тактирование от мастер устройства (высокий уровень)
	BTFSS      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_comm_read75
	BTFSC      _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
	GOTO       L_comm_read75
L__comm_read105:
;transceiver.c,485 :: 		comm_clk_prev_state = 1;
	BSF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,487 :: 		if ( comm_cmd.b[i] & 0x80 )
	MOVF       comm_read_i_L0+0, 0
	ADDLW      _comm_cmd+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R1+0
	BTFSS      R1+0, 7
	GOTO       L_comm_read76
;transceiver.c,488 :: 		COMM_DATA_PIN = 1;                                              // Единица
	BSF        RB6_bit+0, BitPos(RB6_bit+0)
	GOTO       L_comm_read77
L_comm_read76:
;transceiver.c,490 :: 		COMM_DATA_PIN = 0;                                              // Ноль
	BCF        RB6_bit+0, BitPos(RB6_bit+0)
L_comm_read77:
;transceiver.c,492 :: 		comm_cmd.b[i] <<= 1;                                                     // Сдвиг
	MOVF       comm_read_i_L0+0, 0
	ADDLW      _comm_cmd+0
	MOVWF      R3+0
	MOVF       R3+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R3+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;transceiver.c,493 :: 		if ( ++n >= 8 )
	INCF       comm_read_n_L0+0, 1
	MOVLW      8
	SUBWF      comm_read_n_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_comm_read78
;transceiver.c,495 :: 		if ( i )
	MOVF       comm_read_i_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_comm_read79
;transceiver.c,496 :: 		i--;
	DECF       comm_read_i_L0+0, 1
L_comm_read79:
;transceiver.c,497 :: 		n = 0;
	CLRF       comm_read_n_L0+0
;transceiver.c,498 :: 		}
L_comm_read78:
;transceiver.c,499 :: 		}
L_comm_read75:
;transceiver.c,501 :: 		if ( !COMM_CLK_PIN )                                                    // Тактирование от мастер устройства (низкий уровень)
	BTFSC      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_comm_read80
;transceiver.c,502 :: 		comm_clk_prev_state = 0;
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
L_comm_read80:
;transceiver.c,503 :: 		}
	GOTO       L_comm_read69
L_comm_read70:
;transceiver.c,505 :: 		COMM_DATA_READY_PIN = 0;
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,506 :: 		COMM_DATA_DIR = 1;
	BSF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;transceiver.c,508 :: 		INT_ENABLE;
	BSF        INTCON+0, 7
;transceiver.c,509 :: 		}
L_end_comm_read:
	RETURN
; end of _comm_read

_comm_write:

;transceiver.c,514 :: 		void comm_write( )
;transceiver.c,518 :: 		i = COMMAND_SIZE - 1;
	MOVLW      4
	MOVWF      comm_write_i_L0+0
;transceiver.c,519 :: 		n = 0;
	CLRF       comm_write_n_L0+0
;transceiver.c,521 :: 		memset(&comm_cmd, 0, sizeof(struct s_data_queue));
	MOVLW      _comm_cmd+0
	MOVWF      FARG_memset_p1+0
	CLRF       FARG_memset_character+0
	MOVLW      5
	MOVWF      FARG_memset_n+0
	MOVLW      0
	MOVWF      FARG_memset_n+1
	CALL       _memset+0
;transceiver.c,524 :: 		comm_clk_prev_state = 0;                                                    // Предыдущее состоянии COMM_CLK_PIN
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,525 :: 		comm_wr_processed = 0;                                                      // Процесс передачи не начат
	BCF        _comm_wr_processed+0, BitPos(_comm_wr_processed+0)
;transceiver.c,527 :: 		COMM_DATA_READY_PIN = 0;                                                    // Устройство не готово к приему
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,529 :: 		INT_DISABLE;
	BCF        INTCON+0, 7
;transceiver.c,531 :: 		if ( recv_processing || data_queue_size == 0 )                                    // Если идет процесс приема пакета или очередь пуста, ничего не делаем
	BTFSC      _recv_processing+0, BitPos(_recv_processing+0)
	GOTO       L__comm_write111
	MOVF       _data_queue_size+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L__comm_write111
	GOTO       L_comm_write83
L__comm_write111:
;transceiver.c,533 :: 		INT_ENABLE;
	BSF        INTCON+0, 7
;transceiver.c,534 :: 		return;
	GOTO       L_end_comm_write
;transceiver.c,535 :: 		}
L_comm_write83:
;transceiver.c,537 :: 		while ( !COMM_RD_PIN && !COMM_WR_PIN )                                                      // Если COMM_WR_PIN = 0 мастер устройство начало процесс приема данных
L_comm_write84:
	BTFSC      RB4_bit+0, BitPos(RB4_bit+0)
	GOTO       L_comm_write85
	BTFSC      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_comm_write85
L__comm_write110:
;transceiver.c,539 :: 		if ( !comm_wr_processed )                                               // Если передача не начата
	BTFSC      _comm_wr_processed+0, BitPos(_comm_wr_processed+0)
	GOTO       L_comm_write88
;transceiver.c,541 :: 		comm_wr_processed = 1;                                              // Начинаем процесс передачи
	BSF        _comm_wr_processed+0, BitPos(_comm_wr_processed+0)
;transceiver.c,543 :: 		if ( data_queue_size )                                              // Если очередь команд не пуста
	MOVF       _data_queue_size+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_comm_write89
;transceiver.c,545 :: 		i = COMMAND_SIZE - 1;
	MOVLW      4
	MOVWF      comm_write_i_L0+0
;transceiver.c,546 :: 		n = 0;
	CLRF       comm_write_n_L0+0
;transceiver.c,547 :: 		pop_command(&comm_cmd);                                              // Извлекаем команду из очереди
	MOVLW      _comm_cmd+0
	MOVWF      FARG_pop_command_cmd+0
	CALL       _pop_command+0
;transceiver.c,548 :: 		COMM_DATA_DIR = 0;                                              // Пин данных - выход
	BCF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;transceiver.c,549 :: 		COMM_DATA_READY_PIN = 1;                                        // Устанавливаем готовность передачи данных мастер устройству
	BSF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,550 :: 		}
L_comm_write89:
;transceiver.c,551 :: 		}
L_comm_write88:
;transceiver.c,553 :: 		if ( COMM_CLK_PIN && comm_clk_prev_state == 0 )                         // Тактирование от мастер устройства (высокий уровень)
	BTFSS      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_comm_write92
	BTFSC      _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
	GOTO       L_comm_write92
L__comm_write109:
;transceiver.c,555 :: 		comm_clk_prev_state = 1;
	BSF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,557 :: 		if ( comm_cmd.b[i] & 0x80 )
	MOVF       comm_write_i_L0+0, 0
	ADDLW      _comm_cmd+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R1+0
	BTFSS      R1+0, 7
	GOTO       L_comm_write93
;transceiver.c,558 :: 		COMM_DATA_PIN = 1;                                              // Единица
	BSF        RB6_bit+0, BitPos(RB6_bit+0)
	GOTO       L_comm_write94
L_comm_write93:
;transceiver.c,560 :: 		COMM_DATA_PIN = 0;                                              // Ноль
	BCF        RB6_bit+0, BitPos(RB6_bit+0)
L_comm_write94:
;transceiver.c,562 :: 		comm_cmd.b[i] <<= 1;                                                     // Сдвиг
	MOVF       comm_write_i_L0+0, 0
	ADDLW      _comm_cmd+0
	MOVWF      R3+0
	MOVF       R3+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R3+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;transceiver.c,563 :: 		if ( ++n >= 8 )
	INCF       comm_write_n_L0+0, 1
	MOVLW      8
	SUBWF      comm_write_n_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_comm_write95
;transceiver.c,565 :: 		if ( i )
	MOVF       comm_write_i_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_comm_write96
;transceiver.c,566 :: 		i--;
	DECF       comm_write_i_L0+0, 1
L_comm_write96:
;transceiver.c,567 :: 		n = 0;
	CLRF       comm_write_n_L0+0
;transceiver.c,568 :: 		}
L_comm_write95:
;transceiver.c,569 :: 		}
L_comm_write92:
;transceiver.c,571 :: 		if ( !COMM_CLK_PIN )                                                    // Тактирование от мастер устройства (низкий уровень)
	BTFSC      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_comm_write97
;transceiver.c,572 :: 		comm_clk_prev_state = 0;
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
L_comm_write97:
;transceiver.c,573 :: 		}
	GOTO       L_comm_write84
L_comm_write85:
;transceiver.c,575 :: 		COMM_DATA_READY_PIN = 0;                                                    // Устройство не готово к приему (мастер устройство прекратило прием)
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,576 :: 		COMM_DATA_DIR = 1;                                                          // Пин данных - вход
	BSF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;transceiver.c,578 :: 		INT_ENABLE;
	BSF        INTCON+0, 7
;transceiver.c,579 :: 		}
L_end_comm_write:
	RETURN
; end of _comm_write

_main:

;transceiver.c,582 :: 		void main()
;transceiver.c,584 :: 		unsigned long led_counter = 0;
	CLRF       main_led_counter_L0+0
	CLRF       main_led_counter_L0+1
	CLRF       main_led_counter_L0+2
	CLRF       main_led_counter_L0+3
;transceiver.c,586 :: 		CMCON               = 0x07;                                                 // Компаратор выключен
	MOVLW      7
	MOVWF      CMCON+0
;transceiver.c,588 :: 		LED_DIR             = 0;
	BCF        TRISA1_bit+0, BitPos(TRISA1_bit+0)
;transceiver.c,589 :: 		LED_PIN             = 0;
	BCF        RA1_bit+0, BitPos(RA1_bit+0)
;transceiver.c,591 :: 		COMM_WR_DIR         = 1;                                                    // COMM_WR         - вход
	BSF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;transceiver.c,592 :: 		COMM_RD_DIR         = 1;                                                    // COMM_RD         - вход
	BSF        TRISB4_bit+0, BitPos(TRISB4_bit+0)
;transceiver.c,593 :: 		COMM_CLK_DIR        = 1;                                                    // COMM_CLK        - вход
	BSF        TRISB5_bit+0, BitPos(TRISB5_bit+0)
;transceiver.c,594 :: 		COMM_DATA_DIR       = 1;                                                    // COMM_DATA       - вход
	BSF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;transceiver.c,595 :: 		COMM_DATA_READY_DIR = 0;                                                    // COMM_DATA_READY - выход
	BCF        TRISB7_bit+0, BitPos(TRISB7_bit+0)
;transceiver.c,596 :: 		COMM_DATA_READY_PIN = 0;                                                    // COMM_DATA_READY = 0
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;transceiver.c,598 :: 		RO_DIR              = 1;                                                    // RO    - вход
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;transceiver.c,599 :: 		DE_RE_DIR           = 0;                                                    // RE/DE - выход
	BCF        TRISB1_bit+0, BitPos(TRISB1_bit+0)
;transceiver.c,600 :: 		DI_DIR              = 0;                                                    // DI    - выход
	BCF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;transceiver.c,602 :: 		MAX485_RECEIVE;                                                             // MAX485 в режиме приема
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;transceiver.c,604 :: 		OPTION_REG.INTEDG   = 1;                                                    // Прерывание INT0 по нарастающему фронту
	BSF        OPTION_REG+0, 6
;transceiver.c,605 :: 		OPTION_REG.T0CS     = 0;                                                    // Тактирование таймера 0 от внутреннего генератора
	BCF        OPTION_REG+0, 5
;transceiver.c,606 :: 		OPTION_REG.PSA      = 0;                                                    // Использовать пределитель для таймера 0
	BCF        OPTION_REG+0, 3
;transceiver.c,607 :: 		OPTION_REG.PS2      = 0;                                                    // Предделитель
	BCF        OPTION_REG+0, 2
;transceiver.c,608 :: 		OPTION_REG.PS1      = 1;  //1
	BSF        OPTION_REG+0, 1
;transceiver.c,609 :: 		OPTION_REG.PS0      = 0;
	BCF        OPTION_REG+0, 0
;transceiver.c,611 :: 		INTCON.PEIE         = 1;                                                    // Разрешаем периферийные прерывания
	BSF        INTCON+0, 6
;transceiver.c,612 :: 		INTCON.T0IE         = 1;                                                    // Разрешаем прерывание таймера 0
	BSF        INTCON+0, 5
;transceiver.c,613 :: 		INTCON.INTE         = 1;                                                    // Разрешаем прерывание INT0
	BSF        INTCON+0, 4
;transceiver.c,615 :: 		recv_done           = 0;                                                    // Инициализация флагов
	BCF        _recv_done+0, BitPos(_recv_done+0)
;transceiver.c,616 :: 		recv_processing     = 0;
	BCF        _recv_processing+0, BitPos(_recv_processing+0)
;transceiver.c,617 :: 		comm_clk_prev_state = 0;
	BCF        _comm_clk_prev_state+0, BitPos(_comm_clk_prev_state+0)
;transceiver.c,618 :: 		comm_rd_complete    = 0;
	BCF        _comm_rd_complete+0, BitPos(_comm_rd_complete+0)
;transceiver.c,619 :: 		comm_wr_processed   = 0;
	BCF        _comm_wr_processed+0, BitPos(_comm_wr_processed+0)
;transceiver.c,621 :: 		INT_ENABLE;                                                                 // Разрешаем все прерывания
	BSF        INTCON+0, 7
;transceiver.c,623 :: 		while ( 1 )
L_main98:
;transceiver.c,625 :: 		process_received_packet();                                              // Обработка принятых данных
	CALL       _process_received_packet+0
;transceiver.c,627 :: 		comm_read();                                                            // Прием данных мастер устройства
	CALL       _comm_read+0
;transceiver.c,629 :: 		comm_write();                                                           // Передача данных в мастер устройство
	CALL       _comm_write+0
;transceiver.c,631 :: 		if ( led_counter++ > 10000 )
	MOVF       main_led_counter_L0+0, 0
	MOVWF      R4+0
	MOVF       main_led_counter_L0+1, 0
	MOVWF      R4+1
	MOVF       main_led_counter_L0+2, 0
	MOVWF      R4+2
	MOVF       main_led_counter_L0+3, 0
	MOVWF      R4+3
	MOVF       main_led_counter_L0+0, 0
	MOVWF      R0+0
	MOVF       main_led_counter_L0+1, 0
	MOVWF      R0+1
	MOVF       main_led_counter_L0+2, 0
	MOVWF      R0+2
	MOVF       main_led_counter_L0+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      main_led_counter_L0+0
	MOVF       R0+1, 0
	MOVWF      main_led_counter_L0+1
	MOVF       R0+2, 0
	MOVWF      main_led_counter_L0+2
	MOVF       R0+3, 0
	MOVWF      main_led_counter_L0+3
	MOVF       R4+3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main125
	MOVF       R4+2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main125
	MOVF       R4+1, 0
	SUBLW      39
	BTFSS      STATUS+0, 2
	GOTO       L__main125
	MOVF       R4+0, 0
	SUBLW      16
L__main125:
	BTFSC      STATUS+0, 0
	GOTO       L_main100
;transceiver.c,633 :: 		led_counter = 0;
	CLRF       main_led_counter_L0+0
	CLRF       main_led_counter_L0+1
	CLRF       main_led_counter_L0+2
	CLRF       main_led_counter_L0+3
;transceiver.c,634 :: 		LED_PIN = ~LED_PIN;
	MOVLW
	XORWF      RA1_bit+0, 1
;transceiver.c,635 :: 		}
L_main100:
;transceiver.c,636 :: 		}
	GOTO       L_main98
;transceiver.c,637 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
