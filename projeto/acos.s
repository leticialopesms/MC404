.section .text
# base address of General Purpose Timer
.set base_GPT,  0xFFFF0100
# base address of the Car Simulator
.set base_CAR, 0xFFFF0300
# base address of Serial port
.set base_SERIAL, 0xFFFF0500

.globl _start
_start:
    # ---------------------------------------------------- #
    # --- Registering the interrupt service routine(s) --- #
    # ---------------------------------------------------- #
    la t0, main_isr     # Loads the main_isr routine address into t0
    csrw mtvec, t0      # Copy t0 value into mtvec CSR

    # ----------------------------- #
    # --- Setting-up the stacks --- #
    # ----------------------------- #
    # User stack
    li sp, 0x07FFFFFC
    # System stack
    la t0, system_stack_end
    csrw mscratch, t0

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

    # ----------------------------------------- #
    # --- Changing to User/Application mode --- #
    # ----------------------------------------- #
    csrr t1, mstatus    # Update the mstatus.MPP
    li t2, ~0x1800      # field (bits 11 and 12)
    and t1, t1, t2      # with value 00 (U-mode)
    csrw mstatus, t1

    la t0, main         # Loads the user software
    csrw mepc, t0       # entry point into mepc
    
    # -------------------- #
    # --- Calling main --- #
    # -------------------- #
    mret    # PC <= MEPC; mode <= MPP;


main_isr:
    # -------------------------- #
    # --- Saving the context --- #
    # -------------------------- #
    csrrw sp, mscratch, sp  # exchange sp with mscratch
    addi sp, sp, -64        # allocates space at the ISR stack
    # sw a0, 0(sp)            # saves a0
    sw a1, 4(sp)            # saves a1
    sw a2, 8(sp)            # saves a2
    sw a3, 12(sp)           # saves a3
    sw a4, 16(sp)           # saves a4
    sw a5, 20(sp)           # saves a5
    sw a6, 24(sp)           # saves a6
    sw a7, 28(sp)           # saves a7
    sw t0, 32(sp)           # saves t0
    sw t1, 36(sp)           # saves t1
    sw t2, 40(sp)           # saves t2
    sw t3, 44(sp)           # saves t3

    # --------------------------------------------------------------- #
    # --- Checking if it was an INTERRUPT (1) or an EXCEPTION (0) --- #
    # --------------------------------------------------------------- #
    csrr t1, mcause             # reads the interrupt cause
    srli t1, t1, 31             # t1 = mcause.INTERRUPT
    beqz t1, handle_exception   # if t1 == 0 then handle_exception
                                # if (mcause.INTERRUPT == 0) then handle_exception

    # ------------------------------ #
    # --- Handling the interrupt --- #
    # ------------------------------ #
    handle_interrupt:
        csrr t1, mcause
        andi t1, t1, 0x3f           # Isolates the interrupt cause (bit 31)
        # --- Checks if it was a external interrupt --- #
        li t2, 11                           # t2 = EXCCODE 11 = Machine external interrupt
        beq t1, t2, handle_external_isr     # if t1 == t2 then external_isr
                                            # if (mcause.EXCCODE == 11) then external_isr
        j end_interrupt

        # --- Handling the external interrupt --- #
        handle_external_isr:
            # --- Handling GPT --- #
            j GPT_isr

        end_interrupt:
            j end_main_isr

    # ------------------------------ #
    # --- Handling the exception --- #
    # ------------------------------ #
    handle_exception:
        csrr t1, mcause
        andi t1, t1, 0x3f           # Isolates the interrupt cause (bit 31)
        # --- Checking if it was a syscall --- #
        li t2, 8                    # t2 = EXCCODE 8 = Environment call (syscall) from U-mode
        beq t1, t2, handle_syscall  # if t1 == t2 then handle_syscall
                                    # if (mcause.EXCCODE == 8) then handle_syscall
        j end_exception

        # --- Handling the syscall exception --- #
        handle_syscall:
            li t0, 10
            beq a7, t0, Syscall_set_engine_and_steering
            li t0, 11
            beq a7, t0, Syscall_set_handbrake
            li t0, 12
            beq a7, t0, Syscall_read_sensors
            li t0, 13
            beq a7, t0, Syscall_read_sensor_distance
            li t0, 15
            beq a7, t0, Syscall_get_position
            li t0, 16
            beq a7, t0, Syscall_get_rotation
            li t0, 17
            beq a7, t0, Syscall_read_serial
            li t0, 18
            beq a7, t0, Syscall_write_serial
            li t0, 20
            beq a7, t0, Syscall_get_systime

        end_exception:
            csrr t0, mepc   # load return address (address of the instruction that invoked the syscall)
            addi t0, t0, 4  # adds 4 to the return address (to return after ecall)
            csrw mepc, t0   # stores the return address back on mepc
            j end_main_isr

    # ----------------------------- #
    # --- Restoring the context --- #
    # ----------------------------- #
    end_main_isr:
    lw t3, 44(sp)           # restores t3
    lw t2, 40(sp)           # restores t2
    lw t1, 36(sp)           # restores t1
    lw t0, 32(sp)           # restores t0
    lw a7, 28(sp)           # restores a7
    lw a6, 24(sp)           # restores a6
    lw a5, 20(sp)           # restores a5
    lw a4, 16(sp)           # restores a4
    lw a3, 12(sp)           # restores a3
    lw a2, 8(sp)            # restores a2
    lw a1, 4(sp)            # restores a1
    # lw a0, 0(sp)            # restores a0
    addi sp, sp, 64         # deallocate space from the ISR stack
    csrrw sp, mscratch, sp  # exchange sp with mscratch
    mret                    # Recover remaining context (pc <- mepc)
                            # returns from the interrupt


