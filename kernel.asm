[bits 32]
[inc abs.asm]

	;;	task struktur:
	;;	00	text offset
	;;	04	text längd
	;;	08	data offset
	;;	0c	data längd
	;;	10	bss offset
	;;	14	bss längd
	;;	18	stack offset
	;;	1c	stack längd

[section .data]
		
gdt     dw 800h
	dd gdt
	dw      0
krnlcs	equ	$-gdt
	dd	0000ffffh	; code descriptor
	dd	00cf9a00h
krnlds	equ	$-gdt
	dd	0000ffffh	; data descriptor
	dd	00cf9200h
tsw	equ	$-gdt
	dw	0,t0desc	; Task Gate
	dw	08500h,0
t0desc	equ	$-gdt
	dw	400h,pcbs	; Task 0
	dd	00008900h

	
c3desc	equ	0040fa00h
d3desc	equ	0040f200h
	

	times 800h-$+gdt db 0


idtptr	dw	07ffh
	dd	idt

lastsel dd	30h

	
msg1	db	'Running....',0ah,0


[section .text]
	
start:
	dd	gdt
	dd	0
	mov ax,krnlds
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	mov esp,10000h
	
	call enableA20
 	call getmems
	call init8259
	call init8253
	call initIDT
	call initpcbs
	lidt [idtptr]
	sti

	mov bl,0
	int 42h
	mov esi,msg1
	mov bl,5
	int 42h
	mov bl,4
	mov al,0ah
	int 42h

 	mov ecx,1000h
 	call memget
 	mov edi,eax	
 	mov esi,dataend
 	mov ecx,1000h
 	rep movsb
	mov esi,eax
	call loadtask
	call runtask

	
   	mov ecx,1000h
   	call memget
    	mov edi,eax
   	mov esi,dataend+200h
   	mov ecx,1000h
   	rep movsb
	mov esi,eax
   	call loadtask
;    	call runtask

	mov eax,[pcbs+tssel]
	mov bl,8
	int 42h
	mov eax,[pcbs+tssel+300h]
	int 42h
	
	jmp $

newgdtent:			; esi = pekare till task
	push eax
	push ebx
	push edi
	mov eax,esi
	shl eax,16
	mov ecx,[esi+04]
	add ecx,[esi+0ch]
	add ecx,[esi+14h]
	add ecx,[esi+1ch]
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
	ret			; ecx=code selector edx=data selector
	

addgdtent:				; eax:ebx = descriptor
	mov edx,[lastsel]
	add edx,8
	mov [gdt+edx],eax
	mov [gdt+edx+4],ebx
	mov [lastsel],edx
	ret			; returnerar selector i edx

	
[inc memory.asm]
[inc proc.asm]
[inc video.asm]
[inc ints.asm]
[inc kbd.asm]
[inc init.asm]

[section .text]
codeend:
[section .data]
dataend:	
