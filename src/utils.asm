; Utility functions for input/output and conversions

section .bss
    input_buffer resb 256

section .data
    column_separator db 9, 0 ; tab, null-terminated
    newline db 10, 0     ; newline, null-terminated

section .text
    global get_input, atoi, trim_newline, print_result_set
    extern fgets, printf, sqlite3_step, sqlite3_column_text

; Get string input from user
; rdi = buffer, rsi = max length
get_input:
    push rbp
    mov rbp, rsp
    
    mov rdx, rdi
    mov rdi, input_buffer
    mov rsi, 256
    call fgets
    
    ; Remove newline
    mov rdi, input_buffer
    call trim_newline
    
    ; Copy to destination
    mov rsi, input_buffer
    mov rdi, [rbp+16]
.copy_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    test al, al
    jnz .copy_loop
    
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
    sub rdx, '0'
    imul rax, 10
    add rax, rdx
    inc rcx
    jmp .convert
.done:
    ret

; Trim newline from string
trim_newline:
    mov rcx, rdi
.find_end:
    cmp byte [rcx], 0
    je .check_newline
    inc rcx
    jmp .find_end
.check_newline:
    dec rcx
    cmp byte [rcx], 10
    jne .done
    mov byte [rcx], 0
.done:
    ret

; Print SQLite result set
print_result_set:
    push rbp
    mov rbp, rsp
    
    ; Column count in rsi
    mov rbx, rdi  ; statement handle
    mov r12, rsi  ; column count
    
.fetch_row:
    mov rdi, rbx
    call sqlite3_step
    cmp rax, 100  ; SQLITE_ROW
    jne .done
    
    ; Print columns
    xor r13, r13
.print_columns:
    cmp r13, r12
    jge .next_row
    
    mov rdi, rbx
    mov rsi, r13
    call sqlite3_column_text
    
    mov rdi, rax
    call printf
    
    ; Add separator
    mov rdi, column_separator
    call printf
    
    inc r13
    jmp .print_columns

.next_row:
    mov rdi, newline
    call printf
    jmp .fetch_row

.done:
    mov rsp, rbp
    pop rbp
    ret