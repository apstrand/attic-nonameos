[bits 32]
[section .data]
tcs	equ	4ch
tds	equ	54h
tes	equ	48h
tfs	equ	58h
tgs	equ	5ch
tss	equ	50h
teip	equ	20h
tesp	equ	38h
tsss0	equ	8h
tesp0	equ	4h
tsss1	equ	10h
tesp1	equ	0ch
tsss2	equ	18h
tesp2	equ	14h
tldt	equ	60h
tflags	equ	24h
	
t0stk	equ	21000h
t1stk	equ	22000h

c0d	equ	08h
d0d	equ	10h
t0desc	equ	18h
t1desc	equ	20h
t2desc	equ	28h
c3d	equ	33h
d3d	equ	3bh
	
mintss	equ	18h
maxtss	equ	20h
	
				
gdt:	dw	800h
	dd	gdt
	dw	0
	dd	0000ffffh	; 08h code descriptor
	dd	00cf9a00h
	dd	0000ffffh	; 10h data descriptor
	dd	00cf9200h
	dw	200h,tss0	; 18h Task 0
	dw	8900h,0
	dw	200h,tss1	; 20h Task 1
	dw	8900h,0
	dw	200h,tss2	; 28h Task 2
	dw	8900h,0
	dd	0000ffffh	; 30h cpl3 code descriptor
	dd	00cffa00h
	dd	0000ffffh	; 38h cpl3 data descriptor
	dd	00cff200h

	times 800h-$+gdt db 0
idt:	times 100h dw dummyh,8,8e00h,0


idtptr:	dw	07ffh
	dd	idt
	
tssptr:	dd	0
	dw	18h
	
tss0:	times 200h db 0
tss1:	times 200h db 0
tss2:	times 200h db 0

msg0	db	'Initiating....',0ah,0
msg1	db	'Running....',0ah,0

[section .text]
start:	
	mov ax,d0d
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	mov esp,10000h
	call vcls
	mov esi,msg0
	call vwstr
	call enableA20
	call init8259
 	call init8253
   	call initIDT
	call inittss
	lidt [idtptr]
	sti
	mov esi,msg1
	call vwstr
  	jmp far [tssptr]
	jmp $

task0:	mov eax,70307030h
	mov edx,07200720h
	xor ebx,ebx
.l1:	mov [0b8000h+20*160+ebx],edx
	add ebx,4
	cmp ebx,160
	jb .l2
	xor ebx,ebx
.l2:	mov [0b8000h+20*160+ebx],eax
	mov ecx,100000h
	loop $
	jmp .l1

task1:	mov eax,07310731h
	mov edx,07200720h
	xor ebx,ebx
.l1:	mov [0b8000h+21*160+ebx],edx
	add ebx,4
	cmp ebx,160
	jb .l2
	xor ebx,ebx
.l2:	mov [0b8000h+21*160+ebx],eax
	mov ecx,100000h
	loop $
	jmp .l1

inittss:
	mov ax,10h
	mov dword [tss0+teip],task0
	mov dword [tss0+tesp],t0stk
	mov dword [tss0+tesp0],t0stk+2000h
	mov dword [tss0+tflags],202h
	mov dword [tss0+tcs],c0d
	mov dword [tss0+tds],d0d
	mov dword [tss0+tes],d0d
	mov dword [tss0+tfs],d0d
	mov dword [tss0+tgs],d0d
	mov dword [tss0+tss],d0d
	mov dword [tss0+tsss0],d0d
	mov dword [tss0+tldt],0
	mov dword [tss1+tesp],t1stk
	mov dword [tss1+teip],task1
	mov dword [tss1+tesp0],t1stk+2000h
	mov dword [tss1+tflags],202h
	mov dword [tss1+tcs],c3d
	mov dword [tss1+tds],d3d
	mov dword [tss1+tes],d3d
	mov dword [tss1+tfs],d3d
	mov dword [tss1+tgs],d3d
	mov dword [tss1+tss],d3d
	mov dword [tss1+tsss0],d0d
	mov dword [tss1+tldt],0

	mov ax,t2desc
	ltr ax
	mov word [tssptr+4],t0desc
	ret
	
initIDT:	
	mov edx,exp0
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
 	in al,21h		; irq 0 på!
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

noout:
	test    al,2
	jnz     empty8042
	ret

	
delay:
	jmp .l1
.l1:	ret

[inc video.asm]
[inc ints.asm]

[section .text]
	times 1000h-$+start db 0
