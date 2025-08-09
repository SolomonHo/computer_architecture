## Computer_Architecture

This project is designed to help me become familiar with assembly language syntax. It uses RISC-V to implement a few simple algorithms.


hw1_p1.s implements the Extended Euclidean Algorithm using RISC-V assembly language. The program calculates the greatest common divisor (GCD) of two input numbers and finds their corresponding coefficients.

# Phase 1: Calculating the GCD and Storing Quotients
The program first compares the two input numbers and uses the BGE (Branch Greater or Equal) instruction to ensure the larger number is processed first.

It then enters a loop, using the DIV (divide) and REM (remainder) instructions to calculate the quotient and remainder.

In each iteration, the calculated quotient is pushed onto the stack for temporary storage.

The loop terminates when the remainder becomes 0. The last non-zero remainder is the GCD of the two numbers.

# Phase 2: Calculating the Coefficients
After the GCD is found, the program sequentially pops the previously stored quotients from the stack.

Using a reverse iterative formula, these quotients are used to calculate the coefficients of the Extended Euclidean Algorithm.
