[bits 32]
[include os.inc]
[org 0h]
	
[section .data]
t1msg:	db 'Hello World...',0	
trn:	db '-\|/'
dlen	equ	$-t1msg	
	
[section .text]
task1:	mov edi,trn
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
	
clen	equ	$-task1

[section .data]
	times 1000h-(clen+dlen)	db	0
