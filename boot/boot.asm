org 0x7c00
	jmp	short Label_Start
	nop
	BS_OEMName	db	'MINEboot'
	BPB_BytesPerSec	dw	512
	BPB_SecPerClus	db	1
	BPB_RsvdSecCnt	dw	1
	BPB_NumFATs	db	2
	BPB_RootEntCnt	dw	224
	BPB_TotSec16	dw	2880
	BPB_Media	db	0xf0
	BPB_FATSz16	dw	9
	BPB_SecPerTrk	dw	18
	BPB_NumHeads	dw	2
	BPB_HiddSec	dd	0
	BPB_TotSec32	dd	0
	BS_DrvNum	db	0
	BS_Reserved1	db	0
	BS_BootSig	db	0x29
	BS_VolID	dd	0
	BS_VolLab	db	'boot loader'
	BS_FileSysType	db	'FAT12   '
	
	BaseOfLoader equ 0x1000
	OffsetOfLoader equ 0x0000
	;根目录所占扇区数 根目录项*32/512
	RootDirSectors equ 14
	;根目录起始扇区数
	RootDirStartSectors equ 19
	;fat表起始扇区 
	Fat1Sectors equ 1

Label_Start:
	mov ax,0x7c00
	mov ss,ax
	mov sp,ax
	;清屏
	mov ax,0600h
	mov bx,0
	mov cx,0
	mov dx,184fh
	int 10h
	;初始化软盘
	mov ax,0
	mov dx,0
	int 13h
	;读取数据
	call find_load_inRoot
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

	;读取根目录扇区并寻找对应文件
find_load_inRoot:
	mov cl,RootDirStartSectors
s2:	mov ah,0
	mov al,1
	mov ch,0
	mov bx,readtext
call readSector
	push cx
	mov cx,16
s1:
	mov ax,[bx]
	cmp ax,0x4f42
	jne next
	mov ax,[bx+2]
	cmp ax,0x54f2
	jne next
	mov ax,[bx+4]
	cmp ax,0x2020
	jne next
	mov ax,[bx+8]
	cmp ax,0x2020
	jne next
	mov ax,[bx+10]
	cmp ax,0x5341
	jne next
	mov al,[bx+12]
	cmp al,0x4d
	jne next
	;执行到这里说明找到了
	;当前的bx位置就是起始位置
	;先执行一个显示看看
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,000fh
	mov cx,15
	mov dx,0
	mov bp,bx
	int 10h
	jmp $
next:
	;寻找下一行
	add bx,32
	loop s1
	pop cx
	;当前扇区未找到读取下个扇区
	inc cl
	;所有扇区找完了 没找到 调取显示信息报错
	cmp cl,34
	je loaderNotFound
	jmp s2


;调用io以lba28方式读取数据读取到ds:[bx]中
	;al表示读取扇区数量
	;bx表示偏移位置
	;cl表示读取扇区起始号
readSector:
	;保存寄存器数据
	push ax
	push bx
	push cx
	push dx
	;1设置要读取的扇区数量
	mov dx,0x1f2
	mov ah,0
	out dx,al
	;保存给下面读取使用
	push ax
	;2使用lba28访问硬盘 将扇区号写入0x1f3到0x1f6四个端口中
	mov dx,0x1f3
	mov al,cl
	mov al,0x00
	out dx,al
	inc dx
	;0x1f4
	mov al,0x00
	out dx,al
	;0x1f5
	inc dx
	out dx,al
	;0x1f6
	inc dx
	mov al,0xe0
	out dx,al
	;3向0x1f7写入0x20请求读取硬盘
	mov dx,0x1f7
	mov al,0x20
	out dx,al
	;4读取端口0x1f7数据，等待第七位置1表示准备完毕
	mov dx,0x1f7
waitRead:
	in al,dx
	and al,0x88
	cmp al,0x08
	jnz waitRead
	;5 读取数据512B数据 256*16
	pop ax
	;这里先让扇区数*255再+上扇区数*1获取要读取字节的真正次数
	push ax
	mov ah,255
	mul ah
	mov cx,ax
	pop ax
	mov ah,1
	mul ah
	add cx,ax
	mov dx,0x1f0
readw:
	in ax,dx
	mov [bx],ax
	add bx,2
	loop readw
 	;恢复寄存器数据
	pop dx
	pop cx
	pop bx
	pop ax
	ret
loaderNotFound:
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,000fh
	mov cx,15
	mov dx,0
	mov bp,load_not_found
	int 10h
	jmp $
	ret
boot_Message:
db "KeleOS boot~"
load_not_found:
db "load_not_found!"
times 510-($-$$) db 0
db 0x55,0xaa
readtext:
db 512 dup (0) 
