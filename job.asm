
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

tssd1	equ	200h
tssd2	equ	8900h

inittssd dd	t0desc
firsttss dd	t0desc
lasttss	 dd	t0desc

tsksel	times	20h*2	dd	0
ntask	dd	0
runtsk  dd	0

ntss	dd	0
runtss	dd	0

tss:
tss0	times 200h db 0
tss1	times 200h db 0
tss2	times 200h db 0


[section .text]


loadtask:			; Returnerar tasknr i eax
	mov eax,[ntask]
	inc eax
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
	ret

addtss:				; esi=taskptr
	push eax
	push ebx
	push ecx
	push edx
	push edi
	mov ecx,eax
	mov ebx,110000h
	shl eax,12
	lea eax,[eax*2+eax]		; tasknr*3*4096
	add ebx,eax
	shl ecx,9			; tasknr*200h
	mov dword [ecx+tss+tseip],esi
	mov dword [ecx+tss+tsesp],ebx
	add ebx,10000h
	mov dword [ecx+tss+tsesp0],ebx
	mov dword [ecx+tss+tseflags],202h
	mov dword [ecx+tss+tscs],c3d
	mov dword [ecx+tss+tsds],d3d
	mov dword [ecx+tss+tses],d3d
	mov dword [ecx+tss+tsfs],d3d
	mov dword [ecx+tss+tsgs],d3d
	mov dword [ecx+tss+tsss],d3d
	mov dword [ecx+tss+tsss0],d0d
	mov edi,ecx
	shr edi,9
	mov dword [ecx+tss+tsnum],edi
	add ecx,tss
	push ecx
	mov eax,tssd1
	mov ebx,tssd2
	call addgdtsel
	mov [1000h+edx+2],cx
	bswap ecx
	mov [1000h+edx+4],ch
	mov [1000h+edx+7],cl
	mov [tsksel+edi*8],edx
	pop ebx
	mov [tsksel+edi*8+4],ebx
	add word [lasttss],8
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
