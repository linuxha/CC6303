;
;	On entry the command typed is in the line buffer. The line buffer
;	pointer points to the next argument
;
;	Turn this into a C style argc/argv.
;
;*
;*   FLEX SYSTEM DEFINED ENTRY POINTS AND EQUATES
;*
;*   FLEX       PUBLIC
;*
LINBUF     equ     $A080               ;* LINE BUFFER
CMDADR     equ     $A100               ;* UTILITY COMMAND SPACE (1.5 K)
CMDEND     equ     $A700               ;* UTILITY COMMAND SPACE END
SYSFCB     equ     $A840               ;* SYSTEM FCB ADDRESS
;*
;*   GLOBAL VALUES SPECIFIED BY TTYSET AND ASN
;*
BSPCHR     equ     $AC00               ;* BACKSPACE CHARACTER
DELCHR     equ     $AC01               ;* DELETE CHARACTER
EOLCHR     equ     $AC02               ;* END OF LINE CHARACTER
DEPTH      equ     $AC03               ;* DEPTH COUNT
WIDTH      equ     $AC04               ;* WIDTH COUNT
NULLS      equ     $AC05               ;* NULL COUNT
TABCHR     equ     $AC06               ;* TAB CHARACTER
BSECHR     equ     $AC07               ;* BACKSPACE ECHO CHARACTER
PAUSE      equ     $AC09               ;* PAUSE CONTROL BYTE
ESCCHR     equ     $AC0A               ;* ESCAPE CHARACTER
SDRN       equ     $AC0B               ;* SYSTEM DRIVE NUMBER
WDRN       equ     $AC0C               ;* WORKING DRIVE NUMBER
;*
;*   FLEX SYSTEM GLOBAL VARIABLES
;*
SYSFLG     equ     $AC0D               ;* USE SYSTEM DRIVE FLAG
SYSDATE    equ     $AC0E               ;* DATE REGISTERS
LSTTRM     equ     $AC11               ;* LAST TERMINATOR CHARACTER
CBUFPT     equ     $AC14               ;* LINE BUFFER POINTER
ESCRET     equ     $AC16               ;* ESCAPE RETURN REGISTER
CURCHR     equ     $AC18               ;* CURRENT NXTCH CHARACTER
PREVCH     equ     $AC19               ;* PREVIOUS NXTCH CHARACTER
CURLCT     equ     $AC1A               ;* CURRENT LINE COUNT
LOADAO     equ     $AC1B               ;* LOADER ADDRESS OFFSET DATA
XFRFLG     equ     $AC1D               ;* TRANSFER ADDRESS FLAG
XFRADR     equ     $AC1E               ;* TRANSFER ADDRESS OF LOADED FILE
OUTSWT     equ     $AC22               ;* OUTPUT SWITCH
INSWT      equ     $AC23               ;* INPUT SWITCH
DOCMDF     equ     $AC28               ;* DOCMD ENTRY FLAG
CURCOL     equ     $AC29               ;* CURRENT OUTPUT COLUMN
MEMEND     equ     $AC2B               ;* END OF MEMORY ADDRESS
FMSBUSY    equ     $AC30               ;* FLEX ALREADY BUSY FLAG
CPUTYPE    equ     $AC33               ;* CPU TYPE FLAG
RETADR     equ     $AC43               ;* DOCMD RETURN ADDRESS
ULCFLAG    equ     $AC49               ;* UPPER/LOWER CASE MAP FLAG
PROMPT     equ     $AC4E               ;* POINTER TO PROMPT STRING
;*
;*   FLEX SYSTEM DEFINED ENTRY VECTORS
;*
COLDS      equ     $AD00               ;* FLEX COLD START ADDRESS
WARMS      equ     $AD03               ;* FLEX WARM START ADDRESS
RENTER     equ     $AD06               ;* RE-ENTER FLEX PROCESSING
INCH       equ     $AD09               ;* INPUT CHARACTER (LOW LEVEL)
OUTCH      equ     $AD0F               ;* OUTPUT CHARACTER (LOW LEVEL)
GETCHR     equ     $AD15               ;* INPUT CHARACTER ROUTINE
PUTCHR     equ     $AD18               ;* OUTPUT CHARACTER ROUTINE
INBUFF     equ     $AD1B               ;* INPUT LINE BUFFER
PSTRNG     equ     $AD1E               ;* PRINT STRING
CLASS      equ     $AD21               ;* CLASSIFY CHARACTER
PCRLF      equ     $AD24               ;* PRINT CR/LF SequENCE
NXTCH      equ     $AD27               ;* GET NEXT CHARACTER FROM INPUT BUFFER
GETFIL     equ     $AD2D               ;* SCAN FILE SPEC ADDRESS
LOAD       equ     $AD30               ;* LOAD FILE ENTRY POINT
SETEXT     equ     $AD33               ;* SET UP FILE EXTENSION
OUTDEC     equ     $AD39               ;* OUTPUT DECIMAL NUMBER
OUTHEX     equ     $AD3C               ;* OUTPUT HEXADECIMAL NUMBER
RPTERR     equ     $AD3F               ;* I/O ERROR ABORT ROUTINE
GETHEX     equ     $AD42               ;* GET HEXIDECIMAL SPECIFICATION
OUTADR     equ     $AD45               ;* OUTPUT HEXADECIMAL ADDRESS
INDEC      equ     $AD48               ;* GET DECIMAL NUMBER
DOCMD      equ     $AD4B               ;* DOCMD ENTRY ADDRESS
STATUS     equ     $AD4E               ;* CHECK TERMINAL INPUT STATUS
;*
;*   LOW LEVEL TERMINAL AND INTERRUPT CONTROL ADDRESSES
;*
INTAP      equ     $B3DE               ;* VECTOR FOR INPUT TAP ROUTINE
DUMMY      equ     $B3E0               ;* DUMMY RTS INSTRUCTION USED BY RM
SETIRQ     equ     $B3E1               ;* SET IRQ PROCESS VECTOR
CLRIRQ     equ     $B3E3               ;* CLEAR IRQ PROCESS VECTOR
TINCH      equ     $B3E5               ;* LOW-LEVEL TERM INPUT WITHOUT ECHO
TOFF       equ     $B3ED               ;* TIMER OFF ROUTINE ADDRESS
TON        equ     $B3EF               ;* TIMER ON ROUTINE ADDRESS
TMINIT     equ     $B3F1               ;* TIMER INITIALIZE ROUTINE ADDRESS
TINIT      equ     $B3F5               ;* LOW-LEVEL TERMINAL INITIALIZE
TCHECK     equ     $B3F7               ;* LOW-LEVEL TERMINAL CHECK ADDRESS
TOUTCH     equ     $B3F9               ;* LOW-LEVEL TERMINAL OUTPUT ADDRESS
TINCHE     equ     $B3FB               ;* LOW-LEVEL TERMINAL INPUT WITH ECHO
;*
;*   FILE MANAGEMENT SYSTEM ENTRY POINTS
;*
FMSCLS     equ     $B403               ;* CLOSE UP ALL FILES ENTRY
FMS        equ     $B406               ;* FILE MANAGER EXEC CALL
FCBASE     equ     $B409               ;* FILE CONTROL BLOCK BASE
VERIFY     equ     $B435               ;* FMS VERIFY FLAG
SURTAB     equ     $B436               ;* FMS SURNAME TABLE

