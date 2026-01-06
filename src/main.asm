; Main Assembly program for SQLite Social Network Operations
; NASM x86_64 Linux

%include "include/constants.inc"
%include "include/sqlite_functions.inc"

section .data
    ; Menu strings
    menu_title      db "=== Social Network Database Manager (Assembly + SQLite) ===", 10, 0
    menu_options    db "1. Create New User", 10,
                    db "2. Create Post", 10,
                    db "3. Follow User", 10,
                    db "4. Like Post", 10,
                    db "5. Add Comment", 10,
                    db "6. View User Statistics", 10,
                    db "7. Delete User", 10,
                    db "8. Update User Profile", 10,
                    db "9. Exit", 10, 10,
                    db "Select option: ", 0
    
    ; SQL Statements
    sql_create_post db "INSERT INTO posts (user_id, content, post_type) VALUES (?, ?, ?);", 0
    sql_follow_user db "INSERT OR IGNORE INTO followers (follower_id, following_id) VALUES (?, ?);", 0
    sql_like_post   db "INSERT OR IGNORE INTO likes (user_id, target_type, target_id) VALUES (?, 'post', ?);", 0
    sql_add_comment db "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?);", 0
    sql_delete_user db "DELETE FROM users WHERE user_id = ?;", 0
    sql_update_user db "UPDATE users SET bio = ? WHERE user_id = ?;", 0
    sql_get_stats   db "SELECT username, total_posts, follower_count FROM user_statistics WHERE user_id = ?;", 0
    
    ; Format strings
    prompt_password db "Password: ", 0
    prompt_name     db "Full Name: ", 0
    prompt_bio      db "Bio: ", 0
    prompt_user_id  db "User ID: ", 0
    prompt_post_id  db "Post ID: ", 0
    prompt_content  db "Content: ", 0
    prompt_post_type db "Post Type (text/image/video/link): ", 0
    prompt_follow_id db "User ID to follow: ", 0
    
    ; Result messages
    error_msg       db "Error: ", 0
    stats_header    db "Username | Posts | Followers", 10, "--------------------------------", 10, 0
    
    ; Buffer for user input
    input_buffer    times 256 db 0

section .bss
    ; Database connection
    db_handle       resq 1
    err_msg         resq 1
    
    stmt_handle     resq 1
    user_id_input   resq 1
    post_id_input   resq 1
    follower_id     resq 1
    following_id    resq 1

section .text
    global _start, db_handle, err_msg
    extern sqlite3_open, sqlite3_close, sqlite3_prepare_v2
    extern sqlite3_step, sqlite3_finalize, sqlite3_errmsg
    extern sqlite3_bind_text, sqlite3_bind_int, sqlite3_column_text
    extern sqlite3_column_int, printf, scanf, fgets, malloc, free

    extern initialize_database, create_user_record, create_post_record, create_follow_relationship, like_post_record, add_comment_record, view_user_statistics, delete_user_record, update_user_profile
    extern atoi

; Renamed to main to be compatible with GCC linking
main:
    ; Align the stack to a 16-byte boundary before calling any C functions
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16 

    ; Open the database connection
    call    open_database
    cmp     rax, 0
    jne     .exit_with_error

    ; Main loop to display menu and get user input
.main_loop:
    call    display_menu
    call    get_user_choice

    ; Route to the correct function based on user input
    cmp     rax, 1
    je      .create_user
    cmp     rax, 2
    je      .view_all_users
    cmp     rax, 3
    je      .create_post
    cmp     rax, 4
    je      .follow_user
    cmp     rax, 5
    je      .like_post
    cmp     rax, 6
    je      .add_comment
    cmp     rax, 7
    je      .view_stats
    cmp     rax, 8
    je      .delete_user
    cmp     rax, 9
    je      .update_user
    cmp     rax, 10
    je      .exit_program
    
    ; If input is invalid, loop again
    jmp     .main_loop

.create_user:
    call    create_user_record
    jmp     .main_loop

.view_all_users:
    call    view_all_users_record
    jmp     .main_loop

.create_post:
    call    create_post_record
    jmp     .main_loop

.follow_user:
    call    create_follow_relationship
    jmp     .main_loop

.like_post:
    call    like_post_record
    jmp     .main_loop

.add_comment:
    call    add_comment_record
    jmp     .main_loop

.view_stats:
    call    view_user_statistics
    jmp     .main_loop

.delete_user:
    call    delete_user_record
    jmp     .main_loop

.update_user:
    call    update_user_profile
    jmp     .main_loop
    
; Exit procedures
.exit_with_error:
    mov     rdi, 1      ; Error code
    call    close_database
    jmp     .exit

.exit_program:
    mov     rdi, 0      ; Success code
    call    close_database

.exit:
    ; Restore stack and return
    leave
    ret                 ; Return from main