p386
ideal


segment code para public use16
	assume cs:code,ds:code,es:code

image	db	'init',0
	
start:	mov ax,code
	mov ds,ax
	mov ax,3d00h
	mov dx,offset image
	int 21h
	mov bx,ax
	mov ah,3fh
	mov cx,-1
	mov dx,7000h
	mov ds,dx
	xor dx,dx
	int 21h
	mov ah,3eh
	int 21h	
	cli
	xor si,si
	xor di,di
	mov es,si
	mov ax,7000h
	mov ds,ax
	mov cx,-1
	cld
	rep movsb
	xor ax,ax
	mov ds,ax
	lgdt [fword ptr 1000h]
	mov eax,cr0
	or al,1
	mov cr0,eax
	db 0eah
	dw 2000h,8
	
ends	code
	end start






