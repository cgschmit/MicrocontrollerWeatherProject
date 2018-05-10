;==affichage_temperature==============================
;Permet l'affichage de la température
;in:	erreur, c,d
;out:	LCD,PORTB
;mod:	-
;=====================================================

affichage_temperature:

	rcall	LCD_home		
cas_ok_t:
	cpi	erreur,Mesure_ok		
	brne	cas_inf_t		;affichage de la temperature	
	PRINTF	LCD_putc
	.db	"T=",DEC, c, ".",DEC+DIG2, d, "C "," OK    ", 0 ;juste
	OUTI	PORTB,0xff
cas_inf_t:
	cpi	erreur,Mesure_trop_basse
	brne	cas_sup_t		;affichage de la temperature	
	PRINTF	LCD_putc
	.db	"T=",DEC, c, ".",DEC+DIG2, d, "C "," INF    ", 0 ;juste
	OUTI	PORTB,0x00		
cas_sup_t:
	cpi	erreur,Mesure_trop_haute
	brne	continue_t			;affichage de la temperature	
	PRINTF	LCD_putc
	.db	"T=",DEC, c, ".",DEC+DIG2, d, "C "," SUP    " ,0 ;juste
	OUTI	PORTB,0x00
continue_t:
	ret
	

;==affichage_humidité==============================
;Permet l'affichage de l'humidité
;in:	erreur, c,d
;out:	LCD,PORTB
;mod:	-
;=====================================================
	
affichage_humidite:
	
	ldi	a0,0x40		;affichage de l'humidité sur la deuxieme ligne		
	rcall	LCD_pos	
cas_ok_h:	
	cpi	erreur,Mesure_ok	;On vérifie si on est OK
	brne	cas_inf_h		
	PRINTF	LCD_putc
	.db	"H=",DEC, c, ".",DEC+DIG2, d, "% "," OK   ", 0
	OUTI	PORTB,0xff
cas_inf_h:
	cpi	erreur,Mesure_trop_basse	;On vérifie si on est OK
  	brne	cas_sup_h	
	PRINTF	LCD_putc
	.db	"H=",DEC, c, ".",DEC+DIG2, d, "% "," INF    ", 0
	OUTI	PORTB,0x00	
cas_sup_h:
	cpi	erreur,Mesure_trop_haute	;om verifie si Mesure>temp_ref_sup
	brne	continue_h	
	PRINTF	LCD_putc
	.db	"H=",DEC, c, ".",DEC+DIG2, d, "% "," SUP    " ,0
	OUTI	PORTB,0x00
continue_h:
	ret
	
	
