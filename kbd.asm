[section .data]


[section .text]

kbdih:
	iret
	
kbdget:				; V�ntar p� tangentnedslag och returnerar scankoden i al
	call waitkbd
	mov al,[pcbs+tskey]
	mov dword [pcbs+tskf],0
	ret

kbdchk:				; z = inga scankoder v�ntar...
	cmp byte [pcbs+tskf],0
	ret
	