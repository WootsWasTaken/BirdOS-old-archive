bits 16

org 0x0600                             ; set origin point to where the

section	.text

	align 	4
	dd 	0x1BAD0002
	dd 	0x00
	dd 	(0x1BAD0002*0x00)                                     ; FreeDOS bootloader loads this code

jmp skipDescriptorTables

idt:
     dd       0x00                     ; int 0 handler descriptor
     dd       0x08
     dd       0x00
     dd       010001110b
     dd       0x00

gdt_start:
     dd 0
     dd 0
     
     dw 0xffff
     dw 0 
     db 0
     db 10011010b
     db 11001111b
     db 0 
     
     dw 0xffff
     dw 0 
     db 0
     db 10010010b
     db 11001111b
     db 0 
gdt_end:

GDTHeader:
dw gdt_end - gdt_start - 1
dd gdt_start


load_GDT:
pusha
lgdt [GDTHeader]
popa
ret

skipDescriptorTables:
cli
mov ax, 0x0000                         ; init the stack segment 
mov ss, ax
mov sp, 0xffff

mov ax, 0x0000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

call load_GDT

mov eax, cr0                           ; enter protected mode. YAY!
or eax, 00000001b
mov cr0, eax

jmp 0x08:start

Bits 32


global start
extern kmain

start:

	cli
	call kmain
	hlt
