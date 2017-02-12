
_transceiver_init:

;transceiver.h,5 :: 		void transceiver_init( )
;transceiver.h,7 :: 		COMM_WR_DIR         = 0;      // COMM_WR         - выход
	BCF         TRISB7_bit+0, BitPos(TRISB7_bit+0) 
;transceiver.h,8 :: 		COMM_WR_PIN         = 1;
	BSF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,9 :: 		COMM_RD_DIR         = 0;      // COMM_RD         - выход
	BCF         TRISB6_bit+0, BitPos(TRISB6_bit+0) 
;transceiver.h,10 :: 		COMM_RD_PIN         = 1;
	BSF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,11 :: 		COMM_CLK_DIR        = 0;      // COMM_CLK        - выход
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;transceiver.h,12 :: 		COMM_CLK_PIN        = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,13 :: 		COMM_DATA_DIR       = 0;      // COMM_DATA       - выход
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;transceiver.h,14 :: 		COMM_DATA_PIN       = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;transceiver.h,15 :: 		COMM_DATA_READY_DIR = 1;      // COMM_DATA_READY - вход
	BSF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;transceiver.h,17 :: 		delay_ms(50);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       69
	MOVWF       R12, 0
	MOVLW       169
	MOVWF       R13, 0
L_transceiver_init0:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_init0
	DECFSZ      R12, 1, 1
	BRA         L_transceiver_init0
	DECFSZ      R11, 1, 1
	BRA         L_transceiver_init0
	NOP
	NOP
;transceiver.h,18 :: 		}
L_end_transceiver_init:
	RETURN      0
; end of _transceiver_init

_transceiver_send:

;transceiver.h,29 :: 		unsigned char transceiver_send( unsigned char *cmd, unsigned char *result )
;transceiver.h,34 :: 		memcpy(d, cmd, 5); // Копируем команду во временный буфер
	MOVLW       transceiver_send_d_L0+0
	MOVWF       FARG_memcpy_d1+0 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       FARG_memcpy_d1+1 
	MOVF        FARG_transceiver_send_cmd+0, 0 
	MOVWF       FARG_memcpy_s1+0 
	MOVF        FARG_transceiver_send_cmd+1, 0 
	MOVWF       FARG_memcpy_s1+1 
	MOVLW       5
	MOVWF       FARG_memcpy_n+0 
	MOVLW       0
	MOVWF       FARG_memcpy_n+1 
	CALL        _memcpy+0, 0
;transceiver.h,36 :: 		COMM_WR_PIN  = 0;  // Запись
	BCF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,37 :: 		COMM_RD_PIN  = 1;  //
	BSF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,38 :: 		COMM_CLK_PIN = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,40 :: 		while ( !COMM_DATA_READY_PIN ); // Ждем готовности записи
L_transceiver_send1:
	BTFSC       RB3_bit+0, BitPos(RB3_bit+0) 
	GOTO        L_transceiver_send2
	GOTO        L_transceiver_send1
L_transceiver_send2:
;transceiver.h,42 :: 		if ( !COMM_DATA_READY_PIN ) // Запись отклонена
	BTFSC       RB3_bit+0, BitPos(RB3_bit+0) 
	GOTO        L_transceiver_send3
;transceiver.h,44 :: 		COMM_WR_PIN = 1; // Запись запрeщена
	BSF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,45 :: 		return 0;
	CLRF        R0 
	GOTO        L_end_transceiver_send
;transceiver.h,46 :: 		}
L_transceiver_send3:
;transceiver.h,48 :: 		COMM_DATA_DIR = 0;  // Выход
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;transceiver.h,50 :: 		GIE_bit = 0;
	BCF         GIE_bit+0, BitPos(GIE_bit+0) 
;transceiver.h,52 :: 		for ( n = 4; n >= 0; --n )
	MOVLW       4
	MOVWF       transceiver_send_n_L0+0 
L_transceiver_send4:
	MOVLW       128
	XORWF       transceiver_send_n_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       0
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_transceiver_send5
;transceiver.h,54 :: 		for ( i = 0; i < 8; ++i )
	CLRF        transceiver_send_i_L0+0 
L_transceiver_send7:
	MOVLW       128
	XORWF       transceiver_send_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       8
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_transceiver_send8
;transceiver.h,56 :: 		if ( d[n] & 0x80 )
	MOVLW       transceiver_send_d_L0+0
	MOVWF       FSR0 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       FSR0H 
	MOVF        transceiver_send_n_L0+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       transceiver_send_n_L0+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	BTFSS       R1, 7 
	GOTO        L_transceiver_send10
;transceiver.h,57 :: 		COMM_DATA_PIN = 1;
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_transceiver_send11
L_transceiver_send10:
;transceiver.h,59 :: 		COMM_DATA_PIN = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
L_transceiver_send11:
;transceiver.h,61 :: 		COMM_CLK_PIN = 1;
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,62 :: 		delay_us(PULSE_TIME);
	MOVLW       16
	MOVWF       R13, 0
L_transceiver_send12:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_send12
	NOP
;transceiver.h,63 :: 		COMM_CLK_PIN = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,64 :: 		delay_us(PULSE_TIME);   //?????
	MOVLW       16
	MOVWF       R13, 0
L_transceiver_send13:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_send13
	NOP
;transceiver.h,66 :: 		d[n] <<= 1;
	MOVLW       transceiver_send_d_L0+0
	MOVWF       R3 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       R4 
	MOVF        transceiver_send_n_L0+0, 0 
	ADDWF       R3, 1 
	MOVLW       0
	BTFSC       transceiver_send_n_L0+0, 7 
	MOVLW       255
	ADDWFC      R4, 1 
	MOVFF       R3, FSR0
	MOVFF       R4, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	MOVFF       R3, FSR1
	MOVFF       R4, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;transceiver.h,54 :: 		for ( i = 0; i < 8; ++i )
	INCF        transceiver_send_i_L0+0, 1 
;transceiver.h,67 :: 		}
	GOTO        L_transceiver_send7
L_transceiver_send8:
;transceiver.h,52 :: 		for ( n = 4; n >= 0; --n )
	DECF        transceiver_send_n_L0+0, 1 
;transceiver.h,68 :: 		}
	GOTO        L_transceiver_send4
L_transceiver_send5:
;transceiver.h,70 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;transceiver.h,72 :: 		memset(d, 0, 5); // после записи очищаем буфер
	MOVLW       transceiver_send_d_L0+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       5
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;transceiver.h,76 :: 		COMM_DATA_DIR = 1;  // Вход
	BSF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;transceiver.h,77 :: 		COMM_WR_PIN   = 1;  // Запись запрещена
	BSF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,78 :: 		COMM_RD_PIN   = 0;
	BCF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,80 :: 		while ( COMM_DATA_READY_PIN ); // Ждем готовности чтения
L_transceiver_send14:
	BTFSS       RB3_bit+0, BitPos(RB3_bit+0) 
	GOTO        L_transceiver_send15
	GOTO        L_transceiver_send14
L_transceiver_send15:
;transceiver.h,82 :: 		GIE_bit = 0;
	BCF         GIE_bit+0, BitPos(GIE_bit+0) 
;transceiver.h,84 :: 		for ( n = 4; n >= 0; --n )
	MOVLW       4
	MOVWF       transceiver_send_n_L0+0 
L_transceiver_send16:
	MOVLW       128
	XORWF       transceiver_send_n_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       0
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_transceiver_send17
;transceiver.h,86 :: 		for ( i = 0; i < 8; ++i )
	CLRF        transceiver_send_i_L0+0 
L_transceiver_send19:
	MOVLW       128
	XORWF       transceiver_send_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       8
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_transceiver_send20
;transceiver.h,88 :: 		COMM_CLK_PIN = 1;
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,89 :: 		delay_us(PULSE_TIME);
	MOVLW       16
	MOVWF       R13, 0
L_transceiver_send22:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_send22
	NOP
;transceiver.h,91 :: 		d[n] <<= 1;             // Сдвиг
	MOVLW       transceiver_send_d_L0+0
	MOVWF       R3 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       R4 
	MOVF        transceiver_send_n_L0+0, 0 
	ADDWF       R3, 1 
	MOVLW       0
	BTFSC       transceiver_send_n_L0+0, 7 
	MOVLW       255
	ADDWFC      R4, 1 
	MOVFF       R3, FSR0
	MOVFF       R4, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	MOVFF       R3, FSR1
	MOVFF       R4, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;transceiver.h,92 :: 		if ( COMM_DATA_PIN )    // Единица
	BTFSS       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_transceiver_send23
;transceiver.h,93 :: 		d[n] |= 1;
	MOVLW       transceiver_send_d_L0+0
	MOVWF       R1 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       R2 
	MOVF        transceiver_send_n_L0+0, 0 
	ADDWF       R1, 1 
	MOVLW       0
	BTFSC       transceiver_send_n_L0+0, 7 
	MOVLW       255
	ADDWFC      R2, 1 
	MOVFF       R1, FSR0
	MOVFF       R2, FSR0H
	MOVLW       1
	IORWF       POSTINC0+0, 0 
	MOVWF       R0 
	MOVFF       R1, FSR1
	MOVFF       R2, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
L_transceiver_send23:
;transceiver.h,95 :: 		COMM_CLK_PIN = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,96 :: 		delay_us(PULSE_TIME);
	MOVLW       16
	MOVWF       R13, 0
L_transceiver_send24:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_send24
	NOP
;transceiver.h,86 :: 		for ( i = 0; i < 8; ++i )
	INCF        transceiver_send_i_L0+0, 1 
;transceiver.h,97 :: 		}
	GOTO        L_transceiver_send19
L_transceiver_send20:
;transceiver.h,84 :: 		for ( n = 4; n >= 0; --n )
	DECF        transceiver_send_n_L0+0, 1 
;transceiver.h,98 :: 		}
	GOTO        L_transceiver_send16
L_transceiver_send17:
;transceiver.h,100 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;transceiver.h,102 :: 		COMM_WR_PIN = 1; // Запись запрещена
	BSF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,103 :: 		COMM_RD_PIN = 1; // Чтение запрещено
	BSF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,105 :: 		memcpy(result, d, 5);
	MOVF        FARG_transceiver_send_result+0, 0 
	MOVWF       FARG_memcpy_d1+0 
	MOVF        FARG_transceiver_send_result+1, 0 
	MOVWF       FARG_memcpy_d1+1 
	MOVLW       transceiver_send_d_L0+0
	MOVWF       FARG_memcpy_s1+0 
	MOVLW       hi_addr(transceiver_send_d_L0+0)
	MOVWF       FARG_memcpy_s1+1 
	MOVLW       5
	MOVWF       FARG_memcpy_n+0 
	MOVLW       0
	MOVWF       FARG_memcpy_n+1 
	CALL        _memcpy+0, 0
;transceiver.h,107 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
;transceiver.h,108 :: 		}
L_end_transceiver_send:
	RETURN      0
; end of _transceiver_send

_transceiver_recv:

;transceiver.h,116 :: 		unsigned char transceiver_recv( unsigned char *result )
;transceiver.h,121 :: 		memset(d, 0, 5);
	MOVLW       transceiver_recv_d_L0+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(transceiver_recv_d_L0+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       5
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;transceiver.h,123 :: 		COMM_DATA_DIR = 1;
	BSF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;transceiver.h,125 :: 		COMM_WR_PIN  = 0;  // Запись
	BCF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,126 :: 		COMM_RD_PIN  = 0;  //
	BCF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,127 :: 		COMM_CLK_PIN = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,129 :: 		delay_ms(1); // Ждем готовности записи
	MOVLW       7
	MOVWF       R12, 0
	MOVLW       125
	MOVWF       R13, 0
L_transceiver_recv25:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_recv25
	DECFSZ      R12, 1, 1
	BRA         L_transceiver_recv25
;transceiver.h,131 :: 		if ( !COMM_DATA_READY_PIN ) // Запись отклонена
	BTFSC       RB3_bit+0, BitPos(RB3_bit+0) 
	GOTO        L_transceiver_recv26
;transceiver.h,133 :: 		COMM_WR_PIN = 1; // Запись запрещена
	BSF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,134 :: 		COMM_RD_PIN = 1; // Запись запрещена
	BSF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,135 :: 		return 0;
	CLRF        R0 
	GOTO        L_end_transceiver_recv
;transceiver.h,136 :: 		}
L_transceiver_recv26:
;transceiver.h,138 :: 		GIE_bit = 0;
	BCF         GIE_bit+0, BitPos(GIE_bit+0) 
;transceiver.h,140 :: 		for ( n = 4; n >= 0; --n )
	MOVLW       4
	MOVWF       transceiver_recv_n_L0+0 
L_transceiver_recv27:
	MOVLW       128
	XORWF       transceiver_recv_n_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       0
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_transceiver_recv28
;transceiver.h,142 :: 		for ( i = 0; i < 8; ++i )
	CLRF        transceiver_recv_i_L0+0 
L_transceiver_recv30:
	MOVLW       128
	XORWF       transceiver_recv_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       8
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_transceiver_recv31
;transceiver.h,144 :: 		COMM_CLK_PIN = 1;
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,145 :: 		delay_us(PULSE_TIME);
	MOVLW       16
	MOVWF       R13, 0
L_transceiver_recv33:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_recv33
	NOP
;transceiver.h,147 :: 		d[n] <<= 1;           // Сдвиг
	MOVLW       transceiver_recv_d_L0+0
	MOVWF       R3 
	MOVLW       hi_addr(transceiver_recv_d_L0+0)
	MOVWF       R4 
	MOVF        transceiver_recv_n_L0+0, 0 
	ADDWF       R3, 1 
	MOVLW       0
	BTFSC       transceiver_recv_n_L0+0, 7 
	MOVLW       255
	ADDWFC      R4, 1 
	MOVFF       R3, FSR0
	MOVFF       R4, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	MOVFF       R3, FSR1
	MOVFF       R4, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;transceiver.h,148 :: 		if ( COMM_DATA_PIN )  // Единица
	BTFSS       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_transceiver_recv34
;transceiver.h,149 :: 		d[n] |= 1;
	MOVLW       transceiver_recv_d_L0+0
	MOVWF       R1 
	MOVLW       hi_addr(transceiver_recv_d_L0+0)
	MOVWF       R2 
	MOVF        transceiver_recv_n_L0+0, 0 
	ADDWF       R1, 1 
	MOVLW       0
	BTFSC       transceiver_recv_n_L0+0, 7 
	MOVLW       255
	ADDWFC      R2, 1 
	MOVFF       R1, FSR0
	MOVFF       R2, FSR0H
	MOVLW       1
	IORWF       POSTINC0+0, 0 
	MOVWF       R0 
	MOVFF       R1, FSR1
	MOVFF       R2, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
L_transceiver_recv34:
;transceiver.h,151 :: 		COMM_CLK_PIN = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;transceiver.h,152 :: 		delay_us(PULSE_TIME);
	MOVLW       16
	MOVWF       R13, 0
L_transceiver_recv35:
	DECFSZ      R13, 1, 1
	BRA         L_transceiver_recv35
	NOP
;transceiver.h,142 :: 		for ( i = 0; i < 8; ++i )
	INCF        transceiver_recv_i_L0+0, 1 
;transceiver.h,153 :: 		}
	GOTO        L_transceiver_recv30
L_transceiver_recv31:
;transceiver.h,140 :: 		for ( n = 4; n >= 0; --n )
	DECF        transceiver_recv_n_L0+0, 1 
;transceiver.h,154 :: 		}
	GOTO        L_transceiver_recv27
L_transceiver_recv28:
;transceiver.h,156 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;transceiver.h,158 :: 		COMM_WR_PIN = 1; // Запись запрещена
	BSF         RB7_bit+0, BitPos(RB7_bit+0) 
;transceiver.h,159 :: 		COMM_RD_PIN = 1; // Чтение запрещено
	BSF         RB6_bit+0, BitPos(RB6_bit+0) 
;transceiver.h,161 :: 		memcpy(result, d, 5);
	MOVF        FARG_transceiver_recv_result+0, 0 
	MOVWF       FARG_memcpy_d1+0 
	MOVF        FARG_transceiver_recv_result+1, 0 
	MOVWF       FARG_memcpy_d1+1 
	MOVLW       transceiver_recv_d_L0+0
	MOVWF       FARG_memcpy_s1+0 
	MOVLW       hi_addr(transceiver_recv_d_L0+0)
	MOVWF       FARG_memcpy_s1+1 
	MOVLW       5
	MOVWF       FARG_memcpy_n+0 
	MOVLW       0
	MOVWF       FARG_memcpy_n+1 
	CALL        _memcpy+0, 0
;transceiver.h,163 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
;transceiver.h,164 :: 		}
L_end_transceiver_recv:
	RETURN      0
; end of _transceiver_recv

_net_init:

;net.h,3 :: 		void net_init( char send_attempts )
;net.h,5 :: 		net_send_attempts = send_attempts;
	MOVF        FARG_net_init_send_attempts+0, 0 
	MOVWF       exec_unit_net_send_attempts+0 
	MOVLW       0
	MOVWF       exec_unit_net_send_attempts+1 
;net.h,6 :: 		}
L_end_net_init:
	RETURN      0
; end of _net_init

_net_set_params:

;net.h,13 :: 		unsigned char net_set_params( unsigned char addr, unsigned char ack_wait_time )
;net.h,17 :: 		memset(res, 0, 5);
	MOVLW       net_set_params_res_L0+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(net_set_params_res_L0+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       5
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;net.h,19 :: 		d[0] = 255;
	MOVLW       255
	MOVWF       net_set_params_d_L0+0 
;net.h,20 :: 		d[1] = addr;
	MOVF        FARG_net_set_params_addr+0, 0 
	MOVWF       net_set_params_d_L0+1 
;net.h,21 :: 		d[2] = ack_wait_time;
	MOVF        FARG_net_set_params_ack_wait_time+0, 0 
	MOVWF       net_set_params_d_L0+2 
;net.h,22 :: 		d[3] = 0;
	CLRF        net_set_params_d_L0+3 
;net.h,23 :: 		d[4] = 0;
	CLRF        net_set_params_d_L0+4 
;net.h,25 :: 		if ( !transceiver_send(d, res) )
	MOVLW       net_set_params_d_L0+0
	MOVWF       FARG_transceiver_send_cmd+0 
	MOVLW       hi_addr(net_set_params_d_L0+0)
	MOVWF       FARG_transceiver_send_cmd+1 
	MOVLW       net_set_params_res_L0+0
	MOVWF       FARG_transceiver_send_result+0 
	MOVLW       hi_addr(net_set_params_res_L0+0)
	MOVWF       FARG_transceiver_send_result+1 
	CALL        _transceiver_send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_net_set_params36
;net.h,26 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_net_set_params
L_net_set_params36:
;net.h,28 :: 		return memcmp(d, res, 5);
	MOVLW       net_set_params_d_L0+0
	MOVWF       FARG_memcmp_s1+0 
	MOVLW       hi_addr(net_set_params_d_L0+0)
	MOVWF       FARG_memcmp_s1+1 
	MOVLW       net_set_params_res_L0+0
	MOVWF       FARG_memcmp_s2+0 
	MOVLW       hi_addr(net_set_params_res_L0+0)
	MOVWF       FARG_memcmp_s2+1 
	MOVLW       5
	MOVWF       FARG_memcmp_n+0 
	MOVLW       0
	MOVWF       FARG_memcmp_n+1 
	CALL        _memcmp+0, 0
;net.h,29 :: 		}
L_end_net_set_params:
	RETURN      0
; end of _net_set_params

__net_send:

;net.h,36 :: 		unsigned char _net_send( unsigned char addr, unsigned char cmd, unsigned char *dat )
;net.h,41 :: 		memset(res, 0, 5);
	MOVLW       _net_send_res_L0+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_net_send_res_L0+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       5
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;net.h,43 :: 		d[0] = addr;  // адрес
	MOVF        FARG__net_send_addr+0, 0 
	MOVWF       _net_send_d_L0+0 
;net.h,44 :: 		d[1] = cmd;   // команда
	MOVF        FARG__net_send_cmd+0, 0 
	MOVWF       _net_send_d_L0+1 
;net.h,45 :: 		d[2] = 0;     // Данные (байт 1)
	CLRF        _net_send_d_L0+2 
;net.h,46 :: 		d[3] = 0;     // Данные (байт 2)
	CLRF        _net_send_d_L0+3 
;net.h,47 :: 		d[4] = 0;     // Данные (байт 3)
	CLRF        _net_send_d_L0+4 
;net.h,49 :: 		if ( dat )    // Если с командой передаются данные
	MOVF        FARG__net_send_dat+0, 0 
	IORWF       FARG__net_send_dat+1, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L__net_send37
;net.h,50 :: 		memcpy(&d[2], dat, 3);
	MOVLW       _net_send_d_L0+2
	MOVWF       FARG_memcpy_d1+0 
	MOVLW       hi_addr(_net_send_d_L0+2)
	MOVWF       FARG_memcpy_d1+1 
	MOVF        FARG__net_send_dat+0, 0 
	MOVWF       FARG_memcpy_s1+0 
	MOVF        FARG__net_send_dat+1, 0 
	MOVWF       FARG_memcpy_s1+1 
	MOVLW       3
	MOVWF       FARG_memcpy_n+0 
	MOVLW       0
	MOVWF       FARG_memcpy_n+1 
	CALL        _memcpy+0, 0
L__net_send37:
;net.h,52 :: 		if ( !transceiver_send(d, res) )
	MOVLW       _net_send_d_L0+0
	MOVWF       FARG_transceiver_send_cmd+0 
	MOVLW       hi_addr(_net_send_d_L0+0)
	MOVWF       FARG_transceiver_send_cmd+1 
	MOVLW       _net_send_res_L0+0
	MOVWF       FARG_transceiver_send_result+0 
	MOVLW       hi_addr(_net_send_res_L0+0)
	MOVWF       FARG_transceiver_send_result+1 
	CALL        _transceiver_send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L__net_send38
;net.h,53 :: 		return 1;  // Линия занята
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end__net_send
L__net_send38:
;net.h,55 :: 		return !memcmp(d, res, 5) ? 0 : 2;
	MOVLW       _net_send_d_L0+0
	MOVWF       FARG_memcmp_s1+0 
	MOVLW       hi_addr(_net_send_d_L0+0)
	MOVWF       FARG_memcmp_s1+1 
	MOVLW       _net_send_res_L0+0
	MOVWF       FARG_memcmp_s2+0 
	MOVLW       hi_addr(_net_send_res_L0+0)
	MOVWF       FARG_memcmp_s2+1 
	MOVLW       5
	MOVWF       FARG_memcmp_n+0 
	MOVLW       0
	MOVWF       FARG_memcmp_n+1 
	CALL        _memcmp+0, 0
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__net_send39
	CLRF        ?FLOC____net_sendT75+0 
	GOTO        L__net_send40
L__net_send39:
	MOVLW       2
	MOVWF       ?FLOC____net_sendT75+0 
L__net_send40:
	MOVF        ?FLOC____net_sendT75+0, 0 
	MOVWF       R0 
;net.h,56 :: 		}
L_end__net_send:
	RETURN      0
; end of __net_send

_net_send:

;net.h,64 :: 		unsigned char net_send( unsigned char addr, unsigned char cmd, unsigned char *dat, unsigned char attempts )
;net.h,68 :: 		if ( attempts == 0 )
	MOVF        FARG_net_send_attempts+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_net_send41
;net.h,69 :: 		attempts = net_send_attempts;
	MOVF        exec_unit_net_send_attempts+0, 0 
	MOVWF       FARG_net_send_attempts+0 
L_net_send41:
;net.h,71 :: 		while ( attempts-- )
L_net_send42:
	MOVF        FARG_net_send_attempts+0, 0 
	MOVWF       R0 
	DECF        FARG_net_send_attempts+0, 1 
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_net_send43
;net.h,73 :: 		res = _net_send(addr, cmd, dat);
	MOVF        FARG_net_send_addr+0, 0 
	MOVWF       FARG__net_send_addr+0 
	MOVF        FARG_net_send_cmd+0, 0 
	MOVWF       FARG__net_send_cmd+0 
	MOVF        FARG_net_send_dat+0, 0 
	MOVWF       FARG__net_send_dat+0 
	MOVF        FARG_net_send_dat+1, 0 
	MOVWF       FARG__net_send_dat+1 
	CALL        __net_send+0, 0
	MOVF        R0, 0 
	MOVWF       net_send_res_L0+0 
;net.h,74 :: 		if ( res == 0 )
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_net_send44
;net.h,75 :: 		return 0;
	CLRF        R0 
	GOTO        L_end_net_send
L_net_send44:
;net.h,77 :: 		if ( attempts )
	MOVF        FARG_net_send_attempts+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_net_send45
;net.h,78 :: 		delay_ms(100); // подождем
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_net_send46:
	DECFSZ      R13, 1, 1
	BRA         L_net_send46
	DECFSZ      R12, 1, 1
	BRA         L_net_send46
	DECFSZ      R11, 1, 1
	BRA         L_net_send46
	NOP
	NOP
L_net_send45:
;net.h,79 :: 		}
	GOTO        L_net_send42
L_net_send43:
;net.h,81 :: 		return res;
	MOVF        net_send_res_L0+0, 0 
	MOVWF       R0 
;net.h,82 :: 		}
L_end_net_send:
	RETURN      0
; end of _net_send

_hc165_init:

;hc165.h,7 :: 		void hc165_init( )
;hc165.h,9 :: 		HC165_LOAD_DIR  = 0;
	BCF         TRISD7_bit+0, BitPos(TRISD7_bit+0) 
;hc165.h,10 :: 		HC165_CLOCK_DIR = 0;
	BCF         TRISD6_bit+0, BitPos(TRISD6_bit+0) 
;hc165.h,11 :: 		HC165_DATA_DIR  = 1;
	BSF         TRISD5_bit+0, BitPos(TRISD5_bit+0) 
;hc165.h,13 :: 		HC165_LOAD_PIN  = 1;
	BSF         RD7_bit+0, BitPos(RD7_bit+0) 
;hc165.h,14 :: 		HC165_CLOCK_PIN = 0;
	BCF         RD6_bit+0, BitPos(RD6_bit+0) 
;hc165.h,15 :: 		}
L_end_hc165_init:
	RETURN      0
; end of _hc165_init

_hc165_read:

;hc165.h,19 :: 		ulong hc165_read( uchar bits_count )
;hc165.h,22 :: 		ulong val = 0;
	CLRF        hc165_read_val_L0+0 
	CLRF        hc165_read_val_L0+1 
	CLRF        hc165_read_val_L0+2 
	CLRF        hc165_read_val_L0+3 
;hc165.h,24 :: 		HC165_LOAD_PIN = 0;
	BCF         RD7_bit+0, BitPos(RD7_bit+0) 
;hc165.h,25 :: 		delay_us(1);
	NOP
	NOP
	NOP
	NOP
	NOP
;hc165.h,26 :: 		HC165_LOAD_PIN = 1;
	BSF         RD7_bit+0, BitPos(RD7_bit+0) 
;hc165.h,28 :: 		for ( i = 0; i < bits_count; i++ )
	CLRF        R4 
L_hc165_read47:
	MOVF        FARG_hc165_read_bits_count+0, 0 
	SUBWF       R4, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_hc165_read48
;hc165.h,30 :: 		val <<= 1;
	RLCF        hc165_read_val_L0+0, 1 
	BCF         hc165_read_val_L0+0, 0 
	RLCF        hc165_read_val_L0+1, 1 
	RLCF        hc165_read_val_L0+2, 1 
	RLCF        hc165_read_val_L0+3, 1 
;hc165.h,31 :: 		if ( HC165_DATA_PIN == 0 ) // Инвертировано
	BTFSC       RD5_bit+0, BitPos(RD5_bit+0) 
	GOTO        L_hc165_read50
;hc165.h,32 :: 		val |= 1;
	BSF         hc165_read_val_L0+0, 0 
L_hc165_read50:
;hc165.h,34 :: 		HC165_CLOCK_PIN = 0;
	BCF         RD6_bit+0, BitPos(RD6_bit+0) 
;hc165.h,35 :: 		delay_us(1);
	NOP
	NOP
	NOP
	NOP
	NOP
;hc165.h,36 :: 		HC165_CLOCK_PIN = 1;
	BSF         RD6_bit+0, BitPos(RD6_bit+0) 
;hc165.h,37 :: 		delay_us(1);
	NOP
	NOP
	NOP
	NOP
	NOP
;hc165.h,28 :: 		for ( i = 0; i < bits_count; i++ )
	INCF        R4, 1 
;hc165.h,38 :: 		}
	GOTO        L_hc165_read47
L_hc165_read48:
;hc165.h,40 :: 		return val;
	MOVF        hc165_read_val_L0+0, 0 
	MOVWF       R0 
	MOVF        hc165_read_val_L0+1, 0 
	MOVWF       R1 
	MOVF        hc165_read_val_L0+2, 0 
	MOVWF       R2 
	MOVF        hc165_read_val_L0+3, 0 
	MOVWF       R3 
;hc165.h,41 :: 		}
L_end_hc165_read:
	RETURN      0
; end of _hc165_read

_usb_on:

;usb.h,4 :: 		void usb_on( )
;usb.h,6 :: 		HID_Enable(&readbuff, &writebuff);
	MOVLW       _readbuff+0
	MOVWF       FARG_HID_Enable_readbuff+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       FARG_HID_Enable_readbuff+1 
	MOVLW       _writebuff+0
	MOVWF       FARG_HID_Enable_writebuff+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_HID_Enable_writebuff+1 
	CALL        _HID_Enable+0, 0
;usb.h,7 :: 		}
L_end_usb_on:
	RETURN      0
; end of _usb_on

_usb_read:

;usb.h,9 :: 		char usb_read( )
;usb.h,11 :: 		return HID_Read();
	CALL        _HID_Read+0, 0
;usb.h,12 :: 		}
L_end_usb_read:
	RETURN      0
; end of _usb_read

_usb_write:

;usb.h,14 :: 		char usb_write( )
;usb.h,16 :: 		return HID_Write(&writebuff, USB_REPORT_SIZE);
	MOVLW       _writebuff+0
	MOVWF       FARG_HID_Write_writebuff+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_HID_Write_writebuff+1 
	MOVLW       64
	MOVWF       FARG_HID_Write_len+0 
	CALL        _HID_Write+0, 0
;usb.h,17 :: 		}
L_end_usb_write:
	RETURN      0
; end of _usb_write

_usb_off:

;usb.h,19 :: 		void usb_off( )
;usb.h,21 :: 		HID_Disable();
	CALL        _HID_Disable+0, 0
;usb.h,22 :: 		}
L_end_usb_off:
	RETURN      0
; end of _usb_off

_ee_read:

;internal_eeprom.h,2 :: 		unsigned char ee_read( unsigned char addr )
;internal_eeprom.h,4 :: 		while ( WR_bit );                                                           // Если идет запись, ждем
L_ee_read51:
	BTFSS       WR_bit+0, BitPos(WR_bit+0) 
	GOTO        L_ee_read52
	GOTO        L_ee_read51
L_ee_read52:
;internal_eeprom.h,5 :: 		EEADR     = addr;                                                           // Устанавливаем адрес
	MOVF        FARG_ee_read_addr+0, 0 
	MOVWF       EEADR+0 
;internal_eeprom.h,6 :: 		EEPGD_bit = 0;                                                              // Обращение к EEPROM
	BCF         EEPGD_bit+0, BitPos(EEPGD_bit+0) 
;internal_eeprom.h,7 :: 		CFGS_bit  = 0;                                                              // Обращение к EEPROM
	BCF         CFGS_bit+0, BitPos(CFGS_bit+0) 
;internal_eeprom.h,8 :: 		RD_bit    = 1;                                                              // Запуск чтения
	BSF         RD_bit+0, BitPos(RD_bit+0) 
;internal_eeprom.h,9 :: 		return EEDATA;                                                              // Возвращаем значение
	MOVF        EEDATA+0, 0 
	MOVWF       R0 
;internal_eeprom.h,10 :: 		}
L_end_ee_read:
	RETURN      0
; end of _ee_read

_ee_write:

;internal_eeprom.h,13 :: 		unsigned char ee_write( unsigned char addr, unsigned char val )
;internal_eeprom.h,15 :: 		char int_state = GIE_Bit;                                                   // Запоминаем состояние прерываний
	MOVLW       0
	BTFSC       GIE_bit+0, BitPos(GIE_bit+0) 
	MOVLW       1
	MOVWF       R2 
;internal_eeprom.h,16 :: 		while ( WR_bit );                                                           // Если идет запись, ждем
L_ee_write53:
	BTFSS       WR_bit+0, BitPos(WR_bit+0) 
	GOTO        L_ee_write54
	GOTO        L_ee_write53
L_ee_write54:
;internal_eeprom.h,17 :: 		EEADR     = addr;                                                           // Устанавливаем адрес
	MOVF        FARG_ee_write_addr+0, 0 
	MOVWF       EEADR+0 
;internal_eeprom.h,18 :: 		EEDATA    = val;                                                            // Устанавливаем записываемые данные
	MOVF        FARG_ee_write_val+0, 0 
	MOVWF       EEDATA+0 
;internal_eeprom.h,19 :: 		EEPGD_bit = 0;                                                              // Обращение к EEPROM
	BCF         EEPGD_bit+0, BitPos(EEPGD_bit+0) 
;internal_eeprom.h,20 :: 		CFGS_bit  = 0;                                                              // Обращение к EEPROM
	BCF         CFGS_bit+0, BitPos(CFGS_bit+0) 
