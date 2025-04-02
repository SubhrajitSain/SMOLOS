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

    mov si, sym_space_nl
    times 100 call puts

    mov si, sml_row1
    call puts

    mov si, sml_row2
    call puts

    mov si, sml_row3
    call puts

    mov si, sml_row4
    call puts

    mov si, sml_row5
    call puts

    mov si, sml_row6
    call puts

    mov si, sml_row7
    call puts

    mov si, sym_dash
    times 80 call puts

    mov si, wlc_kernel_loaded
    call puts

    mov si, wlc_welcome
    call puts

    mov si, ver_blr_version
    call puts

    mov si, ver_knl_version
    call puts

    mov si, crd_by
    call puts

    mov si, crd_github_repo
    call puts

    mov si, crd_contrib
    call puts

    mov si, sym_prompt
    call puts

.prompt_loop:
    mov di, cmd_buffer       ; Reset buffer pointer
    mov cx, 255              ; Max input length

.input_loop:
    ; Read character
    mov ah, 0x00
    int 0x16                 ; BIOS keyboard input

    ; Handle special keys
    cmp al, 0x08             ; Backspace
    je .backspace
    cmp al, 0x0D             ; Enter
    je .process_command

    ; Store character
    stosb                   ; Store AL to [DI++]
    dec cx
    jz .input_overflow      ; Handle buffer full

    ; Echo character
    mov ah, 0x0E
    int 0x10
    jmp .input_loop

.backspace:
    cmp si, cmd_buffer
    je .input_loop ; prevent going before buffer start.

    dec si
    mov byte [si], 0 ; clear the last character from buffer.

    mov ah, 0x0E ; echo backspace (destructive)
    mov al, 0x08
    mov bh, 0
    int 0x10

    mov ah, 0x0E ; echo space
    mov al, ' '
    mov bh, 0
    int 0x10

    mov ah, 0x0E ; echo backspace again.
    mov al, 0x08
    mov bh, 0
    int 0x10

    jmp .input_loop

.process_command:
    ; Null-terminate buffer
    mov byte [di], 0

    ; Print newline
    mov si, sym_space_nl
    call puts

    ; Command comparisons
    mov si, cmd_buffer
    mov di, cmd_help
    mov cx, 4               ; command length
    repe cmpsb
    je .help_command

    mov si, cmd_buffer
    mov di, cmd_reboot
    mov cx, 6
    repe cmpsb
    je .reboot_command

    ; Unknown command
    mov si, err_unknown_cmd
    call puts
    jmp .prompt_reset

.help_command:
    mov si, msg_help
    call puts
    jmp .prompt_reset

.reboot_command:
    jmp 0FFFFh:0

.prompt_reset:
    ; Clear buffer
    mov di, cmd_buffer
    mov cx, 256
    xor al, al
    rep stosb

    ; Reprint prompt
    mov si, sym_prompt
    call puts
    jmp .prompt_loop

.input_overflow:
    ; Handle buffer full
    mov si, err_long_prompt
    call puts
    jmp .prompt_reset

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

    mov ah, 0x0E        ; tty mode
    mov bh, 0           ; set page number to 0
    int 0x10            ; interrupt to print the character in al

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

; Data goes here
sml_row1:          db "            /#########\    /##     ##\    /#########\    ##         ", ENDL, 0
sml_row2:          db "            ##       ##    ## ## ## ##    ##       ##    ##         ", ENDL, 0
sml_row3:          db "            ##             ##   #   ##    ##       ##    ##         ", ENDL, 0
sml_row4:          db "            \#########\    ##       ##    ##       ##    ##         ", ENDL, 0
sml_row5:          db "                     ##    ##       ##    ##       ##    ##         ", ENDL, 0
sml_row6:          db "            ##       ##    ##       ##    ##       ##    ##       ##", ENDL, 0
sml_row7:          db "            \#########/    ##       ##    \#########/    \#########/", ENDL, ENDL, 0

wlc_kernel_loaded: db "Kernel loaded successfully.", ENDL, 0
wlc_welcome:       db "Welcome to SMOLOS!", ENDL, ENDL, 0

ver_blr_version:   db "Bootloader version - 5", ENDL, 0
ver_knl_version:   db "Kernel version     - 8", ENDL, ENDL, 0

crd_by:            db "SMOLOS by Subhrajit Sain (ANW), 2025", ENDL, 0
crd_github_repo:   db "Github repo: https://github.com/SubhrajitSain/SMOLOS", ENDL, 0
crd_website:       db "Website: Soon maybe...", ENDL, 0
crd_contrib:       db "[CONTRIBUTION REQUIRED!] [UNDER CONSTRUCTION]", ENDL, ENDL, 0

sym_prompt:        db '-> ', 0
sym_slash1:
sym_dash:          db '-', 0
sym_space_nl:      db ' ', ENDL, 0

cmd_buffer:        times 256 db 0
cmd_help:          db 'help', 0
cmd_reboot:        db 'reboot', 0

msg_help:          db "Available commands: help, reboot", ENDL, 0

err_unknown_cmd:   db "Unknown command! Use `help` to see a list of available commands.", ENDL, 0
err_long_prompt:   db ENDL, "Prompt too long, try shortening it a bit.", ENDL, 0
