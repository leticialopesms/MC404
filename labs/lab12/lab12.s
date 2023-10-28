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


close:
    # a0: address for the file path
    li a7, 57       # a7: syscall close (57)
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


ignore_whitespace:
    lb t1, 0(a0)    # t1 = current byte (from memory address a0 + 0)
    addi a0, a0, 1  # Updates pointer a0

    li t2, ' '
    beq t1, t2, ignore_whitespace
    li t2, '\t'
    beq t1, t2, ignore_whitespace
    li t2, '\n'
    beq t1, t2, ignore_whitespace
    li t2, 0x0b # '\v'
    beq t1, t2, ignore_whitespace
    li t2, 0x0c # '\f'
    beq t1, t2, ignore_whitespace
    li t2, '\r'
    beq t1, t2, ignore_whitespace
    li t2, 0
    beq t1, t2, all_whitespace

    addi a0, a0, -1
    ret

    all_whitespace:
        li a0, 0
        ret


find_newline:
    # Parameters: 
    # a0: pointer to a string
    lb a1, 0(a0)                # a1 = byte from the memory address a0 + 0
    li a2, '\n'                 # a2 = 10
    addi a0, a0, 1              # Updates pointer a0
    bne a1, a2, find_newline    # if a1 != a2 then find_eof
    addi a0, a0, -1             # Updates pointer a0
    # returns the position of '\n'
    ret


find_null:
    # Parameters:
    # a0: pointer to a string
    lb a1, 0(a0)            # a1 = byte from the memory address a0 + 0
    li a2, 0                # a2 = 0
    addi a0, a0, 1          # Updates pointer a0
    bne a1, a2, find_null   # if a1 != a2 then find_null
    addi a0, a0, -1         # Updates pointer a0
    # returns the position of '\0'
    ret


find_space:
    # Parameters:
    # a0: pointer to a string
    lb a1, 0(a0)            # a1 = byte from the memory address a0 + 0
    li a2, ' '              # a2 = 32
    addi a0, a0, 1          # Updates pointer a0
    bne a1, a2, find_space  # if a1 != a2 then find_space
    addi a0, a0, -1         # Updates pointer a0
    # returns the position of ' '
    ret


# Get string from stdin
# char *gets ( char *str )
gets:
    # Parameters:
    # a0 (str): Pointer to a block of memory (array of char) where the string read is copied
    
    # --------------------------------- #
    # --- Storing ra value on stack --- #
    # --------------------------------- #
    addi sp, sp, -4
    sw ra, 0(sp)

    # -------------------------------------------- #
    # --- Storing the begining of str on stack --- #
    # -------------------------------------------- #
    addi sp, sp, -4
    sw a0, 0(sp)

    # ---------------------------------------------------- #
    # --- Storing the current position of str on stack --- #
    # ---------------------------------------------------- #
    addi sp, sp, -4
    sw a0, 0(sp)

    # ------------------------------- #
    # --- Reading from the buffer --- #
    # ------------------------------- #
    1:
        # --- Restoring current position on stack --- #
        lw a1, 0(sp)    # a1 = adress of current byte

        # --- Calling the read funtion --- #
        li a0, 0        # a0: file descriptor (stdin = 0)
                        # a1: buffer
        li a2, 1        # a2: size (bytes)
        jal read

        # --- Getting current byte --- #
        lb a2, 0(a1)    # a2 = byte from 'a0 + 0' memory position
        li a3, '\n'     # a3 = 10

        # --- Checking if '\n' was found --- #
        beq a2, a3, end_gets    # if a2 == a3 then end_gets

        # --- Storing next position of str on stack --- #
        addi a1, a1, 1  # Updates a1 pointer
        sw a1, 0(sp)    # Stores a1 on stack
        j 1b

    end_gets:
        # -------------------------------------------- #
        # --- Updating the current position of str --- #
        # -------------------------------------------- #
        lw a0, 0(sp)        # a0 = end of str (points to '\n')
        addi sp, sp, 4      # Updates stack

        # -------------------------------------- #
        # --- Adding the null character '\0' --- #
        # -------------------------------------- #
        li a1, 0
        sb a1, 0(a0)

        # ------------------------------------ #
        # --- Updating the begining of str --- #
        # ------------------------------------ #
        lw a0, 0(sp)
        addi sp, sp, 4

        # ------------------------------------ #
        # --- Recovering ra value on stack --- #
        # ------------------------------------ #
        lw ra, 0(sp)
        addi sp, sp, 4
        ret


