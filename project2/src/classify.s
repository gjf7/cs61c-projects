.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # check number of command line args
    li t0, 5
    li t1, 89
    bne a0, t0, fail

	# =====================================
    # LOAD MATRICES
    # =====================================
    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)

    mv s0, a1
    mv s1, a2

    # allocate memory to prepare load m0
    li a0, 4
    jal malloc_with_error_handled
    mv s3, a0

    li a0, 4
    jal malloc_with_error_handled
    mv s4, a0

    # Load pretrained m0
    lw a0, 4(s0)
    mv a1, s3
    mv a2, s4
    jal read_matrix
    mv s2, a0



    # allocate memory to prepare load m1
    li a0, 4
    jal malloc_with_error_handled
    mv s6, a0

    li a0, 4
    jal malloc_with_error_handled
    mv s7, a0

    # Load pretrained m1
    lw a0, 8(s0)
    mv a1, s6
    mv a2, s7
    jal read_matrix
    mv s5, a0

    # allocate memory to prepare load input
    li a0, 4
    jal malloc_with_error_handled
    mv s9, a0

    li a0, 4
    jal malloc_with_error_handled
    mv s10, a0

    # Load input matrix
    lw a0, 12(s0)
    mv a1, s9
    mv a2, s10
    jal read_matrix
    mv s8, a0


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    # allocate memory to prepare to call matmul
    lw t0, 0(s3)
    lw t1, 0(s10)
    mul t0, t0, t1
    slli a0, t0, 2
    jal malloc_with_error_handled
    mv s11, a0 
    mv a0, s2 
    lw a1, 0(s3)
    lw a2, 0(s4)
    mv a3, s8
    lw a4, 0(s9)
    lw a5, 0(s10)
    mv a6, s11
    jal matmul
    
    mv a0, s11
    lw t0, 0(s3)
    lw t1, 0(s10)
    mul a1, t0, t1
    jal relu

    # allocate memory to prepare to call matmul
    lw t0, 0(s6)
    lw t1, 0(s7)
    mul t0, t0, t1
    slli a0, t0, 2
    jal malloc_with_error_handled
    addi sp, sp, -4
    sw a0, 0(sp)
    mv a6, a0
    mv a0, s5
    lw a1, 0(s6)
    lw a2, 0(s7)
    mv a3, s11
    lw a4, 0(s3)
    lw a5, 0(s10)
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s0)
    lw a1, 0(sp)
    lw a2, 0(s6)
    lw a3, 0(s10)
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    lw a0, 0(sp)
    addi sp, sp, 4
    lw t0, 0(s3)
    lw t1, 0(s4)
    mul a1, t0, t1
    jal argmax

    bnez s1, Done
    # Print classification
    mv a1, a0
    jal print_int

    # Print newline afterwards for clarity
    li a1 '\n'
    jal print_char
    
Done:
    # Free all allocated memory
    mv a0, s2
    jal free

    mv a0, s3
    jal free
    
    mv a0, s4
    jal free

    mv a0, s5
    jal free

    mv a0, s6
    jal free

    mv a0, s7
    jal free

    mv a0, s8
    jal free

    mv a0, s9
    jal free

    mv a0, s10
    jal free

    mv a0, s11
    jal free
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52

    ret

malloc_with_error_handled:
    addi sp, sp, -4
    sw ra, 0(sp)
    jal malloc
    li t1, 88
    beqz a0, fail
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

fail:
    li a0, 17
    mv a1, t1
    ecall
