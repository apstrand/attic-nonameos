
[section .data]

vbusy:	db	0
	
vfunc:	dd vcls,vsetpos,vgetpos,vgetrpos,vputchar,vwstr,vbyte,vword,vdword,sleep
vfuncs	equ	($-vfunc)/4
					
[section .text]
	
	;; Video routines
	;; bl = function
	;; 0 = Clear Screen
	;; 1 = Set cursorposition
	;; 	ax = RRCC
	;; 2 = Get cursorposition
	;; 	ax = RRCC
	;; 3 = Get real cursorposition
	;; 	ax = RRCC
	;; 4 = Put char
	;; 	al = char
	;; 5 = Write ASCIIZ string
	;; 	esi = string
	;; 6 = Write Byte
	;; 	al = byte
	;; 7 = Write Word
	;; 	ax = word
	;; 8 = Write Doubleword
	;; 	eax = dword

vidih:				; Avbrotts hanterare för video funktioner
	push ds
	push dword krnlds
	pop ds
	cmp bl,[vfuncs]
	ja .l1
	push ebx
	and ebx,0ffh
	call [vfunc+ebx*4]
	pop ebx
.l1:	pop ds
	iret

vcls:
	push eax
	push ebx
	push edx
	mov edx,[runpcb]
	mov ebx,[edx+tsvscr]
	mov eax,80*25*2
	add ebx,0b8000h
.l1:	sub eax,4
	mov dword [ebx+eax],07200720h
	jnz .l1
	xor eax,eax
	mov [edx+tsvpos],eax
	mov [edx+tsvofs],eax
	mov dx,3d4h
	mov ax,0dh
	out dx,ax
	mov ax,0eh
	out dx,ax
	pop edx
	pop ebx
	pop eax
	ret

vsetpos:			; ax = RRCC
	push eax
	push ebx
	push edx
	push edi
	mov edi,[runpcb]
	mov [edi+tsvpos],ax
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
	mov [edi+tsvofs],ebx
	pop edi
	pop edx
	pop ebx
	pop eax
	ret

	
vgetpos:
	mov eax,[runpcb]
	mov eax,[eax+tsvpos]
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
	mov ebx,[runpcb]
	mov [ebx+tsvofs],ax
	shr ax,1
	mov cl,80
	div cl
	xchg ah,al
	mov [ebx+tsvpos],ax
	pop edx
	pop ebx
	ret
	
vputchar:			; tecken i al
	push eax
	cmp al,8
	jne .l1
	call vgetpos
	dec al
	call vsetpos
	pop eax
	ret
.l1:	cmp al,0ah
	jne .l2
	call vgetpos
	xor al,al
	inc ah
	call vsetpos
	pop eax
	ret
.l2:	push ebx
	push ecx
	mov ecx,[runpcb]
	mov ebx,[ecx+tsvofs]
	add ebx,[ecx+tsvscr]
	mov ah,07h
	mov [0b8000h+ebx],ax
	call vgetpos
	inc al
	call vsetpos
	pop ecx
	pop ebx
	pop eax
	ret
	
vwstr:				; sträng i esi
	push eax
	mov eax,[runpcb]
	add esi,[eax+tsofs]
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
