# CC6303

A C compiler for the 6800/6803/6303 processors

This is based upon cc65 [https://github.com/cc65/cc65] but involves doing
some fairly brutal things to the original compiler. As such I currently have
no plans to merge it back the other way.

In particular cc65 has a model where the code is generated into a big array
which is parsed as it goes into all sorts of asm level info which drives
optimizer logic. It also uses it to allow the compiler to re-order blocks
and generate code then change its mind.

# Notes

## Notes: 20241012

I've modified things a bit to allow me to compile a 6800 Flex C program and allow it to run under Flex. I have found a few problems like a double des after a jsr to main. I found it necessary to add a jump to WARMST (flex_fini()) at the end of my main() {}. Once I get the sample program cleaned up I'll provide a sample that should compile on Linux and run on Flex (6800).

```
$ cc68 -V -m6800 -tflex -X hwc.c -o hwc
;* 1:Processing hwc.c 4
;* A [/opt/cc68/lib/cc68 -I /opt/cc68/include/flex/ -I /opt/cc68/include/ -r --add-source --cpu 6800 -D__6800__ -D__FLEX__ hwc.c ]
hwc.c(24): Warning: 'i' is defined but never used
;* B [/opt/cc68/lib/cc68 -I /opt/cc68/include/flex/ -I /opt/cc68/include/ -r --add-source --cpu 6800 -D__6800__ -D__FLEX__ hwc.c ]
;* A [/opt/cc68/lib/copt /opt/cc68/lib/cc68-00.rules ]
;* B [/opt/cc68/lib/copt /opt/cc68/lib/cc68-00.rules ]
;* A [/opt/cc68/bin/as68 hwc.s ]
;* B [/opt/cc68/bin/as68 hwc.s ]
;* A [/opt/cc68/bin/ld68 -b -C 256 -Z 40 -o hwc /opt/cc68/lib/crt0_flex.o hwc.o /opt/cc68/lib/libc.a /opt/cc68/lib/libflex.a /opt/
cc68/lib/lib6800.a ]
;* B [/opt/cc68/bin/ld68 -b -C 256 -Z 40 -o hwc /opt/cc68/lib/crt0_flex.o hwc.o /opt/cc68/lib/libc.a /opt/cc68/lib/libflex.a /opt/
cc68/lib/lib6800.a ]
;* A [/opt/cc68/lib/flex-binify -s 256 -l 408 -x 256 hwc hwc.cmd ]
;* B [/opt/cc68/lib/flex-binify -s 256 -l 408 -x 256 hwc hwc.cmd ]
```
Yes there this is overly verbose but it's a step to getting this working. I don't guarantee the compiler is fully work. At the moment I wouldn't consider this stable.

## Notes: 20240928

I've cloned [EtchedPixel's CC6303](https://github.com/EtchedPixels/CC6303)
compiler and I'm attempting to use it under Linux to compile for Flex
3.0 and the 6800. Later I'll look to use it with the 6803 boards I
have. At the moment it seems to have quite a few issues. No command
line help, two cc68 commands (one goes in bin, one in lib/). If I ask
it to stop at the assembly code I get an empty file. So not sure
what's going on here. Which is why I've cloned it. Let see what I can
do.

## Status

### Current 20240928

I've attempted to use this under Linux and I've run into all sorts of
issues. Not sure why the compiler doesn't work. I can't event get the
compiler to save to a .s (asm file). So it appears this needs some
additional work. At the moment I'm hacking at it.

## Git stuff
```

git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a

git remote prune origin

$ git push
fatal: The current branch dev has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin dev

```

[How to create dev branch from master on Github](https://stackoverflow.com/questions/39478482/how-to-create-development-branch-from-master-on-github)

### Old Status
The basic structure is now reasonably functional. You can "make" and "make
install" to get a complete compiler/assembler/linker/tools that appear
to generate actual binaries.

The assembler and linker should be reasonably reliable and complete. The
compiler at this point should be reasonably solid on 6803 and 6303 except for
32bit types. The core compiler support for 32bit types is there and mostly
tested but the library helpers for shifts, multiply and particularly division
are not yet fully debugged.

On the 6800 processor the library routines are far from complete. Note that
the 6800 target will generate much slower and larger code because the 6800
lacks 16bit operations and some other important features. 6800 code is about
a third larger.

The bundled C library routines are initial code and not fully tested or reviewed.
They are intended to provide native versions of key and time critical functions
not a full C library.

## How to use

For a simple test environment the easiest approach at this point is to
compile the code with cc68 and then link with a suitable crt.o (entry code)

````
cc68 -m6803 -c foo.c
ld68 -b -C startaddress crt.o mycode.o /opt/cc68/lib/lib6803.a
````

```
```

```
./cc68 -m6800 -V -X cls.c

/opt/cc68/lib/cc68 -I /opt/cc68/include/ -r --add-source --cpu 6800 -D__6800__ cls.c
/opt/cc68/lib/copt /opt/cc68/lib/cc68-00.rules
/opt/cc68/bin/as68 cls.s
/opt/cc68/bin/ld68 -b -C 256 -o a.out /opt/cc68/lib/crt0.o cls.o /opt/cc68/lib/libc.a /opt/cc68/lib/lib6800.a
```
## Flex

```
./cc68 -tflex -V -X cls.c
```

```
$ ./cc68 -tflex -V -X cls.c

/opt/cc68/lib/cc68 -I /opt/cc68/include/flex/ -I /opt/cc68/include/ -r --add-source --cpu 6800 -D__6800__ -D__FLEX__ cls.c
/opt/cc68/lib/copt /opt/cc68/lib/cc68-00.rules
/opt/cc68/bin/as68 cls.s
/opt/cc68/bin/ld68 -b -C 256 -Z 40 -o a.out /opt/cc68/lib/crt0.o cls.o /opt/cc68/lib/libc.a /opt/cc68/lib/libflex.a /opt/cc68/lib/lib6800.a
/opt/cc68/lib/flex-binify -s 256 -l 585 -x 256 a.out a.out.cmd
```

## Tandy MC-10 target

````
cc68 -tmc10 foo.c -o foo
````

This will produce a foo.c10 that can be loaded into an emulator or turned
into a wav file. A few minimal C library functions are present including
putchar/puts.

## TODO

- Strip out lots more unused cc65 code. There is a lot of unused code,
  and a load of dangling header references and so on left to resolve.

- Remove remaining '6502' references.

- Make embedding C source into asm as comments work for debugging

- Maybe float: cc65 lacks float beyond the basic parsing support, so this
  means extending the back end to handle all the fp cases (probably via
  stack) and using the long handling paths for the non maths ops.

- A proper optimizer

## BIG ISSUES

- We can make much better use of X in some situations than the cc65 code
  based generator really understands. In particular we want to be able to
  tell the expression evaluation "try and evaluate this into X without using
  D". In practice that means simple constants and stack offsets. That will
  improve some handling of helpers. We can't do that much with it because
  we need to be in D for maths. Right now the worst of this is peepholed.

- Fetch pointers via X when we can, especially on 6803. In particular also
  deal with pre/post-inc of statics (but not alas pre/post inc locals) with

````
	ldx $foo
	inx
	stx $foo
	dex
````
- Make sure we can tell if the result of a function is being evaluated or if
  the function returns void. In those cases we can use D (mostly importantly
  B) to use abx to fix the stack offsets.

- copt has no idea about register usage analysis, dead code elimination etc.
  We could do far better with a proper processor that understood 680x not
  just a pattern handler. We fudge it a bit with hints but it's not ideal.

- Floating point
  The cc65 front end has some float support although it is not supported by
  the back end, and I don't know how tested the frontend code is therefore.
  Adding float should not be hard, it's basically a long with no inlineable
  operators as far as the compiler code generator is concerned. It would
  however need someone to volunteer to write the basic IEEE floating point
  operations (add, negate, multiply, divide, maybe compare, plus conversion
  to and from float) for a 680x processor.

# Targets

** MC10

# 6800 Flex

| ADDRESS     | DESCRIPTION | |
| 0000 - 7FFF | User RAM (Some of the lower end of this area is used | |
|             | by certain utilities such as NEWDISK.) | |
| 8000 - 8001 | ACIA (6850) - Slot 0 SWTPC 6800 | Console
| 8004 - 8005 | ACIA (6850) - Slot 1 SWTPC 6800 | | 
| 8008 - 800F | IDE Port 1 - Slot 2 - SS30-IDE SWTPC 6800 | |
| 8010 - 8013 | RTC (146818) - Slot 4 SWTPC 6800 | |
| 8014        | FDC Select - Slot 5 SWTPC 6800| |
| 8018 - 801B | 2797 - Slot 6 SWTPC 6080 | |
| 801C - 801F | PIA (6821) - Slot 7 SWTPC 6800 | |
| 8028 - 802F | IDE Port 2 | |
| 8040 - 9FFF | RAM | |
| A000 - A07F | Stack Area (SP is initialized to A07F) | |
| A080 - A0FF | Input Buffer | |
| A100 - A6FF | Utility Command Area | |
| A700 - A83F | Scheduler & Printer Spooler | |
| A840 - A97F | System FCB | |
| A980 - ABFF | System Files Area | |
| AC00 - B3FF | DOS | |
| B400 - BE7F | FMS | |
| BE80 - BFFF | Disk Drivers | |
| C000 - DFFF | RAM | |
| E000 - EFFF | EPROM | |
| F000 - FFF7 | RAM | |
| FFF8 - FFFF | 8 locations at top of EPROM mapped for reset/IRQ vectors | |
| | |

* asmb

```
The general syntax of the ASMB command is:
ASMB,<file spec 12[,<file spec 2],+<option 1ist


Some examples of assembler command lines follow:
ASMB, TEST
ASMB,TEST, +LS
ASMB,O.TEST,1.TEST.CM,+S
ASM,TEST, +8N
The first example would assemble the source file TEST.TXT from the
working drive and create a binary file named TEST.BIN on the same drive.
The second example would do the same operation as the first example, but
this time the Listing and the Symbol table output would be suppressed.
The next example would assemble the file named TEST. TXT on drive 0 and
produce a binary file on drive 1 named TEST.CMD. Because of the Sin
the options field, no symbol table would be output. The last example
will assemble the file named TEST. TXT, producing a listing with line
numbers, and not produce a binary file {because of the B).
```

```
asmb,0.hw,0.hw.cmd


                *
                        OPT    PAG
                        TTL    Hello World



Hello World                          9-28-24  TSC ASSEMBLER  PAGE    1


                
 AD1E           PSTRNG  EQU    $AD1E
 AD0F           OUTCH   equ    $AD0F
 AD09           INCH    equ    $AD09
 AD03           WARMST  equ    $AD03
                
 A100                   org    $A100
                
 A100 20 01             bra    start
 A102 01        VN      fcb    1         ;* Command version number
 A103 8E 02 00  start   lds    #$0200
                
 A106 CE A1 0F          ldx    #HWMSG
 A109 BD AD 1E          jsr    PSTRNG
                
 A10C 7E AD 03          jmp    WARMST    ;* Done
                
 A10F 1B        HWMSG   fcb    $1B
 A110 3A                fcb    $3A
 A111 48                fcc    'Hello world'
 A112 65 6C     
 A114 6C 6F     
 A116 20 77     
 A118 6F 72     
 A11A 6C 64     
 A11C 04                fcb    $04
                
                        end    
       
NO ERROR(S) DETECTED



Hello World                          9-28-24  TSC ASSEMBLER  PAGE    2



   SYMBOL TABLE:

HWMSG  A10F   INCH   AD09   OUTCH  AD0F   PSTRNG AD1E   VN     A102   
WARMST AD03   start  A103   


+++
```
