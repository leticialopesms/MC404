_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


# read:
#     li a0, 0                # file descriptor = 0 (stdin)
#     la a1, input_address    # buffer to write the data
#     li a2, 4                # size (reads only 4 bytes)
#     li a7, 63               # syscall read (63)
#     ecall
#     ret


# write:
#     li a0, 1                # file descriptor = 1 (stdout)
#     la a1, input_address    # buffer
#     li a2, 5                # size
#     li a7, 64               # syscall write (64)
#     ecall
#     ret


LOOP:
    # Início do LOOP
    li a1, 'a'              # Adiciona 1 byte ('a') no registrador a1
    sb a1, 0(t1)            # Armazena 1 byte do registrador a1 na posição de memória t1 + 0
    addi t1, t1, 1          # Adiciona 1 ao ponteiro t1
    # Subtrai 1 do contador e volta ao LOOP se t2 != 0
    addi t2, t2, -1
    bne t2, zero, LOOP
    # Instrução após o LOOP
    li a1, '\n'     # Adiciona 1 byte ('\n') no registrador a1
    sb a1, 0(t1)    # Armazena 1 byte do registrador a1 na posição de memória t1 + 0
    ret


LOOP_INPUT:
    # --- Leitura do número --- #
    # Inicializando o contador para o LOOP_NUMERO
    li t5, 4
    jal LOOP_NUMERO

    # --- Conversão para inteiro --- #
    li a2, 0        # Inicializa o inteiro y
                    # Adiciona 4 bytes (0) no registrador a2
    li a3, 1        # Inicializa o fator de multiplicação
                    # Adiciona 4 bytes (1) no registrador a3
    la a4, dez      # Armazena o endereço do rótulo dez em a4
    lw a4, 0(a4)    # Armazena o valor do inteiro 10 em a4
    
    # Inicializando o contador para o LOOP_converte_string
    li t5, 4
    jal LOOP_converte_string

    # --- Cálculo da Raiz --- #
    # Palpite inicial para a raiz (k) de y
    mv a3, a2       # Inicializa o valor da raiz (k) como y
                    # Copia o valor do registrador a2 em a3
    srli a3, a3, 1  # Divide o valor do palpite inicial por 2
                    # Realiza o deslocamento de 1 bit para a direita
    # Inicializando o contador para o LOOP_raiz
    li t5, 10
    jal LOOP_raiz

    # --- Conversão para string --- #
    la a4, dez      # Armazena o endereço do rótulo dez em a4
    lw a4, 0(a4)    # Armazena o valor do inteiro 10 em a4
    # Inicializando o contador para o LOOP_converte_inteiro
    li t5, 4
    jal LOOP_converte_inteiro
    # Inicializando o contador para o LOOP_atualiza_output
    li t5, 4
    jal LOOP_atualiza_output

    # --- Atualização do LOOP --- #
    addi t4, t4, -1             # Subtrai 1 do contador t4
    bne t4, zero, LOOP_INPUT    # Volta ao LOOP se t4 != 0

    # --- Instução após o LOOP --- #
    jal fim


LOOP_NUMERO:    #OK
    # Lê cada um dos 4 algarismos de um número e armazena na string "numero"
    # --- Início do LOOP --- #
    lb a1, 0(t1)    # Adiciona 1 byte (da posição t1 + 0 da memória) no registrador a1
                    # Esse byte é a posição t1 da string "input"
    sb a1, 0(t2)    # Armazena 1 byte do registrador a1 na posição de memória t2 + 0

    # --- Atualização do LOOP --- #
    addi t1, t1, 1  # Adiciona 1 ao iterador t1
                    # Move o ponteiro t1, que aponta para a string "input"
    addi t2, t2, 1  # Adiciona 1 ao iterador t2
                    # Move o ponteiro t2, que aponta para a string "numero"
    addi t5, t5, -1             # Subtrai 1 do contador t5
    bne t5, zero, LOOP_NUMERO   # Volta ao LOOP se t5 != 0

    # --- Instrução após o LOOP --- #
    addi t2, t2, -1 # Remove 1 do iterador t2
                    # Agora t2 aponta para o algarismo menos significativo da string "numero"
    addi t1, t1, 1  # Move o ponteiro t1
                    # Ele passa a apontar para o início do próximo número
                    # e não para o caracter " "
    ret


LOOP_converte_string:   #OK
    # --- Converte de string para inteiro --- #
    lb a1, 0(t2)        # Adiciona 4 bytes (da posição t2 + 0 da memória) no registrador a1
                        # Esse byte é a posição t2 da string "numero"
    addi a1, a1, -48    # Converte de char para int
    mul a1, a1, a3      # Aplica o fator de multiplicação
    add a2, a2, a1      # Soma a2 (valor inicial) com a2 (caracter atual multiplicado pelo seu fator)

    # --- Atualização do LOOP --- #
    mul a3, a3, a4      # Atualiza o fator de multiplicação (multiplica por a3 por 10)
    addi t2, t2, -1     # Remove 1 do iterador t2
                        # Move o ponteiro t2 para a esquerda
    addi t5, t5, -1                     # Subtrai 1 do contador t5
    bne t5, zero, LOOP_converte_string  # Volta ao LOOP se t5 != 0

    # --- Instrução após o LOOP --- #
    addi t2, t2, 1  # Adiciona 1 ao iterador t2
                    # Agora t2 aponta para o algarismo mais significativo da string "numero"
    ret

LOOP_raiz:  #OK
    # --- Calcula a raiz de y --- #
    divu a5, a2, a3 # Inicializa o auxiliar y/k
                    # Divide o valor de a2 (y) pelo valor de a3 (k) e armazena em a5 (auxiliar)
                    # Os números não têm sinal
    add a3, a3, a5  # Soma k com y/k
                    # k' = k + y/k
    srli a3, a3, 1  # Divide o valor de k' por 2
                    # Realiza o deslocamento de 1 bit para a direita
                    # k' = (k + y/k)/2

    # --- Atualização do LOOP --- #
    addi t5, t5, -1          # Subtrai 1 do contador t5
    bne t5, zero, LOOP_raiz  # Volta ao LOOP se t5 != 0

    # --- Instrução após o LOOP --- #
    ret

LOOP_converte_inteiro:
    remu a5, a3, a4     # Calcula o resto da divisão de k por 10
                        # Armazena o resto de a3/a4 (k/10) em a5
                        # Os números não têm sinal
    addi a5, a5, 48     # Atualiza o valor para char, segundo a tabela ASCII
    sb a5, 0(t2)        # Armazena o algarismo da posição t2 da string "numero"
                        # Armazena 1 byte do registrador a5 na posição de memória t2 + 0
    
    # --- Atualização do LOOP --- #
    divu a3, a3, a4     # Divide k por 10
                        # Armazena a divisão de a3 por a4 (k/10) em a3
                        # Os números não têm sinal
    addi t2, t2, 1      # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 para a direita
    addi t5, t5, -1                     # Subtrai 1 do contador t5
    bne t5, zero, LOOP_converte_inteiro # Volta ao LOOP se t5 != 0

    # --- Instrução após o LOOP --- #
    addi t2, t2, -1 # Remove 1 do iterador t2
                    # Agora t2 aponta para o algarismo menos significativo da string "numero"
    ret

LOOP_atualiza_output:
    # --- Armazena um número na string "output"  --- #
    lb a5, 0(t2)    # Adiciona 1 byte (da posição t2 + 0 da memória) no registrador a5
                    # Esse byte é a posição t2 da string "numero"
    sb a5, 0(t3)    # Armazena 1 byte do registrador a5 na posição de memória t3 + 0
    # --- Atualização do LOOP --- #
    addi t3, t3, 1  # Adiciona 1 ao iterador t3
                    # Move o ponteiro t1 para a direita, que aponta para a string "output"
    addi t2, t2, -1 # Remove 1 do iterador t2
                    # Move o ponteiro t2 para a esquerda, que aponta para a string "numero"
    addi t5, t5, -1                     # Subtrai 1 do contador t5
    bne t5, zero, LOOP_atualiza_output  # Volta ao LOOP se t5 != 0

    # --- Instrução após o LOOP --- #
    addi t2, t2, 1  # Adiciona 1 ao iterador t2
                    # Agora t2 aponta para o algarismo mais significativo da string "numero"
                    # ou seja, para o início da string "numero"
    addi t3, t3, 1  # Move o ponteiro t3
                    # Ele passa a apontar para o início do próximo número (com,
                    # e não para o caracter " "
    ret


main:
    # jal read
    la s1, input
    la s2, numero
    la s3, output

    mv t1, s1   # Copia o valor do registrador s1 em t1
                # t1 é um ponteiro para a string endereçada em s1
                # t1 aponta para o primeiro caracter da string "input"

    mv t2, s2   # Copia o valor do registrador s2 em t2
                # t2 é um ponteiro para a string endereçada em s2
                # t2 aponta para o primeiro caracter da string "numero"
    
    mv t3, s3   # Copia o valor do registrador s3 em t3
                # t3 é um ponteiro para a string endereçada em s3
                # t3 aponta para o primeiro caracter da string "output"
    
    # Inicializando o contador para o LOOP_INPUT
    li t4, 4
    jal t0, LOOP_INPUT

    fim:
        # jal write
        jal exit


.data

# input_teste: .asciiz "0400 "
.align 2
input:  .asciiz "0400 5337 2240 9166\n"
.align 2
numero: .asciiz "0000"
.align 2
output:  .asciiz "0000 0000 0000 0000\n"
.align 2
endl: .byte '\n'
.align 2
dez: .byte 10
# input_address: .skip 0x20   # buffer
# output_address: .skip 0x20    # buffer

# s1 = ponteiro que aponta para a string "input"
# s2 = ponteiro que aponta para a string "numero"
# a1 = armazena o byte atual da string "input" / ou / "numero"
# a2 = armazena o o número atual (y) para calcular a sua raiz
# a3 = armazena o fator de multiplicação / ou / o valor aproximado para a raiz de y
# a4 = armazena o inteiro 10
# a5 = armazena o auxiliar y/k
# t1 = iterador da string "input" = ponteiro para o atual caracter da string "input"
# t2 = iterador da string "numero" = ponteiro para o atual caracter da string "numero"
# t3 = iterador da string "output" = ponteiro para o atual caracter da string "output"
# t4 = contador para o LOOP_INPUT
# t5 = contador para os LOOPS internos
