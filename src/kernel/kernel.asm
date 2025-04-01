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

    mov si, ntc_prompt
    call puts

    mov si, ntc_fat
    call puts

    mov si, sym_prompt
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

ver_blr_version:   db "Bootloader version - 5 (x86-64 ASM)", ENDL, 0
ver_knl_version:   db "Kernel version     - 7 (x86-64 ASM)", ENDL, ENDL, 0

crd_by:            db "SMOLOS by Subhrajit Sain (ANW), 2025", ENDL, 0
crd_github_repo:   db "Github repo: https://github.com/SubhrajitSain/SMOLOS", ENDL, 0
crd_website:       db "Website: Soon maybe...", ENDL, 0
crd_contrib:       db "[CONTRIBUTION REQUIRED!] [UNDER CONSTRUCTION]", ENDL, ENDL, 0

ntc_prompt:        db "Prompt system still not implemented!", ENDL, 0
ntc_fat:           db "This OS uses FAT12. Please don't complain.", ENDL, ENDL, 0

sym_prompt:        db '-> ', 0
sym_slash1:
sym_dash:          db '-', 0
sym_space_nl:      db ' ', ENDL, 0
