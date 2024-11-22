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

;; Add disk extension service 
;; Because we need to load our kernel from disk to the memory and jump to the kernel

TestDiskExtension:
    mov [DriveId], dl       ;move to the 0 location using the value stored in variable
    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13            ;call the interupt if the device is not supported
    jc NoSupport        ;the inerupt will make it to jum to label NoSupport
    cmp bx, 0xaa55      ;if bx is not eq to give n value, jump to NoSupport  
    jne NoSupport       ;jne (jump if not euqal)

PrintMessage:
    mov ah,0x13 
    mov al,1
    mov bx,0xa          ;color green to print 
    xor dx,dx
    mov bp,Message      ;address of string to print 
    mov cx,MessageLen   ;length of chars to print 
    int 0x10

NoSupport:      ;will be similar to jumping at the end 
End:
    hlt
    jmp End


;; Variables 
DriveId: db 0
Message: db "Disk extension is supported"
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
