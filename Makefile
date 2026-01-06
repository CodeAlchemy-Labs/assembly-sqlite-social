ASM = nasm
ASM_FLAGS = -f elf64 -Iinclude/
CC = gcc
LD_FLAGS = -lsqlite3 -no-pie

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
TARGET = $(BIN_DIR)/social_network

OBJECTS = $(OBJ_DIR)/main.o $(OBJ_DIR)/utils.o $(OBJ_DIR)/database.o

all: directories $(TARGET)

directories:
	mkdir -p $(OBJ_DIR) $(BIN_DIR)

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^ $(LD_FLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(ASM) $(ASM_FLAGS) -o $@ $<

clean:
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/*

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run directories