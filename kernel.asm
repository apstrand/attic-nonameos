[bits 32]
[inc abs.asm]

	;;	task struktur:
	;;	00	text offset
	;;	04	text l�ngd
	;;	08	data offset
	;;	0c	data l�ngd
	;;	10	bss offset
	;;	14	bss l�ngd
	;;	18	stack offset
	;;	1c	stack l�ngd

[section .data]
		
gdt     dw 800h			; Global Descriptor Table
	dd gdt			; Dessa v�rden laddas fr�n start
	dw      0		; Poster f�r nya processer l�ggs 
krnlcs	equ	$-gdt		; till efterhand.
	dd	0000ffffh	; Code descriptor
	dd	00cf9a00h
krnlds	equ	$-gdt
	dd	0000ffffh	; Data descriptor
	dd	00cf9200h
tsw	equ	$-gdt		; Task Gate
	dw	0,t0desc	; Anv�nds vid taskswitching
	dw	08500h,0
t0desc	equ	$-gdt		; TSS f�r f�rsta processen
	dw	400h,pcbs
	dd	00008900h

	
c3desc	equ	0040fa00h	; Mall f�r Kod descriptor
d3desc	equ	0040f200h	; Mall f�r Data descriptor
	

	times 800h-$+gdt db 0	; Reservera utrymme f�r resten av GDT:n


idtptr	dw	07ffh		; Interrupt Descriptor Table
	dd	idt

lastsel dd	38h		; Variabel som h�ller reda p� sista
				; descriptor post

msg1	db	'Running....',0ah,0

	
msg2	db	'             Kernel    Program 1  Program 2',0ah,'Aktiv tid:',0ah,'Total tid:',0	


[section .text]
	
start:				; H�r startar exekveringen efter att bootkoden
				; har laddat in systemet
	
	dd	gdt		; Pekare till GDT:n
	dd	0		; anv�nds av bootkoden
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
				; f�rsta PCB:n
	lidt [idtptr]		; Ladda IDT:n
	sti			; Sl� p� avbrotten
	mov bl,0
	int 43h
	mov esi,msg1
	mov bl,5
	int 43h
	mov bl,4
	mov al,0ah
	int 43h			; Skriv ut lite meddelanden p� sk�rmen

 	mov ecx,1000h
 	call memget
 	mov edi,eax	
 	mov esi,90000h
 	mov ecx,1000h
 	rep movsb
	mov esi,eax
	call loadtask
	call runtask

	
   	mov ecx,1000h
   	call memget
    	mov edi,eax
   	mov esi,90000h+200h
   	mov ecx,1000h
   	rep movsb
	mov esi,eax
   	call loadtask
   	call runtask

	
	mov ax,1000h
	mov bl,1
	int 43h
	mov esi,msg2
	mov bl,5
	int 43h


.l1
	mov ax,110ch
	mov bl,1
	int 43h
	mov eax,[pcbs+tsttime]
	mov bl,8
	int 43h

	mov ax,1118h
	mov bl,1
	int 43h
	mov eax,[pcbs+300h*4+tsttime]
	mov bl,8
	int 43h
	
	mov ax,1123h
	mov bl,1
	int 43h
	mov eax,[pcbs+300h*5+tsttime]
	mov bl,8
	int 43h

	
	mov ax,120ch
	mov bl,1
	int 43h
	mov eax,[pcbs+tstime]
	mov bl,8
	int 43h

	mov ax,1218h
	mov bl,1
	int 43h
	mov eax,[pcbs+300h*4+tstime]
	mov bl,8
	int 43h
	
	mov ax,1223h
	mov bl,1
	int 43h
	mov eax,[pcbs+300h*5+tstime]
	mov bl,8
	int 43h

	
	jmp .l1


	
	;; Skapar GDT-poster f�r processen
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
	add ecx,[esi+1ch]	; ecx = total l�ngd p� processen
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

	
	;; L�gger in v�rden p� ett ledigt st�lle i GDT:n
	;; Indata:	eax:ebx = Descriptor
	;; Utdata:	edx = selector

addgdtent:
	mov edx,[lastsel]
	add edx,8
	mov [gdt+edx],eax
	mov [gdt+edx+4],ebx
	mov [lastsel],edx
	ret

	

[inc ints.asm]
[inc init.asm]	
[inc proc.asm]
[inc video.asm]
[inc memory.asm]
[inc kbd.asm]


[section .text]
codeend:
[section .data]
dataend:	
