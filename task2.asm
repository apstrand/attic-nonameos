[bits 32]
[include os.inc]
[org 1000h]
	
[section .data]
t2msg:	db 'Hello World again...',0	
trn:	db '-\|/'

	
[section .text]
	
task2:	mov edi,trn
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
	
