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
	

exp0msg:	db	'Divide Error CS:EIP=',0
exp1msg:	db	'Debug Exception CS:EIP=',0
exp2msg:	db	'Non Maskable Interrupt CS:EIP=',0
exp3msg:	db	'Breakpoint CS:EIP=',0
exp4msg:	db	'Overflow CS:EIP=',0
exp5msg:	db	'Bounds Check CS:EIP=',0
exp6msg:	db	'Invalid Opcode CS:EIP=',0
exp7msg:	db	'Coprocessor Not Availible CS:EIP=',0
exp8msg:	db	'Double Fault CS:EIP=',0
exp9msg:	db	'Coprocessor Segment Overrun CS:EIP=',0
exp10msg:	db	'Invalid TSS CS:EIP=',0
exp11msg:	db	'Segment Not Present CS:EIP=',0
exp12msg:	db	'Stack Exception CS:EIP=',0
exp13msg:	db	'General Protection Fault CS:EIP=',0
exp14msg:	db	'Page Fault CS:EIP=',0
exp15msg:	db	'Exception 15 CS:EIP=',0
exp16msg:	db	'Coprocessor Error CS:EIP=',0
	
	

[section .text]
	
irq0:	push eax
	push ebx
  	dec dword [tmrc]
  	jnz .l1
  	mov dword [tmrc],10h
	mov eax,[tmrd+16]
	inc dword [tmrd+16]
	and eax,03h
	mov eax,[tmrd+eax*4]
	mov [0b8000h+78*2],eax
.l1:	mov al,20h
 	out 20h,al
	cmp byte [ntss],0
	je .l3
  	mov eax,[tssptr+4]
.l4:	add eax,8
  	cmp eax,[lasttss]
  	jbe .l2
  	mov eax,[firsttss]
.l2: 	mov ebx,eax
	sub ebx,t0desc
	shl ebx,6
	cmp dword [ebx+tss+tsrun],1
  	jne .l4
	add ebx,tss
	mov [runtss],ebx
	mov [tssptr+4],eax
	pop ebx
 	pop eax
  	jmp far [tssptr]
	iret
.l3:	pop ebx
	pop eax
	iret

irq1:	push eax
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
	ret

	
dummyh:	
	iret



exp0:	mov esi,exp0msg
	jmp cexp
	
exp1:	mov esi,exp1msg
	jmp cexp
		
exp2:	mov esi,exp2msg
	jmp cexp
	
exp3:	mov esi,exp3msg
	jmp cexp
	
exp4:	mov esi,exp4msg
	jmp cexp
	
exp5:	mov esi,exp5msg
	jmp cexp
	
exp6:	mov esi,exp6msg
	jmp cexp
	
exp7:	mov esi,exp7msg
	jmp cexp
	
exp8:	mov esi,exp8msg
	pop eax
	jmp cexp
	
exp9:	mov esi,exp9msg
	jmp cexp
	
exp10:	mov esi,exp10msg
	pop eax
	jmp cexp
	
exp11:	mov esi,exp11msg
	pop eax
	jmp cexp
	
exp12:	mov esi,exp12msg
	pop eax
	jmp cexp
	
exp13:	mov esi,exp13msg
	pop eax
	jmp cexp
	
exp14:	mov esi,exp14msg
	pop eax
	jmp cexp
	
exp15:	mov esi,exp15msg
	jmp cexp
	
exp16:	mov esi,exp16msg
	jmp cexp
	

cexp:	call vwstr
	mov eax,[esp+4]
	call vword
	mov al,':'
	call vputchar
	mov eax,[esp]
	call vdword
	hlt

