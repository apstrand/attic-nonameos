[absolute 0]
	tsblink	resw	2
	tsesp0	resd	1
	tsss0	resw	2
	tsesp1	resd	1
	tsss1	resw	2
	tsesp2	resd	1
	tsss2	resw	2
	tscr3	resd	1
	tseip	resd	1
	tseflags resd	1
	tseax	resd	1
	tsecx	resd	1
	tsedx	resd	1
	tsebx	resd	1
	tsesp	resd	1
	tsebp	resd	1
	tsesi	resd	1
	tsedi	resd	1
	tses	resw	2
	tscs	resw	2
	tsss	resw	2
	tsds	resw	2
	tsfs	resw	2
	tsgs	resw	2
	tsldt	resw	2
	tsio	resd	1

	tsname	resb	20h
	tsnum	resd	1
	tsrun	resd	1
	tstime	resd	1
	tsvofs	resd	1
	tsvscr	resd	1
	tsvpos	resd	1
	
		

[section .data]

tskcodebase	equ	100000h
tskdatabase	equ	101000h
tskstackbase	equ	102000h
	
tssptr:	dd	0
	dd	t0desc
	
inittssd dd	t0desc
firsttss dd	t0desc
lasttss	 dd	t0desc

ntss	dd	0
runtss	dd	0
	
tss:	
tss0:	times 200h db 0
tss1:	times 200h db 0
tss2:	times 200h db 0

t1msg:	db 'Hello World...',0	
t2msg:	db 'Hello World again...',0	
trn:	db '-\|/'
	
[section .text]

loadtask:			; Returnerar tasknr i eax
	mov eax,[ntss]
	inc eax
	call addtss
	mov [ntss],eax
	ret	

runtask:			; Tasknr i eax
	push eax
	shl eax,9
	mov dword [eax+tss+tsrun],1
	pop eax
	ret
		
			
inittss:
	mov eax,[inittssd]
	ltr ax
	sub eax,t0desc
	shl eax,6
	add eax,tss
	mov [runtss],eax
	mov dword [eax+tsrun],1	
	mov dword [eax+tsnum],0
	mov dword [eax+tstime],0
	mov dword [eax+tsvofs],0
	mov dword [eax+tsvscr],0
	mov dword [eax+tsvpos],0
	ret
	
addtss:				; eax=tasknr esi=taskptr
	push eax
	push ebx
	push ecx
	mov ecx,eax
	mov ebx,tskstackbase
	shl eax,12
	lea eax,[eax*2+eax]	; tasknr*3*4096
	add ebx,eax
	shl ecx,9		; tasknr*200h
	mov dword [ecx+tss+tseip],esi
	mov dword [ecx+tss+tsesp],ebx
	add ebx,100000h
	mov dword [ecx+tss+tsesp0],ebx
	mov dword [ecx+tss+tseflags],202h
	mov dword [ecx+tss+tscs],c3d
	mov dword [ecx+tss+tsds],d3d
	mov dword [ecx+tss+tses],d3d
	mov dword [ecx+tss+tsfs],d3d
	mov dword [ecx+tss+tsgs],d3d
	mov dword [ecx+tss+tsss],d3d
	mov dword [ecx+tss+tsss0],d0d
	mov dword [ecx+tss+tsldt],0
	mov dword [ecx+tss+tsrun],0
	mov eax,ecx
	shr eax,9
	mov dword [ecx+tss+tsnum],eax
	mov dword [ecx+tss+tstime],0
	mov dword [ecx+tss+tsvscr],0
	mov dword [ecx+tss+tsvofs],0
	mov dword [ecx+tss+tsvpos],0
	add ecx,tss
	mov [gdt+eax*8+2+18h],cx
  	add word [lasttss],8
	pop ecx
	pop ebx
	pop eax
	ret
	


task1:	mov ax,1000h
	mov bl,1
	call vid3:0
	mov esi,t1msg
	mov bl,5
 	call vid3:0
	xor edx,edx
	mov bl,4
.l1:	mov al,[trn+edx]
	call vid3:0
	mov ecx,100000h
	loop $
	mov al,8
	call vid3:0
	inc dl
	and dl,3
	jmp .l1
	
task2:	mov ax,1200h
	mov bl,1
	call vid3:0
	mov esi,t2msg
	mov bl,5
 	call vid3:0
	xor edx,edx
	mov bl,4
.l1:	mov al,[trn+edx]
	call vid3:0
	mov ecx,100000h
	loop $
	mov al,8
	call vid3:0
	inc dl
	and dl,3
	jmp .l1
	
		
