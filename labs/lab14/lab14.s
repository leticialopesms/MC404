.section .text
.set base_CAR, 0xFFFF0100
.set X_FINAL, 73
.set Y_FINAL, 1
.set Z_FINAL, -19
.globl _start
.globl control_logic


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

    la t0, user_main    # Loads the user software
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
    sw t1, 32(sp)           # saves t1
    sw t2, 36(sp)           # saves t2

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
        li t2, 11                   # a2 = EXCCODE 11 = Machine external interrupt
        beq t1, t2, external_isr    # if a1 == a2 then external_isr
                                    # if (mcause.EXCCODE == 11) then external_isr
        j end_interrupt

        # --- Handling the external interrupt --- #
        external_isr: # TODO

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
            jal car_peripheral

        end_exception:
            csrr t0, mepc   # load return address (address of the instruction that invoked the syscall)
            addi t0, t0, 4  # adds 4 to the return address (to return after ecall)
            csrw mepc, t0   # stores the return address back on mepc
            j end_main_isr


    # ----------------------------- #
    # --- Restoring the context --- #
    # ----------------------------- #
    end_main_isr:
    lw t2, 36(sp)           # restores t2
    lw t1, 32(sp)           # restores t1
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
car_peripheral:
    li t1, base_CAR
    set_gps:
        # base + 0x00
        # Storing “1” triggers the GPS device to start reading
        li t2, 1
        sb t2, 0(t1)

    get_gps:
        # base + 0x00
        # Checking if the GPS already got all the info needed
        # Busy Waiting
        # The value on t1 is set to 0 when the reading is completed
        lb t2, 0(t1)
        bnez t2, get_gps

    # --- Checking operation --- #
    li t0, 10
    beq a7, t0, move    # if a7 == 10 then move    
    li t0, 11
    beq a7, t0, set_handbreak   # if a7 == 11 then set_handbreak
    li t0, 15
    beq a7, t0, get_coordinates # if a7 == 15 then get_coordinates
    j end_car_peripheral

    move:
        # Sets engine and steering
        # Parameters:
        # a0 (dir): Movement direction (foward, backward or off)
        # a1 (angle): Steering wheel angle (value between -127 and 127)
        # -------------- #
        # --- Engine --- #
        # -------------- #
        # base + 0x21
        # foward = 1 | off = 0 | backward = -1
        sb a0, 0x21(t1)
        # -------------------------------------------- #
        # --- Setting the steering wheel direction --- #
        # -------------------------------------------- #
        # base + 0x20
        # Negative values indicate steering to the left
        # Positive values indicate steering to the right
        sb a1, 0x20(t1)
        j end_car_peripheral

    set_handbreak:
        # Enables ou disable handbreak
        # Parameters:
        # a0 (setter): value stating if the handbreak must be used (Storing “1” enables the hand break)
        # enable = 1 | disable = 0
        # ------------------ #
        # --- Hand break --- #
        # ------------------ #
        # base + 0x22
        # enable = 1 | disable = 0
        sb a0, 0x22(t1)
        j end_car_peripheral

    get_coordinates:
        # Gets the current position of the car
        # Parameters:
        # a0 (x-axis): address of the variable that will store the value of x-position
        # a1 (y-axis): address of the variable that will store the value of y-position
        # a2 (z-axis): address of the variable that will store the value of z-position
        # -------------------------- #
        # --- Getting X-position --- #
        # -------------------------- #
        # base + 0x10
        # Storing the X-axis of the car current position
        lw t2, 0x10(t1)
        sw t2, 0(a0)
        # -------------------------- #
        # --- Getting Y-position --- #
        # -------------------------- #
        # base + 0x14
        # Storing the Y-axis of the car current position
        lw t2, 0x14(t1)
        sw t2, 0(a1)
        # -------------------------- #
        # --- Getting Z-position --- #
        # -------------------------- #
        # base + 0x18
        # Storing the Z-axis of the car current position
        lw t2, 0x18(t1)
        sw t2, 0(a2)
        j end_car_peripheral

    end_car_peripheral:
        ret


# ------------------------------------------------------------------------------------------------------ #
# -------------------------------------------- Car Syscalls -------------------------------------------- #
# ------------------------------------------------------------------------------------------------------ #

Syscall_set_engine_and_steering:
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

Syscall_set_handbreak:
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

Syscall_get_position:
    # --- Storing ra value on stack --- #
    # Code: 15
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, x_position
    la a1, y_position
    la a2, z_position
    li a7, 15
    ecall
    # --- Recovering ra value on stack --- #
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# ------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- Control Logic -------------------------------------------- #
# ------------------------------------------------------------------------------------------------------- #
control_logic:
    # ------------------------------- #
    # --- Checking the Z position --- #
    # ------------------------------- #
    jal Syscall_get_position
    lw a0, 0(a2)            # a0 = current z-position
    li a1, Z_FINAL          # a1 = final z-position
    bge a0, a1, end_control # if a0 >= a1 then end_control
    # Setting handbreak to disabled
    li a0, 0
    jal Syscall_set_handbreak
    # Going foward and setting steering wheel
    li a0, 1    # go foward
    li a1, -17  # go left
    jal Syscall_set_engine_and_steering

    LOOP:
        jal Syscall_get_position
        lw a0, 0(a2)            # a0 = current z-position
        li a1, Z_FINAL          # a1 = final z-position
        addi a1, a1, -17        # a1 = (final z-position) - 16
        bge a0, a1, end_control    # if a0 >= a1 then end_control
        j LOOP

    end_control:
        # Powering off the engine
        li a0, 0    # stop moving
        li a1, 0    # stop steering
        jal Syscall_set_engine_and_steering
        # Setting handbreak to enabled
        li a0, 1
        jal Syscall_set_handbreak


.section .data
.align 4
x_position: .word 0
.align 4
y_position: .word 0
.align 4
z_position: .word 0

.section .data
.align 4
program_stack:  .skip 0x100
program_stack_end:
.align 4
isr_stack:      .skip 0x100
isr_stack_end:
