bits 32

%include "abs.asm"

	;;	task struktur:
	;;	00	text offset
	;;	04	text längd
	;;	08	data offset
	;;	0c	data längd
	;;	10	bss offset
	;;	14	bss längd
	;;	18	stack offset
	;;	1c	stack längd

section .data
		
gdt     dw 800h			; Global Descriptor Table
	dd gdt			; Dessa värden laddas från start
	dw      0		; Poster för nya processer läggs 
krnlcs	equ	$-gdt		; till efterhand.
	dd	0000ffffh	; Code descriptor
	dd	00cf9a00h
krnlds	equ	$-gdt
	dd	0000ffffh	; Data descriptor
	dd	00cf9200h
tsw	equ	$-gdt		; Task Gate
	dw	0,t0desc	; Används vid taskswitching
	dw	08500h,0
t0desc	equ	$-gdt		; TSS för första processen
	dw	400h,pcbs
	dd	00008900h

	
c3desc	equ	0040fa00h	; Mall för Kod descriptor
d3desc	equ	0040f200h	; Mall för Data descriptor
	

	times 800h-$+gdt db 0	; Reservera utrymme för resten av GDT:n


idtptr	dw	07ffh		; Interrupt Descriptor Table
	dd	idt

lastsel dd	38h		; Variabel som håller reda på sista
				; descriptor post

msg1	db	'Running....',0ah,0
msg2	db	'Laddar process 1...',0ah,0
msg3	db	'K”r process 1',0ah,0
msg4	db	'Laddar process 2...',0ah,0
msg5	db	'K”r process 2',0ah,0ah,0ah,0ah,0
msg6	db	'Tryck F2 resp. F3 f”r att g† till process 1 resp. 2',0ah,0

	
[section .text]
	
start:				; Här startar exekveringen efter att bootkoden
				; har laddat in systemet
	
	dd	gdt		; Pekare till GDT:n
	dd	0		; används av bootkoden
	mov ax,krnlds
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax		; Ladda segmentregister...
	mov esp,10000h		; Och stackpekare
	
	call enableA20
	mov esi,dataend
	mov edi,90000h
	mov ecx,400h
	rep movsd
	
 	call getmems		; Initiera minneshanteraren
	call init8259		; Initiera Timern
	call init8253		; Initiera PIC
	call initIDT		; Initiera IDT
	call initpcbs		; Initiera PCB tabellen och 
				; första PCB:n
	lidt [idtptr]		; Ladda IDT:n
	sti			; Slå på avbrotten
	mov bl,0
	int 43h
	mov esi,msg1
	mov bl,5
	int 43h
	mov bl,4
	mov al,0ah
	int 43h			; Skriv ut lite meddelanden på skärmen


	mov ecx,1000h
 	call memget
 	mov edi,eax	
 	mov esi,90000h
 	mov ecx,1000h
 	rep movsb
	mov esi,eax
	call loadtask
	mov dword [ebx+tsvscr],80*25*2
	call runtask
	
	mov esi,msg2
	mov bl,5
	int 43h
	mov esi,msg3
	mov bl,5
	int 43h


	mov ecx,1000h
   	call memget
    	mov edi,eax
   	mov esi,90000h+200h
   	mov ecx,1000h
   	rep movsb
	mov esi,eax
   	call loadtask
	mov dword [ebx+tsvscr],80*25*2*2
   	call runtask
	
	mov esi,msg4
	mov bl,5
	int 43h
	mov esi,msg5
	mov bl,5
	int 43h
	mov esi,msg6
	mov bl,5
	int 43h

	
	jmp $

	
	;; Skapar GDT-poster för processen
	;; Indata:	esi = pekare till processen
	;; Utdata:	ecx = kod selector
	;;		edx = data selector
	
newgdtent:
	push eax
	push ebx
	push edi
	mov eax,esi
	shl eax,16
	mov ecx,[esi+04]
	add ecx,[esi+0ch]
	add ecx,[esi+14h]
	add ecx,[esi+1ch]	; ecx = total längd på processen
	mov ax,cx
	and ecx,000f0000h
	mov ebx,esi
	xor bx,bx
	bswap ebx
	ror ebx,8
	or ebx,ecx
	push ebx
	or ebx,c3desc
	call addgdtent
	mov edi,edx
	pop ebx
	or ebx,d3desc
	call addgdtent
	mov ecx,edi
	pop edi
	pop ebx
	pop eax
	ret

	
	;; Lägger in värden på ett ledigt ställe i GDT:n
	;; Indata:	eax:ebx = Descriptor
	;; Utdata:	edx = selector

addgdtent:
	mov edx,[lastsel]
	add edx,8
	mov [gdt+edx],eax
	mov [gdt+edx+4],ebx
	mov [lastsel],edx
	ret

	

%include "ints.asm"
%include "init.asm"	
%include "proc.asm"
%include "video.asm"
%include "memory.asm"
%include "kbd.asm"


section .text
codeend:
section .data
dataend:	
