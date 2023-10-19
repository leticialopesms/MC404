.text
.set DISPLAY_CONTROL_REG_PORT, 0x00000040
.set FLOOR_DATA_REG_PORT, 0x00000080

update_display:
    li a0, FLOOR_DATA_REG_PORT # Reads the floor number and
    lb a1, (a0) # store into a1
    la a0, floor_to_pattern_table # Converts the floor number 
    add t0, a0, a1 # into a configuration
    lb a1, (t0) # byte
    li a0, DISPLAY_CONTROL_REG_PORT # Sets the display controller 
    sb a1, (a0) # with the configuration byte
    ret # Returns

floor_to_pattern_table:
 .byte 0x7e,0x30,0x6d,0x79,0x33,0x5b,0x5f,0x70,0x7f,0x7b




.text
.set DATA_REG_PORT, 0x00000050
.set STAT_REG_PORT, 0x00000051
.set READY_MASK, 0b00000001
.set OVRN_MASK, 0b00000010

read_keypad:
    li a0, STAT_REG_PORT # Reads the keypad 
    lb a0, 0(a0) # status into a0
    andi t0, a0, READY_MASK # Check the READY bit and
    beqz t0, read_keypad # until it is equal to 1
    andi t0, a0, OVRN_MASK # Check if OVRN bit and jump
    bnez t0, ovrn_occured # to ovrn_occured if equals to 1
    la a0, DATA_REG_PORT # Reads the key from the 
    lb a0, 0(a0) # data register into a0
    ret # Return
ovrn_occured:
    li a0, -1 # Returns -1
    ret # Return