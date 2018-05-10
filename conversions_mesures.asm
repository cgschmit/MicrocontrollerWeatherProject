;=======================================
;converti la temperature donnée par le module
;in:	a1,a0
;out:	c0,d0	
;mod:	b0,c1,SREG
;=======================================

convertir_degres:	ldi	b0, 100		; on divise par 100
 			rcall	div21		; on appelle une sous-rôutine de math.asm
			_SUBI	c0, 40		; on soustrait 40 [C]
			clr	c1		; on s'assure que c1 soit tjrs nul
			clr	b0
			ret
	
;=======================================
;converti l'himidité donnée par le module
;in:	a1,a0
;out:	c0,d0	
;mod:	b0,c1,SREG
;=======================================
	
convertir_humidite:	ldi	b0,31
			rcall	div21
			clr	c1
			ret