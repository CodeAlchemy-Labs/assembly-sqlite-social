%include "include/constants.inc"
; Database interaction routines

section .data
    ; Prompt strings
    prompt_username db "Username: ", 0
    prompt_email    db "Email: ", 0
    prompt_password db "Password (optional): ", 0
    prompt_fullname db "Full Name: ", 0
    prompt_bio      db "Bio (optional): ", 0
    
    ; SQL Statements
    sql_create_user db "INSERT INTO users (username, email, password_hash, full_name, bio) VALUES (?, ?, ?, ?, ?);", 0
    sql_view_users  db "SELECT user_id, username, email, full_name FROM users LIMIT 20;", 0
    
    ; Result messages
    success_msg     db "Operation completed successfully!", 10, 0
    error_msg       db "Error: ", 0
    users_header    db "ID  | Username       | Email                     | Full Name", 10
                    db "----+----------------+---------------------------+----------------", 10, 0
    
    sql_enable_fk   db "PRAGMA foreign_keys = ON;", 0
    test_sql        db "SELECT 1;", 0
    
    default_hash    db "default_hash_not_secure", 0
    separator       db " | ", 0
    newline_str     db 10, 0
    empty_str       db "", 0
    msg_not_implemented db "This feature is not yet implemented.", 10, 0
    sqlite_error_format db "SQLite Error [%d]: %s", 10, 0 ; New format string for errors

    db_schema_sql db "-- Professional Social Network Database Schema", 10
                  db "-- Applying Data Engineering Principles", 10, 10
                  db "PRAGMA foreign_keys = ON;", 10
                  db "PRAGMA journal_mode = WAL;", 10
                  db "PRAGMA synchronous = NORMAL;", 10
                  db "PRAGMA cache_size = -64000; -- 64MB cache", 10
                  db "PRAGMA temp_store = MEMORY;", 10, 10
                  db "-- Users table with proper constraints and indexing", 10
                  db "CREATE TABLE IF NOT EXISTS users (", 10
                  db "    user_id INTEGER PRIMARY KEY AUTOINCREMENT,", 10
                  db "    username VARCHAR(50) UNIQUE NOT NULL,", 10
                  db "    email VARCHAR(255) UNIQUE NOT NULL,", 10
                  db "    password_hash CHAR(64) NOT NULL, -- SHA-256", 10
                  db "    full_name VARCHAR(100) NOT NULL,", 10
                  db "    bio TEXT,", 10
                  db "    profile_picture_url VARCHAR(500),", 10
                  db "    date_of_birth DATE,", 10
                  db "    location VARCHAR(100),", 10
                  db "    website VARCHAR(255),", 10
                  db "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10
                  db "    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10
                  db "    is_verified BOOLEAN DEFAULT 0,", 10
                  db "    is_active BOOLEAN DEFAULT 1,", 10, 10
                  db "    -- Constraints", 10
                  db "    CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3),", 10
                  db "    CONSTRAINT chk_email_format CHECK (email LIKE '%_@__%.__%')", 10
                  db ");", 10, 10
                  db "-- Posts table with content management", 10
                  db "CREATE TABLE IF NOT EXISTS posts (", 10
                  db "    post_id INTEGER PRIMARY KEY AUTOINCREMENT,", 10
                  db "    user_id INTEGER NOT NULL,", 10
                  db "    content TEXT NOT NULL,", 10
                  db "    media_url VARCHAR(500),", 10
                  db "    post_type VARCHAR(20) DEFAULT 'text', -- text, image, video, link", 10
                  db "    visibility VARCHAR(20) DEFAULT 'public', -- public, friends, private", 10
                  db "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10
                  db "    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10
                  db "    like_count INTEGER DEFAULT 0,", 10
                  db "    comment_count INTEGER DEFAULT 0,", 10
                  db "    share_count INTEGER DEFAULT 0,", 10, 10
                  db "    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,", 10
                  db "    CONSTRAINT chk_post_type CHECK (post_type IN ('text', 'image', 'video', 'link')),", 10
                  db "    CONSTRAINT chk_visibility CHECK (visibility IN ('public', 'friends', 'private'))", 10
                  db ");", 10, 10
                  db "-- Followers/following relationship", 10
                  db "CREATE TABLE IF NOT EXISTS followers (", 10
                  db "    follower_id INTEGER NOT NULL,", 10
                  db "    following_id INTEGER NOT NULL,", 10
                  db "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10, 10
                  db "    PRIMARY KEY (follower_id, following_id),", 10
                  db "    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,", 10
                  db "    FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE,", 10
                  db "    CONSTRAINT chk_no_self_follow CHECK (follower_id != following_id)", 10
                  db ");", 10, 10
                  db "-- Comments with threading capability", 10
                  db "CREATE TABLE IF NOT EXISTS comments (", 10
                  db "    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,", 10
                  db "    post_id INTEGER NOT NULL,", 10
                  db "    user_id INTEGER NOT NULL,", 10
                  db "    parent_comment_id INTEGER, -- For nested comments", 10
                  db "    content TEXT NOT NULL,", 10
                  db "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10
                  db "    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10
                  db "    like_count INTEGER DEFAULT 0,", 10, 10
                  db "    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,", 10
                  db "    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,", 10
                  db "    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE", 10
                  db ");", 10, 10
                  db "-- Likes table (polymorphic - can like posts or comments)", 10
                  db "CREATE TABLE IF NOT EXISTS likes (", 10
                  db "    like_id INTEGER PRIMARY KEY AUTOINCREMENT,", 10
                  db "    user_id INTEGER NOT NULL,", 10
                  db "    target_type VARCHAR(10) NOT NULL, -- 'post' or 'comment'", 10
                  db "    target_id INTEGER NOT NULL,", 10
                  db "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10, 10
                  db "    UNIQUE(user_id, target_type, target_id),", 10
                  db "    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,", 10
                  db "    CONSTRAINT chk_target_type CHECK (target_type IN ('post', 'comment'))", 10
                  db ");", 10, 10
                  db "-- Messages table for private messaging", 10
                  db "CREATE TABLE IF NOT EXISTS messages (", 10
                  db "    message_id INTEGER PRIMARY KEY AUTOINCREMENT,", 10
                  db "    sender_id INTEGER NOT NULL,", 10
                  db "    receiver_id INTEGER NOT NULL,", 10
                  db "    content TEXT NOT NULL,", 10
                  db "    is_read BOOLEAN DEFAULT 0,", 10
                  db "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,", 10, 10
                  db "    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,", 10
                  db "    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE", 10
                  db ");", 10, 10
                  db "-- Indexes for performance optimization", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_users_created ON users(created_at);", 10, 10
                  
                                    db "CREATE INDEX IF NOT EXISTS idx_posts_user ON posts(user_id);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_posts_visibility ON posts(visibility);", 10, 10
                  
                                    db "CREATE INDEX IF NOT EXISTS idx_followers_follower ON followers(follower_id);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_followers_following ON followers(following_id);", 10, 10
                  
                                    db "CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_comments_user ON comments(user_id);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_comments_parent ON comments(parent_comment_id);", 10, 10
                  
                                    db "CREATE INDEX IF NOT EXISTS idx_likes_user ON likes(user_id);", 10
                                    db "CREATE INDEX IF NOT EXISTS idx_likes_target ON likes(target_type, target_id);", 10, 10
                  
                  db "CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);", 10
                  db "CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiver_id);", 10
                  db "CREATE INDEX IF NOT EXISTS idx_messages_conversation_fwd ON messages(sender_id, receiver_id, created_at);", 10
                  db "CREATE INDEX IF NOT EXISTS idx_messages_conversation_bwd ON messages(receiver_id, sender_id, created_at);", 0
                  db "-- Triggers for denormalized counters (for performance)", 10
                  db "CREATE TRIGGER update_post_counters_insert", 10
                  db "AFTER INSERT ON likes", 10
                  db "FOR EACH ROW", 10
                  db "WHEN NEW.target_type = 'post'", 10
                  db "BEGIN", 10
                  db "    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.target_id;", 10
                  db "END;", 10, 10
                  db "CREATE TRIGGER update_post_counters_delete", 10
                  db "AFTER DELETE ON likes", 10
                  db "FOR EACH ROW", 10
                  db "WHEN OLD.target_type = 'post'", 10
                  db "BEGIN", 10
                  db "    UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.target_id;", 10
                  db "END;", 10, 10
                  db "CREATE TRIGGER update_comment_counters_insert", 10
                  db "AFTER INSERT ON comments", 10
                  db "FOR EACH ROW", 10
                  db "BEGIN", 10
                  db "    UPDATE posts SET comment_count = comment_count + 1 WHERE post_id = NEW.post_id;", 10
                  db "END;", 10, 10
                  db "-- View for user statistics", 10
                  db "CREATE VIEW user_statistics AS", 10
                  db "SELECT ", 10
                  db "    u.user_id,", 10
                  db "    u.username,", 10
                  db "    u.full_name,", 10
                  db "    COUNT(DISTINCT p.post_id) as total_posts,", 10
                  db "    COUNT(DISTINCT f1.following_id) as following_count,", 10
                  db "    COUNT(DISTINCT f2.follower_id) as follower_count,", 10
                  db "    COALESCE(SUM(p.like_count), 0) as total_likes_received", 10
                  db "FROM users u", 10
                  db "LEFT JOIN posts p ON u.user_id = p.user_id", 10
                  db "LEFT JOIN followers f1 ON u.user_id = f1.follower_id", 10
                  db "LEFT JOIN followers f2 ON u.user_id = f2.following_id", 10
                  db "GROUP BY u.user_id;", 10, 10
                  db "-- Insert sample admin user", 10
                  db "INSERT OR IGNORE INTO users (username, email, password_hash, full_name, is_verified)", 10
                  db "VALUES ('admin', 'admin@social.net', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'System Administrator', 1);", 0

