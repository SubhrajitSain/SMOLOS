; (SMOLOS Kernel) HUGE CONTRIBUTIONS REQUIRED!
; Write your Github links below:
;

org 0x0
bits 16

; New line
%define ENDL 0x0D, 0x0A

; --- FAT12 Variables (from BPB) ---
sectors_per_cluster:    dw 0
reserved_sectors:       dw 0
num_fats:               db 0
root_dir_entries:       dw 0
total_sectors:          dw 0
fat_size_sectors:       dw 0
sectors_per_track:      dw 0
num_heads:              dw 0
hidden_sectors:         dd 0
large_sector_count:     dd 0

; --- Calculated Variables ---
fat_start_sector:       dd 0
root_dir_size_sectors:  dw 0
current_drive_number:   db 0 ; Add drive number
root_dir_first_sector_lba: dd 0 ; Add this

; --- Directory Entry Offsets ---
DIR_NAME equ 0
DIR_EXTENSION equ 8
DIR_ATTRIBUTES equ 11
DIR_STARTING_CLUSTER equ 26
DIR_FILE_SIZE equ 28

; --- Attribute Masks ---
ATTR_READ_ONLY equ 0x01
ATTR_HIDDEN equ 0x02
ATTR_SYSTEM equ 0x04
ATTR_VOLUME_ID equ 0x08
ATTR_DIRECTORY equ 0x10
ATTR_ARCHIVE equ 0x20
ATTR_LFN equ ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID

; --- FAT12 Constants ---
FAT12_SECTOR_SIZE equ 512
FAT12_DIR_ENTRY_SIZE equ 32

; --- Buffers ---
boot_sector_buffer: times FAT12_SECTOR_SIZE db 0
directory_buffer:     times FAT12_SECTOR_SIZE db 0

; Entry
start:
    ; print initial messages

    mov si, sym_space_nl
    times 20 call puts

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
    mov di, cmd_buffer         ; Reset buffer pointer
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
    stosb                      ; Store AL to [DI++]
    dec cx
    jz .input_overflow       ; Handle buffer full

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
    mov cx, 4                ; command length
    repe cmpsb
    je .help_command

    mov si, cmd_buffer
    mov di, cmd_clear
    mov cx, 5
    repe cmpsb
    je .clear_command

    mov si, cmd_buffer
    mov di, cmd_reboot
    mov cx, 6
    repe cmpsb
    je .reboot_command

    mov si, cmd_buffer
    mov di, cmd_halt
    mov cx, 4
    repe cmpsb
    je .halt_command

    mov si, cmd_buffer
    mov di, cmd_echo
    mov cx, 4
    repe cmpsb
    je .echo_command

    mov si, cmd_buffer
    mov di, cmd_version
    mov cx, 7
    repe cmpsb
    je .version_command

    mov si, cmd_buffer
    mov di, cmd_ls
    mov cx, 2
    repe cmpsb
    je .ls_command

    ; Unknown command
    mov si, err_unknown_cmd
    call puts
    jmp .prompt_reset

.help_command:
    mov si, msg_help
    call puts
    jmp .prompt_reset

.clear_command:
    mov si, sym_space_nl
    times 100 call puts
    jmp .prompt_reset

.reboot_command:
    mov si, msg_reboot
    call puts
    call delay
    cli
    jmp 0FFFFh:0

.halt_command:
    mov si, msg_halt
    call puts
    cli
    hlt
    jmp $

.echo_command:
    add si, 1
    call puts
    mov si, sym_space_nl
    call puts
    jmp .prompt_reset

.version_command:
    mov si, ver_blr_version
    call puts
    mov si, ver_knl_version
    call puts
    jmp .prompt_reset

.ls_command:
    call read_boot_sector
    cmp ax, 0
    je .ls_error
    call read_root_directory
    call print_directory_entries
    jmp .prompt_reset

