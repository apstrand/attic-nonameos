[bits 32]
[org 0h]
	
[section .data]
dbeg:	

	
dlen	equ	$-dbeg

[section .bss]
bbeg:

		
[section .text]
cbeg:	
	dd	monitor,clen
 	dd	dbeg,dlen
	dd	bbeg,0
	dd	bbeg,1024
	
monitor:
	jmp $
	

	
	times ($$-$) & 3 db 0
		
clen	equ	$-cbeg

[section .data]
	times 1000h-(clen+dlen) db 0