;internal_eeprom.h,21 :: 		WREN_bit  = 1;                                                              // Разрешаем запись
	BSF         WREN_bit+0, BitPos(WREN_bit+0) 
;internal_eeprom.h,22 :: 		GIE_Bit   = 0;                                                              // Запрещаем прерывания
	BCF         GIE_bit+0, BitPos(GIE_bit+0) 
;internal_eeprom.h,23 :: 		EECON2    = 0x55;                                                           // Устанавливаем 0x55
	MOVLW       85
	MOVWF       EECON2+0 
;internal_eeprom.h,24 :: 		EECON2    = 0xAA;                                                           // Устанавливаем 0xAA
	MOVLW       170
	MOVWF       EECON2+0 
;internal_eeprom.h,25 :: 		WR_bit    = 1;                                                              // Запуск записи
	BSF         WR_bit+0, BitPos(WR_bit+0) 
;internal_eeprom.h,26 :: 		GIE_Bit   = int_state;                                                      // Восстанавливаем состояние прерывания
	BTFSC       R2, 0 
	GOTO        L__ee_write295
	BCF         GIE_bit+0, BitPos(GIE_bit+0) 
	GOTO        L__ee_write296
L__ee_write295:
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
L__ee_write296:
;internal_eeprom.h,27 :: 		WREN_bit  = 0;                                                              // Запрещаем запись
	BCF         WREN_bit+0, BitPos(WREN_bit+0) 
;internal_eeprom.h,28 :: 		while ( WR_bit );                                                           // Ожидаем окончания записи
L_ee_write55:
	BTFSS       WR_bit+0, BitPos(WR_bit+0) 
	GOTO        L_ee_write56
	GOTO        L_ee_write55
L_ee_write56:
;internal_eeprom.h,29 :: 		return (WRERR_bit == 0);                                                    // Возвращаем результат выволнения
	CLRF        R1 
	BTFSC       WRERR_bit+0, BitPos(WRERR_bit+0) 
	INCF        R1, 1 
	MOVF        R1, 0 
	XORLW       0
	MOVLW       1
	BTFSS       STATUS+0, 2 
	MOVLW       0
	MOVWF       R0 
;internal_eeprom.h,30 :: 		}
L_end_ee_write:
	RETURN      0
; end of _ee_write

_crc8:

;crc.h,13 :: 		unsigned char crc8( uchar *block, uchar len )
;crc.h,15 :: 		uchar crc = 0xFF;
	MOVLW       255
	MOVWF       crc8_crc_L0+0 
;crc.h,18 :: 		while ( len-- )
L_crc857:
	MOVF        FARG_crc8_len+0, 0 
	MOVWF       R0 
	DECF        FARG_crc8_len+0, 1 
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_crc858
;crc.h,20 :: 		crc ^= *block++;
	MOVFF       FARG_crc8_block+0, FSR2
	MOVFF       FARG_crc8_block+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       crc8_crc_L0+0, 1 
	INFSNZ      FARG_crc8_block+0, 1 
	INCF        FARG_crc8_block+1, 1 
;crc.h,21 :: 		for ( i = 0; i < 8; i++ )
	CLRF        R3 
L_crc859:
	MOVLW       8
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_crc860
;crc.h,22 :: 		crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
	BTFSS       crc8_crc_L0+0, 7 
	GOTO        L_crc862
	MOVF        crc8_crc_L0+0, 0 
	MOVWF       R1 
	MOVLW       0
	MOVWF       R2 
	RLCF        R1, 1 
	BCF         R1, 0 
	RLCF        R2, 1 
	MOVLW       49
	XORWF       R1, 1 
	MOVLW       0
	MOVWF       R2 
	GOTO        L_crc863
L_crc862:
	MOVF        crc8_crc_L0+0, 0 
	MOVWF       R1 
	MOVLW       0
	MOVWF       R2 
	RLCF        R1, 1 
	BCF         R1, 0 
	RLCF        R2, 1 
L_crc863:
	MOVF        R1, 0 
	MOVWF       crc8_crc_L0+0 
;crc.h,21 :: 		for ( i = 0; i < 8; i++ )
	INCF        R3, 1 
;crc.h,22 :: 		crc = crc & 0x80 ? (crc << 1) ^ 0x31 : crc << 1;
	GOTO        L_crc859
L_crc860:
;crc.h,23 :: 		}
	GOTO        L_crc857
L_crc858:
;crc.h,25 :: 		return crc;
	MOVF        crc8_crc_L0+0, 0 
	MOVWF       R0 
;crc.h,26 :: 		}
L_end_crc8:
	RETURN      0
; end of _crc8

_crc16:

;crc.h,39 :: 		unsigned short crc16( uchar *block, ushort len )
;crc.h,41 :: 		ushort crc = 0xFFFF;
	MOVLW       255
	MOVWF       crc16_crc_L0+0 
	MOVLW       255
	MOVWF       crc16_crc_L0+1 
;crc.h,44 :: 		while ( len-- )
L_crc1664:
	MOVF        FARG_crc16_len+0, 0 
	MOVWF       R0 
	MOVF        FARG_crc16_len+1, 0 
	MOVWF       R1 
	MOVLW       1
	SUBWF       FARG_crc16_len+0, 1 
	MOVLW       0
	SUBWFB      FARG_crc16_len+1, 1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_crc1665
;crc.h,46 :: 		crc ^= *block++ << 8;
	MOVFF       FARG_crc16_block+0, FSR0
	MOVFF       FARG_crc16_block+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R3 
	MOVF        R3, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        R0, 0 
	XORWF       crc16_crc_L0+0, 1 
	MOVF        R1, 0 
	XORWF       crc16_crc_L0+1, 1 
	INFSNZ      FARG_crc16_block+0, 1 
	INCF        FARG_crc16_block+1, 1 
;crc.h,47 :: 		for ( i = 0; i < 8; i++ )
	CLRF        R6 
L_crc1666:
	MOVLW       8
	SUBWF       R6, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_crc1667
;crc.h,48 :: 		crc = crc & 0x8000 ? (crc << 1) ^ 0x1021 : crc << 1;
	BTFSS       crc16_crc_L0+1, 7 
	GOTO        L_crc1669
	MOVF        crc16_crc_L0+0, 0 
	MOVWF       R4 
	MOVF        crc16_crc_L0+1, 0 
	MOVWF       R5 
	RLCF        R4, 1 
	BCF         R4, 0 
	RLCF        R5, 1 
	MOVLW       33
	XORWF       R4, 1 
	MOVLW       16
	XORWF       R5, 1 
	GOTO        L_crc1670
L_crc1669:
	MOVF        crc16_crc_L0+0, 0 
	MOVWF       R4 
	MOVF        crc16_crc_L0+1, 0 
	MOVWF       R5 
	RLCF        R4, 1 
	BCF         R4, 0 
	RLCF        R5, 1 
L_crc1670:
	MOVF        R4, 0 
	MOVWF       crc16_crc_L0+0 
	MOVF        R5, 0 
	MOVWF       crc16_crc_L0+1 
;crc.h,47 :: 		for ( i = 0; i < 8; i++ )
	INCF        R6, 1 
;crc.h,48 :: 		crc = crc & 0x8000 ? (crc << 1) ^ 0x1021 : crc << 1;
	GOTO        L_crc1666
L_crc1667:
;crc.h,49 :: 		}
	GOTO        L_crc1664
L_crc1665:
;crc.h,50 :: 		return crc;
	MOVF        crc16_crc_L0+0, 0 
	MOVWF       R0 
;crc.h,51 :: 		}
L_end_crc16:
	RETURN      0
; end of _crc16

_motor_init:

;exec_unit.c,59 :: 		void motor_init( )
;exec_unit.c,61 :: 		M1_DIR = 0;
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;exec_unit.c,62 :: 		M2_DIR = 0;
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;exec_unit.c,63 :: 		M3_DIR = 0;
	BCF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;exec_unit.c,64 :: 		M4_DIR = 0;
	BCF         TRISC0_bit+0, BitPos(TRISC0_bit+0) 
;exec_unit.c,65 :: 		M5_DIR = 0;
	BCF         TRISE2_bit+0, BitPos(TRISE2_bit+0) 
;exec_unit.c,66 :: 		M6_DIR = 0;
	BCF         TRISE1_bit+0, BitPos(TRISE1_bit+0) 
;exec_unit.c,67 :: 		M7_DIR = 0;
	BCF         TRISE0_bit+0, BitPos(TRISE0_bit+0) 
;exec_unit.c,68 :: 		M8_DIR = 0;
	BCF         TRISA5_bit+0, BitPos(TRISA5_bit+0) 
;exec_unit.c,70 :: 		M1_PIN = 0;
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;exec_unit.c,71 :: 		M2_PIN = 0;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;exec_unit.c,72 :: 		M3_PIN = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;exec_unit.c,73 :: 		M4_PIN = 0;
	BCF         RC0_bit+0, BitPos(RC0_bit+0) 
;exec_unit.c,74 :: 		M5_PIN = 0;
	BCF         RE2_bit+0, BitPos(RE2_bit+0) 
;exec_unit.c,75 :: 		M6_PIN = 0;
	BCF         RE1_bit+0, BitPos(RE1_bit+0) 
;exec_unit.c,76 :: 		M7_PIN = 0;
	BCF         RE0_bit+0, BitPos(RE0_bit+0) 
;exec_unit.c,77 :: 		M8_PIN = 0;
	BCF         RA5_bit+0, BitPos(RA5_bit+0) 
;exec_unit.c,79 :: 		memset(motors, 0, sizeof(struct s_motor) * MOTOR_MAX);
	MOVLW       _motors+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_motors+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       64
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;exec_unit.c,80 :: 		}
L_end_motor_init:
	RETURN      0
; end of _motor_init

_motor_set_state:

;exec_unit.c,85 :: 		void motor_set_state( uchar motor, uchar state )
;exec_unit.c,87 :: 		switch ( motor )
	GOTO        L_motor_set_state71
;exec_unit.c,89 :: 		case 1:
L_motor_set_state73:
;exec_unit.c,90 :: 		M1_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state301
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__motor_set_state302
L__motor_set_state301:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__motor_set_state302:
;exec_unit.c,91 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,92 :: 		case 2:
L_motor_set_state74:
;exec_unit.c,93 :: 		M2_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state303
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
	GOTO        L__motor_set_state304
L__motor_set_state303:
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
L__motor_set_state304:
;exec_unit.c,94 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,95 :: 		case 3:
L_motor_set_state75:
;exec_unit.c,96 :: 		M3_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state305
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
	GOTO        L__motor_set_state306
L__motor_set_state305:
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
L__motor_set_state306:
;exec_unit.c,97 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,98 :: 		case 4:
L_motor_set_state76:
;exec_unit.c,99 :: 		M4_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state307
	BCF         RC0_bit+0, BitPos(RC0_bit+0) 
	GOTO        L__motor_set_state308
L__motor_set_state307:
	BSF         RC0_bit+0, BitPos(RC0_bit+0) 
L__motor_set_state308:
;exec_unit.c,100 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,101 :: 		case 5:
L_motor_set_state77:
;exec_unit.c,102 :: 		M5_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state309
	BCF         RE2_bit+0, BitPos(RE2_bit+0) 
	GOTO        L__motor_set_state310
L__motor_set_state309:
	BSF         RE2_bit+0, BitPos(RE2_bit+0) 
L__motor_set_state310:
;exec_unit.c,103 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,104 :: 		case 6:
L_motor_set_state78:
;exec_unit.c,105 :: 		M6_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state311
	BCF         RE1_bit+0, BitPos(RE1_bit+0) 
	GOTO        L__motor_set_state312
L__motor_set_state311:
	BSF         RE1_bit+0, BitPos(RE1_bit+0) 
L__motor_set_state312:
;exec_unit.c,106 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,107 :: 		case 7:
L_motor_set_state79:
;exec_unit.c,108 :: 		M7_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state313
	BCF         RE0_bit+0, BitPos(RE0_bit+0) 
	GOTO        L__motor_set_state314
L__motor_set_state313:
	BSF         RE0_bit+0, BitPos(RE0_bit+0) 
L__motor_set_state314:
;exec_unit.c,109 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,110 :: 		case 8:
L_motor_set_state80:
;exec_unit.c,111 :: 		M8_PIN = state;
	BTFSC       FARG_motor_set_state_state+0, 0 
	GOTO        L__motor_set_state315
	BCF         RA5_bit+0, BitPos(RA5_bit+0) 
	GOTO        L__motor_set_state316
L__motor_set_state315:
	BSF         RA5_bit+0, BitPos(RA5_bit+0) 
L__motor_set_state316:
;exec_unit.c,112 :: 		break;
	GOTO        L_motor_set_state72
;exec_unit.c,113 :: 		}
L_motor_set_state71:
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state73
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state74
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       3
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state75
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       4
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state76
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       5
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state77
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state78
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state79
	MOVF        FARG_motor_set_state_motor+0, 0 
	XORLW       8
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_set_state80
L_motor_set_state72:
;exec_unit.c,114 :: 		}
L_end_motor_set_state:
	RETURN      0
; end of _motor_set_state

_motor_get_fail_state:

;exec_unit.c,117 :: 		uchar motor_get_fail_state( )
;exec_unit.c,120 :: 		uchar s = 0;
	CLRF        motor_get_fail_state_s_L0+0 
;exec_unit.c,122 :: 		for ( i = 0; i < 8; ++i )
	CLRF        R3 
L_motor_get_fail_state81:
	MOVLW       8
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_motor_get_fail_state82
;exec_unit.c,123 :: 		if ( motors[i].state == 2 )
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_get_fail_state318:
	BZ          L__motor_get_fail_state319
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_get_fail_state318
L__motor_get_fail_state319:
	MOVLW       _motors+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_motor_get_fail_state84
;exec_unit.c,124 :: 		s |= (1 << i);
	MOVF        R3, 0 
	MOVWF       R1 
	MOVLW       1
	MOVWF       R0 
	MOVF        R1, 0 
L__motor_get_fail_state320:
	BZ          L__motor_get_fail_state321
	RLCF        R0, 1 
	BCF         R0, 0 
	ADDLW       255
	GOTO        L__motor_get_fail_state320
L__motor_get_fail_state321:
	MOVF        R0, 0 
	IORWF       motor_get_fail_state_s_L0+0, 1 
L_motor_get_fail_state84:
;exec_unit.c,122 :: 		for ( i = 0; i < 8; ++i )
	INCF        R3, 1 
;exec_unit.c,124 :: 		s |= (1 << i);
	GOTO        L_motor_get_fail_state81
L_motor_get_fail_state82:
;exec_unit.c,126 :: 		return s;
	MOVF        motor_get_fail_state_s_L0+0, 0 
	MOVWF       R0 
;exec_unit.c,127 :: 		}
L_end_motor_get_fail_state:
	RETURN      0
; end of _motor_get_fail_state

_motor_read:

;exec_unit.c,131 :: 		char motor_read( ulong *state )
;exec_unit.c,133 :: 		char res = 0;
	CLRF        motor_read_res_L0+0 
;exec_unit.c,135 :: 		curr_motors_state = ((M8_PIN << 7) | (M7_PIN << 6) | (M6_PIN << 5) | (M5_PIN << 4) | (M4_PIN << 3) | (M3_PIN << 2) | (M2_PIN << 1) | (M1_PIN << 0));
	MOVLW       0
	BTFSC       RA5_bit+0, BitPos(RA5_bit+0) 
	MOVLW       1
	MOVWF       _curr_motors_state+0 
	CLRF        _curr_motors_state+1 
	CLRF        _curr_motors_state+2 
	CLRF        _curr_motors_state+3 
	MOVLW       7
	MOVWF       R0 
	MOVLW       0
	MOVWF       _curr_motors_state+1 
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
L__motor_read323:
	BZ          L__motor_read324
	RLCF        _curr_motors_state+0, 1 
	BCF         _curr_motors_state+0, 0 
	RLCF        _curr_motors_state+1, 1 
	ADDLW       255
	GOTO        L__motor_read323
L__motor_read324:
	CLRF        R3 
	BTFSC       RE0_bit+0, BitPos(RE0_bit+0) 
	INCF        R3, 1 
	MOVLW       6
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_read325:
	BZ          L__motor_read326
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_read325
L__motor_read326:
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	CLRF        R3 
	BTFSC       RE1_bit+0, BitPos(RE1_bit+0) 
	INCF        R3, 1 
	MOVLW       5
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_read327:
	BZ          L__motor_read328
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_read327
L__motor_read328:
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	CLRF        R3 
	BTFSC       RE2_bit+0, BitPos(RE2_bit+0) 
	INCF        R3, 1 
	MOVLW       4
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_read329:
	BZ          L__motor_read330
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_read329
L__motor_read330:
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	CLRF        R3 
	BTFSC       RC0_bit+0, BitPos(RC0_bit+0) 
	INCF        R3, 1 
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_read331:
	BZ          L__motor_read332
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_read331
L__motor_read332:
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	CLRF        R3 
	BTFSC       RC1_bit+0, BitPos(RC1_bit+0) 
	INCF        R3, 1 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	CLRF        R3 
	BTFSC       RC2_bit+0, BitPos(RC2_bit+0) 
	INCF        R3, 1 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	CLRF        R0 
	BTFSC       RD0_bit+0, BitPos(RD0_bit+0) 
	INCF        R0, 1 
	MOVLW       0
	MOVWF       R1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVF        R0, 0 
	IORWF       _curr_motors_state+0, 1 
	MOVF        R1, 0 
	IORWF       _curr_motors_state+1, 1 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
	MOVLW       0
	MOVWF       _curr_motors_state+2 
	MOVWF       _curr_motors_state+3 
;exec_unit.c,136 :: 		if ( curr_motors_state != prev_motors_state )
	MOVF        _curr_motors_state+3, 0 
	XORWF       _prev_motors_state+3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__motor_read333
	MOVF        _curr_motors_state+2, 0 
	XORWF       _prev_motors_state+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__motor_read333
	MOVF        _curr_motors_state+1, 0 
	XORWF       _prev_motors_state+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__motor_read333
	MOVF        _curr_motors_state+0, 0 
	XORWF       _prev_motors_state+0, 0 
L__motor_read333:
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_read85
;exec_unit.c,138 :: 		*state = ((ushort)motor_get_fail_state() << 8) | (uchar)(curr_motors_state & 0x000000ff);
	CALL        _motor_get_fail_state+0, 0
	MOVF        R0, 0 
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVF        R4, 0 
	MOVWF       R3 
	CLRF        R2 
	MOVLW       255
	ANDWF       _curr_motors_state+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
	IORWF       R0, 1 
	MOVF        R3, 0 
	IORWF       R1, 1 
	MOVFF       FARG_motor_read_state+0, FSR1
	MOVFF       FARG_motor_read_state+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
	MOVLW       0
	MOVWF       POSTINC1+0 
	MOVWF       POSTINC1+0 
;exec_unit.c,139 :: 		prev_motors_state = curr_motors_state;
	MOVF        _curr_motors_state+0, 0 
	MOVWF       _prev_motors_state+0 
	MOVF        _curr_motors_state+1, 0 
	MOVWF       _prev_motors_state+1 
	MOVF        _curr_motors_state+2, 0 
	MOVWF       _prev_motors_state+2 
	MOVF        _curr_motors_state+3, 0 
	MOVWF       _prev_motors_state+3 
;exec_unit.c,140 :: 		res = 1;
	MOVLW       1
	MOVWF       motor_read_res_L0+0 
;exec_unit.c,141 :: 		}
L_motor_read85:
;exec_unit.c,143 :: 		return res;
	MOVF        motor_read_res_L0+0, 0 
	MOVWF       R0 
;exec_unit.c,144 :: 		}
L_end_motor_read:
	RETURN      0
; end of _motor_read

_motor_start:

;exec_unit.c,147 :: 		void motor_start( uchar number )
;exec_unit.c,149 :: 		TMR1IE_bit = 0;
	BCF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;exec_unit.c,150 :: 		motor_set_state(number + 1, 1);
	MOVF        FARG_motor_start_number+0, 0 
	ADDLW       1
	MOVWF       FARG_motor_set_state_motor+0 
	MOVLW       1
	MOVWF       FARG_motor_set_state_state+0 
	CALL        _motor_set_state+0, 0
;exec_unit.c,151 :: 		motors[number].state = 1;
	MOVLW       3
	MOVWF       R2 
	MOVF        FARG_motor_start_number+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_start335:
	BZ          L__motor_start336
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_start335
L__motor_start336:
	MOVLW       _motors+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       1
	MOVWF       POSTINC1+0 
;exec_unit.c,152 :: 		motors[number].ready = 0;
	MOVLW       3
	MOVWF       R2 
	MOVF        FARG_motor_start_number+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_start337:
	BZ          L__motor_start338
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_start337
L__motor_start338:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       5
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,153 :: 		motors[number].start_time_counter = 0;
	MOVLW       3
	MOVWF       R2 
	MOVF        FARG_motor_start_number+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_start339:
	BZ          L__motor_start340
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_start339
L__motor_start340:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       6
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
	CLRF        POSTINC1+0 
;exec_unit.c,154 :: 		TMR1IE_bit = 1;
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;exec_unit.c,155 :: 		}
L_end_motor_start:
	RETURN      0
; end of _motor_start

_motor_stop:

;exec_unit.c,158 :: 		void motor_stop( uchar number, uchar failure )
;exec_unit.c,160 :: 		motor_set_state(number + 1, 0);
	MOVF        FARG_motor_stop_number+0, 0 
	ADDLW       1
	MOVWF       FARG_motor_set_state_motor+0 
	CLRF        FARG_motor_set_state_state+0 
	CALL        _motor_set_state+0, 0
;exec_unit.c,161 :: 		motors[number].state = failure ? 2 : 0;
	MOVLW       3
	MOVWF       R2 
	MOVF        FARG_motor_stop_number+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_stop342:
	BZ          L__motor_stop343
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_stop342
L__motor_stop343:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVF        FARG_motor_stop_failure+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_stop86
	MOVLW       2
	MOVWF       ?FLOC___motor_stopT188+0 
	GOTO        L_motor_stop87
L_motor_stop86:
	CLRF        ?FLOC___motor_stopT188+0 
L_motor_stop87:
	MOVFF       R0, FSR1
	MOVFF       R1, FSR1H
	MOVF        ?FLOC___motor_stopT188+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,162 :: 		}
L_end_motor_stop:
	RETURN      0
; end of _motor_stop

_motor_acceleration_control:

;exec_unit.c,165 :: 		void motor_acceleration_control( )
;exec_unit.c,168 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	CLRF        R6 
L_motor_acceleration_control88:
	MOVLW       8
	SUBWF       R6, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_motor_acceleration_control89
;exec_unit.c,169 :: 		if ( motors[i].state == 1 && motors[i].ready == FALSE )
	MOVLW       3
	MOVWF       R2 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_acceleration_control345:
	BZ          L__motor_acceleration_control346
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_acceleration_control345
L__motor_acceleration_control346:
	MOVLW       _motors+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_motor_acceleration_control93
	MOVLW       3
	MOVWF       R2 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_acceleration_control347:
	BZ          L__motor_acceleration_control348
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_acceleration_control347
L__motor_acceleration_control348:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       5
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_motor_acceleration_control93
L__motor_acceleration_control269:
;exec_unit.c,170 :: 		if ( motors[i].start_time_counter++ >= motors[i].start_time )
	MOVLW       3
	MOVWF       R2 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_acceleration_control349:
	BZ          L__motor_acceleration_control350
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_acceleration_control349
L__motor_acceleration_control350:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       6
	ADDWF       R0, 0 
	MOVWF       R2 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       R3 
	MOVFF       R2, FSR0
	MOVFF       R3, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R4 
	MOVF        POSTINC0+0, 0 
	MOVWF       R5 
	MOVLW       1
	ADDWF       R4, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      R5, 0 
	MOVWF       R1 
	MOVFF       R2, FSR1
	MOVFF       R3, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
	MOVLW       3
	MOVWF       R2 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_acceleration_control351:
	BZ          L__motor_acceleration_control352
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_acceleration_control351
L__motor_acceleration_control352:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	MOVWF       R1 
	MOVF        POSTINC2+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	SUBWF       R5, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__motor_acceleration_control353
	MOVF        R1, 0 
	SUBWF       R4, 0 
L__motor_acceleration_control353:
	BTFSS       STATUS+0, 0 
	GOTO        L_motor_acceleration_control94
;exec_unit.c,171 :: 		motors[i].ready = TRUE;
	MOVLW       3
	MOVWF       R2 
	MOVF        R6, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_acceleration_control354:
	BZ          L__motor_acceleration_control355
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_acceleration_control354
L__motor_acceleration_control355:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       5
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       1
	MOVWF       POSTINC1+0 
L_motor_acceleration_control94:
L_motor_acceleration_control93:
;exec_unit.c,168 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	INCF        R6, 1 
;exec_unit.c,171 :: 		motors[i].ready = TRUE;
	GOTO        L_motor_acceleration_control88
L_motor_acceleration_control89:
;exec_unit.c,172 :: 		}
L_end_motor_acceleration_control:
	RETURN      0
; end of _motor_acceleration_control

_motor_protect_control:

;exec_unit.c,175 :: 		void motor_protect_control( )
;exec_unit.c,178 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	CLRF        motor_protect_control_i_L0+0 
L_motor_protect_control95:
	MOVLW       8
	SUBWF       motor_protect_control_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_motor_protect_control96
;exec_unit.c,181 :: 		if ( motors[i].state != 1 || motors[i].protect == 0 )
	MOVLW       3
	MOVWF       R2 
	MOVF        motor_protect_control_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_protect_control357:
	BZ          L__motor_protect_control358
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_protect_control357
L__motor_protect_control358:
	MOVLW       _motors+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L__motor_protect_control271
	MOVLW       3
	MOVWF       R2 
	MOVF        motor_protect_control_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_protect_control359:
	BZ          L__motor_protect_control360
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_protect_control359
L__motor_protect_control360:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L__motor_protect_control271
	GOTO        L_motor_protect_control100
L__motor_protect_control271:
;exec_unit.c,182 :: 		continue;
	GOTO        L_motor_protect_control97
L_motor_protect_control100:
;exec_unit.c,185 :: 		if ( motors[i].ready && motors[i].sensor_state )
	MOVLW       3
	MOVWF       R2 
	MOVF        motor_protect_control_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_protect_control361:
	BZ          L__motor_protect_control362
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_protect_control361
L__motor_protect_control362:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       5
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_protect_control103
	MOVLW       3
	MOVWF       R2 
	MOVF        motor_protect_control_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_protect_control363:
	BZ          L__motor_protect_control364
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_protect_control363
L__motor_protect_control364:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_protect_control103
L__motor_protect_control270:
;exec_unit.c,188 :: 		motor_stop(i, TRUE);
	MOVF        motor_protect_control_i_L0+0, 0 
	MOVWF       FARG_motor_stop_number+0 
	MOVLW       1
	MOVWF       FARG_motor_stop_failure+0 
	CALL        _motor_stop+0, 0
;exec_unit.c,189 :: 		}
L_motor_protect_control103:
;exec_unit.c,190 :: 		}
L_motor_protect_control97:
;exec_unit.c,178 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	INCF        motor_protect_control_i_L0+0, 1 
;exec_unit.c,190 :: 		}
	GOTO        L_motor_protect_control95
L_motor_protect_control96:
;exec_unit.c,191 :: 		}
L_end_motor_protect_control:
	RETURN      0
; end of _motor_protect_control

_motor_reset_fail_state:

;exec_unit.c,194 :: 		void motor_reset_fail_state( )
;exec_unit.c,197 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	CLRF        R3 
L_motor_reset_fail_state104:
	MOVLW       8
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_motor_reset_fail_state105
;exec_unit.c,198 :: 		if ( motors[i].state == 2 )
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_reset_fail_state366:
	BZ          L__motor_reset_fail_state367
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_reset_fail_state366
L__motor_reset_fail_state367:
	MOVLW       _motors+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_motor_reset_fail_state107
;exec_unit.c,199 :: 		motors[i].state = 0;
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_reset_fail_state368:
	BZ          L__motor_reset_fail_state369
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_reset_fail_state368
L__motor_reset_fail_state369:
	MOVLW       _motors+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
L_motor_reset_fail_state107:
;exec_unit.c,197 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	INCF        R3, 1 
;exec_unit.c,199 :: 		motors[i].state = 0;
	GOTO        L_motor_reset_fail_state104
L_motor_reset_fail_state105:
;exec_unit.c,200 :: 		}
L_end_motor_reset_fail_state:
	RETURN      0
; end of _motor_reset_fail_state

_motor_get_protected:

;exec_unit.c,203 :: 		unsigned char motor_get_protected( )
;exec_unit.c,205 :: 		char i, n = 0;
	CLRF        motor_get_protected_n_L0+0 
;exec_unit.c,206 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	CLRF        R3 
L_motor_get_protected108:
	MOVLW       8
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_motor_get_protected109
;exec_unit.c,207 :: 		if ( motors[i].protect )
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__motor_get_protected371:
	BZ          L__motor_get_protected372
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__motor_get_protected371
L__motor_get_protected372:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protected111
;exec_unit.c,208 :: 		n++;
	INCF        motor_get_protected_n_L0+0, 1 
L_motor_get_protected111:
;exec_unit.c,206 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	INCF        R3, 1 
;exec_unit.c,208 :: 		n++;
	GOTO        L_motor_get_protected108
L_motor_get_protected109:
;exec_unit.c,209 :: 		return n;
	MOVF        motor_get_protected_n_L0+0, 0 
	MOVWF       R0 
;exec_unit.c,210 :: 		}
L_end_motor_get_protected:
	RETURN      0
; end of _motor_get_protected

_timer1_init:

;exec_unit.c,213 :: 		void timer1_init( )
;exec_unit.c,216 :: 		T1CON      = 0x31;
	MOVLW       49
	MOVWF       T1CON+0 
;exec_unit.c,217 :: 		TMR1IF_bit = 0;
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;exec_unit.c,218 :: 		TMR1H      = 0x0B;
	MOVLW       11
	MOVWF       TMR1H+0 
;exec_unit.c,219 :: 		TMR1L      = 0xD9;
	MOVLW       217
	MOVWF       TMR1L+0 
;exec_unit.c,220 :: 		TMR1IE_bit = 1;
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;exec_unit.c,221 :: 		}
L_end_timer1_init:
	RETURN      0
; end of _timer1_init

_load_config:

;exec_unit.c,224 :: 		void load_config( )
;exec_unit.c,229 :: 		byte_val = ee_read(0x00);
	CLRF        FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVF        R0, 0 
	MOVWF       load_config_byte_val_L0+0 
;exec_unit.c,230 :: 		if ( byte_val != 0xff )
	MOVF        R0, 0 
	XORLW       255
	BTFSC       STATUS+0, 2 
	GOTO        L_load_config112
;exec_unit.c,231 :: 		unit_number = byte_val;
	MOVF        load_config_byte_val_L0+0, 0 
	MOVWF       _unit_number+0 
L_load_config112:
;exec_unit.c,233 :: 		n = 0;
	CLRF        load_config_n_L0+0 
;exec_unit.c,234 :: 		for ( i = 0; i < 8; ++i )
	CLRF        load_config_i_L0+0 
L_load_config113:
	MOVLW       8
	SUBWF       load_config_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_load_config114
;exec_unit.c,237 :: 		byte_val = ee_read(0x01 + n);
	MOVF        load_config_n_L0+0, 0 
	ADDLW       1
	MOVWF       FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVF        R0, 0 
	MOVWF       load_config_byte_val_L0+0 
;exec_unit.c,239 :: 		word_val = ((ushort)ee_read(0x03 + n) << 8) | ee_read(0x02 + n);
	MOVF        load_config_n_L0+0, 0 
	ADDLW       3
	MOVWF       FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVF        R0, 0 
	MOVWF       R1 
	MOVLW       0
	MOVWF       R2 
	MOVF        R1, 0 
	MOVWF       FLOC__load_config+1 
	CLRF        FLOC__load_config+0 
	MOVF        load_config_n_L0+0, 0 
	ADDLW       2
	MOVWF       FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVF        R0, 0 
	IORWF       FLOC__load_config+0, 0 
	MOVWF       load_config_word_val_L0+0 
	MOVF        FLOC__load_config+1, 0 
	MOVWF       load_config_word_val_L0+1 
	MOVLW       0
	IORWF       load_config_word_val_L0+1, 1 
;exec_unit.c,241 :: 		if ( byte_val == 0xff )  // Пропускаем пустые ячейки
	MOVF        load_config_byte_val_L0+0, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_load_config116
;exec_unit.c,242 :: 		continue;
	GOTO        L_load_config115
L_load_config116:
;exec_unit.c,244 :: 		motors[i].protect    = byte_val;
	MOVLW       3
	MOVWF       R2 
	MOVF        load_config_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__load_config375:
	BZ          L__load_config376
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__load_config375
L__load_config376:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVF        load_config_byte_val_L0+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,245 :: 		motors[i].start_time = word_val;
	MOVLW       3
	MOVWF       R2 
	MOVF        load_config_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__load_config377:
	BZ          L__load_config378
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__load_config377
L__load_config378:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVF        load_config_word_val_L0+0, 0 
	MOVWF       POSTINC1+0 
	MOVF        load_config_word_val_L0+1, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,247 :: 		n += 3;
	MOVLW       3
	ADDWF       load_config_n_L0+0, 1 
;exec_unit.c,248 :: 		}
L_load_config115:
;exec_unit.c,234 :: 		for ( i = 0; i < 8; ++i )
	INCF        load_config_i_L0+0, 1 
