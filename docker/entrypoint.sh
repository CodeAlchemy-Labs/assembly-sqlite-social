#!/bin/sh
set -e

DB_PATH="/data/social_network.db"
INIT_DIR="/docker-entrypoint-initdb.d"

echo "=== SQLite Database Initialization ==="

# Create database directory if it doesn't exist
mkdir -p /data

# Initialize database if it doesn't exist
if [ ! -f "$DB_PATH" ]; then
    echo "Creating new database at $DB_PATH..."
    
    # Create empty database file
    sqlite3 "$DB_PATH" "VACUUM;"
    
    # Run initialization scripts if any
    if [ -d "$INIT_DIR" ] && [ "$(ls -A $INIT_DIR/*.sql 2>/dev/null)" ]; then
        echo "Running initialization scripts..."
        for script in $INIT_DIR/*.sql; do
            echo "Executing: $script"
            sqlite3 "$DB_PATH" < "$script"
        done
    else
        echo "No initialization scripts found. Creating default schema..."
        sqlite3 "$DB_PATH" "
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY,
                username TEXT UNIQUE NOT NULL
            );
            INSERT OR IGNORE INTO users (username) VALUES ('admin');
        "
    fi
    
    echo "Database initialized successfully!"
else
    echo "Database already exists at $DB_PATH"
fi

# Set proper permissions
chmod 666 "$DB_PATH" 2>/dev/null || true

echo "Database ready at: $DB_PATH"
echo "Size: $(du -h "$DB_PATH" | cut -f1)"

# Start a simple HTTP server or keep-alive process
echo "=== Database Service Running ==="
exec tail -f /dev/null