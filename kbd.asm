[section .data]


[section .text]

kbdih:
	iret
	
kbdget:	push ebx		; Väntar på tangentnedslag och returnerar scankoden i al
	call waitkbd
	xor eax,eax
	mov eax,[pcbs+tskb]
	inc eax
	and eax,0fh
	mov [pcbs+tskb],eax
	dec dword [pcbs+tsnkb]
	mov al,[pcbs+tskbd+eax]
	pop ebx
	ret

kbdchk:	push eax		; z = inga scankoder väntar...
	push ebx
	mov ebx,[runpcb]
	mov eax,[ebx+tskb]
	cmp eax,[ebx+tske]
	pop ebx
	pop eax
	ret
	
