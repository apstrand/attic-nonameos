[section .data]

vcurpos:	dd	0
vcurofs:	dd	0
		
[section .text]

vcls:
	push eax
	mov eax,80*25*2
.l1:	sub eax,4
	mov dword [0b8000h+eax],07200720h
	jnz .l1
	xor eax,eax
	mov [vcurpos],eax
	mov [vcurofs],eax
	mov dx,3d4h
	mov ax,0dh
	out dx,ax
	mov ax,0eh
	out dx,ax
	pop eax
	ret

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

	
vgetpos:
	mov ax,[vcurpos]
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
	shr ax,1
	mov cl,80
	div cl
	xchg ah,al
	mov [vcurpos],ax
	pop edx
	pop ebx
	ret
	
vputchar:			; tecken i al
	push eax
	cmp al,0ah
	jne .l2
	call vgetpos
	xor al,al
	inc ah
	call vsetpos
	pop eax
	ret
.l2:	push ebx
	mov ebx,[vcurofs]
	mov ah,07h
	mov [0b8000h+ebx],ax
	call vgetpos
	inc al
	call vsetpos
	pop ebx
	pop eax
	ret
	
vwstr:				; sträng i esi
	push eax
.l1:	lodsb
	or al,al
	jz .l2
	call vputchar
	jmp .l1
.l2:	pop eax
	ret

vbyte:
	push eax
	xor ah,ah
	ror eax,4
	add al,30h
	cmp al,39h
	jbe .l1
	add al,7
.l1:	call vputchar
	xor al,al
	rol eax,4
	add al,30h
	cmp al,39h
	jbe .l2
	add al,7
.l2:	call vputchar	
	pop eax
	ret

vword:
	xchg ah,al
	call vbyte
	xchg ah,al
	call vbyte
	ret

vdword:	
	ror eax,16
	call vword
	ror eax,16
	call vword
	ret
	







