# -----------------------------
# RTL8196E Bootloader Makefile
# -----------------------------

# Toolchain
CC      := mips-linux-gnu-gcc
LD      := mips-linux-gnu-ld
OBJCOPY := mips-linux-gnu-objcopy

# CPU / ISA flags
CFLAGS  := -march=mips1 -mabi=32 -EB -mfp32 -mno-abicalls \
           -Os -Wall -Wextra -ffreestanding -nostdlib -nostartfiles \
		   -mno-gpopt -Wl,-n -Wl,--build-id=none -ffreestanding -fno-builtin
LDFLAGS := --build-id=none --no-gc-sections 

# Include path
INCLUDES := -I src

# Directories
SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin

# Targets
TARGET_ELF      := $(BIN_DIR)/bootloader.elf
TARGET_BIN      := $(BIN_DIR)/bootloader.bin
TARGET_BIN_PAD  := $(BIN_DIR)/fw_2MB.bin
PAD_SIZE        := 2097152  # 2MB

# Linker script
LDSCRIPT := bootloader.ld

# Sources / Objects
C_SRCS   := $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS := $(wildcard $(SRC_DIR)/*.s)
OBJ      := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRCS)) \
            $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(ASM_SRCS))

# Default target
all: $(TARGET_BIN) $(TARGET_BIN_PAD)

# Create directories if missing
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Compile C files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Assemble .S files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Link ELF
$(TARGET_ELF): $(OBJ) | $(BIN_DIR)
	$(LD) $(LDFLAGS) -T $(LDSCRIPT) -o $@ $(OBJ)

# Generate raw binary
$(TARGET_BIN): $(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

# Generate 2MB padded binary
$(TARGET_BIN_PAD): $(TARGET_BIN)
	dd if=$(TARGET_BIN) of=$(TARGET_BIN_PAD) bs=1 count=$(shell stat -c%s $(TARGET_BIN)) conv=notrunc
	dd if=/dev/zero bs=1 count=$$(( $(PAD_SIZE) - $(shell stat -c%s $(TARGET_BIN)) )) >> $(TARGET_BIN_PAD)

# Clean build
clean:
	rm -rf $(OBJ_DIR)/* $(BIN_DIR)/*

.PHONY: all clean