# -------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- Car Peripheral -------------------------------------------- #
# -------------------------------------------------------------------------------------------------------- #

Syscall_set_engine_and_steering:
    # Sets engine and steering
    # Parameters:
    # a0 (dir): Movement direction (foward, backward or off)
    # a1 (angle): Steering wheel angle (value between -127 and 127)
    # ------------------ #
    # --- Validating --- #
    # ------------------ #
    # a0
    li t0, -1
    blt a0, t0, invalid_parameter
    li t0, 1
    bgt a0, t0, invalid_parameter
    # a1
    li t0, -127
    blt a1, t0, invalid_parameter
    li t0, 127
    bge a1, t0, invalid_parameter
    # --------------------------------------------- #
    # --- Getting address of the car peripheral --- #
    # --------------------------------------------- #
    li t0, base_CAR
    # -------------- #
    # --- Engine --- #
    # -------------- #
    # base + 0x21
    # foward = 1 | off = 0 | backward = -1
    sb a0, 0x21(t0)
    # -------------------------------------------- #
    # --- Setting the steering wheel direction --- #
    # -------------------------------------------- #
    # base + 0x20
    # Negative values indicate steering to the left
    # Positive values indicate steering to the right
    sb a1, 0x20(t0)
    li a0, 0
    j end_exception
    invalid_parameter:
        li a0, -1
        j end_exception


Syscall_set_handbrake:
    # Enables ou disable handbrake
    # Parameters:
    # a0 (setter): value stating if the handbrake must be used (Storing “1” enables the hand break)
    # enable = 1 | disable = 0
    # --------------------------------------------- #
    # --- Getting address of the car peripheral --- #
    # --------------------------------------------- #
    li t0, base_CAR
    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # enable = 1 | disable = 0
    sb a0, 0x22(t0)
    j end_exception


Syscall_read_sensors:
    # Read values from the luminosity sensor
    # Parameters:
    # a0 (array): address of an array with 256 elements that will store the values read by the luminosity sensor
    # --------------------------------------------- #
    # --- Getting address of the car peripheral --- #
    # --------------------------------------------- #
    li t0, base_CAR
    # --------------------- #
    # --- Capture image --- #
    # --------------------- #
    # base + 0x01
    # Storing “1” triggers the Line Camera device to capture an image
    # The register is set to 0 when the capture is completed
    li t1, 1
    sb t1, 0x01(t0)
    1:
    # Checking if the camera already got all the info needed
    # Busy Waiting
    # The value on t1 is set to 0 when the reading is completed
    lb t1, 0x01(t0)
    bnez t1, 1b
    # ---------------------------------- #
    # --- Copying image to the array --- #
    # ---------------------------------- #
    # base + 0x24
    # Stores the image captured by the Line Camera
    # Each byte represents the luminance of a pixel
    addi t0, t0, 0x24   # t0 = pointer to the sensor array
    mv t1, a0           # t1 = pointer to the given array
    li t2, 256          # t2 = counter
    copy_sensor_array:
        addi t2, t2, -1     # updates counter
        lb a1, 0(t0)        # a1 = current byte
        sb a1, 0(t1)
        addi t0, t0, 1      # updating pointer t0
        addi t1, t1, 1      # updating pointer t1
        bge t2, zero, copy_sensor_array # if t2 >= zero then copy_sensor_array
    j end_exception


Syscall_read_sensor_distance:
    # Read the value from the ultrasonic sensor that detects objects up to 20 meters in front of the car
    # --------------------------------------------- #
    # --- Getting address of the car peripheral --- #
    # --------------------------------------------- #
    li t0, base_CAR
    # ---------------------- #
    # --- Reading sensor --- #
    # ---------------------- #
    # base + 0x02
    # Storing “1” triggers the Ultrasonic Sensor device to measure the distance in front of the car
    # The register is set to 0 when the measurement is completed
    li t1, 1
    sb t1, 0x02(t0)
    1:
    # Checking if the sensor already got all the info needed
    # Busy Waiting
    # The value on t1 is set to 0 when the reading is completed
    lb t1, 0x02(t0)
    bnez t1, 1b
    # ------------------------------- #
    # --- Getting sensor distance --- #
    # ------------------------------- #
    # base + 0x1C
    # Stores the distance (in centimeters) between the Ultrasonic sensor and the nearest obstacle
    # Returns -1 if there’s no obstacle within 20m
    lw a0, 0x1C(t0)
    j end_exception


Syscall_get_position:
    # Gets the current position of the car
    # Parameters:
    # a0 (x-axis): address of the variable that will store the value of x-position
    # a1 (y-axis): address of the variable that will store the value of y-position
    # a2 (z-axis): address of the variable that will store the value of z-position
    # --------------------------------------------- #
    # --- Getting address of the car peripheral --- #
    # --------------------------------------------- #
    li t0, base_CAR
    # ------------------- #
    # --- Reading GPS --- #
    # ------------------- #
    # base + 0x00
    # Storing “1” triggers the GPS device to start reading
    li t1, 1
    sb t1, 0(t0)
    1:
    # base + 0x00
    # Checking if the GPS already got all the info needed
    # Busy Waiting
    # The value on t1 is set to 0 when the reading is completed
    lb t1, 0(t0)
    bnez t1, 1b
    # -------------------------- #
    # --- Getting X-position --- #
    # -------------------------- #
    # base + 0x10
    # Storing the X-axis of the car current position
    lw t1, 0x10(t0)
    sw t1, 0(a0)
    # -------------------------- #
    # --- Getting Y-position --- #
    # -------------------------- #
    # base + 0x14
    # Storing the Y-axis of the car current position
    lw t1, 0x14(t0)
    sw t1, 0(a1)
    # -------------------------- #
    # --- Getting Z-position --- #
    # -------------------------- #
    # base + 0x18
    # Storing the Z-axis of the car current position
    lw t1, 0x18(t0)
    sw t1, 0(a2)
    j end_exception


