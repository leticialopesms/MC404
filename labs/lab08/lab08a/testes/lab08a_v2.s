.text
.globl _start


_start:
    j main


exit:
    li a7, 93       # syscall exit (93)
    ecall


setPixel:
    li a0, 100          # a0: pixel's x coordinate
    li a1, 200          # a1: pixel's y coordinate
    li a2, 0xFFFFFFFF   # a2: concatenated pixel's colors: R|G|B|A
    li a7, 2200         # a7: 2200 (syscall number)
    ecall
    ret


setCanvasSize:
    li a0, 32       # a0: canvas width (value between 0 and 512)
    li a1, 32       # a1: canvas height (value between 0 and 512)
    li a7, 2201     # a7: 2201 (syscall number)
    ecall
    ret


setScaling:
    li a0, 1        # a0: horizontal scaling
    li a1, 1        # a1: vertical scaling
    li a7, 2202     # a7: 2202 (syscall number)
    ecall
    ret


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


get_width:
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    # Atualizando ponteiros
    addi t1, t1, 1
    addi t2, t2, 1
    # Verificando condição de retorno
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    li a1, 32
    bne a0, a1, get_width
    # Instrução após o LOOP
    li a0, '\n'
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    addi t1, t1, 1
    ret


get_height:
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    # Atualizando ponteiros
    addi t1, t1, 1
    addi t2, t2, 1
    # Verificando condição de retorno
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    li a1, 32
    bne a0, a1, get_height
    # Instrução após o LOOP
    li a0, '\n'
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    addi t1, t1, 1
    ret


get_maxval:
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    # Atualizando ponteiros
    addi t1, t1, 1
    addi t2, t2, 1
    # Verificando condição de retorno
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    li a1, 10
    bne a0, a1, get_maxval
    # Instrução após o LOOP
    li a0, '\n'
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    addi t1, t1, 1
    ret


get_pixel:
    check:
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        addi t1, t1, 1  # Atualizando ponteiro t1
        # Verificando condição de retorno
        li a1, 32
        beq a0, a1, check
        li a1, 10
        beq a0, a1, check
    
    addi t1, t1, -1
    LOOP_pixel:
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
        addi t1, t1, 1  # Atualizando ponteiro t1
        addi t2, t2, 1  # Atualizando ponteiro t2
        # Verificando condição de retorno
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        li a1, 32
        beq a0, a1, end_get_pixel
        li a1, 10
        beq a0, a1, end_get_pixel
        j LOOP_pixel

    # Instrução após o LOOP
    end_get_pixel:
        li a0, '\n'
        sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
        ret


to_int:
    # Convertendo para inteiro:
    li a7, 1        # a7 = fator de multiplicação
    li a0, 0        # a0 = valor do retorno de to_int
    addi t2, t2, -1 # Agora t2 não aponta mais para "\n"
    LOOP_to_int:
        # --- Converte de char para inteiro --- #
        lb a1, 0(t2)        # Adiciona 4 bytes (da posição t2 + 0 da memória) no registrador a1
        addi a1, a1, -48    # Converte o valor em a1 de char para int
        mul a1, a1, a7      # Aplica o fator de multiplicação
        add a0, a0, a1      # Soma a0 (valor inicial) com a1 (valor atual multiplicado pelo seu fator)
                            # Armazena em a0

        # --- Atualiza o fator de multiplicação --- #
        li s10, 10
        mul a7, a7, s10         # Atualiza o fator de multiplicação (multiplica a1 por 10)

        # --- Atualiza o ponteiro --- #
        addi t2, t2, -1         # Remove 1 do iterador t2
                                # Move o ponteiro t2 de "numero" para a esquerda
       
        # --- Verificando condição de retorno --- #
        bge t2, s2, LOOP_to_int

    # --- Instrução após o LOOP --- #
    # Agora t2 = s2
    ret


