
[section .data]
idt	times 100h	dd 0,0
	
	

idt1	equ	dummyh+80000h
idt2	equ	8e00h

		
[section .text]


	;; Kollar hur mycket minne som finns och 
	;; uppdaterar minnes-variablerna...

getmems:
	mov ebx,100000h	
	mov al,0a5h
.l1:	mov [ebx],al
	mov cl,[ebx]		; Går igenom minne från 1M och uppåt
	cmp cl,al		; Om läst data inte är lika med skriven
	jne .l2			; data så är minnet slut (eller sönder)
	add ebx,1024
	jmp .l1
.l2:	
	mov ecx,204h
.l3:	mov dword [memlst+ecx],0
	sub ecx,4
	jnz .l3
	mov [memsize],ebx
	mov [memfr],ebx
	mov dword [memsize+4],0
	mov dword [memlst],100000h
	mov dword [membusy],0
	ret
	
initIDT:
	mov eax,idt1
	mov ebx,idt2
	xor ecx,ecx
.l1:	mov [idt+ecx],eax
	mov [idt+ecx+4],ebx
	add ecx,8
	cmp ecx,800h
	jb .l1
	
	mov edx,exp0		; Exception handlers på int 0 till 20h
	mov [idt+0*8],dx
	mov edx,exp1
	mov [idt+1*8],dx
	mov edx,exp2
	mov [idt+2*8],dx
	mov edx,exp3
	mov [idt+3*8],dx
	mov edx,exp4
	mov [idt+4*8],dx
	mov edx,exp5
	mov [idt+5*8],dx
	mov edx,exp6
	mov [idt+6*8],dx
	mov edx,exp7
	mov [idt+7*8],dx
	mov edx,exp8
	mov [idt+8*8],dx
	mov edx,exp9
	mov [idt+9*8],dx
	mov edx,exp10
	mov [idt+10*8],dx
	mov edx,exp11
	mov [idt+11*8],dx
	mov edx,exp12
	mov [idt+12*8],dx
	mov edx,exp13
	mov [idt+13*8],dx
	mov edx,exp14
	mov [idt+14*8],dx
	mov edx,exp15
	mov [idt+15*8],dx
	mov edx,exp16
	mov [idt+16*8],dx
	mov edx,irq0
  	mov [idt+20h*8],dx
	mov edx,irq1
  	mov [idt+21h*8],dx

	mov edx,procih			; Avbrottshanterar för "publika" funktioner
	mov [idt+42h*8],dx		; 42h Processhantering
	or byte [idt+42h*8+5],60h
	mov edx,vidih			; 43h Videorutiner
	mov [idt+43h*8],dx
	or byte [idt+43h*8+5],60h
	mov edx,kbdih			; 44h Tangentbordsrutiner
	mov [idt+44h*8],dx
	or byte [idt+43h*8+5],60h
	ret


init8253:			; Timeravbrott
 	mov al,34h		; timer 0, mode 2, 16 bit
 	out 43h,al
	mov al,9ch		; 2e9c -> 100Hz
	out 40h,al
	mov al,2eh
	out 40h,al
 	in al,21h		; irq 0 och 1 på
 	and al,11111100b
 	out 21h,al
	ret	
	
init8259:			; mappa om hårdvaru-irq
	mov     al,11h		; initialisera 8259 1 och 2
	out     20h,al
	call    delay
	out     0a0h,al
	call    delay
	mov     al,20h		; irq 0 -> 20h ...
	out     21h,al
	call    delay
	mov     al,28h		; irq 8 -> 28h ...
	out     0a1h,al
	call    delay
	mov     al,4		; har en slav på irq 2
	out     21h,al
	call    delay
	mov     al,2		; slave sitter på irq 2
	out     0a1h,al
	call    delay
	mov     al,1		; båda 8086 mode
	out     21h,al
	call    delay
	out     0a1h,al
	call    delay
	mov     al,0ffh		; Alla av
	out     0a1h,al
	call    delay
	mov     al,011111011b	; Alla av utom 8259-2
	out     21h,al
	ret


	
enableA20:			; Slår på A20 så man kan
	call    empty8042	; adressera minnet över 1M
	mov     al,0d1h
	out     64h,al
	call    empty8042
	mov     al,0dfh
	out     60h,al
	call    empty8042
	ret

		
empty8042:	
	call    delay
	in      al,64h
	test    al,1
	jz      noout
	call    delay
	in      al,60h
	jmp     empty8042
noout:	test    al,2
	jnz     empty8042
	ret

	
delay:
	jmp .l1
.l1:	ret

