[section .data]


tmrd:	dd	072f075ch
	dd	072d072dh
	dd	075c072fh
	dd	077c077ch
	dd	0
		
tmrc:	dd	10h

tmrs dd 0
which dd 0	

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
	mov [0b80a0h+78*2],eax
.l1:	mov eax,[waitpcbf]
	or eax,eax
	jz .l2
.lw:	inc dword [eax+tsttime]
	cmp eax,[waitpcbl]
	je .l2
	mov eax,[eax+tsnext]
	jmp .lw
.l2:	
	mov eax,[readyf]
.lr:	inc dword [eax+tsttime]
	dec dword [eax+tscpriv]
	cmp eax,[readyl]
	je .l3
	mov eax,[eax+tsnext]
	jmp .lr
.l3:	
	mov ebx,[readyf]
	cmp ebx,[readyl]
	je near .l20.1
.l21:	cmp dword [ebx+tscpriv],0
	jns near .l20.2
.l20z:	
	mov eax,[ebx+tspriv]
	mov edx,[ebx+tsnext]
	mov ecx,ebx
	
.l5:	mov ecx,[ecx+tsnext]
	cmp ecx,[readyl]
 	je .l6			; Sist
	cmp [ecx+tscpriv],eax
	jbe .l5
	mov [readyf],edx	; Infoga
	mov [edx+tsprev],edx
	mov edx,[ecx+tsnext]
	mov [ecx+tsnext],ebx
	mov [edx+tsprev],ebx
	mov [ebx+tsprev],ecx
	mov [ebx+tsnext],edx
	jmp .l10
.l6:	mov [ecx+tsnext],ebx
	mov [readyl],ebx
	mov [ebx+tsprev],ecx
	mov [ebx+tsnext],ebx
	mov [readyf],edx
	mov [edx+tsprev],edx
.l10:	mov ebx,[readyf]
	mov [runpcb],ebx
	mov eax,[ebx+tspriv]
	mov [ebx+tscpriv],eax
	inc dword [ebx+tstime]
	mov eax,[ebx+tssel]
	mov [gdt+tsw+2],ax
	mov al,20h
	out 20h,al
	pop ds
	pop ecx
	pop ebx
 	pop eax
  	jmp tsw:0
	iret
	
.l20.1:	mov eax,[ebx+tspriv]
	mov [ebx+tscpriv],eax
.l20.2:	inc dword [ebx+tstime]
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
	mov [kbdend],ebx
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
	jmp $
	
exp1:	pushad
	mov esi,exp1msg
	call ehregs
	jmp $
		
exp2:	pushad
	mov esi,exp2msg
	call ehregs
	jmp $
	
exp3:	pushad
	mov esi,exp3msg
	call ehregs
	jmp $
	
exp4:	pushad
	mov esi,exp4msg
	call ehregs
	jmp $
	
exp5:	pushad
	mov esi,exp5msg
	call ehregs
	jmp $
	
exp6:	pushad
	mov esi,exp6msg
	call ehregs
	jmp $
	
exp7:	pushad
	mov esi,exp7msg
	call ehregs
	jmp $
	
exp8:	add esp,4
	pushad
	mov esi,exp8msg
	call ehregs
	jmp $
	
exp9:	pushad
	mov esi,exp9msg
	call ehregs
	jmp $
	
exp10:	add esp,4
	pushad
	mov esi,exp10msg
	call ehregs
	jmp $
	
exp11:	add esp,4
	pushad
	mov esi,exp11msg
	call ehregs
	jmp $
	
exp12:	add esp,4
	pushad
	mov esi,exp12msg
	call ehregs
	jmp $
	
exp13:	add esp,4
	pushad
	mov esi,exp13msg
	call ehregs
	jmp $
	
exp14:	add esp,4
	pushad
	mov esi,exp14msg
	call ehregs
	jmp $
	
exp15:	pushad
	mov esi,exp15msg
	call ehregs
	jmp $
	
exp16:	pushad
	mov esi,exp16msg
	call ehregs
	jmp $
	

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
	
	mov eax,[esp+48]
	mov edi,640
	mov esi,ehcs
	call ehdword
	mov eax,[esp+44]
	mov edi,640+30
	mov esi,eheip
	call ehdword
	mov eax,[readyf]
	mov esi,ehss
	mov edi,640+60
	call ehdword
; 	mov eax,[esp+56]
; 	mov esi,ehesp
; 	mov edi,640+90
; 	call ehdword
	
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