.ls_error:
    mov si, err_disk_error
    call puts
    jmp .prompt_reset

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
;    - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb                      ; loads next character in al
    or al, al                ; verify if next character is null?
    jz .done

    mov ah, 0x0E             ; tty mode
    mov bh, 0                ; set page number to 0
    int 0x10                 ; interrupt to print the character in al

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

; -------------------------------------
; Simple delay loop
delay:
    push cx
    mov cx, 1000000            ; Adjust for desired delay
.delay_loop:
    loop .delay_loop
    pop cx
    ret

;
; Reads sectors from a disk (Enhanced with LBA to CHS and retries)
; Parameters:
;    - ax: LBA address
;    - cl: number of sectors to read (up to 128)
;    - dl: drive number
;    - es:bx: memory address where to store read data (es:bx = directory_buffer)
;
disk_read:
    push ax                  ; save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                  ; temporarily save CL (number of sectors to read)
    call lba_to_chs          ; compute CHS
    pop ax                   ; AL = number of sectors to read

    mov ah, 02h              ; BIOS read sector function
    mov di, 3                ; retry count

.retry:
    pusha                    ; save all registers, we don't know what BIOS modifies
    stc                      ; set carry flag, some BIOS'es don't set it
    int 13h                  ; BIOS interrupt
    jnc .done                ; jump if carry flag is clear (no error)

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    ; all attempts are exhausted
    jmp disk_read_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                   ; restore registers modified
    clc                      ; Clear carry flag (success)
    ret

disk_read_error:
    stc                      ; Set carry flag (error)
    ret

;
; Converts an LBA address to a CHS address
; Parameters:
;    - ax: LBA address
; Returns:
;    - cx [bits 0-5]: sector number
;    - cx [bits 6-15]: cylinder
;    - dh: head
;
lba_to_chs:
    push ax
    push dx

    xor dx, dx                             ; dx = 0
    div word [sectors_per_track]         ; ax = LBA / SectorsPerTrack
                                         ; dx = LBA % SectorsPerTrack
    inc dx                                 ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                             ; cx = sector

    xor dx, dx                             ; dx = 0
    div word [num_heads]                 ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                         ; dx = (LBA / SectorsPerTrack) % Heads = head
    mov dh, dl                             ; dh = head
    mov ch, al                             ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                              ; put upper 2 bits of cylinder in CL

    pop ax
    pop dx
    ret

;
; Resets disk controller
; Parameters:
;    dl: drive number
;
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc .disk_reset_error
    popa
    ret

.disk_reset_error:
    jmp disk_read_error ; Use disk_read_error for consistency

read_boot_sector:
    ; Read sector 0 (boot sector) into boot_sector_buffer
    mov ah, 0x02             ; Read sectors from disk
    mov al, 0x01             ; Number of sectors to read
    mov ch, 0x00             ; Cylinder 0
    mov cl, 0x01             ; Sector 1
    mov dh, 0x00             ; Head 0
    mov dl, 0x80             ; Drive 0 (adjust if necessary)
    mov bx, boot_sector_buffer
    int 0x13
    jc .read_boot_sector_error ; Jump if carry flag is set (error)

    ; Parse boot sector parameters
    mov bx, boot_sector_buffer

    mov ax, [bx + 13] ; bdb_sectors_per_cluster
    mov [sectors_per_cluster], ax

    mov ax, [bx + 14] ; bdb_reserved_sectors
    mov [reserved_sectors], ax

    mov al, [bx + 16] ; bdb_fat_count (byte)
    mov [num_fats], al

    mov ax, [bx + 17] ; bdb_dir_entries_count
    mov [root_dir_entries], ax

    mov ax, [bx + 19] ; bdb_total_sectors
    mov [total_sectors], ax

    mov ax, [bx + 22] ; bdb_sectors_per_fat
    mov [fat_size_sectors], ax

    mov ax, [bx + 24] ; bdb_sectors_per_track
    mov [sectors_per_track], ax

    mov ax, [bx + 26] ; bdb_heads
    mov [num_heads], ax

    mov eax, [bx + 28] ; bdb_hidden_sectors
    mov [hidden_sectors], eax

    mov eax, [bx + 32] ; bdb_large_sector_count
    mov [large_sector_count], eax

    ; Calculate LBA of the first root directory sector
    mov ax, [reserved_sectors]
    mov bx, [fat_size_sectors]
    mov cl, [num_fats]       ; num_fats is a byte
    mul bx                 ; AX = BX * CL (word * byte -> word)
    add ax, [reserved_sectors]
    mov [root_dir_first_sector_lba], eax ; Store the word in the lower part of the dword

    clc                      ; Clear carry flag (no error)
    ret

