_start:
    jal main


exit:
    li a7, 93   # syscall exit (93)
    ecall


read:
    li a0, 0                # file descriptor = 0 (stdin)
    la a1, input_address    # buffer to write the data
    li a2, 4                # size (reads only 4 bytes)
    li a7, 63               # syscall read (63)
    ecall
    ret


write:
    li a0, 1                # file descriptor = 1 (stdout)
    la a1, string           # buffer
    li a2, 19               # size
    li a7, 64               # syscall write (64)
    ecall
    ret


main:
    # jal read
    # addi a2, a1, -48
    jal write


.data
string:  .asciz "Hello! It works!!!\n"
input_address: .skip 0x10  # buffer
output_address: .skip 0x10  # buffer
