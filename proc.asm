
	
[section .data]

tssd1	equ	300h		; Mall för TSS descriptor
tssd2	equ	8900h		
pcblen	equ	tssd1		; Längd så PCB

inittssd dd	t0desc

runpcb	dd	0

actpcb	dd	0
		
readyf	dd	0		; Pekare till den berömda Ready-kön
readyl	dd	0

waitpcbf	dd	0	; Waiting-kön
waitpcbl	dd	0

procfunc	dd	sleep,loadtask,runtask
procfuncs	equ ($-procfunc)/4
	
[section .bss]

pcbs	times pcblen*10h	resb	1


[section .text]

procih:				; Avbrottshanterare 
	push ds
	push dword krnlds
	pop ds
	cmp bl,procfuncs
	jae .l1
	push ebx
	and ebx,0ffh
	call [procfuncs+ebx*4]
	pop ebx
.l1	pop ds
	iret

waitkbd:
	cli
	push eax
	push ebx
	push ecx
	mov ebx,[runpcb]
	mov dword [ebx+tsstat],2
	call movewait
	pop ecx
	pop ebx
	pop eax
	ret	

	;; Söv en process
	;; Indata:	eax = antas hundradels sekunder som processen ska sova
	
sleep:	push eax
	push ebx
	push ecx
	mov ebx,[runpcb]
	mov [ebx+tssleep],eax		; Flytta till waiting kön
	call movewait
	pop ecx
	pop ebx
	pop eax
	ret


	;; Flyttar aktiv process till waiting kön och hoppar
	;; vidare till nästa.
	
movewait:	
	cli
	mov ebx,[runpcb]
	mov [ebx+tssleep],eax	
	mov eax,[waitpcbf]
	mov ecx,[eax+tsnext]
	mov [eax+tsnext],ebx
	mov [ecx+tsprev],ebx
	mov [ebx+tsprev],eax
	mov [ebx+tsnext],ecx
	mov ebx,[readyf]
	cmp ebx,[readyl]
	jne .l1
	mov dword [readyf],0
	mov dword [readyl],0
	jmp .l2
.l1
	mov eax,[ebx+tsnext]	; Hoppa till nästa process i ready-kön
	mov [readyf],eax
	mov [eax+tsprev],eax
.l2
	mov [runpcb],ebx
	mov eax,[ebx+tssel]
	mov [gdt+tsw+2],ax
	jmp tsw:0	 
	sti
	ret
	

	;; Förbered en process för körning och lägg den i waiting kön
	;; Indata:	esi = pekare till process
	;; Utdata:	ebx = PCB
loadtask:
	push eax
	mov ebx,pcbs
.l1:	cmp dword [ebx+tsstat],-1
	je .l4
	add ebx,pcblen
	jmp .l1
.l4:	call newgdtent
	call addtss		; ebx=pcb ecx=codesel edx=datasel esi=task

	push ecx
	mov eax,[waitpcbf]
	mov ecx,[eax+tsnext]
	mov [eax+tsnext],ebx
	mov [ecx+tsprev],ebx
	mov [ebx+tsprev],eax
	mov [ebx+tsnext],ecx
	pop ecx
	
.l3:	mov dword [ebx+tsstat],0
	pop eax
	ret

	
	;; Flytta en process från waiting till ready kön
	;; och kör igång den.
	;; Indata:	ebx = PCB
runtask:
	push eax
	push ebx
	push ecx

	mov eax,[ebx+tsnext]
	mov ecx,[ebx+tsprev]
	mov [eax+tsprev],ecx
	mov [ecx+tsnext],eax
	mov eax,[ebx+tspriv]
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

	
	;; Initiera pcb-listan
	;; och första pcb:n

initpcbs:
	push eax
	push ebx
	mov ebx,pcbs
	mov [actpcb],ebx
	xor eax,eax
	mov ecx,pcblen*10h/4-4
.l2	mov [ebx+ecx],eax
	sub ecx,4
	jns .l2
	mov ebx,pcblen
.l1	mov dword [pcbs+ebx+tsstat],-1
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
	mov dword [ebx+tscpriv],10
	mov dword [ebx+tspriv],10
	mov dword [ebx+tssel],eax
	mov dword [ebx+tsnext],ebx
	mov dword [ebx+tsprev],ebx
	mov dword [ebx+tsstat],1
	mov ebx,pcbs+pcblen
	mov [waitpcbf],ebx
	mov dword [ebx+tsnext],pcbs+pcblen*2
	mov dword [ebx+tsprev],ebx
	mov dword [ebx+tsstat],0
	mov ebx,pcbs+pcblen*2
	mov [waitpcbl],ebx
	mov dword [ebx+tsprev],pcbs+pcblen
	mov dword [ebx+tsnext],ebx
	mov dword [ebx+tsstat],0
	pop ebx
	pop eax
	ret


	;; skapa PCB och lägg in pekare till TSS:n i GDT:n
	;; Indata:	esi = pekare till processen
	;;		ecx = Kodselector
	;;		edx = Dataselector
addtss:	
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
	mov dword [ebx+tspriv],5
	mov dword [ebx+tscpriv],5
	mov ecx,ebx
	mov eax,tssd1
	mov ebx,tssd2
	call addgdtent
	mov [ecx+tssel],edx
	mov [gdt+edx+2],cx
	bswap ecx
	mov [gdt+edx+4],ch
	mov [gdt+edx+7],cl
	
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret



