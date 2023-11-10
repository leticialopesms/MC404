.section .text

.globl set_engine
.globl set_handbrake
.globl read_sensor_distance
.globl get_position
.globl get_rotation
.globl read
.globl write
.globl get_time
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl strlen_custom
.globl approx_sqrt
.globl get_distance
.globl fill_and_pop

# ------------------------------------------------------------------------------------------------------ #
# ------------------------------------------- Car Peripheral ------------------------------------------- #
# ------------------------------------------------------------------------------------------------------ #

set_engine:
    # Code: 10
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 10
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


set_handbrake:
    # Code: 11
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 11
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


read_sensor_distance:
    # Code: 13
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 13
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


get_position:
    # Code: 15
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 15
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


get_rotation:
    # Code: 16
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 16
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ------------------------------------------------------------------------------------------------------ #
# --------------------------------------- Serial Port Peripheral --------------------------------------- #
# ------------------------------------------------------------------------------------------------------ #

read:
    # Code: 17
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 17
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


write:
    # Code: 18
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 18
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ------------------------------------------------------------------------------------------------------ #
# ------------------------------------------- GPT Peripheral ------------------------------------------- #
# ------------------------------------------------------------------------------------------------------ #

get_time:
    # Code: 20
    # --- Storing ra value on stack --- #
    addi sp, sp, -4
    sw ra, 0(sp)
    li a7, 20
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ Utility Functions ------------------------------------------ #
# ------------------------------------------------------------------------------------------------------- #

# Write string to stdout
# void puts (const char *str)
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
    # ---------------------------------------------------- #
    # --- Storing the current position of str on stack --- #
    # ---------------------------------------------------- #
    addi sp, sp, -4
    sw a0, 0(sp)
    # ------------------------- #
    # --- Writing on buffer --- #
    # ------------------------- #
    1:
        # --- Getting current byte --- #
        lb a1, 0(a0)    # a1 = byte from 'a0 + 0' memory position
        # --- Checking if '\0' (null) was found --- #
        beqz a1, end_puts    # if a1 == 0 then end_puts
        # --- Calling the write funtion --- #
        # a0: buffer
        # a1: size (bytes)
        li a1, 1
        jal write
        # --- Restoring current position on stack --- #
        lw a0, 0(sp)    # a0 = adress of current byte
        # --- Storing next position of str on stack --- #
        addi a0, a0, 1  # updates a0 pointer
        sw a0, 0(sp)    # stores a0 on stack
        j 1b

    end_puts:
        # --------------------- #
        # --- Printing '\n' --- #
        # --------------------- #
         # --- Adding the newline character '\n' --- #
        li a1, '\n'     # a1 = 10
        sb a1, 0(a0)    # stores a1 on 'a0 + 0' memory position
        # --- Calling the write funtion --- #
        # a0: buffer
        # a1: size (bytes)
        li a1, 1
        jal write
        # -------------------------------------------- #
        # --- Updating the current position of str --- #
        # -------------------------------------------- #
        lw a0, 0(sp)        # a0 = end of str (points to null)
        addi sp, sp, 4      # updates stack
        # -------------------------------------- #
        # --- Adding the null character '\0' --- #
        # -------------------------------------- #
        li a1, 0        # a1 = 0
        sb a1, 0(a0)    # stores a1 on 'a0 + 0' memory position
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


# Get string from stdin
# char *gets (char *str)
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
        # --- Calling the read funtion --- #
        # a0: buffer
        # a1: size (bytes)
        li a1, 1
        jal read
        # --- Restoring current position on stack --- #
        lw a0, 0(sp)    # a1 = adress of current byte
        # --- Getting current byte --- #
        lb a1, 0(a0)    # a1 = byte from 'a0 + 0' memory position
        li a2, '\n'     # a2 = 10
        # --- Checking if '\n' was found --- #
        beq a1, a2, end_gets    # if a1 == a2 then end_gets
        # --- Storing next position of str on stack --- #
        addi a0, a0, 1  # updates a0 pointer
        sw a0, 0(sp)    # stores a0 on stack
        j 1b

    end_gets:
        # -------------------------------------------- #
        # --- Updating the current position of str --- #
        # -------------------------------------------- #
        lw a0, 0(sp)        # a0 = end of str (points to '\n')
        addi sp, sp, 4      # updates stack
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
    ignore_whitespace:
        lb t1, 0(a0)    # t1 = current byte (from memory address a0 + 0)
        addi a0, a0, 1  # updates pointer a0
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
        beq t1, t2, end_atoi
        addi a0, a0, -1

    beqz t1, end_atoi   # if t1 == 0 then end_atoi
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
        # Returns integer n if valid
        # or 0 if invalid
        ret


# Convert integer to string (non-standard function)
# char *itoa (int value, char *str, int base )
itoa:
    # Parameters:
    # a0 (value): Value (n) to be converted to a string
    # a1 (str): Pointer to array in memory where to store the resulting null-terminated string
    # a2 (base): Numerical base used to represent the value as a string (10 or 16)
    mv t1, a1   # t1 = pointer to str
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
        addi a3, a3, 7      # else considers letters 'A' to 'F'

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
        # Now a1 points to '\0'
        mv a0, t1
        # Returns a pointer to the string
        ret


# Get the size of the string without counting the \0
# int strlen_custom(char *str)
strlen_custom:
    # Parameters:
    # a0 (str): String terminated by \0
    mv t0, a0
    1:
    li t2, 0        # t2 = 0
    lb t1, 0(t0)    # t1 = byte from the memory address a0 + 0
    addi t0, t0, 1  # updates pointer t0
    bne t1, t2, 1b  # if t1 != t2 then 1b
    addi t0, t0, -1 # updates pointer t0 (now points to \0)
    sub a0, t0, a0  # a0 = t0 - a0
    ret


# Calculates approximate Square Root computation using the Babylonian Method
# int approx_sqrt(int value, int iterations)
approx_sqrt:
    # Parameters:
    # a0 (value): integer value
    # a1 (iterations): number of iterations to perform the Babylonian method
    # a0 = y
    # t0 = k
    # t1 = y/k
    # t2 = k'
    srli t0, a0, 1  # t0 = k = y/2
    1:
    divu t1, a0, t0 # t1 = y/k
    add t2, t0, t1  # t2 = k + y/k
    srli t2, t2, 1  # t2 = k' = (k + y/k)/2
    mv t0, t2       # t0 = k = k'
    addi a1, a1, -1 # updates counter a1
    bnez a1, 1b     # if a1 != 0 then 1b
    mv a0, t0
    ret


# Euclidean Distance between two points, A and B, in a 3D space
# int get_distance(int x_a, int y_a, int z_a, int x_b, int y_b, int z_b)
get_distance:
    # Parameters:
    # a0 (x_a): X coordinate of point A.
    # a1 (y_a): Y coordinate of point A.
    # a2 (z_a): Z coordinate of point A.
    # a3 (x_b): X coordinate of point B.
    # a4 (y_b): Y coordinate of point B.
    # a5 (z_b): Z coordinate of point B.
    li t0, 0    # t0 = D = d^2
    # --------------------------------- #
    # --- Storing ra value on stack --- #
    # --------------------------------- #
    addi sp, sp, -4
    sw ra, 0(sp)
    # ----------------------------- #
    # --- Getting (x_a - x_b)^2 --- #
    # ----------------------------- #
    sub t1, a0, a3  # t1 = (a0 - a3) = (x_a - x_b)
    mul t1, t1, t1  # t1 = (x_a - x_b)^2
    add t0, t0, t1  # t0 = t0 + t1
    # ----------------------------- #
    # --- Getting (y_a - y_b)^2 --- #
    # ----------------------------- #
    sub t1, a1, a4  # t1 = (a1 - a4) = (y_a - y_b)
    mul t1, t1, t1  # t1 = (y_a - y_b)^2
    add t0, t0, t1  # t0 = t0 + t1
    # ----------------------------- #
    # --- Getting (z_a - z_b)^2 --- #
    # ----------------------------- #
    sub t1, a2, a5  # t1 = (a2 - a5) = (z_a - z_b)
    mul t1, t1, t1  # t1 = (z_a - z_b)^2
    add t0, t0, t1  # t0 = t0 + t1
    # ------------------------------- #
    # --- Calculating d = sqrt(D) --- #
    # ------------------------------- #
    mv a0, t0   # a0: value
    li a1, 40   # a1: iterations
    jal approx_sqrt
    # ------------------------------------ #
    # --- Recovering ra value on stack --- #
    # ------------------------------------ #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# Copies all fields from the head node to the fill node and returns the next node on the linked list (head->next).
# Node *fill_and_pop(Node *head, Node *fill)
fill_and_pop:
    # Parameters:
    # a0 (head): current head of the linked list
    # a1 (fill): node struct to be filled with values from the current head node
    # ---------------------- #
    # --- Copying fields --- #
    # ---------------------- #
    mv t0, a0
    mv t1, a1
    1:
    lw t2, 0(t0)
    sw t2, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    sub t2, t0, a0
    li t3, 32
    bne t2, t3, 1b  # if t2 != t3 then 1b
    # ------------------------ #
    # --- Poping head node --- #
    # ------------------------ #
    lw a0, 28(a0)
    ret