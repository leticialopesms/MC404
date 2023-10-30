.section .text
# base address of General Purpose Timer
.set base_GPT,  0xFFFF0100
# base address of MIDI Synthesizer
.set base_MIDI, 0xFFFF0300

.globl play_note
.globl _system_time
.globl _start


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
    # Returns the position of '\n'
    ret


find_null:
    # Parameters:
    # a0: pointer to a string
    lb a1, 0(a0)            # a1 = byte from the memory address a0 + 0
    li a2, 0                # a2 = 0
    addi a0, a0, 1          # Updates pointer a0
    bne a1, a2, find_null   # if a1 != a2 then find_null
    addi a0, a0, -1         # Updates pointer a0
    # Returns the position of '\0'
    ret


find_space:
    # Parameters:
    # a0: pointer to a string
    lb a1, 0(a0)            # a1 = byte from the memory address a0 + 0
    li a2, ' '              # a2 = 32
    addi a0, a0, 1          # Updates pointer a0
    bne a1, a2, find_space  # if a1 != a2 then find_space
    addi a0, a0, -1         # Updates pointer a0
    # Returns the position of ' '
    ret


# Get string from stdin
# char *gets (char *str )
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
        lb a2, 0(a1)    # a2 = byte from 'a1 + 0' memory position
        li a3, '\n'     # a3 = 10

        # --- Checking if '\n' was found --- #
        beq a2, a3, end_gets    # if a2 == a3 then end_gets

        # --- Storing next position of str on stack --- #
        addi a1, a1, 1  # updates a1 pointer
        sw a1, 0(sp)    # stores a1 on stack
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


# Write string to stdout
# void puts (const char *str )
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
        # --- Restoring current position on stack --- #
        lw a1, 0(sp)    # a1 = adress of current byte

        # --- Getting current byte --- #
        lb a2, 0(a1)    # a2 = byte from 'a1 + 0' memory position
        li a3, 0        # a3 = 0

        # --- Checking if '\0' (null) was found --- #
        beq a2, a3, end_puts    # if a2 == a3 then end_puts

        # --- Calling the write funtion --- #
        li a0, 1        # a0: file descriptor (stdout = 1)
                        # a1: buffer
        li a2, 1        # a2: size (bytes)
        jal write

        # --- Storing next position of str on stack --- #
        addi a1, a1, 1  # updates a1 pointer
        sw a1, 0(sp)    # stores a1 on stack
        j 1b

    end_puts:
        # -------------------------------------------- #
        # --- Updating the current position of str --- #
        # -------------------------------------------- #
        lw a1, 0(sp)        # a1 = end of str (points to null)
        addi sp, sp, 4      # updates stack

        # --------------------- #
        # --- Printing '\n' --- #
        # --------------------- #
         # --- Adding the newline character '\n' --- #
        li a2, '\n'     # a2 = 10
        sb a2, 0(a1)    # stores a2 on 'a1 + 0' memory position

        # --- Calling the write funtion --- #
        li a0, 1        # a0: file descriptor (stdout = 1)
                        # a1: buffer
        li a2, 1        # a2: size (bytes)
        jal write

        # --- Adding the null character '\0' --- #
        li a2, 0        # a2 = 0
        sb a2, 0(a1)    # stores a2 on 'a1 + 0' memory position

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
        # Now a1 points to '\0'
        mv a0, t1

        # Returns a pointer to the string
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


_start:
    # ---------------------------------------------------- #
    # --- Registering the interrupt service routine(s) --- #
    # ---------------------------------------------------- #
    la t0, main_isr     # Loads the main_isr routine address into t0
    csrw mtvec, t0      # Copy t0 value into mtvec CSR

    # ----------------------------- #
    # --- Setting-up the stacks --- #
    # ----------------------------- #
    # Program stack
    la t0, program_stack_end
    mv sp, t0
    # ISR stack
    la t0, isr_stack_end
    csrw mscratch, t0

    # ------------------------------ #
    # --- Setting GPT peripheral --- #
    # ------------------------------ #
    li t0, base_GPT # t0 = address of base_GPT

    # --- Setting initial time --- #
    # base + 0x04 (word)
    # Stores the time (in milliseconds) at the moment of the last
    # reading by the GPT.
    li t1, 0        # t1 = 0
    sw t1, 4(t0)    # stores 32 bits on memory address base_GPT + 0x04

    # --- Setting timer --- #
    # base + 0x08 (word)
    # Storing 32-bit v > 0 programs the GPT to generate an external
    # interruption after v milliseconds. It also sets this register
    # to 0 after v milliseconds (immediately before generating the
    # interruption).
    li t1, 100      # t1 = 100 ms
    sw t1, 8(t0)    # stores 32 bits on memory address base_GPT + 0x08

    # ---------------------------- #
    #  --- Enabling interrupts --- #
    # ---------------------------- #
    # Enables external interrupts (mie.MEIE <= 1)
    csrr t0, mie        # read the mie register
    li t1, 0x800        # t1 = 0x800 = 2048 = 2^11 = bit 11
    or t0, t0, t1       # set the MEIE field (bit 11)
    csrw mie, t0        # update the mie register

    # Enables global interrupts (mstatus.MIE <= 1)
    csrr t0, mstatus    # read the mstatus register
    li t1, 0x8          # t1 = 0x8 = 8 = 2^3 = bit 3
    or t0, t0, t1       # set MIE field (bit 3)
    csrw mstatus, t0    # update the mstatus register

    # -------------------- #
    # --- Calling main --- #
    # -------------------- #
    li a0, 0
    jal main
    # if exit is called, then there is a problem in the code
    # the song is supposed to play on repeat
    j exit


