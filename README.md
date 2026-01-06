# 🚀 Assembly-SQLite Social Network Project

A professional-grade demonstration connecting x86-64 Assembly with SQLite database operations inside Docker containers. This project showcases low-level programming with high-level database operations.

## 📋 Prerequisites

### Option 1: Using Docker (Recommended)
- **Docker Engine** 20.10+
- **Docker Compose** 2.0+
- **Git** (for cloning)

### Option 2: Manual Installation
- **NASM** (Netwide Assembler) 2.15+
- **GCC** (GNU Compiler Collection) 9.0+
- **SQLite3** 3.35+ with development libraries
- **Make** 4.0+
- **Bash** shell

## 🐳 Quick Start with Docker

### 1. Clone and Setup
```bash
# Clone the project
git clone https://github.com/CodeWithBotinaOficial/assembly-sqlite-social.git
cd assembly-sqlite-social

# Make scripts executable
chmod +x scripts/*.sh
chmod +x docker/entrypoint.sh

# Start the environment
docker-compose up -d
```

### 2. Enter Development Container
```bash
# Access the Assembly development environment
docker-compose exec assembly-dev bash

# Inside the container, build and run
make clean
make all
make run
```

### 3. Verify Services
```bash
# Check container status
docker-compose ps

# View database logs
docker-compose logs -f database

# Test database connection
docker-compose exec database sqlite3 /data/social_network.db ".tables"
```

## ⚙️ Manual Build (Without Docker)

### 1. Install Dependencies
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y nasm gcc gdb make sqlite3 libsqlite3-dev

# macOS with Homebrew
brew install nasm gcc sqlite3

# Fedora/RHEL
sudo dnf install nasm gcc gdb make sqlite3 sqlite3-devel
```

### 2. Build the Project
```bash
# Option A: Using the build script
./scripts/build.sh

# Option B: Manual build steps
mkdir -p obj bin lib data
make clean
make all
make init-db
```

### 3. Run the Application
```bash
# Run the Assembly program
./scripts/run.sh

# Or directly
cd bin && ./social_network
```

## 📁 Project Structure
```
assembly-sqlite-social/
├── docker/                    # Docker configuration
│   ├── Dockerfile.asm        # Assembly dev environment
│   ├── Dockerfile.db         # SQLite database
│   └── entrypoint.sh         # Database initialization
├── docker-compose.yml        # Service orchestration
├── Makefile                  # Build automation
├── database/                 # Database schemas and data
│   ├── schema.sql           # Main database schema
│   └── seed_data.sql        # Sample data
├── src/                      # Assembly source code
│   ├── main.asm             # Main program
│   ├── database.asm         # SQLite interactions
│   └── utils.asm            # Utility functions
├── include/                  # Header files
├── lib/                      # SQLite libraries
├── scripts/                  # Build and run scripts
├── data/                     # Database files (auto-created)
└── bin/                      # Compiled executables
```

## 🛠️ Available Commands

### Docker Commands
```bash
# Start all services in background
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes (deletes data)
docker-compose down -v

# View logs
docker-compose logs -f
docker-compose logs database
docker-compose logs assembly-dev

# Rebuild containers
docker-compose build --no-cache

# Enter development container
docker-compose exec assembly-dev bash
```

### Make Commands (inside container or host)
```bash
make           # Build everything
make clean     # Clean build artifacts
make init-db   # Initialize/Reset database
make run       # Build and run application
make test      # Run tests
make debug     # Build with debug symbols
```

### Script Commands
```bash
./scripts/build.sh    # Full build process
./scripts/run.sh      # Build and run
./scripts/test.sh     # Run test suite
./scripts/test-db.sh  # Test database connectivity
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. "docker: invalid reference format" Error
**Problem**: Path contains uppercase characters or spaces
```bash
# Solution: Use a different directory or rename
mv "Development environment" development
cd development/Assembly/Terminal/assembly-sqlite-social
```

#### 2. Database Container Fails to Start
**Problem**: Health check fails
```bash
# Recreate the database volume
docker-compose down -v
docker-compose up -d database

# Check database initialization
docker-compose logs database --tail=50

# Manually test the database
docker-compose exec database sh
# Inside container:
sqlite3 /data/social_network.db "SELECT 1;"
```

#### 3. "no such function: LEAST" Error
**Problem**: SQLite doesn't have LEAST/GREATEST functions
**Solution**: Update your `database/schema.sql`:
```sql
-- Replace line 127 (in the index creation) with:
CREATE INDEX idx_messages_conversation ON messages(
    CASE WHEN sender_id < receiver_id THEN sender_id ELSE receiver_id END,
    CASE WHEN sender_id > receiver_id THEN sender_id ELSE receiver_id END,
    created_at
);
```

#### 4. "non-deterministic use of date()" Error
**Problem**: SQLite doesn't allow date() in CHECK constraints
**Solution**: Update the users table constraint:
```sql
-- Replace the CHECK constraint (remove or modify)
-- Remove this line:
-- CONSTRAINT chk_age CHECK (date_of_birth <= DATE('now', '-13 years'))

-- Add a trigger instead:
CREATE TRIGGER validate_age_before_insert
BEFORE INSERT ON users
FOR EACH ROW
WHEN NEW.date_of_birth > DATE('now', '-13 years')
BEGIN
    SELECT RAISE(ABORT, 'User must be at least 13 years old');
END;
```

#### 5. "No rule to make target 'obj/main.o'"
**Problem**: Missing source files or incorrect paths
```bash
# Solution: Check your source files
ls -la src/

# Ensure all required files exist
# If missing, create them:
touch src/main.asm src/database.asm src/utils.asm
touch include/constants.inc include/sqlite_functions.inc
```

#### 6. Permission Denied on Scripts
```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x docker/entrypoint.sh
```

#### 7. SQLite Library Extraction Issue
```bash
# Manual library extraction
docker run --rm -v $(pwd)/lib:/opt/out keinos/sqlite3:latest sh -c "find /usr -name 'libsqlite3.*' -exec cp {} /opt/out/ \; 2>/dev/null"
```

## 🗂️ Database Operations

The Assembly program provides a menu-driven interface for:

1. **User Management**
   - Create new users
   - Update profiles
   - Delete users
   - View statistics

2. **Social Features**
   - Create posts (text, image, video, link)
   - Follow/unfollow users
   - Like posts and comments
   - Add comments

3. **Data Operations**
   - CRUD operations via SQLite
   - Transaction support
   - Error handling

## 📊 Sample Queries from Assembly

The program executes these SQL operations:

```sql
-- Create user
INSERT INTO users (username, email, full_name) VALUES (?, ?, ?);

-- Create post
INSERT INTO posts (user_id, content, post_type) VALUES (?, ?, ?);

-- Follow user
INSERT INTO followers (follower_id, following_id) VALUES (?, ?);

-- Get user statistics
SELECT username, total_posts, follower_count FROM user_statistics;
```

## 🔍 Debugging Tips

### Debug Assembly Program
```bash
# Inside the container
cd /workspace
make debug
gdb bin/social_network

# Common GDB commands
break main
run
stepi
info registers
x/10i $pc
```

### Test Database Separately
```bash
# Connect to database
docker-compose exec database sqlite3 /data/social_network.db

# SQLite commands
.tables
.schema users
SELECT * FROM users LIMIT 5;
.headers on
.mode column
```

### Check Build Process
```bash
# Verbose build
make V=1

# Check individual steps
nasm -f elf64 -g -F dwarf src/main.asm -o obj/main.o -Iinclude/
ld -m elf_x86_64 -o bin/social_network obj/main.o obj/database.o obj/utils.o -lc -lsqlite3 -dynamic-linker /lib64/ld-linux-x86-64.so.2
```

## 🚀 Performance Tips

1. **Use Prepared Statements**: The Assembly code uses `sqlite3_prepare_v2` for efficient query execution.

2. **Enable WAL Mode**: The schema enables Write-Ahead Logging for better concurrency.

3. **Proper Indexing**: All foreign keys and search columns are indexed.

4. **Connection Pooling**: Single database connection reused throughout the program.

## 📝 Notes for Class Presentation

### Impressive Features to Demo:
1. **Low-Level Meets High-Level**: Show Assembly calling SQLite C API
2. **Containerized Environment**: Docker setup ensures reproducibility
3. **Professional Schema**: Normalized database with indexes and constraints
4. **Full CRUD Operations**: From Assembly language!

### Quick Demo Script:
```bash
# Start fresh
docker-compose down -v
docker-compose up -d

# Show containers running
docker-compose ps

# Enter container and run
docker-compose exec assembly-dev make run

# Show database contents
docker-compose exec database sqlite3 /data/social_network.db "SELECT * FROM users;"
```

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Examine logs: `docker-compose logs --tail=100`
3. Verify file permissions and paths
4. Ensure all dependencies are installed

## 📄 License

This project is for educational purposes. Feel free to modify and extend for your class presentation.