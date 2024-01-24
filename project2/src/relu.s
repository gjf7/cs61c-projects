.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    li t0, 1
    bge a1, t0, loop_start
    li a0, 17           # ends the program with error code
    li a1, 78
    ecall
loop_start:
    li t1, 0 # counter







loop_continue:
    bge t1, a1, loop_end
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    bge t4, x0, continue
    sw x0, 0(t3)
    addi t1, t1, 1 # increase counter
    j loop_continue


loop_end:
    mv a0, x0

    # Epilogue

    
	ret

continue:
    addi t1, t1, 1
    j loop_continue