main:
    jal setCanvasSize
    # -------------------------------------- #
    # --- Abrindo o arquivo "input_file" --- #
    # -------------------------------------- #
    # Parâmetro de "open_file":
    la a0, input_file   # a0 = address for the file path
    jal open_file

    mv s0, a0       # Armazena o descritor de arquivo de "input_file" em s0
    
    # ------------------------------- #
    # --- Lendo a string "file" --- #
    # ------------------------------- #
    # Parâmetros de "read_file":
                    # a0 = file descriptor
    la a1, file   # a1 = buffer to write the data
    li a2, 0x4000 # a2 = size (reads only 0x4000 bytes)
    jal read_file

    # mv s1, a0       # Armazena o endereço de "file" em s1 !!!! ERRADO !!!
    la s1, file   # Armazena o endereço de "file" em s1
    mv t1, s1       # t1 = ponteiro para "file"

    # --------------------------------- #
    # --- Armazenando w, h e maxval --- #
    # --------------------------------- #
    # Linha 1: "P2\n" ou "P5\n"
    addi t1, t1, 3  # t1 aponta para o primeiro algarismo de w
    
    # Linha 2:

    # w
    la s2, width    # s2 = posição de memória de "width"
    mv t2, s2       # t2 = ponteiro para "width"
    jal get_width   # Armazena a largura na string "width"
    jal to_int      # Converte de string para int
    mv s3, a0       # s3 = width

    # # --- Escrevendo no terminal do simulador --- #
    # # Parâmetros de "write":
    # la a1, width    # a1 = buffer
    # sub a2, t2, s2  # a2 = size
    # jal write

    # h
    la s2, height   # s2 = posição de memória de "height"
    mv t2, s2       # t2 = ponteiro para "width"
    jal get_height  # Armazena a altura na string "height"
    jal to_int      # Converte de string para int
    mv s4, a0       # s4 = height

    # # --- Escrevendo no terminal do simulador --- #
    # # Parâmetros de "write":
    # la a1, height   # a1 = buffer
    # sub a2, t2, s2  # a2 = size
    # jal write

    # Linha 3:

    # maxval
    la s2, maxval   # s2 = posição de memória de "maxval"
    mv t2, s2       # t2 = ponteiro para "maxval"
    jal get_maxval  # Armazena a altura na string "maxval"
    jal to_int      # Converte de string para int
    mv s5, a0       # s5 = maxval

    # # --- Escrevendo no terminal do simulador --- #
    # # Parâmetros de "write":
    # la a1, maxval   # a1 = buffer
    # sub a2, t2, s2  # a2 = size
    # jal write

    # t1 - s1 = tamanho do cabeçalho
    # t1 = primeiro pixel da figura

    # ------------------------------------- #
    # --- Imprimindo a figura no canvas --- #
    # ------------------------------------- #

    mv t4, s4   # t4 = contador para y (height)
    li s7, 0    # s7 = y_inicial
    LOOP_print:
        mv t3, s3   # t3 = contador para x (width)
        li s6, 0    # s6 = x_inicial
        LOOP_linha:
            la s2, pixel    # s2 = posição de memória de "pixel"
            mv t2, s2       # t2 = ponteiro para "pixel"
            jal get_pixel
            jal to_int
            mv a2, a0           # a2 = color
    
            li a7, 255
            mul a2, a2, a7      # a2 = 255*pixel
            div a2, a2, s5      # a2 = 255*pixel/maxval
            sub a2, a7, a2
    
            mv a0, s6           # a0 = x
            mv a1, s7           # a1 = y
            li a7, 2200         # syscall setPixel (2200)
            ecall
        
            # Atualiza x
            addi s6, s6, 1
            # Atualiza t3
            addi t3, t3, -1
            bne t3, zero, LOOP_linha

        # Atualiza y
        addi s7, s7, 1
        # Atualiza t4
        addi t4, t4, -1
        # Verifica condição de retorno
        bne t4, zero, LOOP_print


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# PAREI AQUI
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


    # # --- Escrevendo no terminal do simulador --- #
    # # Parâmetros de "write":
    # la a1, file   # a1 = buffer
    # li a2, 16       # a2 = size
    # jal write

    # --------------------------------------- #
    # --- Fechando o arquivo "input_file" --- #
    # --------------------------------------- #
    # Parâmetros de "close_file":    
    mv a0, s0       # a0 = address for the file path
    jal close_file

    # ------------------------------------ #
    # --- Chamando a saída do programa --- #
    # ------------------------------------ #
    j exit


.data

.align 2
input_file: .string "feep1.pgm"
# input_file: .string "image.pgm"

.align 2
# file: .string "P2*www*hhh*mmm*\n"
file: .skip 0x4000

.align 2
width: .string "000*"   # w = x
                        # max width = 512
.align 2
height: .string "000*"  # h = y
                        # max height = 512
.align 2
maxval: .string "000*"  # max maxval = 255

.align 2
pixel: .string "000"    # max pixel = 255

# REGISTRADORES
    # s0 = descritor de arquivo para "input_file"
    # s1 = endereço de "file"
    # s2 = posições de w ou h ou maxval
    # s3 = width (inteiro)
    # s4 = height (inteiro)
    # s5 = maxval (inteiro)
    # t1 = ponteiro para "file"
    # t2 = ponteiro para w ou h ou maxval
    # a7 = syscalls ou auxiliar de div ou mul