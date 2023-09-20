_start:
    jal main


exit:
    li a7, 93               # syscall exit (93)
    ecall


read:
    li a0, 0                # file descriptor = 0 (stdin)
    la a1, input_address    # buffer to write the data
    li a2, 4                # size (reads only 4 bytes)
    li a7, 63               # syscall read (63)
    ecall
    ret


write:
    li a0, 1                # file descriptor = 1 (stdout)
    la a1, input_address    # buffer
    li a2, 4+10             # size
    li a7, 64               # syscall write (64)
    ecall
    ret


LOOP:
    # Início do LOOP
    li s1, 'a'              # Adiciona 1 byte ('a') no registrador s1
    sb s1, 0(t1)            # Armazena 1 byte do registrador s1 na posição de memória t1 + 0
    addi t1, t1, 1          # Adiciona 1 ao ponteiro t1
    # Subtrai 1 do contador e volta ao LOOP se t2 != 0
    addi t2, t2, -1
    bne t2, zero, LOOP
    # Instrução após o LOOP
    li s1, '\n'     # Adiciona 1 byte ('\n') no registrador s1
    sb s1, 0(t1)    # Armazena 1 byte do registrador s1 na posição de memória t1 + 0
    ret


main:
    jal read
    mv t1, a1       # Copia o valor do registrador a1 em t1
                    # t1 é um ponteiro para a string endereçada em a1
    addi t1, t1, 3  # Adiciona 3 ao ponteiro t1
                    # Agora, t1 aponta para o último caracter da string ('\n')

    # li s1, '4'      # Adiciona 1 byte ('4') no registrador s1
    # sb s1, 0(t1)    # Armazena 1 byte do registrador s1 na posição de memória t1 + 0
    # addi t1, t1, 1  # Adiciona 1 ao ponteiro t1

    # li s1, '\n'     # Adiciona 1 byte ('\n') no registrador s1
    # sb s1, 0(t1)    # Armazena 1 byte do registrador s1 na posição de memória t1 + 0
    # # addi t1, t1, 1  # Não precisa mais atualizar t1, pois ele já está apontando para o '\n'

    # Inicializando o contador para o LOOP
    li t2, 10
    jal LOOP

    jal write
    jal exit


.data

string:  .asciz "Hello! It works!!!\n"
input_address: .skip 0x10  # buffer
output_address: .skip 0x10  # buffer
