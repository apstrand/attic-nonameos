[bits 32]
[include os.inc]
[org 0h]
	
[section .data]
dbeg:	
t2msg:	db 'Hello World again...',0	
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
task2:	
	mov edi,trn
	mov ax,1200h
	mov bl,1
	int 42h
	mov esi,t2msg
	mov bl,5
 	int 42h
	xor edx,edx
	mov bl,4
.l1:	mov al,[edi+edx]
	int 42h
	mov ecx,100000h
	loop $
	mov al,8
	int 42h
	inc dl
	and dl,3
	jmp .l1
		
clen	equ	$-cbeg