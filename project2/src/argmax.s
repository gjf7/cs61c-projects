.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue
    li t0, 1
    bge a1, t0, loop_start
    li a0, 17
    li a1, 77
    ecall


loop_start:
    li t1, 0 # counter
    li t2, 0 # index of max element
    lw t3, 0(a0) # value of max element


loop_continue:
    bge t1, a1, loop_end
    slli t4, t1, 2
    add t4 a0, t4
    lw t4, 0(t4)
    addi t1, t1, 1 # counter + 1
    blt t3, t4, update_max
    j loop_continue


loop_end:
    mv a0, t2

    # Epilogue


    ret

update_max:
    mv t3 t4
    addi t5, t1, -1
    mv t2 t5
    j loop_continue