section .bss
    ; Variables globales
    global db_handle, err_msg
    db_handle       resq 1
    err_msg         resq 1
    
    stmt_handle     resq 1
    input_buffer    resb 256

section .text
    global initialize_database, close_database
    global create_user_record, view_all_users_record
    global create_post_record, create_follow_relationship
    global like_post_record, add_comment_record
    global view_user_statistics, delete_user_record, update_user_profile
    global msg_not_implemented ; Make msg_not_implemented globally visible
    global print_sqlite_error  ; Make print_sqlite_error globally visible
    
    extern printf, fgets, stdin
    extern sqlite3_open, sqlite3_close, sqlite3_exec
    extern sqlite3_prepare_v2, sqlite3_step, sqlite3_finalize
    extern sqlite3_errmsg, sqlite3_bind_text, sqlite3_bind_int
    extern sqlite3_column_text, sqlite3_column_int, sqlite3_bind_null
    extern sqlite3_errcode ; Added for robust error reporting
    extern trim_newline, atoi

; Initialize database connection
initialize_database:
    push rbp
    mov rbp, rsp
    and rsp, -16        ; Align stack to 16 bytes
    sub rsp, 32         ; Allocate local space (multiple of 16)
    
    ; Open database
    lea rdi, [DB_PATH]
    lea rsi, [db_handle]
    call sqlite3_open
    
    cmp rax, SQLITE_OK  ; Check if opening failed
    jne .error_open
    
    ; Enable foreign keys using sqlite3_exec
    mov rdi, [db_handle]
    lea rsi, [sql_enable_fk]
    xor rdx, rdx
    xor rcx, rcx
    xor r8, r8
    call sqlite3_exec
    
    cmp rax, SQLITE_OK  ; Check if enabling foreign keys failed
    jne .error_exec_pragma

    ; Execute the full database schema to create tables if they don't exist
    mov rdi, [db_handle]
    lea rsi, [db_schema_sql] ; Use the embedded schema SQL
    xor rdx, rdx             ; xCallback = NULL
    xor rcx, rcx             ; pArg = NULL
    xor r8, r8               ; pzErr = NULL
    call sqlite3_exec

    cmp rax, SQLITE_OK ; Check if schema execution failed
    jne .error_exec_schema

    ; If we reach here, initialization was successful
    xor rax, rax ; Return 0 for success
    jmp .exit

