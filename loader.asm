[BITS 16]
[ORG 0x7e00]

start:
    MOV [DriveId],dl

    MOV eax, 0x80000000
    CPUID 
    CMP eax, 0x80000001         ;compare if eax is less than given value 
    JB NoSupport                ;jump f below 

    MOV eax, 0x80000001         ;now we can use the value 0x80000001 
    CPUID 
    TEST edx, (1 << 29)
    JZ NoSupport
    TEST edx, (1 << 26)
    JZ NoSupport

LoadKernel:
    MOV si,ReadPacket
    MOV word[si ], 0x10
    MOV word[si + 2], 100
    MOV word[si + 4], 0         ;load the kernel at 10k mem address 
    MOV word[si + 6], 0x1000
    MOV dword[si + 8], 6
    MOV dword[si + 0xc], 0
    MOV dl, [DriveId]
    MOV ah, 0x42
    INT 0x13
    JC  ReadError

TryGetMemInfo:
    MOV eax, 0xe820
    MOV edx, 0x534d4150
    MOV ecx, 20
    MOV edi, 0x9000
    XOR ebx, ebx
    INT 0x15 
    JC NoSupport

GetMemInfo:
    ADD edi, 20
    MOV eax, 0xe820
    MOV edx, 0x534d4150
    MOV ecx, 20  
    INT 0x15 
    JC GetMemInfoDone

    TEST ebx, ebx
    JNZ GetMemInfo

GetMemInfoDone:
; Test for A20

;The A20, or address line 20, is one of the 
;electrical lines that make up the system 
;bus of an x86-based computer system. 
;
;The A20 line in particular is used to transmit the 
;21st bit on the address bus. The high memory area 
;is only available in real mode on 80286 processors 
;if the A20 gate is enabled.
;

TestA20:
    MOV ax, 0xFFFF
    MOV es, ax 
    MOV WORD[DS: 0x7C00], 0xA200
    CMP WORD[ES: 0x7C10], 0xA200
    JNE SetA20LineDone

    MOV WORD[0x7C00], 0xB200
    CMP WORD[ES:0x7C10], 0xB200
    JE End

SetA20LineDone:
    XOR ax, ax
    MOV es, ax

    ; Print a message 
    MOV ah, 0x13
    MOV al, 1
    MOV bx, 0xa
    XOR dx, dx
    MOV bp, Message
    MOV cx, MessageLen 
    INT 0x10


ReadError:
NoSupport:
End:
    HLT 
    JMP End


;; Variables 
DriveId:    DB 0
Message:    DB "A20 line is enabled"
MessageLen: equ $-Message

NoSupportMessage:    DB "long mode is not supported"
NoSupportMessageLen: equ $-NoSupportMessage
ReadPacket: times 16 DB 0