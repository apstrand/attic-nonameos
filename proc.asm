

	
[section .data]

tssd1	equ	200h
tssd2	equ	8900h

inittssd dd	t0desc

tsksel	times	40h*2	dd	0
ntask	dd	0
runtsk  dd	0

ntss	dd	0
runtss	dd	0

tss:
tss0	times 200h db 0
tss1	times 200h db 0
tss2	times 200h db 0

procfunc:	dd	sleep
procfuncs	equ ($-procfunc)/4

[section .text]

procih:	push ds
	push dword krnlds
	pop ds
	cmp bl,[procfuncs]
	ja .l1
	and ebx,0fh
	call [procfunc+ebx*4]
.l1:	pop ds
	iret
	
sleep:	push ebx		; tid i eax (i .01 sek)
	mov ebx,[runtsk]
	mov ebx,[tsksel+ebx*8+4]
	mov [ebx+tssleep],eax
	mov dword [ebx+tsrun],0
	pop ebx
	ret

loadtask:			; Returnerar tasknr i eax
	mov eax,[ntask]
	inc eax
 	call newgdtent
	call addtss
	mov [ntask],eax
	ret

runtask:			; Tasknr i eax
	push eax
	mov eax,[tsksel+eax*8+4]
	mov dword [eax+tsrun],1
	pop eax
	ret


inittss:
	mov eax,[inittssd]
	ltr ax
	mov [tsksel],eax
	mov eax,tss0
	mov [runtss],eax
	mov [tsksel+4],eax
	mov dword [eax+tsrun],1
	mov dword [eax+tscpriv],10
	mov dword [eax+tspriv],10
	ret

addtss:				; esi=taskptr
	push eax
	push ebx
	push ecx
	push edx
	push edi
	mov edi,ecx
	mov ecx,eax
	shl ecx,9			; tasknr*200h
	mov ebx,[esi+18h]
	add ebx,[esi+1ch]
	mov dword [ecx+tss+tsofs],esi
	mov esi,[esi]
	mov dword [ecx+tss+tseip],esi
	mov dword [ecx+tss+tsesp],ebx
	mov ebx,10000h
	add ebx,ecx
	mov dword [ecx+tss+tsesp0],ebx
	mov dword [ecx+tss+tseflags],202h
	add edi,3
	add edx,3
	mov dword [ecx+tss+tscs],edi
	mov dword [ecx+tss+tsds],edx
	mov dword [ecx+tss+tses],edx
	mov dword [ecx+tss+tsfs],edx
	mov dword [ecx+tss+tsgs],edx
	mov dword [ecx+tss+tsss],edx
	mov dword [ecx+tss+tsss0],krnlds
	mov dword [ecx+tss+tspriv],20
	mov dword [ecx+tss+tscpriv],20
	mov edi,ecx
	shr edi,9
	mov dword [ecx+tss+tsnum],edi
	add ecx,tss
	push ecx
	mov eax,tssd1
	mov ebx,tssd2
	call addgdtent
	mov [1000h+edx+2],cx
	bswap ecx
	mov [1000h+edx+4],ch
	mov [1000h+edx+7],cl
	mov [tsksel+edi*8],edx
	pop ebx
	mov [tsksel+edi*8+4],ebx
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret



