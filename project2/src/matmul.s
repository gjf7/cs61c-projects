.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    li t0, 1
    mv t1 a1
    li a1, 72
    blt t1, t0, error
    blt a2, t0, error
    bne t1, a2, error
    
    li a1, 73
    blt a4, t0, error
    blt a5, t0, error
    bne a4, a5, error
    
    li a1, 74
    bne t1, a4, error

    # Prologue
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    sw s7, 32(sp)
    mv s0, a0
    mv s1, a3
    mv s2, t1       # height
    mv s3, a2       # width
    mv s4, a6
    li s5, 0        # row counter
    li s6, 0        # column counter



outer_loop_start:
    bge s5, s2, outer_loop_end
    mul s7, s5, s3
    slli s7, s7, 2
    add s7, s7, s0



inner_loop_start:
    bge s6, s3, inner_loop_end
    # prepare to call dot
    mv a0, s7
    slli t0, s6, 2
    add a1, s1, t0
    mv a2 s3
    li a3, 1
    mv a4, a2
    jal dot
    # store answer to d
    mul t1, s5, s3
    add t1, t1, s6
    slli t1, t1, 2
    add t2, t1, s4
    sw a0, 0(t2)
    addi s6, s6, 1
    j inner_loop_start












inner_loop_end:
    addi s5, s5, 1
    mv s6, x0
    j outer_loop_start




outer_loop_end:


    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36
    
    mv a0, x0
    
    ret

error:
    li a0, 17
    ecall