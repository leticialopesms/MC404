.text
.globl _start


_start:
    j main


exit:
    li a7, 93       # a7: syscall exit (93)
    ecall


setPixel:
    # a0: pixel's x coordinate
    # a1: pixel's y coordinate
    # a2: concatenated pixel's colors: R|G|B|A
        # 0x000000FF = black
        # 0xFFFFFFFF = white
    li a7, 2200     # a7: 2200 (syscall number)
    ecall
    ret


setCanvasSize:
    # a0: canvas width (value between 0 and 512)
    # a1: canvas height (value between 0 and 512)
    li a7, 2201     # a7: 2201 (syscall number)
    ecall
    ret


setScaling:
    # a0: horizontal scaling
    # a1: vertical scaling
    li a7, 2202     # a7: 2202 (syscall number)
    ecall
    ret


open_file:
    # a0: address for the file path
    li a1, 0        # a1 = flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0        # a2 = mode
    li a7, 1024     # a7 = syscall open (1024)
    ecall
    ret


read_file:
    # a0: file descriptor
    # a1: buffer to write the data
    # a2: size (reads only 10 bytes)
    li a7, 63       # a7: syscall read (63)
    ecall
    ret


write:
    # a1: buffer
    # a2: size
    li a0, 1        # a0: file descriptor = 1 (stdout)
    li a7, 64       # a7: syscall write (64)
    ecall
    ret


close_file:
    # a0: address for the file path
    li a7, 57       # a7: syscall close (57)
    ecall
    ret


get_val:
    addi t1, t1, -1
    check:
        addi t1, t1, 1  # Atualizando ponteiro t1
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        # Verificando condição de retorno
        li a1, 35
        beq a0, a1, move_pointer
        li a1, 32
        beq a0, a1, check
        li a1, 10
        beq a0, a1, check

    value:
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
        # Atualizando ponteiros
        addi t1, t1, 1
        addi t2, t2, 1
        # Verificando condição de retorno
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        li a1, 35
        beq a0, a1, end_get_val
        li a1, 32
        beq a0, a1, end_get_val
        li a1, 10
        beq a0, a1, end_get_val
        j value

    move_pointer:
        addi t1, t1, 1
        lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
        li a1, 10
        bne a0, a1, move_pointer
        j check

    # Instrução após o LOOP
    end_get_val:
        li a0, '\n'
        sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
        # addi t1, t1, 1
        ret


