[bits 32]
[org 0h]
	
[section .data]
dbeg:	
t2msg:	db 'Testprogram 2...',0	
trn:	db '-\|/'
dlen	equ	$-dbeg

[section .bss]
bbeg:
	
[section .text]
cbeg:
	dd	task2,clen
 	dd	dbeg,dlen
	dd	bbeg,0
	dd	bbeg,1024
task2:	mov edi,trn
	mov ax,1200h
	mov bl,1
	int 43h
	mov esi,t2msg
	mov bl,5
 	int 43h
	xor esi,esi
.l1:	mov bl,4
	mov al,[edi+esi]
	int 43h
	mov ecx,100000h
	loop $
	mov bl,4
	mov al,8
	int 43h
	inc esi
	and esi,3
	jmp .l1

	times ($$-$) & 3 db 0

clen	equ	$-cbeg


