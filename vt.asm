[org 100h]
[section .data]

vcurpos:	dd	0
vcurofs:	dd	0
		
[section .text]
	mov ax,0615h
	call vsetpos
	call vgetrpos
	mov ax,4c00h
	int 21h
	

vsetpos:			; ax = RRCC
	push eax
	push ebx
	push edx
	mov [vcurpos],ax
	xor ebx,ebx
	mov bl,ah
	and eax,0ffh
	shl ebx,4
	lea ebx,[ebx*4+ebx]
	add ebx,eax
	mov ah,bh
	mov al,0eh
	mov edx,3d4h
	out dx,ax
	mov ah,bl
	mov al,0fh
	out dx,ax
	shl ebx,1
	mov [vcurofs],ebx
	pop edx
	pop ebx
	pop eax
	ret
	
vgetrpos:			; returnerar:	ax = RRCC
	push ebx
	push edx
	mov dx,3d4h
	mov al,0eh
	out dx,al
	inc dx
	in al,dx
	mov bh,al
	dec dx
	mov al,0fh
	out dx,al
	inc dx
	in al,dx
	mov ah,bh
	shl ax,1
	mov [vcurofs],ax
	mov cl,160
	div cl
	xchg ah,al
	mov [vcurpos],ax
	pop edx
	pop ebx
	ret
	
	


