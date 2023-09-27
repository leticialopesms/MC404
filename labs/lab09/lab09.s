.text
.globl _start


_start:
    j main


exit:
    li a7, 93       # a7: syscall exit (93)
    ecall


open:
    # a0: address for the file path
    li a1, 0        # a1 = flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0        # a2 = mode
    li a7, 1024     # a7 = syscall open (1024)
    ecall
    ret


read:
    # a0: file descriptor (stdin = 0)
    # a1: buffer
    # a2: size (bytes)
    li a7, 63       # a7: syscall read (63)
    ecall
    ret


write:
    # a0: file descriptor (stdout = 1)
    # a1: buffer
    # a2: size (bytes)
    li a7, 64       # a7: syscall write (64)
    ecall
    ret


close:
    # a0: address for the file path
    li a7, 57       # a7: syscall close (57)
    ecall
    ret


find_endl:
    # t1: pointer to a string
    addi t1, t1, 1  # Update t1 pointer
    lb a0, 0(t1)            # a0 = byte from the memory position t1 + 0
    li a1, '\n'             # a1 = 10
    bne a0, a1, find_endl   # if a0 != a1 then find_endl
    ret


# Convert a number stored in string format to a integer
to_int:
    # a1: pointer to the least significant digit (LSD) of "input" string
    # a2: pointer to the most significant digit (MSD) of "input" string
    li a0, 0        # a0 = ret value
    li a7, 1        # a7 = multiplication factor
    LOOP_to_int:
        # --- Convert char to int --- #
        lb a3, 0(a1)        # Adiciona 1 byte (da posição a1 + 0 da memória) no registrador a3
        addi a3, a3, -48    # Converte o valor em a3 de char para int
        mul a3, a3, a7      # Aplica o fator de multiplicação em a3
        add a0, a0, a3      # Soma a0 (valor inicial) com a2 (valor atual multiplicado pelo seu fator)
                            # Armazena em a0

        # --- Updating multiplication factor --- #
        li a3, 10
        mul a7, a7, a3         # Atualiza o fator de multiplicação (multiplica a7 por 10)

        # --- Updatig pointer --- #
        addi a1, a1, -1         # Remove 1 do iterador a1
                                # Move o ponteiro a1 de "numero" para a esquerda
       
        # --- Checking LOOP condition --- #
        bge a1, a2, LOOP_to_int

    # --- Instruction after LOOP --- #
    # Now a1 = a2 - 1
    ret


# Convert a number stored in integer format to a string
to_string:
    # a0: n = integer number
    # a1: pointer to the string
    li a2, 0    # a2 = number of digits in n
    li a7, 10   # a7 = number base

    # --- Checking if (number == 0) --- #
    li a3, '0'
    sb a3, 0(a1)
    addi a1, a1, 1  # updates the pointer a1
    beqz a0, end_to_string
    addi a1, a1, -1 # updates the pointer a1
                    # basically ignores what was added
    
    # --- Checking if (number < 0) --- #
    bge a0, zero, LOOP_to_stack # if a0 >= zero then LOOP_to_stack
    li a3, '-'      # else
    sb a3, 0(a1)    # stores the negative sign in the string
    addi a1, a1, 1  # updates the pointer a1
    li a3, -1
    mul a0, a0, a3  # turn n into positive
    
    LOOP_to_stack:
        # --- Getting the digit --- #
        remu a3, a0, a7     # a3 = remainder of a0/a7 (n/10)
        addi a3, a3, 48     # convert value in a3 to char, according to ASCII table
        # --- Stacking up the value --- #
        addi sp, sp, -1
        sb a3, 0(sp)
        # --- Updating number of digits in n --- #
        addi a2, a2, 1
        # --- Updating n --- #
        divu a0, a0, a7     # a0 = a0/a7 (n/10)
        # --- Checking LOOP condition --- #
        bnez a0, LOOP_to_stack
    
    LOOP_to_string:
        # --- Getting the value from stack --- #
        lb a3, 0(sp)
        addi sp, sp, 1
        # --- Adding to string --- #
        sb a3, 0(a1)
        addi a1, a1, 1  # updates the pointer a1
        # --- Updating number of digits in n --- #
        addi a2, a2, -1
        # --- Checking LOOP condition --- #
        bnez a2, LOOP_to_string
    
    end_to_string:
        li a3, '\n'
        sb a3, 0(a1)
        # Now a1 points to '\n'
        ret


search_in_linked_list:
    # a0: input number
    la a1, head_node    # a1 = pointer to head_node
    li a7, 0            # a7 = counter = node index
    LOOP_search:
        # --- Storing the values of the current node --- #
        # VAL1
        lw a2, 0(a1)    # a2 = VAL1
        addi a1, a1, 4  # Update pointer
        # VAL1
        lw a3, 0(a1)    # a2 = VAL1
        addi a1, a1, 4  # Update pointer

        # --- Getting VAL1 + VAL2 --- #
        add a2, a2, a3  # a2 = VAL1 + VAL2
    
        # --- Pointing to the NEXT node --- #
        lw a1, 0(a1)    # a1 = pointer to the next node

        # --- Checking if (VAL1 + VAL2 = input number) --- #
        beq a0, a2, found   # if a0 == a1 then found
        addi a7, a7, 1      # else update counter
        
        # --- Checking if NEXT note is NULL --- #
        beqz a1, not_found  # if a1 == 0 the not_found
        j LOOP_search       # else go back to LOOP to search the next node

    # a0 = function ret
    found:
        mv a0, a7
        ret
    not_found:
        li a0, -1
        ret


main:
    # # ---------------------------- #
    # # --- Reading input number --- #
    # # ---------------------------- #
    li a0, 0        # a0: file descriptor
    la a1, input    # a1: buffer to write the data
    li a2, 6        # a2: size
    jal read

    la s1, input    # s1 = address of "input" string
    mv t1, s1       # t1 = pointer to string "input"

    # -------------------------------- #
    # --- Checking the number sign --- #
    # -------------------------------- #
    lb a0, 0(t1)            # a0 = first digit of "input" string
    li a1, '-'              # a1 = 45
    beq a0, a1, negative    # if a0 == a1 then negative
    j positive              # else then positive

    negative:
        li s11, -1      # s11 = -1 (negative sign)
        addi t1, t1, 1  # Update t1 pointer
        addi s1, s1, 1  # Update the first digit of "input" string
        j convert

    positive:
        li s11, 1       # s11 = 1 (positive sign)
        j convert
    
    # -------------------------------- #
    # --- Converting number to int --- #
    # -------------------------------- #
    convert:
        # Adjusting pointer t1
        jal find_endl
        addi t1, t1, -1 # Now t1 no longer points to '\n' character
        
        # Converting
        mv a1, t1   # a1: pointer to the LSD of "input" string
        mv a2, s1   # a2: pointer to the MSD of "input" string
        jal to_int

        mv s2, a0       # s2 = a0 = number module
        mul s2, s2, s11 # Applying sign
    
    # ------------------------------------------------- #
    # --- Searching for the number in a Linked List --- #
    # ------------------------------------------------- #
    mv a0, s2   # a0: input number
    jal search_in_linked_list
    mv s3, a0   # s3 = answer = node index or -1

    # ----------------------------------- #
    # --- Converting number to string --- #
    # ----------------------------------- #
    la s1, output
    mv a0, s3   # a0: n = integer number
    mv a1, s1   # a1: pointer to the string
    jal to_string

    # ----------------------------------------- #
    # --- Displaying the answer in terminal --- #
    # ----------------------------------------- #
    li a0, 1        # a0: file descriptor
    la a1, output   # a1: buffer
    li a2, 6        # a2: size
    jal write

    # -------------------------------- #
    # --- Calling the program exit --- #
    # -------------------------------- #
    j exit


.data

.align 2
# input: .string "******"
# input: .string "134\n"
input: .string "45\n"

.align 2
output: .string "******"

# .align 2
# head_node: 
#     .word 10
#     .word -4
#     .word node_1
# # .skip 10
# node_1: 
#     .word 56
#     .word 78
#     .word node_2
# # .skip 5
# node_3:
#     .word -100
#     .word -43
#     .word 0
# node_2:
#     .word -654
#     .word 590
#     .word node_3

# Registers:
# s1: address of "input" string or "output" string
# s2: integer number
# s3: answer = node index or -1
# s11: number sign
# t1: pointer to "input" string or "output" string