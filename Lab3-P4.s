section .text
global _start

_start:
    mov rbx, 0x00   ; loop counter
.loop:
    lea rcx, [text+rbx]
    mov al, byte [rcx]
    cmp al, 0x00
    jz _exit ; terminate at the end of message

    cmp al, '.'
    jz _found
    inc rbx
    jmp .loop

_found:
    call _print_offset
    jmp _exit

_print_offset:
    ; Print the offset
    mov rax, 1          ; syscall number for write
    mov rdi, 1          ; File descriptor for STDOUT
    mov rsi, message_prompt
    mov rdx, message_prompt_len
    syscall

    ; Convert the offset to ASCII and print
    mov al, bl          ; Convert offset to ASCII
    add al, '0'
    mov rdi, rbx        ; Print the offset
    call _print
    ret

_print:
    ; Print a single character
    mov rax, 1          ; syscall number for write
    mov rdi, 1          ; File descriptor for STDOUT
    mov rdx, 1          ; Number of bytes to write
    syscall
    ret

_exit:
    ; Exit the program
    mov rax, 60         ; syscall number for exit
    xor rdi, rdi        ; Exit code 0
    syscall

section .data
    message_prompt db "Found at this offset: ", 0
    message_prompt_len equ $ - message_prompt
    text db "0 - term. msg.", 0

section .bss
    msg_offset resb 1
