[section .data]
	
	
memlst	dd	100000h,0
	times	100h	dd	0,0 ; 100h * (ptr,size)
memsize	dd	0,0
memfr	dd	0
membusy dd 0

mfunc	dd	memavail,memfrees,memget,memfree
mfuncs	equ	($-mfunc)/4

	
[section .text]

	;; Memory functions
	;; bl = function
	;; 0 = Get availible memory
	;; 1 = Get free memory
	;; 2 = Allocate memory
	;; 3 = Free memory
	

memory:
	cmp bl,mfuncs
	jb .ok
	stc
	retf
.ok:	push ds
	push dword d0d
	pop ds
.l1	cmp byte [membusy],1
	je .l1
	mov byte [membusy],1
	push ebx
	and ebx,0ffh
	shl ebx,2
	call [vfunc+ebx]
	pop ebx
	mov byte [membusy],0
	pop ds
	clc
	retf

memavail:
	mov eax,[memsize]
	ret

memfrees:
	mov eax,[memfr]
	ret

memprint:
	mov bl,4
	mov al,0ah
	call vid0:0
	mov ecx,memlst
	add ecx,8
.l1:	mov eax,[ecx]
	mov bl,8
	call vid0:0
	mov bl,4
	mov al,'-'
	call vid0:0
	add ecx,4
	cmp ecx,memsize
	jb .l1
	mov al,0ah
	call vid0:0
	ret
	
	
memget:				; Storlek i ecx
	push ebx
	push edx
	push esi
	mov eax,memlst
.l2:	cmp dword [eax],0
	je .l1
	add eax,8
	cmp eax,memsize
	jae .err
	jmp .l2
.l1:	mov edx,eax
.l3:	add eax,8
	cmp dword [eax],0
	je .l3			; edx=första lediga, eax=nästa ickelediga
	mov ebx,[edx-8]
	add ebx,[edx-4]		; ebx=första lediga minnesposition
	mov esi,[eax]
	sub esi,ecx
	cmp esi,ebx
	jb .l2
	mov eax,ebx
	mov [edx],eax
	mov [edx+4],ecx
	sub [memfr],eax
	pop esi
	pop edx
	pop ebx	
	clc
	ret			; pekare till minnesblock i eax
.err:	pop esi
	pop edx
	pop ebx
	stc
	ret
	
	
memfree:			; pekare till minnesblock i eax
	push ebx
	mov ebx,memlst
.l1:	add ebx,8
	cmp [ebx],eax
	jne .l1
	push eax
	mov eax,[ebx+4]
	add [memfr],eax
	pop eax
	mov dword [ebx],0
	mov dword [ebx+4],0
	pop ebx
	ret


