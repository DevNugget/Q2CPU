# Q2CPU - The 2-bit CPU Emulator
A 2-bit experimental CPU emulator. This project was made using the Godot Game Engine.
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3d2ee381-a4b1-4ea3-80b7-7bae399eb640" />



## Hardware Specifications
The Q2CPU operates on a strict 2-bit foundation, meaning data values are clamped between `0` and `3` (`0b00` to `0b11`).

### Registers
* **`A` (Accumulator):** The primary 2-bit workhorse register for all math and memory addressing.
* **`PC` (Program Counter):** An 8-bit register tracking the current instruction address.
* **`MODE` (State Register):** A 2-bit register determining how the CPU decodes the current opcode.
* **`LIO` (Last I/O):** A 2-bit register holding the last value read from or written to an external device.

### Memory Map
System uses a 256-word memory space (`MEM_SIZE = 256`)
* **Instruction Constraint:** Every memory address strictly holds a 2-bit opcode.
* **Addressing Bottleneck:** Because the Accumulator (`A`) is used as the pointer for memory lookups (`MEMORY[A]`), the CPU can natively read or write only to the first four memory addresses (`0x00` to `0x03`).

## Instruction Set Architecture (ISA)

Because opcodes are strictly 2-bit, the CPU can only define 4 instructions at a time. To bypass this, Q2CPU uses a **Mode-Shift**. The `MODE` register cycles between 4 execution states, resulting in a total of 16 operations. Opcode `3` in every mode acts as the mode-switcher.

### Mode 0: Arithmetic Mode

| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0` | `INC` | `A = (A + 1) & 3` | Increments the accumulator. |
| `1` | `DEC` | `A = (A - 1) & 3` | Decrements the accumulator. |
| `2` | `XOR` | `A = (A ^ MEMORY[A]) & 3` | Bitwise XORs `A` with the memory value at address `A`. |
| `3` | `NEXT` | `MODE = 1` | Shifts to Memory Mode. |

### Mode 1: Memory Mode

| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0` | `LOAD` | `A = MEMORY[A] & 3` | Loads data from memory address `A` into `A`. |
| `1` | `STORE` | `MEMORY[A] = A & 3` | Stores the value of `A` into memory address `A`. |
| `2` | `INC_MEM` | `MEMORY[A]++` | Increments the value stored at memory address `A`. |
| `3` | `NEXT_MEM` | `MODE = 2` | Shifts to Control Mode. |

### Mode 2: Control Mode

| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0` | `SKIP0` | `if A == 0: PC++` | Skips the next instruction if `A` is 0. |
| `1` | `JUMP` | `PC = MEMORY[A]` | Jumps to the address stored in memory at address `A`. |
| `2` | `PC2A` | `A = PC & 3` | Loads the lower 2 bits of the Program Counter into `A`. |
| `3` | `NEXT_CTRL` | `MODE = 3` | Shifts to I/O Mode. |

### Mode 3: I/O Mode

| Opcode | Mnemonic | Operation | Description |
| :--- | :--- | :--- | :--- |
| `0` | `OUT` | `write(MEM[A], A)` | Writes the value of `A` to the device mapped at port `MEMORY[A]`. |
| `1` | `IN` | `A = read(MEM[A])` | Reads from the device mapped at port `MEMORY[A]` into `A`. |
| `2` | `READ_OUT` | `A = LIO & 3` | Loads the Last I/O value into the accumulator. |
| `3` | `NEXT_IO` | `MODE = 0` | Shifts back to Arithmetic Mode. |

## I/O and Peripheral Devices

The Q2CPU supports up to 4 mapped ports (`0` to `3`).

### Halting

Number of instructions are limited, so there is no dedicated `HALT` instruction. Instead, the CPU uses an **Unmapped Port Trap**.  

If the `OUT` instruction attempts to write to a port address that does not have a registered device, the CPU halts its execution loop.

### OutPort Character Buffer (Port 0)

The standard output device is the `OutPort`, attached to Port 0.

Because a 2-bit bus cannot natively send ASCII characters, the `OutPort` acts as a data buffer. It accumulates four consecutive 2-bit writes into an array.

Once the buffer is full, it performs bitwise shifts to assemble the four 2-bit chunks into a single 8-bit byte.
The assembled byte is then parsed as an ASCII character and printed to the Godot Label.
