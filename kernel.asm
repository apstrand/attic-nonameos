[bits 32]
[inc os.inc]
[section .data]
	
gdt     dw 800h
	dd gdt
	dw      0
	dd	0000ffffh	; code descriptor
	dd	00cf9a00h
	dd	0000ffffh	; data descriptor
	dd	00cf9200h
	dd	0000ffffh	; cpl3 code descriptor
	dd	00cffa10h
	dd	0000ffffh	; cpl3 data descriptor
	dd	00cff210h
	dw	video0,8h	; Call gate Video dpl 0
	dw	8c00h,0
	dw	video3,8h	; Call gate Video dpl 3
	dw	0ec00h,0
	dw	0,t0desc	; Task Gate
	dw	08500h,0
	dw	200h,tss0	; Task 0
	dd	00008900h

	times 800h-$+gdt db 0
idt	times 100h dw dummyh,8,8e00h,0


idtptr	dw	07ffh
	dd	idt

lastsel dd	40h
msg0	db	'Initiating....',0ah,0
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
	mov esi,0
	call loadtask
	call runtask
 	mov ecx,1000h
 	call memget
 	mov edi,eax
	mov esi,endmark+1000h
	mov ecx,1000h
	rep movsb
	mov esi,1000h
	call loadtask
	call runtask

	jmp $

addgdtsel:			; eax:ebx = descriptor
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