.read_boot_sector_error:
    stc                      ; Set carry flag (error)
    xor ax, ax               ; Return 0 to indicate error
    ret

read_root_directory:
    ; Calculate root directory size in sectors
    mov ax, [root_dir_entries]
    mov ebx, FAT12_DIR_ENTRY_SIZE ; Load 32 into EBX
    mul ebx                      ; EAX = AX * EBX (result in EAX)
    mov ecx, FAT12_SECTOR_SIZE    ; Load 512 into ECX
    div ecx                      ; AX = EAX / ECX (quotient), DX = EAX % ECX (remainder)
    add ax, 31
    shr ax, 5
    mov [root_dir_size_sectors], ax

    ; Read root directory sectors
    mov cx, [root_dir_size_sectors]
    mov si, 0
    mov di, directory_buffer
    mov bl, [current_drive_number] ; Get drive number into BL (8-bit)

.read_root_loop:
    push cx
    push si

    mov eax, [root_dir_first_sector_lba] ; Get the starting LBA of the root directory
    add eax, esi                     ; Add the sector offset within the root directory
    push eax
    pop ax                         ; Move the lower 16 bits of EAX to AX

    ; Use the enhanced disk_read
    push ax                        ; LBA address
    mov cl, 1                      ; Number of sectors to read
    push bx                        ; Push the word-sized BX (contains DL in lower byte)
    push ds                        ; Push Data Segment
    push di                        ; Offset in DS
    call disk_read
    pop di
    pop ds
    pop bx                         ; Pop back into BX
    mov dl, bl                     ; Restore drive number to DL if needed (disk_read uses DL)
    pop ax
    jc .read_root_error

    add di, FAT12_SECTOR_SIZE
    inc si
    pop si
    pop cx
    loop .read_root_loop
    jmp .read_root_done

.read_root_error:
    mov ax, 0
    jmp .read_root_exit

.read_root_done:
    mov ax, 1

.read_root_exit:
    ret

print_directory_entries:
    mov di, directory_buffer
    mov cx, [root_dir_entries]

.print_dir_loop:
    push cx
    push di

    ; Check if entry is empty
    cmp byte [di], 0x00
    je .next_entry

    ; Check if entry is deleted
    cmp byte [di], 0xE5
    je .next_entry

    ; Get attributes
    mov al, [di + DIR_ATTRIBUTES]
    and al, ATTR_VOLUME_ID   ; Skip volume label
    jnz .not_volume_id

    jmp .next_entry

.not_volume_id:

    ; Print filename (8 bytes)
    mov si, di + DIR_NAME
    mov cx, 8
    call print_filename

    ; Print extension (3 bytes)
    mov si, directory_buffer ; Load buffer base
    add si, di               ; Add current directory entry offset
    add si, DIR_EXTENSION    ; Add extension offset
    mov cx, 3
    call print_extension

    ; Print size
    mov eax, [di + DIR_FILE_SIZE]
    call print_filesize

    ; Print newline
    mov si, sym_space_nl
    call puts

.next_entry:
    add di, FAT12_DIR_ENTRY_SIZE
    pop di
    pop cx
    loop .print_dir_loop
    ret

print_filename:
    push cx
    push si

