_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


# read_line1:
#     li a0, 0              # file descriptor = 0 (stdin)
#     la a1, input_decoded  # buffer to write the data
#     li a2, 5              # size (reads only 4 bytes)
#     li a7, 63             # syscall read (63)
#     ecall
#     ret


# read_line2:
#     li a0, 0              # file descriptor = 0 (stdin)
#     la a1, input_encoded  # buffer to write the data
#     li a2, 8              # size (reads only 4 bytes)
#     li a7, 63             # syscall read (63)
#     ecall
#     ret


# write_line1:
#     li a0, 1              # file descriptor = 1 (stdout)
#     la a1, output_encoded # buffer
#     li a2, 8              # size
#     li a7, 64             # syscall write (64)
#     ecall
#     ret


# write_line2:
#     li a0, 1              # file descriptor = 1 (stdout)
#     la a1, output_decoded # buffer
#     li a2, 5              # size
#     li a7, 64             # syscall write (64)
#     ecall
#     ret


# write_line3:
#     li a0, 1              # file descriptor = 1 (stdout)
#     la a1, output_error   # buffer
#     li a2, 2              # size
#     li a7, 64             # syscall write (64)
#     ecall
#     ret


main:
    # --- PARTE 1 --- #
    # jal read_line1
    
    start_part1:
        la s0, input_decoded    # Armazena o endereço da string "input_decoded" em s0
        mv t0, s0   # Copia o valor do registrador s0 em t0
                    # t0 é um ponteiro para a string endereçada em s0
                    # t0 aponta para o primeiro caracter da string "input_decoded"

        # Iterando sobre "input_decoded" para armazenar d1, d2, d3 e d4
        # d1
        lb s1, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador s1
                        # Esse byte é a posição t0 da string "input_decoded"
        addi s1, s1, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d2
        lb s2, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador s2
                        # Esse byte é a posição t0 da string "input_decoded"
        addi s2, s2, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d3
        lb s3, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador s3
                        # Esse byte é a posição t0 da string "input_decoded"
        addi s3, s3, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d4
        lb s4, 0(t0)    # Adiciona 1 byte (da posição t0 + 0 da memória) no registrador s4
                        # Esse byte é a posição t0 da string "input_decoded"
        addi s4, s4, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
    
    # Verificando valor de p1
    encoding_p1:
        li a7, 0        # Inicializando a soma d1 + d2 + d4
        add a7, a7, s1  # a7 = a7 + s1
        add a7, a7, s2  # a7 = a7 + s2
        add a7, a7, s4  # a7 = a7 + s4
        li a6, 1
        beq a7, a6, p1_odd  # if a7 == a6 then p1_odd
        li a6, 3
        beq a7, a6, p1_odd  # else if a7 == a6 then p1_odd
        p1_even:
            li a1, '0'  # p1 = 0
                        # d1d2d3 tem uma qtde par de '1's
            j encoding_p2
        p1_odd:
            li a1, '1'  # p1 = 1
                        # d1d2d4 tem uma qtde ímpar de '1's

    encoding_p2:
        li a7, 0        # Inicializando a soma d1 + d3 + d4
        add a7, a7, s1  # a7 = a7 + s1
        add a7, a7, s3  # a7 = a7 + s3
        add a7, a7, s4  # a7 = a7 + s4
        li a6, 1
        beq a7, a6, p2_odd  # if a7 == a6 then p2_odd
        li a6, 3
        beq a7, a6, p2_odd  # else if a7 == a6 then p2_odd
        p2_even:
            li a2, '0'  # p2 = 0
                        # d1d3d4 tem uma qtde par de '1's
            j encoding_p3
        p2_odd:
            li a2, '1'  # p2 = 1
                        # d1d3d4 tem uma qtde ímpar de '1's
    
    encoding_p3:
        li a7, 0        # Inicializando a soma d2 + d3 + d4
        add a7, a7, s2  # a7 = a7 + s2
        add a7, a7, s3  # a7 = a7 + s3
        add a7, a7, s4  # a7 = a7 + s4
        li a6, 1
        beq a7, a6, p3_odd  # if a7 == a6 then p3_odd
        li a6, 3
        beq a7, a6, p3_odd  # else if a7 == a6 then p3_odd
        p3_even:
            li a3, '0'  # p3 = 0
                        # d2d3d4 tem uma qtde par de '1's
            j continue
        p3_odd:
            li a3, '1'  # p3 = 1
                        # d2d3d4 tem uma qtde ímpar de '1's
    
    continue:
        # Convertendo d1, d2, d3 e d4 para char novamente
        addi s1, s1, '0'
        addi s2, s2, '0'
        addi s3, s3, '0'
        addi s4, s4, '0'

        # Inicializando "output_encoded"
        la s0, output_encoded    # Armazena o endereço da string "output_encoded" em s0
        mv t0, s0   # Copia o valor do registrador s0 em t0
                    # t0 é um ponteiro para a string endereçada em s0
                    # t0 aponta para o primeiro caracter da string "output_encoded"
        
        # Fazendo o encoding na string "output_encoded"
        # p1
        sb a1, 0(t0)    # Armazena 1 byte do registrador a1 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # p2
        sb a2, 0(t0)    # Armazena 1 byte do registrador a2 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d1
        sb s1, 0(t0)    # Armazena 1 byte do registrador s1 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # p3
        sb a3, 0(t0)    # Armazena 1 byte do registrador a3 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d2
        sb s2, 0(t0)    # Armazena 1 byte do registrador s2 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d3
        sb s3, 0(t0)    # Armazena 1 byte do registrador s3 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d4
        sb s4, 0(t0)    # Armazena 1 byte do registrador s4 na posição de memória t0 + 0
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita

    # --- PARTE 2 --- #
    # jal read_line2

    start_part2:
        la s0, input_encoded    # Armazena o endereço da string "input_encoded" em s0
        mv t0, s0   # Copia o valor do registrador s0 em t0
                    # t0 é um ponteiro para a string endereçada em s0
                    # t0 aponta para o primeiro caracter da string "input_encoded"

        # Inicializando p1, p2, d1, p3, d2, d3, d4
        # p1
        lb a1, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # p2
        lb a2, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d1
        lb s1, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # p3
        lb a3, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d2
        lb s2, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d3
        lb s3, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d4
        lb s4, 0(t0)
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
    
    decoding:
        la s0, output_decoded    # Armazena o endereço da string "output_decoded" em s0
        mv t0, s0   # Copia o valor do registrador s0 em t0
                    # t0 é um ponteiro para a string endereçada em s0
                    # t0 aponta para o primeiro caracter da string "output_decoded"

        # Iterando sobre "input_decoded" para armazenar d1, d2, d3 e d4
        # d1
        sb s1, 0(t0)
        addi s1, s1, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d2
        sb s2, 0(t0)
        addi s2, s2, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d3
        sb s3, 0(t0)
        addi s3, s3, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita
        # d4
        sb s4, 0(t0)
        addi s4, s4, -48    # Convertendo para inteiro
        addi t0, t0, 1  # Adiciona 1 ao iterador t0
                        # Move o ponteiro t0 de "input_decoded" para a direita

    # --- PARTE 3 --- #
    addi a1, a1, -48
    addi a2, a2, -48
    addi a3, a3, -48
    # Verificando se houve erros de decodificação
    # p1 XOR d1 XOR d2 XOR d4
    li a0, 0    # Inicializando a proposição 1
    xor a0, a0, a1
    xor a0, a0, s1
    xor a0, a0, s2
    xor a0, a0, s4
    bnez a0, error

    # p2 XOR d1 XOR d3 XOR d4
    li a0, 0    # Inicializando a proposição 2
    xor a0, a0, a2
    xor a0, a0, s1
    xor a0, a0, s3
    xor a0, a0, s4
    bnez a0, error

    # p3 XOR d2 XOR d3 XOR d4
    li a0, 0    # Inicializando a proposição 3
    xor a0, a0, a3
    xor a0, a0, s2
    xor a0, a0, s3
    xor a0, a0, s4
    bnez a0, error

    end:
        # jal write_line1
        # jal write_line2
        # jal write_line3
        jal exit

    error:
        la s0, output_error # Armazena o endereço da string "output_decoded" em s0
        li a0, '1'          # a0 = '1' = 49
        sb a0, 0(s0)        # Armazena a0 na posição de memória (t0 + 0)
        j end
        


.data

.align 2
# input_decoded: .asciiz "1111\n"
input_decoded: .string "0000\n"
# input_decoded: .asciiz "1001\n"
# input_decoded: .skip 0x5 # buffer
.align 2
input_encoded: .string "0000000\n"
# input_encoded: .asciiz "0011001\n"
# input_encoded: .skip 0x8 # buffer
.align 2
output_encoded: .string "0000000\n"
.align 2
output_decoded: .string "0000\n"
.align 2
output_error: .string "0\n" # = 1 se houver erros

# REGISTRADORES:
    # s0 = ponteiro para a string "input_decoded"  / ou / para a string "input_encoded"
    # s1 = d1
    # s2 = d2
    # s3 = d3
    # s4 = d4
    # t0 = iterador da string "input_decoded"  / ou /  da string "input_encoded"
    # a1 = p1
    # a2 = p2
    # a3 = p3
    # a6 = auxiliar de comparação (1 ou 3)
    # a7 = auxiliar de soma

# Causas de erros:
    # p1 XOR d1 XOR d2 XOR d4 = 1   ou
    # p2 XOR d1 XOR d3 XOR d4 = 1   ou
    # p3 XOR d2 XOR d3 XOR d4 = 1