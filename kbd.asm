[section .data]

kbdbuf	times 40h db 0
kbdbeg	dd	0
kbdend	dd	0
	

[section .text]

kbdih:
	iret
	
kbdget:	push ebx		; Väntar på tangentnedslag och returnerar scankoden i al
.l1:	mov ebx,[kbdbeg]
	cmp [kbdend],ebx
	je .l1
	xor eax,eax
	inc ebx
	and ebx,3fh
	mov [kbdbeg],ebx
	mov al,[kbdbuf+ebx]
	pop ebx
	ret

kbdchk:	push ebx		; z = inga scankoder väntar...
	mov ebx,[kbdend]
	cmp ebx,[kbdbeg]
	pop ebx
	ret
	