FCBLEN     equ     256+64              ;* FILE CONTROL BLOCK LENGTH
;*
;*   DISK DRIVER ENTRY POINTS
;*
DREAD      equ     $BE00               ;* READ SECTOR ROUTINE
DWRITE     equ     $BE03               ;* WRITE SECTOR ROUTINE
DVERFY     equ     $BE06               ;* VERIFY ROUTINE
DREST      equ     $BE09               ;* DRIVE RESTORE ROUTINE
DRIVE      equ     $BE0C               ;* DRIVE SELECT ROUTINE
DCHECK     equ     $BE0F               ;* CHECK DRIVE READY
DQUICK     equ     $BE12               ;* QUICK CHECK DRIVE READY
DSEEK      equ     $BE1B               ;* DRIVE SEEK-TO-SECTOR ROUTINE
;
start:		
		bra     l1
VN:		.byte   1
		;
		; Out of memory
		;
nofit:
		ldx     #nomem
		jsr     PSTRNG
		jmp     WARMS
l1:
		;
		;	See if we look like we fit. Allow 512 byts for args
		;	and stack minimum
		;
		ldab    #<__bss
		addb    #<__bss_size
		ldaa    #>__bss
		adca    #>__bss_size
		staa    @tmp
		stab    @tmp+1
	
		ldaa    MEMEND      ;* Was AC2B
		ldab    MEMEND+1    ;* Was AC2C
		subb    @tmp+1
		sbca    @tmp
		bcs     nofit
		; Allow some stack space
		deca
		bcs     nofit
		deca
		bcs     nofit

		ldx     #__bss
wipebss:	cpx     @tmp
		beq     wiped
		clr     ,x
		inx
		bra     wipebss

wiped:
		;
		; Runtime DP constants
		;
		clra
		staa    @zero
		staa    @zero+1
		inca
		staa    @one+1

		; Memory layout
		ldaa    MEMEND     ;* Was AC2B
		ldab    MEMEND+1   ;* Was AC2C
		subb    #$80		; 128 byte line copy
		sbca    #$00
		staa    @tmp
		stab    @tmp+1
		ldx     @tmp
		subb    #$82		; 130 byte line arg worst case
		sbca    #$00
		staa    @tmp2
		stab    @tmp2+1
		lds     @tmp2

		clr     @tmp1		; argc

		; We can't easily get argv[0] as it's been eaten by
		; the OS

		; Ideally we'd use nxtch but nxtch has very non C ideas!

		; tmp is our string copy buffer
		; tmp2 is our argv pointers
		; and stack sits just below that
		
		; Assign argv[0] to a constant string

		ldaa    #>arg0
		ldaa    #<arg0
		bsr     storearg
		;
		; Start processing the next argument
		;
nextarg:
		ldx     CBUFPT
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
		stx     CBUFPT
		ldaa    @tmp		; arg pointer
		ldab    @tmp+1
		bsr     storearg
		;
		;	Copy the argument
		;
copynext:
		stx     CBUFPT
		ldx     @tmp
		stab    ,x
		inx
		stx     @tmp
		ldx     CBUFPT
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
		clra
		clrb
		bsr     storearg
		dec     @tmp1		; argc is the NULL marker arg
		sts     @tmp		; S is balanced so is argv[0] ptr
		ldab    @tmp1		; argc
		clra
		pshb
		psha
		ldaa    @tmp
		ldab    @tmp+1
		pshb
		psha
		jsr     _main
		; if this returns it's an exit()
		;pshb
		;psha
		;jsr    _exit
		; Never returns

;_exit:
;__exit:
		jmp     WARMS

		.data

nomem:		.ascii 'NOT ENOUGH RAM'
		.byte   4
arg0:
		.ascii  'cmd'
		.byte   0
