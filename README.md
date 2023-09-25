# Spiral

```
❯ ./spiral 10 1
# # # # # # # # # #
                  #
# # # # # # # #   #
#             #   #
#   # # # #   #   #
#   #     #   #   #
#   #         #   #
#   # # # # # #   #
#                 #
# # # # # # # # # #
```

## Build

```bash
nasm -f elf64 spiral.asm -o spiral.o && ld -s spiral.o -o spiral
```

### Build with reduced size

```bash
nasm -f elf64 spiral.asm -o spiral.o && ld --nmagic -s spiral.o -o spiral
```

### Build with debugging

```bash
nasm -f elf64 -F stabs spiral.asm -o spiral.o && ld spiral.o -o spiral
```
