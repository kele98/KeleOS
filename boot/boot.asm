org 0x7c00
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
db "KeleOS boot~"
times 510-($-$$) db 0
db 0x55,0xaa