get_number:
    Parameters:
    # a0 (original_str): pointer to the original string
    # a1 (str_num): pointer to the number string

    # ------------------------------------------------ #
    # --- Storing the begining of str_num on stack --- #
    # ------------------------------------------------ #
    addi sp, sp, -4     # Updates stack
    sw a1, 0(sp)        # a1 = begining of str_num

    # ------------------------------------- #
    # --- Reading from the original_str --- #
    # ------------------------------------- #
    mv t1, a0   # t1 = current byte from str
    mv t2, a1   # t2 = current byte from str_num
    1:
        # --- Getting current byte --- #
        lb t3, 0(t1)    # t3 = byte from 't1 + 0' memory position

        # --- Checking if 0 (null char) was found --- #
        li t4, 0                    # t4 = 0
        beq t3, t4, end_get_number  # if t3 == t4 then end_get_number
    
        # --- Updating str_num --- #
        sb t3, 0(t2)
        addi t2, t2, 1

        # --- Updating t1 pointer --- #
        addi t1, t1, 1  # t1 now points to the next byte
        j 1b

    end_get_number:
        # ------------------------------------------------- #
        # --- Adding the null character '\0' on str_num --- #
        # ------------------------------------------------- #
        li t3, 0
        sb t3, 0(t2)

        # ---------------------------------------------------- #
        # --- Restoring the begining of str_num from stack --- #
        # ---------------------------------------------------- #
        lw a0, 0(sp)        # a0 = begining of str_num
        addi sp, sp, 4      # Updates stack

        ret


# Write string to stdout
# void puts ( const char *str )
puts:
    # Parameters:
    # a0 (str): Pointer to C string to be printed
    
    # --------------------------------- #
    # --- Storing ra value on stack --- #
    # --------------------------------- #
    addi sp, sp, -4
    sw ra, 0(sp)

    # -------------------------------------------- #
    # --- Storing the begining of str on stack --- #
    # -------------------------------------------- #
    addi sp, sp, -4
    sw a0, 0(sp)

    # ----------------------------------- #
    # --- Reaching the '\0' character --- #
    # ----------------------------------- #
    1:
        lb a1, 0(a0)        # a1 = byte from the memory address a0 + 0
        addi a0, a0, 1      # Updates a0 pointer
        li a2, 0            # a2 = 0
        bne a1, a2, 1b      # if a1 != a2 then 1b
        addi a0, a0, -1     # else updates a0 pointer
        # Now, a0 points to '\0'

    # ----------------------------------------- #
    # --- Adding the newline character '\n' --- #
    # ----------------------------------------- #
    li a1, '\n'
    sb a1, 0(a0)

    # ------------------------------------- #
    # --- Getting the begining of str --- #
    # ------------------------------------- #
    lw a1, 0(sp)    # a1 = begining of str

    # ------------------------------- #
    # --- Getting the size of str --- #
    # ------------------------------- #
    addi a0, a0, 1  # a0 = end of str + 1
    sub a2, a0, a1  # a2 = size of str

    # --------------------------------- #
    # --- Calling the write funtion --- #
    # --------------------------------- #
    li a0, 1    # a0: file descriptor (stdout = 1)
                # a1: buffer
                # a2: size (bytes)
    jal write

    # ----------------------------------------- #
    # --- Restoring the null character '\0' --- #
    # ----------------------------------------- #
    add a0, a1, a2  # a0 = begining of str + size of str
    addi a0, a0, -1 # a0 now points to '\n'
    li a1, 0
    sb a1, 0(a0)

    # ------------------------------------- #
    # --- Restoring the begining of str --- #
    # ------------------------------------- #
    lw a0, 0(sp)    # a0 = begining of str
    addi sp, sp, 4  # Updates stack

    # ------------------------------------- #
    # --- Recovering ra value on stack --- #
    # ------------------------------------- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# Convert string to integer
# int atoi (const char *str)
atoi:
    # Parameters:
    # a0 (str): Pointer to C string beginning with the representation of an integral number
    
    # --------------------------------- #
    # --- Storing ra value on stack --- #
    # --------------------------------- #
    addi sp, sp, -4
    sw ra, 0(sp)

    # ------------------------------------------ #
    # --- Ignoring the whitespace characters --- #
    # ------------------------------------------ #
    jal ignore_whitespace
    beqz a0, end_atoi       # if a0 == 0 then end_atoi
                            # else a0 = begining of number

    li a4, 1    # a4 = sign of n
    li a5, 0    # a5 = counter = number of digits in n
    li a6, 1    # a6 = multiplication factor
    li a7, 0    # a7 = n

    # -------------------------------- #
    # --- Checking the number sign --- #
    # -------------------------------- #
    check_sign_str:
        lb a1, 0(a0)            # a1 = first digit of number or number sign
        li a2, '-'              # a2 = 45
        beq a1, a2, negative    # if a1 == a2 then negative
        j positive              # else positive

    negative:
        li a4, -1       # a4 = -1 (minus sign)
        addi a0, a0, 1  # Updates the pointer a0
        j LOOP_stack_up_char

    positive:
        # a4 = 1 (plus sign)
        j LOOP_stack_up_char

    # ------------------------- #
    # --- Converting to int --- #
    # ------------------------- #
    LOOP_stack_up_char:
        # --- Checking if the current byte is a number --- #
        lb a1, 0(a0)        # a1 = byte (from memory address a0 + 0)
        li a2, 48
        blt a1, a2, LOOP_to_int # if a1 < a2 then LOOP_to_int
        li a2, 57
        bgt a1, a2, LOOP_to_int # if a1 > a2 then LOOP_to_int

        # --- Stacking up the value --- #
        addi sp, sp, -1
        sb a1, 0(sp)
    
        # --- Updating the pointer a0 --- #
        addi a0, a0, 1

        # --- Updating number of digits in n --- #
        addi a5, a5, 1

        j LOOP_stack_up_char

    LOOP_to_int:
        # --- Checking LOOP condition --- #
        beqz a5, converted

        # --- Getting the value from stack --- #
        lb a1, 0(sp)
        addi sp, sp, 1

        # --- Convert char to int --- #
        addi a1, a1, -48    # converts value in a1 to int (0 to 9), according to ASCII table
        mul a1, a1, a6      # applies multiplication factor on a1
        add a7, a7, a1      # sums the current value on a7

        # --- Updating multiplication factor --- #
        li a1, 10
        mul a6, a6, a1      # updates the multiplication factor (a6 * 10)

        # --- Updatig counter --- #
        addi a5, a5, -1     # shifts a1 pointer to the left
       
        # --- Repeating --- #
        j LOOP_to_int

    converted:
        mul a7, a7, a4  # applies sign
        mv a0, a7       # a0 = integer n
        j end_atoi

    end_atoi:
        # ------------------------------------ #
        # --- Recovering ra value on stack --- #
        # ------------------------------------ #
        lw ra, 0(sp)
        addi sp, sp, 4

        # returns integer n if valid
        # or 0 if invalid
        ret


# Convert integer to string (non-standard function)
# char *itoa ( int value, char *str, int base )
itoa:
    # Parameters:
    # a0 (value): Value (n) to be converted to a string
    # a1 (str): Pointer to array in memory where to store the resulting null-terminated string
    # a2 (base): Numerical base used to represent the value as a string (10 or 16)
    
    mv t1, a1
    li a5, 0    # a5 = number of digits in n

    # --------------------------- #
    # --- Checking if (n < 0) --- #
    # --------------------------- #
    li a3, 16
    beq a2, a3, LOOP_stack_up_int   # if a2 == a3 (base == 16) then LOOP_stack_up_int
    bge a0, zero, LOOP_stack_up_int # if a0 >= 0 (n >= 0) then LOOP_stack_up_int
    
    li a3, '-'      # else
    sb a3, 0(a1)    # stores the negative sign in the string
    addi a1, a1, 1  # updates the pointer a1
    li a3, -1
    mul a0, a0, a3  # turn n into positive

    # ---------------------------- #
    # --- Converting to string --- #
    # ---------------------------- #
    LOOP_stack_up_int:
        # --- Getting the digit --- #
        remu a3, a0, a2     # a3 = remainder of a0/a2 (n/base)

        # --- Stacking up the value --- #
        addi sp, sp, -4
        sw a3, 0(sp)

        # --- Updating number of digits in n --- #
        addi a5, a5, 1

        # --- Updating n --- #
        divu a0, a0, a2     # a0 = a0/a2 (n/base)

        # --- Checking LOOP condition --- #
        bnez a0, LOOP_stack_up_int

    LOOP_to_string:
        # --- Getting the value from stack --- #
        lw a3, 0(sp)
        addi sp, sp, 4

        # --- Converting to char --- #
        li a4, 10
        blt a3, a4, to_char # if a3 < a4 then to_char
        addi a3, a3, 7      # else considers letters 'a' to 'f'
        to_char:
            addi a3, a3, 48 # converts value in a3 to char, according to ASCII table
    
        # --- Adding to string --- #
        sb a3, 0(a1)

        # --- Updating the pointer a1 --- #
        addi a1, a1, 1

        # --- Updating number of digits in n --- #
        addi a5, a5, -1

        # --- Checking LOOP condition --- #
        bnez a5, LOOP_to_string

    end_itoa:
        li a3, 0
        sb a3, 0(a1)
        # now a1 points to '\0'
        mv a0, t1

        # returns a pointer to the string
        ret