exit:
    li a0, 0
    li a7, 93       # a7: syscall exit (93)
    ecall


main_isr:
    # -------------------------- #
    # --- Saving the context --- #
    # -------------------------- #
    csrrw sp, mscratch, sp  # exchange sp with mscratch
    addi sp, sp, -64        # allocates space at the ISR stack
    sw a0, 0(sp)            # saves a0
    sw a1, 4(sp)            # saves a1
    sw a2, 8(sp)            # saves a2
    sw a3, 12(sp)           # saves a3
    sw a4, 16(sp)           # saves a4
    sw a5, 20(sp)           # saves a5
    sw a6, 24(sp)           # saves a6
    sw a7, 28(sp)           # saves a7

    # ----------------------------------------------------------------- #
    # --- # Checking if it was an INTERRUPT (1) or an EXCEPTION (0) --- #
    # ----------------------------------------------------------------- #
    csrr a1, mcause             # reads the interrupt cause
    beqz a1, handle_exception   # if a1 == 0 then handle_exception
                                # if (mcause.INTERRUPT == 0) handle_exception

    # ------------------------------ #
    # --- Handling the interrupt --- #
    # ------------------------------ #
    handle_interrupt:
    andi a1, a1, 0x3f           # Isolates the interrupt cause (bit 31)
    # --- Checks if it was a external interrupt --- #
    li a2, 11                   # a2 = EXCCODE 11 = Machine external interrupt
    beq a1, a2, external_isr    # if a1 == a2 then external_isr
                                # if (mcause.EXCCODE == 11) then external_isr
    j end_main_isr

    # --- Handling the external interrupt --- #
    external_isr:
    # --- Handling GPT --- #
    jal GPT_isr
    j end_main_isr

    # ------------------------------ #
    # --- Handling the exception --- #
    # ------------------------------ #
    handle_exception:   # TO_DO

    # ----------------------------- #
    # --- Restoring the context --- #
    # ----------------------------- #
    end_main_isr:
    lw a7, 28(sp)           # restores a7
    lw a6, 24(sp)           # restores a6
    lw a5, 20(sp)           # restores a5
    lw a4, 16(sp)           # restores a4
    lw a3, 12(sp)           # restores a3
    lw a2, 8(sp)            # restores a2
    lw a1, 4(sp)            # restores a1
    lw a0, 0(sp)            # restores a0
    addi sp, sp, 64         # deallocate space from the ISR stack
    csrrw sp, mscratch, sp  # exchange sp with mscratch
    mret                    # returns from the interrupt


GPT_isr:
    li t0, base_GPT # t0 = address of base_GPT
    
    # --- Reading the current system time --- #
    # base + 0x00 (byte)
    # Storing “1” triggers the GPT device to start reading the
    # current system time. The register is set to 0 when the
    # reading is completed.
    li t1, 1
    sb t1, 0(t0)

    read_system_time:
        lb t1, 0(t0)
        bnez t1, read_system_time
    
    # --- Getting current system time --- #
    # base + 0x04 (word)
    # Stores the time (in milliseconds) at the moment of the last
    # reading by the GPT.
    lw t1, 4(t0)        # t1 = current system time
    la t2, _system_time # t2 = address of _system_time variable
    sw t1, 0(t2)        # storing the time read (t1) on _system_time

    # --- Setting timer --- #
    # base + 0x08 (word)
    # Storing 32-bit v > 0 programs the GPT to generate an external
    # interruption after v milliseconds. It also sets this register
    # to 0 after v milliseconds (immediately before generating the
    # interruption).
    li t1, 100      # t1 = 100 ms
    sw t1, 8(t0)    # stores 32 bits on memory address base_GPT + 0x08

    ret


# void play_note(int ch, int inst, int note, int vel, int dur)
play_note:
    # Parameters:
    # a0 (ch): channel in which the MIDI note will be played
    # a1 (inst): instrument ID
    # a2 (note): musical note
    # a3 (vel): note velocity
    # a4 (dur): note duration

    li t0, base_MIDI
    # ----------------------------- #
    # --- Setting instrument ID --- #
    # ----------------------------- #
    # base_MIDI + 0x02 (short)
    sh a1, 2(t0)    # stores 16 bits on memory address base_MIDI + 0x02

    # ---------------------------- #
    # --- Setting musical note --- #
    # ---------------------------- #
    # base_MIDI + 0x04 (byte)
    sb a2, 4(t0)    # stores 8 bits on memory address base_MIDI + 0x04

    # ----------------------------- #
    # --- Setting note velocity --- #
    # ----------------------------- #
    # base_MIDI + 0x05 (byte)
    sb a3, 5(t0)    # stores 8 bits on memory address base_MIDI + 0x05

    # ----------------------------- #
    # --- Setting note duration --- #
    # ----------------------------- #
    # base_MIDI + 0x06 (short)
    sh a4, 0(t0)    # stores 16 bits on memory address base_MIDI + 0x06

    # ---------------------------------- #
    # --- Triggering the synthesizer --- #
    # ---------------------------------- #
    # base_MIDI + 0x00 (byte)
    # Storing ch ≥ 0 triggers the synthesizer to start
    # playing a MIDI note in the channel ch.
    sb a0, 0(t0)

    ret     # returns ch


.section .bss

.align 4
program_stack:  .skip 0x1000  # stores 0x1000 bits = 4 Kb
program_stack_end:
.align 4
ISR_stack:      .skip 0x1000  # stores 0x1000 bits = 4 Kb
isr_stack_end:
.align 4
_system_time: .word 0
.align 4
buffer: .skip 32