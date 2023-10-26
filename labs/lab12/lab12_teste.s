.text
.globl _start
.globl exit
.globl read
.globl write
.globl puts
.globl gets
.globl atoi
.globl itoa


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


find_eof:
    # Parameters: 
    # a0: pointer to a string
    lb a1, 0(a0)            # a1 = byte from the memory address a0 + 0
    addi a0, a0, 1          # Updates pointer a0
    li a2, '\n'             # a2 = 10
    beq a1, a2, found_eof   # if a1 == a2 then found_eof
    j find_eof
    
    found_eof:
        addi a0, a0, -1         # Updates pointer a0
        # returns the position of '\n'
        ret


find_null:
    # Parameters:
    # a0: pointer to a string
    lb a1, 0(a0)            # a1 = byte from the memory address a0 + 0
    li a2, 0                # a2 = 0
    addi a0, a0, 1          # Updates pointer a0
    bne a1, a2, find_null   # if a1 != a2 then find_null
    addi a0, a0, -1         # Update pointer a0
    # returns the position of '\0'
    ret


# Get string from stdin
# Reads characters from the stdin and stores them as C string into str (a0) until a newline character or the end-of-file is reached.
# The newline character (\n), if found, is not copied into str.
# A terminating null character (\0) is automatically appended after the characters copied to str.
# char *gets ( char *str )
gets:
    # Parameters:
    # a0 (str): Pointer to a block of memory (array of char) where the string read is copied as a C string
    
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
        lw a1, 0(sp)

        # --- Calling the read funtion --- #
        li a0, 0        # a0: file descriptor (stdin = 0)
                        # a1: buffer
        li a2, 1        # a2: size (bytes)
        # jal read

        # --- Getting current byte --- #
        lb a2, 0(a1)    # a2 = byte from 'a0 + 0' memory position
        li a3, '\n'     # a3 = 10

        # --- Storing next position of str on stack --- #
        addi a1, a1, 1  # Updates a1 pointer
        sw a1, 0(sp)    # Stores a1 on stack

        # --- Checking if '\n' was found --- #
        bne a2, a3, 1b    # if a2 != a3 then 1b
        addi a1, a1, -1   # else, a1 now points to '\n'
        sw a1, 0(sp)      # Stores a1 on stack
    
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
    # ------------------------------------- #
    lw a0, 0(sp)
    addi sp, sp, 4

    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# Write string to stdout
# Writes the C string pointed by str to the standard output (stdout) and appends a newline character ('\n').
# The function begins copying from the address specified (str) until it reaches the terminating null character ('\0').
# This terminating null-character is not copied to the stream.
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
# Parses the C-string str into an integral number, which is returned as a value of type int.
# The function discards as many whitespace characters (as in isspace) as necessary until the first non-whitespace is found.
# Then, starting from this character, takes an optional initial plus or minus sign followed by as many base-10 digits as possible.
# The string can contain additional characters after those that form the integral number, which are ignored.
# If it is not a valid integral number, or if no such sequence exists because either str is empty or it contains only whitespace characters, no conversion is performed and zero is returned.
# int atoi (const char *str)
atoi:
    # Parameters:
    # a0 (str): Pointer to C string beginning with the representation of an integral number
    addi a0, a0, -1 # sets pointer a0 to 1 position before the first byte

    # ------------------------------------------ #
    # --- Ignoring the whitespace characters --- #
    # ------------------------------------------ #
    ignore_whitespace:
        addi a0, a0, 1  # moves pointer a0
        lb a1, 0(a0)    # a1 = byte (from memory address a0 + 0)
                        #    = current byte of str
        li a2, ' '
        beq a1, a2, ignore_whitespace
        li a2, '\t'
        beq a1, a2, ignore_whitespace
        li a2, '\n'
        beq a1, a2, ignore_whitespace
        li a2, 0x0b # '\v'
        beq a1, a2, ignore_whitespace
        li a2, 0x0c # '\f'
        beq a1, a2, ignore_whitespace
        li a2, '\r'
        beq a1, a2, ignore_whitespace
        li a2, 0
        beq a1, a2, invalid_number

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

    invalid_number:
        li a0, 0

    end_atoi:
        # returns integer n if valid
        # or 0 if invalid
        ret


# Convert integer to string (non-standard function)
# Converts an integer value to a null-terminated string using the specified base.
# Stores the result in the array given by str parameter.
# If base is 10 and value is negative, the resulting string is preceded with a minus sign (-).
# With any other base, value is always considered unsigned.
# char *itoa ( int value, char *str, int base )
itoa:
    # Parameters:
    # a0 (value): Value (n) to be converted to a string
    # a1 (str): Pointer to array in memory where to store the resulting null-terminated string
    # a2 (base): Numerical base used to represent the value as a string (10 or 16)
    
    mv t1, a1
    li a5, 0    # a5 = number of digits in n

    # # -------------------------------------------- #
    # # --- Storing the begining of str on stack --- #
    # # -------------------------------------------- #
    # addi sp, sp, -4
    # sw a1, 0(sp)

    # ---------------------------- #
    # --- Checking if (n == 0) --- #
    # ---------------------------- #
    li a3, '0'
    sb a3, 0(a1)
    addi a1, a1, 1  # updates the pointer a1
    beqz a0, end_itoa
    addi a1, a1, -1 # updates the pointer a1
                    # basically ignores what was added

    # --------------------------- #
    # --- Checking if (n < 0) --- #
    # --------------------------- #
    li a3, 16
    beq a2, a3, LOOP_stack_up_int # if a2 == a3 then LOOP_stack_up_int

    bge a0, zero, LOOP_stack_up_int # if a0 >= zero then LOOP_stack_up_int
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
        
        # # ------------------------------------- #
        # # --- Restoring the begining of str --- #
        # # ------------------------------------- #
        # lw a0, 0(sp)    # a0 = begining of str
        # addi sp, sp, 4  # Updates stack

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

    # ------------------------------- #
    # --- Reversing string (str1) --- #
    # ------------------------------- #
    # --- Getting size of str1 --- #
    mv t1, a0       # t1 = begining of the original string
    mv t2, a1       # t2 = begining of the reversed string
    jal find_null   # a0 points to '\0'
    sub t3, a0, t1  # t3 = size of string
    addi t1, a0, -1 # t1 = a0 - 1 = end of string

    # --- Coping to str2 --- #
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
        
    reversed:
    li t4, 0
    sb t4, 0(t2)
    mv a0, a1
    # ------------------------------------- #
    # --- Recovering ra value on stack --- #
    # ------------------------------------- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# main

main:
#     la a0, buffer
#     jal gets
#     jal atoi
#     li t1, 1
#     beq a0, t1, operation_1 # if a0 == t1 then operation_1
#     li t1, 2
#     beq a0, t1, operation_2 # if a0 == t1 then operation_2
#     li t1, 3
#     beq a0, t1, operation_3 # if a0 == t1 then operation_3
#     li t1, 4
#     beq a0, t1, operation_4 # if a0 == t1 then operation_4
#     j end_main
    
#     operation_1:
#         # --- Reading string --- #
#         la a0, buffer
#         jal gets
#         # --- Printing string --- #
#         jal puts
#         # --- End --- #
#         j end_main
    operation_2:
        # --- Reading string --- #
        la a0, buffer
        jal gets
        # --- Reversing string --- #
        la a1, aux
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

    end_main:
        la a0, end
        jal puts
        j exit


.data
buffer: .string "ola\n"
aux: .string "............"
end: .string "finished\n"