.global get_elemnt_from_matrix, multiplyMatrices
.extern set_elemnt_in_matrix

.section .text
get_elemnt_from_matrix:                 # rdi = matrix ,rsi=n ,rcx=i, rdx=j
    xor %rax,%rax                       # return matrix[i][j]
    push %rbp
    movq %rsp,%rbp                  
    subq $16,%rsp               
    pushq %r12                          # callee saved
    mov %edx,%r12d                      # we override rdx in mul
    mov %ecx,%eax                       # rax = i
    mul %esi                            # rax = i*n
    add %r12d,%eax                      # rax = i*n + j
    imul $4,%eax                        # rax = 4*(i*n + j) elem of matrix are ints
    mov (%rax,%rdi,1),%eax              # eax = mem[matrix+offset_in_matrix] = mem[i][j]
    popq %r12                           # restore value
    leave
    ret

set_elemnt:                             # rdi = matrix, rsi=n, rcx=i, rdx=j, r8=val
    xor %rax,%rax                       # matrix[i][j] = val
    push %rbp
    movq %rsp,%rbp
    subq $16,%rsp
    pushq %r12                          # callee saved
    mov %edx,%r12d                      # we override rdx in mul
    mov %ecx,%eax                       # rax = i 
    mul %esi                            # rax = i*n
    add %r12d,%eax                      # rax = i*n + j
    imul $4,%eax                        # rax = 4*(i*n + j) elem of matrix are ints
    movl %r8d,(%rax,%rdi,1)             # mem[matrix+offset_in_matrix] = mem[i][j] = val
    popq %r12                           # restore value
    leave
    ret
    
val_i_j:                                # rdi = first, rsi=second, rcx=i, rdx=j, r8=n, r9=p, stack=r
    push %rbp
    movq %rsp,%rbp
    subq $64,%rsp                       # prolog
    pushq %r13
    pushq %r14
    pushq %r12
    mov 16(%rbp),%r12d                  # r12 = r
    xor %r14,%r14                       # sum_of_mult = 0
    xor %r10,%r10                       # counter = 0 
    loop_mul:
        pushq %rsi                  
        pushq %rdx
        mov %r8d,%esi
        mov %r10d,%edx                  
        call get_elemnt_from_matrix     # first_val = get_elemnt_from_matrix(first, n, i, counter)
        popq %rdx
        popq %rsi
        
        pushq %rax                      # save first_val
     
        pushq %rdi
        pushq %rsi
        pushq %rcx
        pushq %rdx
        mov %rsi,%rdi
        mov %r12d,%esi
        mov %r10d,%ecx
        call get_elemnt_from_matrix     # second_val = get_elemnt_from_matrix(second, r, counter, j)
        popq %rdx
        popq %rcx
        popq %rsi
        popq %rdi
        popq %r13 
        pushq %rdx
        mul %r13d                       # rax = first_val * second_val
        popq %rdx
        add %eax,%r14d                  # sum_of_mult += rax
        inc %r10d                       # counter++
        cmp %r10d,%r8d                  # while (counter < n )                 
        jg loop_mul
    mov %r14d,%eax                      # rax = sum_of_mult
    xor %rdx,%rdx                       # rdx = 0 
    div %r9d                            # rbx = sum_of_mult mod p 
    mov %edx,%eax                       # return_value = rbx
    popq %r12
    popq %r14
    popq %r13
    leave
    ret
multiplyMatrices:                       # rdi = first, rsi=second, rdx=result, rcx=m, r8=n, r9=r, stack=p
                                        # calc result[i][j] for every elem in first * second
    push %rbp
    movq %rsp,%rbp
    subq $80,%rsp                       # prolog
    movq 16(%rbp),%r12                  # r12 = p
    xor %rax,%rax
    xor %r10,%r10                       # i = 0
    loop_rows:
        xor %r11,%r11                   # j = 0 
        loop_col:
        
            pushq %rcx
            pushq %rdx
            pushq %r8
            pushq %r10
            pushq %r11
            pushq %r9
            mov %r10d,%ecx
            mov %r11d,%edx
            pushq %r9
            mov %r12d,%r9d
            call val_i_j                # calc val_i_j(first, second, i, j, n, p, r)
            popq %r9
            popq %r9
            popq %r11
            popq %r10
            popq %r8
            popq %rdx
            popq %rcx
            
            pushq %rdi
            pushq %rsi
            pushq %rcx
            pushq %rdx
            pushq %r8
            pushq %r9
            pushq %r10
            pushq %r11
            movq %rdx,%rdi  
            mov %r9d,%esi
            mov %r10d,%ecx
            mov %r11d,%edx
            mov %eax,%r8d 
            call set_elemnt             # set result[i][j] = calc val_i_j(first, second, i, j, n, p, r)
            popq %r11
            popq %r10
            popq %r9
            popq %r8
            popq %rdx
            popq %rcx
            popq %rsi
            popq %rdi
     
            inc %r11d                   # j++
            cmp %r11d,%r9d              # while (j < n)
            jg loop_col
        inc %r10d                       # i++
        cmp %r10d,%ecx                  # while (j < m)
        jg loop_rows
        
end:  
	leave
	ret