[bits 32]
[org 0h]
	
[section .data]
dbeg:	
t1msg:	db 'Hello World...',0
trn:	db '-\|/'
dlen	equ	$-dbeg


[section .bss]
bbeg:

		
[section .text]
cbeg:	
	dd	task1,clen
 	dd	dbeg,dlen
	dd	bbeg,0
	dd	bbeg,1024
task1:
	mov edi,trn
	mov ax,1000h
	mov bl,1
	int 42h
	mov esi,t1msg
	mov bl,5
	int 42h
	xor esi,esi
	mov bl,4
.l1:	mov al,[edi+esi]
	int 42h
	mov ecx,100000h
	loop $
	mov al,8
	int 42h
	inc esi
	and esi,3
	jmp .l1
	
clen	equ	$-cbeg

[section .data]
	times 200h-(clen+dlen+2) db 0

