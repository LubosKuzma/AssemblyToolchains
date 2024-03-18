section .data
    input_msg db "Enter sentence: ", 0
    output_msg db "You entered: ", 0
    camel_case_msg db "Sentence with camel case is: ", 0
    newline db 10, 0
    debug_prefix db "DEBUG: ", 0

section .bss
    input_buffer resb 1000

section .text
global _start

; Syscall numbers
SYS_READ equ 0          ; sys_read
SYS_WRITE equ 1         ; sys_write
SYS_EXIT equ 60         ; sys_exit

_start:
    ; Print "Enter sentence: "
    mov rsi, input_msg
    call print_string

    ; Read input from user
    mov rdi, 0            ; File descriptor for STDIN (0)
    mov rsi, input_buffer ; Buffer to store input
    mov rdx, 1000         
    mov rax, SYS_READ     
    syscall

    ; Print newline
    mov rsi, newline
    call print_string

    ; Print "You entered: "
    mov rsi, output_msg
    call print_string

    ; Print entered string
    mov rsi, input_buffer
    call print_string

    ; Print newline
    mov rsi, newline
    call print_string

    ; Capitalize the first letter of each word
    mov rsi, input_buffer  ; Set RSI to point to input_buffer
    call capitalize_first_letter

    ; Print "Sentence with camel case is: "
    mov rsi, camel_case_msg
    call print_string

    ; Print camel case string
    mov rsi, input_buffer
    call print_string

    ; Exit program
    xor edi, edi            ; Return 0
    mov eax, SYS_EXIT       ; syscall number for exit
    syscall

print_string:
    ; Print the null-terminated string at RSI
    mov rax, SYS_WRITE      ; syscall number for write
    mov rdi, 1              ; File descriptor for STDOUT (1)
    xor rcx, rcx            ; Zero out RCX to calculate the length of the string
    ; Calculate the length of the string
    .calc_length:
        cmp byte [rsi + rcx], 0    ; Check for null terminator
        je .print                  ; If null terminator found, proceed to print
        inc rcx                    ; Move to the next character
        cmp rcx, 1000              ; Check if we've reached the maximum buffer size
        jge .print                 ; If so, proceed to print
        jmp .calc_length
    .print:
    mov rdx, rcx            ; Set the length of the string in RDX
    syscall
    ret

capitalize_first_letter:
    ; Capitalize the first letter of each word
    movzx rcx, byte [rsi]   ; Load current character
    cmp rcx, 0              ; Check for end of string
    je .end_capitalize      ; If end of string, exit
    cmp rcx, 'a'            ; Check if the current character is lowercase
    jb .skip_capitalize     ; If it's lower than 'a', it's not a lowercase letter
    cmp rcx, 'z'            ; Check if the current character is lowercase
    ja .skip_capitalize     ; If it's higher than 'z', it's not a lowercase letter
    ; Current character is lowercase, convert it to uppercase
    sub rcx, 32             ; Convert lowercase to uppercase
    mov [rsi], cl           ; Store the modified character back to the buffer
.skip_capitalize:
    .capitalize_loop:
        inc rsi             ; Move to the next character
        movzx rcx, byte [rsi]   ; Load current character
        cmp rcx, 0          ; Check for end of string
        je .end_capitalize ; If end of string, exit
        cmp rcx, ' '        ; Check if the current character is a space
        jne .skip_capitalize ; If it is not, skip to the next character
        ; Capitalize the next character (if it exists)
        movzx rcx, byte [rsi + 1] ; Load next character
        cmp rcx, 0          ; Check for end of string
        je .end_capitalize ; If end of string, exit
        cmp rcx, 'a'        ; Check if the next character is lowercase
        jb .skip_capitalize ; If it's lower than 'a', it's not a lowercase letter
        cmp rcx, 'z'        ; Check if the next character is lowercase
        ja .skip_capitalize ; If it's higher than 'z', it's not a lowercase letter
        ; Next character is lowercase, convert it to uppercase
        sub rcx, 32         ; Convert lowercase to uppercase
        mov [rsi + 1], cl   ; Store the modified character back to the buffer
        jmp .capitalize_loop
    .end_capitalize:
    ret
