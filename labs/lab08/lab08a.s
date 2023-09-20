.text
.globl _start

_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


# setPixel:
#     li a0, 100          # x coordinate = 100
#     li a1, 200          # y coordinate = 200
#     li a2, 0xFFFFFFFF   # white pixel
#     li a7, 2200         # syscall setPixel (2200)
#     ecall


# open:
#     la a0, input_file   # address for the file path
#     li a1, 0            # flags (0: rdonly, 1: wronly, 2: rdwr)
#     li a2, 0            # mode
#     li a7, 1024         # syscall open
#     ecall


LOOP_print:
    # Inicializa o contador para y
    li t2, 100
    li a1, 1
    LOOP_linha:
        
        li a7, 2200         # syscall setPixel (2200)
        ecall

        addi a1, a1, 1
        # Atualiza t2
        addi t2, t2, -1
        bne t2, zero, LOOP_linha

    addi a0, a0, 1
    # Atualiza t1
    addi t1, t1, -1
    bne t1, zero, LOOP_print
    ret


main:
    # jal open
    # mv t0, a0   # Armazena o valor de "input_file" em t0

    # Inicializa o contador para x
    li t1, 100
    # Inicializa parâmetros de LOOP_print
    li a0, 1
    li a1, 1
    li a2, 0x000000FF
    jal LOOP_print
    jal exit

# .data
# input_file: .string "bird.pgm"
# input_file: .string "feep.pgm"

# OBS.: Maxval é no máximo 255
        # Logo, cada valor de "tom" armazena 1 byte