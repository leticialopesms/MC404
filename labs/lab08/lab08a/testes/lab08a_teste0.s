.text
.globl _start

_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


setPixel:
    li a0, 1          # x coordinate = 100
    li a1, 1          # y coordinate = 200
    li a2, 0x00000000   # black pixel
    li a7, 2200         # syscall setPixel (2200)
    ecall
    ret


# open:
#     la a0, input_file   # address for the file path
#     li a1, 0            # flags (0: rdonly, 1: wronly, 2: rdwr)
#     li a2, 0            # mode
#     li a7, 1024         # syscall open
#     ecall
#     ret


main:
    # jal open
    # mv t0, a0   # Armazena o valor de "input_file" em t0

    jal setPixel
    jal exit

# .data
# input_file: .string "bird.pgm"
# input_file: .string "feep.pgm"

# OBS.: Maxval é no máximo 255
        # Logo, cada valor de "tom" armazena 1 byte