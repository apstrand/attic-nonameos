[section .data]


tmrd	dd	072f075ch
	dd	072d072dh
	dd	075c072fh
	dd	077c077ch
	dd	0
		
tmrc	dd	10h

tmrs	dd	0
which	dd	0

	

[section .text]

	;; Timeravbrottshanteraren
	
	;; Ritar lite streck i övre högra hörnet så man ser att den lever...
	;; Går igenom waiting-kön och flyttar över processer som
	;; ska köras till Ready-kön
	;; Lägger den aktuella processen på rätt ställe i ready-kön
	;; och hoppar till processen längs fram i ready-kön
	
		
irq0:	push eax
	push ebx
	push ecx
	push edx
	push ds
	mov eax,krnlds
	mov ds,ax
	
  	dec dword [tmrc]
  	jnz .l1
	mov dword [tmrc],10h
	mov eax,[tmrd+16]
	inc dword [tmrd+16]
	and eax,03h
	mov eax,[tmrd+eax*4]	; ritar ut snurrande | i övre högra hörnet,
	mov [0b80a0h+78*2],eax	; så man ser att datorn inte har totalhängt...
	
.l1	mov eax,[waitpcbf]
	mov edx,[eax+tsnext]
.lw	mov eax,edx
	mov edx,[eax+tsnext]
	inc dword [eax+tsttime]	  ; öka ttime (=total körtid) för alla
	cmp dword [eax+tssleep],0 ; processer i waiting-kön
	je .lns
	dec dword [eax+tssleep]
	jz .la			; Sovit klart?
.lns	cmp dword [eax+tsstat],2 ; väntar på inmatning
	jne near .lg
	cmp dword [pcbs+tskf],1
	jne .lg	
.la	mov dword [eax+tscpriv],-10
	mov dword [eax+tsstat],1
	mov ebx,[eax+tsnext]	; Lägg in i ready-kön
	mov ecx,[eax+tsprev]
	mov [ebx+tsprev],ecx
	mov [ecx+tsnext],ebx
	cmp dword [readyf],0
	jne .lg1
	mov [readyf],eax
	mov [readyl],eax
	mov [eax+tsprev],eax
	mov [eax+tsnext],eax
	jmp .lg
.lg1	mov ebx,[readyf]
	mov [readyf],eax
	mov [eax+tsprev],eax
	mov [eax+tsnext],ebx
	mov [ebx+tsprev],eax
.lg
	cmp edx,[waitpcbl]
	jne near .lw

	
.l2	mov eax,[readyf]	; öka ttime och minska cpriv för alla
	cmp eax,0		; processer i ready-kön
	je .l3
.lr	inc dword [eax+tsttime]
	dec dword [eax+tscpriv]
	cmp eax,[readyl]
	je .l3
	mov eax,[eax+tsnext]
	jmp .lr

.l3	mov ebx,[runpcb]
	dec dword [ebx+tscpriv]	; Minska prioritet för aktiv process
	cmp dword [readyf],0
	je near .l20.1		; Är jag ensam?
	cmp dword [ebx+tscpriv],0
	jns near .l20.2		; Ingen annan som vill köra?

.l100
	mov ecx,[readyf]
	cmp ecx,[readyl]
	jne .l4			; Bara en process i ready-kön?
	mov [readyf],ebx
	mov [readyl],ebx
	mov [ebx+tsprev],ebx
	mov [ebx+tsnext],ebx
	jmp .l12
.l4	
	mov eax,[ebx+tspriv]	; Går igenom ready-kön för att hitta 
.l5	mov ecx,[ecx+tsnext]	; rätt ställe att skjuta in aktuell process
	cmp ecx,[readyl]
 	je .l6
	cmp [ecx+tscpriv],eax
	jbe .l5
	mov edx,[ecx+tsnext]
	mov [ecx+tsnext],ebx
	mov [edx+tsprev],ebx
	mov [ebx+tsprev],ecx
	mov [ebx+tsnext],edx
	jmp .l10
.l6	mov [ecx+tsnext],ebx
	mov [readyl],ebx
	mov [ebx+tsprev],ecx
	mov [ebx+tsnext],ebx
.l10	
	mov ecx,[readyf]	; Tar bort första processen i kön...
	mov ebx,[ecx+tsnext]
	mov [readyf],ebx
	mov [ebx+tsprev],ebx
	
