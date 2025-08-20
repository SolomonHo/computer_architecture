.globl __start

.rodata
    O_RDWR: .word 0b0000100
    msg1: .string "This is problem 3\n"
    msg2: .string " "
.text

__start:
  li a0, 4
  la a1, msg1
  ecall
  li a0, 13      # ecall code
  la a1, pattern
  lw a2, O_RDWR  # load O_RDWR open flag
  ecall
  # Load address of the input string into a0
  add a1, x0, a0
  li a0, 14      # ecall code
  li a2, 0x10200 # modify to a bigger number if your code is too long
  li a3, 94      # number of bytes to read
  ecall
  li a0, 16
  ecall
  addi t0, x0, 94
  add t1, x0, x0
Shift_ascii:
  add t3, t1, a2
  lb t2, 0(t3)
  addi t2, t2, -32
  add t3, t1, a2
  sb t2, 0(t3)
  addi t1, t1, 1
  bne t0, t1, Shift_ascii
  jal x0, your_function

Exit:
  li a0, 1
  add a1, x0, t0
  ecall
  beq t0, x0, Terminate
  li a0, 4
  la a1, msg2
  ecall
  li a0, 1
  add a1, x0, t1
  ecall
Terminate:
  addi a0, x0, 10
  ecall
################################################################################
# DO NOT MODIFY THE CODE ABOVE
################################################################################

.rodata
     pattern: .string "../../r13921072_hw1/p3/pattern0.txt"
    # pattern: .string "../../r13921072_hw1/p3/pattern1.txt"
    # pattern: .string "../../r13921072_hw1/p3/pattern2.txt"
    # pattern: .string "../../r13921072_hw1/p3/pattern4.txt"
.text

# Write your main function here.
# a2(i.e.,x12) stores the heads address
# store whether there is cycle in t0
# store the entry point in t1
# go to Exit when your function is finish

your_function:
  add t5,a2,x0
  addi a0,x0,94
  addi a6,x0,1
  add t4,x0,x0
  addi t6,x0,127
  li a5,0x10400
  sb a6,0(a5)
Initialize:
  sb x0,1(a5)
  addi t4,t4,1 #t4=1~128
  add a5,a5,t4
  blt t4,t6,Initialize #clear array
  li a5,0x10400  
  sb a6,0(a2)
Start: 
  li a5,0x10400 
  lb s1,0(t5)
  beq s1,a0,null
  add a5,s1,a5
  add t5,s1,a2 
  jal x0,check
next:
  add t5,a2,s1 #next index
  bne s1,a0,Start
End:
  jal x0, Exit
 
check:
  lb a1,0(a5)
  sb a6,0(a5)
  bne a1,a6,next
  addi t0,x0,1 #have cycle
  add t1,x0,s1
  jal x0,End
  
null:
  add t0,x0,x0 #no cycle
  add t1,x0,x0
  jal x0, Exit