[section .data]


tmrd:	dd	072f075ch
	dd	072d072dh
	dd	075c072fh
	dd	077c077ch
	dd	0
		
tmrc:	dd	10h

	

kbdbuf:	times 40h db
kbdbeg:	dd	0
kbdend:	dd	0
	

exp0msg:	db	'Divide Error',0
exp1msg:	db	'Debug Exception',0
exp2msg:	db	'Non Maskable Interrupt',0
exp3msg:	db	'Breakpoint',0
exp4msg:	db	'Overflow',0
exp5msg:	db	'Bounds Check',0
exp6msg:	db	'Invalid Opcode',0
exp7msg:	db	'Coprocessor Not Availible',0
exp8msg:	db	'Double Fault',0
exp9msg:	db	'Coprocessor Segment Overrun',0
exp10msg:	db	'Invalid TSS',0
exp11msg:	db	'Segment Not Present',0
exp12msg:	db	'Stack Exception',0
exp13msg:	db	'General Protection Fault',0
exp14msg:	db	'Page Fault',0
exp15msg:	db	'Exception 15',0
exp16msg:	db	'Coprocessor Error',0

eheax:	db	'EAX: '
ehebx:	db	'EBX: '
ehecx:	db	'ECX: '
ehedx:	db	'EDX: '
ehesi:	db	'ESI: '
ehedi:	db	'EDI: '
ehebp:	db	'EBP: '
	
ehesp:	db	'ESP: '
eheip:	db	'EIP: '
ehcs:	db	'CS:  '
ehds:	db	'DS:  '
ehes:	db	'ES:  '
ehfs:	db	'FS:  '
ehgs:	db	'GS:  '
ehss:	db	'SS:  '
	
	

[section .text]
	
irq0:	push eax
	push ebx
	push ecx
	push ds
	mov eax,krnlds
	mov ds,ax
  	dec dword [tmrc]
  	jnz .l1
  	mov dword [tmrc],10h
	mov eax,[tmrd+16]
	inc dword [tmrd+16]
	and eax,03h
	mov eax,[tmrd+eax*4]
	mov [0b8000h+78*2],eax
.l1:	xor eax,eax
.l6:	mov ebx,[tsksel+eax*8+4]
	dec dword [ebx+tscpriv]
	inc dword [ebx+tsttime]
	inc eax
	cmp eax,[ntask]
	jbe .l6
	mov eax,[runtsk]
.l4:	inc eax
	cmp eax,[ntask]
	jbe .l2
	xor eax,eax
.l2:	cmp eax,[runtsk]
	je .l3
	mov ebx,[tsksel+eax*8+4]
	cmp dword [ebx+tsrun],1
	jne .l4
	add dword [ebx+tscpriv],0
	jns .l4
	mov [runtsk],eax
	inc dword [ebx+tstime]
	push dword [ebx+tspriv]
	pop dword [ebx+tscpriv]
 	mov eax,[tsksel+eax*8]
	mov [1000h+tsw+2],ax
	mov al,20h
 	out 20h,al
	pop ds
	pop ecx
	pop ebx
 	pop eax
  	jmp tsw:0
	iret
.l3:	mov ebx,[tsksel+eax*8+4]
	inc dword [ebx+tstime]
	push dword [ebx+tspriv]
	pop dword [ebx+tscpriv]	
	mov al,20h
 	out 20h,al
	pop ds
	pop ecx
	pop ebx
	pop eax
	iret

irq1:	push ds
	push eax
	mov eax,krnlds
	mov ds,ax
	push ebx
	in al,60h
	mov ebx,[kbdend]
	inc ebx
	and ebx,03fh
	cmp [kbdbeg],ebx
	je .l1
	mov [kbdbuf+ebx],al
.l1:	pop ebx
	pop eax
	pop ds
	iret

	
dummyh:	
	iret



exp0:	pushad
	mov esi,exp0msg
	call ehregs
	hlt
	
