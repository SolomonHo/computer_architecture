.globl __start

.rodata
    msge: .string "\n "
    msg0: .string "This is HW1-1: Extended Euclidean Algorithm\n"
    msg1: .string "Enter a number for input x: "
    msg2: .string "Enter a number for input y: "
    msg3: .string "The result is:\n "
    msg4: .string "GCD: "
    msg5: .string "a: "
    msg6: .string "b: "
    msg7: .string "inv(x modulo y): "

.text
################################################################################
  # You may write function here
Base:
    add s0,a1,x0 #when gcd=last value
    add s1,x0,x0
    addi s2,x0,1    
    bne t4,t3,result
    add t5,s1,x0
    add s1,s2,x0
    add s2,t5,x0
    jal x0,result
################################################################################
__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads int1
    addi a0, x0, 5
    ecall
    add t0, x0, a0
    
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall
    
  # Reads int2
    addi a0, x0, 5
    ecall
    add a1, x0, a0
    add a0, x0, t0
    addi t0, x0, 0
        
################################################################################ 
  # You can do your main function here
    addi t3,t3,1 #def constant t3=1
    add t6,a1,x0
    bge a0,a1,swap #small to large
    jal x0,start
swap:
    add t0,a0,x0
    add a0,a1,x0
    add a1,t0,x0
    addi t4,x0,1
start:
    beq a0,x0,Base
GCD:
    addi sp,sp,-4
    addi a2,a2,1#count
    div t0,a1,a0
    rem t1,a1,a0 #store remainder
    sw t0,0(sp) #store quotient
    add a1,a0,x0
    add a0,t1,x0
    bne a0,x0,GCD  
    add s0,a1,x0 #when gcd=last value
    add s1,x0,x0
    addi s2,x0,1
    add s3,x0,x0 
    
recursive:
    lw t1,0(sp) #advanced quotient
    mul t1,t1,s1
    sub t1,s2,t1
    add s2,s1,x0 #get b 
    add s1,t1,x0 #get a
    sub a2,a2,t3 #countdown
    addi sp,sp,4
    blt x0,a2,recursive
    bne t4,t3,judge
    add t5,s1,x0
    add s1,s2,x0
    add s2,t5,x0
judge:
    beq s0,t3,inv #if gcd=1,do inv module
    jal x0,result
inv:
    add s3,s1,x0
    blt x0,s3,result
    add s3,s3,t6
    jal x0,result

    
################################################################################

result:
    addi t0,a0,0
  # Prints msg
    addi a0, x0, 4
    la a1, msg3
    ecall
    
    addi a0, x0, 4
    la a1, msg4
    ecall

  # Prints the result in s0
    addi a0, x0, 1
    add a1, x0, s0
    ecall
    
    addi a0, x0, 4
    la a1, msge
    ecall
    addi a0, x0, 4
    la a1, msg5
    ecall
    
  # Prints the result in s1
    addi a0, x0, 1
    add a1, x0, s1
    ecall
    
    addi a0, x0, 4
    la a1, msge
    ecall
    addi a0, x0, 4
    la a1, msg6
    ecall
    
  # Prints the result in s2
    addi a0, x0, 1
    add a1, x0, s2
    ecall
    
    addi a0, x0, 4
    la a1, msge
    ecall
    addi a0, x0, 4
    la a1, msg7
    ecall
    
  # Prints the result in s3
    addi a0, x0, 1
    add a1, x0, s3
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall