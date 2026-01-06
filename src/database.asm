%include "include/constants.inc"
; Database interaction routines

section .data
    ; Prompt strings
    prompt_username db "Username: ", 0
    prompt_email    db "Email: ", 0
    
    ; SQL Statements
    sql_create_user db "INSERT INTO users (username, email, password_hash, full_name, bio) VALUES (?, ?, ?, ?, ?);", 0
    
    ; Result messages
    success_msg     db "Operation completed successfully!", 10, 0
    
    sql_enable_fk db "PRAGMA foreign_keys = ON;", 0

section .text
    global initialize_database, execute_sql, create_user_record, create_post_record, create_follow_relationship, like_post_record, add_comment_record, view_user_statistics, delete_user_record, update_user_profile
    extern printf, get_input, atoi, print_result_set, db_handle, err_msg
    extern sqlite3_open, sqlite3_errmsg, sqlite3_prepare_v2, sqlite3_step, sqlite3_finalize, sqlite3_bind_text, sqlite3_bind_int, sqlite3_column_text, sqlite3_column_int

; Initialize database connection
initialize_database:
    push rbp
    mov rbp, rsp
    
    ; Open database
    mov rdi, DB_PATH
    mov rsi, db_handle
    call sqlite3_open
    
    test rax, rax
    jnz .error
    
    ; Enable foreign keys
    mov rdi, [db_handle]
    mov rsi, sql_enable_fk
    mov rdx, 0
    mov rcx, 0
    mov r8, 0
    call execute_sql
    
    xor rax, rax
    jmp .exit

.error:
    ; Get error message
    mov rdi, [db_handle]
    call sqlite3_errmsg
    mov [err_msg], rax
    mov rax, -1

.exit:
    mov rsp, rbp
    pop rbp
    ret

; Execute SQL statement without parameters
execute_sql:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov [rbp-8], rdi  ; db handle
    mov [rbp-16], rsi ; sql string
    
    ; Prepare statement
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, -1
    lea rcx, [rbp-24]
    xor r8, r8
    call sqlite3_prepare_v2
    
    test rax, rax
    jnz .error_exec
    
    ; Execute statement
    mov rdi, [rbp-24]
    call sqlite3_step
    
    ; Finalize statement
    mov rdi, [rbp-24]
    call sqlite3_finalize
    
    xor rax, rax
    jmp .exit_exec

.error_exec:
    mov rax, -1

.exit_exec:
    mov rsp, rbp
    pop rbp
    ret

; Create user with parameters
create_user_record:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Get user input
    mov rdi, prompt_username
    call printf
    lea rdi, [rbp-16]
    mov rsi, 50
    call get_input
    
    mov rdi, prompt_email
    call printf
    lea rdi, [rbp-32]
    mov rsi, 50
    call get_input
    
    ; Prepare SQL statement
    mov rdi, [db_handle]
    mov rsi, sql_create_user
    lea rdx, [rbp-40]
    xor rcx, rcx
    call sqlite3_prepare_v2
    
    ; Bind parameters
    mov rdi, [rbp-40]
    mov rsi, 1
    lea rdx, [rbp-16]
    mov rcx, -1
    mov r8, 0 ; SQLITE_STATIC
    call sqlite3_bind_text
    
    mov rdi, [rbp-40]
    mov rsi, 2
    lea rdx, [rbp-32]
    mov rcx, -1
    mov r8, 0 ; SQLITE_STATIC
    call sqlite3_bind_text
    
    ; Execute
    mov rdi, [rbp-40]
    call sqlite3_step
    
    ; Finalize
    mov rdi, [rbp-40]
    call sqlite3_finalize
    
    ; Success message
    mov rdi, success_msg
    call printf
    
    mov rsp, rbp
    pop rbp
    ret

; Dummy functions for missing operations
create_post_record:
    ret
create_follow_relationship:
    ret
like_post_record:
    ret
add_comment_record:
    ret
view_user_statistics:
    ret
delete_user_record:
    ret
update_user_profile:
    ret