.error_open:
    ; For an error on sqlite3_open, rax contains an error code.
    ; db_handle is NULL in this case. We need to use sqlite3_errmsg(NULL).
    mov r10, rax        ; Save the error code from sqlite3_open in r10
    xor rdi, rdi        ; RDI = 0 for sqlite3_errmsg(NULL)
    call sqlite3_errmsg
    mov rdx, rax        ; RDX = error message string from sqlite3_errmsg(NULL)
    mov rsi, r10        ; RSI = original error code from sqlite3_open
    mov rdi, sqlite_error_format ; RDI = format string
    xor rax, rax        ; No floating-point arguments for printf
    call printf
    mov rax, -1
    jmp .exit

.error_exec_pragma:
.error_exec_schema:
    ; Use the db_handle which should be valid if we reached here
    mov rdi, [db_handle]
    call print_sqlite_error
    mov rax, -1

.exit:
    add rsp, 32         ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; Close database connection
close_database:
    push rbp
    mov rbp, rsp
    and rsp, -16        ; Align stack to 16 bytes
    sub rsp, 16         ; Allocate local space (multiple of 16, or just 0)
    
    mov rdi, [db_handle]
    call sqlite3_close
    
    add rsp, 16         ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; Create user with parameters
create_user_record:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack to 16 bytes
    ; Allocate space for 3 buffers (64*3=192) + padding for 16-byte alignment and safety.
    ; Buffers start at [rsp].
    sub rsp, 256
    
    ; --- Input Collection ---
    ; Get username
    mov rdi, prompt_username
    call printf
    lea rdi, [rsp]         ; username buffer at [rsp]
    mov rsi, 64
    mov rdx, [rel stdin]
    call fgets
    lea rdi, [rsp]
    call trim_newline
    
    ; Get email
    mov rdi, prompt_email
    call printf
    lea rdi, [rsp+64]      ; email buffer at [rsp+64]
    mov rsi, 64
    mov rdx, [rel stdin]
    call fgets
    lea rdi, [rsp+64]
    call trim_newline
    
    ; Get full name
    mov rdi, prompt_fullname
    call printf
    lea rdi, [rsp+128]     ; fullname buffer at [rsp+128]
    mov rsi, 64
    mov rdx, [rel stdin]
    call fgets
    lea rdi, [rsp+128]
    call trim_newline
    
    ; --- SQL Statement Preparation ---
    mov rdi, [db_handle]
    lea rsi, [sql_create_user]
    mov rdx, -1                ; nByte: -1 for null-terminated SQL
    lea rcx, [stmt_handle]     ; ppStmt: pointer to statement handle
    xor r8, r8                 ; pzTail: NULL
    call sqlite3_prepare_v2
    
    cmp rax, SQLITE_OK         ; Check if preparation failed
    jne .error_prepare_user

    ; --- Bind Parameters ---
    ; Bind username
    mov rdi, [stmt_handle]
    mov esi, 1                 ; Parameter index 1
    lea rdx, [rsp]             ; username (buffer at [rsp])
    mov rcx, -1                ; Length: -1 for null-terminated
    xor r8, r8                 ; xDel: SQLITE_STATIC (0)
    call sqlite3_bind_text
    cmp rax, SQLITE_OK
    jne .error_bind_user

    ; Bind email
    mov rdi, [stmt_handle]
    mov esi, 2                 ; Parameter index 2
    lea rdx, [rsp+64]          ; email (buffer at [rsp+64])
    mov rcx, -1
    xor r8, r8                 ; xDel: SQLITE_STATIC (0)
    call sqlite3_bind_text
    cmp rax, SQLITE_OK
    jne .error_bind_user

    ; Bind password hash
    mov rdi, [stmt_handle]
    mov esi, 3                 ; Parameter index 3
    lea rdx, [default_hash]    ; password hash (data section, static)
    mov rcx, -1
    xor r8, r8                 ; xDel: SQLITE_STATIC (0)
    call sqlite3_bind_text
    cmp rax, SQLITE_OK
    jne .error_bind_user
    
    ; Bind full name
    mov rdi, [stmt_handle]
    mov esi, 4                 ; Parameter index 4
    lea rdx, [rsp+128]         ; full name (buffer at [rsp+128])
    mov rcx, -1
    xor r8, r8                 ; xDel: SQLITE_STATIC (0)
    call sqlite3_bind_text
    cmp rax, SQLITE_OK
    jne .error_bind_user
    
    ; Bind NULL for bio (parameter 5)
    mov rdi, [stmt_handle]
    mov esi, 5                 ; Parameter index 5
    call sqlite3_bind_null     ; Bind NULL explicitly
    cmp rax, SQLITE_OK
    jne .error_bind_user ; Use the same error handling for all binds

    ; --- Execute Statement ---
    mov rdi, [stmt_handle]
    call sqlite3_step
    
    cmp rax, SQLITE_DONE       ; SQLITE_DONE (101) expected for successful INSERT
    jne .error_step_user
    
    ; --- Success ---
    ; Finalize statement
    mov rdi, [stmt_handle]
    call sqlite3_finalize
    
    mov rdi, success_msg
    call printf
    
    xor rax, rax               ; Return 0 for success
    jmp .exit_user

