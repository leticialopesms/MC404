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

    # --------------------------------------------------------------- #
    # --- Checking if it was an INTERRUPT (1) or an EXCEPTION (0) --- #
    # --------------------------------------------------------------- #
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
    
    # --- Setting current system time --- #
    la t2, _system_time # t2 = address of _system_time variable
    lw t1, 0(t2)        # loading the value from _system_time
    addi t1, t1, 100    # t1 = t1 + 100 ms
    sw t1, 0(t2)        # updating _system_time

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
    sh a4, 6(t0)    # stores 16 bits on memory address base_MIDI + 0x06

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
_system_time: .word 0
.align 4
program_stack:  .skip 0x1000  # stores 0x1000 bits = 4 Kb
program_stack_end:
.align 4
ISR_stack:      .skip 0x1000  # stores 0x1000 bits = 4 Kb
isr_stack_end:
