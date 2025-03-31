; (SMOLOS Kernel) HUGE CONTRIBUTIONS REQUIRED!
; Write your Github links below:
;

org 0x0
bits 16

; New line
%define ENDL 0x0D, 0x0A

; Entry
start:
    ; print initial messages
    mov si, msg_kernel_loaded
    call puts

    mov si, msg_welcome
    call puts

.halt:
    cli
    hlt

; Methods

;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

; Data
msg_kernel_loaded: db 'Kernel loaded.', ENDL, 0
msg_welcome: db 'Welcome to SMOLOS!', ENDL, 0
