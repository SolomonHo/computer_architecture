.globl __start

.rodata
    msg0: .string "This is HW1-2: Longest Substring without Repeating Characters\n"
    msg1: .string "Enter a string: "
    msg2: .string "Answer: "
.text

# Please use "result" to print out your final answer
################################################################################
# result function
# Usage: 
#     1. Store the beginning address in t4
#     2. Use "j print_char"
#     The function will print the string stored t4
#     When finish, the whole program will return value 0
result:
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    add a1, x0, t4
    ecall
# Ends the program with status code 0
    addi a0, x0, 10
    ecall
################################################################################

__start:
# Prints msg
    addi a0, x0, 4
    la a1, msg0
    ecall
    
    la a1, msg1
    ecall
    
    addi a0, x0, 8
    
    li a1, 0x10200
    addi a2, x0, 2047
    ecall
# Load address of the input string into a0
    add a0, x0, a1

################################################################################
# DO NOT MODIFY THE CODE ABOVE
################################################################################  
# Write your main function here. 
# a0 stores the beginning address (66048(0x10200)) of the  Plaintext

    li t0,0x10400 #t0=array
    add t1,x0,x0 #length
    add a1,a0,x0 #a1=left
    add a2,a0,x0 #a2=right 
    add t2,x0,x0
    addi s1,x0,128
    addi s2,x0,1
    addi sp,sp,-12

Initialize:
    sb x0,0(t0)
    addi t2,t2,1 #t2=0~128
    add t0,t0,t2
    blt t2,s1,Initialize #clear array

Loop:
    lb t3,0(a2) #t3=R char
    beq t3,x0,finish
    add t3,t0,t3 #t3=R addr 
check:
    lb a4,0(t3)
    sb s2,0(t3) #mark char
    beq a4,s2,shift #check whether appear
    sub a3,a2,a1
    add t1,a3,s2 #t1=len=R-L+1
    add a2,a2,s2 # right +1
    lw t5,0(sp)
    blt t1,t5,Loop #put max len in stack
    addi sp,sp,12
    addi sp,sp,-12
    sw a1,8(sp)
    sw a2,4(sp)
    add t1,t1,s2
    sw t1,0(sp) #store max len
    jal x0,Loop

finish:
    lw a1,8(sp)
    lw a2,4(sp)
L_to_R:
    sb x0,0(a2) #add extra
    addi a2,a2,1 
    add a5,a5,s2
    blt a5,s1,L_to_R
    add t4,x0,a1
    jal x0,result

shift:
    lb t6,0(a1) #L char
    add t6,t0,t6 #t6=L addr
    sb x0,0(t6)
    add a1,a1,s2 #left+1 
    lb s3,0(a1)
    lb a6,0(a2)
    #lb t3,0(a2)
    #add t3,t3,t0
    beq a1,a2,check
    beq s3,a6,shift
    jal x0,check
  
    
    

    
    
    
    
    
    
    
 
