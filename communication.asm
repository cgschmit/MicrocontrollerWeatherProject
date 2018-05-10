; file	i2cx.asm		: extended I2C (400kHz)
; copyright (c) 2001-2002 R.Holzer

; === definitions ===
.equ	SDA_port= PORTE
.equ	SDA_pin	= 3
.equ	SCL_port= PORTE
.equ	SCL_pin	= 5

; === macros ===
; these macros control DDRx to simulate an open collector
; with external pull-up resistors

.macro	SCL0
	sbi	SCL_port-1,SCL_pin 	; pull SCL low (output, port=0)
	.endmacro
.macro	SCL1
	cbi	SCL_port-1,SCL_pin 	; release SCL (input, hi Z)
	.endmacro
.macro	SDA0
	sbi	SDA_port-1,SDA_pin 	; pull SDA low (output, port=0)
	.endmacro
.macro	SDA1
	cbi	SDA_port-1,SDA_pin 	; release SDA (input, hi Z)
	.endmacro

.macro	WIRE2_BIT_OUT	;bit
	sbi	SCL_port-1,SCL_pin 	; pull SCL low (output, port=0)
	in	w,SDA_port-1		; sample the SDA line
	bst	a0,@0			; store a0(bit) to T
	bld	w,SDA_pin		; load w(SDA) with T
	out	SDA_port-1,w		; transfer bit_x to SDA
	cbi	SCL_port-1,SCL_pin 	; release SCL (input, hi Z)
	rjmp	PC+1			; wait 2 cyles
	.endmacro

.macro	WIRE2_BIT_IN	;bit
	sbi	SCL_port-1,SCL_pin 	; DDRx=output	SCL=0
	cbi	SDA_port-1,SDA_pin 	; release SDA (input, hi Z)	
	cbi	SCL_port-1,SCL_pin 	; DDRx=input	SCL=1
	nop				; wait 1 cycle
	in	w,SDA_port-2		; PINx=PORTx-2
	bst	w,SDA_pin		; store bit read in T
	bld	a0,@0			; load a0(bit) from T
	.endmacro

; === routines ===
wire2_init:
	cbi	SDA_port,  SDA_pin	; PORTx=0 (for pull-down)
	cbi	SCL_port,  SCL_pin	; PORTx=0 (for pull-down)
	SDA1			; release SDA
	SCL0			
	ret

wire2_rep_start:
; in: 	a0 (byte to transmit)
	SCL0
	SDA1
	SCL1
	
wire2_start:
; in: 	a0 (byte to transmit)

;        _____          _____
;  DATA       \________/
;
;           ____     ____
;   SCL  __/    \___/    \___
;
;

	SDA1
	SCL0
	nop
	
	SDA1
	SCL1
	nop

	SDA0
	nop

		; pour laisser un temps d'attente
	SCL0	
	nop
			; idem
	SCL1
	nop

	SDA1
	nop
	
	SCL0	

wire2_write:
	com	a0		; invert a0
	WIRE2_BIT_OUT 7
	WIRE2_BIT_OUT 6
	WIRE2_BIT_OUT 5
	WIRE2_BIT_OUT 4
	WIRE2_BIT_OUT 3
	WIRE2_BIT_OUT 2
	WIRE2_BIT_OUT 1
	WIRE2_BIT_OUT 0
	com	a0		; restore a0
	
wire2_ack_in:

	SCL0
	SDA1
	nop			; release SDA
	SCL1
	in	w,SDA_port-2	; PINx=PORTx-2
	bst	w,SDA_pin	; store ACK into T
	SCL0
	SDA1
	ret


wire2_read:
; out: 	a0 (byte read)
	WIRE2_BIT_IN 7
	WIRE2_BIT_IN 6
	WIRE2_BIT_IN 5
	WIRE2_BIT_IN 4
	WIRE2_BIT_IN 3
	WIRE2_BIT_IN 2
	WIRE2_BIT_IN 1
	WIRE2_BIT_IN 0
	ret
	
wire2_ack:
;        ____        		Acknowledge écrit sur la Ligne DATA par le microcontroleur 
;  DATA      \______	
;
;        ___   ___
;   SCL     \_/   \_
;
	SDA1
	SCL0
	SDA0
	SCL1
	nop
	SCL0
	SDA1
	ret

	
wire2_no_ack:
;             _______  		pas de Acknowledge.
;  DATA  ____/	
;
;        ___   ___
;   SCL     \_/   \_
	
	SCL0
	SDA1
	SCL1
	nop
	SCL0
	ret


wire2_stop:
	SCL0
	SDA0
	SCL1
	SDA1			; release again
	ret