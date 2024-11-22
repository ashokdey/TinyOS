;BIOS code, file comprised of multiple sections 

;here are the directives 
[BITS 16]           ;the boot code is runing in 16-bit mode (real mode has 8, 16, 32 bit modes)
[ORG 0x7c00]        ;this boot code is targeted to be running in the memory location x7c00

start:              ;label to indicate the start of the code and we are initializing the memory segments 
    xor ax,ax       ;set to 0
    mov ds,ax       ;set to 0 
    mov es,ax       ;set to 0
    mov ss,ax       ;set to 0
    mov sp, 0x7c00  ;point the stack pointer to 

PrintMessage:
    mov ah,0x13 
    mov al,1
    mov bx,0xa          ;color green to print 
    xor dx,dx
    mov bp,Message      ;address of string to print 
    mov cx,MessageLen   ;length of chars to print 
    int 0x10


End:
    hlt
    jmp End

Message: db "Hello"
MessageLen: equ $-Message


times (0x1be - ($ - $$)) db 0

    db 80h                      ;boot indicator 
    db 0,2,0                    ;set starting CHS (Cylinder, Height, Sector)
    db 0f0h                     ;type 
    db 0ffh, 0ffh, 0ffh         ;ending CHS 
    dd 1                        ;starting sector 
    dd (20 * 16 * 63 - 1)       ;size 


    times(16 * 3) db 0 

    db 0x55 
    db 0xaa 
