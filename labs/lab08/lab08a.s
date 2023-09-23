.text
.globl _start


_start:
    j main


exit:
    li a7, 93               # syscall exit (93)
    ecall


open_file:
    # a0 = address for the file path
    li a1, 0        # a1 = flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0        # a2 = mode
    li a7, 1024     # a7 = syscall open (1024)
    ecall
    ret


read_file:
    # a0 = file descriptor
    # a1 = buffer to write the data
    # a2 = size (reads only 10 bytes)
    li a7, 63       # syscall read (63)
    ecall
    ret


write:
    # a1 = buffer
    # a2 = size
    li a0, 1        # a0 = file descriptor = 1 (stdout)
    li a7, 64       # a7 = syscall write (64)
    ecall
    ret


close_file:
    # a0 = address for the file path
    li a7, 57       # syscall close (57)
    ecall
    ret


main:
    # --- Abrindo o arquivo input_file ("feep.pgm") --- #
    # Parâmetro de "open_file":
    la a0, input_file   # a0 = address for the file path
    jal open_file

    mv s0, a0       # Armazena o descritor de arquivo de "file_input" em s0
    
    # --- Lendo a string "header" --- #
    # Parâmetros de "read_file":
                    # a0 = file descriptor
    la a1, header   # a1 = buffer to write the data
    li a2, 15       # a2 = size (reads only a2 bytes)
    jal read_file

    mv s1, a0       # Armazena o endereço de "header" em s0

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# PAREI AQUI
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # --- Escrevendo no terminal do simulador --- #
    # Parâmetros de "write":
    la a1, header   # a1 = buffer
    li a2, 16       # a2 = size
    jal write

    # --- Fechando o arquivo input_file ("feep.pgm") --- #
    # Parâmetros de "close_file":    
    mv a0, s0       # a0 = address for the file path
    jal close_file
    
    j exit


.data
input_file: .string "feep.pgm"

header: .string "P2*www*hhh*mmm*\n"

# width: .string "000\n"  # max width = 512
# height: .string "000\n" # max height = 512
# maxval: .string "000\n" # max maxval = 255