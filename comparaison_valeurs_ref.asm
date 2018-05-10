;==comparaison_valeur_ref_inf============================
;Compare la valeur mesurée avec notre référence inférieur
;in:	PORTE
;out:	a1,a0
;mod:	PORTE
;========================================================

comparaison_valeur_ref_inf:	
	ldi	w,0xfe		;on crée un masque permettant d'obtenir uniquement les 7 premiers bits
	and	w, a0		;on compare a0 (partie entiere le ref) avec le masque
	lsr	w		;on decale les bit vers la droite
	cp	c0,w		;on compare la partie entiere de la mesure avec la partie entire de reference
	brlo	PC+14		;si la mesure est trop basse : on alume les leds

	cp	c0,w		;on re-compare		
	brne	PC+14		;si la mesure est superieure a la ref_inf, on verifie la ref_sup

	ldi	w, 0x01		;a ce niveau les parties decimales sont egales: on va comparer les parties frac
	and	w, a0	
	push	c0	
	mov	a0,w
	ldi	b0,0x32		;on met la valeur 50 dans b0 pour faire la partie fractionnaire (car on a un seul bit pour la partie frac.)
	rcall	mul11		;on effectue la multiplication par 50
	mov	w,c0		
	pop	c0
	cp	d0,w		;on compare les parties frac
	brlo	PC+2		;Température trop basse, on alume les leds
	rjmp	PC+3		;sinon, on compare la valeur de ref sup

	ldi	erreur,Mesure_trop_basse 	;en dessous de la valeur inf
	rjmp	PC+2

	ldi	erreur,Mesure_ok	;au dessus de la valeur inf : on verifie la valeur sup
	ret

;==comparaison_valeur_ref_sup============================
;Compare la valeur mesurée avec notre référence supérieur
;in:	PORTE
;out:	a1,a0
;mod:	PORTE
;========================================================

comparaison_valeur_ref_sup:

	ldi	w,0xfe	;on crée un masque permettant d'obtenir uniquement les 7 premiers bits
	and	w, a1	;on compare a (partie fractionnaire de la mesure) avec le masque
	lsr	w	;on decale les bits
	cp	w,c0	;on compare la partie entiere de la mesure avec 
	brlo	PC+14	;la mesure est trop haute : on alume les led

	cp	w,c0	;on re-compare
	brne	PC+14	;on eteint les led		

	ldi	w, 0x01	;les parties decimales sont egales, on compare les parties frac
	and	w, a1
	push	c0	
	mov	a0,w
	ldi	b0,0x32
	rcall	mul11
	mov	w,c0
	pop	c0
	cp	w,d0	;on compare les parties frac
	brlo	PC+2	;on alume les led
	rjmp	PC+3	;on eteint les led

	ldi	erreur,Mesure_trop_haute	;on alume les led
	rjmp	PC+2

	ldi	erreur,Mesure_ok	;on eteint
	ret
	