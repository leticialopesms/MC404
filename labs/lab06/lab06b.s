_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


read_YX:
    li a0, 0          # file descriptor = 0 (stdin)
    la a1, input_YX   # buffer to write the data
    li a2, 12         # size (reads only 4 bytes)
    li a7, 63         # syscall read (63)
    ecall
    ret


read_T:
    li a0, 0          # file descriptor = 0 (stdin)
    la a1, input_T    # buffer to write the data
    li a2, 20         # size (reads only 4 bytes)
    li a7, 63         # syscall read (63)
    ecall
    ret


write:
    li a0, 1         # file descriptor = 1 (stdout)
    la a1, output    # buffer
    li a2, 12        # size
    li a7, 64        # syscall write (64)
    ecall
    ret


store_num:
    # --- Lê um char de "input_T" e armazena-o em "numero" --- #
    lb a5, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador a5
    sb a5, 0(t2)    # Armazena 1 byte do registrador a1 na posição de memória t2 + 0
    
    # --- Atualiza os ponteiros --- #
    addi t0, t0, 1  # Adiciona 1 ao iterador t0
                    # Move o ponteiro t0 de "input_YX" para a direita
    addi t2, t2, 1  # Adiciona 1 ao iterador t2
                    # Move o ponteiro t2 de "numero" para a direita

    # --- Atualiza o contador --- #
    addi t3, t3, -1         # Subtrai 1 do contador t3
    bne t3, zero, store_num  # Volta ao LOOP se t3 != 0

    # --- Instrução após o LOOP --- #
    addi t0, t0, 1  # Adiciona 1 ao iterador t0
                    # Move o ponteiro t0 de "input_YX" para a direita
    addi t2, t2, -1 # Remove 1 do iterador t2
                    # Move o ponteiro t2 de "numero" para a esquerda
    # Agora t0 aponta para o próximo número (ou sinal do próximo número)
    # Agora t2 aponta para a posição 4 de "numero"
    ret


load_int:
    # --- Converte de char para inteiro --- #
    # a4 = valor do char atual (temp)
    lb a6, 0(t2)        # Adiciona 4 bytes (da posição t2 + 0 da memória) no registrador a0
    addi a6, a6, -48    # Converte de char para int
    mul a6, a6, a5      # Aplica o fator de multiplicação
    add a0, a0, a6      # Soma a0 (valor inicial) com a1 (valor atual multiplicado pelo seu fator)
                        # Armazena em a0

    # --- Atualiza o fator de multiplicação --- #
    mul a5, a5, s10         # Atualiza o fator de multiplicação (multiplica por a5 por 10)

    # --- Atualiza o ponteiro --- #
    addi t2, t2, -1         # Remove 1 do iterador t2
                            # Move o ponteiro t2 de "numero" para a esquerda

    # --- Atualiza o contador --- #
    addi t3, t3, -1         # Subtrai 1 do contador t3
    bne t3, zero, load_int  # Volta ao LOOP se t3 != 0

    # --- Instrução após o LOOP --- #
    # Agora t2 aponta para a posição 0 de "numero"
    ret


calculate_d:
    # --- Calcula o tempo (t) para a transmissão --- #
    # t = T_R - T_i
    # Calcula em [dm]
    sub a0, a4, a0  # a0 <= a4 - a0
                    # Agora a0 = t

    # --- Calcula a distância percorrida (d)  --- #
    # d = v * t = 0.3 * t
    li a5, 3
    mul a0, a0, a5      # a0 <= a0 * a5
                        # Agora, a0 = d * 10
    # Cuidado com propagação de erro devido à divisão inteira!
    # divu a0, a0, s10    # a0 <= a0 / s10
    #                     # Agora, a0 = d
    ret


