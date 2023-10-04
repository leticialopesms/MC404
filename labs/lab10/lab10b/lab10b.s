.text
.globl _start
.globl read
.globl open
.globl close
.globl write
.globl find_eof
.globl find_null

.globl exit
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl linked_list_search
.globl recursive_tree_search


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
    li a2, 31               # a2 = 31
    blt a1, a2, found_eof   # if a1 < a2 then found_eof
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
gets:
    # Parameters:
    # a0 (str): Pointer to a block of memory (array of char) where the string read is copied as a C string
    mv t1, a0   # t1 = pointer to str
    
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # --- Calling the read funtion --- #
    li a0, 0    # a0: file descriptor (stdin = 0)
    mv a1, t1   # a1: buffer
    li a2, 100  # a2: size (bytes)
    jal read

    # --- Reaching the '\n' character --- #
    mv a0, t1
    jal find_eof
    # Now, a0 points to '\n'

    # --- Adding the null character '\0' --- #
    li a1, 0
    sb a1, 0(a0)

    # --- Restoring the begining of str --- #
    mv a0, t1

    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# Write string to stdout
# Writes the C string pointed by str to the standard output (stdout) and appends a newline character ('\n').
# The function begins copying from the address specified (str) until it reaches the terminating null character ('\0').
# This terminating null-character is not copied to the stream.
puts:
    # Parameters:
    # a0 (str): Pointer to C string to be printed
    mv t1, a0   # t1 = pointer to str
    
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)

    # --- Reaching the '\0' character --- #
    mv a0, t1
    jal find_null
    # Now, a0 points to '\0'

    # --- Adding the newline character '\n' --- #
    li a1, '\n'
    sb a1, 0(a0)

    # --- Restoring the begining of str --- #
    mv t2, a0       # t2 = end of string
    addi t3, t2, 1
    sub t3, t3, t1  # t3 = size of str

    # --- Calling the write funtion --- #
    li a0, 1    # a0: file descriptor (stdout = 1)
    mv a1, t1   # a1: buffer
    mv a2, t3   # a2: size (bytes)
    jal write

    # --- Restoring the null character '\0' --- #
    mv a0, t2
    li a1, 0
    sb a1, 0(a0)

    # --- Restoring the begining of str --- #
    mv a0, t1

    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# Convert string to integer
# Parses the C-string str interpreting its content as an integral number, which is returned as a value of type int.
# The function first discards as many whitespace characters (as in isspace) as necessary until the first non-whitespace character is found.
# Then, starting from this character, takes an optional initial plus or minus sign followed by as many base-10 digits as possible, and interprets them as a numerical value.
# The string can contain additional characters after those that form the integral number, which are ignored and have no effect on the behavior of this function.
# If the first sequence of non-whitespace characters in str is not a valid integral number, or if no such sequence exists because either str is empty or it contains only whitespace characters, no conversion is performed and zero is returned.
atoi:
    # Parameters:
    # a0 (str): Pointer to C string beginning with the representation of an integral number
    mv t1, a0       # t1 = pointer to str
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
itoa:
    # Parameters:
    # a0 (value): Value (n) to be converted to a string
    # a1 (str): Pointer to array in memory where to store the resulting null-terminated string
    # a2 (base): Numerical base used to represent the value as a string (10 or 16)
    
    mv t1, a1
    li a5, 0    # a5 = number of digits in n

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
        addi a3, a3, 39     # else considers letters 'a' to 'f'
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


# int recursive_tree_search (Node *root, int val)
recursive_tree_search:
    # a0: Pointer to root_node
    # a1: value
    li a7, 0            # a7 = bool
    # --------------------------------- #
    # --- Storing ra value on stack --- #
    # --------------------------------- #
    addi sp, sp, -16    # Allocates the routine frame
    sw ra, 0(sp)        # Saves the return address

    # -------------------------------------- #
    # --- Loading the current node value --- #
    # -------------------------------------- #
    lw a2, 0(a0)        # a2 = VAL

    # ------------------------------ #
    # --- Checking if (n == VAL) --- #
    # ------------------------------ #
    beq a1, a2, found   # if a1 == a2 then found
    j left_node         # else updates depth

    # -------------------------- #
    # --- Checking left node --- #
    # -------------------------- #
    left_node:
        addi a0, a0, 4              # Updates pointer a0
        sw a0, 4(sp)                # Saves the pointer (a0) on the routine frame
        lw a0, 0(a0)                # Loads the address of the left node
        beqz a0, right_node         # if a0 == 0 then left_node == NULL
        jal recursive_tree_search   # Performs the recursive call
        beqz a7, right_node         # if a7 == 0 (not found yet) then right_node
        addi a7, a7, 1              # else (found) updates depth (a7)
        j end_tree_search

    # --------------------------- #
    # --- Checking right node --- #
    # --------------------------- #
    right_node:
        lw a0, 4(sp)                # Loads the previous pointer (a0)
        
        addi a0, a0, 4              # Updates pointer a0
        sw a0, 4(sp)                # Saves the pointer (a0) on the routine frame
        lw a0, 0(a0)                # Loads the address of the right node
        beqz a0, not_found          # if a0 == 0 then right_node == NULL
        jal recursive_tree_search   # Performs the recursive call
        beqz a7, not_found          # if a7 == 0 then not_found (in this branch)
        addi a7, a7, 1              # else (found) updates depth (a7)
        j end_tree_search

    end_tree_search:
        # ----------------------------------- #
        # --- Restoring ra value on stack --- #
        # ----------------------------------- #
        mv a0, a7       # Moves a7 to a0 (ret value)
        lw ra, 0(sp)
        addi sp, sp, 16
        ret
        # a0 = function ret = depth
    not_found:
        j end_tree_search
    found:
        li a7, 1
        j end_tree_search

