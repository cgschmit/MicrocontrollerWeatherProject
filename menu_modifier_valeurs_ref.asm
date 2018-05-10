;==faire_mesure=======================================
;cette sous routine etabli le protocol pour communiquer avec le capteur et avoir en retour temp et hum
;in:	PORTE
;out:	a1,a0
;mod:	PORTE
;=====================================================

modification_valeurs:
	cpi	CompteurRegistre,0x04		;
	breq	PC+3			;si le compteur est deja à 4, on a fini de modifier les valeurs et on revient au main
	inc	CompteurRegistre	;sinon on incremente le registre pour modifier la valeur suivante
	rjmp	modif_RegTempLow	;on regarde si le compteur pointe sur RegTempLow
	
	clr	CompteurRegistre	
	rcall	LCD_clear 
	reti	
	
modif_RegTempLow:	;VERIFICATION VALEUR DU COMPTEUR DE REGISTRES
	
	cpi	CompteurRegistre,changer_RegTempLow	 ;changer la temp de reference haute
	brne	modif_RegTempHigh 			;verifier la valeur suivante
	WAIT_MS	200

	;AFFICHAGE
	mov	a0,RegTempLow
	rcall	LCD_clear
	PRINTF	LCD_putc	
	.db	"TempLow =",FRAC,a,1,$22,"C",0

	;ETATS DES BOUTONS
	rcall	etats_bouton
	mov	RegTempLow,a0
	;condition pour appuyer sur enter
	cpi	r16,0b00000011
	brne	PC+2
	jmp	modification_valeurs
	
	rjmp	modif_RegTempLow
			
modif_RegTempHigh:	;VERIFICATION VALEUR DU COMPTEUR DE REGISTRES
	
	cpi	CompteurRegistre,changer_RegTempHigh 	;changer la temp de reference haute
	brne	modif_RegHumidityLow			;verifier la valeur suivante		
	WAIT_MS	200


	;AFFICHAGE
	mov	a0,RegTempHigh	
	rcall	LCD_clear
	PRINTF	LCD_putc
	.db	"TempHigh=",FRAC,a,1,$22,"C",0

	;ETATS DES BOUTONS
	rcall	etats_bouton
	mov	RegTempHigh,a0
	;condition pour appuyer sur enter
	cpi	r16,0b00000011
	brne	PC+2;a modifer
	jmp	modification_valeurs
		
	rjmp	modif_RegTempHigh
	
modif_RegHumidityLow:		;VERIFICATION VALEUR DU COMPTEUR DE REGISTRES
	
	cpi	CompteurRegistre,changer_RegHumidityLow 	;changer l'humidite de reference basse
	brne	modif_RegHumidityHigh				;verifier la valeur suivante
	WAIT_MS	200
	
	;AFFICHAGE	
	mov	a0,RegHumidityLow
	rcall	LCD_clear
	PRINTF	LCD_putc
	.db	"HumLow=",FRAC,a,1,$22,"%",0

	;ETATS DES BOUTONS
	rcall	etats_bouton
	mov	RegHumidityLow,a0
	;condition pour appuyer sur enter
	cpi	r16,0b00000011
	brne	PC+2;a modifer
	jmp	modification_valeurs
		
	rjmp	modif_RegHumidityLow
;-----------------------------------------------------------------

modif_RegHumidityHigh:	;VERIFICATION VALEUR DU COMPTEUR DE REGISTRES
	
	cpi	CompteurRegistre,changer_RegHumidityHigh ;changer l'humidite de reference haute
	brne	PC+10 					;aller a modification valeur 	
	WAIT_MS	200
	
	;AFFICHAGE
	mov	a0,RegHumidityHigh
	rcall	LCD_clear
	PRINTF	LCD_putc
	.db	"HumHigh= ",FRAC,a,1,$22,"%",0	

	;ETATS DES BOUTONS
	rcall	etats_bouton
	mov	RegHumidityHigh,a0
	;condition pour appuyer sur enter
	cpi	r16,0b00000011
	brne	PC+2;a modifer
	jmp	modification_valeurs
		
	rjmp	modif_RegHumidityHigh

etats_bouton:
	;on regarde l'etat des boutons
	in	r16,PIND
	andi	r16,0b00001011
	;condition pour incrementer le registre en cours
	cpi	r16,0b00001001
	brne	PC+2;a modifer
	inc	a0
	;condition pour decrementer le registre en cours
	cpi	r16,0b00001010
	brne	PC+2;a modifer
	dec	a0
	
	ret
