.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)
    mv s0, a0
    mv s1, a1
    mv s2, a2

    mv a1, a0
    li a2, 0
    jal fopen
    li t0, -1
    li t1, 90
    beq a0, t0, fail
    
    mv s0, a0

    # read rows
    mv a1, s0
    mv a2, s1
    li a3, 4
    jal fread
    li t0, 4
    li t1, 91
    bne a0, t0, fail

    # read columns
    mv a1, s0
    mv a2, s2
    li a3, 4
    jal fread
    li t0, 4
    li t1, 91
    bne a0, t0, fail

    lw t0, 0(s1) # get rows
    lw t1, 0(s2) # get columns
    mul a0, t0, t1
    slli a0, a0, 2   # number of bytes read from file 
    mv s1, a0 # we need this later
    jal malloc
    # make sure memory allocated
    li t1, 88
    beqz a0, fail
    mv s2, a0 # we also need this later

    # do the actual read
    mv a1, s0
    mv a2, s2
    mv a3, s1
    jal fread
    bne a0, s1, fail
    
    # close after read
    mv a1, s0
    jal fclose
    li t0, -1
    li t1, 92
    beq a0, t0, fail


    # Epilogue
    mv a0, s2
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

fail:
    li a0, 17
    mv a1, t1
    ecall