; --- Error Handling ---
.error_prepare_user:
    mov rdi, [db_handle]
    call print_sqlite_error
    mov rax, -1                ; Return -1 for error
    jmp .exit_user

.error_bind_user:
.error_step_user:
    mov rdi, [db_handle]
    call print_sqlite_error
    ; Finalize statement on error
    mov rdi, [stmt_handle]
    call sqlite3_finalize
    mov rax, -1                ; Return -1 for error
    jmp .exit_user

.exit_user:
    add rsp, 256               ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; View all users
view_all_users_record:
    push rbp
    mov rbp, rsp
    and rsp, -16       ; Align stack to 16 bytes
    sub rsp, 32        ; Allocate local space (multiple of 16)
    
    ; Print header
    mov rdi, users_header
    call printf
    
    ; Prepare statement
    mov rdi, [db_handle]
    lea rsi, [sql_view_users]
    mov rdx, -1                ; nByte: -1 for null-terminated SQL
    lea rcx, [stmt_handle]     ; ppStmt: pointer to statement handle
    xor r8, r8                 ; pzTail: NULL
    call sqlite3_prepare_v2
    
    cmp rax, SQLITE_OK         ; Check if preparation failed
    jne .error_prepare_view
    
.fetch_loop:
    mov rdi, [stmt_handle]
    call sqlite3_step
    
    cmp rax, SQLITE_ROW      ; Check if a row is available (SQLITE_ROW)
    je .process_row
    cmp rax, SQLITE_DONE     ; Check if all rows are processed (SQLITE_DONE)
    je .done_fetch
    ; If neither SQLITE_ROW nor SQLITE_DONE, then it's an error
    jmp .error_step_view

