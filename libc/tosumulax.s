;
;	D = top of stack * D (signed)
;

	.export tosmulax
	.export tosumulax


tosmulax:
tosumulax:
	tsx
	psha
	pshb
	ldaa 4,x		; low byte
	mul			; D is now low x low
	std @tmp
	ldaa 3,x		; high byte
	pulb
	mul			; D is now high x low
	std @tmp1
	ldaa 4,x		; low byte
	pulb			; high byte of D
	mul			; D is now low x high
	addd @tmp1		; High bytes
	tba			; Shift left 8, discarding
	addd @tmp		; Add the low x low
	jmp pop2


	
