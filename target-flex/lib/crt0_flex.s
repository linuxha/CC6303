;
;	On entry the command typed is in the line buffer. The line buffer
;	pointer points to the next argument
;
;	Turn this into a C style argc/argv.
;
;
start:		
		bra     l1
		.byte   1
		;
		; Out of memory
		;
nofit:
		ldx     #nomem
		jsr     $AD1E
		jmp     $AD03
l1:
        	ldaa    #$7E    	;* JMP = $7E
                staa    @jmptmp         ;*
		;
		;	See if we look like we fit. Allow 512 byts for args
		;	and stack minimum
		;
		;*
		;* __bss     = $0292 (this changes depending on the C code)
		;*__bss_size = $0000
		;*
		ldab    #<__bss 	;* $92
		addb    #<__bss_size    ;* $00
		ldaa    #>__bss         ;* $02
		adca    #>__bss_size
		staa    @tmp
		stab    @tmp+1
	
		ldab    $AC2C           ;* Was AC2C = $FF
		ldaa    $AC2B   	;* Was AC2B = $7F
		subb    @tmp+1          ;* $
		sbca    @tmp            ;* 7FFF 03B0
		;***
		;*** Bad math, need to fix this
		;***
		;bcs     nofit
        nop
        nop
		;***
		;*** DECA doesn't affect the Carry
		;***
		;deca            	;*
		;bcs     nofit           ;*
		;deca            	;*
		;bcs     nofit
	nop
	nop
	nop
	nop
	nop
l2:     nop

		;*
		;*
		;*
		ldx     #__bss  	;* $0292 (PRGEND)
wipebss:	cpx     @tmp            ;* $7CED
		beq     wiped
		clr     ,x
		inx
		bra     wipebss

wiped:
		;
		; Runtime DP constants
		;
		clra
		;*
		;* @zero = $0028
		;* @one  = $002A
		;*
		staa    @zero
		staa    @zero+1
		inca
		staa    @one+1

		; Memory layout
		ldaa    $AC2B      	;* Was AC2B - MEMEND   $7F
		ldab    $AC2C           ;* Was AC2C - MEMEND+1 $FF
		subb    #$80		; 128 byte line copy
		sbca    #$00
		staa    @tmp       	;* $7F
		stab    @tmp+1          ;* $7F
		ldx     @tmp
		subb    #$82		;* $7E - 130 byte line arg worst case
		sbca    #$00            ;* $FD
		staa    @tmp2      	;* 
		stab    @tmp2+1
		lds     @tmp2      	;* $7EFD

		clr     @tmp1		;* argc

		; We can't easily get argv[0] as it's been eaten by
		; the OS

		; Ideally we'd use nxtch but nxtch has very non C ideas!

		; tmp is our string copy buffer
		; tmp2 is our argv pointers
		; and stack sits just below that
		
		; Assign argv[0] to a constant string

		ldaa    #>arg0
		ldab    #<arg0
		bsr     storearg 	;* STK = $7EFD ([SP] ← [SP] - 2) = $7EFB
		;
		; Start processing the next argument
		;
nextarg:
		ldx     $AC14       	;* AC14 = Line Buffer Pointer STK = $7EFD
		;
		; Skip spaces, terminate on end marker
		;
leadspace:
		ldab    ,x
		cmpb    #$0D
		beq     done
		; FIXME - and check ttyset char
		inx
		cmpb    #$20
		beq     leadspace
		;
		; Set up the argument pointer as we found an argument
		;
		stx     $AC14
		ldaa    @tmp		; arg pointer
		ldab    @tmp+1
		bsr     storearg
		;
		;	Copy the argument
		;
copynext:
		stx     $AC14
		ldx     @tmp
		stab    ,x
		inx
		stx     @tmp
		ldx     $AC14
		ldab    ,x
		cmpb    #$0D
		beq     argend
		; FIXME - and check ttyset char
		cmpb    #$20
		beq     argend
		inx
		beq     copynext
argend:
		;
		; End of string marker
		;
		ldx     @tmp
		clr     ,x
		inx
		stx     @tmp
		;
		; Look for more
		;
		bra     nextarg

storearg:
		ldx     @tmp2
		staa    ,x
		stab    1,x
		inx
		inx
		stx     @tmp2
		inc     @tmp1
		rts

		;
		; Now set up the C environment
		;
done:
		clra            	;* STK = $7EFB
		clrb
		bsr     storearg
		dec     @tmp1		; argc is the NULL marker arg
		sts     @tmp		; S is balanced so is argv[0] ptr
		ldab    @tmp1		; argc
		clra                    ;
		pshb                    ; $7EFB = B, STK = $7EFA
		psha                    ; $7EFA = A, STK = $7EF9
		ldaa    @tmp            ;
		ldab    @tmp+1          ;
		pshb                    ; $7EF9 = B, STK = $7EF8
		psha                    ; $7EFB = A, STK = $7EF7
		;sr     _main           ; 
		;jsr     kludge          ; 
		; if this returns it's an exit()
		; Never returns
		;

kludge: 	nop
		jsr     _main
		nop
		nop
	        jmp     $AD03   	;* Warmst
		rts

		.data

nomem:		.ascii  'Not enough RAM'
		.byte   4
arg0:
		.ascii  'cmd'
		.byte   0
;*
;* psha - [[SP]] ← [A], [SP] ← [SP] - 1
;* DES  - [SP] ← [SP] - 1
;*
;* pula - [SP] ← [SP] + 1, [A] ← [[SP]]
;* ins  - [SP] ← [SP] + 1