.process_row:
    ; Get user_id (column index 0)
    mov rdi, [stmt_handle]
    xor rsi, rsi             ; Column index 0
    call sqlite3_column_int
    push rax                 ; Save ID for print_int_simple
    
    ; Print ID
    pop rdi
    call print_int_simple
    mov rdi, separator
    call printf
    
    ; Get username (column index 1)
    mov rdi, [stmt_handle]
    mov esi, 1               ; Column index 1
    call sqlite3_column_text
    test rax, rax            ; Check if NULL
    jz .print_empty_username
    mov rdi, rax             ; Use returned string
    jmp .continue_print_username
.print_empty_username:
    mov rdi, empty_str       ; Use empty string
.continue_print_username:
    call printf
    mov rdi, separator
    call printf
    
    ; Get email (column index 2)
    mov rdi, [stmt_handle]
    mov esi, 2               ; Column index 2
    call sqlite3_column_text
    test rax, rax            ; Check if NULL
    jz .print_empty_email
    mov rdi, rax             ; Use returned string
    jmp .continue_print_email
.print_empty_email:
    mov rdi, empty_str       ; Use empty string
.continue_print_email:
    call printf
    mov rdi, separator
    call printf
    
    ; Get full_name (column index 3)
    mov rdi, [stmt_handle]
    mov esi, 3               ; Column index 3
    call sqlite3_column_text
    test rax, rax            ; Check if NULL
    jz .print_empty_fullname
    mov rdi, rax             ; Use returned string
    jmp .continue_print_fullname
.print_empty_fullname:
    mov rdi, empty_str       ; Use empty string
.continue_print_fullname:
    call printf
    
    ; Print newline
    mov rdi, newline_str
    call printf
    
    jmp .fetch_loop

.done_fetch:
    ; Finalize statement
    mov rdi, [stmt_handle]
    call sqlite3_finalize
    
    xor rax, rax               ; Return 0 for success
    jmp .exit_view

