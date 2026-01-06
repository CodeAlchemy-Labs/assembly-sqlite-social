; constants.inc - Assembly constants and definitions

; System call numbers for x86_64 Linux
SYS_WRITE   equ 1
SYS_READ    equ 0
SYS_EXIT    equ 60
STDOUT      equ 1
STDIN       equ 0

; SQLite return codes
SQLITE_OK   equ 0
SQLITE_ROW  equ 100
SQLITE_DONE equ 101

; Database path (relative path in container)
DB_PATH     db "/data/social_network.db", 0

; Buffer sizes
BUFFER_SIZE equ 256
MAX_INPUT   equ 255

; Menu options
OPTION_CREATE_USER   equ 1
OPTION_CREATE_POST   equ 2
OPTION_FOLLOW_USER   equ 3
OPTION_LIKE_POST     equ 4
OPTION_ADD_COMMENT   equ 5
OPTION_VIEW_STATS    equ 6
OPTION_DELETE_USER   equ 7
OPTION_UPDATE_USER   equ 8
OPTION_EXIT          equ 9