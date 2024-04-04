ASM=nasm
ASM_FLAGS=-f obj

CC16=/usr/bin/watcom/binl/wcc
CFLAGS16=-s -wx -ms -zl -zq
LD16=/usr/bin/watcom/binl/wlink

SRC_DIR=src
BUILD_DIR=build

all: clean always floppy_image bootloader kernel

#
# Floppy Image (FAT12)
# 
floppy_image: $(BUILD_DIR)/main.img
$(BUILD_DIR)/main.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "OS" $(BUILD_DIR)/main.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	 
#
# Bootloader
#
bootloader: $(BUILD_DIR)/bootloader.bin
$(BUILD_DIR)/bootloader.bin:
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin:
	$(ASM) $(ASM_FLAGS) -o $(BUILD_DIR)/kernel/asm/main.obj $(SRC_DIR)/kernel/main.asm
	$(ASM) $(ASM_FLAGS) -o $(BUILD_DIR)/kernel/asm/print.obj $(SRC_DIR)/kernel/print.asm
	$(ASM) $(ASM_FLAGS) -o $(BUILD_DIR)/kernel/asm/math.obj $(SRC_DIR)/kernel/math.asm
	$(CC16) $(CFLAGS16) -fo=$(BUILD_DIR)/kernel/c/main.obj $(SRC_DIR)/kernel/main.c
	$(CC16) $(CFLAGS16) -fo=$(BUILD_DIR)/kernel/c/stdio.obj $(SRC_DIR)/kernel/stdio.c
	$(LD16) name $(BUILD_DIR)/kernel.bin FILE \{$(BUILD_DIR)/kernel/asm/main.obj $(BUILD_DIR)/kernel/asm/print.obj $(BUILD_DIR)/kernel/c/main.obj $(BUILD_DIR)/kernel/c/stdio.obj $(BUILD_DIR)/kernel/asm/math.obj \} OPTION MAP=$(BUILD_DIR)/kernel.map @$(SRC_DIR)/kernel/linker.lnk


always:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/kernel
	mkdir -p $(BUILD_DIR)/kernel/asm
	mkdir -p $(BUILD_DIR)/kernel/c

#
# Running OS
#
boot:
	qemu-system-i386 -fda $(BUILD_DIR)/main.img

debug:
	qemu-system-i386 -boot c -m 256 -hda $(BUILD_DIR)/main.img -s -S

clean:
	rm -rf $(BUILD_DIR)/*
