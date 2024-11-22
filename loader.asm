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

SetVideoMode:
    MOV ax, 3
    INT 0x10

; We are going to print on screen 80x25 
; 80 chars (horizontally) 
; 25 lines (vertically)
; Every char has 2 bytes: 
; [ASCII as first byte]
; [Background: Foreground] - attributes in the 2nd byte
;

; Loading the descriptor tables: GDT and IDT 
    CLI                             ; clear the interupts 
    LGDT [Gdt32Ptr]
    LIDT [Idt32Ptr]

    ; enabling the protected mode 
    MOV eax, cr0
    OR  eax, 1
    MOV cr0, eax

    ; loading Code Segment Descriptor via JMP 
    ; also we have to seek to 8 byets away from GDT 
    JMP 8:PMEntry

; This block will be used before we try to get into the protected mode
ReadError:
NoSupport:
End:
    HLT 
    JMP End

; We are using directive to signify that it's 32 bit code 
[BITS 32]
PMEntry:
    MOV ax, 0x10                ; TS register initialization
    MOV ds, ax                  ; DS register initialization
    MOV es, ax                  ; ES register initialization
    MOV ss, ax                  ; SS register initialization
    MOV esp, 0x7C00             ; Setting the stack pointer to the base mem address

    ; setting up paging 
    ; the address (0x80000 to 0x90000) may be used for 
    ; BIOS data. So we can use the address space 
    ; 0x70000 to 0x80000
    CLD
    MOV edi, 0x70000
    XOR eax, eax                ; clear eax
    MOV ecx, 0x10000/4
    REP stosd
    
    MOV dword[0x70000],0x71007
    MOV dword[0x71000],10000111B

    LGDT [Gdt64Ptr]

    MOV eax, cr4
    OR  eax, (1<<5)
    MOV cr4, eax

    MOV eax, 0x70000
    MOV cr3, eax

    MOV ecx, 0xc0000080
    RDMSR
    OR eax, (1<<8)
    WRMSR

    MOV eax, cr0
    OR  eax, (1<<31)
    MOV cr0, eax

    JMP 8:LMEntry

; This is the traditional infinite loop
PEnd:
    HLT
    JMP PEnd

; We are using directive to signify that it's 32 bit code 
[BITS 64]
LMEntry:
    MOV rsp, 0x7C00

    MOV byte[0xB8000],'L'       ; print L on screen to signify we are into the long mode (64-bit mode)
    MOV byte[0xB8001],0xa       ; the attribute for the char of the ASCII char `L`

LEnd:
    HLT
    JMP LEnd

;; Variables 
DriveId:    DB 0
ReadPacket: times 16 DB 0

; Defining the GDT 
; ----------------
; The Global Descriptor Table (GDT) is a binary data structure 
; that is used by  processors to define memory segments.

Gdt32:
    dq 0
Code32:
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 0xcf
    db 0
Data32:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 0xcf
    db 0
    
Gdt32Len: equ $-Gdt32

Gdt32Ptr: dw Gdt32Len-1
          dd Gdt32

; Interupt Descriptor Table
; -------------------------
; For now will are keeping it 0 
Idt32Ptr: dw 0
          dd 0

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64


Gdt64Ptr: dw Gdt64Len-1
          dd Gdt64