# Reverse a variable size string
reverse_string:
    # Parameters:
    # a0 (str1): Pointer to the original string to be reversed
    # a1 (str2): Pointer to a block of memory where the reversed string will be copied

    # --------------------------------- #
    # --- Storing ra value on stack --- #
    # --------------------------------- #
    addi sp, sp, -4
    sw ra, 0(sp)

    # --------------------------------------------- #
    # --- Storing the begining of str2 on stack --- #
    # --------------------------------------------- #
    addi sp, sp, -4
    sw a1, 0(sp)

    # ------------------------------- #
    # --- Reversing string (str1) --- #
    # ------------------------------- #
    # --- Getting size of str1 --- #
    mv t1, a0       # t1 = begining of the original string
    mv t2, a1       # t2 = begining of the reversed string
    jal find_null   # a0 points to '\0'
    sub t3, a0, t1  # t3 = size of string
    addi t1, a0, -1 # t1 = a0 - 1 = end of string

    # --- Copying to str2 --- #
    # t1 = current byte of str1
    # t2 = current byte of str2
    # t3 = size of string
    copy:
        lb t4, 0(t1)
        sb t4, 0(t2)
        addi t1, t1, -1
        addi t2, t2, 1
        addi t3, t3, -1
        bnez t3, copy

    li t4, 0
    sb t4, 0(t2)

    # ------------------------------------- #
    # --- Restoring the begining of str --- #
    # ------------------------------------- #
    lw a0, 0(sp)    # a0 = begining of str
    addi sp, sp, 4  # Updates stack

    # ------------------------------------ #
    # --- Recovering ra value on stack --- #
    # ------------------------------------ #
    lw ra, 0(sp)
    addi sp, sp, 4

    # returns the pointer to the reversed stirng
    ret


# main
main:
    la a0, buffer
    jal gets
    jal atoi
    li t1, 1
    beq a0, t1, operation_1 # if a0 == t1 then operation_1
    li t1, 2
    beq a0, t1, operation_2 # if a0 == t1 then operation_2
    li t1, 3
    beq a0, t1, operation_3 # if a0 == t1 then operation_3
    li t1, 4
    beq a0, t1, operation_4 # if a0 == t1 then operation_4
    j end_main
    
    operation_1:
        # --- Reading string --- #
        la a0, buffer
        jal gets
        # --- Printing string --- #
        jal puts
        # --- End --- #
        j end_main

    operation_2:
        # --- Reading string --- #
        la a0, buffer
        jal gets
        # --- Reversing string --- #
        la a1, reversed
        jal reverse_string
        # --- Printing string --- #
        jal puts
        # --- End --- #
        j end_main

    operation_3:
        # --- Reading decimal number --- #
        la a0, buffer
        jal gets
        # --- Converting to int --- #
        jal atoi
        # --- Converting to hexadecimal --- #
        la a1, buffer
        li a2, 16
        jal itoa
        # --- Printing converted number --- #
        jal puts
        # --- End --- #
        j end_main

    operation_4:
        # --- Reading buffer --- #
        la a0, buffer
        jal gets

        # --- Getting first number --- #
        jal find_space
        li t1, 0
        sb t1, 0(a0)
        mv s3, a0       # s3 = address of the end of the number (points to null)

        la a0, buffer   # a0 = pointer to begining of first number on buffer
        la a1, number   # a1 = pointer to string number
        jal get_number
        jal atoi
        mv s1, a0       # s1 = first number

        # --- Getting operator --- #
        mv a0, s3
        addi a0, a0, 1
        lb s3, 0(a0)    # s3 = operator
        addi a0, a0, 2

        # --- Getting second number --- #
        # a0 = pointer to begining of second number on buffer
        la a1, number   # a1 = pointer to string number
        jal get_number
        jal atoi
        mv s2, a0       # s2 = second number

        # --- Performing operation --- #
        # s1 = first number
        # s2 = second number
        # s3 = operator
        li t1, '+'
        beq s3, t1, sum     # if s3 == t1 then sum
        li t1, '-'
        beq s3, t1, subt    # if s3 == t1 then subt
        li t1, '*'
        beq s3, t1, mult    # if s3 == t1 then mult
        li t1, '/'
        beq s3, t1, divi    # if s3 == t1 then divi
        # else (just in case)
        li a0, 0

        sum:
            add a0, s1, s2  # a0 = s1 + s2
            j print_operation
        subt:
            sub a0, s1, s2  # a0 = s1 - s2
            j print_operation
        mult:
            mul a0, s1, s2  # a0 = s1 * s2
            j print_operation
        divi:
            div a0, s1, s2  # a0 = s1 / s2
            j print_operation
        
        print_operation:
            # --- Converting to string --- #
            la a1, buffer
            li a2, 10
            jal itoa
            # --- Printing result --- #
            jal puts
            # --- End --- #
            j end_main

    end_main:
        j exit


.data
buffer: .skip 0x80
reversed: .skip 0x80
number: .skip 0x20