;BIOS code, file comprised of multiple sections 

;here are the directives 
[BITS 16]                       ;the boot code is runing in 16-bit mode (real mode has 8, 16, 32 bit modes)
[ORG 0x7c00]                    ;this boot code is targeted to be running in the memory location x7c00

start:                          ;label to indicate the start of the code and we are initializing the memory segments 
    XOR ax,ax                   ;set to 0
    MOV ds,ax                   ;set to 0 
    MOV es,ax                   ;set to 0
    MOV ss,ax                   ;set to 0
    MOV sp, 0x7c00              ;point the stack pointer to 

;; Add disk extension service 
;; Because we need to load our kernel from disk to the memory and jump to the kernel

TestDiskExtension:
    MOV [DriveId], dl           ;move to the 0 location using the value stored in variable
    MOV ah, 0x41
    MOV bx, 0x55aa
    INT 0x13                    ;call the interupt if the device is not supported
    JC NoSupport                ;the inerupt will make it to jum to label NoSupport
    cmp bx, 0xaa55              ;if bx is not eq to give n value, jump to NoSupport  
    JNE NoSupport               ;jne (jump if not euqal)

LoadLoader:
    MOV si,ReadPacket
    MOV WORD[si ],0x10
    MOV WORD[si + 2],5
    MOV WORD[si + 4],0x7e00
    MOV WORD[si + 6],0
    MOV DWORD[si + 8],1
    MOV DWORD[si + 0xc],0
    MOV dl,[DriveId]
    MOV ah,0x42
    INT 0x13
    JC  ReadError

    MOV dl,[DriveId]
    JMP 0x7e00 

ReadError:
    MOV ah,0x13 
    MOV al,1
    MOV bx,0xa                      ;color green to print 
    XOR dx,dx
    MOV bp,Message                  ;address of string to print 
    MOV cx,MessageLen               ;length of chars to print 
    INT 0x10

NoSupport:
    MOV ah,0x13 
    MOV al,1
    MOV bx,0xa                      ;color green to print 
    XOR dx,dx
    MOV bp,NoSupportMessage         ;address of string to print 
    MOV cx,NoSupportMessageLen      ;length of chars to print 
    INT 0x10    

End:
    HLT
    JMP End

;; Variables 
NoSupportMessage: DB "Drive extension not supported"
NoSupportMessageLen: EQU $-NoSupportMessage

DriveId: DB 0
Message: DB "Eror occured in boot process"
MessageLen: EQU $-Message
ReadPacket: times 16 DB 0

times (0x1be - ($ - $$)) DB 0

    DB 80h                      ;boot indicator 
    DB 0,2,0                    ;set starting CHS (Cylinder, Height, Sector)
    DB 0f0h                     ;type 
    DB 0ffh, 0ffh, 0ffh         ;ending CHS 
    DD 1                        ;starting sector 
    DD (20 * 16 * 63 - 1)       ;size 


    times(16 * 3) DB 0 

    DB 0x55 
    DB 0xaa 