.l12	mov [runpcb],ecx	; ...och förbereder att skifta till den
	mov eax,[ecx+tspriv]
	mov [ecx+tscpriv],eax
	inc dword [ecx+tstime]
	mov eax,[ecx+tssel]
	mov [gdt+tsw+2],ax
	mov al,20h		; Meddela PIC:n att jag är klar
	out 20h,al
	pop ds
	pop edx
	pop ecx
	pop ebx
 	pop eax
  	jmp tsw:0		; Hoppa till nästa process!
	iret
	
.l20.1	mov eax,[ebx+tspriv]	; Om samma process ska fortsätta....
	mov [ebx+tscpriv],eax
.l20.2	inc dword [ebx+tstime]
	mov al,20h
 	out 20h,al
	pop ds
	pop edx
	pop ecx
	pop ebx
	pop eax
	iret


	
	;; Tangentbordsavbrottshanterare
	;; Fyller på kbdbuf och skiftar "skärm"
	
irq1:	push ds
	push eax
	mov eax,krnlds
	mov ds,ax
	push ebx
	push ecx
	in al,60h		; Hämta scankod
	cmp al,0e0h
	jne .l2			; Utökad?
	in al,60h		; om ja, läs in scankoden
.l2	test al,80h
	jnz .l1			; Hoppa över release koder.
	cmp al,3bh		; <F1
	jb .l3
	cmp al,42h		; >F8
	ja .l3
	sub al,3bh
	and eax,7
	push edx
	imul eax,80*25*2	; eax: F1=0 F2=4000 F3=8000 osv...
	pop edx
	call vidsscr		; F1-F8 skiftar "skärm"
	jmp .l1
.l3
	mov ecx,[actpcb]
	and eax,0ffh
	mov [pcbs+tskey],al
	mov dword [pcbs+tskf],1
.l1	mov al,20h
	out 20h,al		; Färdig!
	pop ecx
	pop ebx
	pop eax
	pop ds
	iret

	
dummyh:	
	iret

[section .data]

exp0msg	db	'Divide Error',0
exp1msg	db	'Debug Exception',0
exp2msg	db	'Non Maskable Interrupt',0
exp3msg	db	'Breakpoint',0
exp4msg	db	'Overflow',0
exp5msg	db	'Bounds Check',0
exp6msg	db	'Invalid Opcode',0
exp7msg	db	'Coprocessor Not Availible',0
exp8msg	db	'Double Fault',0
exp9msg	db	'Coprocessor Segment Overrun',0
exp10msg	db	'Invalid TSS',0
exp11msg	db	'Segment Not Present',0
exp12msg	db	'Stack Exception',0
exp13msg	db	'General Protection Fault',0
exp14msg	db	'Page Fault',0
exp15msg	db	'Exception 15',0
exp16msg	db	'Coprocessor Error',0

eheax	db	'EAX: '
ehebx	db	'EBX: '
ehecx	db	'ECX: '
ehedx	db	'EDX: '
ehesi	db	'ESI: '
ehedi	db	'EDI: '
ehebp	db	'EBP: '
	
ehesp	db	'ESP: '
eheip	db	'EIP: '
ehcs	db	'CS:  '
ehds	db	'DS:  '
ehes	db	'ES:  '
ehfs	db	'FS:  '
ehgs	db	'GS:  '
ehss	db	'SS:  '
dummy	db	'     '	



	
[section .text]

	;; Exception handling......

	
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
.l1	mov al,[esi+ebx]
	or al,al
	jz .l2
	mov [0b8000h+ebx*2],ax
	inc ebx
	jmp .l1

.l2
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
	mov eax,[runpcb]
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
.l1	mov bl,[esi]
	mov [0b8000h+edi],bx
	add edi,2
	inc esi
	loop .l1
	mov cl,4
.l3	xor ebx,ebx
	shld ebx,eax,cl
	and bl,0fh
	add bl,30h
	cmp bl,39h
	jbe .l2
	add bl,7
.l2	mov bh,0fh
	mov [0b8000h+edi],bx
	add edi,2
	add cl,4
	cmp cl,32
	jbe .l3
	mov eax,0f200f20h
	mov [0b8000h+edi],eax
	add edi,4
	ret






