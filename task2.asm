[bits 32]
[include os.inc]

[section .data]
dbeg:	
t2msg:	db 'Hello World again...',0	
trn:	db '-\|/'
dlen	equ	$-dbeg
	
[section .text]
[org 0h]
cbeg:
	dd	task2,clen
 	dd	t2msg,dlen
	dd	0
	dd	1024
task2:	
	mov edi,trn-t2msg
	mov ax,1200h
	mov bl,1
	call vid3:0
	mov esi,t2msg
	mov bl,5
 	call vid3:0
	xor edx,edx
	mov bl,4
.l1:	mov al,[edi+edx]
	call vid3:0
	mov ecx,100000h
	loop $
	mov al,8
	call vid3:0
	inc dl
	and dl,3
	jmp .l1
		
clen	equ	$-cbeg
