[org 0x7c00]        ; "We will be loaded at 0x7C00" — so labels get the right addresses
[bits 16]           ; generate 16-bit code, because the CPU is in real mode

start:
    xor ax, ax      ; ax = 0  (xor with itself is the fastest way to zero)
    mov ds, ax      ; data segment = 0
    mov es, ax      ; extra segment = 0
    mov ss, ax      ; stack segment = 0
    mov sp, 0x7c00  ; stack starts just below our code and grows DOWNWARD
    cld             ; make string instructions (lodsb) move forward

    mov si, msg     ; si = address of our message
.print:
    lodsb           ; al = byte at [ds:si], then si++
    test al, al     ; is it 0? (end of string)
    jz .done        ; if yes, finish
    mov ah, 0x0e    ; BIOS function 0x0E = "teletype": print the char in al
    int 0x10        ; call BIOS video service (interrupt 0x10)
    jmp .print      ; next character
.done:
    cli             ; disable interrupts
    hlt             ; halt the CPU
    jmp .done       ; just in case something wakes it up

msg: db "Alaz is booting...", 0   ; our text, ending in a 0 byte (like C strings!)

times 510 - ($ - $$) db 0   ; pad with zeros until byte 510
dw 0xaa55                   ; boot signature (little-endian: bytes 55 AA)
