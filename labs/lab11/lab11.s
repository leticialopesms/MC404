.text
.globl _start
.globl set_gps
.globl get_gps
.globl power_on
.globl power_off
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
    li a0, MEMORY_SPACE
    addi a0, a0, 0x00
    li a1, 1
    sb a1, 0(a0)
    ret


get_gps:
    # base + 0x00
    # Checking if the GPS already got all the info needed
    # Busy Waiting
    # The value on a0 is set to 0 when the reading is completed
    li a0, MEMORY_SPACE
    addi a0, a0, 0x00
    lb a1, 0(a0)
    bnez a1, get_gps
    ret


power_on:
    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # Storing “1” enables the hand break
    li a0, MEMORY_SPACE
    addi a0, a0, 0x22
    li a1, 0
    sb a1, 0(a0)

    # ------------------------------ #
    # --- Powering on the engine --- #
    # ------------------------------ #
    # base + 0x21
    # Sets the engine direction
    # foward = 1 | off = 0 | backward = -1
    li a0, MEMORY_SPACE
    addi a0, a0, 0x21
    li a1, 1
    sb a1, 0(a0)
    ret


power_off:
    # ------------------------------- #
    # --- Powering off the engine --- #
    # ------------------------------- #
    # base + 0x21
    # Sets the engine direction
    # foward = 1 | off = 0 | backward = -1
    li a0, MEMORY_SPACE
    addi a0, a0, 0x21
    li a1, 0
    sb a1, 0(a0)

    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # Storing “1” enables the hand break
    li a0, MEMORY_SPACE
    addi a0, a0, 0x22
    li a1, 1
    sb a1, 0(a0)
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
    li a0, MEMORY_SPACE
    addi a0, a0, 0x18
    lw a1, 0(a0)
    li a2, Z_FINAL
    bge a2, a1, move_foward # if a2 >= a1 then move_foward
    j end_main

    move_foward:
    jal power_on

    LOOP:
    jal set_gps
    jal get_gps
    li a0, MEMORY_SPACE
    addi a0, a0, 0x18
    lw a1, 0(a0)
    li a2, Z_FINAL
    bge a2, a1, LOOP # if a2 >= a1 then LOOP
    j end_main

    end_main:
        jal power_off
        j exit

