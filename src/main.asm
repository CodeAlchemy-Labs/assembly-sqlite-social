; Main Assembly program for SQLite Social Network Operations
; NASM x86_64 Linux

%include "include/constants.inc"
%include "include/sqlite_functions.inc"

section .data
    ; Menu strings
    menu_title      db "=== Social Network Database Manager (Assembly + SQLite) ===", 10, 0
    menu_options    db "1. Create New User", 10,
                    db "2. View All Users", 10,
                    db "3. Create Post", 10,
                    db "4. Follow User", 10,
                    db "5. Like Post", 10,
                    db "6. Add Comment", 10,
                    db "7. View User Statistics", 10,
                    db "8. Delete User", 10,
                    db "9. Update User Profile", 10,
                    db "10. Exit", 10, 10,
                    db "Select option: ", 0
    
    ; Prompt strings
    prompt_choice   db "Choice: ", 0
    
    ; Result messages
    success_msg     db "Operation completed successfully!", 10, 0
    error_msg       db "Error occurred.", 10, 0
    goodbye_msg     db "Goodbye!", 10, 0
    not_impl_msg    db "Feature not yet implemented.", 10, 0
    
    ; Buffer for user input
    input_buffer    times 256 db 0

section .text
    global main
    extern printf, fgets, stdin, atoi, exit
    
    ; Database functions
    extern initialize_database, close_database
    extern create_user_record, view_all_users_record
    extern create_post_record, create_follow_relationship
    extern like_post_record, add_comment_record
    extern view_user_statistics, delete_user_record, update_user_profile
    extern trim_newline
    extern msg_not_implemented ; Added for inlined "not implemented" message in main.asm ; Added this line

main:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack to 16 bytes
    sub rsp, 32        ; Allocate local space (multiple of 16 for C calls)
    
    ; Initialize database
    call initialize_database
    cmp rax, 0
    jnz .error_exit_init ; Changed label name for clarity
    
    ; Main program loop
.main_loop:
    ; Display menu
    mov rdi, menu_title
    call printf
    
    mov rdi, menu_options
    call printf
    
    mov rdi, prompt_choice
    call printf
    
    ; Get user input
    mov rdi, input_buffer
    mov rsi, 256
    mov rdx, [rel stdin]
    call fgets
    
    ; Remove newline
    mov rdi, input_buffer
    call trim_newline
    
    ; Convert to integer
    mov rdi, input_buffer
    call atoi
    mov ebx, eax      ; Save choice in ebx
    
    ; Process choice
    cmp ebx, 1
    je .create_user
    cmp ebx, 2
    je .view_users
    cmp ebx, 3
    je .create_post
    cmp ebx, 4
    je .follow_user
    cmp ebx, 5
    je .like_post
    cmp ebx, 6
    je .add_comment
    cmp ebx, 7
    je .view_stats
    cmp ebx, 8
    je .delete_user
    cmp ebx, 9
    je .update_user
    cmp ebx, 10
    je .exit_program
    
    ; Invalid choice, loop again
    jmp .main_loop

.create_user:
    call create_user_record
    cmp rax, 0          ; Check return value from create_user_record
    jnz .db_op_error    ; If error, jump to generic db_op_error handler
    jmp .main_loop

.view_users:
    call view_all_users_record
    cmp rax, 0          ; Check return value from view_all_users_record
    jnz .db_op_error    ; If error, jump to generic db_op_error handler
    jmp .main_loop

.create_post:
    call create_post_record
    jmp .main_loop

.follow_user:
    call create_follow_relationship
    jmp .main_loop

.like_post:
    call like_post_record
    jmp .main_loop

.add_comment:
    call add_comment_record
    jmp .main_loop

.view_stats:
    call view_user_statistics
    jmp .main_loop

.delete_user:
    call delete_user_record
    jmp .main_loop

.update_user:
    call update_user_profile
    jmp .main_loop

.exit_program:
    ; Close database
    call close_database
    
    ; Success message
    mov rdi, goodbye_msg
    call printf
    
    ; Exit
    xor edi, edi      ; Exit code 0
    call exit

.db_op_error:       ; Generic error handler for database operations
    ; Specific SQLite error message would have been printed by database.asm function
    mov rdi, error_msg ; Print generic "Error occurred."
    call printf
    jmp .main_loop

.error_exit_init:    ; Error during initialize_database
    mov rdi, error_msg
    call printf
    mov edi, 1
    call exit

; Removed the local trim_newline_helper function as it's now external.

section .note.GNU-stack noalloc noexec nowrite progbits