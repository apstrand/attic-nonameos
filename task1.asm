[bits 32]
[include os.inc]
	
[section .data]
dbeg:	
t1msg:	db 'Hello World...',0
trn:	db '-\|/'
dlen	equ	$-dbeg
	
[section .text]
[org 0h]
cbeg:	
	dd	task1,clen
 	dd	t1msg,dlen
	dd	0
	dd	1024
task1:
	mov edi,trn-dbeg
	mov ax,1000h
	mov bl,1
	call vid3:0
	mov esi,t1msg
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

[section .data]
	times 1000h-(clen+dlen) db 0
