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


main:
    # ----------- #
    # --- GPS --- #
    # ----------- #
    # base + 0x00
    # Storing “1” triggers the GPS device to start reading
    li a0, MEMORY_SPACE
    addi a0, a0, 0x00
    li a1, 1
    sb a1, 0(a0)

    # ------------------------- #
    # --- Ultrasonic Sensor --- #
    # ------------------------- #
    # base + 0x02
    # Storing “1” triggers the Ultrasonic Sensor to measure the
    # distance between the car and the obstacle in front of it
    li a0, MEMORY_SPACE
    addi a0, a0, 0x02
    li a1, 0
    sb a1, 0(a0)

    # ------------------ #
    # --- Hand break --- #
    # ------------------ #
    # base + 0x22
    # Storing “1” enables the hand break
    li a0, MEMORY_SPACE
    addi a0, a0, 0x22
    li a1, 0
    sb a1, 0(a0)

    # check_x:
    # # ------------------------------- #
    # # --- Checking the X position --- #
    # # ------------------------------- #
    # # base + 0x10
    # # Stores the X-axis of the car current position
    # li a0, MEMORY_SPACE
    # addi a0, a0, 0x10
    # lw a1, 0(a0)
    # li a2, X_FINAL
    # bge a1, a2, move_foward # if a1 >= a2 then move_foward
    # j end_main

    check_z:
    # ------------------------------- #
    # --- Checking the Z position --- #
    # ------------------------------- #
    # base + 0x18
    # Stores the X-axis of the car current position
    li a0, MEMORY_SPACE
    addi a0, a0, 0x18
    lw a1, 0(a0)
    li a2, Z_FINAL
    bge a1, a2, move_foward # if a1 >= a2 then move_foward
    j end_main

    move_foward:
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

    LOOP:
    li a0, MEMORY_SPACE
    addi a0, a0, 0x18
    lw a1, 0(a0)
    li a2, Z_FINAL
    bge a2, a1, LOOP # if a1 >= a2 then LOOP

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

    j end_main

    end_main:
        # ------------------ #
        # --- Hand break --- #
        # ------------------ #
        # base + 0x22
        # Storing “1” enables the hand break
        li a0, MEMORY_SPACE
        addi a0, a0, 0x22
        li a1, 1
        sb a1, 0(a0)

        # ------------------------- #
        # --- Ultrasonic Sensor --- #
        # ------------------------- #
        # base + 0x02
        # Storing “0” triggers the Ultrasonic Sensor to stop measurig the
        # distance between the car and the obstacle in front of it
        li a0, MEMORY_SPACE
        addi a0, a0, 0x02
        li a1, 0
        sb a1, 0(a0)

        # ----------- #
        # --- GPS --- #
        # ----------- #
        # base + 0x00
        # Storing “0” triggers the GPS device to stop reading
        li a0, MEMORY_SPACE
        addi a0, a0, 0x00
        li a1, 0
        sb a1, 0(a0)
        
        j exit

