[section .data]




[section .text]

kbdget:	push ebx		; V�ntar p� tangentnedslag och returnerar scankoden i al
.l1:	mov ebx,[kbdbeg]
	cmp [kbdend],ebx
	je .l1
	xor eax,eax
	mov al,[kbdbuf+ebx]
	inc dword [kbdbeg]
	and dword [kbdbeg],3fh
	pop ebx
	ret

kbdchk:	push ebx		; z = inga scankoder v�ntar...
	mov ebx,[kbdend]
	cmp ebx,[kbdbeg]
	pop ebx
	ret

	
