.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    # should check stide and length
    li t0, 1
    li t1, 75               # error code
    blt a2, t0, exception
    li t1, 76               # error code
    blt a3, t0, exception
    blt a4, t0, exception
    li t2, 0 # counter
    li t3, 0 # result
loop_start:
    bge t2, a2, loop_end
    slli t4, t2, 2
    mul t4, t4, a3
    add t4, t4, a0
    slli t5, t2, 2
    mul t5, t5, a4
    add t5, t5, a1
    lw t4, 0(t4)
    lw t5, 0(t5)
    mul t6, t4, t5
    add t3, t3, t6
    addi t2, t2, 1 # counter + 1
    j loop_start




loop_end:
    mv a0, t3

    # Epilogue

    
    ret

exception:
    li a0, 17
    mv a1, t1
    ecall