;exec_unit.c,248 :: 		}
	GOTO        L_load_config113
L_load_config114:
;exec_unit.c,250 :: 		protected_motors = motor_get_protected();
	CALL        _motor_get_protected+0, 0
	MOVF        R0, 0 
	MOVWF       _protected_motors+0 
;exec_unit.c,251 :: 		}
L_end_load_config:
	RETURN      0
; end of _load_config

_write_config_byte:

;exec_unit.c,254 :: 		uchar write_config_byte( uchar addr, uchar dat )
;exec_unit.c,256 :: 		return (ee_write(addr, dat) && (ee_read(addr) == dat));
	MOVF        FARG_write_config_byte_addr+0, 0 
	MOVWF       FARG_ee_write_addr+0 
	MOVF        FARG_write_config_byte_dat+0, 0 
	MOVWF       FARG_ee_write_val+0 
	CALL        _ee_write+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_write_config_byte118
	MOVF        FARG_write_config_byte_addr+0, 0 
	MOVWF       FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVF        R0, 0 
	XORWF       FARG_write_config_byte_dat+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_write_config_byte118
	MOVLW       1
	MOVWF       R0 
	GOTO        L_write_config_byte117
L_write_config_byte118:
	CLRF        R0 
L_write_config_byte117:
;exec_unit.c,257 :: 		}
L_end_write_config_byte:
	RETURN      0
; end of _write_config_byte

_write_config_word:

;exec_unit.c,260 :: 		uchar write_config_word( uchar addr, ushort dat )
;exec_unit.c,262 :: 		return (ee_write(addr, dat & 0x00ff) && ee_write(addr + 1, (dat >> 8) & 0x00ff) && (ee_read(addr) == (dat & 0x00ff)) && (ee_read(addr + 1) == ((dat >> 8) & 0x00ff)));
	MOVF        FARG_write_config_word_addr+0, 0 
	MOVWF       FARG_ee_write_addr+0 
	MOVLW       255
	ANDWF       FARG_write_config_word_dat+0, 0 
	MOVWF       FARG_ee_write_val+0 
	CALL        _ee_write+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_write_config_word120
	MOVF        FARG_write_config_word_addr+0, 0 
	ADDLW       1
	MOVWF       FARG_ee_write_addr+0 
	MOVF        FARG_write_config_word_dat+1, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       255
	ANDWF       R0, 0 
	MOVWF       FARG_ee_write_val+0 
	CALL        _ee_write+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_write_config_word120
	MOVF        FARG_write_config_word_addr+0, 0 
	MOVWF       FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVLW       255
	ANDWF       FARG_write_config_word_dat+0, 0 
	MOVWF       R2 
	MOVF        FARG_write_config_word_dat+1, 0 
	MOVWF       R3 
	MOVLW       0
	ANDWF       R3, 1 
	MOVLW       0
	XORWF       R3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__write_config_word381
	MOVF        R2, 0 
	XORWF       R0, 0 
L__write_config_word381:
	BTFSS       STATUS+0, 2 
	GOTO        L_write_config_word120
	MOVF        FARG_write_config_word_addr+0, 0 
	ADDLW       1
	MOVWF       FARG_ee_read_addr+0 
	CALL        _ee_read+0, 0
	MOVF        FARG_write_config_word_dat+1, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       255
	ANDWF       R1, 0 
	MOVWF       R3 
	MOVF        R2, 0 
	MOVWF       R4 
	MOVLW       0
	ANDWF       R4, 1 
	MOVLW       0
	XORWF       R4, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__write_config_word382
	MOVF        R3, 0 
	XORWF       R0, 0 
L__write_config_word382:
	BTFSS       STATUS+0, 2 
	GOTO        L_write_config_word120
	MOVLW       1
	MOVWF       R0 
	GOTO        L_write_config_word119
L_write_config_word120:
	CLRF        R0 
L_write_config_word119:
;exec_unit.c,263 :: 		}
L_end_write_config_word:
	RETURN      0
; end of _write_config_word

_protect_restore:

;exec_unit.c,267 :: 		void protect_restore( )
;exec_unit.c,269 :: 		SENSORS_PWR_RESTORE_PIN = 1;
	BSF         RD1_bit+0, BitPos(RD1_bit+0) 
;exec_unit.c,270 :: 		delay_ms(100);
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_protect_restore121:
	DECFSZ      R13, 1, 1
	BRA         L_protect_restore121
	DECFSZ      R12, 1, 1
	BRA         L_protect_restore121
	DECFSZ      R11, 1, 1
	BRA         L_protect_restore121
	NOP
	NOP
;exec_unit.c,271 :: 		SENSORS_PWR_RESTORE_PIN = 0;
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;exec_unit.c,272 :: 		}
L_end_protect_restore:
	RETURN      0
; end of _protect_restore

_exec_commands:

;exec_unit.c,276 :: 		void exec_commands( )
;exec_unit.c,280 :: 		while ( 1 )                                                                 // Читает из приемопередатчика, пока есть данные
L_exec_commands122:
;exec_unit.c,282 :: 		delay_ms(1);
	MOVLW       7
	MOVWF       R12, 0
	MOVLW       125
	MOVWF       R13, 0
L_exec_commands124:
	DECFSZ      R13, 1, 1
	BRA         L_exec_commands124
	DECFSZ      R12, 1, 1
	BRA         L_exec_commands124
;exec_unit.c,283 :: 		memset(buff, 0, 5);
	MOVLW       exec_commands_buff_L0+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(exec_commands_buff_L0+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       5
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;exec_unit.c,284 :: 		if ( transceiver_recv(buff) )                                           // Есть данные
	MOVLW       exec_commands_buff_L0+0
	MOVWF       FARG_transceiver_recv_result+0 
	MOVLW       hi_addr(exec_commands_buff_L0+0)
	MOVWF       FARG_transceiver_recv_result+1 
	CALL        _transceiver_recv+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_exec_commands125
;exec_unit.c,286 :: 		is_connected = TRUE;                                                // Хотябы одна команда от сервера была принята
	MOVLW       1
	MOVWF       _is_connected+0 
;exec_unit.c,288 :: 		switch ( buff[1] )                                                  // Команда
	GOTO        L_exec_commands126
;exec_unit.c,296 :: 		case NET_CMD_REQUERY:
L_exec_commands128:
;exec_unit.c,297 :: 		LED_PIN = ~LED_PIN;
	BTG         RD4_bit+0, BitPos(RD4_bit+0) 
;exec_unit.c,298 :: 		changes = TRUE;
	MOVLW       1
	MOVWF       _changes+0 
;exec_unit.c,299 :: 		break;
	GOTO        L_exec_commands127
;exec_unit.c,302 :: 		case NET_CMD_SET_MOTOR_STATE:
L_exec_commands129:
;exec_unit.c,303 :: 		if ( buff[2] )
	MOVF        exec_commands_buff_L0+2, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_exec_commands130
;exec_unit.c,304 :: 		motor_start(buff[3] - 1);
	DECF        exec_commands_buff_L0+3, 0 
	MOVWF       FARG_motor_start_number+0 
	CALL        _motor_start+0, 0
	GOTO        L_exec_commands131
L_exec_commands130:
;exec_unit.c,306 :: 		motor_stop(buff[3] - 1, FALSE);
	DECF        exec_commands_buff_L0+3, 0 
	MOVWF       FARG_motor_stop_number+0 
	CLRF        FARG_motor_stop_failure+0 
	CALL        _motor_stop+0, 0
L_exec_commands131:
;exec_unit.c,307 :: 		break;
	GOTO        L_exec_commands127
;exec_unit.c,310 :: 		case NET_CMD_RESTORE_PROTECT:
L_exec_commands132:
;exec_unit.c,311 :: 		protect_restore();
	CALL        _protect_restore+0, 0
;exec_unit.c,312 :: 		break;
	GOTO        L_exec_commands127
;exec_unit.c,315 :: 		}
L_exec_commands126:
	MOVF        exec_commands_buff_L0+1, 0 
	XORLW       16
	BTFSC       STATUS+0, 2 
	GOTO        L_exec_commands128
	MOVF        exec_commands_buff_L0+1, 0 
	XORLW       5
	BTFSC       STATUS+0, 2 
	GOTO        L_exec_commands129
	MOVF        exec_commands_buff_L0+1, 0 
	XORLW       14
	BTFSC       STATUS+0, 2 
	GOTO        L_exec_commands132
L_exec_commands127:
;exec_unit.c,316 :: 		}
	GOTO        L_exec_commands133
L_exec_commands125:
;exec_unit.c,319 :: 		break;  // Данных больше нет
	GOTO        L_exec_commands123
;exec_unit.c,320 :: 		}
L_exec_commands133:
;exec_unit.c,321 :: 		}
	GOTO        L_exec_commands122
L_exec_commands123:
;exec_unit.c,323 :: 		delay_ms(100);                                                              // ???
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_exec_commands134:
	DECFSZ      R13, 1, 1
	BRA         L_exec_commands134
	DECFSZ      R12, 1, 1
	BRA         L_exec_commands134
	DECFSZ      R11, 1, 1
	BRA         L_exec_commands134
	NOP
	NOP
;exec_unit.c,324 :: 		}
L_end_exec_commands:
	RETURN      0
; end of _exec_commands

_sensors_read:

;exec_unit.c,328 :: 		char sensors_read( ulong *state )
;exec_unit.c,331 :: 		char res = 0;
	CLRF        sensors_read_res_L0+0 
;exec_unit.c,334 :: 		st = hc165_read(24);
	MOVLW       24
	MOVWF       FARG_hc165_read_bits_count+0 
	CALL        _hc165_read+0, 0
	MOVF        R0, 0 
	MOVWF       sensors_read_st_L0+0 
	MOVF        R1, 0 
	MOVWF       sensors_read_st_L0+1 
	MOVF        R2, 0 
	MOVWF       sensors_read_st_L0+2 
	MOVF        R3, 0 
	MOVWF       sensors_read_st_L0+3 
;exec_unit.c,337 :: 		curr_sensors_state = 0;
	CLRF        _curr_sensors_state+0 
	CLRF        _curr_sensors_state+1 
	CLRF        _curr_sensors_state+2 
	CLRF        _curr_sensors_state+3 
;exec_unit.c,338 :: 		if ( st & 0b000000000000000000100000 ) curr_sensors_state |= 0b000000000000000000000001;
	BTFSS       R0, 5 
	GOTO        L_sensors_read135
	BSF         _curr_sensors_state+0, 0 
L_sensors_read135:
;exec_unit.c,339 :: 		if ( st & 0b000000000000000001000000 ) curr_sensors_state |= 0b000000000000000000000010;
	BTFSS       sensors_read_st_L0+0, 6 
	GOTO        L_sensors_read136
	BSF         _curr_sensors_state+0, 1 
L_sensors_read136:
;exec_unit.c,340 :: 		if ( st & 0b000000000000000010000000 ) curr_sensors_state |= 0b000000000000000000000100;
	BTFSS       sensors_read_st_L0+0, 7 
	GOTO        L_sensors_read137
	BSF         _curr_sensors_state+0, 2 
L_sensors_read137:
;exec_unit.c,341 :: 		if ( st & 0b000000000000000000001000 ) curr_sensors_state |= 0b000000000000000000001000;
	BTFSS       sensors_read_st_L0+0, 3 
	GOTO        L_sensors_read138
	BSF         _curr_sensors_state+0, 3 
L_sensors_read138:
;exec_unit.c,342 :: 		if ( st & 0b000000000000000000000100 ) curr_sensors_state |= 0b000000000000000000010000;
	BTFSS       sensors_read_st_L0+0, 2 
	GOTO        L_sensors_read139
	BSF         _curr_sensors_state+0, 4 
L_sensors_read139:
;exec_unit.c,343 :: 		if ( st & 0b000000000000000000000010 ) curr_sensors_state |= 0b000000000000000000100000;
	BTFSS       sensors_read_st_L0+0, 1 
	GOTO        L_sensors_read140
	BSF         _curr_sensors_state+0, 5 
L_sensors_read140:
;exec_unit.c,344 :: 		if ( st & 0b000000000000000000000001 ) curr_sensors_state |= 0b000000000000000001000000;
	BTFSS       sensors_read_st_L0+0, 0 
	GOTO        L_sensors_read141
	BSF         _curr_sensors_state+0, 6 
L_sensors_read141:
;exec_unit.c,345 :: 		if ( st & 0b000000000001000000000000 ) curr_sensors_state |= 0b000000000000000010000000;
	BTFSS       sensors_read_st_L0+1, 4 
	GOTO        L_sensors_read142
	BSF         _curr_sensors_state+0, 7 
L_sensors_read142:
;exec_unit.c,346 :: 		if ( st & 0b000000000010000000000000 ) curr_sensors_state |= 0b000000000000000100000000;
	BTFSS       sensors_read_st_L0+1, 5 
	GOTO        L_sensors_read143
	BSF         _curr_sensors_state+1, 0 
L_sensors_read143:
;exec_unit.c,347 :: 		if ( st & 0b000000000100000000000000 ) curr_sensors_state |= 0b000000000000001000000000;
	BTFSS       sensors_read_st_L0+1, 6 
	GOTO        L_sensors_read144
	BSF         _curr_sensors_state+1, 1 
L_sensors_read144:
;exec_unit.c,348 :: 		if ( st & 0b000000001000000000000000 ) curr_sensors_state |= 0b000000000000010000000000;
	BTFSS       sensors_read_st_L0+1, 7 
	GOTO        L_sensors_read145
	BSF         _curr_sensors_state+1, 2 
L_sensors_read145:
;exec_unit.c,349 :: 		if ( st & 0b000000000000000100000000 ) curr_sensors_state |= 0b000000000000100000000000;
	BTFSS       sensors_read_st_L0+1, 0 
	GOTO        L_sensors_read146
	BSF         _curr_sensors_state+1, 3 
L_sensors_read146:
;exec_unit.c,350 :: 		if ( st & 0b000000000000001000000000 ) curr_sensors_state |= 0b000000000001000000000000;
	BTFSS       sensors_read_st_L0+1, 1 
	GOTO        L_sensors_read147
	BSF         _curr_sensors_state+1, 4 
L_sensors_read147:
;exec_unit.c,351 :: 		if ( st & 0b000000000000010000000000 ) curr_sensors_state |= 0b000000000010000000000000;
	BTFSS       sensors_read_st_L0+1, 2 
	GOTO        L_sensors_read148
	BSF         _curr_sensors_state+1, 5 
L_sensors_read148:
;exec_unit.c,352 :: 		if ( st & 0b000000000000100000000000 ) curr_sensors_state |= 0b000000000100000000000000;
	BTFSS       sensors_read_st_L0+1, 3 
	GOTO        L_sensors_read149
	BSF         _curr_sensors_state+1, 6 
L_sensors_read149:
;exec_unit.c,353 :: 		if ( st & 0b000100000000000000000000 ) curr_sensors_state |= 0b000000001000000000000000;
	BTFSS       sensors_read_st_L0+2, 4 
	GOTO        L_sensors_read150
	BSF         _curr_sensors_state+1, 7 
L_sensors_read150:
;exec_unit.c,354 :: 		if ( st & 0b001000000000000000000000 ) curr_sensors_state |= 0b000000010000000000000000;
	BTFSS       sensors_read_st_L0+2, 5 
	GOTO        L_sensors_read151
	BSF         _curr_sensors_state+2, 0 
L_sensors_read151:
;exec_unit.c,355 :: 		if ( st & 0b010000000000000000000000 ) curr_sensors_state |= 0b000000100000000000000000;
	BTFSS       sensors_read_st_L0+2, 6 
	GOTO        L_sensors_read152
	BSF         _curr_sensors_state+2, 1 
L_sensors_read152:
;exec_unit.c,356 :: 		if ( st & 0b100000000000000000000000 ) curr_sensors_state |= 0b000001000000000000000000;
	BTFSS       sensors_read_st_L0+2, 7 
	GOTO        L_sensors_read153
	BSF         _curr_sensors_state+2, 2 
L_sensors_read153:
;exec_unit.c,357 :: 		if ( st & 0b000010000000000000000000 ) curr_sensors_state |= 0b000010000000000000000000;
	BTFSS       sensors_read_st_L0+2, 3 
	GOTO        L_sensors_read154
	BSF         _curr_sensors_state+2, 3 
L_sensors_read154:
;exec_unit.c,358 :: 		if ( st & 0b000001000000000000000000 ) curr_sensors_state |= 0b000100000000000000000000;
	BTFSS       sensors_read_st_L0+2, 2 
	GOTO        L_sensors_read155
	BSF         _curr_sensors_state+2, 4 
L_sensors_read155:
;exec_unit.c,359 :: 		if ( st & 0b000000100000000000000000 ) curr_sensors_state |= 0b001000000000000000000000;
	BTFSS       sensors_read_st_L0+2, 1 
	GOTO        L_sensors_read156
	BSF         _curr_sensors_state+2, 5 
L_sensors_read156:
;exec_unit.c,360 :: 		if ( st & 0b000000010000000000000000 ) curr_sensors_state |= 0b010000000000000000000000;
	BTFSS       sensors_read_st_L0+2, 0 
	GOTO        L_sensors_read157
	BSF         _curr_sensors_state+2, 6 
L_sensors_read157:
;exec_unit.c,361 :: 		if ( st & 0b000000000000000000010000 ) curr_sensors_state |= 0b100000000000000000000000;
	BTFSS       sensors_read_st_L0+0, 4 
	GOTO        L_sensors_read158
	BSF         _curr_sensors_state+2, 7 
L_sensors_read158:
;exec_unit.c,364 :: 		for ( i = 0; i < protected_motors; ++i )
	CLRF        sensors_read_i_L0+0 
L_sensors_read159:
	MOVF        _protected_motors+0, 0 
	SUBWF       sensors_read_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_sensors_read160
;exec_unit.c,365 :: 		motors[i].sensor_state = (curr_sensors_state & (0x00400000 >> i)) ? 0 : 1;    // 0x00400000 - 23-й байт
	MOVLW       3
	MOVWF       R2 
	MOVF        sensors_read_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__sensors_read386:
	BZ          L__sensors_read387
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__sensors_read386
L__sensors_read387:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       R5 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       R6 
	MOVF        sensors_read_i_L0+0, 0 
	MOVWF       R4 
	MOVLW       0
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVLW       64
	MOVWF       R2 
	MOVLW       0
	MOVWF       R3 
	MOVF        R4, 0 
L__sensors_read388:
	BZ          L__sensors_read389
	RRCF        R3, 1 
	RRCF        R2, 1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R3, 7 
	BTFSC       R3, 6 
	BSF         R3, 7 
	ADDLW       255
	GOTO        L__sensors_read388
L__sensors_read389:
	MOVF        _curr_sensors_state+0, 0 
	ANDWF       R0, 1 
	MOVF        _curr_sensors_state+1, 0 
	ANDWF       R1, 1 
	MOVF        _curr_sensors_state+2, 0 
	ANDWF       R2, 1 
	MOVF        _curr_sensors_state+3, 0 
	ANDWF       R3, 1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	IORWF       R2, 0 
	IORWF       R3, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_sensors_read162
	CLRF        ?FLOC___sensors_readT393+0 
	GOTO        L_sensors_read163
L_sensors_read162:
	MOVLW       1
	MOVWF       ?FLOC___sensors_readT393+0 
L_sensors_read163:
	MOVFF       R5, FSR1
	MOVFF       R6, FSR1H
	MOVF        ?FLOC___sensors_readT393+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,364 :: 		for ( i = 0; i < protected_motors; ++i )
	INCF        sensors_read_i_L0+0, 1 
;exec_unit.c,365 :: 		motors[i].sensor_state = (curr_sensors_state & (0x00400000 >> i)) ? 0 : 1;    // 0x00400000 - 23-й байт
	GOTO        L_sensors_read159
L_sensors_read160:
;exec_unit.c,369 :: 		curr_sensors_state &= protected_mask[protected_motors];
	MOVF        _protected_motors+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _protected_mask+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_protected_mask+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_protected_mask+0)
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, R0
	TBLRD*+
	MOVFF       TABLAT+0, R1
	TBLRD*+
	MOVFF       TABLAT+0, R2
	TBLRD*+
	MOVFF       TABLAT+0, R3
	MOVF        R0, 0 
	ANDWF       _curr_sensors_state+0, 0 
	MOVWF       R4 
	MOVF        R1, 0 
	ANDWF       _curr_sensors_state+1, 0 
	MOVWF       R5 
	MOVF        R2, 0 
	ANDWF       _curr_sensors_state+2, 0 
	MOVWF       R6 
	MOVF        R3, 0 
	ANDWF       _curr_sensors_state+3, 0 
	MOVWF       R7 
	MOVF        R4, 0 
	MOVWF       _curr_sensors_state+0 
	MOVF        R5, 0 
	MOVWF       _curr_sensors_state+1 
	MOVF        R6, 0 
	MOVWF       _curr_sensors_state+2 
	MOVF        R7, 0 
	MOVWF       _curr_sensors_state+3 
;exec_unit.c,372 :: 		if ( curr_sensors_state != prev_sensors_state )
	MOVF        R7, 0 
	XORWF       _prev_sensors_state+3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__sensors_read390
	MOVF        R6, 0 
	XORWF       _prev_sensors_state+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__sensors_read390
	MOVF        R5, 0 
	XORWF       _prev_sensors_state+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__sensors_read390
	MOVF        R4, 0 
	XORWF       _prev_sensors_state+0, 0 
L__sensors_read390:
	BTFSC       STATUS+0, 2 
	GOTO        L_sensors_read164
;exec_unit.c,374 :: 		*state = curr_sensors_state;
	MOVFF       FARG_sensors_read_state+0, FSR1
	MOVFF       FARG_sensors_read_state+1, FSR1H
	MOVF        _curr_sensors_state+0, 0 
	MOVWF       POSTINC1+0 
	MOVF        _curr_sensors_state+1, 0 
	MOVWF       POSTINC1+0 
	MOVF        _curr_sensors_state+2, 0 
	MOVWF       POSTINC1+0 
	MOVF        _curr_sensors_state+3, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,375 :: 		prev_sensors_state = curr_sensors_state;
	MOVF        _curr_sensors_state+0, 0 
	MOVWF       _prev_sensors_state+0 
	MOVF        _curr_sensors_state+1, 0 
	MOVWF       _prev_sensors_state+1 
	MOVF        _curr_sensors_state+2, 0 
	MOVWF       _prev_sensors_state+2 
	MOVF        _curr_sensors_state+3, 0 
	MOVWF       _prev_sensors_state+3 
;exec_unit.c,376 :: 		res = 1;
	MOVLW       1
	MOVWF       sensors_read_res_L0+0 
;exec_unit.c,377 :: 		}
L_sensors_read164:
;exec_unit.c,379 :: 		delay_ms(50);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       69
	MOVWF       R12, 0
	MOVLW       169
	MOVWF       R13, 0
L_sensors_read165:
	DECFSZ      R13, 1, 1
	BRA         L_sensors_read165
	DECFSZ      R12, 1, 1
	BRA         L_sensors_read165
	DECFSZ      R11, 1, 1
	BRA         L_sensors_read165
	NOP
	NOP
;exec_unit.c,381 :: 		return res;
	MOVF        sensors_read_res_L0+0, 0 
	MOVWF       R0 
;exec_unit.c,382 :: 		}
L_end_sensors_read:
	RETURN      0
; end of _sensors_read

_motor_get_protect_mask:

;exec_unit.c,385 :: 		char motor_get_protect_mask( char count )
;exec_unit.c,387 :: 		switch ( count )
	GOTO        L_motor_get_protect_mask166
;exec_unit.c,389 :: 		case 1:
L_motor_get_protect_mask168:
;exec_unit.c,390 :: 		return 0b00000001;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,391 :: 		case 2:
L_motor_get_protect_mask169:
;exec_unit.c,392 :: 		return 0b00000011;
	MOVLW       3
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,393 :: 		case 3:
L_motor_get_protect_mask170:
;exec_unit.c,394 :: 		return 0b00000111;
	MOVLW       7
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,395 :: 		case 4:
L_motor_get_protect_mask171:
;exec_unit.c,396 :: 		return 0b00001111;
	MOVLW       15
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,397 :: 		case 5:
L_motor_get_protect_mask172:
;exec_unit.c,398 :: 		return 0b00011111;
	MOVLW       31
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,399 :: 		case 6:
L_motor_get_protect_mask173:
;exec_unit.c,400 :: 		return 0b00111111;
	MOVLW       63
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,401 :: 		case 7:
L_motor_get_protect_mask174:
;exec_unit.c,402 :: 		return 0b01111111;
	MOVLW       127
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,403 :: 		case 8:
L_motor_get_protect_mask175:
;exec_unit.c,404 :: 		return 0b11111111;
	MOVLW       255
	MOVWF       R0 
	GOTO        L_end_motor_get_protect_mask
;exec_unit.c,405 :: 		}
L_motor_get_protect_mask166:
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask168
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask169
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       3
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask170
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       4
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask171
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       5
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask172
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask173
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask174
	MOVF        FARG_motor_get_protect_mask_count+0, 0 
	XORLW       8
	BTFSC       STATUS+0, 2 
	GOTO        L_motor_get_protect_mask175
;exec_unit.c,406 :: 		return 0;
	CLRF        R0 
;exec_unit.c,407 :: 		}
L_end_motor_get_protect_mask:
	RETURN      0
; end of _motor_get_protect_mask

_init:

;exec_unit.c,410 :: 		void init( )
;exec_unit.c,412 :: 		ADCON1 |= 0x0F;                                                             // Configure all ports with analog function as digital
	MOVLW       15
	IORWF       ADCON1+0, 1 
;exec_unit.c,413 :: 		CMCON  |= 7;                                                                // Comparator off
	MOVLW       7
	IORWF       CMCON+0, 1 
;exec_unit.c,415 :: 		LED_DIR = 0;
	BCF         TRISD4_bit+0, BitPos(TRISD4_bit+0) 
;exec_unit.c,416 :: 		LED_PIN = 0;
	BCF         RD4_bit+0, BitPos(RD4_bit+0) 
;exec_unit.c,418 :: 		SENSORS_PWR_RESTORE_DIR = 0;
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;exec_unit.c,419 :: 		SENSORS_PWR_RESTORE_PIN = 0;
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;exec_unit.c,421 :: 		USB_PWR_DIR = 1;
	BSF         TRISD2_bit+0, BitPos(TRISD2_bit+0) 
;exec_unit.c,422 :: 		}
L_end_init:
	RETURN      0
; end of _init

_interrupt:

;exec_unit.c,424 :: 		void interrupt()
;exec_unit.c,426 :: 		if ( USBIF_bit )
	BTFSS       USBIF_bit+0, BitPos(USBIF_bit+0) 
	GOTO        L_interrupt176
;exec_unit.c,428 :: 		USB_Interrupt_Proc();                                                   // USB servicing is done inside the interrupt
	CALL        _USB_Interrupt_Proc+0, 0
;exec_unit.c,429 :: 		USBIF_bit = 0;
	BCF         USBIF_bit+0, BitPos(USBIF_bit+0) 
;exec_unit.c,430 :: 		}
L_interrupt176:
;exec_unit.c,433 :: 		if ( TMR1IF_bit )
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_interrupt177
;exec_unit.c,435 :: 		TMR1IF_bit = 0;
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;exec_unit.c,436 :: 		TMR1H      = 0x0B;
	MOVLW       11
	MOVWF       TMR1H+0 
;exec_unit.c,437 :: 		TMR1L      = 0xD9;
	MOVLW       217
	MOVWF       TMR1L+0 
;exec_unit.c,439 :: 		motor_acceleration_control();
	CALL        _motor_acceleration_control+0, 0
;exec_unit.c,440 :: 		}
L_interrupt177:
;exec_unit.c,441 :: 		}
L_end_interrupt:
L__interrupt394:
	RETFIE      1
; end of _interrupt

_pc_data_exchange:

;exec_unit.c,444 :: 		void pc_data_exchange( )
;exec_unit.c,446 :: 		if ( USB_PWR_PIN )
	BTFSS       RD2_bit+0, BitPos(RD2_bit+0) 
	GOTO        L_pc_data_exchange178
;exec_unit.c,448 :: 		if ( !usb_state_on )   // Подключен USB кабель, включаем USB HID
	MOVF        _usb_state_on+0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange179
;exec_unit.c,450 :: 		usb_on();
	CALL        _usb_on+0, 0
;exec_unit.c,451 :: 		usb_state_on = TRUE;
	MOVLW       1
	MOVWF       _usb_state_on+0 
;exec_unit.c,452 :: 		}
L_pc_data_exchange179:
;exec_unit.c,453 :: 		}
	GOTO        L_pc_data_exchange180
L_pc_data_exchange178:
;exec_unit.c,456 :: 		if ( usb_state_on )    // Отключен USB кабель, выключаем USB HID
	MOVF        _usb_state_on+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange181
;exec_unit.c,458 :: 		usb_off();
	CALL        _usb_off+0, 0
;exec_unit.c,459 :: 		usb_state_on = FALSE;
	CLRF        _usb_state_on+0 
;exec_unit.c,460 :: 		}
L_pc_data_exchange181:
;exec_unit.c,461 :: 		}
L_pc_data_exchange180:
;exec_unit.c,463 :: 		if ( usb_state_on )
	MOVF        _usb_state_on+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange182
;exec_unit.c,465 :: 		if ( usb_read() )                                                       // Получили команду от ПК
	CALL        _usb_read+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange183
;exec_unit.c,467 :: 		struct s_cmd_header *head = (struct s_cmd_header *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_head_L2+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_head_L2+1 
;exec_unit.c,469 :: 		switch ( head->name )
	MOVF        pc_data_exchange_head_L2+0, 0 
	MOVWF       FLOC__pc_data_exchange+2 
	MOVF        pc_data_exchange_head_L2+1, 0 
	MOVWF       FLOC__pc_data_exchange+3 
	GOTO        L_pc_data_exchange184
;exec_unit.c,472 :: 		case CMD_EU_GET_UNIT_NUMBER:
L_pc_data_exchange186:
;exec_unit.c,474 :: 		struct s_eu_unit_number *rd = (struct s_eu_unit_number *)readbuff;
;exec_unit.c,475 :: 		struct s_eu_unit_number *wr = (struct s_eu_unit_number *)writebuff;
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4+1 
;exec_unit.c,477 :: 		wr->cmd.name   = CMD_EU_GET_UNIT_NUMBER;
	MOVFF       pc_data_exchange_wr_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4+1, FSR1H
	MOVLW       1
	MOVWF       POSTINC1+0 
;exec_unit.c,478 :: 		wr->number     = unit_number;                               // Номер блока
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4+1, 0 
	MOVWF       FSR1H 
	MOVF        _unit_number+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,479 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,481 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,484 :: 		case CMD_EU_SET_UNIT_NUMBER:
L_pc_data_exchange187:
;exec_unit.c,486 :: 		struct s_eu_unit_number *rd = (struct s_eu_unit_number *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_rd_L4_L4+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_rd_L4_L4+1 
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4+1 
;exec_unit.c,489 :: 		wr->cmd.name = CMD_EU_SET_UNIT_NUMBER;
	MOVFF       pc_data_exchange_wr_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4+1, FSR1H
	MOVLW       2
	MOVWF       POSTINC1+0 
;exec_unit.c,490 :: 		if ( rd->number >= 1 && rd->number <= 253 )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       1
	SUBWF       POSTINC0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_pc_data_exchange190
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	SUBLW       253
	BTFSS       STATUS+0, 0 
	GOTO        L_pc_data_exchange190
L__pc_data_exchange277:
;exec_unit.c,492 :: 		if ( write_config_byte(0x00, rd->number) )
	CLRF        FARG_write_config_byte_addr+0 
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_write_config_byte_dat+0 
	CALL        _write_config_byte+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange191
;exec_unit.c,494 :: 		unit_number    = rd->number;                            // Номер блока
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _unit_number+0 
;exec_unit.c,495 :: 		wr->cmd.result = CMD_RESULT_OK;                         // Успешно
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,496 :: 		reboot_needed  = TRUE;                                  // Требуется перезагрузка
	MOVLW       1
	MOVWF       _reboot_needed+0 
;exec_unit.c,497 :: 		}
	GOTO        L_pc_data_exchange192
L_pc_data_exchange191:
;exec_unit.c,500 :: 		wr->cmd.result = CMD_RESULT_EEPROM_WRITE_FAIL;          // Ошибка при записи EEPROM
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       6
	MOVWF       POSTINC1+0 
;exec_unit.c,501 :: 		}
L_pc_data_exchange192:
;exec_unit.c,502 :: 		}
	GOTO        L_pc_data_exchange193
L_pc_data_exchange190:
;exec_unit.c,505 :: 		wr->cmd.result = CMD_RESULT_BAD_INDEX;                       // Некорректный номер блока
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	MOVWF       POSTINC1+0 
;exec_unit.c,506 :: 		}
L_pc_data_exchange193:
;exec_unit.c,508 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,511 :: 		case CMD_EU_GET_SENSORS_STATE:
L_pc_data_exchange194:
;exec_unit.c,513 :: 		struct s_eu_sensors_state *rd = (struct s_eu_sensors_state *)readbuff;
;exec_unit.c,514 :: 		struct s_eu_sensors_state *wr = (struct s_eu_sensors_state *)writebuff;
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4+1 
;exec_unit.c,516 :: 		wr->cmd.name   = CMD_EU_GET_SENSORS_STATE;
	MOVFF       pc_data_exchange_wr_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4+1, FSR1H
	MOVLW       3
	MOVWF       POSTINC1+0 
