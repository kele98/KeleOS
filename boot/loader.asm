org 0x10000

	;显示文字
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,000fh
	mov cx,13
	mov dx,0
	mov bp,boot_Message
	int 10h
	jmp $
boot_Message:
	db 'bootLoader!'
