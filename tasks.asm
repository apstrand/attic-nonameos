[bits 32]
[include os.inc]
[org 0h]
	
[section .data]
t1msg:	db 'Hello World...',0	
t2msg:	db 'Hello World again...',0	
trn:	db '-\|/'
	
	
[section .text]
	dd	task1,task2
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
	
