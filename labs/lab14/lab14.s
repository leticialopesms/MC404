.text
.align 4

.section .text
# base address of General Purpose Timer
.set base_GPT,  0xFFFF0100
# base address of MIDI Synthesizer
.set base_MIDI, 0xFFFF0300

.globl play_note
.globl _system_time
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
    # If exit is called, then there is a problem in the code
    # the song is supposed to play on repeat
    j exit
    
int_handler:
    ###### Syscall and Interrupts handler ######
    # <= Implement your syscall handler here
    csrr t0, mepc   # load return address (address of
                    # the instruction that invoked the syscall)
    addi t0, t0, 4  # adds 4 to the return address (to return after ecall)
    csrw mepc, t0   # stores the return address back on mepc
    mret            # Recover remaining context (pc <- mepc)

.globl _start
_start:
    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                        # the interrupt array.

# Write here the code to change to user mode and call the function
# user_main (defined in another file). Remember to initialize
# the user stack so that your program can use it.

.globl control_logic
control_logic:
    # implement your control logic here, using only the defined syscalls


# IMPLEMENTAR:
    # Syscall_set_engine_and_steering:
        # Code: 10
        # Parameters:
        # a0 (dir): moviment direction
        # a1 (angle): steering wheel angle
        # Returns:  0, if successful
        #           1, if failed (invalid parameters)
        #  