exp1:	pushad
	mov esi,exp1msg
	call ehregs
	hlt
		
exp2:	pushad
	mov esi,exp2msg
	call ehregs
	hlt
	
exp3:	pushad
	mov esi,exp3msg
	call ehregs
	hlt
	
exp4:	pushad
	mov esi,exp4msg
	call ehregs
	hlt
	
exp5:	pushad
	mov esi,exp5msg
	call ehregs
	hlt
	
exp6:	pushad
	mov esi,exp6msg
	call ehregs
	hlt
	
exp7:	pushad
	mov esi,exp7msg
	call ehregs
	hlt
	
exp8:	add esp,4
	pushad
	mov esi,exp8msg
	call ehregs
	hlt
	
exp9:	pushad
	mov esi,exp9msg
	call ehregs
	hlt
	
exp10:	add esp,4
	pushad
	mov esi,exp10msg
	call ehregs
	hlt
	
exp11:	add esp,4
	pushad
	mov esi,exp11msg
	call ehregs
	hlt
	
exp12:	add esp,4
	pushad
	mov esi,exp12msg
	call ehregs
	hlt
	
exp13:	add esp,4
	pushad
	mov esi,exp13msg
	call ehregs
	hlt
	
exp14:	add esp,4
	pushad
	mov esi,exp14msg
	call ehregs
	hlt
	
exp15:	pushad
	mov esi,exp15msg
	call ehregs
	hlt
	
exp16:	pushad
	mov esi,exp16msg
	call ehregs
	hlt
	

ehregs:	mov ax,krnlds
	mov ds,ax
	mov ah,0fh
	xor ebx,ebx
.l1:	mov al,[esi+ebx]
	or al,al
	jz .l2
	mov [0b8000h+ebx*2],ax
	inc ebx
	jmp .l1

.l2:
	mov eax,[esp+32]
	mov edi,160
	mov esi,eheax
	call ehdword
	mov eax,[esp+20]
	mov edi,160+30
	mov esi,ehebx
	call ehdword
	mov eax,[esp+28]
	mov esi,ehecx
	mov edi,160+60
	call ehdword
	mov eax,[esp+24]
	mov esi,ehedx
	mov edi,160+90
	call ehdword
	
	mov eax,[esp+8]
	mov edi,320
	mov esi,ehesi
	call ehdword
	mov eax,[esp+4]
	mov edi,320+30
	mov esi,ehedi
	call ehdword
	mov eax,[esp+12]
	mov esi,ehebp
	mov edi,320+60
	call ehdword
	
	xor eax,eax
	mov ax,ds
	mov edi,480
	mov esi,ehds
	call ehdword
	mov ax,es
	mov edi,480+30
	mov esi,ehes
	call ehdword
	mov ax,fs	
	mov esi,ehfs
	mov edi,480+60
	call ehdword
	mov ax,gs	
	mov esi,ehgs
	mov edi,480+90
	call ehdword
	
	mov eax,[esp+40]
	mov edi,640
	mov esi,ehcs
	call ehdword
	mov eax,[esp+44]
	mov edi,640+30
	mov esi,eheip
	call ehdword
	mov eax,[esp+52]
	mov esi,ehss
	mov edi,640+60
	call ehdword
	mov eax,[esp+56]
	mov esi,ehesp
	mov edi,640+90
	call ehdword
	
	ret

	
	
		
ehdword: mov bh,0fh
	mov ecx,5
.l1:	mov bl,[esi]
	mov [0b8000h+edi],bx
	add edi,2
	inc esi
	loop .l1
	mov cl,4
.l3:	xor ebx,ebx
	shld ebx,eax,cl
	and bl,0fh
	add bl,30h
	cmp bl,39h
	jbe .l2
	add bl,7
.l2:	mov bh,0fh
	mov [0b8000h+edi],bx
	add edi,2
	add cl,4
	cmp cl,32
	jbe .l3
	mov eax,0f200f20h
	mov [0b8000h+edi],eax
	add edi,4
	ret







