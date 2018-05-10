.include "m103def.inc"
.include "macros.asm"
.include "definitions.asm"

;=====================================================
;CONSTANTES
;=====================================================
	
.def	RegTempLow 	= 	r6
.def	RegTempHigh 	=	r7
.def	RegHumidityLow 	=	r26
.def	RegHumidityHigh =	r27
.def	CompteurRegistre=	r28
.def	erreur		= 	r29	
	
.equ	MesureTemp	=	0b00000011
.equ	MesureHum	=	0b00000101


;=====================================================
;INTERRUPTIONS
;=====================================================
.org 0
	jmp reset
.org INT2addr
	jmp modification_valeurs

.include "lcd.asm"
.include "printf.asm"
.include "math.asm"
.include "communication.asm"
.include "menu_modifier_valeurs_ref.asm"
.include "conversions_mesures.asm"
.include "comparaison_valeurs_ref.asm"
.include "affichage_et_led.asm"

;=====================================================
;RESET
;=====================================================

reset:
	LDSP RAMEND
	rcall 	LCD_init
	rcall	LCD_clear
	rcall	LCD_home			;affichage de la temperature	
	PRINTF	LCD_putc
	.db	"INITIALISATION",0 ;juste	
	rcall	wire2_init
	
	_LDI	RegTempLow,0b00110011		;on initialise les valeurs de references
	_LDI	RegTempHigh,0b00111111
	ldi	RegHumidityLow,0b00110011
	ldi	RegHumidityHigh,0b01111111	
	ldi	CompteurRegistre,0x00		;variable qui definit quelle valeur de reference il faut modifier
		
	OUTI	EIMSK,0b00000100		;on autorise des interuption seulement sur le bouton set (PIN2)
	
	ldi	r16,0xFF			; configure portB as output
	out	DDRB,r16
	OUTI	PORTB,0xff
	
	ldi	r16,0x00			; configure portD as input
	out	DDRD,r16
	ldi	r28,0x00
	sei
	
	WAIT_MS	2000
	rjmp	main
	
;=====================================================
;MAIN
;=====================================================	
main:	
	;PARTIE TEMPERATURE
	ldi	a0,MesureTemp 			;indique au module qu'il faut mesurer la temperature
	rcall	faire_mesure		
	rcall 	convertir_degres

	mov	a0,RegTempLow			;on charge les registres de comparaison de la temperature
	mov	a1,RegTempHigh

	rcall	comparaison_valeur_ref_inf
	cpi	erreur,0x01
	breq	PC+2		
	rcall	comparaison_valeur_ref_sup	
	rcall	affichage_temperature;rcall affichage +led
		
	;PARTIE HUMIDITE
	ldi	a0,MesureHum			;indique au module qu'il faut mesurer l'humidité
	rcall	faire_mesure
	rcall	convertir_humidite

	mov	a0,RegHumidityLow		;on charge les registres de comparaison pour l'humidité
	mov	a1,RegHumidityHigh
	
	rcall	comparaison_valeur_ref_inf
	cpi	erreur,0x01
	breq	PC+2		
	rcall	comparaison_valeur_ref_sup
	rcall	affichage_humidite
	
	WAIT_MS	1000

	rjmp	main
	
;=====================================================
;SOUS-ROUTINE : FAIRE LES MESURES
;=====================================================

;==faire_mesure=======================================
;etablit le protocol pour communiquer avec le capteur et avoir en retour temp et hum
;in:	PORTE
;out:	a1,a0
;mod:	PORTE
;=====================================================
faire_mesure :	
	rcall	wire2_start
	WAIT_MS	250
	rcall	wire2_read
	mov	a1,a0	;MSB
	clr	a0
	rcall	wire2_ack	
	rcall	wire2_read
	rcall	wire2_no_ack
			
	ret
	
	
