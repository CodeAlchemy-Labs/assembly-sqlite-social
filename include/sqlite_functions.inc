; sqlite_functions.inc - SQLite function prototypes

; SQLite C API functions
extern sqlite3_open
extern sqlite3_close
extern sqlite3_exec
extern sqlite3_prepare_v2
extern sqlite3_step
extern sqlite3_finalize
extern sqlite3_errmsg
extern sqlite3_bind_text
extern sqlite3_bind_int
extern sqlite3_column_text
extern sqlite3_column_int
extern sqlite3_column_count
extern sqlite3_changes

; Standard C functions
extern printf
extern scanf
extern fgets
extern stdin
extern malloc
extern free
extern strlen
extern atoi
extern sprintf