;exec_unit.c,517 :: 		wr->count      = SENSORS_COUNT - protected_motors;          // Количество доступных датчиков
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVF        _protected_motors+0, 0 
	SUBLW       23
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,518 :: 		wr->state      = sensors_state;                             // Состояние датчиков
	MOVLW       3
	ADDWF       pc_data_exchange_wr_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVF        _sensors_state+0, 0 
	MOVWF       POSTINC1+0 
	MOVF        _sensors_state+1, 0 
	MOVWF       POSTINC1+0 
	MOVF        _sensors_state+2, 0 
	MOVWF       POSTINC1+0 
	MOVF        _sensors_state+3, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,519 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,521 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,524 :: 		case CMD_EU_GET_MOTORS_STATE:
L_pc_data_exchange195:
;exec_unit.c,526 :: 		struct s_eu_motors_state *rd = (struct s_eu_motors_state *)readbuff;
;exec_unit.c,527 :: 		struct s_eu_motors_state *wr = (struct s_eu_motors_state *)writebuff;
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4+1 
;exec_unit.c,529 :: 		wr->cmd.name   = CMD_EU_GET_MOTORS_STATE;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4+1, FSR1H
	MOVLW       4
	MOVWF       POSTINC1+0 
;exec_unit.c,530 :: 		wr->state      = (char)(motors_state & 0x000000ff);         // Состояние двигателей (вкл/выкл)
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       255
	ANDWF       _motors_state+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,531 :: 		wr->protect    = motor_get_protect_mask(protected_motors);  // Состоние защиты (используется/не используется)
	MOVLW       3
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4+0, 0 
	MOVWF       FLOC__pc_data_exchange+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4+1, 0 
	MOVWF       FLOC__pc_data_exchange+1 
	MOVF        _protected_motors+0, 0 
	MOVWF       FARG_motor_get_protect_mask_count+0 
	CALL        _motor_get_protect_mask+0, 0
	MOVFF       FLOC__pc_data_exchange+0, FSR1
	MOVFF       FLOC__pc_data_exchange+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,532 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,534 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,537 :: 		case CMD_EU_GET_MOTOR_CONFIG:
L_pc_data_exchange196:
;exec_unit.c,539 :: 		struct s_eu_motor_config *rd = (struct s_eu_motor_config *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+1 
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+1 
;exec_unit.c,542 :: 		wr->cmd.name   = CMD_EU_GET_MOTOR_CONFIG;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       5
	MOVWF       POSTINC1+0 
;exec_unit.c,543 :: 		if ( rd->number >= 0 && rd->number < 8 )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       0
	SUBWF       POSTINC0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_pc_data_exchange199
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       8
	SUBWF       POSTINC0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange199
L__pc_data_exchange276:
;exec_unit.c,545 :: 		wr->number     = rd->number;
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,546 :: 		wr->state      = (motors_state & (1 << rd->number)) ? TRUE : FALSE;   // Вкл/Выкл
	MOVLW       3
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R4 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R5 
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       R2 
	MOVLW       1
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange396:
	BZ          L__pc_data_exchange397
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange396
L__pc_data_exchange397:
	MOVLW       0
	BTFSC       R1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	MOVF        _motors_state+0, 0 
	ANDWF       R0, 1 
	MOVF        _motors_state+1, 0 
	ANDWF       R1, 1 
	MOVF        _motors_state+2, 0 
	ANDWF       R2, 1 
	MOVF        _motors_state+3, 0 
	ANDWF       R3, 1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	IORWF       R2, 0 
	IORWF       R3, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange200
	MOVLW       1
	MOVWF       ?FLOC___pc_data_exchangeT576+0 
	GOTO        L_pc_data_exchange201
L_pc_data_exchange200:
	CLRF        ?FLOC___pc_data_exchangeT576+0 
L_pc_data_exchange201:
	MOVFF       R4, FSR1
	MOVFF       R5, FSR1H
	MOVF        ?FLOC___pc_data_exchangeT576+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,547 :: 		wr->protect    = motors[rd->number].protect;                          // Используется/Не используется
	MOVLW       4
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R3 
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange398:
	BZ          L__pc_data_exchange399
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange398
L__pc_data_exchange399:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,548 :: 		wr->start_time = motors[rd->number].start_time / 10;                  // Время разгона
	MOVLW       5
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FLOC__pc_data_exchange+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FLOC__pc_data_exchange+1 
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R3 
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange400:
	BZ          L__pc_data_exchange401
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange400
L__pc_data_exchange401:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Div_16X16_U+0, 0
	MOVFF       FLOC__pc_data_exchange+0, FSR1
	MOVFF       FLOC__pc_data_exchange+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,549 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,550 :: 		}
	GOTO        L_pc_data_exchange202
L_pc_data_exchange199:
;exec_unit.c,553 :: 		wr->cmd.result = CMD_RESULT_BAD_INDEX;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	MOVWF       POSTINC1+0 
;exec_unit.c,554 :: 		}
L_pc_data_exchange202:
;exec_unit.c,556 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,559 :: 		case CMD_EU_SET_MOTOR_CONFIG:
L_pc_data_exchange203:
;exec_unit.c,561 :: 		struct s_eu_motor_config *rd = (struct s_eu_motor_config *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1 
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,564 :: 		wr->cmd.name = CMD_EU_SET_MOTOR_CONFIG;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       6
	MOVWF       POSTINC1+0 
;exec_unit.c,565 :: 		if ( rd->number >= 0 && rd->number < 8 )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       0
	SUBWF       POSTINC0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_pc_data_exchange206
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       8
	SUBWF       POSTINC0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange206
L__pc_data_exchange275:
;exec_unit.c,567 :: 		char i, enable = TRUE;
	MOVLW       1
	MOVWF       pc_data_exchange_enable_L5+0 
;exec_unit.c,570 :: 		if ( rd->protect )
	MOVLW       4
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange207
;exec_unit.c,572 :: 		for ( i = 0; i < rd->number; ++i )
	CLRF        pc_data_exchange_i_L5+0 
L_pc_data_exchange208:
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	SUBWF       pc_data_exchange_i_L5+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange209
;exec_unit.c,573 :: 		if ( !motors[i].protect )
	MOVLW       3
	MOVWF       R2 
	MOVF        pc_data_exchange_i_L5+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange402:
	BZ          L__pc_data_exchange403
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange402
L__pc_data_exchange403:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange211
;exec_unit.c,574 :: 		enable = FALSE;
	CLRF        pc_data_exchange_enable_L5+0 
L_pc_data_exchange211:
;exec_unit.c,572 :: 		for ( i = 0; i < rd->number; ++i )
	INCF        pc_data_exchange_i_L5+0, 1 
;exec_unit.c,574 :: 		enable = FALSE;
	GOTO        L_pc_data_exchange208
L_pc_data_exchange209:
;exec_unit.c,575 :: 		}
	GOTO        L_pc_data_exchange212
L_pc_data_exchange207:
;exec_unit.c,578 :: 		for ( i = 8 - 1; i > rd->number; --i )
	MOVLW       7
	MOVWF       pc_data_exchange_i_L5+0 
L_pc_data_exchange213:
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR2H 
	MOVF        pc_data_exchange_i_L5+0, 0 
	SUBWF       POSTINC2+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange214
;exec_unit.c,579 :: 		if ( motors[i].protect )
	MOVLW       3
	MOVWF       R2 
	MOVF        pc_data_exchange_i_L5+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange404:
	BZ          L__pc_data_exchange405
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange404
L__pc_data_exchange405:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange216
;exec_unit.c,580 :: 		enable = FALSE;
	CLRF        pc_data_exchange_enable_L5+0 
L_pc_data_exchange216:
;exec_unit.c,578 :: 		for ( i = 8 - 1; i > rd->number; --i )
	DECF        pc_data_exchange_i_L5+0, 1 
;exec_unit.c,580 :: 		enable = FALSE;
	GOTO        L_pc_data_exchange213
L_pc_data_exchange214:
;exec_unit.c,581 :: 		}
L_pc_data_exchange212:
;exec_unit.c,584 :: 		if ( enable )
	MOVF        pc_data_exchange_enable_L5+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange217
;exec_unit.c,586 :: 		motor_stop(rd->number, FALSE);                       // Останавливаем двигатель
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_motor_stop_number+0 
	CLRF        FARG_motor_stop_failure+0 
	CALL        _motor_stop+0, 0
;exec_unit.c,588 :: 		if ( write_config_byte(0x01 + (rd->number * 3), rd->protect) && write_config_word(0x02 + (rd->number * 3), rd->start_time * 10) )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVLW       3
	MULWF       R0 
	MOVF        PRODL+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	ADDLW       1
	MOVWF       FARG_write_config_byte_addr+0 
	MOVLW       4
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_write_config_byte_dat+0 
	CALL        _write_config_byte+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange220
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVLW       3
	MULWF       R0 
	MOVF        PRODL+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	ADDLW       2
	MOVWF       FARG_write_config_word_addr+0 
	MOVLW       5
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Mul_16X16_U+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_write_config_word_dat+0 
	MOVF        R1, 0 
	MOVWF       FARG_write_config_word_dat+1 
	CALL        _write_config_word+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange220
L__pc_data_exchange274:
;exec_unit.c,590 :: 		motors[rd->number].protect = rd->protect;            // Защита
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R3 
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange406:
	BZ          L__pc_data_exchange407
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange406
L__pc_data_exchange407:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,591 :: 		motors[rd->number].start_time = rd->start_time * 10; // Время разгона
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R3 
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange408:
	BZ          L__pc_data_exchange409
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange408
L__pc_data_exchange409:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FLOC__pc_data_exchange+0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FLOC__pc_data_exchange+1 
	MOVLW       5
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Mul_16X16_U+0, 0
	MOVFF       FLOC__pc_data_exchange+0, FSR1
	MOVFF       FLOC__pc_data_exchange+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,593 :: 		protected_motors = motor_get_protected();            // Устанавливаем количество контролируемых двигателей
	CALL        _motor_get_protected+0, 0
	MOVF        R0, 0 
	MOVWF       _protected_motors+0 
;exec_unit.c,595 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,596 :: 		}
	GOTO        L_pc_data_exchange221
L_pc_data_exchange220:
;exec_unit.c,599 :: 		wr->cmd.result = CMD_RESULT_EEPROM_WRITE_FAIL;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       6
	MOVWF       POSTINC1+0 
;exec_unit.c,600 :: 		}
L_pc_data_exchange221:
;exec_unit.c,601 :: 		}
	GOTO        L_pc_data_exchange222
L_pc_data_exchange217:
;exec_unit.c,604 :: 		wr->cmd.result = CMD_RESULT_BAD_PROTECT_ORDER;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       5
	MOVWF       POSTINC1+0 
;exec_unit.c,605 :: 		}
L_pc_data_exchange222:
;exec_unit.c,606 :: 		}
	GOTO        L_pc_data_exchange223
L_pc_data_exchange206:
;exec_unit.c,609 :: 		wr->cmd.result = CMD_RESULT_BAD_INDEX;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	MOVWF       POSTINC1+0 
;exec_unit.c,610 :: 		}
L_pc_data_exchange223:
;exec_unit.c,612 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,615 :: 		case CMD_EU_GET_MOTOR_STATE:
L_pc_data_exchange224:
;exec_unit.c,617 :: 		struct s_eu_motor_state *rd = (struct s_eu_motor_state *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+1 
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,620 :: 		wr->cmd.name = CMD_EU_GET_MOTOR_STATE;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       7
	MOVWF       POSTINC1+0 
;exec_unit.c,621 :: 		if ( rd->number >= 0 && rd->number < 8 )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       0
	SUBWF       POSTINC0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_pc_data_exchange227
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       8
	SUBWF       POSTINC0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange227
L__pc_data_exchange273:
;exec_unit.c,623 :: 		wr->state = (motors_state & (1 << rd->number)) ? TRUE : FALSE;  // Состояние двигателя
	MOVLW       3
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R4 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R5 
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       R2 
	MOVLW       1
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange410:
	BZ          L__pc_data_exchange411
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange410
L__pc_data_exchange411:
	MOVLW       0
	BTFSC       R1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	MOVF        _motors_state+0, 0 
	ANDWF       R0, 1 
	MOVF        _motors_state+1, 0 
	ANDWF       R1, 1 
	MOVF        _motors_state+2, 0 
	ANDWF       R2, 1 
	MOVF        _motors_state+3, 0 
	ANDWF       R3, 1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	IORWF       R2, 0 
	IORWF       R3, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange228
	MOVLW       1
	MOVWF       ?FLOC___pc_data_exchangeT799+0 
	GOTO        L_pc_data_exchange229
L_pc_data_exchange228:
	CLRF        ?FLOC___pc_data_exchangeT799+0 
L_pc_data_exchange229:
	MOVFF       R4, FSR1
	MOVFF       R5, FSR1H
	MOVF        ?FLOC___pc_data_exchangeT799+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,624 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,625 :: 		}
	GOTO        L_pc_data_exchange230
L_pc_data_exchange227:
;exec_unit.c,628 :: 		wr->cmd.result = CMD_RESULT_BAD_INDEX;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	MOVWF       POSTINC1+0 
;exec_unit.c,629 :: 		}
L_pc_data_exchange230:
;exec_unit.c,631 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,634 :: 		case CMD_EU_SET_MOTOR_STATE:
L_pc_data_exchange231:
;exec_unit.c,636 :: 		struct s_eu_motor_state *rd = (struct s_eu_motor_state *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+1 
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,639 :: 		wr->cmd.name = CMD_EU_SET_MOTOR_STATE;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       8
	MOVWF       POSTINC1+0 
;exec_unit.c,640 :: 		if ( rd->number >= 0 && rd->number < 8 )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       0
	SUBWF       POSTINC0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_pc_data_exchange234
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVLW       8
	SUBWF       POSTINC0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange234
L__pc_data_exchange272:
;exec_unit.c,642 :: 		if ( rd->state )
	MOVLW       3
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange235
;exec_unit.c,643 :: 		motor_start(rd->number);                            // Запуск
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_motor_start_number+0 
	CALL        _motor_start+0, 0
	GOTO        L_pc_data_exchange236
L_pc_data_exchange235:
;exec_unit.c,645 :: 		motor_stop(rd->number, FALSE);                      // Остановка
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_motor_stop_number+0 
	CLRF        FARG_motor_stop_failure+0 
	CALL        _motor_stop+0, 0
L_pc_data_exchange236:
;exec_unit.c,647 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,648 :: 		}
	GOTO        L_pc_data_exchange237
L_pc_data_exchange234:
;exec_unit.c,651 :: 		wr->cmd.result = CMD_RESULT_BAD_INDEX;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	MOVWF       POSTINC1+0 
;exec_unit.c,652 :: 		}
L_pc_data_exchange237:
;exec_unit.c,654 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,657 :: 		case CMD_EU_GET_UNIT_STATE:
L_pc_data_exchange238:
;exec_unit.c,659 :: 		struct s_eu_unit_state *rd = (struct s_eu_unit_state *)readbuff;
;exec_unit.c,660 :: 		struct s_eu_unit_state *wr = (struct s_eu_unit_state *)writebuff;
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,662 :: 		wr->cmd.name   = CMD_EU_GET_UNIT_STATE;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       9
	MOVWF       POSTINC1+0 
;exec_unit.c,663 :: 		wr->state      = is_connected;                              // Состояние блока
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVF        _is_connected+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,664 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,666 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,669 :: 		case CMD_EU_LOAD_CONFIG:
L_pc_data_exchange239:
;exec_unit.c,671 :: 		struct s_eu_config_data *rd = (struct s_eu_config_data *)readbuff;
	MOVLW       _readbuff+0
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1 
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,674 :: 		wr->cmd.name = CMD_EU_LOAD_CONFIG;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       10
	MOVWF       POSTINC1+0 
;exec_unit.c,676 :: 		if ( !(rd->magic[0] == 'E' && rd->magic[1] == 'C' && rd->magic[2] == 'O' && rd->magic[3] == 'N' && rd->magic[4] == 'F') )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       69
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange241
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       67
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange241
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       79
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange241
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       78
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange241
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       4
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       70
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange241
	MOVLW       1
	MOVWF       R0 
	GOTO        L_pc_data_exchange240
L_pc_data_exchange241:
	CLRF        R0 
L_pc_data_exchange240:
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange242
;exec_unit.c,678 :: 		wr->cmd.result = CMD_RESULT_BAD_FORMAT;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       8
	MOVWF       POSTINC1+0 
;exec_unit.c,679 :: 		}
	GOTO        L_pc_data_exchange243