to_string:
    # --- Adiciona o último algarismo de n na string "numero" --- #
    # Retorna o número invertido na string
    # Exemplo: n = 1234, numero = "4321 " (o sinal é adicionado no final depois deste LOOP)
    # a0 = n
    remu a5, a0, s10    # Calcula o resto da divisão de n por 10
                        # Armazena o resto de a0/s10 (n/10) em a5
                        # Os números têm sinal, mas são ignorados para essa conversão
    addi a5, a5, 48     # Atualiza o valor para char, segundo a tabela ASCII
    sb a5, 0(t2)        # Armazena o algarismo da posição t2 da string "numero"
                        # Armazena 1 byte do registrador a5 na posição de memória t2 + 0
    
    # --- Atualização de n --- #
    divu a0, a0, s10    # Divide n por 10
                        # Armazena a divisão de a0 por s10 (n/10) em a0
                        # Os números têm sinal, mas são ignorados para essa conversão

    # --- Atualização do ponteiro --- #
    addi t2, t2, 1      # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita

    # --- Atualização do contador --- #
    addi t3, t3, -1         # Subtrai 1 do contador t3
    bne t3, zero, to_string # Volta ao LOOP se t3 != 0

    # --- Instrução após o LOOP --- #
    # Agora t2 aponta para a posição 4 de "numero"
    ret


update_output:
    # --- Armazena um número na string "output"  --- #
    lb a5, 0(t2)    # Adiciona 1 byte (da posição t2 + 0 da memória) no registrador a5
                    # Esse byte é a posição t2 da string "numero"
    sb a5, 0(t1)    # Armazena 1 byte do registrador a5 na posição de memória t1 + 0
    
    # --- Atualização dos ponteiros --- #
    addi t1, t1, 1  # Adiciona 1 ao iterador t1
                    # Move o ponteiro t3 de "output" para a direita
    addi t2, t2, -1 # Remove 1 do iterador t2
                    # Move o ponteiro t2 de "numero" para a esquerda
    
    # --- Atualização do contador --- #
    addi t3, t3, -1             # Subtrai 1 do contador t3
    bne t3, zero, update_output # Volta ao LOOP se t3 != 0

    # --- Instrução após o LOOP --- #
    addi t1, t1, 1  # Adiciona 1 ao iterador t1
                    # Move o ponteiro t1 de "output" para a direita
    addi t2, t2, 1  # Adiciona 1 ao iterador t2
                    # Move o ponteiro t2 de "numero" para a direita
    # Agora t1 aponta para o sinal do próximo número
    # Agora t2 aponta para a posição 0 de "numero"
    ret