Syscall_get_rotation:
    # Read the global rotation of the car's gyroscope
    # Parameters:
    # a0 (x-angle): address of the variable that will store the value of Euler angle in x
    # a1 (y-angle): address of the variable that will store the value of Euler angle in y
    # a2 (z-angle): address of the variable that will store the value of Euler angle in z
    # --------------------------------------------- #
    # --- Getting address of the car peripheral --- #
    # --------------------------------------------- #
    li t0, base_CAR
    # ------------------- #
    # --- Reading GPS --- #
    # ------------------- #
    # base + 0x00
    # Storing “1” triggers the GPS device to start reading
    li t1, 1
    sb t1, 0(t0)
    1:
    # base + 0x00
    # Checking if the GPS already got all the info needed
    # Busy Waiting
    # The value on t1 is set to 0 when the reading is completed
    lb t1, 0(t0)
    bnez t1, 1b
    # -------------------------------- #
    # --- Getting Euler angle in x --- #
    # -------------------------------- #
    # base + 0x10
    # Storing the current X-angle of the car
    lw t1, 0x04(t0)
    sw t1, 0(a0)
    # -------------------------------- #
    # --- Getting Euler angle in y --- #
    # -------------------------------- #
    # base + 0x14
    # Storing the current Y-angle of the car
    lw t1, 0x08(t0)
    sw t1, 0(a1)
    # -------------------------------- #
    # --- Getting Euler angle in z --- #
    # -------------------------------- #
    # base + 0x18
    # Storing the current Z-angle of the car
    lw t1, 0x0C(t0)
    sw t1, 0(a2)
    j end_exception


# -------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- GPT Peripheral -------------------------------------------- #
# -------------------------------------------------------------------------------------------------------- #
Syscall_get_systime:
    # Gets the time since the system has been booted, in milliseconds
    # --------------------------------------------- #
    # --- Getting address of the GPT peripheral --- #
    # --------------------------------------------- #
    li t0, base_GPT
    # ------------------------ #
    # --- Starting reading --- #
    # ------------------------ #
    # base + 0x00
    # Storing the value 1 triggers the GPT device to start reading the current system time
    li t1, 1        # t1 = 1
    sb t1, 0(t0)    # t0 = base
    # --------------------------- #
    # --- Reading system time --- #
    # --------------------------- #
    # Busy waiting:
    # The byte at base + 0x00 is set to 0 when read is complete
    reading_time:
        lb t1, 0(t0)
        bnez t1, reading_time    # if t1 != 0 then reading_time
    # --------------------------- #
    # --- Getting system time --- #
    # --------------------------- #
    # base + 0x04
    # Stores the time (in milliseconds) at the moment of the last reading by the GPT
    lw a0, 0x04(t0)
    j end_exception


GPT_isr:
    # a0 (v): time until the next interruption
    # --------------------------------------------- #
    # --- Getting address of the GPT peripheral --- #
    # --------------------------------------------- #
    li t0, base_GPT     # t0 = address of base_GPT
    # ----------------------------------- #
    # --- Setting current system time --- #
    # ----------------------------------- #
    la t2, _system_time # t2 = address of _system_time variable
    lw t1, 0(t2)        # loading the value from _system_time
    add t1, t1, a0      # t1 = t1 + a0 ms
    sw t1, 0(t2)        # updating _system_time
    # --------------------- #
    # --- Setting timer --- #
    # --------------------- #
    # base + 0x08 (word)
    # Storing 32-bit v > 0 programs the GPT to generate an external
    # interruption after v milliseconds. It also sets this register
    # to 0 after v milliseconds (immediately before generating the
    # interruption)
    sw a0, 0x08(t0)     # stores 32 bits on memory address base_GPT + 0x08
    j end_interrupt