L_pc_data_exchange242:
;exec_unit.c,682 :: 		if ( crc16(rd->magic, 30) == rd->check_sum )
	MOVLW       2
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FARG_crc16_block+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FARG_crc16_block+1 
	MOVLW       30
	MOVWF       FARG_crc16_len+0 
	MOVLW       0
	MOVWF       FARG_crc16_len+1 
	CALL        _crc16+0, 0
	MOVLW       32
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	MOVWF       R2 
	MOVF        POSTINC2+0, 0 
	MOVWF       R3 
	MOVLW       0
	XORWF       R3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__pc_data_exchange412
	MOVF        R2, 0 
	XORWF       R0, 0 
L__pc_data_exchange412:
	BTFSS       STATUS+0, 2 
	GOTO        L_pc_data_exchange244
;exec_unit.c,684 :: 		uchar res = TRUE;
	MOVLW       1
	MOVWF       pc_data_exchange_res_L6+0 
;exec_unit.c,688 :: 		res = write_config_byte(0x00, rd->number);
	CLRF        FARG_write_config_byte_addr+0 
	MOVLW       7
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_write_config_byte_dat+0 
	CALL        _write_config_byte+0, 0
	MOVF        R0, 0 
	MOVWF       pc_data_exchange_res_L6+0 
;exec_unit.c,690 :: 		p = rd->protect;
	MOVLW       8
	ADDWF       pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       pc_data_exchange_p_L6+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_rd_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       pc_data_exchange_p_L6+1 
;exec_unit.c,691 :: 		for ( i = 0; i < 24; i += 3 )
	CLRF        pc_data_exchange_i_L6+0 
L_pc_data_exchange245:
	MOVLW       24
	SUBWF       pc_data_exchange_i_L6+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange246
;exec_unit.c,693 :: 		res &= write_config_byte(0x01 + i, *(uchar *)p);
	MOVF        pc_data_exchange_i_L6+0, 0 
	ADDLW       1
	MOVWF       FARG_write_config_byte_addr+0 
	MOVFF       pc_data_exchange_p_L6+0, FSR0
	MOVFF       pc_data_exchange_p_L6+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_write_config_byte_dat+0 
	CALL        _write_config_byte+0, 0
	MOVF        R0, 0 
	ANDWF       pc_data_exchange_res_L6+0, 1 
;exec_unit.c,694 :: 		p += 1;
	INFSNZ      pc_data_exchange_p_L6+0, 1 
	INCF        pc_data_exchange_p_L6+1, 1 
;exec_unit.c,695 :: 		res &= write_config_word(0x02 + i, *(ushort *)p);
	MOVF        pc_data_exchange_i_L6+0, 0 
	ADDLW       2
	MOVWF       FARG_write_config_word_addr+0 
	MOVFF       pc_data_exchange_p_L6+0, FSR0
	MOVFF       pc_data_exchange_p_L6+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_write_config_word_dat+0 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_write_config_word_dat+1 
	CALL        _write_config_word+0, 0
	MOVF        R0, 0 
	ANDWF       pc_data_exchange_res_L6+0, 1 
;exec_unit.c,696 :: 		p += 2;
	MOVLW       2
	ADDWF       pc_data_exchange_p_L6+0, 1 
	MOVLW       0
	ADDWFC      pc_data_exchange_p_L6+1, 1 
;exec_unit.c,691 :: 		for ( i = 0; i < 24; i += 3 )
	MOVLW       3
	ADDWF       pc_data_exchange_i_L6+0, 1 
;exec_unit.c,697 :: 		}
	GOTO        L_pc_data_exchange245
L_pc_data_exchange246:
;exec_unit.c,699 :: 		if ( res )
	MOVF        pc_data_exchange_res_L6+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange248
;exec_unit.c,701 :: 		wr->cmd.result = CMD_RESULT_OK;                 // Успешно
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,702 :: 		reboot_needed  = TRUE;                          // Требуется перезагрузка
	MOVLW       1
	MOVWF       _reboot_needed+0 
;exec_unit.c,703 :: 		}
	GOTO        L_pc_data_exchange249
L_pc_data_exchange248:
;exec_unit.c,705 :: 		wr->cmd.result = CMD_RESULT_EEPROM_WRITE_FAIL;  // Ошибка при записи EEPROM
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       6
	MOVWF       POSTINC1+0 
L_pc_data_exchange249:
;exec_unit.c,706 :: 		}
	GOTO        L_pc_data_exchange250
L_pc_data_exchange244:
;exec_unit.c,709 :: 		wr->cmd.result = CMD_RESULT_BAD_CHECK_SUM;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       9
	MOVWF       POSTINC1+0 
;exec_unit.c,710 :: 		}
L_pc_data_exchange250:
;exec_unit.c,711 :: 		}
L_pc_data_exchange243:
;exec_unit.c,713 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,716 :: 		case CMD_EU_SAVE_CONFIG:
L_pc_data_exchange251:
;exec_unit.c,718 :: 		struct s_eu_config_data *rd = (struct s_eu_config_data *)readbuff;
;exec_unit.c,719 :: 		struct s_eu_config_data *wr = (struct s_eu_config_data *)writebuff;
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,723 :: 		wr->cmd.name = CMD_EU_SAVE_CONFIG;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, FSR1H
	MOVLW       11
	MOVWF       POSTINC1+0 
;exec_unit.c,725 :: 		wr->magic[0] = 'E';
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       69
	MOVWF       POSTINC1+0 
;exec_unit.c,726 :: 		wr->magic[1] = 'C';
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       67
	MOVWF       POSTINC1+0 
;exec_unit.c,727 :: 		wr->magic[2] = 'O';
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       79
	MOVWF       POSTINC1+0 
;exec_unit.c,728 :: 		wr->magic[3] = 'N';
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       78
	MOVWF       POSTINC1+0 
;exec_unit.c,729 :: 		wr->magic[4] = 'F';
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       R1 
	MOVLW       4
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       70
	MOVWF       POSTINC1+0 
;exec_unit.c,730 :: 		wr->number   = unit_number;
	MOVLW       7
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVF        _unit_number+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,732 :: 		p = wr->protect;
	MOVLW       8
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       pc_data_exchange_p_L4+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       pc_data_exchange_p_L4+1 
;exec_unit.c,733 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	CLRF        pc_data_exchange_i_L4+0 
L_pc_data_exchange252:
	MOVLW       8
	SUBWF       pc_data_exchange_i_L4+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_pc_data_exchange253
;exec_unit.c,735 :: 		*(uchar *)p  = motors[i].protect;
	MOVLW       3
	MOVWF       R2 
	MOVF        pc_data_exchange_i_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange413:
	BZ          L__pc_data_exchange414
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange413
L__pc_data_exchange414:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVFF       pc_data_exchange_p_L4+0, FSR1
	MOVFF       pc_data_exchange_p_L4+1, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,736 :: 		p += 1;
	INFSNZ      pc_data_exchange_p_L4+0, 1 
	INCF        pc_data_exchange_p_L4+1, 1 
;exec_unit.c,737 :: 		*(ushort *)p = motors[i].start_time;
	MOVLW       3
	MOVWF       R2 
	MOVF        pc_data_exchange_i_L4+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVF        R2, 0 
L__pc_data_exchange415:
	BZ          L__pc_data_exchange416
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__pc_data_exchange415
L__pc_data_exchange416:
	MOVLW       _motors+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_motors+0)
	ADDWFC      R1, 1 
	MOVLW       3
	ADDWF       R0, 1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVFF       pc_data_exchange_p_L4+0, FSR1
	MOVFF       pc_data_exchange_p_L4+1, FSR1H
	MOVFF       R0, FSR0
	MOVFF       R1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;exec_unit.c,738 :: 		p += 2;
	MOVLW       2
	ADDWF       pc_data_exchange_p_L4+0, 1 
	MOVLW       0
	ADDWFC      pc_data_exchange_p_L4+1, 1 
;exec_unit.c,733 :: 		for ( i = 0; i < MOTOR_MAX; ++i )
	INCF        pc_data_exchange_i_L4+0, 1 
;exec_unit.c,739 :: 		}
	GOTO        L_pc_data_exchange252
L_pc_data_exchange253:
;exec_unit.c,741 :: 		wr->check_sum = crc16(wr->magic, 30);                       // Рассчитываем контрольную сумму, начиная с magic
	MOVLW       32
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FLOC__pc_data_exchange+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FLOC__pc_data_exchange+1 
	MOVLW       2
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FARG_crc16_block+0 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FARG_crc16_block+1 
	MOVLW       30
	MOVWF       FARG_crc16_len+0 
	MOVLW       0
	MOVWF       FARG_crc16_len+1 
	CALL        _crc16+0, 0
	MOVFF       FLOC__pc_data_exchange+0, FSR1
	MOVFF       FLOC__pc_data_exchange+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVLW       0
	MOVWF       POSTINC1+0 
;exec_unit.c,743 :: 		wr->cmd.result = CMD_RESULT_OK;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;exec_unit.c,745 :: 		break;
	GOTO        L_pc_data_exchange185
;exec_unit.c,748 :: 		default:
L_pc_data_exchange255:
;exec_unit.c,750 :: 		struct s_cmd_header *wr = (struct s_cmd_header *)writebuff;
	MOVLW       _writebuff+0
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1 
;exec_unit.c,751 :: 		memset(writebuff, 0, USB_REPORT_SIZE);
	MOVLW       _writebuff+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       64
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;exec_unit.c,752 :: 		wr->name = CMD_EU_UNKNOWN;
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, FSR1
	MOVFF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, FSR1H
	CLRF        POSTINC1+0 
;exec_unit.c,753 :: 		wr->result = CMD_RESULT_FAIL;
	MOVLW       1
	ADDWF       pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      pc_data_exchange_wr_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4_L4+1, 0 
	MOVWF       FSR1H 
	MOVLW       1
	MOVWF       POSTINC1+0 
;exec_unit.c,755 :: 		}
	GOTO        L_pc_data_exchange185
L_pc_data_exchange184:
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange186
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange187
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       3
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange194
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       4
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange195
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       5
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange196
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange203
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange224
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       8
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange231
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       9
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange238
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange239
	MOVFF       FLOC__pc_data_exchange+2, FSR0
	MOVFF       FLOC__pc_data_exchange+3, FSR0H
	MOVF        POSTINC0+0, 0 
	XORLW       11
	BTFSC       STATUS+0, 2 
	GOTO        L_pc_data_exchange251
	GOTO        L_pc_data_exchange255
L_pc_data_exchange185:
;exec_unit.c,757 :: 		usb_write();                                                        // Передача команды в ПК
	CALL        _usb_write+0, 0
;exec_unit.c,758 :: 		}
L_pc_data_exchange183:
;exec_unit.c,759 :: 		}
L_pc_data_exchange182:
;exec_unit.c,760 :: 		}
L_end_pc_data_exchange:
	RETURN      0
; end of _pc_data_exchange

_reboot_check:

;exec_unit.c,763 :: 		void reboot_check( )
;exec_unit.c,765 :: 		if ( reboot_needed )
	MOVF        _reboot_needed+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_reboot_check256
;exec_unit.c,768 :: 		if ( usb_state_on )
	MOVF        _usb_state_on+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_reboot_check257
;exec_unit.c,769 :: 		usb_off();
	CALL        _usb_off+0, 0
L_reboot_check257:
;exec_unit.c,772 :: 		delay_ms(1000);
	MOVLW       26
	MOVWF       R11, 0
	MOVLW       94
	MOVWF       R12, 0
	MOVLW       110
	MOVWF       R13, 0
L_reboot_check258:
	DECFSZ      R13, 1, 1
	BRA         L_reboot_check258
	DECFSZ      R12, 1, 1
	BRA         L_reboot_check258
	DECFSZ      R11, 1, 1
	BRA         L_reboot_check258
	NOP
;exec_unit.c,775 :: 		__asm reset
	RESET
;exec_unit.c,776 :: 		}
L_reboot_check256:
;exec_unit.c,777 :: 		}
L_end_reboot_check:
	RETURN      0
; end of _reboot_check

_main:

;exec_unit.c,780 :: 		void main()
;exec_unit.c,782 :: 		delay_ms(1000);                                                             // Ждем инициализации остальных компонентов
	MOVLW       26
	MOVWF       R11, 0
	MOVLW       94
	MOVWF       R12, 0
	MOVLW       110
	MOVWF       R13, 0
L_main259:
	DECFSZ      R13, 1, 1
	BRA         L_main259
	DECFSZ      R12, 1, 1
	BRA         L_main259
	DECFSZ      R11, 1, 1
	BRA         L_main259
	NOP
;exec_unit.c,784 :: 		init();                                                                     // Общая инициализация
	CALL        _init+0, 0
;exec_unit.c,786 :: 		transceiver_init();                                                         // Приемопередатчик
	CALL        _transceiver_init+0, 0
;exec_unit.c,788 :: 		hc165_init();                                                               // HC165
	CALL        _hc165_init+0, 0
;exec_unit.c,790 :: 		motor_init();                                                               // Двигатели
	CALL        _motor_init+0, 0
;exec_unit.c,792 :: 		load_config();                                                              // Загрузка конфигурации
	CALL        _load_config+0, 0
;exec_unit.c,794 :: 		timer1_init();
	CALL        _timer1_init+0, 0
;exec_unit.c,796 :: 		net_init(5);                                                                // Сеть
	MOVLW       5
	MOVWF       FARG_net_init_send_attempts+0 
	CALL        _net_init+0, 0
;exec_unit.c,798 :: 		net_set_params(unit_number, 20);                                            // Установка параметров приемопередатчика
	MOVF        _unit_number+0, 0 
	MOVWF       FARG_net_set_params_addr+0 
	MOVLW       20
	MOVWF       FARG_net_set_params_ack_wait_time+0 
	CALL        _net_set_params+0, 0
;exec_unit.c,801 :: 		INTCON.GIE  = 1;
	BSF         INTCON+0, 7 
;exec_unit.c,802 :: 		INTCON.PEIE = 1;
	BSF         INTCON+0, 6 
;exec_unit.c,804 :: 		while ( TRUE )
L_main260:
;exec_unit.c,807 :: 		exec_commands();
	CALL        _exec_commands+0, 0
;exec_unit.c,810 :: 		if ( motor_read(&motors_state) || changes )
	MOVLW       _motors_state+0
	MOVWF       FARG_motor_read_state+0 
	MOVLW       hi_addr(_motors_state+0)
	MOVWF       FARG_motor_read_state+1 
	CALL        _motor_read+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L__main279
	MOVF        _changes+0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L__main279
	GOTO        L_main264
L__main279:
;exec_unit.c,811 :: 		if ( net_send(SERVER_ADDRESS, NET_CMD_MOTORS_STATE, (uchar *)&motors_state, 0) == 0 )
	MOVLW       254
	MOVWF       FARG_net_send_addr+0 
	MOVLW       12
	MOVWF       FARG_net_send_cmd+0 
	MOVLW       _motors_state+0
	MOVWF       FARG_net_send_dat+0 
	MOVLW       hi_addr(_motors_state+0)
	MOVWF       FARG_net_send_dat+1 
	CLRF        FARG_net_send_attempts+0 
	CALL        _net_send+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main265
;exec_unit.c,812 :: 		motor_reset_fail_state(); // Если команда о состоянии двигателей успешно отправлена, сбрасываем аварийное состояние двигателей
	CALL        _motor_reset_fail_state+0, 0
L_main265:
L_main264:
;exec_unit.c,815 :: 		if ( sensors_read(&sensors_state) || changes )
	MOVLW       _sensors_state+0
	MOVWF       FARG_sensors_read_state+0 
	MOVLW       hi_addr(_sensors_state+0)
	MOVWF       FARG_sensors_read_state+1 
	CALL        _sensors_read+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L__main278
	MOVF        _changes+0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L__main278
	GOTO        L_main268
L__main278:
;exec_unit.c,816 :: 		net_send(SERVER_ADDRESS, NET_CMD_SENSORS_STATE, (uchar *)&sensors_state, 0);
	MOVLW       254
	MOVWF       FARG_net_send_addr+0 
	MOVLW       10
	MOVWF       FARG_net_send_cmd+0 
	MOVLW       _sensors_state+0
	MOVWF       FARG_net_send_dat+0 
	MOVLW       hi_addr(_sensors_state+0)
	MOVWF       FARG_net_send_dat+1 
	CLRF        FARG_net_send_attempts+0 
	CALL        _net_send+0, 0
L_main268:
;exec_unit.c,819 :: 		motor_protect_control();
	CALL        _motor_protect_control+0, 0
;exec_unit.c,822 :: 		pc_data_exchange();
	CALL        _pc_data_exchange+0, 0
;exec_unit.c,825 :: 		changes = FALSE;
	CLRF        _changes+0 
;exec_unit.c,828 :: 		reboot_check();
	CALL        _reboot_check+0, 0
;exec_unit.c,829 :: 		}
	GOTO        L_main260
;exec_unit.c,830 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
