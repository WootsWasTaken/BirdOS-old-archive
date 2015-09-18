bits 16

jmp main

convert_sector:
push bx
push ax
mov bx, ax
mov dx, 0
div word [sectorspertrack]
add dl, 01h
mov cl, dl
mov ax, bx
mov dx, 0
div word [sectorspertrack]
mov dx, 0
div word [sides]
mov dh, dl
mov ch, al
pop ax
pop bx
mov dl, byte [bootdrive]
ret

sectorspertrack dw 18
sides dw 0

reset_floppy:
mov ah, 0
mov dl, byte [bootdrive]
int 13h
ret

print:
lodsb
cmp al, 0
je Done
mov ah, 0eh
int 10h
jmp print

Done:
ret

main:
cli
mov ax, 0x0000
mov ss, ax
mov sp, 0xFFFF
sti

mov ax, 07c0h
mov ds, ax
mov es, ax

mov [bootdrive], dl

mov bx, buffer
mov cl, 2
mov ch, 0
mov dh, 1
mov ah, 2
mov al, 14
pusha

load_root:
int 13h
jnc loaded_root
call reset_floppy
jmp load_root

loaded_root:
popa
mov di, buffer
mov  cx, 224
mov ax, 0
search_root:
push cx
pop dx
mov si, filename
mov cx, 11
rep cmpsb
je found_file
add ax, 32
add di, ax
push dx
pop cx
loop search_root

mov si, msg
call print
int 18h

found_file:
mov ax, word [di+15]
mov word [firstsector], ax

mov bx, buffer
call convert_sector
mov al, 9
mov ah, 2

pusha

load_fat:
int 13h
jne loaded_fat
call reset_floppy
jmp load_fat

loaded_fat:
mov ah, 2
mov al, 1
push ax

load_file_sector:
mov ax, word [firstsector]
add ax, 31
call convert_sector
mov ax, 2000h
mov es, ax
mov bx, word [pointer]

pop ax
push ax
int 13h
jnc  calculate_next_sector
call reset_floppy
jmp load_file_sector

calculate_next_sector:
mov ax,[firstsector]
mov dx, 0
mov bx, 6
mul bx
mov bx, 4
div bx
mov si, buffer
add si, ax
mov ax, word [si]

or dx, dx
jz even

odd:
shr ax, 4
jmp short next_sector_calculated

even:
and ax, 0FFFh

next_sector_calculated:
mov word [firstsector], ax
cmp ax, 0FF8h
jae end
add word[pointer], 512
jmp load_file_sector

end:
pop ax
mov dl, byte[bootdrive]
jmp 2000h:0000h


bootdrive db 0
filename db "KERNEL  SYS"
firstsector dw 0
pointer dw 0
msg db "Failed!"

times 510 - ($-$$) db 0
dw 0xAA55

buffer:
