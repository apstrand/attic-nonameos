[section .data]


tmrd:	dd	072f075ch
	dd	072d072dh
	dd	075c072fh
	dd	077c077ch
	dd	0
		
tmrc:	dd	10h

exp0msg:	db	'Divide Error at CS:EIP=',0
exp1msg:	db	'Debug Exception at CS:EIP=',0
exp2msg:	db	'Non Maskable Interrupt at CS:EIP=',0
exp3msg:	db	'Breakpoint at CS:EIP=',0
exp4msg:	db	'Overflow at CS:EIP=',0
exp5msg:	db	'Bounds Check at CS:EIP=',0
exp6msg:	db	'Invalid Opcode at CS:EIP=',0
exp7msg:	db	'Coprocessor Not Availible at CS:EIP=',0
exp8msg:	db	'Double Fault at CS:EIP=',0
exp9msg:	db	'Coprocessor Segment Overrun at CS:EIP=',0
exp10msg:	db	'Invalid TSS at CS:EIP=',0
exp11msg:	db	'Segment Not Present at CS:EIP=',0
exp12msg:	db	'Stack Exception at CS:EIP=',0
exp13msg:	db	'General Protection Exception at CS:EIP=',0
exp14msg:	db	'Page Fault at CS:EIP=',0
exp15msg:	db	'Exception 15 at CS:EIP=',0
exp16msg:	db	'Coprocessor Error at CS:EIP=',0
	
	

[section .text]

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

	
irq0:	push eax
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
	mov ax,[tssptr+4]
	add ax,8
	cmp ax,maxtss
	jbe .l2
	mov ax,mintss
.l2:	mov [tssptr+4],ax
	pop eax
	jmp far [tssptr]
	iret

dummyh:	
	iret




	