# -------------------------------------------------------------------------------------------------------- #
# ---------------------------------------- Serial Port Peripheral ---------------------------------------- #
# -------------------------------------------------------------------------------------------------------- #

Syscall_read_serial:
    # Parameters:
    # a0 (buffer): pointer to buffer where the string read will be stored
    # a1 (size): size of the string
    # ----------------------------------------------------- #
    # --- Getting address of the serial port peripheral --- #
    # ----------------------------------------------------- #
    li t0, base_SERIAL
    # -------------------- #
    # --- Setting LOOP --- #
    # -------------------- #
    mv t1, a1   # t1 = counter
    mv t2, a0   # t2 = address of current byte
    1:
    # ------------------------ #
    # --- Starting reading --- #
    # ------------------------ #
    # base + 0x02
    # Storing the value 1 triggers a read
    li t3, 1        # t3 = 1
    sb t3, 0x02(t0) # address = base + 0x02
    # -------------------- #
    # --- Reading byte --- #
    # -------------------- #
    # base + 0x03
    # Reading one byte and storing it at base + 0x03
    # Busy waiting:
    # The byte at base + 0x02 is set to 0 when read is complete
    reading:
        lb t3, 0x02(t0)
        bnez t3, reading    # if t3 != 0 then reading
    # -------------------- #
    # --- Storing byte --- #
    # -------------------- #
    # base + 0x03
    # Storing the byte read from base + 0x03 on buffer
    lb t3, 0x03(t0) # t3 = byte read
    sb t3, 0(t2)    # stores byte on buffer
    # --------------------- #
    # --- Checking LOOP --- #
    # --------------------- #
    addi t1, t1, -1     # updates counter t1
    addi t2, t2, 1      # updates byte address
    bgt t1, zero, 1b    # if t1 > zero then 1b
    # ------------------------------------ #
    # --- Getting number of bytes read --- #
    # ------------------------------------ #
    sub a0, t2, a0
    bnez t3, end_exception
    li a0, 0 # Returns the size of string read
    j end_exception


Syscall_write_serial:
    # Parameters:
    # a0 (buffer): pointer to buffer where the string is stored
    # a1 (size): size of the string to be written
    # ----------------------------------------------------- #
    # --- Getting address of the serial port peripheral --- #
    # ----------------------------------------------------- #
    li t0, base_SERIAL
    # -------------------- #
    # --- Setting LOOP --- #
    # -------------------- #
    mv t1, a1   # t1 = counter
    mv t2, a0   # t2 = address of current byte
    1:
    # -------------------- #
    # --- Storing byte --- #
    # -------------------- #
    # base + 0x01
    # Storing the byte from buffer to be wrtitten at base + 0x01
    lb t3, 0(t2)    # t3 = byte to be written
    sb t3, 0x01(t0) # stores byte on base + 0x01
    # ------------------------ #
    # --- Starting writing --- #
    # ------------------------ #
    # base + 0x00
    # Storing the value 1 triggers a write
    li t3, 1        # t3 = 1
    sb t3, 0x00(t0) # address = base + 0x00
    # -------------------- #
    # --- Writing byte --- #
    # -------------------- #
    # base + 0x01
    # Writing the byte that is stored at base + 0x01
    # Busy waiting:
    # The byte at base + 0x00 is set to 0 when write is complete
    writing:
        lb t3, 0(t0)
        bnez t3, writing    # if t3 != 0 then writing
    # --------------------- #
    # --- Checking LOOP --- #
    # --------------------- #
    addi t1, t1, -1     # updates counter t1
    addi t2, t2, 1      # updates byte address
    bgt t1, zero, 1b    # if t1 > zero then 1b
    # --------------------------------------- #
    # --- Getting number of bytes written --- #
    # --------------------------------------- #
    sub a0, t2, a0 # Returns the size of string written
    j end_exception


.section .data
.align 4
_system_time: .word 0

.section .bss
.align 4
system_stack: .skip 0x100
system_stack_end: