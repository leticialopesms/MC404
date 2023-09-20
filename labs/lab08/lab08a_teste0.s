.text
.globl _start

_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


setPixel:
    li a0, 100          # x coordinate = 100
    li a1, 200          # y coordinate = 200
    li a2, 0xFFFFFFFF   # white pixel
    li a7, 2200         # syscall setPixel (2200)
    ecall

open:
    la a0, input_file   # address for the file path
    li a1, 0            # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0            # mode
    li a7, 1024         # syscall open
    ecall


main:
    jal open

.data
input_file: .string "bird.pgm"