; utils.asm - Utility functions for input/output and conversions

section .data
    column_separator db 9, 0 ; tab, null-terminated
    newline db 10, 0         ; newline, null-terminated
    space db " ", 0

section .bss
    input_buffer resb 256

section .text
    global get_input, atoi, trim_newline, print_string, print_newline
    global string_to_int, print_int, int_to_string
    extern fgets, printf, stdin, strlen

; Get string input from user
; rdi = buffer, rsi = max length
get_input:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack
    sub rsp, 16        ; Allocate space for alignment, no local vars
    
    ; RDI (buffer) and RSI (max length) are already set by caller
    mov rdx, [rel stdin] ; RDX = stdin
    call fgets           ; Call fgets(RDI, RSI, RDX)
    
    ; fgets returns RDI (buffer) or NULL in RAX.
    ; Check if fgets returned NULL. If so, don't trim.
    test rax, rax
    jz .fgets_error_or_null ; Handle NULL return from fgets, skip trim
    
    ; Trim newline from the input
    ; RDI still holds the buffer from fgets (original argument)
    call trim_newline
    
.fgets_error_or_null: ; If fgets returned NULL, skip trim
    add rsp, 16        ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; Convert string to integer
; rdi = string
; returns rax = integer
atoi:
    xor rax, rax
    xor rcx, rcx
.convert:
    movzx rdx, byte [rdi + rcx]
    test rdx, rdx
    jz .done
    cmp rdx, '0'
    jb .done
    cmp rdx, '9'
    ja .done
    sub rdx, '0'
    imul rax, 10
    add rax, rdx
    inc rcx
    jmp .convert
.done:
    ret

; Trim newline from string
; rdi = string
trim_newline:
    mov rcx, rdi
.find_end:
    cmp byte [rcx], 0
    je .check_newline
    inc rcx
    jmp .find_end
.check_newline:
    cmp rcx, rdi      ; Check if we are at the beginning of the string (empty string case)
    je .done          ; If so, no newline to trim or string was empty
    dec rcx           ; Move back one byte from null terminator
    cmp byte [rcx], 10
    jne .done
    mov byte [rcx], 0
.done:
    ret

; trim_newline_helper is removed as it's no longer needed

; Print string (simple wrapper for printf)
; rdi = string
print_string:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack
    sub rsp, 16        ; Allocate for alignment, no local vars
    call printf
    add rsp, 16
    mov rsp, rbp
    pop rbp
    ret

; Print newline
print_newline:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack
    sub rsp, 16        ; Allocate for alignment
    mov rdi, newline   ; RDI already holds the newline string
    call printf
    add rsp, 16
    mov rsp, rbp
    pop rbp
    ret

; String to int (alternative name)
string_to_int:
    call atoi
    ret

; Print integer (simple)
; rdi = integer
print_int:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack
    sub rsp, 32        ; Allocate for buffer (21 bytes) + padding
    
    ; Simple conversion
    mov rax, rdi       ; Integer to print (argument in RDI)
    mov rbx, 10
    
    ; Buffer for string conversion on stack: at [rsp+0]
    lea r9, [rsp+20]   ; Pointer to the end of the buffer (rsp+20), last byte in buffer
    mov byte [r9], 0   ; Null terminate the string end
    dec r9             ; Move pointer to the last digit position (rsp+19)
    
    cmp rax, 0
    je .print_zero
    
.convert_loop:
    xor rdx, rdx       ; Clear RDX for division
    div rbx            ; RAX = RAX / RBX, RDX = RAX % RBX
    add dl, '0'        ; Convert digit to ASCII
    mov [r9], dl       ; Store digit in buffer
    dec r9             ; Move to next position in buffer
    test rax, rax      ; Check if quotient is zero
    jnz .convert_loop
    
    inc r9             ; Adjust pointer to the beginning of the string
    
.print:
    mov rdi, r9        ; RDI points to the start of the string
    call printf
    
    jmp .exit_print_int
    
.print_zero:
    lea rdi, [rsp]     ; Point to the start of the buffer for "0"
    mov byte [rdi], '0'
    mov byte [rdi+1], 0
    call printf
    
.exit_print_int:
    add rsp, 32        ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; Integer to string
; rdi = buffer, rsi = integer
int_to_string:
    push rbp
    mov rbp, rsp
    ; No C calls, no specific alignment needed beyond standard func setup
    
    mov rax, rsi
    mov rbx, 10
    mov rcx, 0
    
    test rax, rax
    jnz .convert
    mov byte [rdi], '0'
    mov byte [rdi+1], 0
    jmp .done
    
.convert:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert
    
    mov rsi, rdi
.store:
    pop rax
    mov [rsi], al
    inc rsi
    loop .store
    mov byte [rsi], 0

.done:
    mov rsp, rbp
    pop rbp
    ret