section .data
    msg_address: db "Enter the memory location (hex): ", 0x00
    msg_address_len: equ $ - msg_address
    msg_value: db "Enter the value to write (hex): ", 0x00
    msg_value_len: equ $ - msg_value
    Menu_Text: db "Select R (read) or W (write) to continue: ", 0x00
    Menu_Text_len: equ $ - Menu_Text
    read_success: db "Value read from memory: ", 0x00
    read_success_len: equ $ - read_success
    write_success: db "Value written to memory.", 0x00
    write_success_len: equ $ - write_success
    invalid_hex: db "Invalid hex input. Please enter a valid hexadecimal value.", 0x00
    invalid_hex_len: equ $ - invalid_hex

section .bss
    empty: resb 0xFFFF
    operation: resb 0x02
    value: resb 0x100       ; Assuming value_size is 0x100 as it's not defined in the code
    result: resb 0x20
    hex_table_addr: resb 0x100 ; Assuming value_size is 0x100 as it's not defined in the code
    memory_address: resq 1

section .text
    global _start

_start:
Menu:
    ; PROMPT THE USER FOR THE MEMORY LOCATION:
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, msg_address
    mov rdx, msg_address_len
    syscall

    ; Read the memory location entered by the user
    mov rax, 0x00
    mov rdi, 0x00
    mov rsi, empty
    mov rdx, 0xFFFF
    syscall

    ; Convert hexadecimal input to integer
    mov rax, 0
    mov rdi, empty
    call hex_to_int
    mov [memory_address], rax ; Store the memory address

    ; Ask user to select Read (R) or Write (W)
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, Menu_Text
    mov rdx, Menu_Text_len
    syscall

    ; Read the instruction that the user entered
    mov rax, 0x00
    mov rdi, 0x00
    mov rsi, operation
    mov rdx, 0x02
    syscall

    ; Capitalize the input
    xor rax, rax
    mov al, byte [operation]
    and al, 0b11011111

    ; Handle menu selection
    cmp rax, 'R'
    je Read
    cmp rax, 'W'
    je Write
    jmp Menu

Read:
    ; Handle Read operation
    ; Read from memory address
    mov rax, [memory_address]
    mov rax, [rax]               ; Load the value from memory
    mov rsi, read_success        ; Print message
    mov rdi, 0                   ; File descriptor 0 (stdout)
    mov rax, 0x01                ; syscall number for sys_write
    mov rdx, read_success_len    ; Number of bytes to write
    syscall

    ; Convert integer value to hexadecimal string
    mov rax, [memory_address]
    mov rax, [rax]               ; Load the value from memory
    mov rsi, result              ; Address to store the read value
    call int_to_hex              ; Convert integer value to hexadecimal string

    ; Write the result
    mov rax, 0x01                ; syscall number for sys_write
    mov rdi, 0x01                ; File descriptor 1 (stdout)
    mov rdx, 16                  ; Number of bytes to write
    syscall

    jmp Menu

Write:
    ; Handle Write operation
    ; PROMPT THE USER FOR THE VALUE TO WRITE:
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, msg_value
    mov rdx, msg_value_len
    syscall

    ; Read the value entered by the user
    mov rax, 0                ; syscall number for sys_read
    mov rdi, 0                ; file descriptor 0 (stdin)
    mov rsi, value
    mov rdx, 20               ; Read up to 20 bytes
    syscall

    ; Convert hexadecimal input to integer
    mov rax, 0                ; Clear RAX to prepare for conversion
    mov rdi, value            ; Address of string to convert
    call hex_to_int           ; Convert hexadecimal string to integer

    ; Write value to memory address
    mov rax, [memory_address]
    mov [rax], rax            ; Write the value to memory address

    ; Print success message
    mov rax, 0x01             ; syscall number for sys_write
    mov rdi, 0x01             ; File descriptor 1 (stdout)
    mov rsi, write_success    ; Message
    mov rdx, write_success_len; Message length
    syscall

    jmp Menu

; Function to convert hexadecimal string to integer
hex_to_int:
    xor rcx, rcx      ; Clear RCX
    xor rax, rax      ; Clear RAX

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
    ; For simplicity, this example just terminates the program
    mov rax, 60       ; syscall number for sys_exit
    xor rdi, rdi      ; Exit code 0 (success)
    syscall

hex_to_int_done:
    ret

; Function to convert integer value to hexadecimal string
int_to_hex:
    mov rdi, rsi        ; Destination buffer
    mov rcx, 16         ; Number of digits
    mov rbx, rdx        ; Value to convert

int_to_hex_loop:
    rol rbx, 4          ; Rotate the value to get the next nibble
    mov dl, bl          ; Get the least significant nibble
    and dl, 0x0F        ; Mask the upper nibble
    cmp dl, 10
    jl int_to_hex_digit ; Jump if less than 10
    add dl, 'A' - 10    ; Convert to hex character ('A' - 10)

int_to_hex_digit:
    add dl, '0'         ; Convert to ASCII character
    mov [rdi], dl       ; Store the character
    inc rdi             ; Move to the next byte in the buffer
    loop int_to_hex_loop ; Continue until all digits are processed

    mov byte [rdi], 0   ; Null-terminate the string
    ret
