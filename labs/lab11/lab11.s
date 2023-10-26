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
    addi t1, t1, 0x00
    li a1, 1
    sb a1, 0(t1)
    ret


get_gps:
    # base + 0x00
    # Checking if the GPS already got all the info needed
    # Busy Waiting
    # The value on t1 is set to 0 when the reading is completed
    li t1, MEMORY_SPACE
    addi t1, t1, 0x00
    lb a1, 0(t1)
    bnez a1, get_gps
    ret


move:
    # a0: direction of the car (foward = 1 or backward = -1)
    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # Storing “1” enables the hand break
    li t1, MEMORY_SPACE
    addi t1, t1, 0x22
    li a1, 0
    sb a1, 0(t1)

    # ------------------------------ #
    # --- Powering on the engine --- #
    # ------------------------------ #
    # base + 0x21
    # Sets the engine direction
    # foward = 1 | off = 0 | backward = -1
    li t1, MEMORY_SPACE
    addi t1, t1, 0x21
    sb a0, 0(t1)
    ret


steering:
    # a0: value between -180 and 180
    # -------------------------------------------- #
    # --- Setting the steering wheel direction --- #
    # -------------------------------------------- #
    # base + 0x20
    # Negative values indicate steering to the left
    # Positive values indicate steering to the right
    li t1, MEMORY_SPACE
    addi t1, t1, 0x20
    sb a0, 0(t1)
    ret


power_off:
    # ------------------------------- #
    # --- Powering off the engine --- #
    # ------------------------------- #
    # base + 0x21
    # Sets the engine direction
    # foward = 1 | off = 0 | backward = -1
    li t1, MEMORY_SPACE
    addi t1, t1, 0x21
    li a1, 0
    sb a1, 0(t1)

    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # Storing “1” enables the hand break
    li t1, MEMORY_SPACE
    addi t1, t1, 0x22
    li a1, 1
    sb a1, 0(t1)
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
    # base + 0x18
    # Storing the Z-axis of the car current position
    li t1, MEMORY_SPACE
    addi t1, t1, 0x18
    lw a1, 0(t1)        # a1 = current z-position
    li a2, Z_FINAL      # a2 = final z-position
    bge a1, a2, end_main    # if a1 >= a2 then end_main
    # Going foward
    li a0, 1
    jal move
    # Setting steering wheel
    li a0, -17
    jal steering

    LOOP:
    jal set_gps
    jal get_gps
    li t1, MEMORY_SPACE
    addi t1, t1, 0x18
    lw a1, 0(t1)        # a1 = current z-position
    li a2, Z_FINAL      # a2 = final z-position
    addi a2, a2, -16    # a2 = (final z-position) - 16
    bge a1, a2, end_main    # if a1 >= a2 then end_main
    j LOOP

    end_main:
        jal power_off
        j exit

