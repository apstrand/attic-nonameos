[bits 32]
[inc os.inc]
[section .data]

	
	
gdt:	dw	800h
	dd	gdt
	dw	0
	dd	0000ffffh	; 08h code descriptor
	dd	00cf9a00h
	dd	0000ffffh	; 10h data descriptor
	dd	00cf9200h
	dw	200h,tss0	; 18h Task 0
	dd	00008900h
	dd	00000200h	; 20h Task 1
	dd	00008900h
	dd	00000200h	; 28h Task 2
	dd	00008900h
	dd	0000ffffh	; 30h cpl3 code descriptor
	dd	00cffa10h
	dd	0000ffffh	; 38h cpl3 data descriptor
	dd	00cff210h
	dw	video0,8h	; 40h Call gate Video dpl 0
	dw	8c00h,0
	dw	video3,8h	; 48h Call gate Video dpl 3
	dw	0ec00h,0
	dw	0,t0desc	; 50h Task Gate
	dw	08500h,0
	
	times 800h-$+gdt db 0
idt:	times 100h dw dummyh,8,8e00h,0


idtptr:	dw	07ffh
	dd	idt
	

msg0	db	'Initiating....',0ah,0
msg1	db	'Running....',0ah,0
msgl1	db	'Loading task 1...',0ah,0
msgr1	db	'Running task 1...',0ah,0
msgl2	db	'Loading task 2...',0ah,0
msgr2	db	'Running task 2...',0ah,0
	
	
[section .text]
start:	
	mov ax,d0d
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	mov esp,10000h
	
	call enableA20		
	;; 	call getmems
	call init8259
	call init8253
    	call initIDT
  	call inittss
 	lidt [idtptr]
  	sti
	mov bl,0
	call vid0:0
	mov esi,msg1
	mov bl,5
	call vid0:0
	mov esi,endmark
	mov edi,100000h
	mov ecx,1000h
 	rep movsb
	mov esi,msgl1
	mov bl,5
	call vid0:0
	mov esi,[endmark]
  	call loadtask
   	mov esi,msgr1
   	mov bl,5
   	call vid0:0
   	call runtask	
  	mov esi,msgl2
  	mov bl,5
  	call vid0:0
  	mov esi,[endmark+4]
 	call loadtask
  	mov esi,msgr2
  	mov bl,5
  	call vid0:0
  	call runtask
	jmp $


getmems:
	mov ebx,100000h	
	mov al,0a5h
.l1:	mov [ebx],al
	mov cl,[ebx]
	cmp cl,al
	jne .l2
	inc ebx
	jmp .l1
.l2:	mov eax,ebx
	mov bl,8
	call vid0:0
	ret
	
initIDT:	
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
	ret


init8253:			; Timeravbrott
 	mov al,34h		; timer 0, mode 2, 16 bit
 	out 43h,al
	mov al,9ch		; 2e9c -> 100Hz
	out 40h,al
	mov al,2eh
	out 40h,al
 	in al,21h		; irq 0 på
 	and al,11111110b
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


	
enableA20:	
	call    empty8042
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


[inc job.asm]
[inc video.asm]
[inc ints.asm]
[inc kbd.asm]

[section .text]
	times 1000h-$+start db 0
[section .data]
endmark: