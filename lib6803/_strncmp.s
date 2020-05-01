		.export _strncmp
		.setcpu 6803
		.code
_strncmp:
		tsx
		ldd 3,x
		addd 7,x	; save an end stop value
		std @tmp2
		ldd 5,x
		ldx 7,x
		std @tmp
loop:
		ldab ,x		; get *s1 into B
		stx @tmp2	; switch pointer
		ldx @tmp
		cmpb ,x		; compare with *s2
		blo ret1
		bhi retminus1
		inx		; move on
		stx @tmp
		ldx @tmp2	; switch pointer back
		inx
		cpx @tmp2
		bne loop	; rinse, repeat
ret1:
		ldd @one
		rts
retminus1:
		ldd #-1
		rts
		
