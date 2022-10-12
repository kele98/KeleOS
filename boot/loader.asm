	org 0x7c00
	;清屏
	mov ax,0600h
	mov bx,0
	mov cx,0
	mov dx,184fh
	int 10h
	;进入保护模式
	mov ax,[gdt_base]
	mov dx,[gdt_base+0x2]
	mov bx,16
	div bx
	mov ds,ax
	mov bx,dx

	;创建0#描述符 空描述符 处理器要求
	mov dword [bx],0x00
	mov dword [bx+0x04],0x00
	;创建#1描述符 代码段
	mov dword [bx+0x08],0x7c00ffff
	mov dword [bx+0x0c],0x00409800
	;创建#2描述符 数据段
	mov dword [bx+0x10],0x8000ffff
	mov dword [bx+0x14],0x0040920b
	;创建#3描述符 栈段
	mov dword [bx+0x18],0x00007a00
	mov dword [bx+0x1c],0x00409600
	mov word cs:[gdt_limit],31
	lgdt cs:[gdt_limit]

	in al,0x92
	or al,00000010b
	out 0x92,al

	cli

	mov eax,cr0
	or eax,1
	mov cr0,eax
	
	jmp dword 0x0008:flush-0x7c00

	[bits 32]
flush:
		mov cx,00000000000_10_000B
		mov ds,cx
		mov byte [0x00],'P'
		mov byte [0x02],'r'
		mov byte [0x04],'o'
		mov byte [0x06],'t'
		mov byte [0x08],'e'
		mov byte [0x0a],'c'
		mov byte [0x0c],'t'
		mov byte [0x0e],' '
		mov byte [0x10],'m'
		mov byte [0x12],'o'
		mov byte [0x14],'d'
		mov byte [0x16],'e'
		mov byte [0x18],' '
		mov byte [0x1a],'O'
		mov byte [0x1c],'K'
	 jmp $	
	;gdt边界
gdt_limit:
			dw 0
	;gdt基地址
gdt_base:
			dd 0x000007e00
