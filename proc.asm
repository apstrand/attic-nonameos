
	
[section .data]

tssd1	equ	300h
pcblen	equ	tssd1
tssd2	equ	8900h

inittssd dd	t0desc

runpcb	dd	0
	
npcbs	dd	0
		
readyf	dd	0
readyl	dd	0

waitpcbf	dd	0
waitpcbl	dd	0

; [section .bss]

pcbs	times pcblen*4	db	0

			
; procfunc	dd	sleep
; procfuncs	equ ($-procfunc)/4

[section .text]

sleep:	push eax
	push ebx
	push ecx
	push edx
	mov ebx,[readyf]
	add eax,[ebx+tspriv]
	mov [ebx+tscpriv],eax	; cpriv = priv + sleep
	mov ecx,[ebx+tsnext]
	mov [readyf],ecx
	mov [ecx+tsprev],ecx	; Ta bort mig ur kön

	mov eax,[waitpcbf]
	cmp eax,[waitpcbl]
	je .l2
	mov [waitpcbf],ebx
	mov [ebx+tsnext],eax
	mov [eax+tsprev],ebx
	mov [ebx+tsprev],ebx
	jmp .l4
.l2:	mov [waitpcbf],ebx
	mov [waitpcbl],ebx
	mov [ebx+tsprev],ebx
	mov [ebx+tsnext],ebx
.l4:	

	mov ecx,[readyf]
	mov eax,[ecx+tspriv]
	mov [ecx+tscpriv],eax
	mov eax,[ecx+tssel]
	mov [gdt+tsw+2],ax
  	jmp tsw:0
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

loadtask:
	push eax
	mov ebx,pcbs
.l1:	cmp dword [ebx+tsstat],-1
	je .l4
	add ebx,pcblen
	jmp .l1
.l4:	call newgdtent
	call addtss		; ebx=pcb ecx=codesel edx=datasel esi=task
	mov eax,[waitpcbl]
	cmp eax,[waitpcbf]
	je .l2			; Waiting kön tom.
	mov [eax+tsnext],ebx
	mov [ebx+tsprev],eax
	mov [ebx+tsnext],ebx
	mov [waitpcbl],ebx
	jmp .l3
.l2:	mov [ebx+tsprev],ebx
	mov [ebx+tsnext],ebx
	mov [waitpcbf],ebx
	mov [waitpcbl],ebx
.l3:	mov dword [ebx+tsstat],0
	pop eax
	ret

runtask:			; PCB i ebx
	push eax
	push ebx
	push ecx
	mov eax,[ebx+tsprev]
	mov ecx,[ebx+tsnext]
	cmp eax,ecx
	jne .l00		; Ensam i kedjan?
	mov dword [waitpcbf],0
	mov dword [waitpcbl],0
	jmp .l0
.l00:	cmp eax,ebx		
	jne .l01		; Först i kedjan?	
	mov [waitpcbf],ecx
	mov [ecx+tsprev],ecx
	jmp .l0
.l01:	cmp ecx,ebx
	jne .l02		; Sist i kedjan?
	mov [waitpcbl],eax
	mov [eax+tsnext],eax
	jmp .l0
.l02:	mov [eax+tsnext],ecx
	mov [ecx+tsprev],eax
	
.l0	mov eax,[ebx+tspriv]
	mov ecx,[readyf]
	cmp ecx,0		; Tom?
	jne .l1
	mov [readyf],ebx
	mov [readyl],ebx
	mov [ebx+tsnext],ebx
	mov [ebx+tsprev],ebx
	jmp .l4
.l1:	cmp [ecx+tsnext],ecx
	je .l3			; I slutet?
	cmp [ecx+tspriv],eax
	ja .l2			; Högre prioritet?
	mov ecx,[ecx+tsnext]
	jmp .l1			; Nästa
.l2:	mov eax,[ecx+tsnext]	; Infoga
	mov [ecx+tsnext],ebx
	mov [ebx+tsnext],eax
	mov [ebx+tsprev],ecx
	mov [eax+tsprev],ebx
	jmp .l4
.l3:	mov [ecx+tsnext],ebx	; Lägg till i slutet
	mov [ebx+tsprev],ecx
	mov [ebx+tsnext],ebx
	mov [readyl],ebx
.l4	mov dword [ebx+tsstat],1
	pop ecx
	pop ebx
	pop eax
	ret


initpcbs:
	push eax
	push ebx
	mov ebx,pcblen
.l1:	mov dword [pcbs+ebx+tsstat],-1
	add ebx,pcblen
	cmp ebx,pcblen*10h
	jb .l1
	mov eax,[inittssd]
	ltr ax
	mov ebx,pcbs
	mov dword [readyf],0
	mov dword [readyl],0
	mov [runpcb],ebx
	mov dword [ebx+tsrun],1
	mov dword [ebx+tscpriv],20
	mov dword [ebx+tspriv],20
	mov dword [ebx+tssel],eax
	mov dword [ebx+tsnext],ebx
	mov dword [ebx+tsprev],ebx
	mov dword [ebx+tsstat],1
	mov dword [ebx+tsofs],0
	mov dword [ebx+tsvscr],0
	pop ebx
	pop eax
	ret

addtss:				; esi=taskptr, ecx=codesel, edx=datasel
	push eax
	push ebx
	push ecx
	push edx
	push edi
	mov edi,ecx
	mov eax,[esi+18h]
	add eax,[esi+1ch]
	mov dword [ebx+tsofs],esi
	mov esi,[esi]
	mov dword [ebx+tseip],esi
	mov dword [ebx+tsesp],eax
	mov eax,ebx
	add eax,pcblen
	mov dword [ebx+tsesp0],eax
	mov dword [ebx+tseflags],202h
	add edi,3
	add edx,3
	mov dword [ebx+tscs],edi
	mov dword [ebx+tsds],edx
	mov dword [ebx+tses],edx
	mov dword [ebx+tsfs],edx
	mov dword [ebx+tsgs],edx
	mov dword [ebx+tsss],edx
	mov dword [ebx+tsss0],krnlds
	mov dword [ebx+tspriv],20
	mov dword [ebx+tscpriv],20
	mov ecx,ebx
	mov eax,tssd1
	mov ebx,tssd2
	call addgdtent
	mov [ecx+tssel],edx
	mov [gdt+edx+2],cx
	bswap ecx
	mov [gdt+edx+4],ch
	mov [gdt+edx+7],cl
	mov [ecx+tssel],edx
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret



