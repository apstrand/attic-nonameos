[bits 16]
[org 0h]
boot:
	push word 7c0h
	pop ds
	xor ax,ax
	mov fs,ax
	xor si,si
	xor di,di
	mov ax,9000h
	mov es,ax
	mov ss,ax
	mov sp,0ff80h
	mov cx,256
	cld
	rep movsw
       	jmp 9000h:go		; Flytta bootkoden ur vägen, till 9000:0  ss:sp=9000:ff80
go:	mov si,msg1
	call print		; Loading...
 	lds si,[fs:78h]
 	mov di,0ff00h
 	mov cx,6
 	rep movsw
 	sub di,12
 	mov ds,ax
 	mov byte [di+4],36
  	mov [fs:78h],di
  	mov [fs:7ah],es		; Ändra antalet sektorer för BIOS
	xor ah,ah
	xor dl,dl
	int 13h			; Reset FDC
	mov ax,4000h
	mov es,ax		; Lägg koden tillfälligt på 4000:0
	xor dx,dx
	mov cx,2
	xor bx,bx
	mov ax,0211h
	int 13h			; Läs sektor 2 till 17, spår 0, sida 0
	hlt
	mov ax,0211h
	int 13h
	hlt
	mov ax,0211h
	int 13h	
	push bx
	mov ax,0e2eh
	xor bh,bh
	int 10h
	pop bx
	add bx,17*512
	mov ax,0212h
	mov dh,1
	mov cx,1
	int 13h
	hlt
	mov ax,0212h
	int 13h			; Läs sektor 1 till 18, spår 0, sida 1
	push bx
	mov ax,0e2eh
	xor bh,bh
	int 10h
	pop bx
	mov dx,3f2h
	xor ax,ax
	out dx,al		; Döda motor
	cli
	mov es,ax
	mov ax,4000h
	mov ds,ax
	mov cx,-1
	xor si,si
	xor di,di
	rep movsb		; Flytta kod till 0:0
	mov ax,0
	mov ds,ax
	mov ax,[0]
	mov bx,9000h
	mov ds,bx
	mov [gdt+2],ax
	lgdt [gdt]
	mov eax,1
	mov cr0,eax
	jmp 8:8
	
print:	push ax
	push bx
	push ds
	push word 9000h
	pop ds
	mov ah,0eh
	xor bh,bh
.l1:	lodsb
	or al,al
	jz .l2
	int 10h
	jmp .l1
.l2:	pop ds
	pop bx
	pop ax
	ret
	

msg1	db	'Loading...',0

gdt	dw	800h
	dd	0h

times 200h-$+boot db 0






