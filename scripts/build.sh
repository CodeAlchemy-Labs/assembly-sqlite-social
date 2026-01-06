#!/bin/bash

# Build script for Assembly-SQLite project

echo "Building Assembly-SQLite Social Network Project..."
echo "=================================================="

# Check dependencies
echo "Checking dependencies..."
which nasm > /dev/null || { echo "NASM not found. Installing..."; sudo apt-get install nasm; }
which gcc > /dev/null || { echo "GCC not found. Installing..."; sudo apt-get install gcc; }
which sqlite3 > /dev/null || { echo "SQLite3 not found. Installing..."; sudo apt-get install sqlite3 libsqlite3-dev; }

# Create directories
mkdir -p obj bin lib data

# Extract SQLite library from Docker if needed
if [ ! -f "lib/libsqlite3.a" ]; then
    echo "Extracting SQLite library..."
    docker run --rm -v $(pwd)/lib:/opt/out keinos/sqlite3 sh -c "cp /usr/lib/libsqlite3.* /opt/out/ 2>/dev/null || cp /usr/local/lib/libsqlite3.* /opt/out/"
fi

# Build using Makefile
echo "Compiling Assembly code..."
make clean
make all

# Initialize database
echo "Initializing database..."
make init-db

echo "Build complete! Executable: bin/social_network"