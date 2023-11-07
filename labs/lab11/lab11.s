.text
.globl _start
.set MEMORY_SPACE, 0xFFFF0100
.set X_FINAL, 73
.set Y_FINAL, 1
.set Z_FINAL, -19

_start:
    j main


exit:
    li a7, 93       # a7: syscall exit (93)
    ecall


set_gps:
    # base + 0x00
    # Storing “1” triggers the GPS device to start reading
    li t1, MEMORY_SPACE
    li a1, 1
    sb a1, 0(t1)
    ret


get_gps:
    # base + 0x00
    # Checking if the GPS already got all the info needed
    # Busy Waiting
    # The value on t1 is set to 0 when the reading is completed
    li t1, MEMORY_SPACE
    lb a1, 0(t1)
    bnez a1, get_gps
    ret


get_coordinates:
    # Gets the current position of the car
    # Parameters:
    # a0 (x-axis): address of the variable that will store the value of x-position
    # a1 (y-axis): address of the variable that will store the value of y-position
    # a2 (z-axis): address of the variable that will store the value of z-position
    li t1, MEMORY_SPACE
    
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
    sw t2, 0(a1)
    
    ret


move:
    # Sets engine and steering
    # Parameters:
    # a0 (dir): Movement direction (foward = 1 or backward = -1 or off = 0)
    # a1 (wheel): Steering wheel angle (value between -127 and 127)
    li t1, MEMORY_SPACE
    
    # -------------- #
    # --- Engine --- #
    # -------------- #
    # base + 0x21
    # Sets the engine direction
    # foward = 1 | off = 0 | backward = -1
    sb a0, 0x21(t1)

    # -------------------------------------------- #
    # --- Setting the steering wheel direction --- #
    # -------------------------------------------- #
    # base + 0x20
    # Negative values indicate steering to the left
    # Positive values indicate steering to the right
    sb a1, 0x20(t1)
    
    ret


set_handbreak:
    # Parameters:
    # a0 (setter): value stating if the handbreak must be used
    # enable = 1 | disable = 0
    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # Storing “1” enables the hand break
    li t1, MEMORY_SPACE
    sb a0, 0x22(t1)
    ret


main:
    # ----------- #
    # --- GPS --- #
    # ----------- #
    # Getting all the information from the GPS device
    jal set_gps
    jal get_gps

    check_z:
        # ------------------------------- #
        # --- Checking the Z position --- #
        # ------------------------------- #
        la a0, x_position
        la a1, y_position
        la a2, z_position
        jal get_coordinates     # a2 = address of current z-position
        lw a0, 0(a2)            # a0 = current z-position
        li a1, Z_FINAL          # a1 = final z-position
        bge a0, a1, end_main    # if a0 >= a1 then end_main
        # Setting handbreak to disabled
        li a0, 0
        jal set_handbreak
        # Going foward and setting steering wheel
        li a0, 1    # go foward
        li a1, -17  # go left
        jal move

    LOOP:
        jal set_gps
        jal get_gps
        la a0, x_position
        la a1, y_position
        la a2, z_position
        jal get_coordinates     # a2 = address of current z-position
        lw a0, 0(a2)            # a0 = current z-position
        li a1, Z_FINAL          # a1 = final z-position
        addi a1, a1, -16        # a1 = (final z-position) - 16
        bge a0, a1, end_main    # if a0 >= a1 then end_main
        j LOOP

    end_main:
        # Powering off the engine
        li a0, 0    # stop moving
        li a1, 0    # stop steering
        jal move
        # Setting handbreak to enabled
        li a0, 1
        jal set_handbreak
        j exit

.data
.align 2
x_position: .word
.align 2
y_position: .word
.align 2
z_position: .word