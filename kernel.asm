[bits 32]
[inc os.inc]
[section .data]

	;;	task struktur:
	;;	00	text offset
	;;	04	text längd
	;;	08	data offset
	;;	0C	data längd
	;;	10	bss längd
	;;	14	stack längd
	;;	.
	;;	.
	;;	.


		
gdt     dw 800h
	dd gdt
	dw      0
	dd	0000ffffh	; code descriptor
	dd	00cf9a00h
	dd	0000ffffh	; data descriptor
	dd	00cf9200h
	dw	video0,8h	; Call gate Video dpl 0
	dw	8c00h,0
	dw	video3,8h	; Call gate Video dpl 3
	dw	0ec00h,0
	dw	0,t0desc	; Task Gate
	dw	08500h,0
	dw	200h,tss0	; Task 0
	dd	00008900h

	
c3desc	equ	0040fa00h
d3desc	equ	0040f200h
	

	times 800h-$+gdt db 0
idt	times 100h dw dummyh,8,8e00h,0


idtptr	dw	07ffh
	dd	idt

lastsel dd	30h

msg1	db	'Running....',0ah,0
msgl1	db	'Loading task 1...',0ah,0
msgr1	db	'Running task 1...',0ah,0
msgl2	db	'Loading task 2...',0ah,0
msgr2	db	'Running task 2...',0ah,0


[section .text]
start:	
	mov ax,d0d
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
	call inittss
	lidt [idtptr]
	sti
	mov bl,0
	call vid0:0
	mov esi,msg1
	mov bl,5
	call vid0:0

 	mov ecx,1000h
 	call memget
 	mov edi,eax	
 	mov esi,endmark
 	mov ecx,1000h
 	rep movsb
	mov esi,eax
	call loadtask
	call runtask
	
   	mov ecx,1000h
  	call memget
   	mov edi,eax
  	mov esi,endmark+1000h
  	mov ecx,1000h
  	rep movsb
  	mov esi,eax
  	call loadtask
  	call runtask

	jmp $

newgdtent:			; esi = pekare till task
	push eax
	push ebx
	push esi
	push edi

	mov eax,esi
	shl eax,16
	mov ecx,[esi+4]
	add ecx,[esi+10h]
	add ecx,[esi+14h]
	mov ax,cx
	mov ebx,c3desc
	call addgdtent
	mov edi,edx
	mov edx,[esi]
	add edx,esi
	shr edx,16
	mov [1000h+edi+4],dl
	mov [1000h+edi+7],dh
	shr ecx,16
	and cl,0fh
	or [1000h+edi+6],cl	

		
	mov eax,[esi+8h]
	add eax,esi
	shl eax,16
	mov ecx,[esi+0ch]
	add ecx,[esi+10h]
	add ecx,[esi+14h]
	mov ax,cx
	mov ebx,d3desc
	call addgdtent
	mov ebx,[esi+8]
	add ebx,esi
	shr ebx,16
	mov [1000h+edx+4],bl
	mov [1000h+edx+7],bh
	shr ecx,16
	and cl,0fh
	or [1000h+edx+6],cl
	mov ecx,edi
	pop edi		
	pop esi
	pop ebx
	pop eax
	ret
	

addgdtent:				; eax:ebx = descriptor
	mov edx,[lastsel]
	add edx,8
	mov [1000h+edx],eax
	mov [1000h+edx+4],ebx
	mov [lastsel],edx
	ret			; returnerar selector i edx

[inc memory.asm]
[inc job.asm]
[inc video.asm]
[inc ints.asm]
[inc kbd.asm]
[inc init.asm]

[section .text]
	times 1000h-$+start db 0
[section .data]
endmark:

