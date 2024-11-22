[BITS 64]                       ; the kernel will operate in the 64-bit mode (aka long mode)
[ORG 0x200000]                  ; the starting mem address for the kernel will be 200k

start:
    ; print kernal mode `K`
    MOV byte[0xB8000], 'K'
    MOV byte[0xB8001], 0xA

; traditional infinite loop
End:
    HLT 
    JMP End
