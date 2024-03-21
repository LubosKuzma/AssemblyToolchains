section .data
    msg_address: db "Enter the memory location (hex): ", 0x00
    msg_address_len: equ $ - msg_address
    msg_value: db "Enter the value to write (hex): ", 0x00
    msg_value_len: equ $ - msg_value
    Menu_Text: db "Select R (read) or W (write) to continue: ", 0x00
    Menu_Text_len: equ $ - Menu_Text
    read_success: db "Value read from memory: ", 0x00
    read_success_len: equ $ - read_success

section .bss
    memory_address: resq 1 ; Reserve 8 bytes for memory address (64-bit)
    operation: resb 2       ; Reserve 2 bytes for operation (R or W and null terminator)
    value: resq 1           ; Reserve 8 bytes for value to write (64-bit)
    buffer: resb 10         ; Reserve 10 bytes for input buffer

section .text
    global _start

_start:
    jmp start_menu

start_menu:
    ; PROMPT THE USER FOR THE MEMORY LOCATION:
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, msg_address
    mov rdx, msg_address_len
    syscall

    ; Read the memory location entered by the user
    mov rax, 0       ; syscall number for sys_read
    mov rdi, 0       ; file descriptor 0 (stdin)
    mov rsi, buffer
    mov rdx, 10      ; Read up to 10 bytes
    syscall

    ; Convert hexadecimal input to integer
    mov rax, 0      ; Clear RAX to prepare for conversion
    mov rdi, buffer ; Address of string to convert
    call hex_to_int ; Convert hexadecimal string to integer
    mov [memory_address], rax ; Store the memory address

menu:
    ; Prompt the user for operation (R or W)
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, Menu_Text
    mov rdx, Menu_Text_len
    syscall

    ; Read the operation entered by the user
    mov rax, 0      ; syscall number for sys_read
    mov rdi, 0      ; file descriptor 0 (stdin)
    mov rsi, operation
    mov rdx, 2      ; Read 2 bytes (operation and null terminator)
    syscall

    ; Check if the operation is R (Read)
    cmp byte [operation], 'R'
    je read_memory

    ; Check if the operation is W (Write)
    cmp byte [operation], 'W'
    je write_memory

    ; If neither R nor W, loop back to start menu
    jmp menu

read_memory:
    ; Read from memory address
    mov rax, [memory_address]
    mov rax, [rax]           ; Load the value from memory
    mov rsi, rax              ; Value to print
    mov rdi, 0                ; File descriptor 0 (stdout)
    mov rax, 0x01             ; syscall number for sys_write
    mov rdx, 8                ; Number of bytes to write (64-bit)
    syscall
    jmp start_menu

write_memory:
    ; Prompt the user to enter value to write
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, msg_value
    mov rdx, msg_value_len
    syscall

    ; Read the value entered by the user
    mov rax, 0                ; syscall number for sys_read
    mov rdi, 0                ; file descriptor 0 (stdin)
    mov rsi, buffer
    mov rdx, 10               ; Read up to 10 bytes
    syscall

    ; Convert hexadecimal input to integer
    mov rax, 0      ; Clear RAX to prepare for conversion
    mov rdi, buffer ; Address of string to convert
    call hex_to_int ; Convert hexadecimal string to integer
    mov [value], rax ; Store the value to write

    ; Write value to memory address
    mov rax, [memory_address]
    mov rbx, [value]          ; Load the value to write
    mov [rax], rbx            ; Write the value to memory address

    jmp start_menu

; Function to convert hexadecimal string to integer
hex_to_int:
    xor rcx, rcx      ; Clear RCX for counting
    xor rax, rax      ; Clear RAX for accumulating result

hex_to_int_loop:
    movzx rbx, byte [rdi + rcx] ; Load the next character
    cmp rbx, 0         ; Check for null terminator
    je hex_to_int_done
    imul rax, rax, 16  ; Multiply current result by 16
    cmp rbx, '0'
    jb hex_to_int_error ; Check if below '0'
    cmp rbx, '9'
    jbe hex_to_int_digit ; Check if between '0' and '9'
    sub rbx, 'A' - 10  ; Adjust for 'A' to 'F'
    cmp rbx, 5
    jbe hex_to_int_digit ; Check if between 'A' and 'F'
    sub rbx, 'a' - 'A' ; Adjust lowercase 'a' to 'A'
hex_to_int_digit:
    add rax, rbx       ; Add the digit to result
    inc rcx            ; Move to the next character
    jmp hex_to_int_loop

hex_to_int_error:
    ; Handle error (invalid hexadecimal character)
    ; You can print an error message or take appropriate action
    ; For simplicity, this example just terminates the program
    mov rax, 60       ; syscall number for sys_exit
    xor rdi, rdi      ; Exit code 0 (success)
    syscall

hex_to_int_done:
    ret
