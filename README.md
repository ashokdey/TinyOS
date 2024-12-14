## Hacking the OS

### Phase I 

### Bootloader and Kernel Initialization

This repository demonstrates the sequence of bootloader and kernel setup for a basic operating system using BIOS:

1. **Stage 1 Bootloader**:
   - Loaded by the BIOS to `0x7C00`.
   - Initializes the CPU in real mode, sets up a stack, and loads the Stage 2 bootloader or kernel from disk using BIOS interrupts.

2. **Stage 2 Bootloader**:
   - Handles advanced initialization, loads the kernel into memory, and switches to protected or long mode (for 64-bit systems).

3. **Kernel Execution**:
   - Starts at the kernel’s entry point, initializes system resources, and begins execution.

#### Tools
- **Assembler**: NASM or similar.
- **Testing**: QEMU or Bochs for emulation.
- **Disk Imaging**: Use `dd` to write bootloader to a disk image.

--- 

### Instructions 

- Run the `build.sh` to create the bootimage 
- Install QEMU in Ubuntu 
- Head to the repo `machine`
- Execute the boot image via QEMU using `qemu-system-x86_64 -drive format=raw,file=boot.img -cpu qemu64,pdpe1gb` 