.print_filename_loop:
    mov al, [si]
    cmp al, ' '            ; Stop at space
    je .print_filename_done
    mov ah, 0x0E
    int 0x10
    inc si
    loop .print_filename_loop

.print_filename_done:
    pop si
    pop cx
    ret

print_extension:
    push cx
    push si

    cmp byte [si], ' '
    je .print_extension_done

    mov si, sym_dot
    call puts

.print_extension_loop:
    mov al, [si]
    cmp al, ' '            ; Stop at space
    je .print_extension_done
    mov ah, 0x0E
    int 0x10
    inc si
    loop .print_extension_loop

.print_extension_done:
    pop si
    pop cx
    ret

print_filesize:
    push eax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

.print_filesize_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test eax, eax
    jnz .print_filesize_loop

    mov si, sym_space
    call puts

.print_filesize_loop2:
    pop dx
    add dl, '0'
    mov ah, 0x0E
    int 0x10
    loop .print_filesize_loop2

    pop dx
    pop cx
    pop bx
    pop eax
    ret


; Data goes here
sml_row1:       db " /#########\   /##      ##\  /#########\   ##          ", ENDL, 0
sml_row2:       db " ##       ##   ## ## ## ##   ##       ##   ##          ", ENDL, 0
sml_row3:       db " ##            ##   #   ##   ##       ##   ##          ", ENDL, 0
sml_row4:       db " \#########\   ##       ##   ##       ##   ##          ", ENDL, 0
sml_row5:       db "          ##   ##       ##   ##       ##   ##          ", ENDL, 0
sml_row6:       db " ##       ##   ##       ##   ##       ##   ##       ##", ENDL, 0
sml_row7:       db " \#########/   ##       ##   \#########/   \#########/", ENDL, ENDL, 0

wlc_kernel_loaded: db "[  OK  ] Kernel loaded successfully without panicking.", ENDL, 0
wlc_welcome:      db "[ INFO ] Welcome to SMOLOS! Use the `help` command to show all commands.", ENDL, ENDL, 0

ver_blr_version:  db "[ INFO ] Bootloader version - 5", ENDL, 0
ver_knl_version:  db "[ INFO ] Kernel version    - 10", ENDL, 0

crd_by:           db ENDL, "[ INFO ] SMOLOS by Subhrajit Sain (ANW), 2025", ENDL, 0
crd_github_repo:  db "[ INFO ] Github repo: https://github.com/SubhrajitSain/SMOLOS", ENDL, 0
crd_website:      db "[ INFO ] Website: Soon maybe...", ENDL, 0
crd_contrib:      db "[ INFO ] This OS is in need of contribution, and is under construction.", ENDL, ENDL, 0

sym_prompt:       db '-> ', 0
sym_dash:         db '-', 0
sym_dot:          db '.', 0
sym_space:        db ' ', 0
sym_space_nl:     db ' ', ENDL, 0

cmd_buffer:       times 256 db 0
cmd_help:         db 'help', 0
cmd_clear:        db 'clear', 0
cmd_reboot:       db 'reboot', 0
cmd_halt:         db 'halt', 0
cmd_echo:         db 'echo', 0
cmd_version:      db 'version', 0
cmd_ls:           db 'ls', 0

msg_help:         db "[ INFO ] Available commands: help, clear, reboot, halt, echo, version, ls", ENDL, 0
msg_reboot:       db "[ INFO ] Rebooting...", ENDL, 0
msg_halt:         db "[ INFO ] CPU fully halted. It is now safe to turn off your computer.", ENDL, 0

err_unknown_cmd:  db "[ ERR! ] Unknown command! Use `help` to see a list of available commands.", ENDL, 0
err_long_prompt:  db ENDL, "[ ERR! ] Prompt too long, try shortening it a bit.", ENDL, 0
err_critical:     db "[ CRIT ] SMOLOS has encountered a critical issue. Press any key to restart.", 0
err_disk_error:   db "[ ERR! ] Disk read error", ENDL, 0