main:
    inicio:
        jal read_YX
        jal read_T

        la s1, output   # Armazena o endereço da string "output" em s1
        la s2, numero   # Armazena o endereço da string "numero" em s2

        mv t1, s1       # Copia o valor do registrador s1 em t1
                        # t1 é um ponteiro para a string endereçada em s1
                        # t1 aponta para o primeiro caracter da string "output"
        mv t2, s2       # Copia o valor do registrador s2 em t2
                        # t2 é um ponteiro para a string endereçada em s2
                        # t2 aponta para o primeiro caracter da string "numero"

        li s10, 10  # Armazena 4 bytes (o inteiro 10) em s10
        
    # --- Leitura de Y_B e X_C--- #
    la s0, input_YX     # Armazena o endereço da string "input_YX" em s0
    mv t0, s0           # Copia o valor do registrador s0 em t0
                        # t0 é um ponteiro para a string endereçada em s0
                        # t0 aponta para o primeiro caracter da string "input_YX"
    read_Y_B:
        # Lendo o sinal (+ ou -) de Y_B
        lb a4, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador a4
                        # Esse byte é a posição t0 = 0 da string "input_YX"
        sb a4, 0(t2)    # Armazena 1 byte do registrador a4 na posição de memória t2 + 0
                        # Adiciona o byte na posição t2 = 0 da string "numero"

        # Atualizando os ponteiros
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_YX" para a direita
        addi t2, t2, 1  # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita

        # Verificando o sinal de Y_B
        li a5, '+'
        beq a4, a5, positive_Y # if a4 == a5 then positive else negative
        negative_Y:    # (a4 = 1)
            li a4, -1
            j continue_Y
        positive_Y:    # (a4 = -1)
            li a4, 1

        # Alocando Y_B em s3
        continue_Y:
            # Inicializando o contador para a leitura de chars
            li t3, 4        # t3 = número de algarismos
            # Lendo Y_B de "input_YX" e armazenando em "numero"
            jal store_num
            li a5, 1        # a5 = fator de multiplicação
            li a0, 0        # a0 = valor do retorno de load_int
            # Inicializando o contador para a conversão do número
            li t3, 4        # t3 = número de algarismos
            # Convertendo Y_B na string "numero" em um inteiro e alocando seu valor em a0
            jal load_int    # LOOP
            mv s3, a0       # s3 = a0
            mul s3, s3, a4  # Aplica o sinal de Y_B (+ ou -)

            # Agora t0 aponta para o sinal do próximo número
            # Agora t2 aponta para a posição 0 de "numero" 
    
    read_X_C:
        # Lendo o sinal (+ ou -) de X_C
        lb a4, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador a4
                        # Esse byte é a posição t0 = 0 da string "input_YX"
        sb a4, 0(t2)    # Armazena 1 byte do registrador a4 na posição de memória t2 + 0
                        # Adiciona o byte na posição t2 = 0 da string "numero"

        # Atualizando os ponteiros
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_YX" para a direita
        addi t2, t2, 1  # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita

        # Verificando o sinal de X_C
        li a5, '+'
        beq a4, a5, positive_X # if a4 == a5 then positive else negative
        negative_X:    # (a4 = 1)
            li a4, -1
            j continue_X
        positive_X:    # (a4 = -1)
            li a4, 1

        # Alocando X_C em s4
        continue_X:
            # Inicializando o contador para a leitura de chars
            li t3, 4        # t3 = número de algarismos
            # Lendo X_C de "input_YX" e armazenando em "numero"
            jal store_num
            li a5, 1        # a5 = fator de multiplicação
            li a0, 0        # a0 = valor do retorno de load_int
            # Inicializando o contador para a conversão do número
            li t3, 4        # t3 = número de algarismos
            # Convertendo X_C na string "numero" em um inteiro e alocando seu valor em a0
            jal load_int    # LOOP
            mv s4, a0       # s4 = a0
            mul s4, s4, a4  # Aplica o sinal de X_C (+ ou -)

            # Agora t0 aponta para o sinal do próximo número
            # Agora t2 aponta para a posição 0 de "numero"

    # --- Leitura de T_A, T_B, T_C e T_R --- #
    la s0, input_T      # Armazena o endereço da string "input_T" em s0
    mv t0, s0           # Copia o valor do registrador s0 em t0
                        # t0 é um ponteiro para a string endereçada em s0
                        # t0 aponta para o primeiro caracter da string "input_T"
    
    read_T_A:
        addi t2, t2, 1  # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita
                        # Agora t2 aponta para a posição 1 de "numero"
        # Inicializando o contador para a leitura de chars
        li t3, 4        # t3 = número de algarismos
        # Lendo T_A de "input_T" e armazenando em "numero"
        jal store_num
        li a5, 1        # a5 = fator de multiplicação
        li a0, 0        # a0 = valor do retorno de load_int
        # Inicializando o contador para a conversão do número
        li t3, 4        # t3 = número de algarismos
        # Convertendo T_A na string "numero" em um inteiro e alocando seu valor em a0
        jal load_int    # LOOP
        mv a1, a0       # a1 = a0
        # Agora t0 aponta para o próximo número
        # Agora t2 aponta para a posição 0 de "numero"
    
    read_T_B:
        addi t2, t2, 1  # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita
                        # Agora t2 aponta para a posição 1 de "numero"
        # Inicializando o contador para a leitura de chars
        li t3, 4        # t3 = número de algarismos
        # Lendo T_B de "input_T" e armazenando em "numero"
        jal store_num
        li a5, 1        # a5 = fator de multiplicação
        li a0, 0        # a0 = valor do retorno de load_int
        # Inicializando o contador para a conversão do número
        li t3, 4        # t3 = número de algarismos
        # Convertendo T_B na string "numero" em um inteiro e alocando seu valor em a0
        jal load_int    # LOOP
        mv a2, a0       # a2 = a0
        # Agora t0 aponta para o próximo número
        # Agora t2 aponta para a posição 0 de "numero"
    
    read_T_C:
        addi t2, t2, 1  # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita
                        # Agora t2 aponta para a posição 1 de "numero"
        # Inicializando o contador para a leitura de chars
        li t3, 4        # t3 = número de algarismos
        # Lendo T_C de "input_T" e armazenando em "numero"
        jal store_num
        li a5, 1        # a5 = fator de multiplicação
        li a0, 0        # a0 = valor do retorno de load_int
        # Inicializando o contador para a conversão do número
        li t3, 4        # t3 = número de algarismos
        # Convertendo T_C na string "numero" em um inteiro e alocando seu valor em a0
        jal load_int    # LOOP
        mv a3, a0       # a3 = a0
        # Agora t0 aponta para o próximo número
        # Agora t2 aponta para a posição 0 de "numero"

    read_T_R:
        addi t2, t2, 1  # Adiciona 1 ao iterador t2
                        # Move o ponteiro t2 de "numero" para a direita
                        # Agora t2 aponta para a posição 1 de "numero"
        # Inicializando o contador para a leitura de chars
        li t3, 4        # t3 = número de algarismos
        # Lendo T_R de "input_T" e armazenando em "numero"
        jal store_num
        li a5, 1        # a5 = fator de multiplicação
        li a0, 0        # a0 = valor do retorno de load_int
        # Inicializando o contador para a conversão do número
        li t3, 4        # t3 = número de algarismos
        # Convertendo T_R na string "numero" em um inteiro e alocando seu valor em a0
        jal load_int    # LOOP
        mv a4, a0       # a4 = a0
        # Agora t0 aponta para o próximo número
        # Agora t2 aponta para a posição 0 de "numero"
    
    # --- Cálculo de d_A, d_B e d_C --- #
    get_d_A:
        mv a0, a1       # Armazena o valor de a1 (T_A) em a0
        jal calculate_d # Calcula o valor da distância d_A e armazena em a0
        mv a1, a0       # Armazena o valor de a0 (d_A) em a1 (em [dm])

    get_d_B:
        mv a0, a2       # Armazena o valor de a2 (T_B) em a0
        jal calculate_d # Calcula o valor da distância d_A e armazena em a0
        mv a2, a0       # Armazena o valor de a0 (d_B) em a2 (em [dm])

    get_d_C:
        mv a0, a3       # Armazena o valor de a3 (T_C) em a0
        jal calculate_d # Calcula o valor da distância d_A e armazena em a0
        mv a3, a0       # Armazena o valor de a0 (d_C) em a3 (em [dm])

    # --- Cálculo de x e y --- #
    mul a1, a1, a1  # Armazena em (d_A)^2 em a1 (em [cm])
    mul a2, a2, a2  # Armazena em (d_B)^2 em a2 (em [cm])
    mul a3, a3, a3  # Armazena em (d_C)^2 em a3 (em [cm])
    
    get_x:
        # x = [(d_A)^2 - (d_C)^2)] / (2*X_C) + (X_C) / 2
        li a0, 0        # Valor inicial de x
        add a0, a0, a1  # a0 <= a0 + a1
                        # a0 <= a0 + (d_A)^2
        sub a0, a0, a3  # a0 <= a0 - a3
                        # a0 <= a0 - (d_C)^2
        div a0, a0, s4  # a0 <= a0 / s4 (com sinal)
                        # a0 <= a0 / X_C
        srai a0, a0, 1  # a0 <= a0 / 2 (com sinal)
                        # Realiza o deslocamento de 1 bit para a direita
        
        # Converte de [cm] para [dm]
        div a0, a0, s10
        # Converte de [dm] para [m]
        div a0, a0, s10

        srai s4, s4, 1  # s4 <= s4 / 2 (com sinal)
                        # Divide X_C por 2
                        # Realiza o deslocamento de 1 bit para a direita
        add a0, a0, s4  # a0 <= a0 + s4
                        # a0 <= a0 + (X_C)
        
        bge a0, zero, plus_sign_x # if a0 >= zero then plus_sign_x
        minus_sign_x:
            li a4, -1
            mul a0, a0, a4  # Considera o módulo de x
            li a4, '-'
            j add_x
        plus_sign_x:
            li a4, '+'
        
        add_x:
            # Inicializando o contador
            li t3, 4        # t3 = número de algarismos
            jal to_string
            sb a4, 0(t2)    # Armazena 1 byte do registrador a4 (sinal) na posição de memória t2 + 0
            # Inicializando o contador
            li t3, 5        # t3 = número de algarismos + o sinal
            jal update_output


    get_y:
        # x = [(d_A)^2 - (d_B)^2)] / (2*Y_B) + (Y_B) / 2
        li a0, 0        # Valor inicial de y
        add a0, a0, a1  # a0 <= a0 + a1
                        # a0 <= a0 + (d_A)^2
        sub a0, a0, a2  # a0 <= a0 - a2
                        # a0 <= a0 - (d_B)^2
        div a0, a0, s3  # a0 <= a0 / s3 (com sinal)
                        # a0 <= a0 / Y_B
        srai a0, a0, 1  # a0 <= a0 / 2 (com sinal)
                        # Realiza o deslocamento de 1 bit para a direita
        
        # Converte de [cm] para [dm]
        div a0, a0, s10
        # Converte de [dm] para [m]
        div a0, a0, s10
    
        srai s3, s3, 1  # s3 <= s3 / 2 (com sinal)
                        # Divide Y_B por 2
                        # Realiza o deslocamento de 1 bit para a direita
        add a0, a0, s3  # a0 <= a0 + s3
                        # a0 <= a0 + (Y_B)

        bge a0, zero, plus_sign_y # if a0 >= zero then plus_sign_y
        minus_sign_y:
            li a4, -1
            mul a0, a0, a4  # Considera o módulo de x
            li a4, '-'
            j add_y
        plus_sign_y:
            li a4, '+'
        
        add_y:
            # Inicializando o contador
            li t3, 4        # t3 = número de algarismos
            jal to_string
            sb a4, 0(t2)    # Armazena 1 byte do registrador a4 (sinal) na posição de memória t2 + 0
            # Inicializando o contador
            li t3, 5        # t3 = número de algarismos + o sinal
            jal update_output

    fim:
        jal write
        jal exit


.data

.align 2
input_YX: .skip 0x20  # buffer
.align 2
input_T: .skip 0x12  # buffer
.align 2
output: .asciz "?0000 ?0000\n"
.align 2
numero: .asciz "?0000"

# REGISTRADORES: 
    # s0 = ponteiro para a string "input_YX"  / ou /  ponteiro para a string "input_T"
    # s1 = ponteiro para a string "numero"
    # s2 = ponteiro para a string "output"
    # s3 = Y_B
    # s4 = X_C
    # s10 = 10 (constante)
    # t0 = iterador da string "input_YX"  / ou /  "input_T"
    # t1 = iterador da string "output" = ponteiro para a atual posição da string "output"
    # t2 = iterador da string "numero" = ponteiro para a atual posição da string "numero"
    # t3 = contador para LOOPS
    # a0 = RETORNO  / ou /  RESPOSTAS (x e y)
    # a1 = T_A  / ou /  d_A
    # a2 = T_B  / ou /  d_B
    # a3 = T_C  / ou /  d_C
    # a4 = sinal do número atual  / ou /  T_R
    # a5 = auxiliares
    # a6 = auxiliares

# v = velocidade de propagação do sinal = 0.3 m/ns
# [T] = ns
# [d] = dm