; --- Error Handling ---
.error_prepare_view:
    mov rdi, [db_handle]
    call print_sqlite_error
    mov rax, -1                ; Return -1 for error
    jmp .exit_view

.error_step_view:
    mov rdi, [db_handle]
    call print_sqlite_error
    ; Finalize statement on error
    mov rdi, [stmt_handle]
    call sqlite3_finalize
    mov rax, -1                ; Return -1 for error
    jmp .exit_view
    
.exit_view:
    add rsp, 32        ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; Helper function to print integer
print_int_simple:
    push rbp
    mov rbp, rsp
    and rsp, -16        ; Align stack to 16 bytes
    sub rsp, 32         ; Allocate 32 bytes for local variables (21 for string, 11 padding for alignment)
                        ; (rsp initially 16-aligned, push rbp makes it 8-aligned, and rsp, -16 makes it 16-aligned again)

    mov rax, rdi        ; Integer to print (argument in RDI)
    mov rbx, 10         ; Divisor
    
    ; Buffer for string conversion on stack: at [rsp+0]
    ; Max 64-bit int is 19 digits. Plus null terminator, needs 20 bytes.
    ; Let's use 21 bytes for safety.
    ; [rsp + 20] will be the null terminator initially, then adjusted.
    lea r9, [rsp+20]    ; Pointer to the end of the buffer (rsp+20), last byte in buffer
    mov byte [r9], 0    ; Null terminate the string end
    dec r9              ; Move pointer to the last digit position (rsp+19)

    cmp rax, 0
    je .print_zero

.convert_loop:
    xor rdx, rdx        ; Clear RDX for division
    div rbx             ; RAX = RAX / RBX, RDX = RAX % RBX
    add dl, '0'         ; Convert digit to ASCII
    mov [r9], dl        ; Store digit in buffer
    dec r9              ; Move to next position in buffer
    test rax, rax       ; Check if quotient is zero
    jnz .convert_loop

    inc r9              ; Adjust pointer to the beginning of the string

.print:
    mov rdi, r9         ; RDI points to the start of the string
    call printf         ; Print the string
    
    jmp .exit_print_int

.print_zero:
    lea rdi, [rsp]      ; Point to the start of the buffer for "0"
    mov byte [rdi], '0'
    mov byte [rdi+1], 0
    call printf

.exit_print_int:
    add rsp, 32         ; Restore stack
    mov rsp, rbp
    pop rbp
    ret

; Dummy functions for other operations
create_post_record:
    mov rdi, msg_not_implemented
    call printf
    xor rax, rax
    ret

create_follow_relationship:
    mov rdi, msg_not_implemented
    call printf
    xor rax, rax
    ret

like_post_record:
    mov rdi, msg_not_implemented
    call printf
    xor rax, rax
    ret

add_comment_record:
    mov rdi, msg_not_implemented
    call printf
    xor rax, rax
    ret

view_user_statistics:
    mov rdi, msg_not_implemented
    call printf
    xor rax, rax
    ret

delete_user_record:
    mov rdi, msg_not_implemented
    call printf
    xor rax, rax
    ret

    update_user_profile:
        mov rdi, msg_not_implemented
        call printf
        xor rax, rax
        ret

    ; Helper function to print SQLite errors
    ; Arg: rdi = db_handle (sqlite3*)
    print_sqlite_error:
        push rbp
        mov rbp, rsp
        and rsp, -16       ; Align stack
        sub rsp, 32        ; Allocate local space for printf args
    
        mov rbx, rdi       ; Save db_handle to rbx
    
        ; Get error code
        mov rdi, rbx       ; db_handle for sqlite3_errcode
        call sqlite3_errcode
        mov r10, rax       ; Save error code in r10 (will be RSI for printf)
    
        ; Get error message
        mov rdi, rbx       ; db_handle for sqlite3_errmsg
        call sqlite3_errmsg
        mov rdx, rax       ; error message string (will be RDX for printf)
    
        ; Prepare for printf: "SQLite Error [%d]: %s\n"
        mov rdi, sqlite_error_format ; 1st arg for printf (format string)
        mov rsi, r10       ; 2nd arg for printf (error code)
        ; RDX already has the string message
        xor rax, rax       ; No floating point arguments
        call printf
    
        add rsp, 32        ; Restore stack
        mov rsp, rbp
        pop rbp
        ret