FROM ubuntu:22.04

# Install essential tools
RUN apt-get update && apt-get install -y \
    nasm \
    gcc \
    gdb \
    make \
    libsqlite3-dev \
    sqlite3 \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace

# Set environment variables
ENV ASM_FLAGS="-f elf64"
ENV LD_FLAGS="-m elf_x86_64 -lc -lsqlite3"

# Default command
CMD ["/bin/bash"]