get_byte:
    lb a0, 0(t1)    # Adiciona 1 byte da posição de memória t1 + 0 em a0
    sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    addi t1, t1, 1  # Atualizando ponteiro t1
    addi t2, t2, 1  # Atualizando ponteiro t2
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
    # -------------------------------------- #
    # --- Abrindo o arquivo "input_file" --- #
    # -------------------------------------- #
    # Parâmetro de "open_file":
    la a0, input_file   # a0: address for the file path
    jal open_file

    mv s0, a0       # Armazena o descritor de arquivo de "input_file" em s0
    
    # ------------------------------- #
    # --- Lendo a string "file" --- #
    # ------------------------------- #
    # Parâmetros de "read_file":
                    # a0: file descriptor
    la a1, file     # a1: buffer to write the data
    li a2, 0x40000  # a2: size (reads only 0x40000 bytes)
    jal read_file

    la s1, file     # Armazena o endereço de "file" em s1
    mv t1, s1       # t1 = ponteiro para "file"

    # --------------------------------- #
    # --- Armazenando w, h e maxval --- #
    # --------------------------------- #
    addi t1, t1, 3  # t1 aponta para o primeiro algarismo de w

    # --- w --- #
    la s2, width    # s2 = posição de memória de "width"
    mv t2, s2       # t2 = ponteiro para "width"
    jal get_val     # Armazena a largura na string "width"
    sub a2, t2, s2  # a2 = size
    jal to_int      # Converte de string para int
    mv s3, a0       # s3 = width

    # --- Escrevendo no terminal do simulador --- #
    # Parâmetros de "write":
    la a1, width    # a1: buffer
    addi a2, a2, 1  # a2: size
    jal write

    # --- h --- #
    la s2, height   # s2 = posição de memória de "height"
    mv t2, s2       # t2 = ponteiro para "width"
    jal get_val     # Armazena a altura na string "height"
    sub a2, t2, s2  # a2 = size
    jal to_int      # Converte de string para int
    mv s4, a0       # s4 = height

    # --- Escrevendo no terminal do simulador --- #
    # Parâmetros de "write":
    la a1, height   # a1: buffer
    addi a2, a2, 1  # a2: size
    jal write

    # --- maxval --- #
    la s2, maxval   # s2 = posição de memória de "maxval"
    mv t2, s2       # t2 = ponteiro para "maxval"
    jal get_val     # Armazena a altura na string "maxval"
    sub a2, t2, s2  # a2 = size
    jal to_int      # Converte de string para int
    mv s5, a0       # s5 = maxval

    # --- Escrevendo no terminal do simulador --- #
    # Parâmetros de "write":
    la a1, maxval   # a1: buffer
    addi a2, a2, 1  # a2: size
    jal write

    addi t1, t1, 1
    # Agora:
    # t1 = primeiro pixel da figura
    # t1 - s1 = tamanho do cabeçalho

    # ----------------------------- #
    # --- Configurando o Canvas --- #
    # ----------------------------- #
    # Parâmetros de "setCanvasSize":
    mv a0, s3           # a0: canvas width (value between 0 and 512)
    mv a1, s4           # a1: canvas height (value between 0 and 512)
    jal setCanvasSize   # Habilitar essa função para resolver o problema "Incorret Size"
                        # Para o lab08a: a0 = 10 e a1 = 10
    
    # Parâmetros de "setScaling":
    li a0, 1         # a0: horizontal scaling
    li a1, 1         # a1: vertical scaling
    jal setScaling

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
            jal get_byte
            mv a2, a0       # a2 = cor do pixel
            li a0, '\n'
            sb a0, 0(t2)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    
            li a7, 255
            mul a2, a2, a7      # a2 = 255*pixel
            div a2, a2, s5      # a2 = 255*pixel/maxval
            sub a2, a7, a2
    
            mv a0, s6           # a0: x
            mv a1, s7           # a1: y
                                # a2: pixel's color
            jal setPixel

            # # --- Escrevendo no terminal do simulador --- #
            # # Parâmetros de "write":
            # la a1, pixel        # a1: buffer
            # sub a2, t2, s2
            # addi a2, a2, 1      # a2: size
            # jal write
        
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

    li a0, '\n'
    sb a0, 0(t1)    # Armazena 1 byte de t1 na posição de memória t2 + 0
    # --- Escrevendo no terminal do simulador --- #
    # Parâmetros de "write":
    la a1, file     # a1: buffer
    li a2, 0x40000  # a2: size
    jal write

    # --------------------------------------- #
    # --- Fechando o arquivo "input_file" --- #
    # --------------------------------------- #
    # Parâmetros de "close_file":    
    mv a0, s0       # a0: address for the file path
    jal close_file

    # ------------------------------------ #
    # --- Chamando a saída do programa --- #
    # ------------------------------------ #
    j exit


.data

.align 2
# input_file: .string "feep.pgm"
# input_file: .string "bird.pgm"
# input_file: .string "test.pgm"
input_file: .string "image6.pgm"
# input_file: .string "image.pgm"

.align 2
file: .skip 0x40000

.align 2
width: .string "000*"   # w = x 
                        # max width = 512
.align 2
height: .string "000*"  # h = y
                        # max height = 512
.align 2
maxval: .string "000*"  # max maxval = 255

.align 2
pixel: .string "000*"   # max pixel = 255

# REGISTRADORES
    # s0 = descritor de arquivo para "input_file"
    # s1 = endereço de "file"
    # s2 = posições de w ou h ou maxval
    # s3 = width (inteiro)
    # s4 = height (inteiro)
    # s5 = maxval (inteiro)
    # t1 = ponteiro para "file"
    # t2 = ponteiro para width ou height ou maxval
    # a7 = syscalls ou auxiliar de div ou mul